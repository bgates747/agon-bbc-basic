"""Run fresh qualification for the private symbol-text variant.

All parsing and emission run in the BBC compiler. Existing harnesses supply
their original CPU fixtures and assertions; this only selects inputs/cohorts.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import os
import shutil
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
SOURCE = TASK/'candidate-meta.bas'
PYTHON = ROOT/'.venv/bin/python'
CLI = TASK/'build/observer-target/release/agon-cli-emulator'
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()


def retained(name):
    directory = TASK/'evidence'/name
    manifest = json.loads((directory/'manifest.json').read_text())
    for filename,expected in manifest.items():
        path = (directory/filename).resolve(strict=True)
        assert path.is_relative_to(directory.resolve()) and digest(path) == expected
    return json.loads((directory/'results.json').read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--role',choices=['hosted','native','errors'],required=True)
    args = parser.parse_args()
    assert digest(SOURCE) == '70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e'
    name = {'hosted':'meta-hosted-pipeline-001','native':'meta-native-pipeline-001',
        'errors':'meta-error-controller-001'}[args.role]
    evidence = TASK/'evidence'/name
    evidence.mkdir(parents=True,exist_ok=False)
    shutil.copyfile(__file__,evidence/'metadata_pipeline.py')
    report = dict(role=args.role,compiler_source_sha256=digest(SOURCE),completed=False,
        attempted=[],completed_stages=[],failure=None)
    processes = []
    start = time.monotonic()
    def interrupted(signum,frame):
        raise InterruptedError(f'Metadata controller received signal {signum}')
    old_term = signal.signal(signal.SIGTERM,interrupted)
    def launch(label,script,*arguments):
        report['attempted'].append(label)
        logfile = (evidence/(label+'.log')).open('w')
        child = subprocess.Popen([str(PYTHON),str(ROOT/script),*map(str,arguments)],
            cwd=ROOT,stdout=logfile,stderr=subprocess.STDOUT,start_new_session=True)
        processes.append((child,logfile))
        print('Starting',label,flush=True)
        return child
    def finish(label,child):
        last = time.monotonic()
        while child.poll() is None:
            if time.monotonic()-last >= 30:
                print('METADATA_ACTIVE',label,round(time.monotonic()-start,1),flush=True)
                last = time.monotonic()
            time.sleep(0.5)
        assert child.returncode == 0,(label,child.returncode)
        report['completed_stages'].append(label)
    def run(label,script,*arguments):
        finish(label,launch(label,script,*arguments))
    def wait(name):
        last = time.monotonic()
        while not (TASK/'evidence'/name/'manifest.json').exists():
            if time.monotonic()-start > 7500:
                raise TimeoutError('Prerequisite did not complete within guard')
            if time.monotonic()-last >= 30:
                print('METADATA_WAITING',name,round(time.monotonic()-start,1),flush=True)
                last = time.monotonic()
            time.sleep(1)
        result = retained(name)
        assert result['completed'],(name,result)
        return result
    try:
        if args.role == 'hosted':
            run('baseline','compiler/tools/test_compiler.py','--compiler',SOURCE,
                '--cli',CLI,'--profile',ROOT/'.emulator/c010-fit')
            run('freeze-baseline','docs/tasks/C010/freeze_fit_baseline.py',
                '--source',SOURCE,'--name','meta-hosted-baseline-001')
            run('admissions','docs/tasks/C010/admit_fit.py',
                '--source',SOURCE,'--name','meta-admissions-001')
            run('repack','docs/tasks/C010/repack_fit.py',
                '--source',SOURCE,'--name','meta-repack-001')
            for suite in ['basic','bounded','errors','interactions']:
                run('wire-'+suite,'docs/tasks/C010/qualify_fit.py','--source',SOURCE,
                    '--suite',suite,'--name','meta-wire-'+suite+'-001')
        else:
            built = wait('meta-native-build-001')
            assert built['compiler_source_sha256'] == digest(SOURCE)
            image = TASK/'evidence/meta-native-build-001/compiler.dat'
            assert digest(image) == built['image_sha256']
            report['image_sha256'] = digest(image)
            if args.role == 'native':
                checks = TASK/'evidence/meta-image-checks-001'
                try:
                    run('image-checks','docs/tasks/C005/compact/check_compiler_image.py',
                        '--image',image,'--output',checks)
                finally:
                    if checks.exists():
                        shutil.copyfile(ROOT/'docs/tasks/C005/compact/check_compiler_image.py',checks/'check_compiler_image.py')
                        (checks/'manifest.json').write_text(json.dumps({p.name:digest(p)
                            for p in sorted(checks.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
                # The hosted job owns c010-fit until its complete final manifest.
                wait('meta-hosted-pipeline-001')
                run('native-mandelbrot','docs/tasks/C010/compile_fit_mandelbrot.py',
                    '--source',SOURCE,'--native',image,'--name','meta-native-mandelbrot-001')
                self_build = launch('native-self','docs/tasks/C010/bootstrap_fit_self.py',
                    '--source',SOURCE,'--seed',image,'--expected',image,
                    '--name','meta-native-self-001','--timeout','7200')
                for suite in ['baseline','representative']:
                    run('native-'+suite,'docs/tasks/C010/run_fit_regressions.py',
                        '--source',SOURCE,'--reference',TASK/'evidence/meta-hosted-baseline-001',
                        '--suite',suite,'--native',image,'--name','meta-native-'+suite+'-001')
                for suite in ['basic','bounded','errors','interactions']:
                    run('native-wire-'+suite,'docs/tasks/C010/qualify_fit.py','--source',SOURCE,
                        '--suite',suite,'--native',image,'--name','meta-native-wire-'+suite+'-001')
                finish('native-self',self_build)
            else:
                # Original C006 error fixture/checker uses the separate root SD.
                script = ROOT/'docs/tasks/C006/native_errors.py'
                spec = importlib.util.spec_from_file_location('native_errors',script)
                module = importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
                module.TASK = TASK
                sys.argv = [str(script),'--native',str(image),'--source',str(SOURCE),
                    '--cli',str(CLI),'--name','meta-native-errors-001']
                module.main()
                directory = TASK/'evidence/meta-native-errors-001'
                for i in range(39):
                    assert (directory/f'p{i}.dat').read_bytes() == (ROOT/f'docs/tasks/C006/evidence/live-native-errors-001/p{i}.dat').read_bytes(),i
                (directory/'execution.json').write_text(json.dumps(dict(
                    original_harness_sha256=digest(script),source_sha256=digest(SOURCE),
                    identical_full_images=list(range(39)),profile='.emulator'),indent=2)+'\n')
                shutil.copyfile(__file__,directory/'metadata_pipeline.py')
                (directory/'manifest.json').write_text(json.dumps({p.name:digest(p)
                    for p in sorted(directory.iterdir()) if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
                report['completed_stages'].append('native-errors')
                report['identical_full_images'] = list(range(39))
        report['completed'] = True
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        for child,logfile in processes:
            if child.poll() is None:
                os.killpg(child.pid,signal.SIGTERM)
                try:
                    child.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    os.killpg(child.pid,signal.SIGKILL);child.wait()
            logfile.close()
        report['controller_seconds'] = round(time.monotonic()-start,3)
        (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
        signal.signal(signal.SIGTERM,old_term)
        print(json.dumps(report),flush=True)


if __name__ == '__main__':
    main()
