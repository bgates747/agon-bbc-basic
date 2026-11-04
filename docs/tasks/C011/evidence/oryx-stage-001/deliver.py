"""Stage portable benchmark archive, or deploy to the selected mounted C8 card.

No emulator/hardware process operations. Existing differing files are preserved.
"""
from pathlib import Path
from datetime import datetime,timezone
import argparse,hashlib,io,json,re,shlex,shutil,subprocess,tarfile
TASK=Path(__file__).resolve().parent
REMOTE=r'''
from pathlib import Path
import hashlib,io,json,os,subprocess,sys,tarfile,tempfile
assert subprocess.check_output(['hostname'],text=True).strip()=='oryx-linuxlite'
kind=sys.argv[1];data=sys.stdin.buffer.read();sha=lambda b:hashlib.sha256(b).hexdigest()
with tarfile.open(fileobj=io.BytesIO(data),mode='r:') as archive:
    members=archive.getmembers()
    assert all(m.isfile() and not m.issym() and m.name.startswith('benchmarks/') and '..' not in Path(m.name).parts for m in members)
    files={m.name:archive.extractfile(m).read() for m in members}
assert len(files)==len(members)
manifest=json.loads(files['benchmarks/manifest.json'])
assert set(files)=={'benchmarks/'+n for n in manifest['files']}|{'benchmarks/manifest.json'}
for name,meta in manifest['files'].items():assert sha(files['benchmarks/'+name])==meta['sha256']
if kind=='stage':
    path=Path('/home/smith/Agon/mystuff/c011-console8-001.tar')
    assert path.parent.is_dir() and path.parent.resolve()==path.parent
    assert path.resolve()==path
    if path.exists():assert sha(path.read_bytes())==sha(data),'Preserve existing archive'
    else:
        with path.open('xb') as f:f.write(data);f.flush();os.fsync(f.fileno())
    subprocess.run(['sync','-f',str(path)],check=True)
    print(json.dumps(dict(staged=str(path),archive_sha256=sha(data),synced=True,card_written=False,no_emulator=True)))
else:
    root=Path('/run/media/smith/AGONC8/mystuff/basic-compiled')
    assert root.is_dir() and root.resolve()==root,'Selected Console8 card root is absent; no writes'
    mount='/run/media/smith/AGONC8'
    assert subprocess.check_output(['findmnt','-rn','-o','TARGET,FSTYPE','-T',mount],text=True).strip()==mount+' vfat'
    assert 'rw' in subprocess.check_output(['findmnt','-rn','-o','OPTIONS','-T',mount],text=True).strip().split(',')
    assert sha((root/'compiler.bin').read_bytes())==manifest['compiler_sha256'],'Unexpected installed compiler'
    actions=[]
    for name,b in files.items():
        path=root/name
        assert path.resolve()==path and path.is_relative_to(root)
        if path.exists():assert sha(path.read_bytes())==sha(b),('Preserve changed file',name)
        else:actions.append(name)
    for name in actions:
        path=root/name;path.parent.mkdir(parents=True,exist_ok=True)
        fd,tmp=tempfile.mkstemp(prefix='.c011-',dir=path.parent)
        try:
            with os.fdopen(fd,'wb') as f:f.write(files[name]);f.flush();os.fsync(f.fileno())
            os.chmod(tmp,0o644);os.replace(tmp,path)
        finally:
            if os.path.exists(tmp):os.unlink(tmp)
    subprocess.run(['sync','-f',str(root)],check=True)
    print(json.dumps(dict(card_written=True,written=actions,synced=True,left_mounted=True,no_emulator=True)))
'''

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--package',type=Path,required=True);p.add_argument('--target',choices=['stage','card'],required=True)
    p.add_argument('--name',required=True);a=p.parse_args()
    assert re.fullmatch(r'[a-z0-9-]+',a.name)
    package=a.package.resolve(strict=True);assert package.is_relative_to(TASK/'build')
    sha=lambda b:hashlib.sha256(b).hexdigest()
    manifest=json.loads((package/'manifest.json').read_text())
    stream=io.BytesIO()
    with tarfile.open(fileobj=stream,mode='w',format=tarfile.USTAR_FORMAT) as archive:
        for name in sorted(set(manifest['files'])|{'manifest.json'}):
            assert Path(name).name==name and not (package/name).is_symlink()
            data=(package/name).read_bytes()
            if name!='manifest.json':assert sha(data)==manifest['files'][name]['sha256']
            item=tarfile.TarInfo('benchmarks/'+name);item.size=len(data);item.mode=0o644
            archive.addfile(item,io.BytesIO(data))
    evidence=TASK/'evidence'/a.name;evidence.mkdir(parents=True,exist_ok=False)
    started=datetime.now(timezone.utc).isoformat()
    result=subprocess.run(['ssh','-o','BatchMode=yes','oryx-linuxlite','python3 -c '+shlex.quote(REMOTE)+' '+a.target],input=stream.getvalue(),capture_output=True)
    report=dict(started=started,finished=datetime.now(timezone.utc).isoformat(),target=a.target,
        returncode=result.returncode,stdout=result.stdout.decode(),stderr=result.stderr.decode(),
        manifest_sha256=sha((package/'manifest.json').read_bytes()),archive_sha256=sha(stream.getvalue()),no_target_execution=True)
    (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    shutil.copyfile(__file__,evidence/'deliver.py')
    (evidence/'evidence-manifest.json').write_text(json.dumps({f.name:sha(f.read_bytes()) for f in sorted(evidence.iterdir())},indent=2)+'\n')
    print(json.dumps(report));assert result.returncode==0,'Inspect frozen receipt before any retry'

if __name__=='__main__':main()
