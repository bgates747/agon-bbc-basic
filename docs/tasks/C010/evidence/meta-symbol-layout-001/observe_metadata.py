"""Observe actual BBC layout metadata; this does not generate a compiler image."""
from pathlib import Path
import hashlib
import importlib.util
import json
import re
import shutil
import signal
import threading
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT/'.emulator/c010-wire'
SD = PROFILE/'sdcard'
SOURCE = TASK/'candidate-meta.bas'
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
assert digest(SOURCE) == '70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e'
evidence = TASK/'evidence/meta-symbol-layout-001'
evidence.mkdir(parents=True,exist_ok=False)
body = '1000 DEF'+SOURCE.read_text().split('1000 DEF',1)[1]
assert body.count('1095 FOR phase%=1 TO 3') == 1
body = body.replace('1095 FOR phase%=1 TO 3','1095 FOR phase%=1 TO 1')
driver = '''10 ON ERROR GOTO 100
20 PROCinit
30 PROCcompile("meta-layout-source.bas","meta-layout-output.bin")
40 PROCobserve:PRINT "META_LAYOUT_OK"
50 CLOSE#0:OSCLI "BYE"
100 REPORT:PRINT:PRINT "META_LAYOUT_FAILED":CLOSE#0:OSCLI "BYE"
500 DEF PROCobserve
510 LOCAL i%,n%,s$,saving%,pages%,other%
520 n%=0:saving%=0:pages%=0:other%=0
530 FOR i%=0 TO snum%-1
540 s$=sname$(i%):n%=n%+LEN(s$)
550 IF LEFT$(s$,2)="$V" saving%=saving%+2
560 IF LEFT$(s$,2)="$B" OR LEFT$(s$,2)="$P" saving%=saving%+3
570 IF LEFT$(s$,1)="$" AND INSTR("0123456789",MID$(s$,2,1))>0 saving%=saving%+2
580 NEXT
590 FOR i%=0 TO 63:IF lrefs%(i%)<>0 pages%=pages%+1
600 NEXT
610 FOR i%=0 TO 255:other%=other%+LEN(pname$(i%))+LEN(vname$(i%)):NEXT
620 FOR i%=0 TO 511:other%=other%+LEN(return$(i%)):NEXT
630 FOR i%=0 TO 4:other%=other%+LEN(kwords$(i%)):NEXT
640 FOR i%=0 TO 31:other%=other%+LEN(ifid$(i%))+LEN(bid$(i%))+LEN(lname$(i%)):NEXT
650 PRINT "META_LAYOUT_IMAGE_BYTES:";pc%
660 PRINT "META_LAYOUT_SYMBOLS:";snum%
670 PRINT "META_LAYOUT_SYMBOL_BYTES:";n%
680 PRINT "META_LAYOUT_PREFIX_BYTES_SAVED:";saving%
690 PRINT "META_LAYOUT_OTHER_STRINGS:";other%
700 PRINT "META_LAYOUT_PAGES:";pages%
710 PRINT "META_LAYOUT_ROUTINES:";pnum%
720 PRINT "META_LAYOUT_BINDINGS:";vnum%
730 ENDPROC
'''+body
assert max(len(row.split(' ',1)[1]) for row in driver.splitlines()) <= 255
(SD/'meta-layout-driver.bas').write_text(driver)
(evidence/'driver.bas').write_text(driver)
shutil.copyfile(SOURCE,SD/'meta-layout-source.bas')
shutil.copyfile(SOURCE,evidence/'compiler.bas')
shutil.copyfile(__file__,evidence/'observe_metadata.py')
sentinel = b'Layout-only observation must not open output'
(SD/'meta-layout-output.bin').write_bytes(sentinel)
spec = importlib.util.spec_from_file_location('keyboard',ROOT/'docs/tasks/C005/io/interactive.py')
keyboard = importlib.util.module_from_spec(spec);spec.loader.exec_module(keyboard)
report = dict(source_sha256=digest(SOURCE),driver_sha256=digest(evidence/'driver.bas'),
    cli_sha256=digest(PROFILE/'fab-agon-emulator.bin'),completed=False,
    scope='Actual interpreted layout observation only; no native compiler/image or fit claim')
start = time.monotonic()
stop = threading.Event()
def heartbeat():
    while not stop.wait(30):
        print('METADATA_LAYOUT_ACTIVE',round(time.monotonic()-start,1),flush=True)
def interrupted(signum,frame):
    raise InterruptedError(f'Layout observer received signal {signum}')
old_term = signal.signal(signal.SIGTERM,interrupted)
watcher = threading.Thread(target=heartbeat,daemon=True);watcher.start()
try:
    log = keyboard.run(PROFILE,'load /bin/basic.bin\nrun . /meta-layout-driver.bas\n',[],
        'META_LAYOUT_OK','meta-layout.log',timeout_seconds=5400,
        abort_patterns=[(0,'META_LAYOUT_FAILED')])
    assert (SD/'meta-layout-output.bin').read_bytes() == sentinel
    for field in ['IMAGE_BYTES','SYMBOLS','SYMBOL_BYTES','PREFIX_BYTES_SAVED',
                  'OTHER_STRINGS','PAGES','ROUTINES','BINDINGS']:
        match = re.search('META_LAYOUT_'+field+r':\s*(\d+)',log)
        assert match,field
        report[field.lower()] = int(match.group(1))
    report.update(completed=True,old_output_preserved=True)
except BaseException as error:
    report['failure'] = repr(error)
    raise
finally:
    stop.set();watcher.join(timeout=3)
    if (PROFILE/'meta-layout.log').exists():
        shutil.copyfile(PROFILE/'meta-layout.log',evidence/'console.log')
    report['controller_seconds'] = round(time.monotonic()-start,3)
    (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
        for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
    signal.signal(signal.SIGTERM,old_term)
    print(json.dumps(report),flush=True)
