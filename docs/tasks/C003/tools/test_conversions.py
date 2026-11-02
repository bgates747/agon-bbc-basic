"""Differential string/numeric conversions: actual BASIC is the oracle."""
import importlib.util
from pathlib import Path
import sys

TASK = Path(__file__).resolve().parents[1]
ROOT = TASK.parents[2]


def programs():
    groups = [
        ['a$="  -12.5suffix":n=VAL(a$):PRINT ;n',
         'PRINT "[";STR$(n);"]:[";STR$~(-12.9);"]"',
         'PRINT ;ASC "";":";ASC CHR$(0);":";ASC CHR$(255)',
         'PRINT ;VAL STR$(1/3);":";LEN STR$ 1/3',
         'b$=STR$(VAL("12")+1)+STR$~255:PRINT b$'],
        [f'PRINT ;VAL("{s}")' for s in ['', ' ', '+', '-', '.', '-.',
            'words', '&FF', '  12', ' +12', '- 12', '--12', '+-12',
            '12suffix', '12 34', '1.2.3', '1e2', '1E', '1E+', '1E-',
            '1E 2', '1E +2', '1E+ 2', '1E- 2', '1E--2']],
        [f'PRINT ;VAL("{s}")' for s in ['0', '-0', '1.0', '-1.0', '.5',
            '2147483647', '2147483648', '4294967295', '4294967296',
            '-2147483648', '-4294967295', '1E-38', '1E-39', '1E-99',
            '1.234567890123456789', '99999999999999999999999999999']],
        ['PRINT ;VAL(CHR$(0)+"12");":";VAL("12"+CHR$(0)+"34")',
         'PRINT ;VAL(CHR$(9)+"12");":";VAL(CHR$(255)+"12");":";VAL("12"+CHR$(128))',
         'a$="'+(' '*128)+'"', 'b$="'+(' '*125)+'12"',
         'c$=a$+b$:PRINT ;LEN c$;":";VAL c$;":";ASC c$'],
        [f'PRINT "[";STR$({s});"]:[";STR$~({s});"]"'
            for s in ['0', '-0', '1', '-1', '1.0', '-1.0', '.9', '-.9',
                      '255', '256', '65536', '&7FFFFFFF', '&80000000', '&FFFFFFFF']],
        [f'PRINT "[";STR$({s});"]"' for s in ['1/3', '-1/3', 'PI',
            '2147483648', '4294967296', '1E20', '1E-20', '1E38', '1E-38',
            '999999999', '999999999.5', '0.000000001', '0.0000000001']],
        ['PRINT ;1+VAL "2"*3;":";ASC "a"+1',
         'PRINT STR$ 1+STR$ 2', 'PRINT ;LEN STR$ (1/3)',
         'PRINT ;VAL LEFT$("12x",2);":";ASC MID$("abc",2)',
         'PRINT ;VAL STR$ VAL "12.5";":";ASC STR$~255',
         'PRINT STR$("a"="a");":";CHR$(ASC "A")',
         'a$="x":a$=STR$ ASC a$:PRINT a$'],
        ['PRINT ;ASC CHR$(0);":";ASC CHR$(128);":";ASC CHR$(255)',
         'PRINT ;ASC("a"+CHR$(0)+"z");":";ASC LEFT$("a",0)',
         'PRINT ;VAL("1E2")=100;":";(STR$(1)<STR$(2))',
         'VDU ASC "A",ASC STR$(2),13,10'],
    ]
    result = [dict(source='\n'.join(g)+'\n', reference=True, status=0) for g in groups]
    result.append(dict(source='10 GOTO 30\n20 PRINT VAL "1E999"\n30 PRINT "unreachable conversion"\n',
                       expected='unreachable conversion\n', status=0))
    result += [dict(source=s, reference=True, reference_error=True, status=1) for s in [
        'PRINT VAL "1E39"\n', 'PRINT VAL "1E100"\n',
        'PRINT STR$~2147483648\n', 'PRINT STR$~(-2147483649)\n',
        'PRINT VAL missing$\n', 'PRINT ASC missing$\n',
        'PRINT STR$(1/0)\n', 'PRINT VAL STR$~(1/0)\n',
        'a$="'+('x'*128)+'"\nb$="'+('y'*128)+'"\nPRINT VAL(a$+b$)\n',
    ]]
    result += [dict(source=s, diagnostic=d) for s, d in [
        ('PRINT VAL 1\n', 'Expected a string item'),
        ('PRINT ASC 1\n', 'Expected a string item'),
        ('PRINT STR$ "x"\n', 'String value used as a numeric item'),
        ('PRINT STR$~ "x"\n', 'String value used as a numeric item'),
        ('PRINT STR$(1,2)\n', 'Expected )'),
        ('PRINT VAL("1",2)\n', 'Expected )'),
        ('PRINT VAL "1"+"2"\n', 'Numeric/string type mismatch'),
        ('@%=0\n', 'Expected a name'),
        ('PRINT INKEY$(1)\n', 'Unsupported string item INKEY'),
        ('PRINT EVAL("1")\n', 'EVAL is deliberately unsupported'),
        ('PRINT "raw\ttab"\n', 'Use CHR$ for control bytes'),
    ]]
    return result


if __name__ == '__main__':
    smoke = '--smoke' in sys.argv
    if smoke:
        sys.argv.remove('--smoke')
    spec = importlib.util.spec_from_file_location('output_harness', ROOT/'docs/tasks/C002/tools/test_output.py')
    output = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(output)
    output.TASK = TASK
    output.programs = (lambda: programs()[:1]) if smoke else programs
    sys.argv += ['--isolate-reference', '--skip-legacy']
    if '--timeout' not in sys.argv:
        sys.argv += ['--timeout', '360']
    if '--string-runtime' not in sys.argv:
        sys.argv += ['--string-runtime', str(ROOT/'compiler/build/string-runtime')]
    output.main()
