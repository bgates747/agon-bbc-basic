"""Compare actual BBC-emitted maps/adapters with independent GNU runtime links."""
from pathlib import Path
import json,subprocess
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
ALIASES=['$cplit','$cpnum','$cpread1','$cpread4','$cpread5','$cpstore1','$cpstore4','$cpstore5','$cpprefix','$cpaddr','$cpsave','$cpbind','$cpbegin']
TARGETS=['$v0','$s0','$numop','$numerror','$numlit','$novar','$arrayprefix','$arrayaddr','$memerror','$actsave','$actbind','$actbegin','$acterror']
def check(build):
 rt=TASK/'build/compact-runtime';meta=json.loads((rt/'runtime.json').read_text());exports=list(meta['exports']);sd=ROOT/'.emulator/sdcard';cases=json.loads((build/'cases.json').read_text());rows=[]
 for i,c in enumerate(cases):
  if 'diagnostic' in c:continue
  mp=sd/f'p{i}.bin.map';pairs=[line.split('=',1) for line in mp.read_text().splitlines()];symbols={name:int(value) for name,value in pairs};assert len(symbols)==len(pairs);(build/f'p{i}.map').write_bytes(mp.read_bytes())
  if ALIASES[0] not in symbols:continue
  assert symbols['$zero']==0
  base=symbols[ALIASES[0]]-meta['exports'][exports[0]]
  for boundary in ['$sheap','$actbase']:
   if boundary in symbols:assert base+meta['bytes']<=symbols[boundary],(i,'adapter overlaps workspace',boundary)
  for alias,name in zip(ALIASES,exports[:13]):assert symbols[alias]==base+meta['exports'][name],(i,alias)
  target=build/f'compact-{base:x}.dat';subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e','cp_literal','--oformat=binary','-o',str(target),str(rt/'runtime.o')],check=True)
  wanted=bytearray(target.read_bytes());bridges={}
  for name,destination in zip(exports[13:],TARGETS):
   address=symbols.get(destination,0);offset=meta['exports'][name];wanted[offset:offset+3]=address.to_bytes(3,'little');bridges[name]=dict(target=destination,address=address)
  target.write_bytes(wanted);image=(sd/f'p{i}.bin').read_bytes();offset=base-0x40000;assert offset>=0 and image[offset:offset+len(wanted)]==wanted,(i,'compact runtime/bridge mismatch')
  rows.append(dict(program=i,base=base,bytes=len(wanted),bridges=bridges))
 assert rows,'This cohort must exercise an actual emitted compact module'
 (build/'compact-links.json').write_text(json.dumps(rows,indent=2)+'\n');print('Independent compact modules:',[(r['program'],hex(r['base'])) for r in rows]);return rows
