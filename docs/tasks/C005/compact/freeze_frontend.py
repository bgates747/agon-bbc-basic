"""Freeze completed source/native qualification plus BBC maps and GNU adapter links."""
from pathlib import Path
import argparse,hashlib,json,shutil,subprocess
ROOT=Path(__file__).resolve().parents[4];T=ROOT/'docs/tasks/C005';p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('--compiler',type=Path,required=True);p.add_argument('--script',type=Path,required=True);p.add_argument('--log',type=Path,required=True);a=p.parse_args()
subprocess.run([str(ROOT/'.venv/bin/python'),str(T/'freeze_output_evidence.py'),a.name,'--compiler',str(a.compiler),'--script',str(a.script),'--log',str(a.log)],check=True)
d=T/'evidence'/a.name;b=T/'build/output-integration'
cases=json.loads((b/'cases.json').read_text())
for i,c in enumerate(cases):
 if 'diagnostic' not in c:
  q=b/f'p{i}.map';assert q.stat().st_mtime>=(b/'cases.json').stat().st_mtime;shutil.copy2(q,d/q.name)
link=b/'compact-links.json';shutil.copy2(link,d/link.name)
for row in json.loads(link.read_text()):shutil.copy2(b/f'compact-{row["base"]:x}.dat',d/f'compact-{row["base"]:x}.dat')
for q in [T/'compact/runtime.s',T/'compact/ABI.md',T/'compact/build_runtime.py',T/'compact/frontend.bas',T/'compact/integrate.py',T/'compact/maps_harness.py',T/'compact/check_images.py',T/'build/compact-runtime/runtime.json']:shutil.copy2(q,d/q.name)
(d/'manifest.json').write_text(json.dumps({q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in d.iterdir() if q.name!='manifest.json'},indent=2)+'\n')
