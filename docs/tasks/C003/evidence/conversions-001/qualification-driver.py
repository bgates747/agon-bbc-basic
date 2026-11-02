"""Retained prototype orchestration; no language or arithmetic implementation."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess

ROOT=Path('/Agon/mystuff/bbc-basic-v-adl')
TASK=ROOT/'docs/tasks/C003'
EVIDENCE=TASK/'evidence/conversions-001'
PYTHON=ROOT/'.venv/bin/python'
CLI='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
COMPILER=TASK/'conversions/compiler.bas'
RUNTIME=TASK/'build/conversion-runtime'


def archive(source, destination):
    destination.mkdir(parents=True, exist_ok=True)
    for p in source.iterdir():
        if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat'):
            shutil.copy2(p,destination/p.name)


def run(label, script, arguments, build):
    result=subprocess.run([str(PYTHON),script,'--cli',CLI,*arguments],cwd=ROOT,
                          text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (EVIDENCE/f'{label}.log').write_text(result.stdout)
    archive(build,EVIDENCE/label)
    if result.returncode:
        raise SystemExit(result.stdout)
    print(label+': '+result.stdout,flush=True)


def manifest():
    members={str(p.relative_to(EVIDENCE)):hashlib.sha256(p.read_bytes()).hexdigest()
             for p in EVIDENCE.rglob('*') if p.is_file() and p.name!='manifest.json'}
    (EVIDENCE/'manifest.json').write_text(json.dumps(members,indent=2)+'\n')


if __name__=='__main__':
    archive(TASK/'build/output-integration',EVIDENCE/'transcripts')
    run('abi','docs/tasks/C003/tools/test_conversion_abi.py',
        ['--runtime',str(RUNTIME)],TASK/'build/conversion-abi')
    run('storage','docs/tasks/C003/tools/test_string_storage.py',
        ['--compiler',str(COMPILER),'--conversions','--numeric-runtime',str(RUNTIME)],
        TASK/'build/conversion-storage')
    run('baseline','compiler/tools/test_compiler.py',
        ['--compiler',str(COMPILER)],ROOT/'compiler/build')
    for p in [COMPILER,TASK/'conversions/expression_runtime.s',
              TASK/'conversions/abi.s',ROOT/'compiler/tools/build_numeric_runtime.py',
              TASK/'tools/test_conversions.py',TASK/'tools/test_conversion_abi.py',
              TASK/'tools/test_string_storage.py']:
        shutil.copy2(p,EVIDENCE/p.name)
    archive(RUNTIME,EVIDENCE/'runtime')
    shutil.copy2(RUNTIME/'runtime-0.bin',EVIDENCE/'runtime/runtime-0.dat')
    shutil.copy2(TASK/'build/conversion-abi/probe.bin',EVIDENCE/'abi/probe.dat')
    manifest()
