from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
def archive(src,dst):
 dst.mkdir(parents=True,exist_ok=True)
 for p in src.iterdir():
  if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat'):shutil.copy2(p,dst/p.name)
def manifest(e):
 (e/'manifest.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
def run(e,label,script,args,build):
 res=subprocess.run([str(py),str(r/script),'--cli',cli,*args],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(e/f'{label}.log').write_text(res.stdout);archive(build,e/label)
 print(label+': '+res.stdout,flush=True)
 if res.returncode:raise SystemExit(res.returncode)
e=t/'evidence/conditionals-001';e.mkdir(parents=True,exist_ok=True);archive(t/'build/output-integration',e/'transcripts')
for p in (t/'conditionals').iterdir():
 if p.is_file():shutil.copy2(p,e/p.name)
shutil.copy2(t/'tools/test_conditionals.py',e/'test_conditionals.py')
run(e,'baseline','compiler/tools/test_compiler.py',['--compiler',str(t/'conditionals/compiler.bas')],r/'compiler/build')
manifest(e)
shutil.copy2(t/'conditionals/compiler.bas',r/'compiler/compiler.bas');(t/'conditionals/compiler.bas').unlink()
p=t/'evidence/conditionals-promotion-001';p.mkdir(parents=True,exist_ok=True);shutil.copy2(r/'compiler/compiler.bas',p/'compiler.bas')
run(p,'baseline','compiler/tools/test_compiler.py',[],r/'compiler/build')
run(p,'conditionals-smoke','docs/tasks/C004/tools/test_conditionals.py',['--smoke'],t/'build/output-integration')
run(p,'slice-store-smoke','docs/tasks/C003/tools/test_slice_store.py',['--smoke'],r/'docs/tasks/C003/build/output-integration')
(p/'summary.json').write_text(json.dumps(dict(byte_identical_promotion=(e/'compiler.bas').read_bytes()==(r/'compiler/compiler.bas').read_bytes(),full_prototype_programs=26,full_prototype_native=17,full_prototype_rejected=9,selected_live=True,human_hardware_validation=False),indent=2)+'\n')
manifest(p)
