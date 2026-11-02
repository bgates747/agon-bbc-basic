from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';e=t/'evidence/functions-promotion-001';py=r/'.venv/bin/python'
res=subprocess.run([str(py),'docs/tasks/C004/tools/test_function_strings.py','--cli','/tmp/bbc-compiler-cli-target/release/agon-cli-emulator','--timeout','600'],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
(e/'string-consumers.log').write_text(res.stdout);d=e/'string-consumers';d.mkdir(exist_ok=True)
for p in (t/'build/output-integration').iterdir():
 if p.is_file() and p.suffix in ('.json','.log','.bas','.dat'):shutil.copy2(p,d/p.name)
print(res.stdout,flush=True)
if res.returncode:raise SystemExit(res.returncode)
subprocess.run([str(py),str(t/'tools/check_procedure_images.py')],cwd=r,check=True,stdout=subprocess.DEVNULL)
shutil.copy2(t/'build/output-integration/procedure-links.json',d/'procedure-links.json');shutil.copy2(t/'tools/test_function_strings.py',e/'test_function_strings.py')
summary=json.loads((e/'summary.json').read_text());summary['additional_string_consumers']=json.loads((d/'results.json').read_text());(e/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
(e/'manifest.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
