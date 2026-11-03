"""Journal one explicit Olimex operation through maintained Extender tools.

Requires an existing physical lease and a qualified offline bundle. It neither
reserves the bench nor dispatches successors/retries, resets or flashes.
Machine addresses, serial identity, lease and operation receipts stay local.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
EXTENDER = ROOT.parent / 'agon-extender'
ENVIRONMENT = ROOT.parent / 'agon-dev-env'
PINNED = EXTENDER / 'agents/remote009/fast-transfer-pin-r01'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config', type=Path, required=True)
    p.add_argument('--bundle', type=Path, required=True)
    p.add_argument('--lease', required=True)
    p.add_argument('--record', type=Path, required=True)
    sub = p.add_subparsers(dest='operation', required=True)
    sub.add_parser('status')
    t = sub.add_parser('type')
    t.add_argument('text')
    m = sub.add_parser('mkdir')
    m.add_argument('remote')
    put = sub.add_parser('put')
    put.add_argument('local', type=Path)
    put.add_argument('remote')
    get = sub.add_parser('get')
    get.add_argument('remote')
    get.add_argument('local', type=Path)
    sub.add_parser('exit')
    capture = sub.add_parser('capture')
    capture.add_argument('--seconds', type=float, default=7200)
    a = p.parse_args()
    a.record = a.record.resolve()
    if a.operation in ('put', 'get'):
        a.local = a.local.resolve()
    config = json.loads(a.config.read_text())
    bundle = a.bundle.resolve(strict=True)
    manifest = json.loads((bundle / 'manifest.json').read_text())
    for name, value in manifest.items():
        path = (bundle / name).resolve(strict=True)
        assert path.is_relative_to(bundle) and digest(path) == value, name
    assert 'fixture.json' in manifest
    fixture = json.loads((bundle / 'fixture.json').read_text())
    roots = [fixture['fixture_path'], fixture['result_path']]
    assert roots[0].startswith('/extender/diagnostics/bbc-basic/')
    assert roots[1].startswith('/agents/extender/results/bbc-basic/')
    if a.operation in ('mkdir', 'put', 'get'):
        assert any(a.remote == root or a.remote.startswith(root+'/') for root in roots)
        assert all(part not in ('', '.', '..') for part in a.remote[1:].split('/'))
    if a.operation == 'put':
        local = a.local.resolve(strict=True)
        assert local.is_relative_to(bundle / 'payload')
        relative = str(local.relative_to(bundle))
        assert relative in manifest and digest(local) == manifest[relative]
    if a.operation == 'get':
        assert not a.local.exists(), 'Preserve previous retrieval'
    if a.operation == 'capture':
        port = Path(config['mainboard_serial'])
        assert port.parent == Path('/dev/serial/by-id')
        port.resolve(strict=True)
        assert 0 < a.seconds <= 7200
    python = EXTENDER / '.venv/bin/python'
    assert python.exists()
    lease_command = [str(ENVIRONMENT / '.venv/bin/python'),
                     str(ENVIRONMENT / 'cross-agent/olimex-bench/bench_lease.py'),
                     'assert-owner', '--owner', 'bbc-basic', '--lease', a.lease]
    a.record.mkdir(parents=True, exist_ok=False)
    report = dict(operation=a.operation, started_epoch=time.time(),
                  bundle=str(bundle), fixture_sha256=digest(bundle / 'fixture.json'),
                  hardware_action_attempted=False, completed=False,
                  scope='One explicit operation; keyboard emission is not MOS completion')
    if a.operation == 'type':
        report.update(requested_text=a.text, mos_completion_observed=False)
    if a.operation in ('mkdir', 'put', 'get'):
        report['remote'] = a.remote
    if a.operation in ('put', 'get'):
        report['local'] = str(a.local)
    if a.operation == 'put':
        report['input_sha256'] = digest(a.local)
    report_path = a.record / 'receipt.json'

    def save():
        report_path.write_text(json.dumps(report, indent=2)+'\n')

    def execute(label, script, options):
        # Every delegated target operation has an immediate current-owner check.
        check = subprocess.run(lease_command, check=True, capture_output=True, text=True)
        (a.record / (label+'-lease.json')).write_text(check.stdout)
        command = [str(python), str(script), '--url', config['extender_url'],
                   '--state', str(a.record / (label+'-state.json')), *options]
        report['hardware_action_attempted'] = True
        report.setdefault('tools', {})[str(script)] = digest(script)
        save()
        with (a.record / (label+'.stdout')).open('w') as stdout, (a.record / (label+'.stderr')).open('w') as stderr:
            subprocess.run(command, check=True, stdout=stdout, stderr=stderr, cwd=EXTENDER)

    save()
    try:
        if a.operation in ('mkdir', 'exit', 'put', 'get'):
            # Metadata must use checksum-free major2 too, including EXIT.
            execute('listener-preflight', PINNED / 'sdcard.py', ['status'])
            listener = json.loads((a.record / 'listener-preflight.stdout').read_text())
            assert listener['online'] and listener['protocol'] == 2, 'Expected admitted fast major2 listener'
        if a.operation == 'status':
            execute('keyboard-status', EXTENDER / 'scripts/keyboard.py', ['status'])
            execute('listener-status', PINNED / 'sdcard.py', ['status'])
            execute('worker-status', PINNED / 'sdcard_staged.py', ['status'])
        elif a.operation == 'type':
            execute('keyboard', EXTENDER / 'scripts/keyboard.py', ['type', a.text, '--enter'])
            report['submitted_text'] = a.text
        elif a.operation == 'mkdir':
            execute('metadata', PINNED / 'sdcard.py', ['mkdir', a.remote, '--parents'])
        elif a.operation == 'exit':
            # A new operation record creates a fresh metadata connection after
            # the staged worker's private sessions, as required by Extender.
            execute('metadata', PINNED / 'sdcard.py', ['exit'])
            report['exit_acknowledged'] = True
            save()
            deadline = time.monotonic()+15
            index = 0
            while True:
                label = f'exit-presence-{index:03d}'
                execute(label, PINNED / 'sdcard.py', ['status'])
                presence = json.loads((a.record / (label+'.stdout')).read_text())
                if not presence['online'] and not presence['pending']:
                    report['listener_offline_observed'] = True
                    break
                if time.monotonic() >= deadline:
                    raise TimeoutError('EXIT acknowledged but offline handback unobserved; retain state, do not repeat EXIT')
                time.sleep(.1)
                index += 1
        elif a.operation in ('put', 'get'):
            script = PINNED / 'sdcard_staged.py'
            assert digest(script) == 'f7aa43bd05d62cc1bdc051d8ae569128766cb9ec95076bd1bb951063997683ef'
            options = ['--timeout', '900', a.operation]
            options += [str(a.local), a.remote, '--activate'] if a.operation == 'put' else [a.remote, str(a.local)]
            execute('staged', script, options)
            report['remote'] = a.remote
            report['local_sha256'] = digest(a.local)
        else:
            check = subprocess.run(lease_command, check=True, capture_output=True, text=True)
            (a.record / 'capture-lease.json').write_text(check.stdout)
            script = EXTENDER / 'scripts/serial_monitor.py'
            report.update(hardware_action_attempted=True,
                          tools={str(script):digest(script),
                                 str(EXTENDER / 'scripts/passive_serial.py'):digest(EXTENDER / 'scripts/passive_serial.py')})
            save()
            command = [str(python), str(script), '--port', str(port),
                       '--output', str(a.record / 'capture.bin'), '--seconds', str(a.seconds),
                       '--ready-file', str(a.record / 'ready'), '--stop-file', str(a.record / 'stop')]
            with (a.record / 'capture.stdout').open('w') as stdout, (a.record / 'capture.stderr').open('w') as stderr:
                subprocess.run(command, check=True, stdout=stdout, stderr=stderr, cwd=EXTENDER)
            report.update(port_open_observed=(a.record / 'ready').is_file(),
                          legacy_text_channel_qualified=False)
        report.update(completed=True, finished_epoch=time.time())
        save()
        print(json.dumps(dict(operation=a.operation, completed=True, receipt=str(report_path))))
    except BaseException as error:
        report.update(failure=repr(error), finished_epoch=time.time())
        save()
        raise


if __name__ == '__main__':
    main()
