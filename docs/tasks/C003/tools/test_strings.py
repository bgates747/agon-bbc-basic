"""Compare string compiler output with isolated actual BASIC reference programs."""
import importlib.util
from pathlib import Path
import sys

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def programs():
    groups=[
        ['a$="hello":PRINT a$:LET b$=a$:PRINT b$', 'a$="x":PRINT a$;":";b$',
         'a$=a$+"y":PRINT a$', 'b$=b$:PRINT b$'],
        ['empty$="":PRINT "[";empty$;"]"', 'fresh$=fresh$+"a":PRINT fresh$',
         'PRINT LEN(empty$);":";LEN(fresh$)', 'PRINT ("a"+("b"+"c"))',
         'PRINT "a"+CHR$(65+1)+"c"', 'PRINT LEN(CHR$(0))'],
        ['n%=65:a$=CHR$(n%):PRINT a$;":";LEN(a$)',
         'PRINT CHR$65;CHR$(321);CHR$65.9', 'PRINT LEN("a"+"bc")+LEN "d"',
         'PRINT CHR$(64+LEN("a"));":";CHR$(LEN(CHR$(65))+64)',
         'text$="a:b""c":PRINT text$'],
        ['a$="a":b$="b":a$="longer":b$="longest":PRINT a$;":";b$',
         'a$="x":a$="same":a$="":a$="up":PRINT a$;":";b$',
         's$="a":s=7:s%=8:s&=9:PRINT s$;s;s%;s&'],
        ['a$="'+('x'*128)+'"', 'b$="'+('y'*127)+'"', 'c$=a$+b$:PRINT LEN(c$)',
         'PRINT LEN(c$+""):d$=c$:c$="z":PRINT LEN(d$);":";LEN(c$)'],
    ]
    if '--smoke' in sys.argv:groups=groups[:2]
    result=[dict(source='\n'.join(g)+'\n',reference=True,status=0) for g in groups]
    result += [dict(source=f'reused$="{text}":PRINT reused$\n',reference=True,status=0) for text in ('one','two')]
    if '--smoke' in sys.argv:return result
    result += [dict(source=s,reference=True,reference_error=True,status=1) for s in [
        'PRINT missing$\n',
        'PRINT LEN(missing$)\n',
        'PRINT CHR$(2147483648)\n',
        'a$="'+('x'*128)+'"\nb$="'+('y'*128)+'"\nc$=a$+b$\n',
        # Group must finish (division error) before the outer concatenation overflows.
        'a$="'+('x'*200)+'"\nb$="'+('y'*100)+'"\nPRINT a$+(b$+CHR$(1/0))\n',
    ]]
    result += [dict(source=s,expected=e,status=st) for s,e,st in [
        ('GOTO @ok\na$="x"\n@ok:PRINT a$\n','No such variable\n',1),
        ('a$="a":GOSUB @sub:PRINT a$:END\n@sub:a$=a$+"b":RETURN\n','ab\n',0),
    ]]
    result += [dict(source=s,reference=True,status=0) for s in ['PRINT STR$(1)\n','PRINT VAL("1")\n']]
    result += [dict(source=s,diagnostic=d) for s,d in [
        ('a$=1\n','Expected a string item'),
        ('a%=s$\n','String value used as a numeric item'),
        ('a$="x"+1\n','Numeric/string type mismatch'),
        ('PRINT INKEY$(1)\n','Unsupported string item INKEY'),
        ('a$(0)="x"\n','Arrays and function calls'),
        ('a$+="x"\n','Expected ='),
        ('PRINT "a"="b"="c"\n','Chained comparisons'),
    ]]
    return result


if __name__=='__main__':
    smoke='--smoke' in sys.argv
    spec=importlib.util.spec_from_file_location('output_harness',ROOT/'docs/tasks/C002/tools/test_output.py')
    output=importlib.util.module_from_spec(spec);spec.loader.exec_module(output)
    output.TASK=TASK
    output.programs=programs
    # Select the small fixture without passing a harness-specific flag onward.
    if smoke:sys.argv.remove('--smoke')
    if smoke:output.programs=lambda: [dict(source=s,reference=True,status=0) for s in [
        'a$="hello":b$=a$:a$="x":PRINT a$;":";b$:a$=a$+"y":PRINT a$\n',
        'empty$="":PRINT "[";empty$;"]":fresh$=fresh$+"a":PRINT fresh$:PRINT LEN(fresh$)\n',
    ]]
    sys.argv+=['--isolate-reference']
    if '--string-runtime' not in sys.argv:
        sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
    output.main()
