"""Qualify the fit native compiler with C006's full39 error/ERR/ERL fixtures.

The root automated profile is idle after the retained failed self-fit. It is
separate from the fit self-build and serial regression profiles.
"""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import signal
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    control = TASK/'evidence/fit-error-controller-002'
    control.mkdir(parents=True,exist_ok=False)
    shutil.copyfile(__file__,control/'fit_error_pipeline.py')
    report = dict(completed=False,failure=None)
    start = time.monotonic()
    def interrupted(signum,frame):
        raise InterruptedError(f'Error controller received signal {signum}')
    old_term = signal.signal(signal.SIGTERM,interrupted)
    try:
        build = TASK/'evidence/fit-native-build-002'
        last = start
        while not (build/'manifest.json').exists():
            if time.monotonic()-start > 7200:
                raise TimeoutError('Fit build wait guard expired')
            if time.monotonic()-last >= 30:
                print('ERROR_QUALIFICATION_WAITING_FOR_FIT_BUILD',round(time.monotonic()-start,1),flush=True)
                last = time.monotonic()
            time.sleep(1)
        for name,expected in json.loads((build/'manifest.json').read_text()).items():
            assert digest(build/name) == expected
        built = json.loads((build/'results.json').read_text())
        assert built['completed'] and built['compiler_source_sha256'] == digest(TASK/'candidate-fit.bas')
        script = ROOT/'docs/tasks/C006/native_errors.py'
        spec = importlib.util.spec_from_file_location('native_errors',script)
        module = importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
        module.TASK = TASK
        # Keep its original root profile: its independent GNU image checker
        # reads those exact root-SD files. Other fit jobs use separate profiles.
        cli = TASK/'build/observer-target/release/agon-cli-emulator'
        sys.argv = [str(script),'--native',str(build/'compiler.dat'),
            '--source',str(TASK/'candidate-fit.bas'),'--cli',str(cli),'--name','fit-native-errors-001']
        module.main()
        result = TASK/'evidence/fit-native-errors-001'
        identical = []
        for i in range(39):
            assert (result/f'p{i}.dat').read_bytes() == (ROOT/f'docs/tasks/C006/evidence/live-native-errors-001/p{i}.dat').read_bytes(),i
            identical.append(i)
        execution = dict(original_harness_sha256=digest(script),observer_sha256=digest(cli),
            source_sha256=digest(TASK/'candidate-fit.bas'),identical_full_images=identical,
            profile='.emulator',scope='Fresh native39 reference/runtime/link checks plus earlier full-image equality')
        (result/'execution.json').write_text(json.dumps(execution,indent=2)+'\n')
        shutil.copyfile(__file__,result/'fit_error_pipeline.py')
        (result/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(result.iterdir()) if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
        report.update(completed=True,native_image_sha256=digest(build/'compiler.dat'),identical_full_images=identical)
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        report['controller_seconds'] = round(time.monotonic()-start,3)
        (control/'results.json').write_text(json.dumps(report,indent=2)+'\n')
        (control/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(control.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
        signal.signal(signal.SIGTERM,old_term)
        print(json.dumps(report),flush=True)


if __name__ == '__main__':
    main()
