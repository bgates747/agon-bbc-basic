"""Retain only the current numbered error-language cohort and verified links."""
from pathlib import Path
import argparse,hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def main():
 p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('--log',type=Path,required=True);p.add_argument('--compiler',type=Path,default=TASK/'compiler.bas');a=p.parse_args();d=TASK/'evidence'/a.name;assert not d.exists();d.mkdir(parents=True);b=TASK/'build/errors-language';report=json.loads((b/'results.json').read_text());cases=json.loads((b/'cases.json').read_text());assert len(cases)==report['programs']
 assert 'ERROR_COMPILE_DONE' in (b/'compile.log').read_text()
 assert report['compiler_sha256']==hashlib.sha256(a.compiler.read_bytes()).hexdigest()
 names=['cases.json','results.json','compile.log','driver.bas','native.log','runtime-links.json']
 for i in range(len(cases)):names += [f'reference-{i}.bas',f'reference-{i}.log',f'p{i}.dat']
 for n in names:shutil.copy2(b/n,d/n)
 for row in json.loads((b/'runtime-links.json').read_text()):
  for key,base in row['bases'].items():shutil.copy2(b/f'{key}-{base:x}.dat',d/f'{key}-{base:x}.dat')
 for q in [a.compiler,TASK/'test_errors.py',TASK/'check_error_images.py',TASK/'errors/frontend.bas',TASK/'errors/integrate.py',TASK/'errors/errors.s',TASK/'errors/report_keywords.inc',TASK/'errors/build_report_keywords.py',TASK/'build/error-runtime/runtime.json']:shutil.copy2(q,d/q.name)
 shutil.copy2(a.log,d/'controller.log');shutil.copy2(ROOT/'.emulator/sdcard/error-repeat.bin',d/'repeat.dat')
 (d/'provenance.json').write_text(json.dumps(dict(snapshot_after_run=True,hashes={str(q):hashlib.sha256(q.read_bytes()).hexdigest() for q in [ROOT/'bin/basic.bin',ROOT/'.emulator/mos_platform.bin',ROOT/'.emulator/fab-agon-emulator.bin']}),indent=2)+'\n')
 (d/'manifest.json').write_text(json.dumps({q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in d.iterdir() if q.name!='manifest.json'},indent=2)+'\n');print('Frozen',d)
if __name__=='__main__':main()
