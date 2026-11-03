"""Read only the two preserved startup/listener files during known-return cleanup.

Use maintained pinned clients, a fresh journal per operation and an immediate
current-lease assertion. A failure stops without retry or another target action.
This neither invokes an application nor writes any remote file.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
EXTENDER = ROOT.parent/'agon-extender'
ENV = ROOT.parent/'agon-dev-env'
PIN = EXTENDER/'agents/remote009/fast-transfer-pin-r01'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config', type=Path, required=True)
    p.add_argument('--grant', type=Path, required=True)
    p.add_argument('--record', type=Path, required=True)
    a = p.parse_args()
    config = json.loads(a.config.read_text())
    grant = json.loads(a.grant.read_text())
    a.record = a.record.resolve()
    a.record.mkdir(parents=True, exist_ok=False)
    staged = PIN/'sdcard_staged.py'
    assert hashlib.sha256(staged.read_bytes()).hexdigest() == 'f7aa43bd05d62cc1bdc051d8ae569128766cb9ec95076bd1bb951063997683ef'
    report = dict(started_epoch=time.time(), verified_files={}, passed=False)

    def run(label, script, args):
        lease = [str(ENV/'.venv/bin/python'), str(ENV/'cross-agent/olimex-bench/bench_lease.py'),
                 'assert-owner', '--owner', 'bbc-basic', '--lease', grant['lease']]
        check = subprocess.run(lease, check=True, capture_output=True, text=True)
        (a.record/(label+'-lease.json')).write_text(check.stdout)
        command = [str(EXTENDER/'.venv/bin/python'), str(script), '--url', config['extender_url'],
                   '--state', str(a.record/(label+'-state.json')), *args]
        with (a.record/(label+'.stdout')).open('w') as out, (a.record/(label+'.stderr')).open('w') as err:
            subprocess.run(command, check=True, stdout=out, stderr=err, cwd=EXTENDER)

    try:
        for remote, name, field in [('/autoexec.txt', 'startup.dat', 'startup_sha256'),
                                    ('/emos/sdserve.bin', 'listener.dat', 'listener_sha256')]:
            label = name.split('.')[0]
            run(label+'-presence', PIN/'sdcard.py', ['status'])
            status = json.loads((a.record/(label+'-presence.stdout')).read_text())
            assert status['online'] and status['protocol'] == 2 and not status['pending']
            output = a.record/name
            run(label, staged, ['--timeout', '900', 'get', remote, str(output)])
            sha = hashlib.sha256(output.read_bytes()).hexdigest()
            assert sha == grant['entry_observation']['components'][field]
            report['verified_files'][remote] = dict(bytes=output.stat().st_size, sha256=sha)
        report['passed'] = True
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        report['finished_epoch'] = time.time()
        (a.record/'results.json').write_text(json.dumps(report, indent=2)+'\n')


if __name__ == '__main__':
    main()
