"""Promote the exact qualified C005 source and rehearsed runtime packagers.

This copies BBC/assembly source and rebuilds embedded assembly DATA. It never
compiles BASIC, launches an emulator, commits changes or claims hardware tests.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'
EXPECTED = '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8'
PRIOR = '7cac4bba8644a047c38c496a5fc7cb0fc6c9118b892aad6c3314091867c7fe36'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def retained(directory, report='results.json'):
    manifest = json.loads((directory / 'manifest.json').read_text())
    assert report in manifest
    for name, value in manifest.items():
        path = (directory / name).resolve(strict=True)
        assert path.is_relative_to(directory.resolve())
        assert digest(path) == value, (directory.name, name)
    return json.loads((directory / report).read_text())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--name', required=True)
    a = p.parse_args()
    assert a.name and all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-' for c in a.name)
    source = TASK / 'compact/packed.bas'
    live = ROOT / 'compiler/compiler.bas'
    assert digest(source) == EXPECTED
    assert digest(live) == PRIOR, 'Review independent live changes before promotion'
    evidence = TASK / 'evidence'
    inputs = []
    for name, start, count in [('packed-errors-core-001', 0, 6),
                               ('packed-errors-tail-001', 6, 33)]:
        report = retained(evidence / name)
        assert report['compiler_sha256'] == EXPECTED
        assert report['source_case_indices'] == list(range(start, start+count))
        assert report['all_outputs_and_ERR_ERL_match'] and report['deterministic_repeat']
        assert report['fresh_reference_per_program']
        inputs.append(name)
    capacity = retained(evidence / 'packed-capacity-001')
    assert (capacity['programs'], capacity['native_executions'], capacity['rejected_sources']) == (3, 2, 1)
    assert capacity['hashes']['docs/tasks/C005/compact/packed.bas'] == EXPECTED
    bounds = json.loads((evidence / 'packed-capacity-001/packed-capacity.json').read_text())
    assert bounds['large_executable_bytes'] > 65536
    assert bounds['named_labels_executed'] == 2048 and bounds['labels_rejected'] == 4097
    inputs.append('packed-capacity-001')
    baseline = retained(evidence / 'packed-baseline-001', 'test-results.json')
    assert baseline['compiler_sha256'] == EXPECTED and baseline['cases'] == 39
    assert baseline['assembler_oracle'] and baseline['deterministic_repeat']
    inputs.append('packed-baseline-001')
    for name, count in [('packed-frontend-002', 9), ('packed-helpers-001', 1)]:
        report = retained(evidence / name)
        assert report['native_executions'] == count and report['deterministic_repeat']
        assert report['hashes']['docs/tasks/C005/compact/packed.bas'] == EXPECTED
        inputs.append(name)
    native_path = ROOT / 'docs/tasks/C006/evidence/packed-native-preflight-001'
    native = retained(native_path)
    assert native['native_self_source_matches_resource_seed']
    assert native['compiler_sha256'] == EXPECTED
    assert (native_path / 'g1.dat').read_bytes() == (native_path / 'g0-seed.dat').read_bytes()
    preparation = evidence / 'promotion-preparation-002'
    prepared = retained(preparation)
    assert prepared['regenerated_source_sha256'] == EXPECTED
    assert prepared['individual_repackers_preserve_source']
    destination = evidence / a.name
    assert not destination.exists(), 'Preserve prior promotion evidence'
    destination.mkdir()
    shutil.copy2(__file__, destination / 'promote.py')
    report = dict(scope='Development source promotion and DATA regeneration; no emulator/hardware run',
                  prior_live_sha256=PRIOR, qualified_sha256=EXPECTED,
                  qualification_cohorts=inputs, native_preflight=str(native_path),
                  completed_repackers=[], hardware_validation=False)

    def save():
        (destination / 'results.json').write_text(json.dumps(report, indent=2)+'\n')
        manifest = {q.name: digest(q) for q in destination.iterdir()
                    if q.is_file() and q.name != 'manifest.json'}
        (destination / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')

    save()
    try:
        shutil.copy2(source, live)
        shutil.copy2(preparation / 'compact.s', ROOT / 'compiler/runtime/compact.s')
        for name, value in prepared['modified_tools'].items():
            path = preparation / (name + '.py')
            assert digest(path) == value
            shutil.copy2(path, ROOT / 'compiler/tools' / path.name)
            shutil.copy2(path, destination / path.name)
        shutil.copy2(live, destination / 'compiler.bas')
        shutil.copy2(ROOT / 'compiler/runtime/compact.s', destination / 'compact.s')
        keywords = digest(ROOT / 'compiler/runtime/report_keywords.inc')
        packages = ['report_keywords', 'numeric_runtime', 'strings_runtime', 'control_runtime',
                    'procedure_runtime', 'memory_runtime', 'io_runtime', 'data_runtime',
                    'error_runtime', 'compact_runtime']
        for name in packages:
            command = [str(ROOT / '.venv/bin/python'), str(ROOT / f'compiler/tools/build_{name}.py')]
            if name != 'report_keywords':
                command += ['--compiler', str(live)]
            if name == 'numeric_runtime':
                command += ['--update-compiler']
            with (destination / (name + '.log')).open('w') as output:
                subprocess.run(command, check=True, stdout=output, stderr=subprocess.STDOUT)
            assert digest(live) == EXPECTED, name
            assert digest(ROOT / 'compiler/runtime/report_keywords.inc') == keywords
            report['completed_repackers'].append(name)
            save()
        modules = {}
        for name, expected in prepared['modules'].items():
            directory = 'string' if name == 'strings' else name
            template = ROOT / f'compiler/build/{directory}-runtime/runtime-0.bin'
            value = dict(bytes=template.stat().st_size, sha256=digest(template))
            assert value == expected, name
            modules[name] = value
        report.update(all_repackers_preserve_exact_source=True, modules=modules,
                      promoted_source_sha256=digest(live))
        save()
        print(json.dumps(report, indent=2))
    except BaseException as error:
        report['failure'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
