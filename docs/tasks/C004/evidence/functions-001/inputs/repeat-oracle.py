"""Reference STRING$ function-result carrier probe."""
from pathlib import Path
import importlib.util
r=Path(__file__).resolve().parents[4];p=Path(__file__).resolve().parent
body=['ON ERROR REPORT:PRINT:PRINT "FN_REPEAT_DONE":OSCLI "BYE"','scratch$="123456":r$=STRING$(2,FNa)','PRINT ;LEN r$;":";ASC MID$(r$,1);":";ASC MID$(r$,2);":";ASC MID$(r$,3);":";ASC MID$(r$,4);":";ASC MID$(r$,5);":";ASC MID$(r$,6)','scratch$="UVWXYZ":r$=STRING$(2,FNa)','PRINT ;ASC MID$(r$,4);":";ASC MID$(r$,5);":";ASC MID$(r$,6)','r$=STRING$(2,FNa+""):PRINT r$','PRINT "FN_REPEAT_DONE":OSCLI "BYE"']
source='\n'.join(f'{10+i*10} {s}' for i,s in enumerate(body))+'\n1000 DEF FNa="ABC"\n'
(p/'repeat-oracle.bas').write_text(source);(r/'.emulator/sdcard/repeat-oracle.bas').write_text(source)
spec=importlib.util.spec_from_file_location('h',r/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
log=h.run_profile(r/'.emulator','load /bin/basic.bin\nrun . /repeat-oracle.bas\n','FN_REPEAT_DONE','repeat-oracle.log');(p/'repeat-oracle.log').write_text(log);print(log)
