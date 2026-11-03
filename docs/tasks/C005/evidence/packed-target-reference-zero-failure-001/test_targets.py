"""Actual numbered-source oracles and unchanged public capacity boundaries."""
from pathlib import Path
import importlib.util
import json
import sys

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'


def programs():
    return [
        dict(source='0 A%=A%+1:IF A%=1 THEN GOTO 2047 ELSE GOTO 2048\n2047 GOSUB 65279:GOTO 0\n2048 PRINT ;A%:END\n65279 RETURN\n', reference=True, status=0),
        dict(source='0 RESTORE 2048:READ a%:GOTO 2048\n2048 DATA 8\n2050 PRINT ;a%:RESTORE 65279:READ a%:PRINT ;a%:END\n65279 DATA 9\n', reference=True, status=0),
        dict(source='0 GOTO 65279\n1 END\n', diagnostic='Undefined target #65279'),
        dict(source='0 RESTORE 65279:END\n65279 PRINT "not DATA"\n', diagnostic='Undefined target $data#65279'),
    ]


def main():
    path = TASK / 'streaming/test_streaming.py'
    spec = importlib.util.spec_from_file_location('stream', path)
    stream = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(stream)
    capacity = '--capacity' in sys.argv
    if capacity:
        sys.argv.remove('--capacity')
        cases = stream.programs()[9:]
        cases[0] = dict(source='x%=0\n'+'x%=x%+1\n'*1800+'PRINT ;x%:END\n',
                        expected='1800\n', status=0, reference=False)
    else:
        cases = programs()
    stream.programs = lambda: cases
    stream.main()
    if capacity:
        size = (ROOT / '.emulator/sdcard/p0.bin').stat().st_size
        assert size > 65536
        (TASK / 'build/output-integration/packed-capacity.json').write_text(json.dumps(dict(
            large_executable_bytes=size, repeated_stores=1800,
            named_labels_executed=2048, labels_rejected=4097,
            scope='Capacity/output checks, not performance measurements'), indent=2)+'\n')
        print('Actual executable above64K:', size)


if __name__ == '__main__':
    main()
