"""Isolate reference omitted-count RIGHT$ after a function result."""
from pathlib import Path
import importlib.util
r=Path(__file__).resolve().parents[4];p=Path(__file__).resolve().parent
main=['ON ERROR REPORT:PRINT:PRINT "FN_RIGHT_DONE":OSCLI "BYE"']
for expr in ['FNa','FNb("ABC")','FNc','FNd','FNe','FNa+""','(FNa)','FNempty']:
 main += [f'PRINT "{expr.replace(chr(34),chr(34)*2)}"',f'PRINT ;LEN RIGHT$({expr});":";ASC RIGHT$({expr});":";ASC RIGHT$({expr},1);":";ASC MID$({expr},3)']
main += ['PRINT "FN_RIGHT_DONE":OSCLI "BYE"']
defs=['DEF FNa="ABC"','DEF FNb(s$)=s$','DEF FNc="A"+"BC"','DEF FNd=CHR$(65)+CHR$(66)+CHR$(67)','DEF FNe:LOCAL s$:s$="ABC":=s$','DEF FNempty=""']
source='\n'.join([*[f'{10+i*10} {s}' for i,s in enumerate(main)],*[f'{1000+i*10} {s}' for i,s in enumerate(defs)]])+'\n'
(p/'right-oracle.bas').write_text(source);(r/'.emulator/sdcard/right-oracle.bas').write_text(source)
spec=importlib.util.spec_from_file_location('h',r/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
log=h.run_profile(r/'.emulator','load /bin/basic.bin\nrun . /right-oracle.bas\n','FN_RIGHT_DONE','right-oracle.log');(p/'right-oracle.log').write_text(log);print(log)
