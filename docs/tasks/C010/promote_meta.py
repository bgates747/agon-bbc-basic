"""Promote exact C010 artifacts only after completed compatibility/self-build gates.

This copies source, an unchanged native image and provenance. It never compiles
BASIC, launches tools, deploys, publishes, or claims new hardware/visual tests.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
SOURCE = '70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e'
PRIOR_SOURCE = '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8'
PRIOR_IMAGE = '299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def retained(name, report='results.json'):
    directory = TASK/'evidence'/name
    manifest = json.loads((directory/'manifest.json').read_text())
    assert report in manifest
    for filename, expected in manifest.items():
        path = (directory/filename).resolve(strict=True)
        assert path.is_relative_to(directory.resolve()) and digest(path) == expected, (name, filename)
    return json.loads((directory/report).read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    assert digest(TASK/'candidate-meta.bas') == SOURCE
    assert digest(ROOT/'compiler/compiler.bas') == PRIOR_SOURCE
    assert digest(ROOT/'compiler/bin/compiler.bin') == PRIOR_IMAGE
    old_manifest = json.loads((ROOT/'compiler/bin/manifest.json').read_text())
    inputs = []
    hosted = retained('meta-hosted-pipeline-001')
    assert hosted['completed'] and hosted['failure'] is None
    assert hosted['compiler_source_sha256'] == SOURCE
    assert set(hosted['completed_stages']) == {'baseline','freeze-baseline',
        'admissions','repack','wire-basic','wire-bounded','wire-errors','wire-interactions'}
    inputs.append('meta-hosted-pipeline-001')
    for name, count in [('meta-wire-basic-001', 5), ('meta-wire-bounded-001', 1),
                        ('meta-wire-errors-001', 9), ('meta-wire-interactions-001', 3)]:
        report = retained(name)
        assert report['compiler_source_sha256'] == SOURCE
        assert report['completed'] and len(report['cases']) == count
        assert all(c['equal'] for c in report['cases'])
        inputs.append(name)
    admission = retained('meta-admissions-001')
    assert admission['compiler_source_sha256'] == SOURCE
    assert admission['completed'] and admission['exact_full_source_compiled']
    assert len(admission['rejected']) == 12 and admission['all_outputs_preserved']
    inputs.append('meta-admissions-001')
    repack = retained('meta-repack-001')
    assert repack['candidate_sha256'] == SOURCE and repack['all_identical']
    assert len(repack['completed']) == 10 and len(repack['modules']) == 9
    inputs.append('meta-repack-001')
    baseline = retained('meta-hosted-baseline-001')
    assert baseline['compiler_sha256'] == SOURCE and baseline['cases'] == 39
    assert baseline['assembler_oracle'] and baseline['deterministic_repeat']
    assert baseline['all_15_complete_images_identical_to_earlier_source']
    assert baseline['all_24_diagnostics_and_preserved_outputs_match']
    inputs.append('meta-hosted-baseline-001')
    build = retained('meta-native-build-001')
    self_build = retained('meta-native-self-001')
    image = TASK/'evidence/meta-native-self-001/compiler.dat'
    image_hash = digest(image)
    assert build['completed'] and build['compiler_source_sha256'] == SOURCE
    assert build['seed_sha256'] == PRIOR_IMAGE
    assert self_build['completed'] and self_build['complete_image_equals_expected']
    assert self_build['compiler_source_sha256'] == SOURCE
    assert self_build['seed_sha256'] == build['image_sha256'] == image_hash
    assert self_build['image_sha256'] == image_hash
    assert image.read_bytes() == (TASK/'evidence/meta-native-build-001/compiler.dat').read_bytes()
    inputs += ['meta-native-build-001', 'meta-native-self-001']
    layout = retained('meta-symbol-layout-001')
    assert layout['completed'] and layout['old_output_preserved']
    assert layout['source_sha256'] == SOURCE and layout['image_bytes'] == image.stat().st_size
    assert 0 < layout['symbols'] <= 4096 and layout['bindings'] <= 256 and layout['routines'] <= 256
    assert layout['prefix_bytes_saved'] > 0
    inputs.append('meta-symbol-layout-001')
    checked = retained('meta-image-checks-001', 'compiler-image-checks.json')
    assert checked['image_sha256'] == image_hash and checked['complete_standard_runtimes_and_entry_checked']
    assert checked['compact_PIC_matches_GNU']
    inputs.append('meta-image-checks-001')
    for name, count in [('meta-native-baseline-001', 39), ('meta-native-representative-001', 12)]:
        report = retained(name)
        assert report['native_compiler_sha256'] == image_hash
        assert report['all_cases_passed'] and report['completed_cases'] == list(range(count))
        inputs.append(name)
    representative_execution = retained('meta-native-representative-001', 'execution.json')
    assert representative_execution['identical_representative_full_images'] == list(range(10))
    for suite, count in [('basic', 5), ('bounded', 1), ('errors', 9), ('interactions', 3)]:
        name = f'meta-native-wire-{suite}-001'
        report = retained(name)
        assert report['compiler_source_sha256'] == SOURCE and report['native_compiler_sha256'] == image_hash
        assert report['completed'] and len(report['cases']) == count and all(c['equal'] for c in report['cases'])
        inputs.append(name)
    native_mandel = retained('meta-native-mandelbrot-001')
    assert native_mandel['completed'] and native_mandel['native_compiler_sha256'] == image_hash
    assert native_mandel['compiler_source_sha256'] == SOURCE
    assert native_mandel['image_sha256'] == admission['image_sha256']
    assert native_mandel['exact_source_and_complete_image_match_hosted']
    inputs.append('meta-native-mandelbrot-001')
    full_native = retained('full-native-002')
    full_reference = retained('full-reference-001')
    assert full_native['completed'] and full_reference['completed']
    assert full_native['image_sha256'] == native_mandel['image_sha256']
    assert full_native['source_sha256'] == full_reference['source_sha256'] == admission['source_sha256']
    assert full_native['key_supplied_after_final_plot'] and full_reference['key_supplied_after_final_plot']
    assert full_native['plots'] == full_native['gcol_commands'] == full_reference['plots'] == full_reference['gcol_commands']
    assert (TASK/'evidence/full-native-002/graphics.dat').read_bytes() == (TASK/'evidence/full-reference-001/graphics.dat').read_bytes()
    inputs += ['full-native-002', 'full-reference-001']
    pair = retained('full-pair-001')
    assert pair['completed'] and pair['whole_graphics_stream_identical']
    assert pair['native_image_sha256'] == native_mandel['image_sha256']
    inputs.append('full-pair-001')
    pipeline = retained('meta-native-pipeline-001')
    assert pipeline['completed'] and pipeline['failure'] is None
    assert pipeline['image_sha256'] == image_hash
    assert set(pipeline['completed_stages']) == {'image-checks', 'native-mandelbrot',
        'native-baseline', 'native-representative', 'native-wire-basic', 'native-wire-bounded',
        'native-wire-errors', 'native-wire-interactions', 'native-self'}
    inputs.append('meta-native-pipeline-001')
    errors = retained('meta-native-errors-001')
    assert errors['native_compiler_sha256'] == image_hash
    assert errors['supplied_compiler_source_sha256'] == SOURCE
    assert errors['all_outputs_and_ERR_ERL_match'] and errors['deterministic_repeat']
    assert errors['completed_cases'] == list(range(39))
    errors_execution = retained('meta-native-errors-001', 'execution.json')
    assert errors_execution['identical_full_images'] == list(range(39))
    error_controller = retained('meta-error-controller-001')
    assert error_controller['completed'] and error_controller['failure'] is None
    inputs += ['meta-native-errors-001', 'meta-error-controller-001']
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True, exist_ok=False)
    shutil.copyfile(__file__, evidence/'promote.py')
    shutil.copyfile(ROOT/'compiler/bin/manifest.json', evidence/'prior-native-manifest.json')
    shutil.copyfile(TASK/'candidate-meta.bas', ROOT/'compiler/compiler.bas')
    shutil.copyfile(image, ROOT/'compiler/bin/compiler.bin')
    license_file = ROOT/'compiler/bin/LICENSE.txt'
    assert license_file.read_bytes() == (ROOT/'license.txt').read_bytes()
    metadata = dict(scope='Development executable qualified by automated compatibility and native self-compilation',
        target='Agon MOS, eZ80 ADL24, load040000', image_bytes=image.stat().st_size,
        image_sha256=image_hash, source='compiler/compiler.bas', source_sha256=SOURCE,
        binary_copied_unchanged_from='docs/tasks/C010/evidence/meta-native-self-001/compiler.dat',
        license_sha256=digest(license_file),
        emulator_generations=['C006-native-seed-to-C010', 'C010-native-self'],
        native_regressions=dict(baseline=39, representative=12, errors=39, graphics_keyboard_pairs=18),
        physical_qualification=dict(source_compiles=0, generated_programs=0, self_source_generations=0),
        prior_qualified_release=dict(source_sha256=PRIOR_SOURCE, image_sha256=PRIOR_IMAGE,
            physical_qualification=old_manifest['physical_qualification'],
            evidence='docs/tasks/C006/evidence/native-promotion-001'),
        evidence=['docs/tasks/C010/evidence/'+name for name in inputs],
        original_failure_records_preserved=True, human_optical_validation=False, performance_benchmark=False)
    (ROOT/'compiler/bin/manifest.json').write_text(json.dumps(metadata, indent=2)+'\n')
    (ROOT/'compiler/bin/README.md').write_text(
        '# Development native compiler\n\n'
        'This BBC-written compiler runs directly under Agon MOS in eZ80 ADL mode. '
        'Its runtime is included; no installed interpreter or assembler is required.\n\n'
        'Load `compiler.bin` with MOS LOAD, then use `RUN .` and enter the source '
        'and destination filenames. Run the emitted program with MOS LOAD and `RUN .`.\n\n'
        'This build adds MODE, GCOL, PLOT and bare numeric GET for the unchanged '
        'Mandelbrot program. Automated reference comparisons, baseline/native '
        'regressions and a byte-identical native self-build qualify its documented '
        '[subset](../COMPATIBILITY.md). Full-program VDU streams match the reference. '
        'Rendered/human, physical and performance results for this version remain '
        'unclaimed. Earlier physical results describe the older version recorded '
        'separately in the manifest.\n\n'
        'See [C010](../../docs/tasks/C010.md) for exact qualification and retained '
        'failures, [runtime provenance](../runtime/vendor/PROVENANCE.md) and '
        '[LICENSE.txt](LICENSE.txt) for original authorship and notices.\n')
    result = dict(prior_source_sha256=PRIOR_SOURCE, prior_image_sha256=PRIOR_IMAGE,
        promoted_source_sha256=digest(ROOT/'compiler/compiler.bas'),
        promoted_image_sha256=digest(ROOT/'compiler/bin/compiler.bin'),
        qualification_cohorts=inputs, hardware_validation=False, human_validation=False)
    (evidence/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    shutil.copyfile(ROOT/'compiler/bin/manifest.json', evidence/'native-manifest.json')
    (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
        for p in sorted(evidence.iterdir()) if p.name!='manifest.json'}, indent=2)+'\n')
    print(json.dumps(result), flush=True)


if __name__ == '__main__':
    main()
