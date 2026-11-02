"""BBC differential array/DIM/indirection programs, with independent helper links."""
from pathlib import Path
import importlib.util
import json
import subprocess
import sys

TASK = Path(__file__).resolve().parent
ROOT = TASK.parents[2]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def programs():
    p = module('procedures', ROOT/'docs/tasks/C004/tools/test_procedures.py')
    result = [dict(source='DIM a%(0):PRINT ;a%(0)\n', reference=True, status=0), p.program([
        'DIM a%(1,2),b&(2),x(1),s$(1),mem% 15',
        'PRINT ;a%(0,0);":";b&(2);":";x(1);":";LEN s$(1)',
        'a%(1,2)=-123:b&(2)=257:x(1)=1/3:s$(1)="ABC"',
        'PRINT ;a%(1,2);":";b&(2);":";x(1)=1/3;":";LEN s$(1)',
        'PRINT ;^a%(0,1)-^a%(0,0);":";^a%(1,0)-^a%(0,0)',
        'PRINT ;^b&(1)-^b&(0);":";^x(1)-^x(0);":";^s$(1)-^s$(0)',
        'mem%?0=17:!(mem%+4)=-77:|(mem%+9)=1/3',
        'PRINT ;?mem%;":";mem%!(4);":";|(mem%+9)=1/3',
        'copy$=s$(1):s$(1)="changed":PRINT copy$;":";s$(1)',
        'PRINT ;FNtouch(1);":";a%(1,2)',
    ], ['DEF FNtouch(i%):a%(i%,2)=a%(i%,2)+1:=a%(i%,2)'])]
    result += [p.program(main, definitions) for main, definitions in [
        (['DIM a&(100000):a&(100000)=255:PRINT ;a&(0);":";a&(100000)',
          'PRINT ;^a&(100000)-^a&(0)'], []),
        (['DIM a&(300,300):a&(300,300)=127:PRINT ;a&(0,0);":";a&(300,300)',
          'PRINT ;^a&(1,0)-^a&(0,0)'], []),
        (['DIM a%(-0.9):a%(0.9)=7:PRINT ;a%(0)'], []),
        (['DIM a%(0),b&(0),x(0):a%(0)=&80000000:b&(0)=-1:x(0)=-0.9',
          'PRINT ;a%(0);":";b&(0);":";x(0)=-0.9',
          'a%(0)=x(0):b&(0)=x(0):PRINT ;a%(0);":";b&(0)'], []),
        (['a%=7:DIM a%(1),A%(0):a%(0)=9:PRINT ;a%;":";a%(0);":";A%;":";A%(0)'], []),
        (['DIM s$(2):s$(0)=STRING$(255,"q"):s$(1)=s$(0):s$(2)=CHR$(0)+CHR$(128)+CHR$(255)',
          's$(0)="changed":PRINT ;LEN s$(1);":";ASC s$(1);":";LEN s$(2);":";ASC RIGHT$(s$(2))'], []),
        (['DIM a%(2):i%=1:a%(i%)=FNrhsarray',
          'PRINT ;a%(1);":";a%(2);":";i%'], ['DEF FNrhsarray:i%=2:=99']),
        (['DIM a%(1):a%(0)=10:a%(1)=20:PRINT ;a%(FNindexone)+a%(FNindextwo)'],
          ['DEF FNindexone=0', 'DEF FNindextwo=1']),
        (['DIM s$(1):s$(0)="outer":s$(FNstrindex)=FNstrrhs:PRINT s$(0);":";s$(1)',
          'PRINT RIGHT$(s$(0));":";STRING$(2,s$(0))'],
          ['DEF FNstrindex=0', 'DEF FNstrrhs:s$(1)="side":="new"']),
        (['DIM a%(4):FOR i%=0 TO 4:a%(i%)=i%*10:NEXT:PRINT ;FNarraysum(4)'],
          ['DEF FNarraysum(n%):IF n%=0 THEN =a%(0) ELSE =a%(n%)+FNarraysum(n%-1)']),
        (['DIM a%(3):PROCarrayfill(3):PRINT ;a%(0);":";a%(1);":";a%(2);":";a%(3)'],
          ['DEF PROCarrayfill(n%):LOCAL t%:t%=n%:IF n%>0 THEN PROCarrayfill(n%-1)',
           'a%(t%)=t%*10:ENDPROC']),
        (['DIM a%(2):FOR i%=0 TO 2:a%(i%)=i%:NEXT',
          'IF a%(2)>1 THEN a%(1)=9 ELSE a%(1)=8',
          'PRINT ;a%(0)+a%(1)+a%(2)'], []),
        (['p%=7:q%=0:expected%=^p% AND &FFFF:DIM p% FNrawseed:DIM q% 0:PRINT ;q%-p%=1'],
          ['DEF FNrawseed:PRINT ;p%=expected%:=0']),
        (['p%=7:q%=0:DIM p% p%:DIM q% 0:PRINT ;q%-p%=(^p% AND &FFFF)+1'], []),
        (['x=7.25:expected%=^x AND &FFFF:DIM x FNvariantseed'],
          ['DEF FNvariantseed:PRINT ;x=expected%;":";?(^x+4):=0']),
        (['p%=7:DIM p% FNrawmutate:PRINT ;?(^p%+3)'], ['DEF FNrawmutate:p%=-1:=0']),
        (['x=7:DIM x FNrawfloat:PRINT ;?(^x+3)=hi%;":";?(^x+4)=ex%'],
          ['DEF FNrawfloat:x=1/3:hi%=?(^x+3):ex%=?(^x+4):=0']),
        (['p%=0:q%=0:DIM p% -1:DIM q% 0:PRINT ;q%-p%',
          'DIM wide% 65536:wide%?65536=99:PRINT ;?wide%;":";wide%?65536'], []),
        (['DIM p% 15:p%?1=250:p%?3=77:PRINT ;p%?1+2;":";?(p%+3)',
          '!(p%+4)=-123456789:PRINT ;!(p%+4);":";p%!(4)',
          'p%?8=255:PRINT ;?(p%+16777216+8)',
          '|(p%+9)=1/3:PRINT ;|(p%+9)=1/3'], []),
        (['DIM p% 3:old%=p%:p%?1=FNrawrhs:PRINT ;old%?1;":";p%=old%'],
          ['DEF FNrawrhs:p%=0:=255']),
        (['DIM first% 0:p%=123:PROClocalraw:PRINT ;p%:DIM second% 0:PRINT ;second%-first%>1'],
          ['DEF PROClocalraw:LOCAL p%:DIM p% 7:PRINT ;?p%;":";p%?7:ENDPROC']),
        (['PRINT ;^missing%>0;":";missing%:PRINT ;^missing$>0;":";LEN missing$'], []),
    ]]
    for body in [
        ['DIM a%(-1)'], ['DIM a%(16777216)'], ['DIM a%(16777215)'],
        ['DIM a%(65535,65535)'], ['DIM a%(1):PRINT a%(-1)'],
        ['DIM a%(1):PRINT a%(16777216)'], ['DIM a%(1):PRINT a%(2)'],
        ['PRINT missing%(0)'], ['missing%(0)=7'], ['PRINT ^missing%(0)'],
        ['DIM a%(1):DIM a%(0)'], ['DIM s$(1):DIM s$(0)'],
        ['DIM b&(1):DIM b&(0)'], ['DIM a%(1):DIM a%(-1)'],
        ['DIM a%(0):a%(0)=1E20'], ['DIM p% 3:!p%=1E20'],
    ]:
        case = p.program(body, [])
        case.update(reference_error=True, status=1)
        result.append(case)
    result += [dict(source=source, diagnostic=diagnostic) for source, diagnostic in [
        ('DIM a%(1,1):PRINT a%(0)\n', 'Array arity must be consistent'),
        ('DIM a%(1):PRINT a%(0,0)\n', 'Array arity must be consistent'),
        ('DIM a%()\n', 'Empty DIM dimensions are unsupported'),
        ('DIM a%(0):a%()=3\n', 'Whole-array values are unsupported'),
        ('DIM p& 3\n', 'Raw DIM requires a four-byte or variant numeric target'),
        ('DIM p% LOCAL 3\n', 'DIM LOCAL storage is unsupported'),
        ('DIM a%(FNbound)\nEND\nDEF FNbound=1\n', 'FN calls in array DIM expressions are unqualified'),
        ('DIM a%((^x% AND 7))\n', 'Address-of in array DIM expressions is unqualified'),
        ('DEF PROCbad(a%())\nENDPROC\n', 'Array formal parameters are unsupported'),
        ('DEF PROCbad:LOCAL a%():ENDPROC\n', 'LOCAL arrays are unsupported'),
        ('DIM s$(0):LEFT$(s$(0),1)="x"\n', 'Array slice assignment is unsupported'),
        ('DIM a%(1):FOR a%(0)=1 TO 2:NEXT\n', 'Array FOR variables are unsupported'),
        ('DIM s$(0):PRINT RIGHT$(FNarraystring)\nEND\nDEF FNarraystring=s$(0)\n',
         'Omitted RIGHT$ on a FN string result is unqualified'),
    ]]
    return result


if __name__ == '__main__':
    if '--memory-runtime' in sys.argv:
        offset = sys.argv.index('--memory-runtime')
        memory_runtime = Path(sys.argv[offset+1]).resolve(strict=True)
        del sys.argv[offset:offset+2]
    else:
        memory_runtime = ROOT/'compiler/build/memory-runtime'
        if not memory_runtime.exists():
            memory_runtime = TASK/'build/memory-runtime'
    h = module('output', ROOT/'docs/tasks/C002/tools/test_output.py')
    h.TASK = TASK
    smoke = '--smoke' in sys.argv
    if smoke:
        sys.argv.remove('--smoke')
    h.programs = (lambda: programs()[:2]) if smoke else programs
    sys.argv += ['--isolate-reference', '--skip-legacy']
    if '--string-runtime' not in sys.argv:
        sys.argv += ['--string-runtime', str(ROOT/'compiler/build/string-runtime')]
    h.main()
    build = TASK/'build/output-integration'
    runtime = memory_runtime
    template = (runtime/'runtime-0.bin').read_bytes()
    verified = []
    for i, case in enumerate(json.loads((build/'cases.json').read_text())):
        if 'diagnostic' in case:
            continue
        image = (ROOT/'.emulator/sdcard'/f'p{i}.bin').read_bytes()
        position = image.find(template[:20])
        if position < 0:
            continue
        base = 0x40000+position
        output = build/f'memory-{base:x}.bin'
        subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld', f'-Ttext=0x{base:x}',
            '-e', 'mem_alloc', '--oformat=binary', '-o', str(output),
            str(runtime/'runtime.o')], check=True)
        assert image[position:position+len(template)] == output.read_bytes()
        verified.append(dict(program=i, base=base, bytes=len(template)))
    (build/'memory-links.json').write_text(json.dumps(verified, indent=2)+'\n')
    assert verified
    print('Independent memory helper links:', verified)
    checker = module('activation_links', ROOT/'docs/tasks/C004/tools/check_procedure_images.py')
    checker.TASK = TASK
    act = (ROOT/'compiler/build/procedure-runtime/runtime-0.bin').read_bytes()
    indices = [i for i, case in enumerate(json.loads((build/'cases.json').read_text()))
               if 'diagnostic' not in case and (ROOT/'.emulator/sdcard'/f'p{i}.bin').read_bytes().find(act[20:28]) >= 20]
    assert indices
    checker.check(case_indices=indices)
