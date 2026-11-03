"""Drive unchanged BBC source/main through interpreted and native self-generations."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time,signal,threading
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C006';PROFILE=ROOT/'.emulator'
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,default=ROOT/'compiler/compiler.bas');p.add_argument('--cli',type=Path,required=True);p.add_argument('--name',required=True);p.add_argument('--timeout',type=float,default=7200);p.add_argument('--resource-preflight',type=Path);p.add_argument('--expected-image',type=Path);a=p.parse_args();e=TASK/'evidence'/a.name;assert not e.exists(),'Preserve existing generation evidence';e.mkdir(parents=True);sd=PROFILE/'sdcard';assert (PROFILE/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True)
 source=a.compiler.resolve(strict=True);before=digest(source);shutil.copy2(source,e/'compiler.bas');shutil.copy2(source,sd/'self-source.bas');shutil.copy2(__file__,e/'bootstrap.py');keyboard=module('keyboard',ROOT/'docs/tasks/C005/io/interactive.py');durations={};images={}
 report=dict(scope='Actual source/main interpreted and native generation experiment',compiler_sha256=before,hardware_validation=False,performance_benchmark=False,inputs={str(q):digest(q) for q in [ROOT/'bin/basic.bin',PROFILE/'mos_platform.bin',PROFILE/'fab-agon-emulator.bin']},completed_stages=[],attempted_stages=[])
 stages=[('g0',None),('g1','g0'),('g2','g1'),('repeat','g1')]
 report['unmodified_interpreted_main_executed']=False
 expected_image=None
 if a.expected_image:
  expected_image=a.expected_image.read_bytes();assert expected_image[64:69]==b'MOS\x00\x01'
  shutil.copy2(a.expected_image,e/'expected-image.dat');report['expected_image_sha256']=digest(a.expected_image)
 if a.resource_preflight:
  origin=a.resource_preflight.resolve(strict=True);seed=origin/'native-compiler.dat';provenance=json.loads((origin/'results.json').read_text())
  assert provenance['source_compilation_succeeded'] and provenance['source_sha256']==before
  assert digest(seed)==provenance['image_sha256']
  shutil.copy2(seed,sd/'self-g0.bin');shutil.copy2(seed,e/'g0-seed.dat');shutil.copy2(origin/'results.json',e/'resource-seed-results.json');images['g0']=seed.read_bytes();stages=[('g1','g0')]
  report.update(scope='Native self-source/RAM preflight from resource-probe G0; full unmodified-main generation chain remains separate',resource_seed_directory=str(origin),resource_seed_sha256=digest(seed))
 def save():
  (e/'results.json').write_text(json.dumps(report,indent=2)+'\n');(e/'manifest.json').write_text(json.dumps({q.name:digest(q) for q in e.iterdir() if q.is_file() and q.name!='manifest.json'},indent=2)+'\n')
 save();stop=threading.Event()
 def interrupted(signum,frame):
  report['interrupted_by_signal']=signum;save()
  raise InterruptedError(f'Bootstrap controller received signal {signum}')
 previous_term=signal.signal(signal.SIGTERM,interrupted)
 def heartbeat():
  while not stop.wait(30):
   attempted=report['attempted_stages']
   if attempted:print('BOOTSTRAP_CONTROLLER_ACTIVE',attempted[-1],flush=True)
 observer=threading.Thread(target=heartbeat,daemon=True);observer.start()
 try:
  for stage,executable in stages:
   target=f'self-{stage}.bin';(sd/target).unlink(missing_ok=True);marker=f'SELF_{stage.upper()}_DONE';start=time.monotonic();steps=[('Source file: ','self-source.bas'),('Output file: ',target)]
   if executable is None:
    auto='load /bin/basic.bin\nrun . /self-source.bas\necho '+marker+'\n';steps.append(('Wrote '+target,'*BYE'))
   else:auto=f'try /self-{executable}.bin\necho SELF_STATUS:<Try$ReturnCode>\necho {marker}\n'
   (e/f'{stage}-commands.txt').write_text(auto);(e/f'{stage}-keyboard.json').write_text(json.dumps(steps,indent=2)+'\n');report['attempted_stages'].append(stage);save();(PROFILE/f'self-{stage}.log').unlink(missing_ok=True);print('Starting',stage,flush=True)
   log=keyboard.run(PROFILE,auto,steps,marker,f'self-{stage}.log',timeout_seconds=a.timeout,abort_patterns=[(i,'\n>') for i in range(3)] if executable is None else []);(e/f'{stage}.log').write_text(log);assert 'Wrote '+target in log,log
   if executable is not None:assert 'SELF_STATUS:0\n' in log,log
   blob=(sd/target).read_bytes();assert blob[64:69]==b'MOS\x00\x01',blob[:80];shutil.copy2(sd/target,e/f'{stage}.dat');images[stage]=blob;durations[stage]=round(time.monotonic()-start,3);report['completed_stages'].append(stage);report['generation_hashes']={n:hashlib.sha256(v).hexdigest() for n,v in images.items()};report['generation_sizes']={n:len(v) for n,v in images.items()};report['controller_seconds']=durations
   if stage=='g0':report['unmodified_interpreted_main_executed']=True
   save();print('Completed',stage,len(blob),durations[stage],flush=True)
   if expected_image is not None:assert blob==expected_image,f'{stage} differs from previously qualified image; stop before further native execution'
   if executable is not None:assert blob==images['g0'],f'{stage} differs from interpreted generation'
  assert digest(source)==before,'Compiler source changed during generation'
  if a.resource_preflight:report['native_self_source_matches_resource_seed']=True
  else:report['all_four_images_identical']=True
  save();print(json.dumps(report,indent=2))
 except BaseException as err:
  report['failure']=repr(err)
  for stage in report['attempted_stages']:
   log=PROFILE/f'self-{stage}.log'
   if log.is_file() and not (e/f'{stage}.log').exists():shutil.copy2(log,e/f'{stage}.log')
  save();raise
 finally:
  stop.set();observer.join(timeout=3);signal.signal(signal.SIGTERM,previous_term)
if __name__=='__main__':main()
