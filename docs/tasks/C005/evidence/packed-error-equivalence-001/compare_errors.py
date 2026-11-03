"""Compare retained source-error programs across private-storage compaction."""
from pathlib import Path
import hashlib
import json
import shutil

TASK = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    out = TASK / 'evidence/packed-error-equivalence-001'
    assert not out.exists(), 'Preserve earlier evidence'
    results = []
    for part, count in [('core', 6), ('tail', 33)]:
        old = TASK / f'evidence/compact-errors-{part}-001'
        new = TASK / f'evidence/packed-errors-{part}-001'
        for directory in [old, new]:
            manifest = json.loads((directory / 'manifest.json').read_text())
            for name, value in manifest.items():
                path = (directory / name).resolve(strict=True)
                assert path.is_relative_to(directory.resolve()) and digest(path) == value, path
        before = json.loads((old / 'cases.json').read_text())
        after = json.loads((new / 'cases.json').read_text())
        assert len(before) == len(after) == count
        for i, (a, b) in enumerate(zip(before, after)):
            assert a['source'] == b['source'], (part, i)
            assert a['expected'] == b['expected'], (part, i)
            assert (old / f'p{i}.dat').read_bytes() == (new / f'p{i}.dat').read_bytes(), (part, i)
            results.append(dict(cohort=part, case=i, image_sha256=digest(new / f'p{i}.dat')))
    out.mkdir()
    shutil.copy2(__file__, out / 'compare_errors.py')
    (out / 'results.json').write_text(json.dumps(dict(programs=39,
        all_sources_oracles_and_complete_images_identical=True,
        before_compiler_sha256=digest(TASK / 'compact/integrated.bas'),
        after_compiler_sha256=digest(TASK / 'compact/packed.bas'),
        scope='Retained actual image equality; no new emulator/hardware execution',
        images=results), indent=2)+'\n')
    (out / 'manifest.json').write_text(json.dumps({q.name:digest(q) for q in out.iterdir()
        if q.is_file()}, indent=2)+'\n')
    print('All39 complete error-program images remain identical')


if __name__ == '__main__':
    main()
