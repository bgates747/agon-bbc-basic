"""Drive unchanged BBC source/main through interpreted and native self-generations."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C006';PROFILE=ROOT/'.emulator'
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,default=ROOT/'compiler/compiler.bas');p.add_argument('--cli',type=Path,required=True);p.add_argument('--name',required=True);p.add_argument('--timeout',type=float,default=7200);a=p.parse_args();e=TASK/'evidence'/a.name;assert not e.exists(),'Preserve existing generation evidence';e.mkdir(parents=True);sd=PROFILE/'sdcard';assert (PROFILE/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True)
 source=a.compiler.resolve(strict=True);before=digest(source);shutil.copy2(source,e/'compiler.bas');shutil.copy2(source,sd/'self-source.bas');shutil.copy2(__file__,e/'bootstrap.py');keyboard=module('keyboard',ROOT/'docs/tasks/C005/io/interactive.py');durations={};images={}
 report=dict(scope='Actual source/main interpreted and native generation experiment',compiler_sha256=before,hardware_validation=False,performance_benchmark=False,inputs={str(q):digest(q) for q in [ROOT/'bin/basic.bin',PROFILE/'mos_platform.bin',PROFILE/'fab-agon-emulator.bin']},completed_stages=[],attempted_stages=[])
 def save():
  (e/'results.json').write_text(json.dumps(report,indent=2)+'\n');(e/'manifest.json').write_text(json.dumps({q.name:digest(q) for q in e.iterdir() if q.is_file() and q.name!='manifest.json'},indent=2)+'\n')
 try:
  for stage,executable in [('g0',None),('g1','g0'),('g2','g1'),('repeat','g1')]:
   target=f'self-{stage}.bin';(sd/target).unlink(missing_ok=True);marker=f'SELF_{stage.upper()}_DONE';start=time.monotonic();steps=[('Source file: ','self-source.bas'),('Output file: ',target)]
   if executable is None:
    auto='load /bin/basic.bin\nrun . /self-source.bas\necho '+marker+'\n';steps.append(('Wrote '+target,'*BYE'))
   else:auto=f'try /self-{executable}.bin\necho SELF_STATUS:<Try$ReturnCode>\necho {marker}\n'
   (e/f'{stage}-commands.txt').write_text(auto);(e/f'{stage}-keyboard.json').write_text(json.dumps(steps,indent=2)+'\n');report['attempted_stages'].append(stage);(PROFILE/f'self-{stage}.log').unlink(missing_ok=True);print('Starting',stage,flush=True)
   log=keyboard.run(PROFILE,auto,steps,marker,f'self-{stage}.log',timeout_seconds=a.timeout,abort_patterns=[(2,'\n>')] if executable is None else []);(e/f'{stage}.log').write_text(log);assert 'Wrote '+target in log,log
   if executable is not None:assert 'SELF_STATUS:0\n' in log,log
   blob=(sd/target).read_bytes();assert blob[64:69]==b'MOS\x00\x01',blob[:80];shutil.copy2(sd/target,e/f'{stage}.dat');images[stage]=blob;durations[stage]=round(time.monotonic()-start,3);report['completed_stages'].append(stage);report['generation_hashes']={n:hashlib.sha256(v).hexdigest() for n,v in images.items()};report['generation_sizes']={n:len(v) for n,v in images.items()};report['controller_seconds']=durations;save();print('Completed',stage,len(blob),durations[stage],flush=True)
   if executable is not None:assert blob==images['g0'],f'{stage} differs from interpreted generation'
  assert digest(source)==before,'Compiler source changed during generation';report['all_four_images_identical']=True;save();print(json.dumps(report,indent=2))
 except BaseException as err:
  report['failure']=repr(err)
  for stage in report['attempted_stages']:
   log=PROFILE/f'self-{stage}.log'
   if log.is_file() and not (e/f'{stage}.log').exists():shutil.copy2(log,e/f'{stage}.log')
  save();raise
if __name__=='__main__':main()
