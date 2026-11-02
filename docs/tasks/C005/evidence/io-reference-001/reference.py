"""Observe actual BBC/MOS file behavior; no native compiler or numeric model."""
from pathlib import Path
import hashlib
import importlib.util
import json
import time

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT/'docs/tasks/C005'


def cases():
    return [
        ('missing', ['PRINT ;OPENIN("io-does-not-exist.dat")']),
        ('binary-eof', ['h%=OPENIN("io-oracle-in.dat"):PRINT ;h%>0;":";EOF#h%',
            'WHILE NOT EOF#h%:PRINT ;BGET#h%;", ";:ENDWHILE:PRINT:PRINT ;EOF#h%', 'CLOSE#h%']),
        ('empty', ['h%=OPENIN("io-oracle-empty.dat"):PRINT ;EOF#h%:CLOSE#h%']),
        ('past-eof-observation', ['h%=OPENIN("io-oracle-in.dat")',
            'FOR i%=1 TO 4:n%=BGET#h%:NEXT',
            'PRINT ;BGET#h%;":";BGET#h%;":";BGET#h%;":";EOF#h%:CLOSE#h%']),
        ('invalid-handles', ['PRINT ;BGET#0;":";EOF#0;":";BGET#255;":";EOF#255']),
        ('truncate', ['h%=OPENOUT("io-oracle-truncate.dat"):BPUT#h%,65:CLOSE#h%',
            'h%=OPENIN("io-oracle-truncate.dat"):n%=0:WHILE NOT EOF#h%:v%=BGET#h%:n%=n%+1:ENDWHILE',
            'PRINT ;n%;":";v%:CLOSE#h%']),
        ('strings', ['h%=OPENOUT("io-oracle-out.dat")',
            'BPUT#h%,0:BPUT#h%,255:BPUT#h%,CHR$(0)+CHR$(128)+CHR$(255)',
            'BPUT#h%,"";:BPUT#h%,"":BPUT#h%,STRING$(255,"q");:CLOSE#h%']),
        ('read-only-write', ['h%=OPENIN("io-oracle-in.dat"):BPUT#h%,42:CLOSE#h%']),
        ('wrap', ['h%=OPENIN("io-oracle-in.dat"):PRINT ;BGET#(h%+256):CLOSE#(h%+256)',
            'PRINT ;BGET#h%;":";EOF#h%']),
        ('handle-limit', ['DIM handles%(8):FOR i%=0 TO 8:handles%(i%)=OPENIN("io-oracle-in.dat"):PRINT ;handles%(i%);",";:NEXT:PRINT',
            'CLOSE#255:h%=OPENIN("io-oracle-in.dat"):PRINT ;h%:CLOSE#0']),
        ('filename-control', ['h%=OPENIN("io-oracle-in.dat"+CHR$(0)+"ignored"):PRINT ;h%>0:CLOSE#h%',
            'h%=OPENIN("io-oracle-in.dat"+CHR$(13)+"ignored"):PRINT ;h%>0:CLOSE#h%']),
        ('fn-filename', ['scratch$="io-oracle-in.datX":h%=OPENIN FNfilename:PRINT ;h%>0:CLOSE#h%',
            'scratch$="io-oracle-in.datX":h%=OPENIN(FNfilename+""):PRINT ;h%>0:CLOSE#h%']),
        ('fn-write', ['h%=OPENOUT("io-oracle-fn.dat"):BPUT#h%,FNbytes;:CLOSE#h%']),
    ]


def main():
    evidence = TASK/'evidence/io-reference-001'
    evidence.mkdir(parents=True, exist_ok=True)
    profile = ROOT/'.emulator'
    fixtures = {'io-oracle-in.dat': bytes([0,127,128,255]), 'io-oracle-empty.dat': b'',
                'io-oracle-truncate.dat': b'old-data-and-a-long-tail'}
    for name, data in fixtures.items():
        (profile/'sdcard'/name).write_bytes(data)
    for name in ('io-oracle-out.dat', 'io-oracle-fn.dat'):
        (profile/'sdcard'/name).unlink(missing_ok=True)
    main_lines = ['ON ERROR REPORT:PRINT:CLOSE#0:PRINT "IO_REFERENCE_FAILED":OSCLI "BYE"', '@%=&90A']
    definitions = []
    for i, (name, body) in enumerate(cases()):
        main_lines += ['CLEAR:CLOSE#0', f'PRINT "IO_BEGIN_{i}"', f'PROCcase{i}', f'PRINT "IO_END_{i}"']
        definitions += [(10000+i*100, f'DEF PROCcase{i}:LOCAL ERROR'),
                        (10001+i*100, 'ON ERROR LOCAL PRINT "ERR=";ERR:REPORT:PRINT:CLOSE#0:ENDPROC')]
        definitions += [(10002+i*100+j, line) for j,line in enumerate(body)]
        definitions += [(10090+i*100, 'ENDPROC')]
    main_lines += ['CLOSE#0:PRINT "IO_REFERENCE_DONE":OSCLI "BYE"']
    definitions += [(30000, 'DEF FNfilename="io-oracle-in.dat"'),
                    (30100, 'DEF FNbytes=CHR$(0)+CHR$(128)+CHR$(255)')]
    source = '\n'.join([*[f'{10+i*10} {line}' for i,line in enumerate(main_lines)],
                         *[f'{n} {line}' for n,line in definitions]])+'\n'
    assert max(len(line.split(' ',1)[1]) for line in source.splitlines()) <= 255
    (evidence/'reference.bas').write_text(source)
    (profile/'sdcard/io-reference.bas').write_text(source)
    spec = importlib.util.spec_from_file_location('h', ROOT/'compiler/tools/test_compiler.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    start = time.monotonic()
    log = h.run_profile(profile, 'load /bin/basic.bin\nrun . /io-reference.bas\n',
                        'IO_REFERENCE_DONE', 'io-reference.log', timeout_seconds=120)
    (evidence/'reference.log').write_text(log)
    assert 'IO_REFERENCE_FAILED' not in log
    observations = {name: log.split(f'IO_BEGIN_{i}\n',1)[1].split(f'IO_END_{i}\n',1)[0]
                    for i,(name,_) in enumerate(cases())}
    outputs = {}
    for name in ('io-oracle-in.dat', 'io-oracle-truncate.dat', 'io-oracle-out.dat', 'io-oracle-fn.dat'):
        data = (profile/'sdcard'/name).read_bytes()
        (evidence/name).write_bytes(data)
        outputs[name] = dict(bytes=len(data), hex=data.hex())
    report = dict(scope='Pinned interpreted BBC/MOS observations only', observations=observations,
                  files=outputs, duration_seconds=round(time.monotonic()-start,3),
                  basic_sha256=hashlib.sha256((ROOT/'bin/basic.bin').read_bytes()).hexdigest())
    (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
