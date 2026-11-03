"""Sequentially upload and independently retrieve the frozen C006 payloads.

Each explicit step uses olimex_step.py's current-lease check and maintained
Extender tools. An error stops the cohort without retry or cleanup dispatch.
No compiler/program invocation or startup/firmware changes occur here.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import time


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bundle', type=Path, required=True)
    p.add_argument('--config', type=Path, required=True)
    p.add_argument('--lease', required=True)
    p.add_argument('--record', type=Path, required=True)
    a = p.parse_args()
    bundle = a.bundle.resolve(strict=True)
    manifest = json.loads((bundle/'manifest.json').read_text())
    for name, expected in manifest.items():
        path = (bundle/name).resolve(strict=True)
        assert path.is_relative_to(bundle) and digest(path) == expected, name
    fixture = json.loads((bundle/'fixture.json').read_text())
    uploads = fixture['uploads']
    assert len(uploads) == 40 and len(set(uploads.values())) == 40
    for name, remote in uploads.items():
        assert name in manifest and name.startswith('payload/')
        assert (remote.startswith(fixture['fixture_path']+'/') or
                remote.startswith(fixture['result_path']+'/'))
    record = a.record.resolve()
    record.mkdir(parents=True, exist_ok=False)
    shutil.copy2(__file__, record/'deploy_olimex.py')
    report = dict(started_epoch=time.time(), completed_files=[], all_bytes_equal=False,
                  fixture_manifest_sha256=digest(bundle/'manifest.json'))
    try:
        for index, (name, remote) in enumerate(uploads.items()):
            common = [sys.executable, str(Path(__file__).with_name('olimex_step.py')),
                      '--config', str(a.config.resolve()), '--bundle', str(bundle),
                      '--lease', a.lease, '--record']
            local = bundle/name
            downloaded = record/f'readback-{index:02d}.dat'
            subprocess.run(common+[str(record/f'put-{index:02d}'),
                                   'put', str(local), remote], check=True)
            subprocess.run(common+[str(record/f'get-{index:02d}'),
                                   'get', remote, str(downloaded)], check=True)
            assert downloaded.read_bytes() == local.read_bytes(), remote
            report['completed_files'].append(dict(name=name, remote=remote,
                                                  bytes=local.stat().st_size,
                                                  sha256=digest(local)))
            (record/'results.json').write_text(json.dumps(report, indent=2)+'\n')
            print('Verified uploaded file', index, name, flush=True)
        report['all_bytes_equal'] = True
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        report['finished_epoch'] = time.time()
        (record/'results.json').write_text(json.dumps(report, indent=2)+'\n')


if __name__ == '__main__':
    main()
