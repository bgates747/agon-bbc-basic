"""Package assembled control runtime as BBC DATA; never compile BASIC source."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
EXPORTS=('ctl_init','ctl_push','ctl_check','ctl_pop','ctl_until','ctl_again','ctl_for','ctl_next','ctl_numslot','ctl_top','ctl_frames','ctl_frames_end')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,default=ROOT/'compiler/runtime/control.s')
    parser.add_argument('--compiler',type=Path)
    parser.add_argument('--output',type=Path,default=ROOT/'compiler/build/control-runtime')
    args=parser.parse_args()
    source=args.source.resolve(strict=True)
    build=args.output.resolve();build.mkdir(parents=True,exist_ok=True)
    tc=Path('/Agon/agondev/release/bin')
    def run(name,*arguments):return subprocess.check_output([str(tc/name),*map(str,arguments)],text=True)
    obj=build/'runtime.o'
    run('ez80-none-elf-as','-march=ez80+full',f'-al={build/"runtime.lst"}','-o',obj,source)
    assert not run('ez80-none-elf-nm','-u',obj).strip()
    syms={f[2]:int(f[0],16) for line in run('ez80-none-elf-nm','-n',obj).splitlines()
          if len(f:=line.split())==3 and f[1] in ('t','T')}
    listing=run('ez80-none-elf-readelf','-r',obj);(build/'relocations.txt').write_text(listing)
    relocations=[]
    for line in listing.splitlines():
        if m:=re.match(r'\s*([0-9a-f]{8})\s+[0-9a-f]{8}\s+(R_Z80_\S+)',line):
            assert m[2]=='R_Z80_24',line
            relocations.append(int(m[1],16))
    images={}
    for base in (0,0x42000,0x48000):
        p=build/f'runtime-{base:x}.bin'
        run('ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e','ctl_init','--oformat=binary','-o',p,obj)
        images[base]=p.read_bytes()
    template=images[0]
    for base in (0x42000,0x48000):
        moved=bytearray(template)
        for offset in relocations:
            value=int.from_bytes(template[offset:offset+3],'little');assert 0<=value<=len(template)
            moved[offset:offset+3]=(value+base).to_bytes(3,'little')
        assert moved==images[base]
    rows=[','.join(map(str,[len(template),len(relocations),*[syms[n] for n in EXPORTS]]))]
    rows+=['"'+template[i:i+40].hex().upper()+'"' for i in range(0,len(template),40)]
    rows+=[','.join(map(str,relocations[i:i+20])) for i in range(0,len(relocations),20)]
    data='\n'.join(f'{40000+i*10} DATA {row}' for i,row in enumerate(rows))+'\n'
    (build/'runtime_data.bas').write_text(data)
    prefix=syms['ctl_frames']
    assert syms['ctl_frames_end']==len(template)
    assert template[prefix:]==bytes(len(template)-prefix)
    assert all(off+3<=prefix for off in relocations)
    assert syms['ctl_numslot']+3<=prefix
    prefix_rows=[rows[0]]
    prefix_rows+=['"'+template[i:min(i+40,prefix)].hex().upper()+'"' for i in range(0,prefix,40)]
    prefix_rows+=[','.join(map(str,relocations[i:i+20])) for i in range(0,len(relocations),20)]
    prefix_data='\n'.join(f'{40000+i*10} DATA {row}' for i,row in enumerate(prefix_rows))+'\n'
    (build/'prefix_data.bas').write_text(prefix_data)
    selected=data
    if args.compiler and 'DIM timage% tframes%-1' in args.compiler.read_text():selected=prefix_data
    if args.compiler:
        original,previous=args.compiler.read_text().split('40000 DATA',1)
        procedures='50000 DATA'+previous.split('50000 DATA',1)[1] if '50000 DATA' in previous else ''
        args.compiler.write_text(original+selected+procedures)
    report=dict(bytes=len(template),relocations=len(relocations),exports={n:syms[n] for n in EXPORTS},
                independent_link_bases=[0x42000,0x48000],unresolved_symbols=0,
                hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in [source,build/'runtime_data.bas',build/'prefix_data.bas',build/'runtime-0.bin']})
    (build/'runtime.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))


if __name__=='__main__':main()
