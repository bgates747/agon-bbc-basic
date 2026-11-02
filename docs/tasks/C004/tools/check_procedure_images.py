"""Check assembled runtime relocation/bridges and native entry workspace."""
from pathlib import Path
import json,subprocess
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C004'
def check(limit=None,procedure_runtime=None,case_indices=None):
 build=TASK/'build/output-integration';sd=ROOT/'.emulator/sdcard'
 paths={'numeric':ROOT/'compiler/build/numeric-runtime','control':ROOT/'compiler/build/control-runtime','procedure':ROOT/'compiler/build/procedure-runtime'}
 if procedure_runtime is not None:paths['procedure']=Path(procedure_runtime).resolve(strict=True)
 if not paths['procedure'].exists():paths['procedure']=TASK/'build/procedure-runtime'
 metadata={name:json.loads((p/'runtime.json').read_text()) for name,p in paths.items()}
 templates={name:(p/'runtime-0.bin').read_bytes() for name,p in paths.items()};bases=[]
 for i,case in enumerate(json.loads((build/'cases.json').read_text())[:limit]):
  if case_indices is not None and i not in case_indices:continue
  if 'diagnostic' in case:continue
  image=(sd/f'p{i}.bin').read_bytes();numpos=image.find(templates['numeric'][:20]);controlpos=image.find(templates['control'][9:15])-9;actpos=image.find(templates['procedure'][20:28])-20
  assert min(numpos,controlpos,actpos)>=0,(i,numpos,controlpos,actpos)
  numbase=0x40000+numpos;controlbase=0x40000+controlpos;actbase=0x40000+actpos
  for name,pos,base in [('control',controlpos,controlbase),('procedure',actpos,actbase)]:
   p=build/f'{name}-verified-{base:x}.dat'
   subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e', 'ctl_init' if name=='control' else 'act_init','--oformat=binary','-o',str(p),str(paths[name]/'runtime.o')],check=True)
   expected=bytearray(p.read_bytes());exports=metadata[name]['exports'];numaddr=numbase+metadata['numeric']['exports']['rt_numeric']
   if name=='control':fixups={'ctl_numslot':numaddr}
   else:fixups={**{f'act_{n}slot':controlbase+metadata['control']['exports'][f'ctl_{n}'] for n in ['push','check','pop']},'act_numslot':numaddr}
   for slot,addr in fixups.items():offset=exports[slot];expected[offset:offset+3]=addr.to_bytes(3,'little')
   assert image[pos:pos+len(expected)]==expected,(i,name,pos)
  start=int.from_bytes(image[1:4],'little')-0x40000;hook=image[start:start+22]
  assert hook[:5]==b'\xcd'+(controlbase+metadata['control']['exports']['ctl_init']).to_bytes(3,'little')+b'\xd5'
  assert hook[5]==0x21 and hook[9]==0x11
  arena=int.from_bytes(hook[6:9],'little');limit=int.from_bytes(hook[10:13],'little')
  assert arena>=0x40000+len(image) and limit-arena==32768 and limit<=0xB0000
  assert hook[13:]==b'\xcd'+(actbase+metadata['procedure']['exports']['act_init']).to_bytes(3,'little')+b'\xd1\xc3\x45\x00\x04'
  bases.append(dict(case=i,numeric=numbase,control=controlbase,procedure=actbase,arena=arena,limit=limit))
 report=dict(independent_control_and_procedure_links=bases,all_external_bridges_checked=True,entry_reset_and_workspace_checked=True)
 (build/'procedure-links.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':
 import argparse
 parser=argparse.ArgumentParser();parser.add_argument('--limit',type=int);parser.add_argument('--procedure-runtime',type=Path);args=parser.parse_args();check(args.limit,args.procedure_runtime)
