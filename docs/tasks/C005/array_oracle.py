"""Record the pinned interpreter's array/DIM/indirection behavior, not a model."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = ROOT/'docs/tasks/C005'


def cases():
    return [
        ('array-widths', ['DIM a%(1,2),b&(2),c(2),s$(2)',
            'PRINT ;a%(0,0);":";a%(1,2);":";b&(2);":";c(1);":";LEN s$(2)',
            'PRINT ;^a%(0,1)-^a%(0,0);":";^a%(1,0)-^a%(0,0)',
            'PRINT ;^b&(1)-^b&(0);":";^c(1)-^c(0);":";^s$(1)-^s$(0)',
            'a%(1,2)=-123:b&(2)=257:c(1)=1/3:s$(2)=CHR$(0)+CHR$(255)',
            'PRINT ;a%(1,2);":";b&(2);":";c(1)=1/3;":";LEN s$(2);":";ASC RIGHT$(s$(2))']),
        ('fractional-dim-index', ['DIM a%(-0.9):a%(0.9)=7:PRINT ;a%(0)']),
        ('negative-dim', ['DIM a%(-1)']),
        ('wide-dim', ['DIM a%(16777216)']),
        ('overflow-dim', ['DIM a%(16777215)']),
        ('negative-index', ['DIM a%(1):PRINT a%(-1)']),
        ('wide-index', ['DIM a%(1):PRINT a%(16777216)']),
        ('high-index', ['DIM a%(1):PRINT a%(2)']),
        ('undimensioned-read', ['PRINT a%(0)']),
        ('undimensioned-write', ['a%(0)=7']),
        ('too-few-indices', ['DIM a%(1,1):PRINT a%(0)']),
        ('too-many-indices', ['DIM a%(1):PRINT a%(0,0)']),
        ('redim-before-expression', ['DIM a%(1):DIM a%(FNmark)']),
        ('block-zero-before-size', ['p%=7:q%=0:DIM p% p%:DIM q% 0:PRINT ;q%-p%;":";?p%']),
        ('block-zero-size', ['p%=0:q%=0:DIM p% -1:DIM q% 0:PRINT ;q%-p%']),
        ('block-and-indirection', ['DIM p% 15',
            'PRINT ;?p%;":";p%?15',
            'p%?1=250:p%?3=77:PRINT ;p%?1+2;":";?(p%+3)',
            '!(p%+4)=-123456789:PRINT ;!(p%+4);":";p%!(4)',
            'p%?8=255:PRINT ;?(p%+16777216+8)',
            '|(p%+9)=1/3:PRINT ;|(p%+9)=1/3']),
        ('local-pointer', ['p%=123:PROClocalblock:PRINT ;p%']),
        ('array-scalar-namespace', ['a%=7:DIM a%(1):a%(0)=9:PRINT ;a%;":";a%(0)']),
        ('bad-dim-before-next', ['DIM a%(-1,FNmark)']),
        ('bad-index-before-next', ['DIM a%(1,1):PRINT a%(-1,FNmark)']),
        ('missing-before-index', ['PRINT a%(FNmark)']),
        ('raw-target-seed', ['p%=7:q%=0:expected%=^p% AND &FFFF',
            'DIM p% FNseesize:DIM q% 0:PRINT ;q%-p%=1']),
        ('raw-self-size', ['p%=7:q%=0:DIM p% p%:DIM q% 0:PRINT ;q%-p%=(^p% AND &FFFF)+1']),
        ('raw-variant-seed', ['x=7.25:expected%=^x AND &FFFF:DIM x FNseevariant']),
        ('raw-rhs-target-mutation', ['p%=7:DIM p% FNsettarget:PRINT ;?(^p%+3)']),
        ('repeat-numeric-target', ['DIM a%(1):a%(0)=9:PROCrepeattry',
            'PRINT ;a%(0)=(^a%(0) AND &FFFF)']),
        ('repeat-string', ['DIM s$(1):s$(0)="saved":DIM s$(FNmark)']),
        ('repeat-byte', ['DIM b&(1):b&(0)=99:DIM b&(FNmark)']),
        ('repeat-negative-index', ['DIM a%(1):DIM a%(-1)']),
        ('early-product-overflow', ['DIM a%(65535,65535,FNmark)']),
    ]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--evidence', default='array-reference-003')
    args = parser.parse_args()
    evidence = TASK/'evidence'/args.evidence
    evidence.mkdir(parents=True, exist_ok=True)
    main_lines = ['ON ERROR REPORT:PRINT:PRINT "ARRAY_ORACLE_FAILED":OSCLI "BYE"', '@%=&90A']
    definitions = []
    for i, (name, body) in enumerate(cases()):
        main_lines += ['CLEAR', f'PRINT "ARRAY_BEGIN_{i}"', f'PROCcase{i}', f'PRINT "ARRAY_END_{i}"']
        definitions += [(10000+i*100, f'DEF PROCcase{i}:LOCAL ERROR'),
                        (10001+i*100, 'ON ERROR LOCAL PRINT "ERR=";ERR:REPORT:PRINT:ENDPROC')]
        definitions += [(10002+i*100+j, line) for j, line in enumerate(body)]
        definitions += [(10090+i*100, 'ENDPROC')]
    main_lines += ['PRINT "ARRAY_ORACLE_DONE":OSCLI "BYE"']
    definitions += [(30000, 'DEF FNmark:PRINT "SIDE EFFECT":=0'),
                    (30100, 'DEF PROClocalblock:LOCAL p%:DIM p% 7:PRINT ;?p%;":";p%?7:ENDPROC'),
                    (30200, 'DEF FNseesize:PRINT ;p%=expected%:=0'),
                    (30300, 'DEF FNseevariant:PRINT ;x=expected%;":";?(^x+4):=0'),
                    (30400, 'DEF FNsettarget:p%=-1:=0'),
                    (30500, 'DEF PROCrepeattry:LOCAL ERROR'),
                    (30501, 'ON ERROR LOCAL PRINT "ERR=";ERR:REPORT:PRINT:ENDPROC'),
                    (30502, 'DIM a%(FNmark)'),
                    (30503, 'ENDPROC'),
                    (30600, 'DEF FNinnerdim:DIM a%(0):=1')]
    source = '\n'.join([*[f'{10+i*10} {line}' for i, line in enumerate(main_lines)],
                         *[f'{number} {line}' for number, line in definitions]])+'\n'
    assert max(len(line.split(' ', 1)[1]) for line in source.splitlines()) <= 255
    (evidence/'reference.bas').write_text(source)
    profile = ROOT/'.emulator'
    (profile/'sdcard/array-oracle.bas').write_text(source)
    spec = importlib.util.spec_from_file_location('h', ROOT/'compiler/tools/test_compiler.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    started = time.monotonic()
    log = h.run_profile(profile, 'load /bin/basic.bin\nrun . /array-oracle.bas\n',
                        'ARRAY_ORACLE_DONE', 'array-oracle.log')
    (evidence/'reference.log').write_text(log)
    assert 'ARRAY_ORACLE_FAILED' not in log
    observations = {name: log.split(f'ARRAY_BEGIN_{i}\n', 1)[1].split(f'ARRAY_END_{i}\n', 1)[0]
                    for i, (name, body) in enumerate(cases())}
    report = dict(scope='Pinned interpreted BASIC observations only; no native array implementation',
                  duration_seconds=round(time.monotonic()-started, 3), observations=observations,
                  hashes={str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in [Path(__file__), evidence/'reference.bas', ROOT/'bin/basic.bin']})
    (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
