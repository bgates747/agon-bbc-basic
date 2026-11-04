"""Supply the pristine starter under a separate name, preserving edited hello.bas."""
from pathlib import Path
from datetime import datetime,timezone
import base64,hashlib,json,shlex,shutil,subprocess

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
source = ROOT/'docs/tasks/C010/build/manual-001/hello.bas'
digest = lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
expected = '53fb3b335a5eeca2f037c1464697fdf4010ac9b3f1eebbe2b213710c0a4a92a3'
assert digest(source) == expected
remote = r'''
from pathlib import Path
import base64,hashlib,json,os,subprocess,sys
assert subprocess.check_output(['hostname'],text=True).strip() == 'oryx-linuxlite'
root = Path('/home/smith/Agon/flexe-emulator/sdcard/basic-compiled')
assert root.resolve() == root and root.is_dir()
sha = lambda b:hashlib.sha256(b).hexdigest()
assert sha((root/'manifest.json').read_bytes()) == '1a9e5b2c1d4300ff25ec766f63487bc0c577aeeb80b1a96378dac364dfacee9f'
payload = json.load(sys.stdin)
data = base64.b64decode(payload['data'],validate=True)
assert sha(data) == payload['sha256']
preserved = sha((root/'hello.bas').read_bytes())
target = root/'hello-package.bas'
assert target.resolve() == target
written = False
if target.exists():
    assert sha(target.read_bytes()) == payload['sha256'],'Preserve existing hello-package.bas'
else:
    with target.open('xb') as file:
        assert file.write(data) == len(data)
        file.flush();os.fsync(file.fileno())
    written = True
subprocess.run(['sync','-f',str(root)],check=True)
print(json.dumps(dict(supplied_starter='hello-package.bas',source_sha256=payload['sha256'],
    written=written,synced=True,preserved_user_hello_sha256=preserved,
    no_user_file_overwrite=True,no_emulator_launch=True)))
'''
evidence = TASK/'evidence/default-starter-preserved-001'
evidence.mkdir(parents=True,exist_ok=False)
started = datetime.now(timezone.utc).isoformat()
result = subprocess.run(['ssh','-o','BatchMode=yes','oryx-linuxlite',
    'python3 -c '+shlex.quote(remote)],input=json.dumps(dict(sha256=expected,
        data=base64.b64encode(source.read_bytes()).decode())),text=True,capture_output=True)
report = dict(started=started,finished=datetime.now(timezone.utc).isoformat(),
    returncode=result.returncode,stdout=result.stdout,stderr=result.stderr,manual_validation=False)
(evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
shutil.copyfile(__file__,evidence/'preserve_default_starter.py')
shutil.copyfile(source,evidence/'hello-package.bas')
(evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
    for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
print(json.dumps(report),flush=True)
assert result.returncode == 0
