"""Verify the promoted file copy against frozen C006 qualification evidence.

No compiler, emulator or hardware execution occurs. Write a new evidence cohort
only; never modify the live distribution or prior evidence.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil

from promote_native import verified

ROOT = Path(__file__).resolve().parents[3]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evidence', type=Path, required=True)
    args = parser.parse_args()
    live = ROOT / 'compiler/bin'
    metadata = json.loads((live / 'manifest.json').read_text())
    source = ROOT / metadata['source']
    assert sha(source) == metadata['source_sha256'] == '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8'
    image = (live / 'compiler.bin').read_bytes()
    assert len(image) == metadata['image_bytes'] == 324275
    assert sha(live / 'compiler.bin') == metadata['image_sha256'] == '299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0'
    assert image[64:69] == b'MOS\x00\x01'
    assert (ROOT / metadata['binary_copied_unchanged_from']).read_bytes() == image
    cohorts = [verified(ROOT / name) for name in metadata['evidence']]
    assert len(cohorts) == 7
    bootstrap = cohorts[0]
    assert all((bootstrap / (stage + '.dat')).read_bytes() == image
               for stage in ['g0', 'g1', 'g2', 'repeat'])
    assert all((cohort / 'output.dat').read_bytes() == image for cohort in cohorts[-2:])
    assert (live / 'LICENSE.txt').read_bytes() == (ROOT / 'license.txt').read_bytes()
    assert (live / 'LICENSE.txt').read_bytes() == (ROOT / 'compiler/runtime/vendor/LICENSE.txt').read_bytes()
    assert sha(live / 'LICENSE.txt') == metadata['license_sha256']
    assert {p.name for p in live.iterdir()} == {'compiler.bin', 'LICENSE.txt', 'README.md', 'manifest.json'}
    release = json.loads((cohorts[-1] / 'cleanup-release-summary.json').read_text())
    assert release['generation'] == 8 and release['released_at'] and all(release['checks'].values())
    assert metadata['physical_qualification']['self_source_generations'] == 2
    out = args.evidence.resolve()
    assert out.is_relative_to(ROOT / 'docs/tasks/C006/evidence')
    out.mkdir(parents=True, exist_ok=False)
    for name in ['manifest.json', 'README.md', 'LICENSE.txt']:
        shutil.copy2(live / name, out / ('promoted-' + name))
    for script in [Path(__file__), Path(__file__).with_name('promote_native.py')]:
        shutil.copy2(script, out / script.name)
    results = dict(
        scope='Host file-copy/provenance verification; no additional compiler or target execution',
        passed=True, source_sha256=sha(source), image_sha256=sha(live / 'compiler.bin'),
        image_bytes=len(image), live_files={p.name: sha(p) for p in sorted(live.iterdir())},
        prerequisite_manifests_verified=[str(p.relative_to(ROOT)) for p in cohorts],
        all_six_completed_images_equal=True, original_hardware_output_copied_unchanged=True,
        exact_root_and_vendor_notice_preserved=True,
        second_hardware_clean_release=release['released_at'],
        new_compiler_execution=False, new_hardware_execution=False,
        main_promoted=False, human_optical_validation=False, performance_benchmark=False)
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    files = {p.name: sha(p) for p in sorted(out.iterdir())}
    (out / 'manifest.json').write_text(json.dumps(files, indent=2) + '\n')
    print(json.dumps(results, indent=2))


if __name__ == '__main__':
    main()
