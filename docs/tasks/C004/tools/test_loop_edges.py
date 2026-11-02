"""Supplementary evaluated-once, step and recursive loop probes."""
from pathlib import Path
import importlib.util,sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
def programs():
 result=[dict(source=s,reference=True,status=0) for s in [
  'n%=0:FOR i%=1 TO 2 STEP 0:n%=n%+1:PRINT ;i%:IF n%=3 THEN i%=3\nNEXT:PRINT ;i%;":";n%\n',
  'n%=0:FOR i%=0 TO 1 STEP .5:n%=n%+1:PRINT ;i%:IF n%=3 THEN i%=2\nNEXT:PRINT ;i%;":";n%\n',
  'FOR x=2147483647 TO 2147483647:PRINT ;x:NEXT:PRINT ;x\nFOR b&=256 TO 0:PRINT ;b&:NEXT:PRINT ;b&\n',
  'i%=0:WHILE -.9:PRINT "bad":ENDWHILE:REPEAT:i%=i%+1:UNTIL i%/2:PRINT ;i%\n',
 ]]
 result += [dict(source='FOR i%=&7FFFFFFF TO &7FFFFFFF:PRINT ;i%:NEXT\n',reference=True,reference_error=True,status=1)]
 result += [dict(source='n%=0:GOSUB @sub:PRINT "done":END\n@sub:n%=n%+1:FOR i%=1 TO 2:PRINT ;n%;":";i%:IF n%<2 THEN GOSUB @sub\nNEXT:n%=n%-1:RETURN\n',expected='1:1\n2:1\n2:2\ndone\n',status=0)]
 return result
if __name__=='__main__':
 spec=importlib.util.spec_from_file_location('output',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 h.TASK=TASK;h.programs=programs;sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
 spec=importlib.util.spec_from_file_location('loopchecks',TASK/'tools/test_loops.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);m.check_control_images()
