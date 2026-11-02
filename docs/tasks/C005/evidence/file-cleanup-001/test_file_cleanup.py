"""Check generated END/fall-through/error cleanup within a single live MOS session."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,subprocess,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def main():
 p=argparse.ArgumentParser();p.add_argument('--cli',type=Path,required=True);p.add_argument('--compiler',type=Path,default=TASK/'compiler.bas');a=p.parse_args()
 b=TASK/'build/file-cleanup';b.mkdir(parents=True,exist_ok=True);profile=ROOT/'.emulator';sd=profile/'sdcard'
 assert (profile/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True)
 sources=['FOR i%=1 TO 8:h%=OPENIN("file.dat"):NEXT:END\n','h%=OPENIN("file.dat")\n']
 for i,s in enumerate(sources):(b/f'p{i}.bas').write_text(s);(sd/f'cleanup-{i}.bas').write_text(s)
 defs=a.compiler.read_text().split('1000 DEF',1)[1]
 driver='10 ON ERROR REPORT:PRINT:PRINT "CLEANUP_COMPILE_FAILED":OSCLI "BYE"\n20 PROCinit\n30 PROCcompile("cleanup-0.bas","cleanup-0.bin")\n40 PROCcompile("cleanup-1.bas","cleanup-1.bin")\n50 PRINT "CLEANUP_COMPILE_DONE":OSCLI "BYE"\n1000 DEF'+defs
 (b/'driver.bas').write_text(driver);(sd/'cleanup-driver.bas').write_text(driver)
 sp=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);start=time.monotonic()
 log=h.run_profile(profile,'load /bin/basic.bin\nrun . /cleanup-driver.bas\n','CLEANUP_COMPILE_','cleanup-compile.log',timeout_seconds=600)
 (b/'compile.log').write_text(log);assert 'CLEANUP_COMPILE_DONE' in log,log
 tc=Path('/Agon/agondev/release/bin')
 subprocess.run([str(tc/'ez80-none-elf-as'),'-march=ez80+full','-o',str(b/'probe.o'),str(TASK/'io/file-cleanup.s')],check=True)
 subprocess.run([str(tc/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','entry','--oformat=binary','-o',str(b/'probe.bin'),str(b/'probe.o')],check=True)
 shutil.copy2(b/'probe.bin',sd/'cleanup-probe.bin');shutil.copy2(TASK/'evidence/io-002/p22.dat',sd/'cleanup-error.bin');(sd/'file.dat').write_bytes(b'fixture')
 commands=[]
 for i,image in enumerate(['cleanup-0.bin','cleanup-1.bin','cleanup-error.bin']):
  commands += [f'try /{image}',f'echo CLEANUP_PROGRAM_{i}:<Try$ReturnCode>','try /cleanup-probe.bin',f'echo CLEANUP_CHECK_{i}:<Try$ReturnCode>']
 commands+=['echo CLEANUP_NATIVE_DONE']
 log=h.run_profile(profile,'\n'.join(commands)+'\n','CLEANUP_NATIVE_DONE','cleanup-native.log',timeout_seconds=60);(b/'native.log').write_text(log)
 for i,status in enumerate([0,0,1]):
  assert f'CLEANUP_PROGRAM_{i}:{status}\n' in log,log
  assert f'CLEANUP_CHECK_{i}:0\n' in log,log
 for i in range(2):shutil.copy2(sd/f'cleanup-{i}.bin',b/f'p{i}.dat')
 report=dict(same_MOS_session=True,end_fallthrough_and_uncaught_error=True,eight_handles_available_after_each=True,duration_seconds=round(time.monotonic()-start,3),compiler_sha256=hashlib.sha256(a.compiler.read_bytes()).hexdigest())
 (b/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
