"""Compare physical native scalar storage with actual BASIC variable bytes.

BASIC supplies payload expectations and the compiler's symbol map. Python only
orchestrates, extracts byte ranges and checks flags/guards/relocation.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import time

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cli',required=True,type=Path)
    parser.add_argument('--compiler',type=Path,default=TASK/'scalar/compiler.bas')
    args=parser.parse_args()
    compiler=args.compiler.resolve(strict=True)
    original=compiler.read_bytes()
    spec=importlib.util.spec_from_file_location('harness',ROOT/'compiler/tools/test_compiler.py')
    harness=importlib.util.module_from_spec(spec);spec.loader.exec_module(harness)
    profile=ROOT/'.emulator';sd=profile/'sdcard';build=TASK/'build/storage';build.mkdir(parents=True,exist_ok=True)
    assert (profile/'fab-agon-emulator.bin').resolve()==args.cli.resolve(strict=True)
    started=time.monotonic()
    assignments=[
        'integer=1','floating=1.0','fraction=1/3','copy=fraction',
        'large=4294967296.0','positive%=&7FFFFFFF','negative%=&80000000',
        'byte&=-1.5','fraction%=-7/2','A%=-1','fresh=fresh+1',
        'upper=1:UPPER=2:upper%=3:upper&=4','_test9=5',
        'floatcopy=floating','converted%=floating','small&=321','Z%=Z%',
    ]
    bindings=[('integer',5),('floating',5),('fraction',5),('copy',5),('large',5),
              ('positive%',4),('negative%',4),('byte&',1),('fraction%',4),
              ('A%',4),('fresh',5),('upper',5),('UPPER',5),('upper%',4),('upper&',1),
              ('_test9',5),('floatcopy',5),('converted%',4),('small&',1),('Z%',4)]
    prefix='\n'.join(f'{10+i*10} {line}' for i,line in enumerate(assignments))+'\n'
    # Identical conventional control flow: unreachable read creates no binding.
    prefix+='900 GOTO 1000\n910 PRINT ;never\n'
    source=prefix+'1000 END\n'
    (build/'source.bas').write_text(source);(sd/'scalar-storage.bas').write_text(source)
    reference=prefix+'1000 PROCcapture:OSCLI "BYE"\n'
    reference+='2000 DEF PROCcapture:LOCAL ch%,p%,i%\n2010 ch%=OPENOUT("scalar-expected.dat")\n'
    for i,(name,size) in enumerate(bindings):
        reference+=f'{2020+i*10} p%=^{name}:FOR i%=0 TO {size-1}:BPUT#ch%,p%?i%:NEXT\n'
    # Z%=Z% checks a predefined static read before the assignment completes.
    reference+='4000 CLOSE#ch%:PRINT "STORAGE_REFERENCE_DONE":ENDPROC\n'
    (build/'reference.bas').write_text(reference);(sd/'scalar-storage-reference.bas').write_text(reference)
    ref=harness.run_profile(profile,'load /bin/basic.bin\nrun . /scalar-storage-reference.bas\n',
                            'STORAGE_REFERENCE_DONE','scalar-storage-reference.log')
    (build/'reference.log').write_text(ref)
    expected=(sd/'scalar-expected.dat').read_bytes();assert len(expected)==sum(size for _,size in bindings)
    (build/'expected.dat').write_bytes(expected)
    definitions=original.decode().split('1000 DEF',1)[1]
    before,after=definitions.split('20000 DATA',1)
    driver='''10 PROCinit
20 PROCcompile("scalar-storage.bas","scalar-storage.bin")
30 mh%=OPENOUT("scalar-layout.txt")
40 FOR vi%=0 TO cvnum%-1
50 vs$="$var"+STR$(vi%):bs$="$bind"+STR$(vi%)
60 map$=cvname$(vi%)+"|"+STR$(cvsize%(vi%))+"|"+STR$(csaddr%(FNsymbol(vs$)))+"|"+STR$(csaddr%(FNsymbol(bs$)))
70 FOR mi%=1 TO LEN(map$):BPUT#mh%,ASC(MID$(map$,mi%,1)):NEXT:BPUT#mh%,10
80 NEXT
81 FOR vi%=0 TO cnslots%-1
82 vs$="$v"+STR$(vi%):map$=vs$+"|5|"+STR$(csaddr%(FNsymbol(vs$)))+"|0":PROCmap
83 NEXT
84 map$="$savedsp|3|"+STR$(csaddr%(FNsymbol("$savedsp")))+"|0":PROCmap
85 CLOSE#mh%:PRINT "STORAGE_COMPILE_DONE":OSCLI "BYE"
900 DEF PROCmap
910 FOR mi%=1 TO LEN(map$):BPUT#mh%,ASC(MID$(map$,mi%,1)):NEXT:BPUT#mh%,10:ENDPROC
'''
    driver+='1000 DEF'+before+'20000 DATA'+after
    (build/'driver.bas').write_text(driver);(sd/'scalar-storage-driver.bas').write_text(driver)
    compiled=harness.run_profile(profile,'load /bin/basic.bin\nrun . /scalar-storage-driver.bas\n',
                                 'STORAGE_COMPILE_DONE','scalar-storage-compile.log',180)
    (build/'compile.log').write_text(compiled)
    image=(sd/'scalar-storage.bin').read_bytes();(build/'compiled.bin').write_bytes(image)
    layout=(sd/'scalar-layout.txt').read_text();(build/'layout.txt').write_text(layout)
    native=harness.run_profile(profile,
        f'try /scalar-storage.bin\necho STORAGE_STATUS:<Try$ReturnCode>\nsave /scalar-native.dat 262144 {len(image)}\necho STORAGE_NATIVE_DONE\n',
        'STORAGE_NATIVE_DONE','scalar-storage-native.log')
    (build/'native.log').write_text(native);assert 'STORAGE_STATUS:0\n' in native,native
    memory=(sd/'scalar-native.dat').read_bytes();assert len(memory)==len(image),(len(memory),len(image))
    (build/'native.dat').write_bytes(memory)
    actual={name:(int(size),int(address)-0x40000,int(flag)-0x40000)
            for name,size,address,flag in (line.split('|') for line in layout.splitlines())}
    cursor=0;records=[];mutable=set()
    for name,size in bindings:
        width,address,flag=actual[name];assert width==size,(name,width,size)
        wanted=expected[cursor:cursor+size];got=memory[address:address+size];cursor+=size
        assert got==wanted,(name,wanted.hex(),got.hex())
        assert memory[flag]==1,(name,memory[flag])
        mutable.update(range(address,address+size));mutable.add(flag)
        records.append(dict(name=name,size=size,expected=wanted.hex(),actual=got.hex(),offset=address))
    width,address,flag=actual['never'];assert width==5 and memory[flag]==0
    assert memory[address:address+5]==bytes(5)
    for name,(width,address,flag) in actual.items():
        if name.startswith('$'):mutable.update(range(address,address+width))
    unexpected=[i for i,(a,b) in enumerate(zip(image,memory)) if i not in mutable and a!=b]
    assert not unexpected,('unexpected writes outside scalar/temp/saved-stack storage',unexpected)
    runtime=ROOT/'compiler/build/numeric-runtime';template=(runtime/'runtime-0.bin').read_bytes()
    position=image.index(template[:20]);base=0x40000+position;linked=build/'runtime.bin'
    subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e','rt_numeric',
                    '--oformat=binary','-o',str(linked),str(runtime/'runtime.o')],check=True)
    assert image[position:position+len(template)]==linked.read_bytes()
    assert compiler.read_bytes()==original
    report=dict(bindings=len(bindings),undefined_bindings=1,packed_mismatches=0,
                unexpected_memory_writes=0,independent_runtime_link_base=base,
                records=records,duration_seconds=round(time.monotonic()-started,3),
                hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in [compiler,ROOT/'bin/basic.bin',build/'source.bas',build/'expected.dat',build/'native.dat']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()
