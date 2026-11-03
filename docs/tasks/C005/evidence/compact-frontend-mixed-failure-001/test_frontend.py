"""Actual BBC oracles and native execution for compact emitter integration."""
from pathlib import Path
import importlib.util,sys
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def programs():
 p=module('p',ROOT/'docs/tasks/C004/tools/test_procedures.py');tables=module('tab',TASK/'compact/test_tables.py');out=[]
 out.append(dict(source='a%=7:b&=257:c=2.75\nPRINT ;a%;":";b&;":";c;":";(a%+b&)*(c-1)\na%=c:b&=-1:c=a%+0.5:PRINT ;a%;":";b&;":";c\n',reference=True,status=0))
 out.append(dict(source='DIM a%(1,1),b&(1),f(1),s$(1)\na%(1,1)=-123:b&(1)=257:f(1)=2.75:s$(1)="array"\nPRINT ;a%(1,1);":";b&(1);":";f(1);":";s$(1)\n',reference=True,status=0))
 out.append(p.programs()[1]);out.append(tables.programs()[2])
 out.append(dict(source='a$="string only":PRINT a$\n',reference=True,status=0))
 out += [dict(source=s,reference=True,reference_error=True,status=1) for s in ['PRINT ;1/0\n','PRINT ;missing%\n','a%=2147483648\n','DIM a%(0):PRINT ;a%(1)\n']]
 return out

def main():
 h=module('maps',TASK/'compact/maps_harness.py').load();cases=programs()
 if '--smoke' in sys.argv:sys.argv.remove('--smoke');cases=cases[:2]
 h.programs=lambda:cases;sys.argv+=['--skip-legacy','--isolate-reference','--string-runtime',str(ROOT/'compiler/build/string-runtime')];h.main();module('links',TASK/'compact/check_images.py').check(TASK/'build/output-integration')
if __name__=='__main__':main()
