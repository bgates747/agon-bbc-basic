"""Actual BASIC differential function results and saved caller expressions."""
from pathlib import Path
import importlib.util,sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
spec=importlib.util.spec_from_file_location('procs',TASK/'tools/test_procedures.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def programs():
 return [m.program(['PRINT ;FNadd(2,3);":";FNtext("x")','PRINT ;7+FNadd(4,5);":";"a"+FNtext("b")+"c"'],['DEF FNadd(a,b)=a+b','DEF FNtext(s$)=s$+s$'])]
if __name__=='__main__':
 spec=importlib.util.spec_from_file_location('output',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 h.TASK=TASK;h.programs=programs;sys.argv+=['--isolate-reference','--skip-legacy','--string-runtime',str(ROOT/'compiler/build/string-runtime')];h.main()
