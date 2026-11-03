"""Copy the actual qualified hardware repeat into the development distribution.

This verifies retained evidence and copies bytes/notices. It cannot compile
BASIC, patch an image, substitute arithmetic, publish, or promote to main.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = ROOT/'docs/tasks/C006'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verified(path):
    path = path.resolve(strict=True)
    manifest = json.loads((path/'manifest.json').read_text())
    for name, expected in manifest.items():
        file = (path/name).resolve(strict=True)
        assert file.is_relative_to(path) and sha(file) == expected, name
    return path


def report(name):
    path = verified(TASK/'evidence'/name)
    return path, json.loads((path/'results.json').read_text())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repeat', type=Path, required=True)
    p.add_argument('--output', type=Path, default=ROOT/'compiler/bin')
    a = p.parse_args()
    boot, b = report('live-bootstrap-resume-001')
    baseline, n = report('live-native-baseline-001')
    regressions, r = report('live-regressions-001')
    errors, e = report('live-native-errors-001')
    small, s = report('olimex-small-001')
    first, f = report('olimex-self-a-late-001')
    repeat = verified(a.repeat)
    second = json.loads((repeat/'results.json').read_text())
    stage = json.loads((repeat/'stage-results.json').read_text())
    release = json.loads((repeat/'cleanup-release-summary.json').read_text())
    assert b['all_four_images_identical'] and b['unmodified_interpreted_main_executed']
    assert b['completed_stages'] == ['g0','g1','g2','repeat']
    assert n['all_cases_passed'] and n['completed_cases'] == list(range(39))
    assert n['images_matched'] == 15 and n['diagnostics_matched'] == 24
    assert r['all_cases_passed'] and r['completed_cases'] == list(range(12)) and r['file_io_bytes_verified']
    assert e['all_outputs_and_ERR_ERL_match'] and e['deterministic_repeat'] and e['completed_cases'] == list(range(39))
    assert s['all_twelve_compiles_pass'] and s['all_ten_programs_pass'] and s['file_io_bytes_equal']
    assert f['hardware_validation'] and f['late_completion_observed'] and f['all_output_bytes_equal']
    assert all(json.loads((first/'cleanup-release-summary.json').read_text())['checks'].values())
    assert second['passed'] and second['hardware_validation'] and second['whole_image_matches_input_and_bootstrap']
    assert stage['stage'] == 'self-b' and stage['passed'] and stage['physical_hardware'] and stage['all_output_bytes_equal']
    assert all(release['checks'].values()) and release['released_at']
    image = repeat/'output.dat'
    data = image.read_bytes()
    expected_sha = sha(image)
    source = ROOT/'compiler/compiler.bas'
    expected_source = sha(source)
    assert len(data) == 324275 and data[64:69] == b'MOS\x00\x01'
    assert all((boot/(name+'.dat')).read_bytes() == data for name in b['completed_stages'])
    assert (first/'output.dat').read_bytes() == data
    assert b['compiler_sha256'] == f['source_sha256'] == second['source_sha256'] == expected_source
    assert n['reference_compiler_sha256'] == e['supplied_compiler_source_sha256'] == expected_source
    for result in [n, r, e, s]:
        assert result['native_compiler_sha256'] == expected_sha
    assert f['image_sha256'] == stage['image_sha256'] == second['input_hardware_image_sha256'] == expected_sha
    license_source = ROOT/'license.txt'
    assert license_source.read_bytes() == (ROOT/'compiler/runtime/vendor/LICENSE.txt').read_bytes()
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    shutil.copy2(image, out/'compiler.bin')
    shutil.copy2(license_source, out/'LICENSE.txt')
    (out/'README.md').write_text(
        '# Qualified development native compiler\n\n'
        'This is the BBC-written compiler compiled from compiler/compiler.bas. '
        'It contains its runtime and runs directly under Agon MOS in eZ80 ADL mode; '
        'an installed BASIC interpreter or assembler is not required.\n\n'
        'If the compiler directory is copied to the card as /compiler, use:\n\n'
        '```text\nLOAD /compiler/bin/compiler.bin\nRUN .\n```\n\n'
        'Enter the plain-text source and a different destination filename at the prompts. '
        'Load and run the emitted program normally from MOS. To rebuild the compiler, '
        'supply /compiler/compiler.bas and a fresh output filename, then compare it with this image.\n\n'
        'This development build supports the documented subset in '
        '[the compatibility matrix](../COMPATIBILITY.md). It is not a full BBC BASIC implementation. '
        'The original timeout/resumption and physical qualification records remain explicit in '
        '[C006](../../docs/tasks/C006.md); no human optical or performance acceptance is claimed.\n\n'
        'The executable includes the preserved BBC BASIC V math package and marked standalone '
        'adaptations. Original authorship, notices and exact source origins are retained in '
        '[runtime provenance](../runtime/vendor/PROVENANCE.md) and [LICENSE.txt](LICENSE.txt).\n')
    metadata = dict(scope='Qualified development executable; no main/production promotion',
        target='Agon MOS, eZ80 ADL24, load040000', image_bytes=len(data), image_sha256=expected_sha,
        source='compiler/compiler.bas', source_sha256=expected_source,
        binary_copied_unchanged_from=str(image.relative_to(ROOT)),
        license_sha256=sha(out/'LICENSE.txt'),
        emulator_generations=['g0','g1','g2','repeat'],
        native_regressions=dict(baseline=39, representative=12, errors=39),
        physical_qualification=dict(source_compiles=12, generated_programs=10, self_source_generations=2),
        evidence=[str(path.relative_to(ROOT)) for path in [boot, baseline, regressions, errors, small, first, repeat]],
        original_interruption_and_timeout_records_preserved=True,
        human_optical_validation=False, performance_benchmark=False)
    (out/'manifest.json').write_text(json.dumps(metadata, indent=2)+'\n')
    print(json.dumps(metadata, indent=2))


if __name__ == '__main__':
    main()
