from pathlib import Path
import subprocess,shutil,json,hashlib
r=Path('/Agon/mystuff/bbc-basic-v-adl');t=r/'docs/tasks/C004';e=t/'evidence/functions-001';py=r/'.venv/bin/python';cli='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
def archive(src,dst):
 dst.mkdir(parents=True,exist_ok=True)
 for f in src.iterdir():
  if f.is_file() and f.suffix in ('.json','.log','.bas','.txt','.dat','.py','.s','.md'):shutil.copy2(f,dst/f.name)
def manifest(e):
 (e/'manifest.json').write_text(json.dumps({str(f.relative_to(e)):hashlib.sha256(f.read_bytes()).hexdigest() for f in e.rglob('*') if f.is_file() and f.name!='manifest.json'},indent=2)+'\n')
(e/'summary.json').write_text(json.dumps(dict(scope='Revised full FN prototype with explicit carrier exclusions',full=json.loads((e/'transcripts/results.json').read_text()),edges=json.loads((e/'edges/results.json').read_text()),abi=json.loads((e/'abi/results.json').read_text()),procedure_abi=json.loads((e/'procedure-abi/results.json').read_text()),baseline=json.loads((e/'baseline/test-results.json').read_text()),earlier_attempt_failed_on_reference_carrier_mismatch=True,human_hardware_validation=False),indent=2)+'\n')
(e/'resume_functions.py').unlink(missing_ok=True);shutil.copy2('/tmp/qualify-function-edges.py',e/'qualification-driver.py');manifest(e)
partial=t/'evidence/functions-interrupted-001';shutil.copy2(t/'tools/resume_functions.py',partial/'resume_functions.py')
with (partial/'README.md').open('a') as f:f.write('\nThe resumed native phase found a reference carrier mismatch; see ../functions-reference-diff-001. This is failed/partial historical evidence. The tool snapshot retains its original tools-directory path assumptions. Revised functions-001 owns the passing scope.\n')
for name in ['functions-interrupted-001','functions-reference-diff-001','fn-proc-abi-report-debug-001']:manifest(t/'evidence'/name)
shutil.copy2(t/'functions/compiler.bas',r/'compiler/compiler.bas');shutil.copy2(t/'functions/procedures.s',r/'compiler/runtime/procedures.s')
expected=hashlib.sha256((r/'compiler/compiler.bas').read_bytes()).hexdigest();assert expected=='6feb0b21b09ac4353347876df89043caf8800727b5a8c4f985588c3e6741c8f4'
for script,args in [('build_numeric_runtime.py',['--update-compiler']),('build_strings_runtime.py',['--compiler','compiler/compiler.bas']),('build_control_runtime.py',['--compiler','compiler/compiler.bas']),('build_procedure_runtime.py',['--compiler','compiler/compiler.bas'])]:
 subprocess.run([str(py),str(r/'compiler/tools'/script),*args],cwd=r,check=True,stdout=subprocess.DEVNULL)
 assert hashlib.sha256((r/'compiler/compiler.bas').read_bytes()).hexdigest()==expected,script
(t/'functions/compiler.bas').unlink();(t/'functions/procedures.s').unlink();(t/'tools/build_functions_runtime.py').unlink();(t/'tools/resume_functions.py').unlink()
p=t/'evidence/functions-promotion-001';p.mkdir(parents=True,exist_ok=True)
for f in [r/'compiler/compiler.bas',r/'compiler/runtime/procedures.s',r/'compiler/tools/build_procedure_runtime.py']:shutil.copy2(f,p/f.name)
archive(r/'compiler/build/procedure-runtime',p/'runtime');shutil.copy2(r/'compiler/build/procedure-runtime/runtime-0.bin',p/'runtime/runtime-0.dat')
for label,script,args,build in [
 ('baseline','compiler/tools/test_compiler.py',[],r/'compiler/build'),
 ('functions-smoke','docs/tasks/C004/tools/test_functions.py',['--smoke'],t/'build/output-integration'),
 ('carriers','docs/tasks/C004/tools/test_function_carriers.py',[],t/'build/output-integration'),
 ('function-abi','docs/tasks/C004/tools/test_functions_abi.py',[],t/'build/function-abi'),
 ('procedure-smoke','docs/tasks/C004/tools/test_procedures.py',['--smoke'],t/'build/output-integration'),
 ('loops-smoke','docs/tasks/C004/tools/test_loops.py',['--smoke'],t/'build/output-integration')]:
 res=subprocess.run([str(py),script,'--cli',cli,*args],cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(p/f'{label}.log').write_text(res.stdout);archive(build,p/label);print(label+': '+res.stdout,flush=True)
 if res.returncode:raise SystemExit(res.returncode)
 if label in ['functions-smoke','procedure-smoke']:
  subprocess.run([str(py),str(t/'tools/check_procedure_images.py')],cwd=r,check=True,stdout=subprocess.DEVNULL);archive(build,p/label)
 if label=='function-abi':shutil.copy2(build/'probe.bin',p/label/'probe.dat')
(p/'summary.json').write_text(json.dumps(dict(scope='Selected live FN rechecks',compiler_sha256=expected,byte_identical_promotion=(e/'compiler.bas').read_bytes()==(r/'compiler/compiler.bas').read_bytes(),all_four_packers_reproduce_source=True,activation_runtime_bytes=783,activation_relocations=58,human_hardware_validation=False),indent=2)+'\n');manifest(p)
