"""Qualify the shared256 scalar/array binding boundary using the BBC compiler."""
from pathlib import Path
import importlib.util
import sys

TASK = Path(__file__).resolve().parent
ROOT = TASK.parents[2]


def programs():
    assignments = [f'v{i}%={i}' for i in range(256)]
    return [
        dict(source='DIM a%(0):PRINT ;a%(0)\n', expected='0\n', status=0),
        dict(source='\n'.join(assignments+['PRINT ;v255%'])+'\n', expected='255\n', status=0),
        dict(source='\n'.join(assignments+['overflow%=0'])+'\n', diagnostic='Variable limit exceeds 256'),
        dict(source='\n'.join(['DIM a%(0)', *assignments[:254], 'tail$="end"',
            'PRINT ;a%(0);":";v253%;":";tail$'])+'\n', expected='0:253:end\n', status=0),
        dict(source='GOTO @done\n'*4100+'@done:END\n', diagnostic='Too many address fixups'),
    ]


if __name__ == '__main__':
    spec = importlib.util.spec_from_file_location('output', ROOT/'docs/tasks/C002/tools/test_output.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    h.TASK = TASK
    h.programs = programs
    sys.argv += ['--skip-legacy', '--string-runtime', str(ROOT/'compiler/build/string-runtime')]
    h.main()
