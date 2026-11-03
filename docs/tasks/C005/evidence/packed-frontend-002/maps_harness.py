"""Add BBC-emitted label maps to the retained orchestration harness.
This only observes the actual BBC compiler's completed tables; it never compiles
BASIC or computes source-program addresses on the host.
"""
from pathlib import Path
import sys,types
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def load():
 path=ROOT/'docs/tasks/C002/tools/test_output.py';s=path.read_text()
 def change(a,b):
  nonlocal s
  assert s.count(a)==1,a
  s=s.replace(a,b)
 change("'70 PROCcompile(src$,dst$)', '80 PRINT", "'70 PROCcompile(src$,dst$)', '75 PROCdumpmap(dst$)', '80 PRINT")
 old='source = "\\n".join(driver)+"\\n1000 DEF"+before+'
 address='saddr%(mi%)'
 if '--compiler' in sys.argv:
  candidate=Path(sys.argv[sys.argv.index('--compiler')+1]).read_text()
  if 'DEF FNsymboladdr(i%)' in candidate:address='FNsymboladdr(mi%)'
 definitions=['500 DEF PROCdumpmap(mapname$)','510 LOCAL mh%,mi%','520 mh%=OPENOUT(mapname$+".map")','530 FOR mi%=0 TO snum%-1','540 BPUT#mh%,sname$(mi%)+"="+STR$('+address+')','550 NEXT:CLOSE#mh%:ENDPROC']
 change(old,'source = "\\n".join(driver)+"\\n"+'+repr('\n'.join(definitions)+'\n')+'+"1000 DEF"+before+')
 change('(sd / f"p{i}.bin").write_bytes(sentinel)','(sd / f"p{i}.bin").write_bytes(sentinel)\n        (sd / f"p{i}.bin.map").unlink(missing_ok=True)')
 change('report = dict(programs=len(tests),','report = dict(symbol_maps=True, programs=len(tests),')
 m=types.ModuleType('compact_output_harness');m.__file__=str(path);exec(compile(s,str(path),'exec'),m.__dict__);m.TASK=TASK;return m
