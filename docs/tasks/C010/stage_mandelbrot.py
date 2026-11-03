"""Deliver the completed native program for optional Author visual comparison."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import hashlib
import json
import shlex
import shutil
import subprocess

TASK = Path(__file__).resolve().parent
REMOTE = r'''
from pathlib import Path
import hashlib,json,os,subprocess,sys,tempfile
assert subprocess.check_output(['hostname'],text=True).strip() == 'oryx-linuxlite'
directory = Path('/home/smith/Agon/flexe-emulator/sdcard/basic-compiled/tests/12-mandelbrot')
assert directory.resolve() == directory and directory.is_dir()
sha = lambda b:hashlib.sha256(b).hexdigest()
assert sha((directory/'mandelbrot.bas').read_bytes()) == sys.argv[1]
image = sys.stdin.buffer.read()
assert sha(image) == sys.argv[2]
target = directory/'mandelbrot-c010.bin'
if sys.argv[3] == 'verify-only':
    assert target.resolve() == target and sha(target.read_bytes()) == sys.argv[2]
    print(json.dumps(dict(existing_image_verified=True,image_sha256=sha(target.read_bytes()),
        no_writes=True,no_program_execution=True,no_emulator_launch=True)))
    sys.exit(0)
assert not target.exists(), 'Preserve existing target; inspect rather than overwriting'
fd,temporary = tempfile.mkstemp(prefix='.c010-program-',dir=directory)
try:
    with os.fdopen(fd,'wb') as file:
        file.write(image);file.flush();os.fsync(file.fileno())
    os.link(temporary,target)
finally:
    os.unlink(temporary)
subprocess.run(['sync','-f',str(directory)],check=True)
print(json.dumps(dict(copied_and_synced=True,image_sha256=sha(image),image_bytes=len(image),
    source_unchanged=True,no_program_execution=True,no_emulator_launch=True)))
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', default='visual-fixture-001')
    parser.add_argument('--verify-only', action='store_true')
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True,exist_ok=False)
    full = TASK/'evidence/full-native-002'
    report = json.loads((full/'results.json').read_text())
    for name, expected in json.loads((full/'manifest.json').read_text()).items():
        assert hashlib.sha256((full/name).read_bytes()).hexdigest() == expected
    assert report['completed'] and report['key_supplied_after_final_plot']
    image = (full/'mandelbrot.dat').read_bytes()
    started = datetime.now(timezone.utc).isoformat()
    command = ('python3 -c '+shlex.quote(REMOTE)+' '+report['source_sha256']+' '+report['image_sha256']
        +' '+('verify-only' if args.verify_only else 'copy-new'))
    result = subprocess.run(['ssh','-o','BatchMode=yes','oryx-linuxlite',command],input=image,capture_output=True)
    receipt = dict(scope='New named program file only in the Author-owned emulator SD; no emulator control',
        started=started,finished=datetime.now(timezone.utc).isoformat(),returncode=result.returncode,
        stdout=result.stdout.decode(errors='replace'),stderr=result.stderr.decode(errors='replace'),
        source_sha256=report['source_sha256'],image_sha256=report['image_sha256'],
        human_validation=False,root_compiler_updated=False,verification_only=args.verify_only)
    (evidence/'results.json').write_text(json.dumps(receipt,indent=2)+'\n')
    shutil.copyfile(__file__,evidence/'stage_mandelbrot.py')
    (evidence/'manifest.json').write_text(json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
    print(json.dumps(receipt),flush=True)
    assert result.returncode == 0, 'Inspect receipt; never replay an uncertain transfer blindly'


if __name__ == '__main__':
    main()
