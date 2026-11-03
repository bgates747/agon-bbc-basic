"""Real Escape recovery and native file cleanup with source error facilities."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,subprocess,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def main():
 p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,default=TASK/'compiler.bas');p.add_argument('--cli',type=Path,required=True);p.add_argument('--reuse-compiled',action='store_true');a=p.parse_args();profile=ROOT/'.emulator';sd=profile/'sdcard';assert (profile/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True)
 b=TASK/'build/error-io';b.mkdir(parents=True,exist_ok=True);start=time.monotonic();previous_driver=(b/'driver.bas').read_text() if (b/'driver.bas').exists() else '';previous_cases=(b/'cases.json').read_text() if (b/'cases.json').exists() else ''
 source='10 PRINT "IO_ERROR_BEGIN"\n20 s$="old"\n30 ON ERROR PRINT ;ERR;":";ERL;":";s$:REPORT:PRINT:END\n40 INPUT LINE "ERROR_ESCAPE:"s$\n50 PRINT "WRONG":END\n'
 sources=[source,
 '10 ON ERROR PRINT ;BGET#h%:END\n20 FOR i%=1 TO 8:h%=OPENIN("error-file.dat"):NEXT\n30 ERROR 100,"caught"\n',
 '10 FOR i%=1 TO 8:h%=OPENIN("error-file.dat"):NEXT\n20 ERROR 100,"uncaught"\n']
 if a.reuse_compiled:assert json.loads(previous_cases)==[dict(source=text) for text in sources],'Previous source cohort differs'
 for i,text in enumerate(sources):(b/f'p{i}.bas').write_text(text);(sd/f'error-io-{i}.bas').write_text(text)
 (b/'cases.json').write_text(json.dumps([dict(source=text) for text in sources],indent=2)+'\n');defs=a.compiler.read_text().split('1000 DEF',1)[1]
 driver='10 ON ERROR REPORT:PRINT:CLOSE#0:PRINT "ERROR_IO_COMPILE_FAILED":OSCLI "BYE"\n20 PROCinit\n'+'\n'.join(f'{100+i*10} PROCcompile("error-io-{i}.bas","error-io-{i}.bin")' for i in range(len(sources)))+'\n200 PRINT "ERROR_IO_COMPILE_DONE":OSCLI "BYE"\n1000 DEF'+defs
 (b/'driver.bas').write_text(driver);(sd/'error-io-driver.bas').write_text(driver);h=mod('h',ROOT/'compiler/tools/test_compiler.py');keyboard=mod('keyboard',TASK/'io/interactive.py')
 if a.reuse_compiled:
  assert previous_driver==driver,'Previous embedded BBC compiler differs'
  log=(b/'compile.log').read_text();assert 'ERROR_IO_COMPILE_DONE' in log
  for i in range(3):assert (b/f'p{i}.dat').read_bytes()==(sd/f'error-io-{i}.bin').read_bytes(),'Native file changed since compilation'
 else:
  log=h.run_profile(profile,'load /bin/basic.bin\nrun . /error-io-driver.bas\n','ERROR_IO_COMPILE_','error-io-compile.log',timeout_seconds=800);(b/'compile.log').write_text(log);assert 'ERROR_IO_COMPILE_DONE' in log,log
 for i in range(3):shutil.copy2(sd/f'error-io-{i}.bin',b/f'p{i}.dat')
 ref=source.replace(':END',':OSCLI "BYE"');(b/'reference.bas').write_text(ref);(sd/'error-io-reference.bas').write_text(ref)
 logs={}
 for name,auto in [('reference','load /bin/basic.bin\nrun . /error-io-reference.bas\necho ERROR_IO_SESSION_DONE\n'),('native','try /error-io-0.bin\necho ERROR_IO_STATUS:<Try$ReturnCode>\necho ERROR_IO_SESSION_DONE\n')]:
  out=keyboard.run(profile,auto,[('ERROR_ESCAPE:','\x1b')],'ERROR_IO_SESSION_DONE','error-io-'+name+'.log',timeout_seconds=60);(b/(name+'.log')).write_text(out);logs[name]=out.split('IO_ERROR_BEGIN\n',1)[1].split('ERROR_IO_STATUS:',1)[0].split('ERROR_IO_SESSION_DONE',1)[0]
 assert logs['reference']==logs['native'],logs;assert '17:30:old\nEscape\n' in logs['native'],logs;assert 'ERROR_IO_STATUS:0\n' in (b/'native.log').read_text()
 (sd/'error-file.dat').write_bytes(b'fixture');(sd/'file.dat').write_bytes(b'fixture')
 ref='1 PRINT "ERROR_FILE_REF_BEGIN"\n'+sources[1].replace(':END\n',':OSCLI "BYE"\n');(b/'file-reference.bas').write_text(ref);(sd/'error-file-reference.bas').write_text(ref);out=h.run_profile(profile,'load /bin/basic.bin\nrun . /error-file-reference.bas\necho ERROR_FILE_REF_DONE\n','ERROR_FILE_REF_DONE','error-file-reference.log',timeout_seconds=60);(b/'file-reference.log').write_text(out);assert out.split('ERROR_FILE_REF_BEGIN\n',1)[1].split('ERROR_FILE_REF_DONE\n',1)[0]=='102\n',out
 tc=Path('/Agon/agondev/release/bin');subprocess.run([str(tc/'ez80-none-elf-as'),'-march=ez80+full','-o',str(b/'probe.o'),str(TASK/'io/file-cleanup.s')],check=True);subprocess.run([str(tc/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','entry','--oformat=binary','-o',str(b/'probe.bin'),str(b/'probe.o')],check=True);shutil.copy2(b/'probe.bin',sd/'error-cleanup-probe.bin');shutil.copy2(b/'probe.bin',b/'probe.dat');shutil.copy2(TASK/'io/file-cleanup.s',b/'probe.s');(sd/'error-file.dat').write_bytes(b'fixture');(sd/'file.dat').write_bytes(b'fixture')
 commands=[]
 for i in [1,2]:commands += [f'try /error-io-{i}.bin',f'echo ERROR_FILE_STATUS_{i}:<Try$ReturnCode>','try /error-cleanup-probe.bin',f'echo ERROR_FILE_CHECK_{i}:<Try$ReturnCode>']
 commands+=['echo ERROR_FILE_DONE'];out=h.run_profile(profile,'\n'.join(commands)+'\n','ERROR_FILE_DONE','error-file-cleanup.log',timeout_seconds=60);(b/'cleanup.log').write_text(out)
 assert '102\nERROR_FILE_STATUS_1:0\n' in out,out
 for i,status in [(1,0),(2,1)]:assert f'ERROR_FILE_STATUS_{i}:{status}\n' in out and f'ERROR_FILE_CHECK_{i}:0\n' in out,out
 mod('check',TASK/'check_error_images.py').check(b,'error-io-{}.bin')
 report=dict(programs=3,real_Escape_matches_reference=True,ERR_ERL_old_string_and_REPORT_match=True,caught_handler_keeps_open_file=True,caught_END_and_uncaught_error_close_all_eight_handles=True,duration_scope='resume validation and UI/native checks' if a.reuse_compiled else 'full compilation and UI/native checks',reused_complete_compile=a.reuse_compiled,duration_seconds=round(time.monotonic()-start,3),compiler_sha256=hashlib.sha256(a.compiler.read_bytes()).hexdigest());(b/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
