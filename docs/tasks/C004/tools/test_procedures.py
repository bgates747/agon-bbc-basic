"""Reference differential scalar PROC/LOCAL qualification."""
from pathlib import Path
import importlib.util,sys,json,subprocess
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]

def program(main,defs,**kw):
 source='\n'.join([*main,'END',*defs])+'\n'
 return dict(source=source,reference_source='\n'.join(main)+'\n',reference_definitions=defs,reference=True,status=0,**kw)

def programs():
 result=[
  program(['A%=7:B%=8:PROCswap(A%,B%):PRINT ;A%;":";B%'],['DEF PROCswap(B%,A%):PRINT ;A%;":";B%:ENDPROC']),
  program(['x%=7:y%=8:PROCstaged(3,x%):PRINT ;x%;":";y%'],['DEF PROCstaged(x%,y%):PRINT ;x%;":";y%:ENDPROC']),
  program(['PROCnew:PRINT ;fresh%;":";LEN fresh$'],['DEF PROCnew:LOCAL fresh%,fresh$:fresh%=4:fresh$="x":ENDPROC']),
  program(['v%=7:PROCtwice:PRINT ;v%'],['DEF PROCtwice:LOCAL v%:v%=3:LOCAL v%:PRINT ;v%:v%=4:ENDPROC']),
  program(['text$="outer":PROCouter:PRINT text$'],['DEF PROCouter:LOCAL text$:text$="inner":PROCsee:ENDPROC','DEF PROCsee:PRINT text$:ENDPROC']),
  program(['value=1.5:whole%=-7:byte&=255:s$="old":PROCtypes(2.5,9.9,257,"new"):PRINT ;value;":";whole%;":";byte&;":";s$'],['DEF PROCtypes(value,whole%,byte&,s$):PRINT ;value;":";whole%;":";byte&;":";s$:ENDPROC']),
  program(['copy$="original":PROCslice(copy$):PRINT copy$'],['DEF PROCslice(s$):MID$(s$,2,2)="XY":PRINT s$:ENDPROC']),
  program(['PROCrecursive(4):PRINT ;n%'],['DEF PROCrecursive(n%):PRINT ;n%:IF n%>0 THEN PROCrecursive(n%-1)','ENDPROC']),
  program(['n%=9:s$="outer":PROCnest(3):PRINT ;n%;":";s$'],['DEF PROCnest(n%):LOCAL s$:s$=STR$ n%:IF n%>0 THEN PROCnest(n%-1)','PRINT ;n%;":";s$:ENDPROC']),
  program(['FOR i%=1 TO 3:PROCloop(i%):NEXT:PRINT ;i%'],['DEF PROCloop(i%):LOCAL j%:FOR j%=1 TO 2:PRINT ;i%;":";j%:NEXT:ENDPROC']),
  program(['PROCearly(0):PROCearly(1):PRINT "done"'],['DEF PROCearly(n%):LOCAL x%:x%=7:IF n%=0 THEN PRINT "early":ENDPROC','PRINT "normal":ENDPROC']),
  program(['a$="saved":PROCfull(STRING$(255,"x")):PRINT a$'],['DEF PROCfull(a$):PRINT ;LEN a$;":";ASC a$:a$=STRING$(255,"y"):PRINT ;LEN a$;":";ASC a$:ENDPROC']),
  program(['PROCrepeated:PRINT ;x%;":";y%'],['DEF PROCrepeated:LOCAL x%,y%:x%=2:y%=3:ENDPROC']),
 ]
 # Bundle independent observations to avoid rebuilding identical runtime code.
 observations=result;result=[]
 for start in range(0,len(observations),4):
  block=observations[start:start+4];main=[];defs=[]
  for case in block:main+=case['reference_source'].splitlines();defs+=case['reference_definitions']
  case=program(main,defs);case['procedure_observations']=len(block);result.append(case)
 for main,defs in [
  (['PROCbadloop'],['DEF PROCbadloop:FOR i%=1 TO 1:LOCAL x%:NEXT:ENDPROC']),
  (['PROCbadexit'],['DEF PROCbadexit:FOR i%=1 TO 1:ENDPROC:NEXT']),
  (['PROCbadreturn'],['DEF PROCbadreturn:RETURN:ENDPROC']),
  (['PROCundefined'],['DEF PROCundefined:PRINT missing:ENDPROC']),
  (['PROCbadarg(2147483648)'],['DEF PROCbadarg(n%):PRINT n%:ENDPROC']),
  (['PROCbadstr(STRING$(128,"ab"))'],['DEF PROCbadstr(s$):ENDPROC']),
 ]:
  case=program(main,defs);case.update(reference_error=True,status=1);result.append(case)
 result += [dict(source=s,expected=e,status=status) for s,e,status in [
  ('LOCAL x%\n','Not in a FN or PROC\n',1),('ENDPROC\n','Not in a PROC\n',1),
  ('DEF PROCunused:PRINT "bad":ENDPROC\nPRINT "after"\n','after\n',0),
  ('DEF PROCfall\nPRINT "body"\nENDPROC\n','body\nNot in a PROC\n',1),
  ('PROCsub:PRINT "done":END\nDEF PROCsub\nGOSUB @sub\nENDPROC\n@sub:PRINT "gosub":RETURN\n','gosub\ndone\n',0),
 ]]
 result += [dict(source=s,diagnostic=d) for s,d in [
  ('PROCmissing\n','Undefined PROC missing'),('DEF PROCp\nDEF PROCp\n','Duplicate definition p'),
  ('DEF PROCp(a%,a%)\n','Duplicate formal parameter'),('DEF PROCp(RETURN a%)\n','Unsupported formal parameter RETURN'),
  ('DEF invalid\n','Expected PROC or FN after DEF'),('LOCAL DATA\n','Unsupported LOCAL form DATA'),
  ('PROCp(1)\nEND\nDEF PROCp(s$):ENDPROC\n','Procedure argument type mismatch'),
  ('PROCp(1,2)\nEND\nDEF PROCp(a%):ENDPROC\n','Expected )'),
  ('PROCp\nEND\nDEF PROCp(a%):ENDPROC\n','Expected ('),
  ('DEF PROCp()\n','Empty formal parameter lists are unsupported'),
  ('GOTO @finish\nDEF PROCp:ENDPROC\n@finish:END\n','Undefined target @finish'),
  ('@outside:END\nDEF PROCp:GOTO @outside:ENDPROC\n','Undefined target $p1@outside'),
  ('IF 1 THEN\nDEF PROCp:ENDPROC\nENDIF\n','Definition crosses an open block'),
 ]]
 return result

if __name__=='__main__':
 smoke='--smoke' in sys.argv
 if smoke:sys.argv.remove('--smoke')
 spec=importlib.util.spec_from_file_location('output',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 compiler=Path(sys.argv[sys.argv.index('--compiler')+1]) if '--compiler' in sys.argv else ROOT/'compiler/compiler.bas'
 lines=compiler.read_text().splitlines();ids=[int(l.split()[0]) for l in lines]
 assert ids==sorted(set(ids)) and max(len(l.split(' ',1)[1]) for l in lines)<=255
 h.TASK=TASK;h.programs=(lambda:programs()[:1]) if smoke else programs
 sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
