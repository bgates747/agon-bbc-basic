"""Compare actual reference/native UART streams; Python does no BASIC arithmetic.

Requires the isolated C010 protocol observer profile. It is not a renderer.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import os
import shutil
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT / '.emulator/c010-fit'
SD = PROFILE / 'sdcard'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def cases(suite):
    basic = [
        dict(name='basic-graphics', body='MODE 8\nGCOL 0,5\nPLOT 69,2,3\nMODE 1'),
        dict(name='graphics-conversions', body='MODE 257.9\nGCOL 7\nGCOL 257,-1.9\n'
             'PLOT 65537,-65537\nPLOT 325.9,32768,-32768\nPLOT -1,-1.9,65535.9\nMODE 1'),
        dict(name='argument-order', body='GCOL FNn(1),FNn(2)\nPLOT FNn(3),FNn(4),FNn(5)',
             definitions='DEF FNn(n%)\nVDU 64+n%\n=n%'),
        dict(name='keyboard', body='PRINT "C010_WAIT"\na%=GET:b%=GET\nPRINT ;a%;":";b%',
             keyboard=[('C010_WAIT', 'Q')]),
        dict(name='keyboard-expression', body='PRINT "C010_WAIT"\nPRINT ;100+GET*2;":";GET+1',
             keyboard=[('C010_WAIT', 'Q')]),
    ]
    if suite == 'basic':
        return basic
    if suite == 'bounded':
        original = (TASK/'evidence/source-001/mandelbrot.bas').read_text()
        body = '\n'.join(line.strip().split(' ', 1)[1] for line in original.splitlines())
        body = body.replace('ITERS=32', 'ITERS=8').replace('SCALE=1', 'SCALE=64')
        body = body.replace('A%=GET', 'PRINT "C010_WAIT":A%=GET')
        return [dict(name='mandelbrot-bounded', body=body, keyboard=[('C010_WAIT', 'Q')])]
    if suite == 'interactions':
        return [
            dict(name='mode-local-recovery', body='x%=77\nMODE FNmode\nPRINT ;x%\nMODE 1',
                definitions='DEF FNmode\nLOCAL x%:x%=9\nON ERROR LOCAL =8\nERROR 100,"mode argument"\n=1'),
            dict(name='keyboard-local', body='s$="outer":x%=7\nPRINT "C010_WAIT"\n'
                'PRINT ;FNkey(100);":";x%;":";s$',
                definitions='DEF FNkey(n%)\nLOCAL x%,s$\nx%=9:s$="inner"\n=n%+GET',
                keyboard=[('C010_WAIT', 'Q')]),
            dict(name='mode-handler-reuse', body='ON ERROR MODE 1:PRINT ;ERR;":";ERL:GOTO 900\nMODE 1E20'),
        ]
    errors = []
    for name, statement in [
        ('gcol-first-overflow', 'GCOL 1E20,FNlater'),
        ('gcol-second-overflow', 'GCOL FNfirst,1E20'),
        ('plot-first-overflow', 'PLOT 1E20,FNlater,FNlater'),
        ('plot-second-overflow', 'PLOT FNfirst,1E20,FNlater'),
        ('plot-third-overflow', 'PLOT FNfirst,FNfirst,1E20'),
        ('mode-overflow', 'MODE 1E20'),
        ('mode-expression-error', 'MODE 1/0'),
        ('gcol-expression-error', 'GCOL 1/0,FNlater'),
    ]:
        errors.append(dict(name=name, body='ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:GOTO 900\n'+statement,
            definitions='DEF FNfirst:VDU 65:=1\nDEF FNlater:PRINT "WRONG":=2'))
    errors.append(dict(name='keyboard-escape', body='ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:GOTO 900\n'
        'PRINT "C010_WAIT"\na%=GET\nPRINT "WRONG"', keyboard=[('C010_WAIT', '\x1b')]))
    return errors


def source(case, reference=False):
    lines = ['PRINT "C010_BEGIN"'] + case['body'].splitlines()
    text = ''.join(f'{10+i*10} {line}\n' for i, line in enumerate(lines))
    text += '900 PRINT "C010_END"\n910 '+('OSCLI "BYE"' if reference else 'END')+'\n'
    text += ''.join(f'{1000+i*10} {line}\n' for i, line in enumerate(case.get('definitions', '').splitlines()))
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    parser.add_argument('--suite', choices=['basic', 'bounded', 'errors', 'interactions'], default='basic')
    parser.add_argument('--native', type=Path, help='compile probes with this actual native compiler')
    parser.add_argument('--source', type=Path, default=TASK/'candidate-fit.bas')
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    evidence = TASK / 'evidence' / args.name
    evidence.mkdir(parents=True, exist_ok=False)
    shutil.copyfile(__file__, evidence/'qualify_wire.py')
    keyboard = load('keyboard', ROOT / 'docs/tasks/C005/io/interactive.py')
    selected = cases(args.suite)
    report = dict(scope='Actual CPU UART stream parity; protocol peer, no renderer or human validation',
                  compiler_source_sha256=digest(args.source),
                  reference_sha256=digest(SD/'bin/basic.bin'),
                  observer_sha256=digest(PROFILE/'fab-agon-emulator.bin'),
                  mos_sha256=digest(PROFILE/'mos_platform.bin'), suite=args.suite, cases=[], completed=False)
    report['native_compiler_sha256'] = digest(args.native) if args.native else None
    start = time.monotonic()
    try:
        # BBC BASIC performs every parse, conversion and byte of native emission.
        definitions = args.source.read_text().split('1000 DEF', 1)[1]
        driver = ['10 PROCinit', '20 ON ERROR REPORT:PRINT:OSCLI "BYE"']
        for i, case in enumerate(selected):
            (SD/f'w{i}.bas').write_text(source(case))
            (evidence/f'{case["name"]}.bas').write_text(source(case))
            (evidence/f'{case["name"]}-reference.bas').write_text(source(case, True))
            driver.append(f'{30+i*10} PROCcompile("w{i}.bas","w{i}.bin"):PRINT "COMPILED:{i}"')
        driver += [f'{30+len(selected)*10} PRINT "C010_COMPILE_DONE":OSCLI "BYE"']
        (SD/'wire-driver.bas').write_text('\n'.join(driver)+'\n1000 DEF'+definitions)
        if args.native:
            shutil.copyfile(args.native, SD/'wire-compiler.bin')
            logs = []
            for i, case in enumerate(selected):
                log = keyboard.run(PROFILE, 'try /wire-compiler.bin\necho C010_CC_STATUS:<Try$ReturnCode>\n'
                    'echo C010_CC_DONE\n', [('Source file: ', f'w{i}.bas'), ('Output file: ', f'w{i}.bin')],
                    'C010_CC_DONE', f'c010-native-compile-{i}.log', timeout_seconds=300)
                (evidence/f'compile-{i}.log').write_text(log)
                assert f'Wrote w{i}.bin\n' in log and 'C010_CC_STATUS:0\n' in log, log
                logs.append(log+f'COMPILED:{i}\n')
            log = '\n'.join(logs)
        else:
            log = keyboard.run(PROFILE, 'load /bin/basic.bin\nrun . /wire-driver.bas\n', [],
                               'C010_COMPILE_DONE', 'c010-wire-compile.log', timeout_seconds=300)
        (evidence/'compile.log').write_text(log)
        assert all(f'COMPILED:{i}\n' in log for i in range(len(selected))), log
        for i, case in enumerate(selected):
            shutil.copyfile(SD/f'w{i}.bin', evidence/f'{case["name"]}.dat')
            streams = {}
            for mode in ['reference', 'native']:
                raw = evidence/f'{case["name"]}-{mode}-wire.dat'
                os.environ['BBC_C010_WIRE'] = str(raw)
                marker = f'C010_DONE_{i}'
                if mode == 'reference':
                    (SD/'wire-reference.bas').write_text(source(case, True))
                    auto = f'load /bin/basic.bin\nrun . /wire-reference.bas\necho {marker}\n'
                else:
                    auto = f'try /w{i}.bin\necho C010_STATUS:<Try$ReturnCode>\necho {marker}\n'
                log = keyboard.run(PROFILE, auto, case.get('keyboard', []), marker,
                                   f'c010-wire-{mode}.log', timeout_seconds=120)
                (evidence/f'{case["name"]}-{mode}.log').write_text(log)
                if mode == 'native':
                    assert 'C010_STATUS:0\n' in log, log
                wire = raw.read_bytes()
                begin = b'C010_BEGIN\r\n'
                end = b'C010_END\r\n'
                assert wire.count(begin) == wire.count(end) == 1, (case['name'], mode, wire)
                streams[mode] = wire.split(begin, 1)[1].split(end, 1)[0]
                (evidence/f'{case["name"]}-{mode}-body.dat').write_bytes(streams[mode])
            same = streams['reference'] == streams['native']
            report['cases'].append(dict(name=case['name'], equal=same,
                reference_hex=streams['reference'].hex(), native_hex=streams['native'].hex(),
                image_bytes=(SD/f'w{i}.bin').stat().st_size))
            assert same, report['cases'][-1]
        report['completed'] = True
    finally:
        os.environ.pop('BBC_C010_WIRE', None)
        report['controller_seconds'] = round(time.monotonic()-start, 3)
        (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'}, indent=2)+'\n')
        print(json.dumps(report), flush=True)


if __name__ == '__main__':
    main()
