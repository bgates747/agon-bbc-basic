"""Reference function suffix/type probe; fixture preparation only."""
from pathlib import Path
import importlib.util
r=Path(__file__).resolve().parents[4];p=Path(__file__).resolve().parent
source='10 ON ERROR REPORT:PRINT:PRINT "FN_SUFFIX_DONE":OSCLI "BYE"\n20 PRINT ;FNnumber$;":";FNtext\n30 PRINT "FN_SUFFIX_DONE":OSCLI "BYE"\n1000 DEF FNnumber$=3\n1010 DEF FNtext="text"\n'
(p/'suffix-oracle.bas').write_text(source);(r/'.emulator/sdcard/suffix-oracle.bas').write_text(source)
spec=importlib.util.spec_from_file_location('h',r/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
log=h.run_profile(r/'.emulator','load /bin/basic.bin\nrun . /suffix-oracle.bas\n','FN_SUFFIX_DONE','suffix-oracle.log');(p/'suffix-oracle.log').write_text(log);print(log)
