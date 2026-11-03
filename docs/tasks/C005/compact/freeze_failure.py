"""Retain a failed source/native integration attempt without stale result claims."""
from pathlib import Path
import argparse,json,hashlib,shutil
R=Path(__file__).resolve().parents[4];T=R/'docs/tasks/C005';p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('--log',type=Path,required=True);p.add_argument('--compiler',type=Path,required=True);p.add_argument('--scope',required=True);a=p.parse_args();d=T/'evidence'/a.name;assert not d.exists();d.mkdir();b=T/'build/output-integration';sd=R/'.emulator/sdcard';cases=json.loads((b/'cases.json').read_text())
for n in ['cases.json','driver.bas','compile.log','reference.bas','reference.log','native.log']:shutil.copy2(b/n,d/n)
for q in [a.compiler,T/'compact/test_frontend.py',T/'compact/integrate.py',T/'compact/frontend.bas',T/'compact/runtime.s',T/'compact/maps_harness.py',T/'compact/check_images.py']:shutil.copy2(q,d/q.name)
shutil.copy2(a.log,d/'controller.log')
for i,c in enumerate(cases):
 shutil.copy2(sd/f'p{i}.bas',d/f'p{i}.bas');shutil.copy2(sd/f'p{i}.bin',d/f'p{i}.dat')
 mp=sd/f'p{i}.bin.map'
 if mp.exists():shutil.copy2(mp,d/f'p{i}.map')
(d/'SCOPE.md').write_text(a.scope+'\n');(d/'manifest.json').write_text(json.dumps({q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in d.iterdir() if q.name!='manifest.json'},indent=2)+'\n')
