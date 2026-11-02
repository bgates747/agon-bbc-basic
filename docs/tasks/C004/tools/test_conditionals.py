"""Differential conditional qualification using actual BBC BASIC as oracle."""
from pathlib import Path
import importlib.util
import sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
def programs():
 groups=[
 ['IF 1 THEN PRINT "yes" ELSE PRINT "bad"','IF 0 THEN PRINT "bad" ELSE PRINT "no"','IF 1 PRINT "omitted"','IF 0 PRINT "bad"','PRINT "done"'],
 [f'IF {v} THEN PRINT "true" ELSE PRINT "false"' for v in ['0','1','-1','.9','-.9','1.9','-1.9','&80000000','&7FFFFFFF','65536','16777216','TRUE','FALSE','1=1','"a"<"b"']],
 [f'IF {a} THEN IF {b} THEN PRINT "inner-yes" ELSE PRINT "inner-no" ELSE PRINT "outer-no"' for a,b in [(0,0),(0,1),(1,0),(1,1)]],
 ['IF 0 THEN PRINT "bad":PRINT "bad" ELSE PRINT "else":PRINT "tail"','IF 1 THEN PRINT "then":PRINT "tail" ELSE PRINT "bad":PRINT "bad"','IF 0 THEN PRINT "bad" ELSE IF 1 THEN PRINT "nested" ELSE PRINT "bad"'],
 ['IF 1 THEN PRINT "ELSE : THEN" ELSE PRINT "bad"','IF 0 THEN PRINT "ELSE" ELSE PRINT """quoted"""','IF 0 THEN REM ELSE PRINT "bad"','IF 1 THEN REM ELSE PRINT "bad"','PRINT "after REM"'],
 ['IF 1 THEN PRINT ELSE PRINT "bad"','IF 0 THEN PRINT "bad" ELSE PRINT','IF 0 THEN PRINT "bad" ELSE PRINT ;','IF 1 THEN PRINT ;1 ELSE PRINT ;2','IF 1 THEN PRINT "x"; ELSE PRINT "bad"','PRINT "y"'],
 ['IF 0 THEN missing%=missing%+1:PRINT missing$','IF 0 THEN PRINT 1E39 ELSE PRINT "skipped overflow"','IF 1 THEN PRINT "skipped error" ELSE PRINT 1/0'],
 ['IF 0 THEN','PRINT "bad"','ELSE','PRINT "outer else"','IF 1 THEN','PRINT "inner true"','ELSE','PRINT "bad"','ENDIF','ENDIF','PRINT "done"'],
 ['IF 1 THEN','PRINT "true"','IF 0 THEN','PRINT "bad"','ELSE PRINT "inner else"','ENDIF','ELSE PRINT "bad"','ENDIF','IF 0 THEN','PRINT "bad"','ENDIF','PRINT "done"'],
 ['IF 1 THEN a$="abc":VDU 65,13,10 ELSE PRINT "bad"','IF a$="abc" THEN PRINT a$ ELSE PRINT "bad"'],
 ]
 result=[dict(source='\n'.join(g)+'\n',reference=True,status=0) for g in groups]
 result += [dict(source=s,reference=True,reference_error=True,status=1) for s in ['IF missing THEN PRINT "bad"\n','IF 1/0 THEN PRINT "bad"\n','IF 2147483648 THEN PRINT "bad"\n','IF 1 THEN PRINT missing$ ELSE PRINT "bad"\n','IF 0 THEN PRINT "bad" ELSE PRINT 1E39\n']]
 # Conventional numbered targets cannot pass the renumbering reference wrapper.
 result += [dict(source='10 IF 0 THEN 40 ELSE 30\n20 PRINT "bad":END\n30 PRINT "line":END\n40 PRINT "bad":END\n',expected='line\n',status=0),dict(source='IF 0 THEN GOTO @bad ELSE GOSUB @sub\nPRINT "done":END\n@bad:PRINT "bad":END\n@sub:PRINT "sub":RETURN\n',expected='sub\ndone\n',status=0)]
 result += [dict(source=s,diagnostic=d) for s,d in [
 ('IF 1 THEN\nPRINT "x"\n','Missing ENDIF'),('ELSE\n','ELSE without multiline IF'),('ENDIF\n','ENDIF without multiline IF'),('IF 1 THEN\nELSE\nELSE\nENDIF\n','Duplicate multiline ELSE'),('PRINT 1 ELSE PRINT 2\n','ELSE without inline IF'),('IF "x" THEN PRINT 1\n','String value used as a numeric item'),('IF 1 THEN IF 1 THEN\nENDIF\n','Multiline IF inside inline IF is unsupported'),('IF 1 THEN\n'*33+'ENDIF\n'*33,'Block nesting exceeds 32'),('IF 1 THEN '*33+'PRINT 1\n','Source line exceeds 255 bytes')]]
 return result
if __name__=='__main__':
 smoke='--smoke' in sys.argv
 if smoke:sys.argv.remove('--smoke')
 spec=importlib.util.spec_from_file_location('output',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 compiler=Path(sys.argv[sys.argv.index('--compiler')+1]) if '--compiler' in sys.argv else ROOT/'compiler/compiler.bas'
 lines=compiler.read_text().splitlines();ids=[int(line.split()[0]) for line in lines]
 assert ids==sorted(set(ids)) and max(len(line.split(' ',1)[1]) for line in lines)<=255
 h.TASK=TASK;h.programs=(lambda:programs()[:1]) if smoke else programs
 sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
