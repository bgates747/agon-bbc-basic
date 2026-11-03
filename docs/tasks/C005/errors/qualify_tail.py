"""Historical44533e0d orchestration, stopped at the recorded Escape mismatch.
Current qualification is indexed by ERRORS.md; do not replay against newer source.
"""
from pathlib import Path
import hashlib,json,shutil,subprocess
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005';PY=ROOT/'.venv/bin/python';CLI='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator';COMPILER=TASK/'compiler.bas'
def run(script,*args,log):
 print('Starting',script,flush=True)
 with Path(log).open('w') as f:result=subprocess.run([str(PY),str(ROOT/script),*map(str,args)],cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
 if result.returncode:raise SystemExit(f'{script} failed ({result.returncode}); see {log}')
 print('Passed',script,flush=True)
def manifest(d):
 (d/'manifest.json').write_text(json.dumps({str(q.relative_to(d)):hashlib.sha256(q.read_bytes()).hexdigest() for q in d.rglob('*') if q.is_file() and q.name!='manifest.json'},indent=2)+'\n')
def main():
 assert hashlib.sha256(COMPILER.read_bytes()).hexdigest()=='44533e0d4d5c2a0477ea80cae0ed263088e0c203e61d32a8dcd0e777d7f73104','Historical44533e0d workflow; use ERRORS.md current commands'
 log='/tmp/c005-errors-unchanged-024.log';run('docs/tasks/C005/test_errors.py','--cli',CLI,'--start',24,'--count',2,'--timeout',900,log=log);subprocess.run([str(PY),str(TASK/'check_error_images.py')],cwd=ROOT,check=True)
 old=TASK/'evidence/errors-final-cohort-024';b=TASK/'build/errors-language';assert all((old/f'p{i}.dat').read_bytes()==(b/f'p{i}.dat').read_bytes() for i in range(2))
 original=(old/'compiler.bas').read_text();assert original.replace('11220 PROClabel(cid$+"b"):PROCerrmark','11220 PROClabel(cid$+"b"):IF ck%<>2 PROCerrmark')==COMPILER.read_text()
 unchanged=[]
 for start in range(0,30,6):
  d=TASK/f'evidence/errors-final-cohort-{start:03d}'
  cases=json.loads((d/'cases.json').read_text());assert all('WHILE' not in c['source'] for c in cases);unchanged+=list(range(start,start+len(cases)))
 subprocess.run([str(PY),str(TASK/'freeze_error_evidence.py'),'errors-unchanged-024','--log',log],cwd=ROOT,check=True);d=TASK/'evidence/errors-unchanged-024';(d/'emission-equivalence.json').write_text(json.dumps(dict(previous_source=hashlib.sha256(original.encode()).hexdigest(),current_source=hashlib.sha256(COMPILER.read_bytes()).hexdigest(),only_change='Skip extra error mark for WHILE condition reentry',previous_cases_without_WHILE=unchanged,actual_full_images_identical=[24,25]),indent=2)+'\n');manifest(d)
 for label,script in [('errors-rejections-001','test_error_rejections.py'),('errors-modern-001','test_modern_errors.py')]:
  log='/tmp/c005-'+label+'.log';run('docs/tasks/C005/'+script,'--cli',CLI,'--compiler',COMPILER,'--timeout',900,log=log)
  if 'modern' in label:subprocess.run([str(PY),str(TASK/'check_error_images.py'),'--build',str(TASK/'build/output-integration'),'--image-pattern','p{}.bin'],cwd=ROOT,check=True)
  subprocess.run([str(PY),str(TASK/'freeze_output_evidence.py'),label,'--script',str(TASK/script),'--log',log],cwd=ROOT,check=True)
 log='/tmp/c005-errors-io-001.log';run('docs/tasks/C005/test_error_io.py','--cli',CLI,'--compiler',COMPILER,log=log);d=TASK/'evidence/errors-io-001';assert not d.exists();d.mkdir(parents=True)
 for q in (TASK/'build/error-io').iterdir():
  if q.suffix in ['.bas','.dat','.json','.log','.s']:shutil.copy2(q,d/q.name)
 for q in [COMPILER,TASK/'test_error_io.py',TASK/'check_error_images.py',TASK/'io/interactive.py',Path(log)]:shutil.copy2(q,d/q.name)
 manifest(d)
 log='/tmp/c005-errors-baseline-001.log';run('compiler/tools/test_compiler.py','--cli',CLI,'--compiler',COMPILER,'--timeout',600,log=log);d=TASK/'evidence/errors-baseline-001';assert not d.exists();d.mkdir(parents=True)
 for q in [COMPILER,ROOT/'compiler/build/test-results.json',ROOT/'.emulator/compile.log',ROOT/'.emulator/native.log',ROOT/'.emulator/sdcard/driver.bas',Path(log)]:shutil.copy2(q,d/q.name)
 for source,name in [(ROOT/'compiler/build/golden.bin','golden.dat'),(ROOT/'.emulator/sdcard/t0.bin','actual.dat'),(ROOT/'.emulator/sdcard/repeat.bin','repeat.dat')]:shutil.copy2(source,d/name)
 manifest(d)
 run('docs/tasks/C005/probe_bootstrap_gap.py','--compiler',COMPILER,'--evidence','errors-source-gap-001',log='/tmp/c005-errors-source-gap-001.log')
 print('Final error/UI/baseline qualification and measured source gap complete',flush=True)
if __name__=='__main__':main()
