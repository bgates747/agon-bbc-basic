"""Retain a fresh standard baseline, including every source and expected image."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[4]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('name')
    p.add_argument('--compiler', type=Path, required=True)
    p.add_argument('--log', type=Path, required=True)
    a = p.parse_args()
    destination = ROOT / 'docs/tasks/C005/evidence' / a.name
    assert not destination.exists(), 'Preserve prior evidence'
    profile = ROOT / '.emulator'
    sd = profile / 'sdcard'
    report = json.loads((ROOT / 'compiler/build/test-results.json').read_text())
    assert report['compiler_sha256'] == digest(a.compiler)
    assert report['cases'] == 39 and report['native_executions'] == 15
    assert report['assembler_oracle'] and report['deterministic_repeat']
    console = (profile / 'compile.log').read_text()
    assert 'COMPILE_DONE' in console
    cases = []
    sentinel = b'existing output must survive a compilation error'
    for i in range(report['cases']):
        source = f't{i}.bas'
        image = sd / f't{i}.bin'
        case = dict(source_file=source)
        if f'CASE_ERR:{source}\n' in console:
            case['diagnostic'] = console.split(f'CASE_ERR:{source}\n', 1)[1].splitlines()[0]
            assert image.read_bytes() == sentinel, i
        else:
            assert f'CASE_OK:{source}\n' in console
            assert image.read_bytes()[64:69] == b'MOS\x00\x01'
            case['image_file'] = f't{i}.dat'
        cases.append(case)
    assert sum('image_file' in c for c in cases) == 15
    assert (sd / 'repeat.bin').read_bytes() == (sd / 't0.bin').read_bytes()
    assert (ROOT / 'compiler/build/golden.bin').read_bytes() == (sd / 't0.bin').read_bytes()
    destination.mkdir()
    for path in [a.compiler, ROOT / 'compiler/tools/test_compiler.py', Path(__file__)]:
        shutil.copy2(path, destination / path.name)
    for original, name in [(ROOT / 'compiler/build/test-results.json', 'test-results.json'),
                           (ROOT / 'compiler/build/golden.bin', 'golden.dat'),
                           (profile / 'compile.log', 'compile.log'),
                           (profile / 'native.log', 'native.log'),
                           (sd / 'driver.bas', 'driver.bas'),
                           (sd / 'repeat.bin', 'repeat.dat'), (a.log, 'controller.log')]:
        shutil.copy2(original, destination / name)
    for case in cases:
        shutil.copy2(sd / case['source_file'], destination / case['source_file'])
        if 'image_file' in case:
            shutil.copy2(sd / case['image_file'].replace('.dat', '.bin'), destination / case['image_file'])
    (destination / 'cases.json').write_text(json.dumps(cases, indent=2)+'\n')
    manifest = {q.name: digest(q) for q in destination.iterdir() if q.is_file()}
    (destination / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print('Frozen', destination)


if __name__ == '__main__':
    main()
