"""Run reference-only conditional association probes; no compiler logic."""
from pathlib import Path
import importlib.util
r=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('harness',r/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
lines=['ON ERROR REPORT:PRINT:OSCLI "BYE"']
for a,b in [(0,0),(0,1),(1,0),(1,1)]:
 lines += [f'PRINT "CASE {a},{b}"',f'IF {a} THEN IF {b} THEN PRINT "inner-yes" ELSE PRINT "inner-no" ELSE PRINT "outer-no"','PRINT "next"']
lines += ['IF .9 THEN PRINT "fraction-true" ELSE PRINT "fraction-false"','IF -.9 THEN PRINT "negative-true" ELSE PRINT "negative-false"', 'IF 0 THEN PRINT "no":PRINT "no" ELSE PRINT "yes":PRINT "yes"','IF 1 THEN PRINT "yes" ELSE PRINT "no" ELSE PRINT "no2"','IF 0 THEN','PRINT "bad"','ELSE PRINT "blockelse"','ENDIF','PRINT "CONDITIONAL_ORACLE_DONE":OSCLI "BYE"']
source='\n'.join(f'{10+i*10} {line}' for i,line in enumerate(lines))+'\n'
p=r/'docs/tasks/C004/conditionals';(p/'oracle.bas').write_text(source);(r/'.emulator/sdcard/conditional-oracle.bas').write_text(source)
log=h.run_profile(r/'.emulator','load /bin/basic.bin\nrun . /conditional-oracle.bas\n','CONDITIONAL_ORACLE_DONE','conditional-oracle.log');(p/'oracle.log').write_text(log);print(log)
