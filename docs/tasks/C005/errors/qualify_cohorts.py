"""Run disjoint cohorts sequentially and freeze each before fixture reuse."""
from pathlib import Path
import argparse,subprocess,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005';PY=ROOT/'.venv/bin/python'
def main():
 p=argparse.ArgumentParser();p.add_argument('--start',type=int,default=12);p.add_argument('--stop',type=int,default=39);p.add_argument('--compiler',type=Path,default=TASK/'compiler.bas');p.add_argument('--prefix',default='errors-final-cohort');a=p.parse_args()
 for start in range(a.start,a.stop,6):
  name=f'{a.prefix}-{start:03d}';log=Path('/tmp')/f'c005-{name}.log';assert not (TASK/'evidence'/name).exists();print('Starting',name,flush=True)
  with log.open('w') as out:
   child=subprocess.Popen([str(PY),str(TASK/'test_errors.py'),'--cli','/tmp/bbc-compiler-cli-target/release/agon-cli-emulator','--compiler',str(a.compiler),'--start',str(start),'--count',str(min(6,a.stop-start)),'--timeout','1200'],cwd=ROOT,stdout=out,stderr=subprocess.STDOUT)
   while child.poll() is None:time.sleep(20)
  if child.returncode:raise SystemExit(f'{name} failed ({child.returncode}); see {log}')
  subprocess.run([str(PY),str(TASK/'check_error_images.py')],cwd=ROOT,check=True)
  subprocess.run([str(PY),str(TASK/'freeze_error_evidence.py'),name,'--log',str(log)],cwd=ROOT,check=True)
  print('Qualified and frozen',name,flush=True)
if __name__=='__main__':main()
