"""Actual BBC compilation at the routine boundary and bounded FN transfers."""
from pathlib import Path
import importlib.util
import sys

TASK = Path(__file__).resolve().parent
ROOT = TASK.parents[2]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def programs():
    p = module('procedures', ROOT/'docs/tasks/C004/tools/test_procedures.py')
    definitions = [f'DEF PROCp{i}:ENDPROC' for i in range(256)]
    return [
        dict(source='PROCp255:PRINT "capacity":END\n'+'\n'.join(definitions)+'\n',
             expected='capacity\n', status=0),
        p.program([
            'PRINT ;LEN FNempty;":";LEN FNmaximum;":";FNmaximum=STRING$(255,"q")',
            'PRINT ;ASC FNbytes;":";ASC MID$(FNbytes,2);":";ASC RIGHT$(FNbytes,1)',
            'PRINT FNtext;":";FNempty+"end"',
        ], ['DEF FNempty=""', 'DEF FNmaximum=STRING$(255,"q")',
            'DEF FNbytes=CHR$(0)+CHR$(128)+CHR$(255)', 'DEF FNtext="DATA REM = text"']),
        dict(source='\n'.join(definitions+['DEF PROCoverflow:ENDPROC'])+'\n',
             diagnostic='Procedure limit exceeds 256'),
        dict(source='PRINT FNvalue:END\nDEF FNvalue=3\nDATA : ="not a return"\n',
             diagnostic='Unsupported statement DATA'),
        dict(source='PRINT FNvalue:END\nDEF FNvalue=3:DATA : ="not a return"\n',
             diagnostic='Unsupported statement DATA'),
    ]


if __name__ == '__main__':
    h = module('output', ROOT/'docs/tasks/C002/tools/test_output.py')
    h.TASK = TASK
    smoke = '--smoke' in sys.argv
    if smoke:
        sys.argv.remove('--smoke')
    h.programs = (lambda: [programs()[i] for i in (1, 3, 4)]) if smoke else programs
    sys.argv += ['--isolate-reference', '--skip-legacy']
    h.main()
