"""Admitted string consumers and FN side effects during slice assignment."""
from pathlib import Path
import importlib.util,sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
spec=importlib.util.spec_from_file_location('p',TASK/'tools/test_procedures.py');p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
def programs():
 result=[p.program([
  'PRINT LEFT$(FNletters);":";LEFT$(FNletters,2);":";RIGHT$(FNletters,2)',
  'PRINT MID$(FNletters,2);":";MID$(FNletters,0);":";MID$(FNletters,2,3)',
  'PRINT ;LEN FNletters;":";ASC FNletters;":";VAL FNdigits;":";INSTR(FNletters,FNneedle)',
  'PRINT ;INSTR(FNletters,FNneedle,FNcount);":";(FNletters="ABCDEF");":";("ABCDEF"=FNletters)',
  'PRINT ;ASC LEFT$(FNbytes);":";ASC MID$(FNbytes,0,1);":";ASC RIGHT$(FNbytes,1)',
  'PRINT "["+LEFT$(FNletters)+"]";":";STRING$(2,STR$ FNnumber)',
 ],['DEF FNletters="ABCDEF"','DEF FNneedle="CD"','DEF FNdigits="12.5"','DEF FNcount:scratch$="changed":=2','DEF FNbytes=CHR$(0)+CHR$(128)+CHR$(255)','DEF FNnumber=3']),
 p.program([
  's$="abcdef":MID$(s$,2,3)=FNchange:PRINT s$',
  's$="abcdef":MID$(s$,FNstart,2)="XY":PRINT s$',
  's$="abcdef":guard$="guard":MID$(s$,2,2)=FNreallocate:PRINT s$;":";guard$',
 ],['DEF FNchange:s$="1234":="XY"','DEF FNstart:s$="12":=2','DEF FNreallocate:s$=STRING$(12,"q"):="YZ"'])]
 case=p.program(['MID$(missing$,1)=FNcreate'],['DEF FNcreate:missing$="new":PRINT "called":="x"']);case.update(reference_error=True,status=1);result.append(case)
 return result
if __name__=='__main__':
 spec=importlib.util.spec_from_file_location('o',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 h.TASK=TASK;h.programs=programs;sys.argv+=['--isolate-reference','--skip-legacy','--string-runtime',str(ROOT/'compiler/build/string-runtime')];h.main()
