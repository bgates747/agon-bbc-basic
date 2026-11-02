from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C005';e=t/'evidence/capacity-copy-001';e.mkdir(parents=True,exist_ok=True);py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
def archive(src,dst):
 dst.mkdir(parents=True,exist_ok=True)
 for p in src.iterdir():
  if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat','.s','.py'):shutil.copy2(p,dst/p.name)
shutil.copy2(t/'compiler.bas',e/'compiler.bas');shutil.copy2(t/'copy/strings.s',e/'strings.s');shutil.copy2(t/'copy/abi.s',e/'abi.s');shutil.copy2(t/'build_strings_runtime.py',e/'build_strings_runtime.py')
for label,script,args,build in [
 ('abi','docs/tasks/C005/test_copy_abi.py',[],t/'build/copy-abi'),
 ('functions-smoke','docs/tasks/C004/tools/test_functions.py',['--compiler',str(t/'compiler.bas'),'--smoke','--string-runtime',str(t/'build/string-runtime')],r/'docs/tasks/C004/build/output-integration'),
 ('function-strings','docs/tasks/C004/tools/test_function_strings.py',['--compiler',str(t/'compiler.bas'),'--string-runtime',str(t/'build/string-runtime'),'--timeout','600'],r/'docs/tasks/C004/build/output-integration'),
 ('baseline','compiler/tools/test_compiler.py',['--compiler',str(t/'compiler.bas')],r/'compiler/build')]:
 res=subprocess.run([str(py),script,'--cli',cli,*args],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(e/f'{label}.log').write_text(res.stdout);archive(build,e/label);print(label+': '+res.stdout,flush=True)
 if res.returncode:raise SystemExit(res.returncode)
 if label=='abi':shutil.copy2(build/'probe.bin',e/'abi/probe.dat')
archive(t/'build/string-runtime',e/'runtime');shutil.copy2(t/'build/string-runtime/runtime-0.bin',e/'runtime/runtime-0.dat')
(e/'manifest.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
