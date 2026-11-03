"""Package qualified compiler/regression bytes for an explicit Olimex run.

This host-only tool never contacts hardware, compiles BASIC or changes an image.
It requires the completed normal-main generation chain and native regressions.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[3]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verified(directory):
    directory = directory.resolve(strict=True)
    manifest = json.loads((directory / 'manifest.json').read_text())
    for name, expected in manifest.items():
        path = (directory / name).resolve(strict=True)
        assert path.is_relative_to(directory), name
        assert digest(path) == expected, name
    assert 'results.json' in manifest
    return json.loads((directory / 'results.json').read_text())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--compiler', type=Path, default=ROOT / 'compiler/compiler.bas')
    p.add_argument('--bootstrap', type=Path, required=True)
    p.add_argument('--regressions', type=Path, required=True)
    p.add_argument('--native-baseline', type=Path, required=True)
    p.add_argument('--native-errors', type=Path, required=True)
    p.add_argument('--run-id', required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    assert re.fullmatch(r'[a-z][a-z0-9-]{0,31}', a.run_id)
    boot = verified(a.bootstrap)
    regressions = verified(a.regressions)
    baseline = verified(a.native_baseline)
    errors = verified(a.native_errors)
    source = a.compiler.resolve(strict=True)
    assert boot['all_four_images_identical']
    assert boot['unmodified_interpreted_main_executed']
    assert boot['completed_stages'] == ['g0', 'g1', 'g2', 'repeat']
    assert boot['compiler_sha256'] == digest(source)
    images = [a.bootstrap / (stage + '.dat') for stage in boot['completed_stages']]
    seed = images[0].read_bytes()
    assert seed[64:69] == b'MOS\x00\x01'
    assert int.from_bytes(seed[-6:-3], 'little') == 0x40000+len(seed)
    assert int.from_bytes(seed[-3:], 'little') == 0xA7F00
    assert all(path.read_bytes() == seed for path in images)
    assert regressions['all_cases_passed']
    assert regressions['native_compiler_sha256'] == digest(images[0])
    assert baseline['native_compiler_sha256'] == digest(images[0])
    assert baseline['reference_compiler_sha256'] == digest(source)
    assert baseline['all_cases_passed'] and baseline['completed_cases'] == list(range(39))
    assert baseline['images_matched'] == 15 and baseline['diagnostics_matched'] == 24
    assert errors['native_compiler_sha256'] == digest(images[0])
    assert errors['supplied_compiler_source_sha256'] == digest(source)
    assert errors['source_case_indices'] == errors['completed_cases'] == list(range(39))
    assert errors['all_outputs_and_ERR_ERL_match'] and errors['deterministic_repeat']
    cases = json.loads((a.regressions / 'cases.json').read_text())
    assert regressions['completed_cases'] == list(range(len(cases)))
    assert len(cases) == 12
    for i, case in enumerate(cases):
        assert case.get('status', 0) == 0, 'Nonzero application return needs an explicit EXEC error plan'
        assert 'NREG_COMPILER_STATUS:0\n' in (a.regressions / f'compile-{i}.log').read_text()
        assert (a.regressions / f'nreg-{i}.bas').read_text() == case['source']
        if 'diagnostic' not in case:
            assert (a.regressions / f'p{i}.dat').is_file()
    out = a.output.resolve()
    assert not out.exists(), 'Preserve prior fixture'
    out.mkdir(parents=True)
    payload = out / 'payload'
    payload.mkdir()
    expected = out / 'expected'
    expected.mkdir()
    fixtures = f'/extender/diagnostics/bbc-basic/{a.run_id}'
    results = f'/agents/extender/results/bbc-basic/{a.run_id}'
    shutil.copy2(source, payload / 'compiler.bas')
    shutil.copy2(images[0], payload / 'compiler.bin')
    prompts = {}

    def command(name, executable, marker):
        # RUN . is deliberate MOS syntax. The caller observes both filename
        # prompts and completion; this batch never supplies speculative keys.
        (payload / name).write_text(
            f'CD {results}\nECHO BBC_BEGIN_{marker}\nLOAD {executable}\nRUN .\n'
            f'ECHO BBC_END_{marker}\nEMOS sdserve --fast /\n')

    for stage, executable in [('self-a', fixtures + '/compiler.bin'),
                              ('self-b', results + '/self-a.bin')]:
        command(stage + '.txt', executable, stage.upper().replace('-', '_'))
        prompts[stage] = [fixtures + '/compiler.bas', results + '/' + stage + '.bin']
    for i, case in enumerate(cases):
        shutil.copy2(a.regressions / f'nreg-{i}.bas', payload / f'case-{i}.bas')
        command(f'compile-{i}.txt', fixtures + '/compiler.bin', f'COMPILE_{i}')
        prompts[f'compile-{i}'] = [fixtures + f'/case-{i}.bas', results + f'/case-{i}.bin']
        if 'diagnostic' in case:
            # Deploy this sentinel before compiling; rejection must preserve it.
            (payload / f'reject-{i}.dat').write_bytes(b'Native rejection preserves previous output')
        else:
            shutil.copy2(a.regressions / f'p{i}.dat', expected / f'case-{i}.dat')
            command(f'run-{i}.txt', results + f'/case-{i}.bin', f'NATIVE_{i}')
    report = dict(scope='Offline fixture preparation; no hardware access or result',
                  compiler_sha256=digest(source), native_compiler_sha256=digest(images[0]),
                  image_bytes=len(seed), load_address=0x40000,
                  static_image_end=0x40000+len(seed), private_heap_limit=0xA7F00,
                  activation_arena_bytes=32768, top_reserve_bytes=256,
                  fixture_path=fixtures, result_path=results, filename_inputs=prompts,
                  bootstrap_evidence=str(a.bootstrap.resolve()),
                  regression_evidence=str(a.regressions.resolve()),
                  planned_RUN_returns=0, EXEC_RUN_line=4,
                  hardware_validation=False)
    (out / 'cases.json').write_text(json.dumps(cases, indent=2)+'\n')
    (out / 'fixture.json').write_text(json.dumps(report, indent=2)+'\n')
    for name, directory in [('bootstrap', a.bootstrap), ('regressions', a.regressions),
                            ('native-baseline', a.native_baseline), ('native-errors', a.native_errors)]:
        shutil.copy2(directory / 'results.json', out / (name+'-results.json'))
    shutil.copy2(__file__, out / 'prepare_olimex.py')
    manifest = {str(path.relative_to(out)): digest(path)
                for path in sorted(out.rglob('*')) if path.is_file()}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
