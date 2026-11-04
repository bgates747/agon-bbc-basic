"""Freeze the completed C010 hosted 39-case baseline and compare older images."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT/'.emulator/c010-fit'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    parser.add_argument('--source', type=Path, default=TASK/'candidate-fit.bas')
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True, exist_ok=False)
    old = ROOT/'docs/tasks/C005/evidence/live-baseline-streaming-001'
    manifest = json.loads((old/'manifest.json').read_text())
    for name, expected in manifest.items():
        assert digest(old/name) == expected
    cases = json.loads((old/'cases.json').read_text())
    report = json.loads((ROOT/'compiler/build/test-results.json').read_text())
    assert report['compiler_sha256'] == digest(args.source)
    assert (report['cases'], report['native_executions']) == (39, 15)
    assert report['assembler_oracle'] and report['deterministic_repeat']
    console = (PROFILE/'compile.log').read_text()
    assert 'COMPILE_DONE\n' in console
    sentinel = b'existing output must survive a compilation error'
    for i, case in enumerate(cases):
        source = case['source_file']
        image = PROFILE/'sdcard'/f't{i}.bin'
        assert (PROFILE/'sdcard'/source).read_bytes() == (old/source).read_bytes()
        shutil.copyfile(old/source, evidence/source)
        if 'diagnostic' in case:
            assert f'CASE_ERR:{source}\n'+case['diagnostic']+'\n' in console
            assert image.read_bytes() == sentinel
        else:
            assert f'CASE_OK:{source}\n' in console
            assert image.read_bytes() == (old/case['image_file']).read_bytes()
            shutil.copyfile(image, evidence/case['image_file'])
    for source, name in [
        (args.source, 'compiler.bas'),
        (ROOT/'compiler/tools/test_compiler.py', 'test_compiler.py'),
        (ROOT/'compiler/build/test-results.json', 'test-results.json'),
        (ROOT/'compiler/build/golden.bin', 'golden.dat'),
        (PROFILE/'sdcard/repeat.bin', 'repeat.dat'),
        (PROFILE/'sdcard/driver.bas', 'driver.bas'),
        (PROFILE/'compile.log', 'compile.log'), (PROFILE/'native.log', 'native.log'),
        (old/'cases.json', 'cases.json'), (Path(__file__), 'freeze_baseline.py'),
    ]:
        shutil.copyfile(source, evidence/name)
    report.update(all_15_complete_images_identical_to_earlier_source=True,
        all_24_diagnostics_and_preserved_outputs_match=True,
        prior_cohort='docs/tasks/C005/evidence/live-baseline-streaming-001')
    (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
        for p in sorted(evidence.iterdir()) if p.name!='manifest.json'}, indent=2)+'\n')
    print(json.dumps(report), flush=True)


if __name__ == '__main__':
    main()
