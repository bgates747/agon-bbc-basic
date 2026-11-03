"""Compile exact Mandelbrot and verify unsupported forms preserve old outputs."""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT/'.emulator/c010-fit'
SD = PROFILE/'sdcard'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True, exist_ok=False)
    spec = importlib.util.spec_from_file_location('keyboard', ROOT/'docs/tasks/C005/io/interactive.py')
    keyboard = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(keyboard)
    unsupported = [
        'MODE "8"', 'GCOL "0",1', 'GCOL 0,"1"', 'PLOT 69,"1",2',
        'PLOT 69,1,"2"', 'PLOT 69', 'PLOT BY 1,2', 'GCOL 0,1,2',
        'a%=GET(1)', 'a%=GET#1', 'a$=GET$', 'MODE 8,1',
    ]
    sentinel = b'Existing output must survive unsupported graphics/input syntax'
    source = TASK/'evidence/source-001/mandelbrot.bas'
    shutil.copyfile(source, SD/'admission-0.bas')
    shutil.copyfile(source, evidence/'mandelbrot.bas')
    for i, text in enumerate(unsupported, 1):
        data = (text+'\n').encode()
        (SD/f'admission-{i}.bas').write_bytes(data)
        (evidence/f'reject-{i}.bas').write_bytes(data)
        (SD/f'admission-{i}.bin').write_bytes(sentinel)
    definitions = (TASK/'candidate-fit.bas').read_text().split('1000 DEF', 1)[1]
    driver = ['10 PROCinit:RESTORE 300', '20 test%=0', '30 READ src$,dst$',
        '40 ON ERROR PRINT "REJECT:";test%:REPORT:PRINT:CLOSE#0:GOTO 70',
        '50 PROCcompile(src$,dst$)', '60 PRINT "SUCCESS:";test%',
        f'70 test%=test%+1:IF test%<={len(unsupported)} THEN GOTO 30',
        '80 PRINT "C010_ADMISSIONS_DONE":OSCLI "BYE"']
    driver += [f'{300+i*10} DATA "admission-{i}.bas","admission-{i}.bin"'
        for i in range(len(unsupported)+1)]
    (SD/'admissions-driver.bas').write_text('\n'.join(driver)+'\n1000 DEF'+definitions)
    report = dict(compiler_source_sha256=digest(TASK/'candidate-fit.bas'),
        observer_sha256=digest(PROFILE/'fab-agon-emulator.bin'),
        source_sha256=digest(source), completed=False, rejected=[])
    start = time.monotonic()
    try:
        log = keyboard.run(PROFILE, 'load /bin/basic.bin\nrun . /admissions-driver.bas\n', [],
            'C010_ADMISSIONS_DONE', 'c010-admissions.log', timeout_seconds=300)
        (evidence/'console.log').write_text(log)
        assert 'SUCCESS:0\n' in log
        image = SD/'admission-0.bin'
        assert image.read_bytes() == (TASK/'evidence/compile-001/mandelbrot.dat').read_bytes()
        shutil.copyfile(image, evidence/'mandelbrot.dat')
        for i, text in enumerate(unsupported, 1):
            assert f'REJECT:{i}\n' in log, (i, text, log)
            assert (SD/f'admission-{i}.bin').read_bytes() == sentinel, (i, text)
            report['rejected'].append(text)
        report.update(completed=True, exact_full_source_compiled=True,
            image_sha256=digest(image), image_bytes=image.stat().st_size,
            complete_image_equal_to_partial_first_compile=True, all_outputs_preserved=True)
    finally:
        if (PROFILE/'c010-admissions.log').exists():
            shutil.copyfile(PROFILE/'c010-admissions.log', evidence/'console.log')
        report['controller_seconds'] = round(time.monotonic()-start, 3)
        (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
        shutil.copyfile(__file__, evidence/'qualify_admissions.py')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'}, indent=2)+'\n')
        print(json.dumps(report), flush=True)


if __name__ == '__main__':
    main()
