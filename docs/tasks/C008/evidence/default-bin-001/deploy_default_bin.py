"""Deploy the qualified compiler to the existing default emulator SD bin."""
from pathlib import Path
from datetime import datetime, timezone
import base64, hashlib, json, shlex, shutil, subprocess
ROOT=Path(__file__).resolve().parents[3]
sha=lambda b:hashlib.sha256(b).hexdigest()
data=(ROOT/'compiler/bin/compiler.bin').read_bytes()
notice=(ROOT/'compiler/bin/LICENSE.txt').read_bytes()
assert sha(data)=='40e4ae06730b6735696f5f07962efd10e6c9cfbdc44a81b65dd6e9ce1c82355a'
assert sha(notice)=='cc8e92d92cf12fb1d04ddae0b573367f14188df5fcd6c7909d36486ff53a108a'
remote=r'''
from pathlib import Path
import base64,hashlib,json,os,subprocess,sys,tempfile
assert subprocess.check_output(['hostname'],text=True).strip()=='oryx-linuxlite'
profile=Path('/home/smith/Agon/flexe-emulator')
assert 'profile='+str(profile) in Path('/home/smith/.local/bin/flexe-agon-emulator').read_text().splitlines()
root=profile/'sdcard/bin'
assert root.is_dir() and root.resolve()==root
sha=lambda b:hashlib.sha256(b).hexdigest()
payload=json.load(sys.stdin)
items={name:base64.b64decode(item['data'],validate=True) for name,item in payload.items()}
for name,data in items.items():
    assert sha(data)==payload[name]['sha256']
    target=root/name
    assert target.resolve()==target
old=(root/'compiler.bin').read_bytes()
assert sha(old) in ['299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0',payload['compiler.bin']['sha256']],'Unexpected existing compiler'
license=root/'compiler-license.txt'
assert not license.exists() or license.read_bytes()==items['compiler-license.txt']
for name,data in items.items():
    fd,tmp=tempfile.mkstemp(prefix='.compiler-update-',dir=root)
    try:
        with os.fdopen(fd,'wb') as f:
            f.write(data);f.flush();os.fsync(f.fileno())
        os.chmod(tmp,0o644)
        os.replace(tmp,root/name)
    finally:
        if os.path.exists(tmp):os.unlink(tmp)
subprocess.run(['sync','-f',str(root)],check=True)
print(json.dumps(dict(previous_sha256=sha(old),previous_bytes=len(old),
    installed={n:dict(bytes=len(d),sha256=sha(d)) for n,d in items.items()},
    synced=True,no_emulator_control=True)))
'''
evidence=Path(__file__).resolve().parent/'evidence/default-bin-001'
evidence.mkdir(parents=True,exist_ok=False)
payload={n:dict(data=base64.b64encode(d).decode(),sha256=sha(d)) for n,d in [('compiler.bin',data),('compiler-license.txt',notice)]}
started=datetime.now(timezone.utc).isoformat()
result=subprocess.run(['ssh','-o','BatchMode=yes','oryx-linuxlite','python3 -c '+shlex.quote(remote)],input=json.dumps(payload),text=True,capture_output=True)
report=dict(started=started,finished=datetime.now(timezone.utc).isoformat(),returncode=result.returncode,stdout=result.stdout,stderr=result.stderr)
(evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
shutil.copyfile(__file__,evidence/'deploy_default_bin.py')
(evidence/'compiler.dat').write_bytes(data)
(evidence/'compiler-license.txt').write_bytes(notice)
(evidence/'manifest.json').write_text(json.dumps({p.name:sha(p.read_bytes()) for p in sorted(evidence.iterdir())},indent=2)+'\n')
print(json.dumps(report))
assert result.returncode==0
