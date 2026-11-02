"""Supplemental staging, ownership and bounded activation cases."""
from pathlib import Path
import importlib.util,sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
spec=importlib.util.spec_from_file_location('procedures',TASK/'tools/test_procedures.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def programs():
 result=[m.program(['PROCcreated(newformal%):PRINT ;newformal%'],['DEF PROCcreated(newformal%):PRINT ;newformal%:ENDPROC']),
 m.program(['a$="A":b$="B":PROCexchange(a$,b$):PRINT a$;":";b$;":";saved$'],['DEF PROCexchange(b$,a$):LOCAL scratch$:scratch$=a$+b$:saved$=scratch$:PRINT scratch$:ENDPROC']),
 m.program(['s$="old":PROCappend(s$+"new"):PRINT s$'],['DEF PROCappend(s$):PRINT s$:ENDPROC'])]
 case=m.program(['PROCstageerror(2147483648,STRING$(128,"ab"))'],['DEF PROCstageerror(n%,s$):ENDPROC']);case.update(reference_error=True,status=1);result.append(case)
 result.append(dict(source='PROCexhaust:END\nDEF PROCexhaust:LOCAL s$:s$=STRING$(255,"x"):PROCexhaust:ENDPROC\n',expected='No room\n',status=1))
 result += [dict(source=s,diagnostic=d) for s,d in [
 ('\n'.join(f'DEF PROCp{i}' for i in range(129))+'\n','Procedure limit exceeds 128'),
 ('DEF PROCp('+','.join(f'a{i}%' for i in range(17))+')\n','Procedure argument limit exceeds 16'),
 ('PROCp()\nEND\nDEF PROCp:ENDPROC\n','Empty call argument lists are unsupported')]]
 return result
if __name__=='__main__':
 spec=importlib.util.spec_from_file_location('output',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 h.TASK=TASK;h.programs=programs;sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
