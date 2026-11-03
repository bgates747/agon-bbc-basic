"""Exercise byte-metadata boundaries through actual BBC compilation and execution."""
from pathlib import Path
import importlib.util,sys
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def programs():
 p=module('p',ROOT/'docs/tasks/C004/tools/test_procedures.py');out=[]
 out.append(p.program(['PROCwidth(7):PRINT ;FNwide(3)'],['DEF PROCwidth(x%):LOCAL y%:y%=x%+1:PRINT ;y%:ENDPROC','DEF FNwide(n%)=n%+2']))
 defs=[]
 for i in range(16):
  args=','.join(f'wa{i}x{j}%' for j in range(16));body=f'PRINT ;wa{i}x15%:' if i==15 else ''
  defs.append(f'DEF PROCwp{i}({args}):{body}ENDPROC')
 out.append(p.program(['PROCwp15('+','.join(str(i) for i in range(16))+')'],defs))
 args=','.join(f'w{i}%' for i in range(16));call='FNwargs('+','.join(str(i) for i in range(16))+')'
 outer=','.join(f'wo{i}%' for i in range(16));actual=','.join([*(str(i) for i in range(15)),call])
 out.append(p.program(['PRINT ;1+FNwouter('+actual+')'],['DEF FNwouter('+outer+')=wo0%+wo15%','DEF FNwargs('+args+')=w0%+w15%']))
 out.append(dict(source='\n'.join(f'DEF PROCwo{i}:ENDPROC' for i in range(257))+'\n',diagnostic='Procedure limit exceeds 256'))
 # This256-definition reference footer must be last: the common harness's
 # normal100-line footer stride cannot precede another fixture's definitions.
 out.append(p.program(['PRINT ;FNwf255'],[f'DEF FNwf{i}={i}' for i in range(256)]))
 return out

def main():
 cases=programs()
 if '--consumers' in sys.argv:
  sys.argv.remove('--consumers');cases=[module('p',ROOT/'docs/tasks/C004/tools/test_procedures.py').programs()[1],module('fs',ROOT/'docs/tasks/C004/tools/test_function_strings.py').programs()[0]]
 h=module('h',ROOT/'docs/tasks/C002/tools/test_output.py');h.TASK=TASK;h.programs=lambda:cases
 sys.argv+=['--skip-legacy','--isolate-reference','--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
if __name__=='__main__':main()
