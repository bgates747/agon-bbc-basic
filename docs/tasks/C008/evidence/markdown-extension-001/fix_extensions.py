"""Correct the one Markdown filename and its two package references on the card."""
from pathlib import Path
import hashlib, json, subprocess

TASK = Path(__file__).resolve().parent
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
old = TASK/'build/manual-002'
new = TASK/'build/manual-003'
a = json.loads((old/'manifest.json').read_text())
b = json.loads((new/'manifest.json').read_text())
expected = dict(a['files'])
expected['compatibility.md'] = expected.pop('compatibility.txt')
expected['readme.txt'] = b['files']['readme.txt']
assert expected == b['files']
script = f'''
set -eu
root=/run/media/smith/AGONC8/mystuff/basic-compiled
mount=/run/media/smith/AGONC8
test "$(findmnt -rn -o TARGET,FSTYPE -T "$mount")" = "$mount vfat"
case ",$(findmnt -rn -o OPTIONS -T "$mount")," in *,rw,*) ;; *) exit 1;; esac
test "$(readlink -f "$root")" = "$root"
check() {{
  actual=$(sha256sum "$root/$2")
  test "${{actual%% *}}" = "$1"
}}
check {sha(old/'manifest.json')} manifest.json
check {a['files']['readme.txt']} readme.txt
check {a['files']['compatibility.txt']} compatibility.txt
test ! -e "$root/compatibility.md"
test ! -L "$root/compatibility.md"
mv -n "$root/compatibility.txt" "$root/compatibility.md"
sed -i 's/compatibility[.]txt/compatibility.md/g' "$root/readme.txt"
sed -i 's/compatibility[.]txt/compatibility.md/g; s/{a['files']['readme.txt']}/{b['files']['readme.txt']}/g' "$root/manifest.json"
sync -f "$mount"
printf 'RENAMED_REFERENCES_UPDATED_AND_SYNCED\\n'
'''
result = subprocess.run(['ssh','-o','BatchMode=yes','oryx-linuxlite',script],capture_output=True,text=True)
evidence = TASK/'evidence/markdown-extension-001'
evidence.mkdir(parents=True,exist_ok=False)
record = dict(scope='Filename/reference correction only',returncode=result.returncode,stdout=result.stdout,stderr=result.stderr,
              renamed={'compatibility.txt':'compatibility.md'},updated=['readme.txt','manifest.json'],
              expected_package_manifest_sha256=sha(new/'manifest.json'),other_markdown_txt_files_found=False,
              manual_validation=False)
(evidence/'results.json').write_text(json.dumps(record,indent=2)+'\n')
(evidence/'package-manifest.json').write_bytes((new/'manifest.json').read_bytes())
(evidence/'readme.txt').write_bytes((new/'readme.txt').read_bytes())
(evidence/'fix_extensions.py').write_bytes(Path(__file__).read_bytes())
(evidence/'manifest.json').write_text(json.dumps({p.name:sha(p) for p in sorted(evidence.iterdir())},indent=2)+'\n')
print(json.dumps(record,indent=2))
assert result.returncode == 0 and result.stdout == 'RENAMED_REFERENCES_UPDATED_AND_SYNCED\n'
