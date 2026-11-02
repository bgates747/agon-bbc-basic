"""Inspect DATA cursor entry reset and complete memory/control/activation links."""
from pathlib import Path
import importlib.util,json,subprocess
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def data_entry(image,start):
 hook=image[start:start+12]
 assert len(hook)==12 and [hook[i] for i in (0,4,8)]==[0x21,0x22,0xc3],(start,hook.hex())
 begin=int.from_bytes(hook[1:4],'little');ctx=int.from_bytes(hook[5:8],'little')-0x40000;old=int.from_bytes(hook[9:12],'little')-0x40000
 assert 0<=ctx<len(image)-5 and 0<=old<len(image)
 assert int.from_bytes(image[ctx:ctx+3],'little')==begin
 end=int.from_bytes(image[ctx+3:ctx+6],'little')
 assert 0x40000<=begin<=end==0x40000+start
 return old
def main():
 b=TASK/'build/output-integration';sd=ROOT/'.emulator/sdcard';mt=ROOT/'compiler/build/memory-runtime';template=(mt/'runtime-0.bin').read_bytes();act=(ROOT/'compiler/build/procedure-runtime/runtime-0.bin').read_bytes();memory=[];indices=[];entries=[]
 for i,c in enumerate(json.loads((b/'cases.json').read_text())):
  if 'diagnostic' in c:continue
  data=(sd/f'p{i}.bin').read_bytes();start=int.from_bytes(data[1:4],'little')-0x40000;old=data_entry(data,start);entries.append(dict(program=i,data_reset=0x40000+start,next_entry=0x40000+old))
  pos=data.find(template[:20])
  if pos>=0:
   base=0x40000+pos;p=b/f'memory-{base:x}.dat';subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e','mem_alloc','--oformat=binary','-o',str(p),str(mt/'runtime.o')],check=True);assert data[pos:pos+len(template)]==p.read_bytes();memory.append(dict(program=i,base=base,bytes=len(template)))
  if data.find(act[20:28])>=20:indices.append(i)
 assert memory and indices
 (b/'memory-links.json').write_text(json.dumps(memory,indent=2)+'\n');(b/'data-entry.json').write_text(json.dumps(entries,indent=2)+'\n')
 c=module('activation',ROOT/'docs/tasks/C004/tools/check_procedure_images.py');c.TASK=TASK;c.check(case_indices=indices,entry_resolver=data_entry)
 print('DATA entry resets:',len(entries),'memory links:',len(memory),'activation images:',indices)
if __name__=='__main__':main()
