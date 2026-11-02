from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';e=t/'evidence/procedures-001';e.mkdir(parents=True,exist_ok=True);py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
def archive(src,dst):
 dst.mkdir(parents=True,exist_ok=True)
 for p in src.iterdir():
  if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat','.s','.py','.md'):shutil.copy2(p,dst/p.name)
archive(t/'build/output-integration',e/'transcripts');archive(t/'build/procedure-runtime',e/'runtime');archive(t/'build/procedure-abi',e/'abi')
shutil.copy2(t/'build/procedure-runtime/runtime-0.bin',e/'runtime/runtime-0.dat');shutil.copy2(t/'build/procedure-abi/probe.bin',e/'abi/probe.dat')
for name in ['compiler.bas','procedures.s','abi.s','PROCEDURES.md','AUDIT.md']:shutil.copy2(t/'activations'/name,e/name)
for name in ['test_procedures.py','test_procedure_abi.py','test_procedure_edges.py','check_procedure_images.py','build_procedure_runtime.py']:shutil.copy2(t/'tools'/name,e/name)
for name,script,args,build in [
 ('edges','docs/tasks/C004/tools/test_procedure_edges.py',['--timeout','900'],t/'build/output-integration'),
 ('baseline','compiler/tools/test_compiler.py',[],r/'compiler/build')]:
 res=subprocess.run([str(py),script,'--cli',cli,'--compiler',str(t/'activations/compiler.bas'),*args],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(e/f'{name}.log').write_text(res.stdout);archive(build,e/name);print(name+': '+res.stdout,flush=True)
 if res.returncode:raise SystemExit(res.returncode)
 if name=='edges':
  subprocess.run([str(py),str(t/'tools/check_procedure_images.py')],cwd=r,check=True,stdout=subprocess.DEVNULL);archive(build,e/name)
(e/'manifest.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
