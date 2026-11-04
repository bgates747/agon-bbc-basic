"""Run the old qualified native compiler on the new BBC compiler source."""
from pathlib import Path
import hashlib
import argparse
import importlib.util
import json
import shutil
import signal
import threading
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT / '.emulator/c010-fit-build'
sd = PROFILE / 'sdcard'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--name', default='native-build-001')
parser.add_argument('--seed', type=Path)
parser.add_argument('--expected', type=Path)
parser.add_argument('--source', type=Path, default=TASK/'candidate-fit.bas')
parser.add_argument('--timeout', type=float, default=3600)
args = parser.parse_args()
assert args.name.replace('-', '').isalnum()
evidence = TASK / 'evidence' / args.name
evidence.mkdir(parents=True, exist_ok=False)
source = args.source.resolve(strict=True)
image = args.seed or ROOT / 'compiler/bin/compiler.bin'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
if args.seed is None:
    assert sha(image) == '299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0'
assert image.read_bytes()[64:69] == b'MOS\x00\x01'
shutil.copyfile(__file__, evidence/'bootstrap_native.py')
for p, name in [(image, 'c010-bootstrap.bin'), (source, 'c010-self-source.bas')]:
    shutil.copyfile(p, sd / name)
    shutil.copyfile(p, evidence / (name.replace('.bin', '.dat')))
spec = importlib.util.spec_from_file_location('keyboard', ROOT/'docs/tasks/C005/io/interactive.py')
k = importlib.util.module_from_spec(spec)
spec.loader.exec_module(k)
report = dict(scope='Actual previous qualified native compiler compiles the new BBC source',
              compiler_source_sha256=sha(source), seed_sha256=sha(image),
              cli_sha256=sha(PROFILE/'fab-agon-emulator.bin'), completed=False)
if args.seed:
    report['scope'] = 'Actual supplied native compiler self-compiles the exact BBC candidate'
def interrupted(signum, frame):
    report['interrupted_by_signal'] = signum
    raise InterruptedError(f'Controller received signal {signum}')
previous_term = signal.signal(signal.SIGTERM, interrupted)
start = time.monotonic()
stop = threading.Event()
def heartbeat():
    while not stop.wait(30):
        target = sd/'c010-newcompiler.bin'
        print('NATIVE_BUILD_ACTIVE', args.name, round(time.monotonic()-start, 1),
              target.stat().st_size if target.exists() else 0, flush=True)
observer = threading.Thread(target=heartbeat, daemon=True)
observer.start()
try:
    (sd/'c010-newcompiler.bin').unlink(missing_ok=True)
    log = k.run(PROFILE,
        'load /c010-bootstrap.bin\nrun .\necho C010_BOOT_DONE\n',
        [('Source file: ', 'c010-self-source.bas'), ('Output file: ', 'c010-newcompiler.bin')],
        'C010_BOOT_DONE', 'c010-bootstrap.log', timeout_seconds=args.timeout, abort_patterns=[(step, pattern) for step in range(3) for pattern in ['\nNo room at line', 'Error executing autoexec.txt']])
    assert 'Wrote c010-newcompiler.bin' in log, log
    target = sd / 'c010-newcompiler.bin'
    shutil.copyfile(target, evidence/'compiler.dat')
    report.update(completed=True, image_sha256=sha(target), image_bytes=target.stat().st_size)
    if args.expected:
        assert target.read_bytes() == args.expected.read_bytes()
        report['complete_image_equals_expected'] = True
except BaseException as error:
    report['failure'] = repr(error)
    raise
finally:
    stop.set()
    observer.join(timeout=3)
    signal.signal(signal.SIGTERM, previous_term)
    report['controller_seconds'] = round(time.monotonic() - start, 3)
    if (PROFILE/'c010-bootstrap.log').exists():
        shutil.copyfile(PROFILE/'c010-bootstrap.log', evidence/'console.log')
    if not report['completed'] and (sd/'c010-newcompiler.bin').exists():
        shutil.copyfile(sd/'c010-newcompiler.bin', evidence/'partial-compiler.dat')
    (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    (evidence/'manifest.json').write_text(json.dumps({str(p.relative_to(evidence)):sha(p)
        for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
    print(json.dumps(report), flush=True)
