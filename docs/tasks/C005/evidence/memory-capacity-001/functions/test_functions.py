"""Actual BASIC differential function results and saved caller expressions."""
from pathlib import Path
import importlib.util,sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
spec=importlib.util.spec_from_file_location('procs',TASK/'tools/test_procedures.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def programs():
 result=[
 m.program(['PRINT ;FNadd(2,3);":";FNtext("x")','PRINT ;7+FNadd(4,5);":";"a"+FNtext("b")+"c"'],['DEF FNadd(a,b)=a+b','DEF FNtext(s$)=s$+s$']),
 m.program(['PRINT ;FNfact(7);":";FNfib(8);":";n%','PRINT ;FNidentity(1/3)=1/3;":";FNidentity(&80000000)','PRINT ;FNwide(&7FFFFFFF);":";FNidentity(1.5)'],['DEF FNfact(n%):IF n%=0 THEN =1 ELSE =n%*FNfact(n%-1)','DEF FNfib(n%):IF n%<2 THEN =n% ELSE =FNfib(n%-1)+FNfib(n%-2)','DEF FNidentity(x)=x','DEF FNwide(x)=x+1']),
 m.program(['PRINT "a"+FNrepeat(3)+"b"','PRINT FNleft(2,"A");":";FNempty;":";FNtag$("x");":";FNnumber$','PRINT ;LEN FNnul;":";ASC MID$(FNnul,2);":";ASC RIGHT$(FNnul,1)','PRINT ;LEN FNfull;":";ASC FNfull'],['DEF FNrepeat(n%):IF n%=0 THEN ="x" ELSE =FNrepeat(n%-1)+"x"','DEF FNleft(n%,s$):IF n%=0 THEN =s$ ELSE =s$+FNleft(n%-1,s$+"B")','DEF FNempty=""','DEF FNtag$(s$)=s$+"!"','DEF FNnumber$=3','DEF FNnul=CHR$(0)+CHR$(128)+CHR$(255)','DEF FNfull=STRING$(255,"q")']),
 m.program(['A%=7:B%=8:PRINT FNswap(A%,B%):PRINT ;A%;":";B%','PRINT FNjoin(FNdouble("a"),FNdouble("b"))','PRINT FNcombine(FNsum(1,2),FNsum(3,4),FNdouble("z"))','PRINT ;FNcreated(newarg%);":";newarg%','x%=7:PRINT ;FNtake(FNside);":";x%'],['DEF FNswap(B%,A%)=STR$ A%+":"+STR$ B%','DEF FNjoin(a$,b$)=a$+b$','DEF FNdouble(s$)=s$+s$','DEF FNsum(a,b)=a+b','DEF FNcombine(a%,b%,s$)=STR$ a%+":"+STR$ b%+":"+s$','DEF FNcreated(newarg%)=newarg%','DEF FNtake(x%)=x%','DEF FNside:x%=9:=1']),
 m.program(['s$="outer":PRINT FNglobal:PRINT s$;":";retained$','PRINT FNwithproc(3):PROCprintnum(FNwithproc(2))'],['DEF FNglobal:LOCAL s$:s$="inner":retained$=s$:=s$+"!"','DEF FNwithproc(n%):LOCAL value%:value%=n%+1:PROCsnoop:=value%*2','DEF PROCsnoop:PRINT ;value%:ENDPROC','DEF PROCprintnum(n%):PRINT ;n%:ENDPROC']),
 m.program(['PRINT FNforward;":";FNcomments;":";FNparent(2)','PRINT ;FNlogic(1);":";FNlogic(0);":";FNplus','PRINT FNquoted'],['DEF FNforward=FNlater','DEF FNlater="forward"','DEF FNcomments:REM =1 ELSE =0','="comment"','DEF FNparent(n%)=(FNlater+STR$ n%)','DEF FNlogic(n%)=NOT(n%=0) AND TRUE','DEF FNplus=+1','DEF FNquoted="a:ELSE""THEN"']),
 ]
 for main,defs in [
  (['PRINT FNoverflow'],['DEF FNoverflow=1E39']),
  (['PRINT FNbadloop'],['DEF FNbadloop:FOR i%=1 TO 1:=1:NEXT']),
  (['PRINT FNbadend'],['DEF FNbadend:ENDPROC:=1']),
  (['PRINT FNbadlocal'],['DEF FNbadlocal:WHILE 1:LOCAL x%:ENDWHILE:=1']),
  (['PRINT FNbadparam(2147483648)'],['DEF FNbadparam(n%)=n%']),
  (['PRINT FNbadstring'],['DEF FNbadstring=STRING$(128,"ab")']),
  (['PROCwrong'],['DEF PROCwrong:=1']),
  (['=1/0'],[]),
 ]:
  case=m.program(main,defs);case.update(reference_error=True,status=1);result.append(case)
 result += [dict(source='=1\n',expected='Not in a FN\n',status=1)]
 result += [dict(source=s,diagnostic=d) for s,d in [
  ('PRINT FNmissing\n','Undefined FN missing'),
  ('PRINT ;ASC RIGHT$(FNnul)\nEND\nDEF FNnul=CHR$(0)+CHR$(128)+CHR$(255)\n','Omitted RIGHT$ on a FN string result is unqualified'),
  ('PRINT STRING$(2,FNa)\nEND\nDEF FNa="ABC"\n','STRING$ on a FN string result is unqualified'),
  ('PRINT RIGHT$(LEFT$((FNa)))\nEND\nDEF FNa="ABC"\n','Omitted RIGHT$ on a FN string result is unqualified'),
  ('DEF FNbad(n%):IF n%=0 THEN =0 ELSE ="x"\n','Mixed numeric/string FN results are unsupported'),
  ('DEF FNfirst=FNsecond\nDEF FNsecond=FNfirst\n','Unresolved FN result kind'),
  ('DEF FNmissing:REM =1\n','Unresolved FN result kind'),
  ('DEF FNp(RETURN x%)=x%\n','Unsupported formal parameter RETURN'),
  ('DEF FNp()=1\n','Empty formal parameter lists are unsupported'),
  ('PRINT FNp()\nEND\nDEF FNp=1\n','Empty call argument lists are unsupported'),
  ('PRINT FNp("x")\nEND\nDEF FNp(n%)=n%\n','Procedure argument type mismatch'),
  ('PRINT FNp(1)\nEND\nDEF FNp(s$)=s$\n','Procedure argument type mismatch'),
  ('@outside:END\nDEF FNp:GOTO @outside:=1\n','Undefined target $p1@outside'),
 ]]
 return result
if __name__=='__main__':
 smoke='--smoke' in sys.argv
 if smoke:sys.argv.remove('--smoke')
 spec=importlib.util.spec_from_file_location('output',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 compiler=Path(sys.argv[sys.argv.index('--compiler')+1]) if '--compiler' in sys.argv else ROOT/'compiler/compiler.bas'
 lines=compiler.read_text().splitlines();ids=[int(l.split()[0]) for l in lines];assert ids==sorted(set(ids)) and max(len(l.split(' ',1)[1]) for l in lines)<=255
 h.TASK=TASK;h.programs=(lambda:programs()[:1]) if smoke else programs
 sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
