"""Run retained error fixtures through an actual native BBC-written compiler.
Python copies fixtures, types filenames, runs pinned BASIC oracles and compares
complete output/images. It never compiles or transforms a user's BASIC program.
"""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C006';PROFILE=ROOT/'.emulator';C5=ROOT/'docs/tasks/C005'
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--native',type=Path,required=True);p.add_argument('--source',type=Path,required=True);p.add_argument('--cli',type=Path,required=True);p.add_argument('--name',required=True);p.add_argument('--start',type=int,default=0);p.add_argument('--count',type=int);p.add_argument('--timeout',type=float,default=1800);a=p.parse_args();e=TASK/'evidence'/a.name;assert not e.exists();e.mkdir(parents=True);sd=PROFILE/'sdcard';assert (PROFILE/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True);shutil.copy2(a.native,sd/'native-compiler.bin');shutil.copy2(a.native,e/'native-compiler.dat');shutil.copy2(a.source,e/'compiler.bas');shutil.copy2(__file__,e/'native_errors.py');fixtures=mod('fixtures',C5/'test_errors.py');h=mod('h',ROOT/'compiler/tools/test_compiler.py');keyboard=mod('k',C5/'io/interactive.py');cases=fixtures.programs()[a.start:a.start+a.count if a.count is not None else None];assert cases;start=time.monotonic();report=dict(scope='Native compiler output qualification; generation/self-hosting proof is separate',native_compiler_sha256=digest(a.native),supplied_compiler_source_sha256=digest(a.source),source_case_indices=list(range(a.start,a.start+len(cases))),completed_cases=[],hardware_validation=False,performance_benchmark=False,hashes={str(q):digest(q) for q in [ROOT/'bin/basic.bin',PROFILE/'mos_platform.bin',PROFILE/'fab-agon-emulator.bin']})
 try:
  for i,c in enumerate(cases):
   c['source']=fixtures.source(c,i);c['reference_source']=fixtures.source(c,i,True);(sd/f'nerr-{i}.bas').write_text(c['source']);(e/f'p{i}.bas').write_text(c['source']);(sd/f'nerr-ref-{i}.bas').write_text(c['reference_source']);(e/f'reference-{i}.bas').write_text(c['reference_source']);auto=f'load /bin/basic.bin\nrun . /nerr-ref-{i}.bas\necho NERR_REF_END_{i}\n'
   if c.get('fatal'):out=keyboard.run(PROFILE,auto,[(c['fatal']+' at line','*BYE')],f'NERR_REF_END_{i}',f'nerr-ref-{i}.log',timeout_seconds=60)
   else:out=h.run_profile(PROFILE,auto,f'NERR_REF_END_{i}',f'nerr-ref-{i}.log',timeout_seconds=60)
   (e/f'reference-{i}.log').write_text(out);c['expected']=out.split(f'ERROR_CASE_BEGIN_{i}\n',1)[1].split(f'NERR_REF_END_{i}\n',1)[0].replace('>*BYE\n','');assert 'WRONG' not in c['expected']
   auto=f'try /native-compiler.bin\necho NERR_COMPILER_STATUS:<Try$ReturnCode>\necho NERR_COMPILE_END_{i}\n';out=keyboard.run(PROFILE,auto,[('Source file: ',f'nerr-{i}.bas'),('Output file: ',f'nerr-{i}.bin')],f'NERR_COMPILE_END_{i}',f'nerr-compile-{i}.log',timeout_seconds=a.timeout);(e/f'compile-{i}.log').write_text(out);assert f'Wrote nerr-{i}.bin\n' in out and 'NERR_COMPILER_STATUS:0\n' in out,out;shutil.copy2(sd/f'nerr-{i}.bin',e/f'p{i}.dat')
   out=h.run_profile(PROFILE,f'try /nerr-{i}.bin\necho NERR_STATUS:<Try$ReturnCode>\necho NERR_EXEC_END_{i}\n',f'NERR_EXEC_END_{i}',f'nerr-native-{i}.log',timeout_seconds=120);(e/f'native-{i}.log').write_text(out);got=out.split(f'ERROR_CASE_BEGIN_{i}\n',1)[1].split(f'NERR_EXEC_END_{i}\n',1)[0];assert got==c['expected']+f'NERR_STATUS:{c.get("status",0)}\n',(i,got,c)
   report['completed_cases'].append(a.start+i);print('Native compiler error fixture',a.start+i,'matches pinned BASIC',flush=True)
  auto='try /native-compiler.bin\necho NERR_REPEAT_DONE\n';out=keyboard.run(PROFILE,auto,[('Source file: ','nerr-0.bas'),('Output file: ','nerr-repeat.bin')],'NERR_REPEAT_DONE','nerr-repeat.log',timeout_seconds=a.timeout);(e/'repeat.log').write_text(out);assert 'Wrote nerr-repeat.bin' in out;assert (sd/'nerr-repeat.bin').read_bytes()==(e/'p0.dat').read_bytes();shutil.copy2(sd/'nerr-repeat.bin',e/'repeat.dat');(e/'cases.json').write_text(json.dumps(cases,indent=2)+'\n');mod('check',C5/'check_error_images.py').check(e,'nerr-{}.bin');report.update(all_outputs_and_ERR_ERL_match=True,deterministic_repeat=True,controller_seconds=round(time.monotonic()-start,3))
 except BaseException as err:report['failure']=repr(err);raise
 finally:
  (e/'cases.json').write_text(json.dumps(cases,indent=2)+'\n');(e/'results.json').write_text(json.dumps(report,indent=2)+'\n');(e/'manifest.json').write_text(json.dumps({q.name:digest(q) for q in e.iterdir() if q.is_file() and q.name!='manifest.json'},indent=2)+'\n')
 print(json.dumps(report,indent=2))
if __name__=='__main__':main()
