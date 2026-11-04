"""Compare actual native compiler output with a fresh frozen 39-case baseline.

Source fixtures and expected bytes/diagnostics come from the reference-hosted
compiler test run. Python types filenames and compares results; it never
parses BASIC or emits executable code.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = ROOT / 'docs/tasks/C006'
PROFILE = ROOT / '.emulator'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--native', type=Path, required=True)
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--cli', type=Path, required=True)
    p.add_argument('--name', required=True)
    p.add_argument('--timeout', type=float, default=1800)
    a = p.parse_args()
    assert (PROFILE / 'fab-agon-emulator.bin').resolve() == a.cli.resolve(strict=True)
    reference = a.reference.resolve(strict=True)
    manifest = json.loads((reference / 'manifest.json').read_text())
    for name, value in manifest.items():
        path = (reference / name).resolve(strict=True)
        assert path.is_relative_to(reference) and digest(path) == value, name
    assert {'cases.json', 'test-results.json'} <= manifest.keys()
    baseline = json.loads((reference / 'test-results.json').read_text())
    assert baseline['cases'] == 39 and baseline['native_executions'] == 15
    assert baseline['assembler_oracle'] and baseline['deterministic_repeat']
    cases = json.loads((reference / 'cases.json').read_text())
    assert len(cases) == 39
    e = TASK / 'evidence' / a.name
    assert not e.exists(), 'Preserve native qualification evidence'
    e.mkdir(parents=True)
    shutil.copy2(__file__, e / 'native_baseline.py')
    shutil.copy2(reference / 'cases.json', e / 'cases.json')
    shutil.copy2(a.native, e / 'native-compiler.dat')
    shutil.copy2(a.native, PROFILE / 'sdcard/native-compiler.bin')
    spec = importlib.util.spec_from_file_location('keyboard', ROOT / 'docs/tasks/C005/io/interactive.py')
    keyboard = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(keyboard)
    report = dict(native_compiler_sha256=digest(a.native), reference_directory=str(reference),
                  reference_compiler_sha256=baseline['compiler_sha256'],
                  completed_cases=[], images_matched=0, diagnostics_matched=0,
                  hardware_validation=False,
                  scope='Native compiler output equivalence; reference cohort owns runtime execution')
    started = time.monotonic()
    sentinel = b'Native compiler rejection must preserve this previous output'

    def save():
        (e / 'results.json').write_text(json.dumps(report, indent=2)+'\n')
        (e / 'manifest.json').write_text(json.dumps({q.name: digest(q)
            for q in e.iterdir() if q.is_file() and q.name != 'manifest.json'}, indent=2)+'\n')

    save()
    try:
        for i, case in enumerate(cases):
            source = case['source_file']
            assert source == f't{i}.bas' and source in manifest
            shutil.copy2(reference / source, e / source)
            shutil.copy2(reference / source, PROFILE / 'sdcard' / source)
            target = f'nbaseline-{i}.bin'
            path = PROFILE / 'sdcard' / target
            path.write_bytes(sentinel)
            commands = (f'try /native-compiler.bin\necho NBASE_STATUS:<Try$ReturnCode>\n'
                        f'echo NBASE_DONE_{i}\n')
            report['attempted_case'] = i
            save()
            log = keyboard.run(PROFILE, commands,
                [('Source file: ', source), ('Output file: ', target)],
                f'NBASE_DONE_{i}', f'nbaseline-{i}.log', timeout_seconds=a.timeout)
            (e / f'compile-{i}.log').write_text(log)
            assert 'NBASE_STATUS:0\n' in log, (i, log)
            if 'diagnostic' in case:
                assert case['diagnostic']+'\n' in log, (i, log, case)
                assert path.read_bytes() == sentinel, i
                report['diagnostics_matched'] += 1
            else:
                assert 'Wrote '+target+'\n' in log, (i, log)
                assert case['image_file'] in manifest
                assert path.read_bytes() == (reference / case['image_file']).read_bytes(), i
                shutil.copy2(path, e / f'p{i}.dat')
                report['images_matched'] += 1
            report['completed_cases'].append(i)
            save()
            print('Native baseline equivalence', i, 'passed', flush=True)
        assert report['images_matched'] == 15 and report['diagnostics_matched'] == 24
        report.update(all_cases_passed=True, controller_seconds=round(time.monotonic()-started, 3))
        save()
    except BaseException as error:
        report['failure'] = repr(error)
        attempted = report.get('attempted_case')
        if attempted is not None:
            raw = PROFILE / f'nbaseline-{attempted}.log'
            if raw.is_file() and not (e / f'compile-{attempted}.log').exists():
                shutil.copy2(raw, e / f'compile-{attempted}.log')
        save()
        raise
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
