"""Actual BASIC supplies INSTR/STRING$ results and errors; Python orchestrates."""
import importlib.util
from pathlib import Path
import sys

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def programs():
    groups=[
        ['a$="abracadabra":PRINT ;INSTR(a$,"abra");":";INSTR(a$,"abra",2)',
         'b$=STRING$(3,"ab"):PRINT b$;":";STR$ INSTR(b$,"ba")',
         'PRINT "[";STRING$(0,"x");"]:[";STRING$(2.9,"xy");"]"',
         'PRINT ;INSTR(STRING$(4,"ab"),"ab",INSTR("123","2"))',
         'PRINT STRING$(INSTR("abc","b"),STR$ ASC "A")'],
        [f'PRINT ;INSTR("abcabc","bc",{n});":";INSTR("abcabc","a",{n})'
         for n in [0,1,2,3,6,7,-1,-256,255,256,257,511,65536,16777217,1.9,-1.9]],
        ['PRINT ;INSTR("","");":";INSTR("a","");":";INSTR("","a")',
         'a$=STRING$(255,"a"):PRINT ;INSTR(a$,"");":";INSTR(a$,"",255)',
         'PRINT ;INSTR(a$,"a",255);":";INSTR(a$,"a",-1);":";INSTR(a$,"aa",255)',
         'PRINT ;INSTR(a$,"a",256);":";INSTR(a$,"a",0)',
         'PRINT ;INSTR(a$,a$);":";INSTR(a$,a$,2)',
         'PRINT ;INSTR("ab","abc");":";INSTR("aaaaab","aaab");":";INSTR("aaa","b")'],
        ['a$=CHR$(0)+CHR$(128)+CHR$(255)+CHR$(0)',
         'PRINT ;INSTR(a$,CHR$(0));":";INSTR(a$,CHR$(0),2);":";INSTR(a$,CHR$(128)+CHR$(255))',
         'b$=STRING$(3,CHR$(0)+CHR$(255)):PRINT ;LEN b$;":";ASC b$;":";ASC MID$(b$,2)',
         'PRINT ;(b$=CHR$(0)+CHR$(255)+CHR$(0)+CHR$(255)+CHR$(0)+CHR$(255))',
         'PRINT ;INSTR(b$,CHR$(255)+CHR$(0),3)'],
        [f'PRINT ;LEN STRING$({n},"x");":";LEN STRING$({n},"")'
         for n in [0,1,2,255,256,257,511,-1,-256,-255,65536,16777217,1.9,-1.9]],
        ['PRINT ;LEN STRING$(85,"abc");":";LEN STRING$(127,"ab")',
         'a$=STRING$(255,"x"):PRINT ;(STRING$(1,a$)=a$);":";LEN STRING$(0,a$)',
         'PRINT ;INSTR(STRING$(254,"x")+"y","y");":";INSTR(STRING$(253,"x")+"yz","yz")',
         'PRINT ;INSTR(STRING$(255,"x"),STRING$(255,"x"))'],
        ['s$="ab":s$=STRING$(3,s$):PRINT s$:t$=s$:s$="z":PRINT t$',
         'PRINT STRING$(2,STRING$(3,"x"))+STR$ INSTR("abc","b")',
         'PRINT ;LEN STRING$(2,LEFT$("abcdef",3));":";VAL STRING$(2,"12")',
         'PRINT ;1+INSTR("abc","b")*2;":";(INSTR("abc","a")=1)',
         'VDU 64+INSTR("abc","a"),13,10'],
        ['n%=INSTR("abc","b"):b&=INSTR(STRING$(255,"x"),"x",255):r=INSTR("x","")',
         'PRINT ;n%;":";b&;":";r',
         'PRINT STRING$("a"="b","x");":";LEN STRING$("a"="a","x")',
         'PRINT ;INSTR("abc","a","a"="b");":";INSTR("abc","a",&80000000)'],
    ]
    result=[dict(source='\n'.join(g)+'\n',reference=True,status=0) for g in groups]
    result += [dict(source=s,reference=True,reference_error=True,status=1) for s in [
        'PRINT STRING$(128,"ab")\n',
        'PRINT STRING$(-1,"ab")\n',
        'PRINT STRING$(2147483648,missing$)\n',
        'PRINT STRING$(0,missing$)\n',
        'PRINT STRING$(0,CHR$(1/0))\n',
        'PRINT STRING$(2,STRING$(128,"ab"))\n',
        'PRINT INSTR(missing$,CHR$(1/0),2147483648)\n',
        'PRINT INSTR("x",missing$,1/0)\n',
        'PRINT INSTR("","",2147483648)\n',
        'PRINT INSTR("abc","",1/0)\n',
        'PRINT INSTR("x",CHR$(1/0),2147483648)\n',
    ]]
    result += [dict(source=s,diagnostic=d) for s,d in [
        ('PRINT INSTR(1,"x")\n','Expected a string item'),
        ('PRINT INSTR("x",1)\n','Expected a string item'),
        ('PRINT INSTR("x","x","x")\n','String value used as a numeric item'),
        ('PRINT INSTR("x")\n','Expected ,'),
        ('PRINT INSTR("x","x",1,2)\n','Expected )'),
        ('PRINT STRING$("x","x")\n','String value used as a numeric item'),
        ('PRINT STRING$(1,2)\n','Expected a string item'),
        ('PRINT STRING$(1,"x",2)\n','Expected )'),
        ('PRINT STRING$(1)\n','Expected ,'),
        ('PRINT INKEY$(1)\n','Unsupported string item INKEY'),
        ('PRINT EVAL("1")\n','EVAL is deliberately unsupported'),
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
