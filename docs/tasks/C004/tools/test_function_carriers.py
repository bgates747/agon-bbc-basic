"""Qualified string carriers and explicit rejections of reference-state paths."""
from pathlib import Path
import importlib.util,sys
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
spec=importlib.util.spec_from_file_location('p',TASK/'tools/test_procedures.py');p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
def programs():
 result=[p.program(['s$=FNa:PRINT RIGHT$(s$);":";RIGHT$(FNa,1);":";RIGHT$(FNa+"");":";RIGHT$(LEFT$(FNa,2))','PRINT STRING$(2,FNa+"")'],['DEF FNa="ABC"'])]
 result += [dict(source=s,diagnostic=d) for s,d in [
 ('PRINT RIGHT$(FNa)\nEND\nDEF FNa="ABC"\n','Omitted RIGHT$ on a FN string result is unqualified'),
 ('PRINT STRING$(2,FNa)\nEND\nDEF FNa="ABC"\n','STRING$ on a FN string result is unqualified'),
 ('PRINT RIGHT$(LEFT$((FNa)))\nEND\nDEF FNa="ABC"\n','Omitted RIGHT$ on a FN string result is unqualified')]]
 return result
if __name__=='__main__':
 spec=importlib.util.spec_from_file_location('o',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 h.TASK=TASK;h.programs=programs;sys.argv+=['--isolate-reference','--skip-legacy','--string-runtime',str(ROOT/'compiler/build/string-runtime')];h.main()
