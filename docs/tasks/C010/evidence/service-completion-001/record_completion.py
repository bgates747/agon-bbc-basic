"""Read-only confirmation that our finite services and CPU jobs have closed."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib
import json
import os
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
result = subprocess.run(['systemctl','--user','list-units','--all',
    'bbc-basic-c010-*','--no-legend','--plain'],capture_output=True,text=True,check=True)
owned = []
for directory in Path('/proc').iterdir():
    if not directory.name.isdigit() or int(directory.name) == os.getpid():
        continue
    try:
        comm = (directory/'comm').read_text().strip().lower()
        if not (comm.startswith('python') or ('agon' in comm and 'emulat' in comm)):
            continue
        cwd = (directory/'cwd').resolve(strict=True)
        argv = (directory/'cmdline').read_bytes().split(b'\0')
        if comm.startswith('python') and len(argv)>1:
            script = Path(os.fsdecode(argv[1]))
            if not script.is_absolute():
                script = cwd/script
            if script.resolve().is_relative_to(TASK) and script.suffix == '.py':
                owned.append(dict(pid=int(directory.name),kind='C010 Python controller',script=str(script)))
        elif cwd == ROOT/'.emulator' or cwd.is_relative_to(ROOT/'.emulator'):
            owned.append(dict(pid=int(directory.name),kind='Project CLI emulator',cwd=str(cwd)))
    except (FileNotFoundError,ProcessLookupError,PermissionError):
        continue
report = dict(observed=datetime.now(timezone.utc).isoformat(),
    service_listing=result.stdout,service_stderr=result.stderr,
    owned_controllers_or_emulators=owned,all_owned_jobs_closed=not owned and not result.stdout.strip(),
    scope='Read-only Pi process/service check; no hardware or Oryx access')
evidence = TASK/'evidence/service-completion-001'
evidence.mkdir(parents=True,exist_ok=False)
shutil.copyfile(__file__,evidence/'record_completion.py')
(evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
(evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
    for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
print(json.dumps(report),flush=True)
assert report['all_owned_jobs_closed']
