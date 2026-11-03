"""Compare full error-enabled native runtimes, patched bridges and entry state."""
from pathlib import Path
import json,subprocess
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def u24(blob,offset):return int.from_bytes(blob[offset:offset+3],'little')
def check(build=None,image_pattern="error-{}.bin"):
 b=Path(build) if build is not None else TASK/'build/errors-language';paths={n:ROOT/f'compiler/build/{p}-runtime' for n,p in [('numeric','numeric'),('strings','string'),('control','control'),('procedure','procedure'),('memory','memory')]};paths['error']=TASK/'build/error-runtime'
 optional={n:ROOT/f'compiler/build/{n}-runtime' for n in ['io','data']};allpaths={**paths,**optional}
 meta={n:json.loads((p/'runtime.json').read_text()) for n,p in allpaths.items()};templates={n:(p/'runtime-0.bin').read_bytes() for n,p in allpaths.items()};report=[]
 for i,c in enumerate(json.loads((b/'cases.json').read_text())):
  if 'diagnostic' in c:continue
  data=(ROOT/'.emulator/sdcard'/image_pattern.format(i)).read_bytes();positions={n:data.find(t[:20]) for n,t in templates.items() if n not in ['control','procedure','error'] and (n not in optional or t[:20] in data)}
  positions['control']=data.find(templates['control'][9:15])-9;positions['procedure']=data.find(templates['procedure'][20:28])-20;positions['error']=data.find(templates['error'][:8]);assert min(positions.values())>=0,(i,positions)
  bases={n:0x40000+p for n,p in positions.items()};exports={n:v['exports'] for n,v in meta.items()}
  start=u24(data,1)-0x40000;data_reset=False
  if data[start]==0x21:
   hook=data[start:start+12];assert [hook[j] for j in [0,4,8]]==[0x21,0x22,0xc3];ctx=u24(hook,5)-0x40000;assert u24(data,ctx)==u24(hook,1);assert u24(data,ctx+3)==0x40000+start;start=u24(hook,9)-0x40000;data_reset=True
  hook=data[start:start+26];assert hook[:5]==b'\xcd'+(bases['control']+exports['control']['ctl_init']).to_bytes(3,'little')+b'\xd5';assert hook[5]==0x21 and hook[9]==0x11
  arena=u24(hook,6);limit=u24(hook,10);assert limit-arena==32768 and limit<=0xB0000 and arena>=0x40000+len(data)
  assert hook[13:]==b'\xcd'+(bases['procedure']+exports['procedure']['act_init']).to_bytes(3,'little')+b'\xd1\xcd'+(bases['error']+exports['error']['err_init']).to_bytes(3,'little')+b'\xc3\x45\x00\x04'
  assert data[0x45:0x4e]==bytes.fromhex('F5C5D5DDE5FDE5ED73');savedsp=u24(data,0x4e);assert data[0x51:0x53]==bytes.fromhex('AF32');depth=u24(data,0x53)
  errbase=positions['error'];ex=exports['error'];target=u24(data,errbase+ex['err_exit_slot'])-0x40000;assert data[target:target+5]==bytes.fromhex('21010000C3');exitpos=u24(data,target+5)-0x40000
  assert target==exitpos-12 and data[exitpos-4:exitpos]==bytes.fromhex('21000000');tail=exitpos
  if data[tail:tail+3]==bytes.fromhex('E5AFCD'):
   assert 'io' in bases
   assert data[tail:tail+7]==bytes.fromhex('E5AFCD')+(bases['io']+exports['io']['io_close']).to_bytes(3,'little')+bytes.fromhex('E1');tail+=7
  assert data[tail:tail+5]==b'\xed\x7b'+savedsp.to_bytes(3,'little');assert data[tail+5:tail+13]==bytes.fromhex('FDE1DDE1D1C1F1C9')
  heapctx=0x40000+len(data)-6;assert u24(data,heapctx-0x40000)==0x40000+len(data);assert u24(data,heapctx-0x40000+3)==arena
  fixes={'control':{'ctl_numslot':bases['numeric']+exports['numeric']['rt_numeric']},'procedure':{**{f'act_{k}slot':bases['control']+exports['control'][f'ctl_{k}'] for k in ['push','check','pop']},'act_numslot':bases['numeric']+exports['numeric']['rt_numeric']},'error':{
   'err_ctlpush_slot':bases['control']+exports['control']['ctl_push'],'err_strload_slot':bases['strings']+exports['strings']['rt_strload'],'err_strstore_slot':bases['strings']+exports['strings']['rt_strstore'],'err_exit_slot':0x40000+target,
   'err_cfg_ctltop':bases['control']+exports['control']['ctl_top'],'err_cfg_acttop':bases['procedure']+exports['procedure']['act_top'],'err_cfg_frames':bases['control']+exports['control']['ctl_frames'],'err_cfg_base':arena,'err_cfg_limit':limit,'err_cfg_rootsp':savedsp,'err_cfg_depth':depth,'err_cfg_heap':heapctx}}
  for name in positions:
   path=allpaths[name]
   entry={'numeric':'rt_numeric','strings':'rt_strliteral','control':'ctl_init','procedure':'act_init','memory':'mem_alloc','error':'err_init','io':'io_open','data':'data_peek'}[name];out=b/f'{name}-{bases[name]:x}.dat'
   subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',f'-Ttext=0x{bases[name]:x}','-e',entry,'--oformat=binary','-o',str(out),str(path/'runtime.o')],check=True);expected=bytearray(out.read_bytes())
   for slot,address in fixes.get(name,{}).items():offset=exports[name][slot];expected[offset:offset+3]=address.to_bytes(3,'little')
   assert data[positions[name]:positions[name]+len(expected)]==expected,(i,name)
  report.append(dict(program=i,bases=bases,arena=arena,limit=limit,saved_sp_slot=savedsp,depth_slot=depth,heap_context=heapctx,data_cursor_entry_reset=data_reset,error_and_ACT_bridges_checked=True))
 (b/'runtime-links.json').write_text(json.dumps(report,indent=2)+'\n');print('Complete error-enabled runtime/entry checks:',len(report))
if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser();p.add_argument('--build',type=Path);p.add_argument('--image-pattern',default='error-{}.bin');a=p.parse_args();check(a.build,a.image_pattern)
