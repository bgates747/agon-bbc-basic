"""Continue the authorized C010 native checks when the fresh build completes.

Two owned profiles are used: root for self-building and c010-wire for serial
regressions. No hardware, Oryx emulator control or live promotion occurs here.
"""
from pathlib import Path
import hashlib
import json
import os
import shutil
import signal
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PYTHON = ROOT/'.venv/bin/python'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    evidence = TASK/'evidence/fit-native-pipeline-001'
    evidence.mkdir(parents=True,exist_ok=False)
    shutil.copyfile(__file__,evidence/'native_pipeline.py')
    report = dict(completed=False,attempted=[],completed_stages=[],failure=None)
    processes = []
    start = time.monotonic()
    def interrupted(signum,frame):
        raise InterruptedError(f'Native pipeline received signal {signum}')
    previous_term = signal.signal(signal.SIGTERM,interrupted)
    def launch(label,script,*args):
        report['attempted'].append(label)
        log = (evidence/f'{label}.log').open('w')
        child = subprocess.Popen([str(PYTHON),str(ROOT/script),*map(str,args)],
            cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
        processes.append((label,child,log))
        print('Starting',label,flush=True)
        return child
    def finish(label,child):
        last_report = time.monotonic()
        while child.poll() is None:
            if time.monotonic()-last_report >= 30:
                print('NATIVE_PIPELINE_ACTIVE',label,round(time.monotonic()-start,1),flush=True)
                last_report = time.monotonic()
            time.sleep(0.5)
        assert child.returncode == 0,(label,child.returncode)
        report['completed_stages'].append(label)
    def run(label,script,*args):
        finish(label,launch(label,script,*args))
    try:
        build = TASK/'evidence/fit-native-build-001'
        last_report = time.monotonic()
        while not (build/'manifest.json').exists():
            if time.monotonic()-start > 7200:
                raise TimeoutError('Waiting for build guard expired')
            if time.monotonic()-last_report >= 30:
                print('NATIVE_PIPELINE_WAITING_FOR_BUILD',round(time.monotonic()-start,1),flush=True)
                last_report = time.monotonic()
            time.sleep(1)
        for name,expected in json.loads((build/'manifest.json').read_text()).items():
            assert digest(build/name) == expected,(name,'Changed build evidence')
        built = json.loads((build/'results.json').read_text())
        assert built['completed'] and built['compiler_source_sha256'] == digest(TASK/'candidate-fit.bas')
        image = build/'compiler.dat'
        assert digest(image) == built['image_sha256']
        report['image_sha256'] = digest(image)
        checks = TASK/'evidence/fit-image-checks-001'
        try:
            run('image-checks','docs/tasks/C005/compact/check_compiler_image.py',
                '--image',image,'--output',checks)
        finally:
            if checks.exists():
                shutil.copyfile(ROOT/'docs/tasks/C005/compact/check_compiler_image.py',checks/'check_compiler_image.py')
                (checks/'manifest.json').write_text(json.dumps({p.name:digest(p)
                    for p in sorted(checks.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
        run('native-mandelbrot','docs/tasks/C010/compile_fit_mandelbrot.py',
            '--native',image,'--name','fit-native-mandelbrot-001')
        self_build = launch('native-self','docs/tasks/C010/bootstrap_fit_self.py',
            '--seed',image,'--expected',image,'--name','fit-native-self-001', '--timeout', 7200)
        for suite in ['baseline','representative']:
            run('native-'+suite,'docs/tasks/C010/run_fit_regressions.py',
                '--suite',suite,'--native',image,'--name','fit-native-'+suite+'-001')
        for suite in ['basic','bounded','errors','interactions']:
            run('native-wire-'+suite,'docs/tasks/C010/qualify_fit.py',
                '--suite',suite,'--native',image,'--name','fit-native-wire-'+suite+'-001')
        finish('native-self',self_build)
        report['completed'] = True
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        for label,child,log in processes:
            if child.poll() is None:
                os.killpg(child.pid,signal.SIGTERM)
                try:
                    child.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    os.killpg(child.pid,signal.SIGKILL)
                    child.wait()
            log.close()
        report['controller_seconds'] = round(time.monotonic()-start,3)
        (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
        signal.signal(signal.SIGTERM,previous_term)
        print(json.dumps(report),flush=True)


if __name__ == '__main__':
    main()
