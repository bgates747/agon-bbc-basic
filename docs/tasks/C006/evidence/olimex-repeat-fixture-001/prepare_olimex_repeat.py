"""Freeze one physical repeat using the actual unchanged hardware-produced image.

Offline copying/hashing only. No compilation, image patch or device access.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verified(directory):
    directory = directory.resolve(strict=True)
    for name, value in json.loads((directory/'manifest.json').read_text()).items():
        path = (directory/name).resolve(strict=True)
        assert path.is_relative_to(directory) and digest(path) == value, name
    return directory


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--previous', type=Path, required=True)
    p.add_argument('--fixture', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--run-id', default='c006-r02')
    a = p.parse_args()
    assert re.fullmatch(r'[a-z][a-z0-9-]{0,31}', a.run_id)
    previous = verified(a.previous)
    fixture = verified(a.fixture)
    report = json.loads((previous/'results.json').read_text())
    release = json.loads((previous/'cleanup-release-summary.json').read_text())
    base = json.loads((fixture/'fixture.json').read_text())
    assert report['hardware_validation'] and report['late_completion_observed']
    assert report['all_output_bytes_equal'] and not report['second_physical_generation_executed']
    assert all(release['checks'].values()) and release['released_at']
    seed = previous/'output.dat'
    source = fixture/'payload/compiler.bas'
    assert digest(source) == report['source_sha256'] == base['compiler_sha256']
    assert digest(seed) == report['image_sha256'] == base['native_compiler_sha256']
    assert seed.read_bytes() == (fixture/'payload/compiler.bin').read_bytes()
    assert len(seed.read_bytes()) == 324275 and seed.read_bytes()[64:69] == b'MOS\x00\x01'
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    payload = out/'payload'
    payload.mkdir()
    shutil.copy2(seed, payload/'compiler.bin')
    shutil.copy2(source, payload/'compiler.bas')
    fixtures = '/extender/diagnostics/bbc-basic/'+a.run_id
    results = '/agents/extender/results/bbc-basic/'+a.run_id
    (payload/'self-b.txt').write_text(
        f'CD {results}\nECHO BBC_BEGIN_SELF_B\nLOAD {fixtures}/compiler.bin\nRUN .\n'
        'ECHO BBC_END_SELF_B\nEMOS sdserve --fast /\n')
    plan = dict(scope='One physical self-source repeat from actual hardware-produced compiler; offline preparation only',
                compiler_sha256=digest(source), native_compiler_sha256=digest(seed), image_bytes=seed.stat().st_size,
                previous_hardware_evidence=str(previous), previous_hardware_image=digest(seed),
                previous_late_completion_preserved=True, previous_slot_released_at=release['released_at'],
                fixture_path=fixtures, result_path=results,
                filename_inputs={'self-b':[fixtures+'/compiler.bas', results+'/self-b.bin']},
                uploads={'payload/'+q.name:fixtures+'/'+q.name for q in sorted(payload.iterdir())},
                planned_RUN_returns=0, EXEC_RUN_line=4, completion_bound_seconds=6600,
                capture_lifetime_seconds=7200, hardware_validation=False,
                observed_previous_capture_interval_seconds=report['capture_last_write_after_input_seconds'],
                observed_previous_get_host_seconds=report['get_host_seconds'])
    (out/'fixture.json').write_text(json.dumps(plan, indent=2)+'\n')
    (out/'cases.json').write_text('[]\n')
    shutil.copy2(__file__, out/'prepare_olimex_repeat.py')
    (out/'manifest.json').write_text(json.dumps({str(q.relative_to(out)):digest(q)
        for q in sorted(out.rglob('*')) if q.is_file()}, indent=2)+'\n')
    print(json.dumps(dict(payloads=3, payload_bytes=sum(q.stat().st_size for q in payload.iterdir()),
                         manifest_sha256=digest(out/'manifest.json'), fixture=plan), indent=2))


if __name__ == '__main__':
    main()
