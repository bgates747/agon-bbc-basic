"""Package assembled compact native-call runtime as BBC DATA; never compile BASIC source."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[4]
EXPORTS=('cp_literal', 'cp_numeric', 'cp_read1', 'cp_read4', 'cp_read5', 'cp_store1', 'cp_store4', 'cp_store5', 'cp_arrayprefix', 'cp_arrayaddr', 'cp_actsave', 'cp_actbind', 'cp_actbegin', 'cp_num_base', 'cp_str_base', 'cp_slot_numeric', 'cp_slot_numerror', 'cp_slot_literal', 'cp_slot_novar', 'cp_slot_prefix', 'cp_slot_addr', 'cp_slot_memerror', 'cp_slot_save', 'cp_slot_bind', 'cp_slot_begin', 'cp_slot_acterror')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,default=ROOT/'docs/tasks/C005/compact/runtime.s')
    parser.add_argument('--compiler',type=Path)
    parser.add_argument('--output',type=Path,default=ROOT/'docs/tasks/C005/build/compact-runtime')
    args=parser.parse_args()
    source=args.source.resolve(strict=True)
    build=args.output.resolve();build.mkdir(parents=True,exist_ok=True)
    tc=Path('/Agon/agondev/release/bin')
    def run(name,*arguments):return subprocess.check_output([str(tc/name),*map(str,arguments)],text=True)
    obj=build/'runtime.o'
    run('ez80-none-elf-as','-march=ez80+full','-I',source.parent,f'-al={build/"runtime.lst"}','-o',obj,source)
    assert not run('ez80-none-elf-nm','-u',obj).strip()
    syms={f[2]:int(f[0],16) for line in run('ez80-none-elf-nm','-n',obj).splitlines()
          if len(f:=line.split())==3 and f[1] in ('t','T')}
    listing=run('ez80-none-elf-readelf','-r',obj);(build/'relocations.txt').write_text(listing)
    relocations=[]
    for line in listing.splitlines():
        if m:=re.match(r'\s*([0-9a-f]{8})\s+[0-9a-f]{8}\s+(R_Z80_\S+)',line):
            assert m[2]=='R_Z80_24',line
            relocations.append(int(m[1],16))
    assert relocations==sorted(set(relocations))
    fields=[syms[n] for n in EXPORTS[13:]]
    assert fields==sorted(fields) and len(set(fields))==13
    assert not ({i for off in fields for i in range(off,off+3)} & {i for off in relocations for i in range(off,off+3)})
    images={}
    for base in (0,0x42000,0x48000):
        p=build/f'runtime-{base:x}.bin'
        run('ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e','cp_literal','--oformat=binary','-o',p,obj)
        images[base]=p.read_bytes()
    template=images[0]
    for base in (0x42000,0x48000):
        moved=bytearray(template)
        for offset in relocations:
            value=int.from_bytes(template[offset:offset+3],'little');assert 0<=value<len(template)
            moved[offset:offset+3]=(value+base).to_bytes(3,'little')
        assert moved==images[base]
    rows=[','.join(map(str,[len(template),len(relocations),*[syms[n] for n in EXPORTS]]))]
    rows+=['"'+template[i:i+40].hex().upper()+'"' for i in range(0,len(template),40)]
    rows+=[','.join(map(str,relocations[i:i+20])) for i in range(0,len(relocations),20)]
    data='\n'.join(f'{64000+i*10} DATA {row}' for i,row in enumerate(rows))+'\n'
    (build/'runtime_data.bas').write_text(data)
    if args.compiler:
        original=args.compiler.read_text().split('64000 DATA',1)[0]
        args.compiler.write_text(original+data)
    report=dict(bytes=len(template),relocations=len(relocations),exports={n:syms[n] for n in EXPORTS},
                independent_link_bases=[0x42000,0x48000],unresolved_symbols=0,external_bridge_fields={n:syms[n] for n in EXPORTS[13:]},
                hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in [source,build/'runtime_data.bas',build/'runtime-0.bin']})
    (build/'runtime.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))


if __name__=='__main__':main()
