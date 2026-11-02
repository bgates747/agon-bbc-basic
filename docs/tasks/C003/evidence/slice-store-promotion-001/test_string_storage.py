"""Compare string contents against BASIC and check native heap/descriptor guards.

Python extracts bytes and checks bounds; BBC BASIC supplies all string values.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import time

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cli',required=True,type=Path)
    parser.add_argument('--compiler',type=Path,default=ROOT/'compiler/compiler.bas')
    parser.add_argument('--slices',action='store_true',help='also qualify sliced contents and packed relations')
    parser.add_argument('--conversions',action='store_true',help='qualify raw VAL records and STR$/ASC values')
    parser.add_argument('--search-repeat',action='store_true',help='qualify INSTR records and STRING$ contents')
    parser.add_argument('--slice-store',action='store_true',help='qualify slice assignment bytes and allocation')
    parser.add_argument('--numeric-runtime',type=Path,default=ROOT/'compiler/build/numeric-runtime')
    args=parser.parse_args();compiler=args.compiler.resolve(strict=True);original=compiler.read_bytes()
    spec=importlib.util.spec_from_file_location('harness',ROOT/'compiler/tools/test_compiler.py')
    h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
    profile=ROOT/'.emulator';sd=profile/'sdcard';build=TASK/('build/slice-store-storage' if args.slice_store else 'build/search-repeat-storage' if args.search_repeat else 'build/conversion-storage' if args.conversions else 'build/slice-storage' if args.slices else 'build/string-storage');build.mkdir(parents=True,exist_ok=True)
    assert (profile/'fab-agon-emulator.bin').resolve()==args.cli.resolve(strict=True)
    started=time.monotonic()
    assignments=['empty$=""','zero$=CHR$(0)+"x"+CHR$(255)','original$="hello"',
                 'copy$=original$','original$="z"','copy$=copy$',
                 'tail$="a"','tail$=tail$+"bc"','block$="q"','tail$=tail$+"def"',
                 'tail$=""','tail$="xy"','Case$="UP"','case$="low"',
                 'fresh$=fresh$+"new"','left$="'+('l'*128)+'"',
                 'right$="'+('r'*127)+'"','maximum$=left$+right$',
                 'independent$=maximum$','maximum$="m"','length%=LEN(independent$)']
    # Force repeated non-tail growth, tail growth, shrinking and reassignment.
    for n in (1,2,4,8,16,32,64,128,255):
        assignments += ['churn$=""','churn$=left$'] if n==128 else []
        if n==255:
            assignments += ['churn$=left$+right$']
        else:
            assignments += ['churn$="'+('c'*n)+'"']
        assignments += ['barrier$="b"','barrier$=barrier$+"b"']
    names=['empty$','zero$','original$','copy$','tail$','block$','Case$','case$',
           'fresh$','left$','right$','maximum$','independent$','churn$','barrier$']
    numbers=[]
    assert sum([args.slices,args.conversions,args.search_repeat,args.slice_store])<=1
    if args.slice_store:
        assignments=['defaultleft$="abcdef":LEFT$(defaultleft$)="XYZ"',
                     'rightshort$="abcdef":RIGHT$(rightshort$,5)="XY"',
                     'midzero$="abcdef":MID$(midzero$,0,2)="YZ"',
                     'lastmarker$=STRING$(255,"x"):MID$(lastmarker$,255,2)="YZ"',
                     'clamped$=STRING$(255,"x"):MID$(clamped$,255,3)="YZ"',
                     'allbutlast$=STRING$(255,"x"):MID$(allbutlast$,2,255)=STRING$(255,"z")',
                     'alias$="abcdef":MID$(alias$,2,3)=alias$',
                     'bytes$=CHR$(0)+CHR$(128)+CHR$(255):copy$=bytes$',
                     'MID$(bytes$,2,1)=CHR$(0):LEFT$(bytes$,1)=CHR$(128)',
                     'empty$="":RIGHT$(empty$,3)=CHR$(255)',
                     'nop$="abc":LEFT$(nop$,0)=STRING$(1,"Y")',
                     'length%=LEN allbutlast$:first%=ASC bytes$:last%=ASC RIGHT$(clamped$)']
        names=['defaultleft$','rightshort$','midzero$','lastmarker$','clamped$',
               'allbutlast$','alias$','bytes$','copy$','empty$','nop$']
        numbers=[('length%',4),('first%',4),('last%',4)]
    if args.search_repeat:
        assignments=['pattern$=CHR$(0)+CHR$(128)+CHR$(255)',
                     'repeated$=STRING$(3,pattern$)','full$=STRING$(85,pattern$)',
                     'empty$=STRING$(0,pattern$)','wrapped$=STRING$(257,"ab")',
                     'negative$=STRING$(-1,"x")','fraction$=STRING$(2.9,"ab")',
                     'nested$=STRING$(2,STRING$(3,"xy"))','copy$=repeated$',
                     'repeated$=STRING$(2,"q")','created$=STRING$(2,created$+"z")',
                     'text$=STRING$(3,"12")','converted$=STR$ INSTR("abc","b")']
        names=['pattern$','repeated$','full$','empty$','wrapped$','negative$',
               'fraction$','nested$','copy$','created$','text$','converted$']
        expressions=['INSTR(full$,pattern$)','INSTR(full$,pattern$,2)',
                     'INSTR(full$,pattern$,253)','INSTR(full$,pattern$,254)',
                     'INSTR(full$,CHR$(255),255)','INSTR(full$,"")','INSTR("",pattern$)',
                     'INSTR(negative$,"x",-1)','INSTR(negative$,"x",256)',
                     'INSTR("aaaaab","aaab")','INSTR("abc","z")',
                     'INSTR(nested$,"xy",INSTR("123","2"))','VAL text$']
        for i,expression in enumerate(expressions):
            name=f'result{i}';assignments.append(f'{name}={expression}');numbers.append((name,5))
        assignments+=['position%=INSTR(full$,CHR$(255),255)',
                      'byte&=INSTR(full$,CHR$(255),255)','length%=LEN full$']
        numbers += [('position%',4),('byte&',1),('length%',4)]
    if args.conversions:
        assert not args.slices
        assignments=['empty$=STR$(0)','zero$=STR$ ASC CHR$(0)',
                     'third$=STR$(1/3)','large$=STR$(1E38)','small$=STR$(1E-38)',
                     'negative$=STR$(-1/3)','hexzero$=STR$~0','hexmax$=STR$~&FFFFFFFF',
                     'hexmin$=STR$~&80000000','nested$=STR$ VAL "12.5"',
                     'left$="'+(' '*128)+'"','right$="'+(' '*125)+'12"',
                     'maximum$=left$+right$','copy$=nested$','nested$=STR$~(-12.9)']
        names=['empty$','zero$','third$','large$','small$','negative$',
               'hexzero$','hexmax$','hexmin$','nested$','left$','right$','maximum$','copy$']
        for i,text in enumerate(['0','-0','1.0','-1.0','2147483647','2147483648',
                                 '4294967295','4294967296','-2147483648','1.234567890123456789',
                                 '1E-38','1E-99','1E 2','1E+ 2','1e2','&FF','words']):
            name=f'value{i}'
            assignments.append(f'{name}=VAL("{text}")');numbers.append((name,5))
        assignments+=['maximumval=VAL maximum$','nulval=VAL("12"+CHR$(0)+"34")',
                      'asempty%=ASC ""','ashigh%=ASC CHR$(255)','asnul%=ASC CHR$(0)']
        numbers += [('maximumval',5),('nulval',5),('asempty%',4),('ashigh%',4),('asnul%',4)]
    if args.slices:
        assignments += ['full$=left$+right$','cutleft$=LEFT$(full$,129)',
                        'cutright$=RIGHT$(full$,128)','cutmid$=MID$(full$,128,3)',
                        'lowzero$=LEFT$(zero$,1)','wrap$=MID$(full$,256,257)',
                        'chained$=RIGHT$(MID$(full$,128),2)','emptycut$=RIGHT$(full$,0)',
                        'cmpresult%=((full$=left$+right$)AND(LEFT$(full$,128)=left$))']
        names += ['full$','cutleft$','cutright$','cutmid$','lowzero$','wrap$','chained$','emptycut$']
    prefix='\n'.join(f'{10+i*10} {line}' for i,line in enumerate(assignments))+'\n'
    prefix+='900 GOTO 1000\n910 PRINT missing$\n'
    source=prefix+'1000 END\n';(build/'source.bas').write_text(source);(sd/'string-storage.bas').write_text(source)
    reference=prefix+'1000 PROCcapture:OSCLI "BYE"\n'
    reference+='2000 DEF PROCcapture:LOCAL ch%,p%,q%,i%,n%\n2010 ch%=OPENOUT("string-expected.dat")\n'
    for i,name in enumerate(names):
        reference+=f'{2020+i*10} p%=^{name}:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT\n'
    for i,(name,size) in enumerate(numbers):
        reference+=f'{3000+i*10} p%=^{name}:FOR i%=0 TO {size-1}:BPUT#ch%,p%?i%:NEXT\n'
    reference+='4000 CLOSE#ch%:PRINT "STRING_STORAGE_REFERENCE_DONE":ENDPROC\n'
    (build/'reference.bas').write_text(reference);(sd/'string-storage-reference.bas').write_text(reference)
    log=h.run_profile(profile,'load /bin/basic.bin\nrun . /string-storage-reference.bas\n',
                      'STRING_STORAGE_REFERENCE_DONE','string-storage-reference.log')
    (build/'reference.log').write_text(log);expected=(sd/'string-expected.dat').read_bytes();(build/'expected.dat').write_bytes(expected)
    driver='''10 PROCinit
20 PROCcompile("string-storage.bas","string-storage.bin")
30 mh%=OPENOUT("string-layout.txt")
40 FOR vi%=0 TO cvnum%-1
50 vs$="$var"+STR$(vi%):bs$="$bind"+STR$(vi%)
60 map$=cvname$(vi%)+"|"+STR$(cvsize%(vi%))+"|"+STR$(csaddr%(FNsymbol(vs$)))+"|"+STR$(csaddr%(FNsymbol(bs$)))
70 PROCmap
80 NEXT
81 FOR vi%=0 TO cnslots%-1
82 vs$="$v"+STR$(vi%):map$=vs$+"|5|"+STR$(csaddr%(FNsymbol(vs$)))+"|0":PROCmap
83 NEXT
84 FOR vi%=0 TO csslots%-1
85 vs$="$s"+STR$(vi%):map$=vs$+"|256|"+STR$(csaddr%(FNsymbol(vs$)))+"|0":PROCmap
86 NEXT
87 map$="$savedsp|3|"+STR$(csaddr%(FNsymbol("$savedsp")))+"|0":PROCmap
88 map$="$sheapctx|6|"+STR$(csaddr%(FNsymbol("$sheapctx")))+"|0":PROCmap
89 map$="$sheap|"+STR$(1024*csvars%)+"|"+STR$(csaddr%(FNsymbol("$sheap")))+"|0":PROCmap
90 CLOSE#mh%:PRINT "STRING_STORAGE_COMPILE_DONE":OSCLI "BYE"
900 DEF PROCmap
910 FOR mi%=1 TO LEN(map$):BPUT#mh%,ASC(MID$(map$,mi%,1)):NEXT:BPUT#mh%,10:ENDPROC
'''
    if args.conversions or args.search_repeat:
        runtime=json.loads((args.numeric_runtime/'runtime.json').read_text())
        scratch=runtime['scratch']['val_text']
        delta=scratch['offset']-runtime['exports']['rt_numeric']
        # Layout of the only mutable private VAL scratch, derived from assembly
        # symbols and the BBC compiler's own link map, never a Python compiler.
        driver=driver.replace('90 CLOSE#',f'90 map$="$numscratch|256|"+STR$(csaddr%(FNsymbol("$numop"))+({delta}))+"|0":PROCmap\n91 CLOSE#')
    driver+='1000 DEF'+original.decode().split('1000 DEF',1)[1]
    (build/'driver.bas').write_text(driver);(sd/'string-storage-driver.bas').write_text(driver)
    log=h.run_profile(profile,'load /bin/basic.bin\nrun . /string-storage-driver.bas\n',
                      'STRING_STORAGE_COMPILE_DONE','string-storage-compile.log',180)
    (build/'compile.log').write_text(log);image=(sd/'string-storage.bin').read_bytes();(build/'compiled.dat').write_bytes(image)
    layout=(sd/'string-layout.txt').read_text();(build/'layout.txt').write_text(layout)
    actual={name:(int(size),int(addr)-0x40000,int(flag)-0x40000)
            for name,size,addr,flag in (line.split('|') for line in layout.splitlines())}
    budget,heap,_=actual['$sheap'];assert heap==len(image),(heap,len(image))
    canary=bytes([0xa5])*(budget+32);(sd/'string-heap-init.dat').write_bytes(canary)
    # MOS SAVE can retain a longer existing file's tail. A fresh capture must
    # have exactly the requested extent, independent of an earlier suite.
    (sd/'string-native.dat').unlink(missing_ok=True)
    log=h.run_profile(profile,
        f'load /string-heap-init.dat {0x40000+heap}\ntry /string-storage.bin\necho STRING_STORAGE_STATUS:<Try$ReturnCode>\nsave /string-native.dat 262144 {len(image)+len(canary)}\necho STRING_STORAGE_NATIVE_DONE\n',
        'STRING_STORAGE_NATIVE_DONE','string-storage-native.log')
    (build/'native.log').write_text(log);assert 'STRING_STORAGE_STATUS:0\n' in log,log
    memory=(sd/'string-native.dat').read_bytes();(build/'native.dat').write_bytes(memory)
    assert len(memory)==len(image)+len(canary)
    cursor=0;records=[];mutable=set();allocations=[]
    for name in names:
        width,offset,flag=actual[name];assert width==5 and memory[flag]==1
        length,capacity=memory[offset:offset+2];pointer=int.from_bytes(memory[offset+2:offset+5],'little')-0x40000
        wanted_length=expected[cursor];cursor+=1;wanted=expected[cursor:cursor+wanted_length];cursor+=wanted_length
        assert length==wanted_length and 0<=length<=capacity<=255,(name,length,capacity,wanted_length)
        got=memory[pointer:pointer+length] if length else b'';assert got==wanted,(name,got.hex(),wanted.hex())
        if capacity:
            assert heap<=pointer and pointer+capacity<=heap+budget,(name,pointer,capacity)
            assert all(pointer+capacity<=p or p+c<=pointer for p,c in allocations),(name,'shared contents')
            allocations.append((pointer,capacity))
        mutable.update(range(offset,offset+5));mutable.add(flag)
        records.append(dict(name=name,length=length,capacity=capacity,pointer=pointer+0x40000,contents=got.hex()))
    numeric_records=[]
    for name,size in numbers:
        width,offset,flag=actual[name];assert width==size and memory[flag]==1
        wanted=expected[cursor:cursor+size];cursor+=size;got=memory[offset:offset+size]
        assert got==wanted,(name,got.hex(),wanted.hex())
        mutable.update(range(offset,offset+size));mutable.add(flag)
        numeric_records.append(dict(name=name,size=size,expected=wanted.hex(),actual=got.hex()))
    assert cursor==len(expected)
    if not (args.conversions or args.search_repeat or args.slice_store):
        width,offset,flag=actual['length%'];assert width==4 and memory[offset:offset+4]==b'\xff\x00\x00\x00' and memory[flag]==1
        mutable.update(range(offset,offset+4));mutable.add(flag)
    if args.slices:
        width,offset,flag=actual['cmpresult%'];assert width==4 and memory[offset:offset+4]==b'\xff'*4 and memory[flag]==1
        mutable.update(range(offset,offset+4));mutable.add(flag)
    width,offset,flag=actual['missing$'];assert memory[flag]==0 and memory[offset:offset+5]==bytes(5)
    for name,(width,offset,_) in actual.items():
        if name.startswith('$') and name!='$sheap':mutable.update(range(offset,offset+width))
    ctx=actual['$sheapctx'][1];free=int.from_bytes(memory[ctx:ctx+3],'little')-0x40000
    limit=int.from_bytes(memory[ctx+3:ctx+6],'little')-0x40000
    assert heap<=free<=limit==heap+budget
    assert all(p+c<=free for p,c in allocations)
    if args.slice_store:
        assert free-heap==sum(c for p,c in allocations),'slice assignment allocated abandoned storage'
    assert memory[free:]==bytes([0xa5])*(len(memory)-free),'writes beyond allocated heap'
    unexpected=[i for i,(a,b) in enumerate(zip(image,memory)) if i not in mutable and a!=b]
    assert not unexpected,('writes outside descriptors, flags, temporaries, context, saved SP',unexpected)
    assert compiler.read_bytes()==original
    report=dict(bindings=len(names),undefined_bindings=1,string_content_mismatches=0,
                descriptor_bounds_checked=True,independent_ownership=True,heap_budget=budget,heap_used=free-heap,
                heap_guard_bytes=len(memory)-free,unexpected_memory_writes=0,records=records,numeric_records=numeric_records,
                slice_assignment_without_allocation=True if args.slice_store else None,
                duration_seconds=round(time.monotonic()-started,3),
                hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in [compiler,ROOT/'bin/basic.bin',build/'source.bas',build/'expected.dat',build/'native.dat']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))


if __name__=='__main__':main()
