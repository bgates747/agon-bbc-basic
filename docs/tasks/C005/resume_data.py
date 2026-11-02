"""Finish an interrupted DATA batch from verified BBC-compiled outputs."""
from pathlib import Path
import hashlib,importlib.util,json,shutil,subprocess,time,sys
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005';B=TASK/'build/output-integration';P=ROOT/'.emulator';SD=P/'sdcard'
def main():
 source=TASK/'compiler.bas';text=source.read_text();digest=hashlib.sha256(source.read_bytes()).hexdigest();assert digest=='55643c54bbbff7c0d36f139cad2e9824cec5e36a7078e9f7274b30ebf2d7b8fa'
 tests=json.loads((B/'cases.json').read_text());compiled=(P/'output-compile.log').read_text()
 body=(B/'driver.bas').read_text().split('1000 DEF',1)[1];body='\n'.join(x for x in body.splitlines() if not (x.split() and x.split()[0].isdigit() and 10000<=int(x.split()[0])<11000))+'\n';assert body==text.split('1000 DEF',1)[1]
 sentinel=b'Existing output survives output-expression errors'
 for i,c in enumerate(tests):
  assert (SD/f'p{i}.bas').read_text()==c['source']
  if 'diagnostic' in c:
   record=compiled.split(f'ERR:p{i}.bas\n',1)[1].split('ERR:',1)[0].split('OK:',1)[0];assert c['diagnostic'] in record,(i,record);assert (SD/f'p{i}.bin').read_bytes()==sentinel
  else:assert f'OK:p{i}.bas\n' in compiled,(i,compiled)
 d=TASK/'evidence/data-interrupted-001'
 if d.exists():
  manifest=json.loads((d/'manifest.json').read_text())
  for name,expected in manifest.items():assert hashlib.sha256((d/name).read_bytes()).hexdigest()==expected
  assert (d/'compiler.bas').read_text()==text
 else:
  d.mkdir(parents=True)
 if not (d/'manifest.json').exists():
  for name in ['cases.json','driver.bas','reference.bas','reference.log']:shutil.copy2(B/name,d/name)
  shutil.copy2(source,d/'compiler.bas');(d/'compile.log').write_text(compiled)
  for i,c in enumerate(tests):
   if 'diagnostic' not in c:shutil.copy2(SD/f'p{i}.bin',d/f'p{i}.dat')
  (d/'status.json').write_text(json.dumps(dict(passed=False,host_exit_code=143,completed_native_compilations=22,expected_rejections=10,repeat_and_native_executions_unfinished=True,native_owned_process_check_clear=True,termination_cause_unknown=True),indent=2)+'\n')
  (d/'manifest.json').write_text(json.dumps({x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in d.iterdir() if x.name!='manifest.json'},indent=2)+'\n')
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h);start=time.monotonic()
 driver='10 ON ERROR REPORT:PRINT:CLOSE#0:PRINT "DATA_RESUME_FAILED":OSCLI "BYE"\n20 PROCinit:PROCcompile("p0.bas","data-fresh-repeat.bin")\n30 PRINT "DATA_RESUME_DONE":OSCLI "BYE"\n1000 DEF'+text.split('1000 DEF',1)[1]
 if '--existing-repeat' in sys.argv:
  assert (B/'resume-driver.bas').read_text()==driver
  log=(B/'resume-repeat.log').read_text();assert 'DATA_RESUME_DONE' in log
 else:
  (B/'resume-driver.bas').write_text(driver);(SD/'data-resume.bas').write_text(driver);(SD/'data-fresh-repeat.bin').unlink(missing_ok=True)
  log=h.run_profile(P,'load /bin/basic.bin\nrun . /data-resume.bas\n','DATA_RESUME_','data-resume-repeat.log',timeout_seconds=600);(B/'resume-repeat.log').write_text(log);assert 'DATA_RESUME_DONE' in log,log
 assert (SD/'data-fresh-repeat.bin').read_bytes()==(SD/'p0.bin').read_bytes();shutil.copy2(SD/'data-fresh-repeat.bin',SD/'output-repeat.bin');(B/'compile.log').write_text(compiled+'\nFresh repeat resume:\n'+log)
 linked=[];strings=[]
 for i,c in enumerate(tests):
  if 'diagnostic' in c:continue
  image=(SD/f'p{i}.bin').read_bytes()
  for dirname,prefix,entry,rows in [('numeric-runtime','runtime','rt_numeric',linked),('string-runtime','strings','rt_strliteral',strings)]:
   rt=ROOT/'compiler/build'/dirname;template=(rt/'runtime-0.bin').read_bytes();pos=image.find(template[:20])
   if pos<0:continue
   base=0x40000+pos;out=B/f'{prefix}-{base:x}.bin';subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e',entry,'--oformat=binary','-o',str(out),str(rt/'runtime.o')],check=True);assert image[pos:pos+len(template)]==out.read_bytes();rows.append(base)
 commands=[]
 for i,c in enumerate(tests):
  if 'diagnostic' not in c:commands += [f'echo OUTPUT_BEGIN_{i}',f'try /p{i}.bin','echo OUTPUT_STATUS:<Try$ReturnCode>',f'echo OUTPUT_END_{i}']
 commands+=['echo OUTPUT_NATIVE_DONE'];native=h.run_profile(P,'\n'.join(commands)+'\n','OUTPUT_NATIVE_DONE','data-resume-native.log',timeout_seconds=120);(B/'native.log').write_text(native)
 for i,c in enumerate(tests):
  if 'diagnostic' in c:continue
  got=native.split(f'OUTPUT_BEGIN_{i}\n',1)[1].split(f'OUTPUT_END_{i}\n',1)[0];assert got==c['expected']+f'OUTPUT_STATUS:{c["status"]}\n',(i,repr(got),c)
 template=(TASK/'build/data-runtime/runtime-0.bin').read_bytes();rows=[]
 for i,c in enumerate(tests):
  if 'diagnostic' in c:continue
  image=(SD/f'p{i}.bin').read_bytes();pos=image.find(template);assert pos>=0;rows.append(dict(program=i,base=0x40000+pos,bytes=len(template)))
 (B/'data-links.json').write_text(json.dumps(rows,indent=2)+'\n')
 subprocess.run([str(ROOT/'.venv/bin/python'),str(TASK/'check_data_images.py')],check=True)
 assert hashlib.sha256(source.read_bytes()).hexdigest()==digest
 report=dict(programs=len(tests),native_executions=sum('diagnostic' not in c for c in tests),rejected_sources=sum('diagnostic' in c for c in tests),reference_output_programs=sum(bool(c.get('reference')) for c in tests),deterministic_repeat=True,compiler_driver_byte_match=True,resumed_after_exit143=True,reference_eof_fixture_corrected=True,fresh_repeat_reused='--existing-repeat' in sys.argv,interrupted_compile_duration_unreported=True,duration_seconds=round(time.monotonic()-start,3),duration_scope='Current resume validation/execution/link checks; earlier interrupted compilation and reused fresh repeat excluded',independent_link_bases=linked,string_link_bases=strings,hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [source,ROOT/'bin/basic.bin',B/'cases.json']})
 (B/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
