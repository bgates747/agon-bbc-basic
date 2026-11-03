"""Update only unchanged managed files; preserve all user programs and results."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import hashlib
import io
import json
import re
import shlex
import shutil
import subprocess
import tarfile

TASK = Path(__file__).resolve().parent
DESTINATIONS = dict(card='/run/media/smith/AGONC8/mystuff/basic-compiled',
    emulator='/home/smith/Agon/flexe-emulator/sdcard/basic-compiled')
REMOTE = r'''
from pathlib import Path
import hashlib, io, json, os, subprocess, sys, tarfile, tempfile
assert subprocess.check_output(['hostname'],text=True).strip() == 'oryx-linuxlite'
root = Path(sys.argv[1]); kind = sys.argv[2]
assert root.is_dir() and root.resolve() == root
if kind == 'card':
    mount = '/run/media/smith/AGONC8'
    assert subprocess.check_output(['findmnt','-rn','-o','TARGET,FSTYPE','-T',mount],text=True).strip() == mount+' vfat'
    assert 'rw' in subprocess.check_output(['findmnt','-rn','-o','OPTIONS','-T',mount],text=True).strip().split(',')
archive = tarfile.open(fileobj=io.BytesIO(sys.stdin.buffer.read()),mode='r:')
members = archive.getmembers()
assert all(m.isfile() and not m.issym() for m in members)
payload = {m.name:archive.extractfile(m).read() for m in members}
assert len(payload) == len(members)
plan = json.loads(payload.pop('.c010-plan.json'))
sha = lambda b:hashlib.sha256(b).hexdigest()
assert sha((root/'manifest.json').read_bytes()) == plan['previous_manifest_sha256']
assert set(payload) == set(plan['files'])
actions = []
for name, rule in plan['files'].items():
    path = root/name
    assert path.resolve() == path and path.is_relative_to(root)
    assert sha(payload[name]) == rule['new']
    if path.exists():
        current = sha(path.read_bytes())
        if rule['old'] is None:
            assert current == rule['new'], ('Preserve existing user file',name,current)
            continue
        assert current == rule['old'], ('Managed file changed since packaging',name,current)
    else:
        assert rule['old'] is None, ('Missing managed file',name)
    actions.append(name)
# All checks precede all writes. Replace the managed manifest last.
for name in sorted(actions,key=lambda n:n == 'manifest.json'):
    path = root/name
    path.parent.mkdir(parents=True,exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix='.c010-',dir=path.parent)
    try:
        with os.fdopen(fd,'wb') as file: file.write(payload[name])
        os.replace(temporary,path)
    finally:
        if os.path.exists(temporary): os.unlink(temporary)
subprocess.run(['sync','-f',str(root)],check=True)
print(json.dumps(dict(updated_and_synced=True,written=actions,
    identical_existing_additions_preserved=[n for n in plan['files'] if n not in actions],
    package_manifest_sha256=sha((root/'manifest.json').read_bytes()),
    no_program_execution=True,no_emulator_launch=True,no_unmount=True)))
'''


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--previous', type=Path, required=True)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--target', choices=DESTINATIONS, required=True)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    previous = args.previous.resolve(strict=True)
    package = args.package.resolve(strict=True)
    assert package.is_relative_to(TASK/'build')
    old = json.loads((previous/'manifest.json').read_text())
    new = json.loads((package/'manifest.json').read_text())
    assert new['schema'] == 'bbc-manual-package-v2' and new['package_root'] == '.'
    assert set(old['files']) <= set(new['files'])
    assert digest(previous/'manifest.json') == '7fe79c811878fc9e151d1689a8a5156e631e394dd66c75396e626868ed591b26'
    for directory, metadata in [(previous, old), (package, new)]:
        assert set(metadata['files']) | {'manifest.json'} == {str(p.relative_to(directory)) for p in directory.rglob('*') if p.is_file()}
        for name, expected in metadata['files'].items():
            assert re.fullmatch(r'[A-Za-z0-9_./-]+', name) and '..' not in Path(name).parts
            assert not Path(name).is_absolute() and digest(directory/name) == expected
    names = [name for name in new['files'] if old['files'].get(name) != new['files'][name]]+['manifest.json']
    plan = dict(previous_manifest_sha256=digest(previous/'manifest.json'),
        files={name:dict(old=digest(previous/name) if name == 'manifest.json' else old['files'].get(name),
            new=digest(package/name)) for name in names})
    stream = io.BytesIO()
    with tarfile.open(fileobj=stream, mode='w', format=tarfile.USTAR_FORMAT) as archive:
        encoded = (json.dumps(plan)+'\n').encode()
        member = tarfile.TarInfo('.c010-plan.json'); member.size=len(encoded)
        archive.addfile(member, io.BytesIO(encoded))
        for name in names:
            assert not (package/name).is_symlink()
            archive.add(package/name, arcname=name, recursive=False)
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True, exist_ok=False)
    started = datetime.now(timezone.utc).isoformat()
    command = 'python3 -c '+shlex.quote(REMOTE)+' '+shlex.quote(DESTINATIONS[args.target])+' '+args.target
    result = subprocess.run(['ssh','-o','BatchMode=yes','oryx-linuxlite',command],
        input=stream.getvalue(), capture_output=True)
    report = dict(scope='Bounded managed-file update; no program/emulator/hardware execution',
        target=args.target, destination=DESTINATIONS[args.target], started=started,
        finished=datetime.now(timezone.utc).isoformat(), returncode=result.returncode,
        stdout=result.stdout.decode(errors='replace'), stderr=result.stderr.decode(errors='replace'),
        package_manifest_sha256=digest(package/'manifest.json'),
        manual_validation=False, user_files_not_selected=True)
    (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    (evidence/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
    for label, directory in [('before',previous),('after',package)]:
        for name in names:
            if (directory/name).exists():
                target = evidence/label/name
                target.parent.mkdir(parents=True,exist_ok=True)
                shutil.copyfile(directory/name,target)
    shutil.copyfile(__file__,evidence/'update_package.py')
    (evidence/'manifest.json').write_text(json.dumps({str(p.relative_to(evidence)):digest(p)
        for p in sorted(evidence.rglob('*')) if p.is_file() and p != evidence/'manifest.json'},indent=2)+'\n')
    print(json.dumps(report),flush=True)
    assert result.returncode == 0, 'Inspect receipt; do not replay a failed update blindly'
    remote = json.loads(report['stdout'])
    assert remote['updated_and_synced'] and remote['package_manifest_sha256'] == report['package_manifest_sha256']


if __name__ == '__main__':
    main()
