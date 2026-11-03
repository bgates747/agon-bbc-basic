"""Run real BBC/native fixtures and require complete pre-compaction image identity."""
from pathlib import Path
import importlib.util
import json
import sys

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    baseline = TASK / 'evidence/compact-frontend-002'
    fixture = module('fixtures', TASK / 'compact/test_frontend.py')
    harness = module('maps', TASK / 'compact/maps_harness.py').load()
    cases = fixture.programs()
    previous = json.loads((baseline / 'cases.json').read_text())
    assert len(cases) == len(previous)
    assert all(all(old.get(key) == value for key, value in case.items())
               for case, old in zip(cases, previous))
    harness.programs = lambda: cases
    sys.argv += ['--skip-legacy', '--isolate-reference', '--string-runtime',
                 str(ROOT / 'compiler/build/string-runtime')]
    harness.main()
    build = TASK / 'build/output-integration'
    module('links', TASK / 'compact/check_images.py').check(build)
    for index in range(len(cases)):
        assert (ROOT / f'.emulator/sdcard/p{index}.bin').read_bytes() == (baseline / f'p{index}.dat').read_bytes(), index
    (build / 'zero-tail-identity.json').write_text(json.dumps(dict(
        scope='Complete executable equality with compact-frontend-002',
        identical_images=len(cases),
        source='docs/tasks/C005/compact/zero_tail.bas'), indent=2)+'\n')
    print('Complete control-zero-tail image identity:', len(cases))


if __name__ == '__main__':
    main()
