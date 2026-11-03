"""Use the qualified BBC-native compiler to measure new emitter body code size.

This is an isolated size probe, not full-source fit proof. Common procedure
stubs keep the signatures constant; actual new BBC bodies replace five stubs.
"""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT/'.emulator/c010-wire'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    evidence = TASK/'evidence/growth-001'
    evidence.mkdir(parents=True,exist_ok=False)
    spec = importlib.util.spec_from_file_location('keyboard',ROOT/'docs/tasks/C005/io/interactive.py')
    keyboard = importlib.util.module_from_spec(spec);spec.loader.exec_module(keyboard)
    stubs = ['DEF PROCexpr(a%):ENDPROC','DEF PROCneednumber:ENDPROC',
        'DEF PROCnumoperation(a%,b%,c%):ENDPROC','DEF PROCaddr(a$,b$):ENDPROC',
        'DEF PROCbyte(a%):ENDPROC','DEF PROCbytes(a$):ENDPROC',
        'DEF PROCcharacter(a%):ENDPROC','DEF PROCspace:ENDPROC',
        'DEF PROCexpect(a$):ENDPROC','DEF PROCbad(a$):ENDPROC',
        'DEF PROCnumslot:ENDPROC','DEF PROCerrorconstant(a%,a$):ENDPROC',
        'DEF FNpeek=""','DEF FNflow=""']
    prefix = ('10 ndepth%=0:sdepth%=0:valuekind%=0:w$="":n$="":s$="":i%=0:j%=0:n%=0\n'
        '20 PROCbyte(0):FOR q%=0 TO 0:NEXT:END\n')
    prefix += ''.join(f'{1000+10*i} {line}\n' for i,line in enumerate(stubs))
    bodies = ''.join(line+'\n' for line in (TASK/'candidate.bas').read_text().splitlines()
        if 19630 <= int(line.split(' ',1)[0]) < 20000)
    empty = ('19630 DEF PROCgraphicarg:ENDPROC\n19634 DEF PROCgraphicbyte(i%,j%):ENDPROC\n'
        '19640 DEF PROCgraphics(w$):ENDPROC\n19670 DEF PROCmode:ENDPROC\n'
        '19680 DEF PROCkeyvalue:ENDPROC\n')
    dispatch = ('1500 DEF PROCdispatch\n1510 @GRAPHICS@\n1520 ENDPROC\n'
        '1530 DEF PROCitemdispatch\n1540 @GET@\n1550 ENDPROC\n')
    sd = PROFILE/'sdcard'
    shutil.copyfile(ROOT/'compiler/bin/compiler.bin',sd/'growth-compiler.bin')
    report = dict(seed_sha256=digest(ROOT/'compiler/bin/compiler.bin'),
        compiler_source_sha256=digest(TASK/'candidate.bas'),completed=False,images={})
    try:
        for name in ['empty','bodies']:
            d = dispatch.replace('@GRAPHICS@', 'REM baseline').replace('@GET@','REM baseline')
            if name == 'bodies':
                d = dispatch.replace('@GRAPHICS@','IF w$="MODE" OR w$="GCOL" OR w$="PLOT" THEN PROCgraphics(w$):ENDPROC')
                d = d.replace('@GET@','IF w$="GET" THEN PROCkeyvalue:ENDPROC')
            source = prefix+d+(empty if name == 'empty' else bodies)
            (sd/f'growth-{name}.bas').write_text(source)
            (evidence/f'{name}.bas').write_text(source)
            log = keyboard.run(PROFILE,'try /growth-compiler.bin\necho C010_GROWTH_STATUS:<Try$ReturnCode>\n'
                'echo C010_GROWTH_DONE\n',[('Source file: ',f'growth-{name}.bas'),
                ('Output file: ',f'growth-{name}.bin')],'C010_GROWTH_DONE',f'growth-{name}.log',timeout_seconds=120)
            (evidence/f'{name}.log').write_text(log)
            assert f'Wrote growth-{name}.bin\n' in log and 'C010_GROWTH_STATUS:0\n' in log,log
            image = sd/f'growth-{name}.bin'
            shutil.copyfile(image,evidence/f'{name}.dat')
            numeric_prefix = (ROOT/'compiler/build/numeric-runtime/runtime-0.bin').read_bytes()[:20]
            data = image.read_bytes()
            assert data.count(numeric_prefix) == 1
            report['images'][name] = dict(bytes=len(data),numeric_offset=data.index(numeric_prefix))
        report.update(completed=True,body_code_delta=report['images']['bodies']['numeric_offset']-
            report['images']['empty']['numeric_offset'],image_delta=report['images']['bodies']['bytes']-
            report['images']['empty']['bytes'],scope='Actual compiler size probe; full-image and native fit checks remain authoritative')
    finally:
        (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
        shutil.copyfile(__file__,evidence/'measure_growth.py')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
        print(json.dumps(report),flush=True)


if __name__ == '__main__':
    main()
