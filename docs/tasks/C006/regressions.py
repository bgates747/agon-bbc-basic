"""Compile regression fixtures using only an actual generated native compiler."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C006';PROFILE=ROOT/'.emulator'
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def programs():
 return [
  dict(source='PRINT "native compiler":END\n',expected='native compiler\n',status=0),
  dict(source='PRINT ;STR$(1/10);":";STR$~(-1);":";INT(-1.1):END\n',reference=True,status=0),
  dict(source='n%=0:FOR i%=1 TO 10:IF i% MOD 2 THEN n%=n%+i%\nNEXT:WHILE n%<30:n%=n%+1:ENDWHILE:REPEAT:n%=n%-1:UNTIL n%=25\nPRINT ;n%:END\n',reference=True,status=0),
  dict(source='x%=7:PRINT ;FNsum(5);":";x%:END\nDEF FNsum(n%):LOCAL x%:x%=n%:IF n%<=1 THEN =1\n=n%+FNsum(n%-1)\n',reference=True,status=0),
  dict(source='s$="outer":PROCp:PRINT s$:END\nDEF PROCp:LOCAL s$:s$="inside":PRINT s$:ENDPROC\n',reference=True,status=0),
  dict(source='DIM a%(1,2),s$(1):a%(1,2)=2147483647:s$(1)="array"\nPRINT ;a%(1,2);":";s$(1):END\n',reference=True,status=0),
  dict(source='DIM p% 9:p%?0=255:p%!1=&80000000:PRINT ;?p%;":";p%!1:END\n',reference=True,status=0),
  dict(source='READ a,s$:PRINT ;a;":";s$:RESTORE:READ a:PRINT ;a:END\nDATA .1,"record"\n',reference=True,status=0),
  dict(source='h%=OPENOUT("native-test.dat"):BPUT#h%,255:BPUT#h%,"text";:CLOSE#h%\nh%=OPENIN("native-test.dat"):PRINT ;BGET#h%;":";BGET#h%;":";EOF#h%:CLOSE#h%:END\n',expected='255:116:0\n',status=0),
  dict(source='10 x%=7\n20 ON ERROR PRINT ;ERR;":";ERL;":";x%:REPORT:PRINT:END\n30 PROCp\n100 DEF PROCp:LOCAL x%:x%=99:ERROR 100,"recovery"\n',expected='100:100:99\nrecovery\n',status=0),
  dict(source='GOTO @missing\n',diagnostic='Undefined target @missing'),
  dict(source='PRINT EVAL("1")\n',diagnostic='EVAL is deliberately unsupported'),
 ]
def main():
 p=argparse.ArgumentParser();p.add_argument('--native',type=Path,required=True);p.add_argument('--cli',type=Path,required=True);p.add_argument('--name',required=True);p.add_argument('--timeout',type=float,default=1800);a=p.parse_args();e=TASK/'evidence'/a.name;assert not e.exists();e.mkdir(parents=True);sd=PROFILE/'sdcard';assert (PROFILE/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True);shutil.copy2(a.native,sd/'native-compiler.bin');shutil.copy2(a.native,e/'native-compiler.dat');shutil.copy2(__file__,e/'regressions.py');h=mod('h',ROOT/'compiler/tools/test_compiler.py');keyboard=mod('k',ROOT/'docs/tasks/C005/io/interactive.py');cases=programs();start=time.monotonic();report=dict(native_compiler_sha256=digest(a.native),completed_cases=[],hardware_validation=False)
 try:
  for i,c in enumerate(cases):
   source=f'nreg-{i}.bas';target=f'nreg-{i}.bin';(sd/source).write_text(c['source']);(e/source).write_text(c['source']);sentinel=b'Native rejection preserves previous output';(sd/target).write_bytes(sentinel)
   auto=f'try /native-compiler.bin\necho NREG_COMPILER_STATUS:<Try$ReturnCode>\necho NREG_COMPILE_DONE_{i}\n';out=keyboard.run(PROFILE,auto,[('Source file: ',source),('Output file: ',target)],f'NREG_COMPILE_DONE_{i}',f'nreg-compile-{i}.log',timeout_seconds=a.timeout);(e/f'compile-{i}.log').write_text(out)
   # The unchanged BBC compiler main catches diagnostics and END returns normally.
   assert 'NREG_COMPILER_STATUS:0\n' in out,out
   if 'diagnostic' in c:assert c['diagnostic'] in out and (sd/target).read_bytes()==sentinel,(i,out)
   else:
    assert 'Wrote '+target in out,out;shutil.copy2(sd/target,e/f'p{i}.dat')
    if c.get('reference'):
     ref='10 PRINT "NREG_REFERENCE_BEGIN"\n'+'\n'.join(f'{100+j*10} {line}' for j,line in enumerate(c['source'].splitlines()))+'\n';ref=ref.replace(':END\n',':OSCLI "BYE"\n');(sd/f'nreg-ref-{i}.bas').write_text(ref);(e/f'reference-{i}.bas').write_text(ref)
     out=h.run_profile(PROFILE,f'load /bin/basic.bin\nrun . /nreg-ref-{i}.bas\necho NREG_REFERENCE_END\n','NREG_REFERENCE_END',f'nreg-reference-{i}.log',timeout_seconds=120);(e/f'reference-{i}.log').write_text(out);body=out.split('NREG_REFERENCE_BEGIN\n',1)[1].split('NREG_REFERENCE_END\n',1)[0];c['expected']=body
    out=h.run_profile(PROFILE,f'echo NREG_NATIVE_BEGIN\ntry /{target}\necho NREG_STATUS:<Try$ReturnCode>\necho NREG_NATIVE_END\n','NREG_NATIVE_END',f'nreg-native-{i}.log',timeout_seconds=120);(e/f'native-{i}.log').write_text(out);got=out.split('NREG_NATIVE_BEGIN\n',1)[1].split('NREG_NATIVE_END\n',1)[0];assert got==c['expected']+f'NREG_STATUS:{c["status"]}\n',(i,got,c)
   report['completed_cases'].append(i);print('Native compiler regression',i,'passed',flush=True)
  report.update(all_cases_passed=True,controller_seconds=round(time.monotonic()-start,3))
 except BaseException as err:report['failure']=repr(err);raise
 finally:
  (e/'cases.json').write_text(json.dumps(cases,indent=2)+'\n');(e/'results.json').write_text(json.dumps(report,indent=2)+'\n');(e/'manifest.json').write_text(json.dumps({q.name:digest(q) for q in e.iterdir() if q.is_file() and q.name!='manifest.json'},indent=2)+'\n')
 print(json.dumps(report,indent=2))
if __name__=='__main__':main()
