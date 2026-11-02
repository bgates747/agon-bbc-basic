from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';e=t/'evidence/procedures-001';py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
def archive(src,dst):
 dst.mkdir(parents=True,exist_ok=True)
 for f in src.iterdir():
  if f.is_file() and f.suffix in ('.json','.log','.bas','.txt','.dat','.py','.s','.md'):shutil.copy2(f,dst/f.name)
def manifest(e):
 (e/'manifest.json').write_text(json.dumps({str(f.relative_to(e)):hashlib.sha256(f.read_bytes()).hexdigest() for f in e.rglob('*') if f.is_file() and f.name!='manifest.json'},indent=2)+'\n')
(e/'summary.json').write_text(json.dumps(dict(scope='Full scalar PROC/LOCAL prototype and supplemental cases',full=json.loads((e/'transcripts/results.json').read_text()),edges=json.loads((e/'edges/results.json').read_text()),baseline=json.loads((e/'baseline/test-results.json').read_text()),abi=json.loads((e/'abi/results.json').read_text()),all_native_runtime_links=json.loads((e/'transcripts/procedure-links.json').read_text()),human_hardware_validation=False),indent=2)+'\n')
shutil.copy2('/tmp/qualify-proc-edges.py',e/'qualification-driver.py');manifest(e)
shutil.copy2(t/'activations/compiler.bas',r/'compiler/compiler.bas');shutil.copy2(t/'activations/procedures.s',r/'compiler/runtime/procedures.s')
expected=hashlib.sha256((r/'compiler/compiler.bas').read_bytes()).hexdigest();assert expected=='7d6d6abcede0e294c5ea0017cd49fbc59674e51c992b53b42c47d520ba169c96'
for script,args in [('build_numeric_runtime.py',['--update-compiler']),('build_strings_runtime.py',['--compiler','compiler/compiler.bas']),('build_control_runtime.py',['--compiler','compiler/compiler.bas']),('build_procedure_runtime.py',['--compiler','compiler/compiler.bas'])]:
 subprocess.run([str(py),str(r/'compiler/tools'/script),*args],cwd=r,check=True,stdout=subprocess.DEVNULL)
 assert hashlib.sha256((r/'compiler/compiler.bas').read_bytes()).hexdigest()==expected,script
(t/'activations/compiler.bas').unlink();(t/'activations/procedures.s').unlink()
p=t/'evidence/procedures-promotion-001';p.mkdir(parents=True,exist_ok=True)
for f in [r/'compiler/compiler.bas',r/'compiler/runtime/procedures.s',r/'compiler/tools/build_procedure_runtime.py',r/'compiler/tools/build_control_runtime.py']:shutil.copy2(f,p/f.name)
archive(r/'compiler/build/procedure-runtime',p/'runtime');shutil.copy2(r/'compiler/build/procedure-runtime/runtime-0.bin',p/'runtime/runtime-0.dat')
for label,script,args,build in [
 ('baseline','compiler/tools/test_compiler.py',[],r/'compiler/build'),
 ('procedure-smoke','docs/tasks/C004/tools/test_procedures.py',['--smoke'],t/'build/output-integration'),
 ('procedure-abi','docs/tasks/C004/tools/test_procedure_abi.py',['--runtime',str(r/'compiler/build/procedure-runtime')],t/'build/procedure-abi'),
 ('loops-smoke','docs/tasks/C004/tools/test_loops.py',['--smoke'],t/'build/output-integration'),
 ('conditionals-smoke','docs/tasks/C004/tools/test_conditionals.py',['--smoke'],t/'build/output-integration'),
 ('slice-store-smoke','docs/tasks/C003/tools/test_slice_store.py',['--smoke'],r/'docs/tasks/C003/build/output-integration')]:
 res=subprocess.run([str(py),script,'--cli',cli,*args],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(p/f'{label}.log').write_text(res.stdout);archive(build,p/label);print(label+': '+res.stdout,flush=True)
 if res.returncode:raise SystemExit(res.returncode)
 if label=='procedure-smoke':
  subprocess.run([str(py),str(t/'tools/check_procedure_images.py')],cwd=r,check=True,stdout=subprocess.DEVNULL);archive(build,p/label)
shutil.copy2(t/'build/procedure-abi/probe.bin',p/'procedure-abi/probe.dat')
(p/'summary.json').write_text(json.dumps(dict(scope='Selected live scalar PROC/LOCAL rechecks',compiler_sha256=expected,byte_identical_promotion=(e/'compiler.bas').read_bytes()==(r/'compiler/compiler.bas').read_bytes(),all_four_packers_reproduce_source=True,procedure_runtime_bytes=502,procedure_runtime_relocations=27,human_hardware_validation=False),indent=2)+'\n');manifest(p)
