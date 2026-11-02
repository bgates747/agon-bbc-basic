"""Differential slicing and typed string-relation qualification, using BASIC."""
import importlib.util
from pathlib import Path
import sys

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def programs():
    groups=[
        ['a$="abc":PRINT LEFT$(a$);":";RIGHT$(a$);":";MID$(a$,2)',
         'PRINT LEFT$(a$,2);":";RIGHT$(a$,2);":";MID$(a$,2,1)',
         'PRINT ;("a"<"b");":";("abc"="abc");":";("a">="b")',
         'n%=(("a"="a") AND ("ab">"a")):PRINT ;n%:VDU 65-("a"="b"),13,10'],
        ['a$="abcd"']+[f'PRINT "[";LEFT$(a$,{n});"]:[";RIGHT$(a$,{n});"]"'
             for n in [0,1,4,5,-1,-256,255,256,257,511,65536,16777217]],
        ['a$="abcd"']+[f'PRINT "[";MID$(a$,{n});"]:[";MID$(a$,{n},2);"]"'
             for n in [0,1,2,4,5,-1,-256,255,256,257,511,65536,16777218]],
        ['a$="abcd"']+[f'PRINT "[";MID$(a$,2,{n});"]"'
             for n in [0,1,3,4,-1,255,256,257,511,-256]],
        ['empty$="":PRINT "[";LEFT$(empty$);RIGHT$(empty$);MID$(empty$,0);"]"',
         'PRINT LEN(LEFT$(empty$,255));":";LEN(RIGHT$(empty$,1));":";LEN(MID$(empty$,1,2))',
         'a$="abc":PRINT LEFT$(a$,2.9);":";RIGHT$(a$,-1.9);":";MID$(a$,2.9,1.9)',
         'PRINT LEFT$("a"+"bc",1+1)+RIGHT$("xyz",2)',
         'PRINT MID$(LEFT$("abcdef",5),2,LEN(RIGHT$("abcd",2)))'],
        ['a$="abc":b$=MID$(a$,2):a$="z":PRINT b$:b$=LEFT$(b$):PRINT b$',
         'x$="abcdef":x$=MID$(x$,2,3):PRINT x$:x$=RIGHT$(x$,2):PRINT x$',
         'PRINT ;LEN(LEFT$("abcd",2))+LEN(MID$("abcd",3))',
         'PRINT ;("a"="a")+2;":";NOT("a"="b");":";ABS("a"="a")',
         'PRINT ;(("a"<"b")=(1<2));":";(("a"="a") AND ("c">"b"))'],
        ['a$=CHR$(0)+CHR$(128)+CHR$(255)',
         'PRINT LEN(MID$(a$,1,1));":";LEN(RIGHT$(a$,2));":";LEN(LEFT$(a$,3))',
         'PRINT ;(CHR$(0)<CHR$(1));":";(CHR$(255)>CHR$(128));":";(CHR$(128)>"z")',
         'PRINT ;(CHR$(0)+"x"=CHR$(0)+"x");":";(CHR$(0)<CHR$(0)+"x")'],
    ]
    for left,right in [('""','""'),('""','"a"'),('"a"','""'),('"a"','"aa"'),('"aa"','"a"'),('"abc"','"abd"')]:
        groups.append([f'PRINT ;({left}{op}{right})' for op in ['=','<>','<','<=','>','>=']])
    groups.append(['a$="'+('x'*128)+'"','b$="'+('y'*127)+'"','c$=a$+b$',
        'PRINT LEN(LEFT$(c$,255));":";LEN(RIGHT$(c$,255));":";LEN(MID$(c$,255,255))',
        'PRINT ;(LEFT$(c$,128)=a$);":";(RIGHT$(c$,127)=b$);":";(c$=a$+b$)'])
    groups.append(['PRINT '+('('*20)+'"deep"'+(')'*20),
                   'PRINT LEFT$("abc",("a"="a"));":";MID$("abc",("a"="b"),257)'])
    result=[dict(source='\n'.join(g)+'\n',reference=True,status=0) for g in groups]
    result += [dict(source=s,reference=True,reference_error=True,status=1) for s in [
        'PRINT LEFT$("abc",2147483648)\n',
        'PRINT RIGHT$("",2147483648)\n',
        'PRINT MID$("abc",2147483648)\n',
        'PRINT MID$("abc",1,2147483648)\n',
        'PRINT LEFT$(missing$,1/0)\n',
        'PRINT MID$("abc",1/0,2147483648)\n',
        'PRINT MID$("",255,1/0)\n',
        'PRINT "a"=missing$\n',
        'PRINT "a"=CHR$(1/0)\n',
        'a$="'+('x'*128)+'"\nb$="'+('y'*128)+'"\nPRINT a$+b$=""\n',
    ]]
    result.append(dict(source='LEFT$(a$,1)="x"\n',reference=True,reference_error=True,status=1))
    result += [dict(source=s,diagnostic=d) for s,d in [
        ('PRINT LEFT$("x",1,2)\n','Expected )'),
        ('PRINT MID$("x")\n','Expected ,'),
        ('PRINT LEFT$(1,2)\n','Expected a string item'),
        ('PRINT RIGHT$("x","a")\n','String value used as a numeric item'),
        ('PRINT "x"=1\n','Numeric/string type mismatch'),
        ('PRINT 1="x"\n','Numeric/string type mismatch'),
        ('PRINT "a"<"b"<"c"\n','Chained comparisons'),
        ('PRINT "a"-"b"\n','Only concatenation and comparisons'),
        ('PRINT EVAL("1")\n','EVAL is deliberately unsupported'),
        ('PRINT INKEY$(1)\n','Unsupported string item INKEY'),
    ]]
    result.append(dict(source='\n'.join([
        'PRINT "a"="a"', 'PRINT "b"<"a"', 'PRINT "a"+"b"="ab"',
        'PRINT ;"a"="a";":";"x"<"y"', 'PRINT ("a"="a")+2',
        'PRINT ABS("a"="a")',
        'a$="abcde":a$=MID$(a$,2,LEN(a$)-1):PRINT a$',
    ])+'\n',reference=True,status=0))
    return result


if __name__=='__main__':
    smoke='--smoke' in sys.argv
    if smoke:sys.argv.remove('--smoke')
    dispatch='--print-dispatch' in sys.argv
    if dispatch:sys.argv.remove('--print-dispatch')
    spec=importlib.util.spec_from_file_location('output_harness',ROOT/'docs/tasks/C002/tools/test_output.py')
    output=importlib.util.module_from_spec(spec);spec.loader.exec_module(output)
    output.TASK=TASK;output.programs=(lambda:programs()[:1]) if smoke else programs
    if dispatch:output.programs=lambda:programs()[-1:]
    sys.argv+=['--isolate-reference','--skip-legacy']
    if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
    output.main()
