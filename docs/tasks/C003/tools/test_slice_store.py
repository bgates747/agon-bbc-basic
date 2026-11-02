"""Compare slice-assignment source and errors with actual BBC BASIC."""
import importlib.util
from pathlib import Path
import sys

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def programs():
    groups=[
        ['a$="abcdef":LEFT$(a$)="XYZ":PRINT a$',
         'a$="abcdef":RIGHT$(a$)="XYZ":PRINT a$',
         'a$="abcdef":MID$(a$,2)="XYZ":PRINT a$',
         'a$="abcdef":MID$(a$,0)="XYZ":PRINT a$',
         'a$="abcdef":MID$(a$,0,2)="XYZ":PRINT a$'],
    ]
    counts=[0,1,2,5,6,7,-1,-256,255,256,257,511,65536,16777217,1.9,-1.9]
    for function in ['LEFT','RIGHT']:
        groups.append([f'a$="abcdef":{function}$(a$,{n})="XYZ":PRINT a$' for n in counts])
    for start in [counts[:8],counts[8:]]:
        groups.append([f'a$="abcdef":MID$(a$,{n})="XYZ":PRINT a$' for n in start]+
                      [f'a$="abcdef":MID$(a$,{n},2)="XYZ":PRINT a$' for n in start])
    groups.append([f'a$="abcdef":MID$(a$,2,{n})="XYZ":PRINT a$' for n in counts])
    groups.append([f'a$=STRING$(255,"x"):MID$(a$,{s},{n})="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)'
                   for s,n in [(2,255),(3,254),(255,2),(255,3),(0,255),(0,0),(0,1),(256,2),(1,255),(2,256),(257,255),(-1,2)]])
    groups += [
        ['a$="":LEFT$(a$)="x":RIGHT$(a$)="x":MID$(a$,0,2)="x":PRINT "[";a$;"]"',
         'a$="x":LEFT$(a$)="y":PRINT a$:LEFT$(a$,1)="":PRINT a$',
         'a$="xy":RIGHT$(a$,255)="A":PRINT a$:MID$(a$,1,0)="B":PRINT a$',
         'RIGHT$(a$,255)="":PRINT a$:LEFT$(a$,255)="ABCDEF":PRINT a$'],
        ['a$="abcdef":LEFT$(a$,3)=RIGHT$(a$,3):PRINT a$',
         'a$="abcdef":RIGHT$(a$,4)=LEFT$(a$,2):PRINT a$',
         'a$="abcdef":MID$(a$,2,3)=a$:PRINT a$',
         'b$=a$:MID$(a$,2,LEN(a$)-2)=STRING$(2,"Z"):PRINT a$;":";b$',
         'LEFT$(a$,LEN(a$))=STR$ INSTR(a$,"a"):PRINT a$'],
        ['a$=CHR$(0)+CHR$(128)+CHR$(255):b$=a$',
         'MID$(a$,2,1)=CHR$(0):PRINT ;LEN a$;":";ASC MID$(a$,2);":";ASC RIGHT$(a$)',
         'RIGHT$(a$,2)=CHR$(255):PRINT ;ASC RIGHT$(a$);":";(b$=CHR$(0)+CHR$(128)+CHR$(255))',
         'LEFT$(a$,1)=CHR$(128):PRINT ;ASC a$;":";LEN a$'],
    ]
    result=[dict(source='\n'.join(g)+'\n',reference=True,status=0) for g in groups]
    result += [dict(source=s,reference=True,reference_error=True,status=1) for s in [
        'LEFT$(missing$,1/0)=CHR$(1/0)\n',
        'RIGHT$(missing$)="x"\n',
        'MID$(missing$,2147483648)="x"\n',
        'a$="x":LEFT$(a$,2147483648)=missing$\n',
        'a$="":MID$(a$,1/0,2147483648)=missing$\n',
        'a$="":MID$(a$,1,2147483648)=missing$\n',
        'a$="":LEFT$(a$,0)=missing$\n',
        'a$="x":MID$(a$,0)=CHR$(1/0)\n',
        'a$="":RIGHT$(a$,0)=STRING$(128,"ab")\n',
    ]]
    result += [dict(source=s,diagnostic=d) for s,d in [
        ('LEFT$(a%,1)="x"\n','Expected a string variable'),
        ('MID$("abc",1)="x"\n','Expected a name'),
        ('RIGHT$(a$(0),1)="x"\n','Arrays and function calls'),
        ('MID$(a$)="x"\n','Expected ,'),
        ('LEFT$(a$,1,2)="x"\n','Expected )'),
        ('LEFT$(a$,"x")="x"\n','String value used as a numeric item'),
        ('LEFT$(a$,1)=1\n','Expected a string item'),
        ('RIGHT$(a$,1)\n','Expected ='),
    ]]
    return result


if __name__=='__main__':
    smoke='--smoke' in sys.argv
    if smoke:sys.argv.remove('--smoke')
    spec=importlib.util.spec_from_file_location('output_harness',ROOT/'docs/tasks/C002/tools/test_output.py')
    output=importlib.util.module_from_spec(spec);spec.loader.exec_module(output)
    output.TASK=TASK;output.programs=(lambda:programs()[:1]) if smoke else programs
    sys.argv+=['--isolate-reference','--skip-legacy']
    if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
    output.main()
