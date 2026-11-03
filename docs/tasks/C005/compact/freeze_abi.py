"""Freeze one native adapter attempt before any diagnostic change."""
from pathlib import Path
import argparse,hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[4];T=ROOT/'docs/tasks/C005'
p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('--log',type=Path,required=True);p.add_argument('--scope',required=True);a=p.parse_args();d=T/'evidence'/a.name;assert not d.exists();d.mkdir();b=T/'build/compact-abi';rt=T/'build/compact-runtime'
for src,name in [(T/'compact/runtime.s','runtime.s'),(T/'compact/abi.s','abi.s'),(T/'compact/ABI.md','ABI.md'),(T/'compact/test_abi.py','test_abi.py'),(T/'compact/build_runtime.py','build_runtime.py'),(b/'probe.bin','probe.dat'),(b/'probe.lst','probe.lst'),(b/'native.log','native.log'),(rt/'runtime.json','runtime.json'),(rt/'runtime-0.bin','runtime.dat'),(a.log,'controller.log')]:shutil.copy2(src,d/name)
if (b/'results.json').exists() and (b/'results.json').stat().st_mtime>=(b/'probe.bin').stat().st_mtime:shutil.copy2(b/'results.json',d/'results.json')
(d/'SCOPE.md').write_text(a.scope+'\n');(d/'manifest.json').write_text(json.dumps({q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in d.iterdir() if q.name!='manifest.json'},indent=2)+'\n');print(d)
