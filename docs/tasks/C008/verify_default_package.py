"""Survey the default Oryx Flexe package while preserving user edits.

Preserve all user files. This reads supplied files and syncs the filesystem;
it reports differences and never launches the emulator or rewrites files.
"""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import argparse
import json
import shlex
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PACKAGE = ROOT/'docs/tasks/C010/build/manual-001'
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
expected_manifest = '1a9e5b2c1d4300ff25ec766f63487bc0c577aeeb80b1a96378dac364dfacee9f'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--name',default='default-emulator-package-001')
args = parser.parse_args()
assert args.name.replace('-','').isalnum()
assert digest(PACKAGE/'manifest.json') == expected_manifest
files = json.loads((PACKAGE/'manifest.json').read_text())['files']
files = dict(files, **{'manifest.json':expected_manifest})
assert len(files) == 53
for name,expected in files.items():
    assert digest(PACKAGE/name) == expected,name
remote = r'''
from pathlib import Path
import hashlib,json,subprocess,sys
assert subprocess.check_output(['hostname'],text=True).strip() == 'oryx-linuxlite'
launcher = Path('/home/smith/.local/bin/flexe-agon-emulator')
assert 'profile=/home/smith/Agon/flexe-emulator' in launcher.read_text().splitlines()
root = Path('/home/smith/Agon/flexe-emulator/sdcard/basic-compiled')
assert root.is_dir() and root.resolve() == root
files = json.load(sys.stdin)
mismatches = []
for name,expected in files.items():
    path = root/name
    assert path.resolve() == path and path.is_relative_to(root)
    actual = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None
    if actual != expected:
        mismatches.append(dict(file=name,expected=expected,actual=actual))
subprocess.run(['sync','-f',str(root)],check=True)
print(json.dumps(dict(all_supplied_files_match=not mismatches,mismatches=mismatches,
    matching_files=len(files)-len(mismatches),files=len(files),synced=True,
    package_manifest_sha256=files['manifest.json'],no_files_rewritten=True,
    user_files_preserved=True,no_emulator_launch=True,
    launcher_sha256=hashlib.sha256(launcher.read_bytes()).hexdigest())))
'''
evidence = TASK/'evidence'/args.name
evidence.mkdir(parents=True,exist_ok=False)
started = datetime.now(timezone.utc).isoformat()
result = subprocess.run(['ssh','-o','BatchMode=yes','oryx-linuxlite',
    'python3 -c '+shlex.quote(remote)],input=json.dumps(files),capture_output=True,text=True)
report = dict(started=started,finished=datetime.now(timezone.utc).isoformat(),
    returncode=result.returncode,stdout=result.stdout,stderr=result.stderr,
    package_manifest_sha256=expected_manifest,manual_validation=False,
    scope='Fresh default-profile and supplied-file verification; no emulator execution')
(evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
shutil.copyfile(__file__,evidence/'verify_default_package.py')
shutil.copyfile(PACKAGE/'manifest.json',evidence/'package-manifest.json')
(evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
    for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
print(json.dumps(report),flush=True)
assert result.returncode == 0,'Inspect receipt before changing any file'
assert len(json.loads(result.stdout)['mismatches'])+json.loads(result.stdout)['matching_files'] == 53
