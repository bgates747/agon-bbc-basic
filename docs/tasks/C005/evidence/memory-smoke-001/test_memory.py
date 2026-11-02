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
    return [p.program([
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


if __name__ == '__main__':
    h = module('output', ROOT/'docs/tasks/C002/tools/test_output.py')
    h.TASK = TASK
    h.programs = programs
    sys.argv += ['--isolate-reference', '--skip-legacy']
    if '--string-runtime' not in sys.argv:
        sys.argv += ['--string-runtime', str(ROOT/'compiler/build/string-runtime')]
    h.main()
    build = TASK/'build/output-integration'
    runtime = TASK/'build/memory-runtime'
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
