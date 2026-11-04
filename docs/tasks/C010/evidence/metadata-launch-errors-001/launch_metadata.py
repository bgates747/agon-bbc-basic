"""Launch one finite metadata qualification job; never install a startup unit."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import hashlib
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--role', choices=['build','hosted','native','errors'], required=True)
args = parser.parse_args()
source = TASK/'candidate-meta.bas'
assert digest(source) == '70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e'
if args.role == 'build':
    script = TASK/'bootstrap_fit_self.py'
    arguments = ['--source',str(source),'--name','meta-native-build-001','--timeout','7200']
    maximum = 7500
else:
    script = TASK/'metadata_pipeline.py'
    arguments = ['--role',args.role]
    maximum = 16000 if args.role != 'hosted' else 3600
unit = 'bbc-basic-c010-meta-'+args.role+'-001'
logfile = TASK/'build/controller-logs'/(unit+'.log')
assert not logfile.exists()
evidence = TASK/'evidence'/('metadata-launch-'+args.role+'-001')
evidence.mkdir(parents=True,exist_ok=False)
command = ['systemd-run','--user','--collect','--service-type=exec','--unit='+unit,
    '--property=WorkingDirectory='+str(ROOT),'--property=RuntimeMaxSec='+str(maximum),
    '--property=TimeoutStopSec=90','--property=KillMode=mixed',
    '--property=StandardOutput=append:'+str(logfile),'--property=StandardError=inherit',
    str(ROOT/'.venv/bin/python'),str(script),*arguments]
result = subprocess.run(command,capture_output=True,text=True)
report = dict(started=datetime.now(timezone.utc).isoformat(),role=args.role,unit=unit,
    source_sha256=digest(source),script=str(script.relative_to(ROOT)),script_sha256=digest(script),
    arguments=arguments,runtime_max_seconds=maximum,log=str(logfile.relative_to(ROOT)),
    returncode=result.returncode,stdout=result.stdout,stderr=result.stderr,
    startup_unit_installed=False,launch_is_not_qualification=True)
(evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
shutil.copyfile(__file__,evidence/'launch_metadata.py')
shutil.copyfile(script,evidence/script.name)
(evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
    for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
print(json.dumps(report),flush=True)
assert result.returncode == 0
