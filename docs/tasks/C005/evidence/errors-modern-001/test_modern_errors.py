"""Documented ERL0 for unnumbered source; deliberately outside numbered reference syntax."""
from pathlib import Path
import importlib.util,sys
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def programs():
 return [dict(source='ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:END\nGOTO @fail\nPRINT "WRONG"\n@fail:ERROR 100,"modern"\n',expected='100:0\nmodern\n',status=0,reference=False),
         dict(source='ERROR 100,"modern-untrapped"\n',expected='\nmodern-untrapped\n',status=1,reference=False)]
def main():
 sp=importlib.util.spec_from_file_location('h',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);h.TASK=TASK;h.programs=programs;sys.argv+=['--skip-legacy','--string-runtime',str(ROOT/'compiler/build/string-runtime')];h.main()
if __name__=='__main__':main()
