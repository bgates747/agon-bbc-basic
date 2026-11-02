from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';e=t/'evidence/functions-001';e.mkdir(parents=True,exist_ok=True);py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
def archive(src,dst):
 dst.mkdir(parents=True,exist_ok=True)
 for p in src.iterdir():
  if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat','.s','.py','.md'):shutil.copy2(p,dst/p.name)
subprocess.run([str(py),str(t/'tools/check_procedure_images.py'),'--procedure-runtime',str(t/'build/function-runtime')],cwd=r,check=True,stdout=subprocess.DEVNULL)
archive(t/'build/output-integration',e/'transcripts');archive(t/'build/function-runtime',e/'runtime');archive(t/'functions',e/'inputs')
shutil.copy2(t/'functions/compiler.bas',e/'compiler.bas');shutil.copy2(t/'functions/procedures.s',e/'procedures.s');shutil.copy2(t/'build/function-runtime/runtime-0.bin',e/'runtime/runtime-0.dat')
for name in ['test_functions.py','test_function_edges.py','test_functions_abi.py','build_functions_runtime.py','check_procedure_images.py','resume_functions.py']:shutil.copy2(t/'tools'/name,e/name)
for label,script,args,build in [
 ('edges','docs/tasks/C004/tools/test_function_edges.py',['--compiler',str(t/'functions/compiler.bas'),'--timeout','900'],t/'build/output-integration'),
 ('abi','docs/tasks/C004/tools/test_functions_abi.py',[],t/'build/function-abi'),
 ('procedure-abi','docs/tasks/C004/tools/test_procedure_abi.py',['--runtime',str(t/'build/function-runtime')],t/'build/procedure-abi'),
 ('baseline','compiler/tools/test_compiler.py',['--compiler',str(t/'functions/compiler.bas')],r/'compiler/build')]:
 res=subprocess.run([str(py),script,'--cli',cli,*args],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(e/f'{label}.log').write_text(res.stdout);archive(build,e/label);print(label+': '+res.stdout,flush=True)
 if res.returncode:raise SystemExit(res.returncode)
 if label=='edges':
  subprocess.run([str(py),str(t/'tools/check_procedure_images.py'),'--procedure-runtime',str(t/'build/function-runtime')],cwd=r,check=True,stdout=subprocess.DEVNULL);archive(build,e/label)
 if label in ['abi','procedure-abi']:shutil.copy2(build/'probe.bin',e/label/'probe.dat')
(e/'manifest.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
