"""Run the old qualified native compiler on the new BBC compiler source."""
from pathlib import Path
import hashlib
import argparse
import importlib.util
import json
import shutil
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT / '.emulator'
sd = PROFILE / 'sdcard'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--name', default='native-build-001')
args = parser.parse_args()
assert args.name.replace('-', '').isalnum()
evidence = TASK / 'evidence' / args.name
evidence.mkdir(parents=True, exist_ok=False)
source = TASK / 'candidate.bas'
image = ROOT / 'compiler/bin/compiler.bin'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(image) == '299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0'
for p, name in [(image, 'c010-bootstrap.bin'), (source, 'c010-self-source.bas')]:
    shutil.copyfile(p, sd / name)
    shutil.copyfile(p, evidence / (name.replace('.bin', '.dat')))
spec = importlib.util.spec_from_file_location('keyboard', ROOT/'docs/tasks/C005/io/interactive.py')
k = importlib.util.module_from_spec(spec)
spec.loader.exec_module(k)
report = dict(scope='Actual previous qualified native compiler compiles the new BBC source',
              compiler_source_sha256=sha(source), seed_sha256=sha(image),
              cli_sha256=sha(PROFILE/'fab-agon-emulator.bin'), completed=False)
start = time.monotonic()
try:
    log = k.run(PROFILE,
        'load /c010-bootstrap.bin\nrun .\necho C010_BOOT_DONE\n',
        [('Source file: ', 'c010-self-source.bas'), ('Output file: ', 'c010-newcompiler.bin')],
        'C010_BOOT_DONE', 'c010-bootstrap.log', timeout_seconds=3600)
    assert 'Wrote c010-newcompiler.bin' in log, log
    target = sd / 'c010-newcompiler.bin'
    shutil.copyfile(target, evidence/'compiler.dat')
    report.update(completed=True, image_sha256=sha(target), image_bytes=target.stat().st_size)
finally:
    report['controller_seconds'] = round(time.monotonic() - start, 3)
    if (PROFILE/'c010-bootstrap.log').exists():
        shutil.copyfile(PROFILE/'c010-bootstrap.log', evidence/'console.log')
    (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    (evidence/'manifest.json').write_text(json.dumps({str(p.relative_to(evidence)):sha(p)
        for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
    print(json.dumps(report), flush=True)
