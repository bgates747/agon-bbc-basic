"""Recheck the existing count consumers after separating compiler helper names."""
from pathlib import Path
import importlib.util,sys
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def main():
 base=ROOT/'docs/tasks/C003/tools'
 slices=module('slices',base/'test_slices.py').programs()
 search=module('search',base/'test_search_repeat.py').programs()
 stores=module('stores',base/'test_slice_store.py').programs()
 cases=[slices[0],search[0],stores[8],stores[1],
        next(c for c in slices if c['source']=='PRINT LEFT$("abc",2147483648)\n'),
        next(c for c in search if c['source']=='PRINT STRING$(2147483648,missing$)\n')]
 h=module('h',ROOT/'docs/tasks/C002/tools/test_output.py');h.TASK=TASK;h.programs=lambda:cases
 sys.argv+=['--skip-legacy','--isolate-reference','--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
if __name__=='__main__':main()
