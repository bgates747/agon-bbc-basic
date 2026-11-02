"""Finish an interrupted qualification from retained BBC-compiled outputs."""
from pathlib import Path
import hashlib,importlib.util,json,shutil,subprocess,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C004';BUILD=TASK/'build/output-integration';PROFILE=ROOT/'.emulator';SD=PROFILE/'sdcard'

def main():
 compiler=TASK/'functions/compiler.bas';source=compiler.read_text();tests=json.loads((BUILD/'cases.json').read_text());compiled=(PROFILE/'output-compile.log').read_text()
 # Verify that the retained driver contains this exact compiler's definitions/DATA.
 old=(BUILD/'driver.bas').read_text().split('1000 DEF',1)[1]
 old='\n'.join(line for line in old.splitlines() if not (line.split() and line.split()[0].isdigit() and 10000<=int(line.split()[0])<11000))+'\n'
 assert old==source.split('1000 DEF',1)[1]
 sentinel=b'Existing output survives output-expression errors'
 for i,case in enumerate(tests):
  if 'diagnostic' in case:
   record=compiled.split(f'ERR:p{i}.bas\n',1)[1].split('ERR:',1)[0].split('OK:',1)[0]
   assert case['diagnostic'] in record,(i,record)
   assert (SD/f'p{i}.bin').read_bytes()==sentinel
  else:assert f'OK:p{i}.bas\n' in compiled,(i,compiled)
 e=TASK/'evidence/functions-interrupted-001';e.mkdir(parents=True,exist_ok=True)
 for p in BUILD.iterdir():
  if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat'):shutil.copy2(p,e/p.name)
 shutil.copy2(compiler,e/'compiler.bas');(e/'interrupted-compile.log').write_text(compiled)
 (e/'README.md').write_text('# Interrupted FN qualification\n\nAll25 compilation cases are retained and validated against the exact compiler driver. The controlling session ended before its final repeat/native-output phase. This archive is partial evidence, not a completed test pass. resume_functions.py performs a fresh BBC repeat and all native executions before reporting completion.\n')
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 before,after=source.split('1000 DEF',1)
 repeat='10 PROCinit\n20 ON ERROR REPORT:PRINT:PRINT "FN_RESUME_FAILED":OSCLI "BYE"\n30 PROCcompile("p0.bas","fn-repeat.bin")\n40 PRINT "FN_RESUME_REPEAT_DONE":OSCLI "BYE"\n1000 DEF'+after
 (BUILD/'resume-driver.bas').write_text(repeat);(SD/'fn-resume.bas').write_text(repeat);(SD/'fn-repeat.bin').unlink(missing_ok=True)
 start=time.monotonic();log=h.run_profile(PROFILE,'load /bin/basic.bin\nrun . /fn-resume.bas\n','FN_RESUME_REPEAT_DONE','fn-resume-repeat.log',timeout_seconds=300)
 (BUILD/'resume-repeat.log').write_text(log);assert (SD/'fn-repeat.bin').read_bytes()==(SD/'p0.bin').read_bytes()
 commands=[]
 for i,case in enumerate(tests):
  if 'diagnostic' not in case:commands += [f'echo OUTPUT_BEGIN_{i}',f'try /p{i}.bin','echo OUTPUT_STATUS:<Try$ReturnCode>',f'echo OUTPUT_END_{i}']
 commands+=['echo OUTPUT_NATIVE_DONE']
 native=h.run_profile(PROFILE,'\n'.join(commands)+'\n','OUTPUT_NATIVE_DONE','fn-resume-native.log',timeout_seconds=120);(BUILD/'native.log').write_text(native)
 for i,case in enumerate(tests):
  if 'diagnostic' not in case:
   actual=native.split(f'OUTPUT_BEGIN_{i}\n',1)[1].split(f'OUTPUT_END_{i}\n',1)[0]
   assert actual==case['expected']+f'OUTPUT_STATUS:{case["status"]}\n',(i,actual,case)
 subprocess.run([str(ROOT/'.venv/bin/python'),str(TASK/'tools/check_procedure_images.py'),'--procedure-runtime',str(TASK/'build/function-runtime')],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
 report=dict(programs=len(tests),native_executions=sum('diagnostic' not in c for c in tests),rejected_sources=sum('diagnostic' in c for c in tests),reference_output_programs=sum(c.get('reference',False) for c in tests),deterministic_repeat=True,compiler_driver_byte_match=True,all_native_outputs_match=True,resumed_after_interruption=True,resume_duration_seconds=round(time.monotonic()-start,3),compiler_sha256=hashlib.sha256(compiler.read_bytes()).hexdigest(),interrupted_compile_duration_not_reported=True,human_hardware_validation=False)
 (BUILD/'results.json').write_text(json.dumps(report,indent=2)+'\n')
 (e/'manifest.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='manifest.json'},indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
