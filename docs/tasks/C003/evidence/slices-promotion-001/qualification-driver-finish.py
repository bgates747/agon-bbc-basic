from pathlib import Path
import subprocess,shutil,hashlib,json
root=Path('/Agon/mystuff/bbc-basic-v-adl');task=root/'docs/tasks/C003';dest=task/'evidence/slices-promotion-001';dest.mkdir(exist_ok=True)
cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
transcripts=['results.json','cases.json','reference.bas','driver.bas','reference.log','compile.log','native.log']
storage=['results.json','reference.bas','driver.bas','reference.log','compile.log','native.log','source.bas','layout.txt','expected.dat','native.dat','compiled.dat']
expressions=transcripts+['oracle.dat']
jobs=[
 ('output','docs/tasks/C002/tools/test_output.py',['--timeout','480'],root/'docs/tasks/C002/build/output-integration',transcripts),
 ('expressions','docs/tasks/C002/tools/test_expressions.py',['--start','0','--count','12'],root/'docs/tasks/C002/build/expressions/promotion/batch-000',expressions),
 ('expressions-targeted','docs/tasks/C002/tools/test_expressions.py',['--start','60','--count','26'],root/'docs/tasks/C002/build/expressions/promotion/batch-060',expressions),
 ('print-dispatch','docs/tasks/C003/tools/test_slices.py',['--print-dispatch','--timeout','240'],task/'build/output-integration',transcripts),
]
for label,tool,args,build,names in jobs:
 out=dest/label;out.mkdir(exist_ok=True)
 p=subprocess.run([str(root/'.venv/bin/python'),tool,'--cli',cli,*args],cwd=root,capture_output=True,text=True)
 (out/'run.log').write_text(p.stdout+p.stderr);print(label,'exit',p.returncode,flush=True)
 if p.returncode:print(p.stdout+p.stderr,flush=True);raise SystemExit(p.returncode)
 for name in names:shutil.copyfile(build/name,out/name.replace('.bin','.dat'))
 print(p.stdout[-250:],flush=True)
