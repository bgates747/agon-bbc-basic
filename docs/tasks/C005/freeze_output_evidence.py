"""Retain current qualification artifacts explicitly, excluding stale build snapshots."""
from pathlib import Path
import argparse,hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def main():
 p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('--script',required=True,type=Path);p.add_argument('--log',required=True,type=Path);p.add_argument('--compiler',type=Path,default=TASK/'compiler.bas');a=p.parse_args()
 d=TASK/'evidence'/a.name;assert not d.exists();d.mkdir(parents=True)
 b=TASK/'build/output-integration';cases=json.loads((b/'cases.json').read_text());report=json.loads((b/'results.json').read_text())
 assert len(cases)==report['programs']
 shutil.copy2(a.compiler,d/'compiler.bas');shutil.copy2(a.script,d/a.script.name);shutil.copy2(a.log,d/'controller.log')
 for n in ['cases.json','driver.bas','reference.bas','reference.log','compile.log','native.log','results.json']:
  shutil.copy2(b/n,d/n)
 for i,c in enumerate(cases):
  if 'diagnostic' not in c:shutil.copy2(ROOT/'.emulator/sdcard'/f'p{i}.bin',d/f'p{i}.dat')
 shutil.copy2(ROOT/'.emulator/sdcard/output-repeat.bin',d/'repeat.dat')
 for prefix,key in [('runtime','independent_link_bases'),('strings','string_link_bases')]:
  for base in set(report[key]):shutil.copy2(b/f'{prefix}-{base:x}.bin',d/f'{prefix}-{base:x}.dat')
 for module in ['io','memory']:
  link=b/(module+'-links.json')
  if link.is_file() and link.stat().st_mtime>=(b/'cases.json').stat().st_mtime:
   shutil.copy2(link,d/link.name)
   for row in json.loads(link.read_text()):
    q=b/f'{module}-{row["base"]:x}.dat'
    if not q.exists():q=q.with_suffix('.bin')
    shutil.copy2(q,d/(q.stem+'.dat'))
 (d/'manifest.json').write_text(json.dumps({x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in d.iterdir() if x.name!='manifest.json'},indent=2)+'\n')
 print('Frozen',d)
if __name__=='__main__':main()
