"""Measure actual interpreted compiler initialization headroom through BBC BASIC."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = ROOT/'docs/tasks/C005'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--compiler', type=Path, default=TASK/'compiler.bas')
    parser.add_argument('--evidence', required=True)
    args = parser.parse_args()
    evidence = TASK/'evidence'/args.evidence
    evidence.mkdir(parents=True, exist_ok=True)
    source = args.compiler.read_text()
    driver = ('10 ON ERROR REPORT:PRINT:PRINT "HOST_MEMORY_FAILED":OSCLI "BYE"\n'
              '20 PROCinit\n30 PRINT "HOST_MEMORY_BEGIN"\n'
              '40 PRINT ;HIMEM;":";END;":";HIMEM-END\n'
              '50 PRINT "HOST_MEMORY_DONE":OSCLI "BYE"\n1000 DEF'+source.split('1000 DEF', 1)[1])
    (evidence/'driver.bas').write_text(driver)
    profile = ROOT/'.emulator'
    (profile/'sdcard/host-memory.bas').write_text(driver)
    spec = importlib.util.spec_from_file_location('h', ROOT/'compiler/tools/test_compiler.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    start = time.monotonic()
    log = h.run_profile(profile, 'load /bin/basic.bin\nrun . /host-memory.bas\n',
                        'HOST_MEMORY_DONE', 'host-memory.log', timeout_seconds=60)
    (evidence/'native-host.log').write_text(log)
    assert 'HOST_MEMORY_FAILED' not in log
    fields = log.split('HOST_MEMORY_BEGIN\n', 1)[1].split('\n', 1)[0].split(':')
    values = [int(float(value)) for value in fields]
    report = dict(scope='Pinned interpreted compiler host after PROCinit; not native compiler memory',
                  compiler_sha256=hashlib.sha256(source.encode()).hexdigest(),
                  himem=values[0], heap_end=values[1], free_bytes=values[2],
                  duration_seconds=round(time.monotonic()-start, 3))
    (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
