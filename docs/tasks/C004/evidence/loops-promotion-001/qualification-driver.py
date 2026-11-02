from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';e=t/'evidence/loops-001';py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
def archive(src,dst):
 dst.mkdir(parents=True,exist_ok=True)
 for f in src.iterdir():
  if f.is_file() and f.suffix in ('.json','.log','.bas','.txt','.dat','.py','.s','.md'):shutil.copy2(f,dst/f.name)
def manifest(folder):
 (folder/'manifest.json').write_text(json.dumps({str(f.relative_to(folder)):hashlib.sha256(f.read_bytes()).hexdigest() for f in folder.rglob('*') if f.is_file() and f.name!='manifest.json'},indent=2)+'\n')
archive(t/'loops',e/'reference-probes')
(e/'summary.json').write_text(json.dumps(dict(scope='Full loop prototype plus supplemental cases',full=json.loads((e/'transcripts/results.json').read_text()),edges=json.loads((e/'edges/results.json').read_text()),baseline=json.loads((e/'baseline/test-results.json').read_text()),abi=json.loads((e/'abi/results.json').read_text()),reference_numbered_marker_probes=6,human_hardware_validation=False),indent=2)+'\n')
shutil.copy2('/tmp/qualify-loop-edges.py',e/'qualification-driver.py');manifest(e)
shutil.copy2(t/'loops/compiler.bas',r/'compiler/compiler.bas');shutil.copy2(t/'loops/control.s',r/'compiler/runtime/control.s')
expected=hashlib.sha256((r/'compiler/compiler.bas').read_bytes()).hexdigest();assert expected=='2890c6be59a6b9015c69809ad9cb47efedfabacb543d025da3745718dee5b370'
for script,args in [('build_numeric_runtime.py',['--update-compiler']),('build_strings_runtime.py',['--compiler','compiler/compiler.bas']),('build_control_runtime.py',['--compiler','compiler/compiler.bas'])]:
 subprocess.run([str(py),str(r/'compiler/tools'/script),*args],cwd=r,check=True,stdout=subprocess.DEVNULL)
 assert hashlib.sha256((r/'compiler/compiler.bas').read_bytes()).hexdigest()==expected,script
(t/'loops/compiler.bas').unlink();(t/'loops/control.s').unlink()
p=t/'evidence/loops-promotion-001';p.mkdir(parents=True,exist_ok=True)
for f in [r/'compiler/compiler.bas',r/'compiler/runtime/control.s',r/'compiler/tools/build_control_runtime.py',r/'compiler/tools/build_strings_runtime.py']:shutil.copy2(f,p/f.name)
archive(r/'compiler/build/control-runtime',p/'runtime');shutil.copy2(r/'compiler/build/control-runtime/runtime-0.bin',p/'runtime/runtime-0.dat')
for label,script,args,build in [
 ('baseline','compiler/tools/test_compiler.py',[],r/'compiler/build'),
 ('loops-smoke','docs/tasks/C004/tools/test_loops.py',['--smoke'],t/'build/output-integration'),
 ('control-abi','docs/tasks/C004/tools/test_control_abi.py',['--runtime',str(r/'compiler/build/control-runtime')],t/'build/control-abi'),
 ('conditionals-smoke','docs/tasks/C004/tools/test_conditionals.py',['--smoke'],t/'build/output-integration'),
 ('slice-store-smoke','docs/tasks/C003/tools/test_slice_store.py',['--smoke'],r/'docs/tasks/C003/build/output-integration')]:
 res=subprocess.run([str(py),script,'--cli',cli,*args],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(p/f'{label}.log').write_text(res.stdout);archive(build,p/label)
 print(label+': '+res.stdout,flush=True)
 if res.returncode:raise SystemExit(res.returncode)
shutil.copy2(t/'build/control-abi/probe.bin',p/'control-abi/probe.dat')
(p/'summary.json').write_text(json.dumps(dict(scope='Selected live checks of exact loop promotion',compiler_sha256=expected,byte_identical_promotion=(e/'compiler.bas').read_bytes()==(r/'compiler/compiler.bas').read_bytes(),all_three_data_packers_reproduce_source=True,control_runtime_bytes=8657,control_relocations=30,human_hardware_validation=False),indent=2)+'\n');manifest(p)
