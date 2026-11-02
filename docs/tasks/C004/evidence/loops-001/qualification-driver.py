from pathlib import Path
import subprocess,shutil
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';e=t/'evidence/loops-001';py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
for label,script,build in [('baseline','compiler/tools/test_compiler.py',r/'compiler/build'),('edges','docs/tasks/C004/tools/test_loop_edges.py',t/'build/output-integration')]:
 result=subprocess.run([str(py),script,'--cli',cli,'--compiler',str(t/'loops/compiler.bas')],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(e/f'{label}.log').write_text(result.stdout);(e/label).mkdir(exist_ok=True)
 for p in build.iterdir():
  if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat'):shutil.copy2(p,e/label/p.name)
 print(label+': '+result.stdout,flush=True)
 if result.returncode:raise SystemExit(result.returncode)
shutil.copy2(t/'tools/test_loop_edges.py',e/'test_loop_edges.py')
