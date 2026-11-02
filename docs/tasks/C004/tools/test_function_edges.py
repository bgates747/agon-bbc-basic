"""Namespace, simultaneous prefixes, float recursion and capacity probes."""
from pathlib import Path
import importlib.util,sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
spec=importlib.util.spec_from_file_location('p',TASK/'tools/test_procedures.py');p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
def programs():
 result=[p.program(['PROCshared(4):PRINT ;FNshared(5);":";n%'],['DEF PROCshared(n%):PRINT ;n%:ENDPROC','DEF FNshared(n%)=n%+1']),
 p.program(['PRINT FNpack(7,8,FNjoin("a",FNdecorate("b")))','PRINT FNjoin(FNdecorate("c"),FNdecorate("d"))'],['DEF FNpack(a%,b%,s$)=STR$ a%+":"+STR$ b%+":"+s$','DEF FNjoin(a$,b$)=a$+b$','DEF FNdecorate(s$)=STR$ LEN(s$)+s$']),
 p.program(['PRINT ;FNfactorial(15);":";FNexact(1/3)=1/3','PRINT ;FNmaximum=STRING$(255,"q")'],['DEF FNfactorial(n%):IF n%=0 THEN =1 ELSE =n%*FNfactorial(n%-1)','DEF FNexact(x)=x','DEF FNmaximum=STRING$(255,"q")']),
 p.program(['s$=FNcarrier:PRINT RIGHT$(s$);":";RIGHT$(FNcarrier+"");":";RIGHT$(LEFT$(FNcarrier,2));":";RIGHT$(MID$(FNcarrier,1))','PRINT STRING$(2,FNcarrier+"");":";STRING$(2,LEFT$(FNcarrier,3))'],['DEF FNcarrier="ABC"']),
 dict(source='PRINT FNlimit(0):END\nDEF FNlimit(n%):IF n%<0 THEN =0 ELSE =FNlimit(n%+1)\n',expected='No room\n',status=1)]
 return result
if __name__=='__main__':
 spec=importlib.util.spec_from_file_location('o',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 h.TASK=TASK;h.programs=programs;sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
