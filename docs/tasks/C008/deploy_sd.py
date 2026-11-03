"""Initial deployment to the Author's exact Oryx card directory.

Validate the mounted volume and refuse a nonempty target. Stream only the
locally verified package, synchronize the card and leave it mounted. No target
program runs, firmware writes, deletions or overwrites are permitted.
"""
from pathlib import Path
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
HOST = 'oryx-linuxlite'
DESTINATION = '/run/media/smith/AGONC8/mystuff/basic-compiled'
REMOTE = r'''
set -eu
mount=/run/media/smith/AGONC8
destination=/run/media/smith/AGONC8/mystuff/basic-compiled
test "$(hostname)" = oryx-linuxlite
test "$(findmnt -rn -o TARGET -T "$mount")" = "$mount"
test "$(findmnt -rn -o FSTYPE -T "$mount")" = vfat
options=$(findmnt -rn -o OPTIONS -T "$mount")
case ",$options," in *,rw,*) ;; *) echo 'Card is not read/write' >&2; exit 1;; esac
test -d "$destination"
test ! -L "$destination"
test "$(readlink -f "$destination")" = "$destination"
if test -n "$(find "$destination" -mindepth 1 -maxdepth 1 -print -quit)"; then
  echo 'Refusing nonempty target: preserve existing user files and plan an explicit update' >&2
  exit 1
fi
tar --extract --keep-old-files --no-same-owner --no-same-permissions --file=- --directory="$destination"
sync -f "$mount"
printf 'COPIED_AND_SYNCED\n'
find "$destination" -type f | wc -l
findmnt -rn -o TARGET,FSTYPE -T "$mount"
'''


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--receipt', type=Path, required=True)
    args = parser.parse_args()
    package = args.package.resolve(strict=True)
    assert package.is_relative_to(TASK / 'build')
    metadata = json.loads((package / 'manifest.json').read_text())
    assert metadata['schema'] == 'bbc-manual-package-v2' and metadata['package_root'] == '.'
    names = set(metadata['files']) | {'manifest.json'}
    actual = {str(p.relative_to(package)) for p in package.rglob('*') if p.is_file()}
    assert names == actual
    for name, expected in metadata['files'].items():
        p = package / name
        assert p.resolve().is_relative_to(package) and not p.is_symlink()
        assert sha(p) == expected, name
    # Preserve only regular files and their relative paths; no archive links.
    stream = io.BytesIO()
    with tarfile.open(fileobj=stream, mode='w', format=tarfile.USTAR_FORMAT) as archive:
        for name in sorted(names):
            p = package / name
            assert p.is_file() and not p.is_symlink()
            archive.add(p, arcname=name, recursive=False)
    receipt = args.receipt.resolve()
    assert receipt.is_relative_to(TASK) and not receipt.exists()
    started = datetime.now(timezone.utc).isoformat()
    result = subprocess.run(['ssh', '-o', 'BatchMode=yes', HOST, REMOTE],
                            input=stream.getvalue(), stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, check=False)
    stdout = result.stdout.decode(errors='replace')
    stderr = result.stderr.decode(errors='replace')
    record = dict(scope='Initial SD file deployment only; no compiler/editor/hardware test execution',
                  started=started, finished=datetime.now(timezone.utc).isoformat(),
                  host=HOST, destination=DESTINATION, files=len(names),
                  package_manifest_sha256=sha(package / 'manifest.json'),
                  returncode=result.returncode, stdout=stdout, stderr=stderr,
                  synchronized_and_left_mounted=result.returncode == 0,
                  manual_validation=False, firmware_changed=False)
    receipt.parent.mkdir(parents=True, exist_ok=True)
    receipt.write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record, indent=2))
    assert result.returncode == 0, 'Deployment failed; inspect receipt; do not replay blindly'
    lines = stdout.splitlines()
    assert lines == ['COPIED_AND_SYNCED', str(len(names)), '/run/media/smith/AGONC8 vfat']


if __name__ == '__main__':
    main()
