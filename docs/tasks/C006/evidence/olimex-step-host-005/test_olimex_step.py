"""Device-free dispatch checks: all subprocess execution is mocked."""
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
import argparse
import contextlib
import hashlib
import importlib.util
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

TASK = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('step', TASK / 'olimex_step.py')
step = importlib.util.module_from_spec(spec)
spec.loader.exec_module(step)


class Dispatch(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='bbc-olimex-host-', dir='/tmp')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bundle = self.root / 'bundle'
        (self.bundle / 'payload').mkdir(parents=True)
        self.fixture = dict(fixture_path='/extender/diagnostics/bbc-basic/host-test',
                            result_path='/agents/extender/results/bbc-basic/host-test')
        (self.bundle / 'fixture.json').write_text(json.dumps(self.fixture))
        (self.bundle / 'payload/test.dat').write_bytes(b'Host-only fixture; never executed')
        manifest = {str(p.relative_to(self.bundle)): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in self.bundle.rglob('*') if p.is_file()}
        (self.bundle / 'manifest.json').write_text(json.dumps(manifest))
        self.config = self.root / 'config.json'
        self.config.write_text(json.dumps(dict(extender_url='http://127.0.0.1')))
        self.record = self.root / 'receipt'

    def invoke(self, *operation, effect=None):
        argv = ['olimex_step.py', '--config', str(self.config), '--bundle', str(self.bundle),
                '--lease', 'host-test-only-not-a-real-lease', '--record', os.path.relpath(self.record), *operation]
        with patch.object(sys, 'argv', argv), patch.object(step.subprocess, 'run',
                side_effect=effect, return_value=SimpleNamespace(stdout='{}')) as run:
            try:
                with contextlib.redirect_stdout(io.StringIO()):
                    step.main()
            finally:
                self.calls = run.call_args_list
            return run.call_args_list

    def test_invalid_lease_prevents_target_operation(self):
        error = subprocess.CalledProcessError(1, ['mock-owner-check'])
        with self.assertRaises(subprocess.CalledProcessError):
            self.invoke('type', 'MEM', effect=error)
        self.assertEqual(len(self.calls), 1)
        self.assertIn('assert-owner', self.calls[0].args[0])
        receipt = json.loads((self.record / 'receipt.json').read_text())
        self.assertFalse(receipt['hardware_action_attempted'])
        self.assertFalse(receipt['completed'])

    def test_every_status_query_has_its_own_owner_check(self):
        calls = self.invoke('status')
        self.assertEqual(len(calls), 6)
        for i in (0, 2, 4):
            self.assertIn('assert-owner', calls[i].args[0])
        for i in (1, 3, 5):
            command = calls[i].args[0]
            self.assertEqual(command[-1], 'status')
            self.assertTrue(Path(command[command.index('--state')+1]).is_absolute())

    def test_retrieval_uses_new_staged_client_and_absolute_output(self):
        target = self.root / 'download.dat'
        remote = self.fixture['result_path']+'/result.dat'

        def fake(command, **kwargs):
            if command[-1] == 'status':
                kwargs['stdout'].write(json.dumps(dict(online=True, protocol=2)))
            if 'get' in command:
                self.assertEqual(Path(command[1]).name, 'sdcard_staged.py')
                self.assertTrue(Path(command[-1]).is_absolute())
                Path(command[-1]).write_bytes(b'Mocked retrieval only')
            return SimpleNamespace(stdout='{}')

        calls = self.invoke('get', remote, os.path.relpath(target), effect=fake)
        self.assertEqual(len(calls), 4)
        self.assertEqual(target.read_bytes(), b'Mocked retrieval only')

    def test_upload_outside_manifest_stops_before_lease_or_device(self):
        other = self.root / 'other.dat'
        other.write_bytes(b'Not an approved payload')
        with self.assertRaises(AssertionError):
            self.invoke('put', str(other), self.fixture['fixture_path']+'/other.dat')
        self.assertFalse(self.record.exists())

    def test_wrong_listener_protocol_prevents_transfer_submission(self):
        def fake(command, **kwargs):
            if command[-1] == 'status':
                kwargs['stdout'].write(json.dumps(dict(online=True, protocol=1)))
            return SimpleNamespace(stdout='{}')
        with self.assertRaises(AssertionError):
            self.invoke('get', self.fixture['result_path']+'/result.dat',
                        str(self.root / 'download.dat'), effect=fake)
        self.assertEqual(len(self.calls), 2)
        self.assertEqual(self.calls[1].args[0][-1], 'status')

    def test_remote_parent_traversal_stops_before_lease_or_device(self):
        remote = self.fixture['result_path']+'/../other/result.dat'
        with self.assertRaises(AssertionError):
            self.invoke('get', remote, str(self.root / 'download.dat'))
        self.assertFalse(self.record.exists())

    def test_exit_waits_for_offline_and_no_pending_after_acknowledgement(self):
        observed = []

        def fake(command, **kwargs):
            if command[-1] == 'status':
                observed.append(len(observed))
                kwargs['stdout'].write(json.dumps(dict(protocol=2,
                    online=len(observed)==1, pending=len(observed)==2)))
            return SimpleNamespace(stdout='{}')

        calls = self.invoke('exit', effect=fake)
        self.assertEqual(len(calls), 8)
        for call in calls[::2]:
            self.assertIn('assert-owner', call.args[0])
        self.assertEqual(len(observed), 3)
        receipt = json.loads((self.record / 'receipt.json').read_text())
        self.assertTrue(receipt['exit_acknowledged'])
        self.assertTrue(receipt['listener_offline_observed'])
        self.assertTrue(receipt['completed'])

    def test_uncertain_exit_stops_without_new_session_or_retry(self):
        def fake(command, **kwargs):
            if command[-1] == 'status':
                kwargs['stdout'].write(json.dumps(dict(protocol=2, online=True, pending=False)))
            if command[-1] == 'exit':
                raise subprocess.CalledProcessError(1, command)
            return SimpleNamespace(stdout='{}')

        with self.assertRaises(subprocess.CalledProcessError):
            self.invoke('exit', effect=fake)
        self.assertEqual(len(self.calls), 4)
        self.assertEqual(sum(c.args[0][-1]=='exit' for c in self.calls), 1)
        receipt = json.loads((self.record / 'receipt.json').read_text())
        self.assertFalse(receipt['completed'])
        self.assertNotIn('listener_offline_observed', receipt)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--name', required=True)
    a = p.parse_args()
    stream = io.StringIO()
    result = unittest.TextTestRunner(stream=stream, verbosity=2).run(
        unittest.defaultTestLoader.loadTestsFromTestCase(Dispatch))
    print(stream.getvalue(), end='')
    assert result.wasSuccessful()
    out = TASK / 'evidence' / a.name
    out.mkdir(parents=True, exist_ok=False)
    for source in [Path(__file__), TASK / 'olimex_step.py']:
        shutil.copy2(source, out / source.name)
    (out / 'tests.log').write_text(stream.getvalue())
    (out / 'results.json').write_text(json.dumps(dict(tests=result.testsRun,
        all_passed=True, subprocess_calls_mocked=True, network_or_serial_access=False,
        hardware_validation=False,
        scope='Host-only owner-check/dispatch/journal boundary qualification'), indent=2)+'\n')
    (out / 'manifest.json').write_text(json.dumps({q.name: hashlib.sha256(q.read_bytes()).hexdigest()
        for q in out.iterdir() if q.is_file()}, indent=2)+'\n')


if __name__ == '__main__':
    main()
