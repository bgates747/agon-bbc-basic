"""Update only unchanged managed documentation on the Author's mounted card.

Machine-specific deployment coordinates belong in this repository tool, never
in the consumer payload. User files, programs and outputs are preserved.
"""
from pathlib import Path
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
import re
import shlex
import shutil
import subprocess
import tarfile

TASK = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--previous', type=Path, required=True)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--evidence', type=Path, required=True)
    args = parser.parse_args()
    old = args.previous.resolve(strict=True)
    new = args.package.resolve(strict=True)
    evidence = args.evidence.resolve()
    assert old.is_relative_to(TASK / 'build') and new.is_relative_to(TASK / 'build')
    assert evidence.is_relative_to(TASK / 'evidence') and not evidence.exists()
    a = json.loads((old / 'manifest.json').read_text())
    b = json.loads((new / 'manifest.json').read_text())
    assert b['schema'] == 'bbc-manual-package-v2' and b['package_root'] == '.'
    assert a['files'].keys() == b['files'].keys()
    changed = sorted(name for name in a['files'] if a['files'][name] != b['files'][name])
    assert changed
    assert all(Path(name).suffix in {'.txt', '.md', '.json'} and
               not name.endswith('expected.txt') for name in changed)
    assert all(re.fullmatch(r'[A-Za-z0-9_./-]+', name) and
               not Path(name).is_absolute() and '..' not in Path(name).parts
               for name in b['files'])
    for directory, metadata in [(old, a), (new, b)]:
        for name, expected in metadata['files'].items():
            assert sha(directory / name) == expected, name
    checks = '\n'.join(f'check {a["files"][name]} {shlex.quote(name)}' for name in changed)
    replacements = '\n'.join(f'replace {shlex.quote(name)}' for name in changed + ['manifest.json'])
    script = f'''
set -eu
root=/run/media/smith/AGONC8/mystuff/basic-compiled
mount=/run/media/smith/AGONC8
test "$(hostname)" = oryx-linuxlite
test "$(findmnt -rn -o TARGET,FSTYPE -T "$mount")" = "$mount vfat"
case ",$(findmnt -rn -o OPTIONS -T "$mount")," in *,rw,*) ;; *) exit 1;; esac
test "$(readlink -f "$root")" = "$root"
check() {{
  test "$(readlink -f "$root/$2")" = "$root/$2"
  actual=$(sha256sum "$root/$2")
  test "${{actual%% *}}" = "$1"
}}
check {sha(old / 'manifest.json')} manifest.json
{checks}
stage=$(mktemp -d /tmp/bbc-package-update.XXXXXX)
temporary=''
trap 'if test -n "$temporary"; then rm -f -- "$temporary"; fi; rm -rf -- "$stage"' EXIT
tar --extract --no-same-owner --no-same-permissions --file=- --directory="$stage"
replace() {{
  temporary=$(mktemp "$root/$(dirname "$1")/.c008-update.XXXXXX")
  cp -- "$stage/$1" "$temporary"
  mv -f -- "$temporary" "$root/$1"
  temporary=''
}}
{replacements}
sync -f "$mount"
printf 'UPDATED_AND_SYNCED\\n'
'''
    stream = io.BytesIO()
    with tarfile.open(fileobj=stream, mode='w', format=tarfile.USTAR_FORMAT) as archive:
        for name in changed + ['manifest.json']:
            archive.add(new / name, arcname=name, recursive=False)
    evidence.mkdir(parents=True)
    started = datetime.now(timezone.utc).isoformat()
    result = subprocess.run(['ssh', '-o', 'BatchMode=yes', 'oryx-linuxlite', script],
                            input=stream.getvalue(), capture_output=True)
    record = dict(scope='Portable package documentation update only; no program execution',
                  started=started, finished=datetime.now(timezone.utc).isoformat(),
                  returncode=result.returncode, stdout=result.stdout.decode(errors='replace'),
                  stderr=result.stderr.decode(errors='replace'),
                  changed_files=changed + ['manifest.json'],
                  previous_manifest_sha256=sha(old / 'manifest.json'),
                  package_manifest_sha256=sha(new / 'manifest.json'),
                  user_files_touched=False, manual_validation=False)
    (evidence / 'results.json').write_text(json.dumps(record, indent=2) + '\n')
    for label, directory in [('before', old), ('after', new)]:
        for name in changed + ['manifest.json']:
            target = evidence / label / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(directory / name, target)
    for source in [Path(__file__), TASK / 'prepare.py']:
        shutil.copyfile(source, evidence / source.name)
    manifest = {str(p.relative_to(evidence)): sha(p) for p in sorted(evidence.rglob('*')) if p.is_file()}
    (evidence / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(record, indent=2))
    assert result.returncode == 0 and result.stdout == b'UPDATED_AND_SYNCED\n', 'Inspect receipt; do not replay blindly'


if __name__ == '__main__':
    main()
