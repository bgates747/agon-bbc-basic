"""Launch only the authorized finite C010 jobs as transient user services.

No installed/enabled unit or login/startup configuration is written. All test
artifacts and controller logs remain in the project. Units collect on exit.
"""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    assert digest(TASK/'candidate-fit.bas') == 'b8afbfdb51de803e7c8e670d4c00e434371e3f2d0af4ce354ce29f3580cdd875'
    evidence = TASK/'evidence/durable-launch-001'
    evidence.mkdir(parents=True,exist_ok=False)
    logs = TASK/'build/controller-logs'
    logs.mkdir(parents=True,exist_ok=True)
    jobs = [
        ('bbc-basic-c010-fit-build-002','bootstrap_fit_self.py',
         ['--name','fit-native-build-002','--timeout','7200'],7500),
        ('bbc-basic-c010-fit-pipeline-002','fit_pipeline_v2.py',[],16000),
        ('bbc-basic-c010-fit-errors-002','fit_error_pipeline_v2.py',[],16000),
    ]
    report = dict(scope='Finite project-owned user services; no startup installation/hardware/Oryx operation',
        started=datetime.now(timezone.utc).isoformat(),source_sha256=digest(TASK/'candidate-fit.bas'),
        launch_is_not_qualification=True,jobs=[],completed=False)
    try:
        for unit,script,args,maximum in jobs:
            logfile = logs/(unit+'.log')
            assert not logfile.exists()
            command = ['systemd-run','--user','--collect','--service-type=exec','--unit='+unit,
                '--property=WorkingDirectory='+str(ROOT),
                '--property=RuntimeMaxSec='+str(maximum),
                '--property=TimeoutStopSec=90','--property=KillMode=mixed',
                '--property=StandardOutput=append:'+str(logfile),
                '--property=StandardError=inherit',str(ROOT/'.venv/bin/python'),str(TASK/script),*args]
            result = subprocess.run(command,capture_output=True,text=True)
            report['jobs'].append(dict(unit=unit,script=script,script_sha256=digest(TASK/script),
                arguments=args,runtime_max_seconds=maximum,log=str(logfile.relative_to(ROOT)),
                returncode=result.returncode,stdout=result.stdout,stderr=result.stderr))
            assert result.returncode == 0,report['jobs'][-1]
        report['completed'] = True
    finally:
        (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
        shutil.copyfile(__file__,evidence/'launch_durable.py')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
        print(json.dumps(report),flush=True)


if __name__ == '__main__':
    main()
