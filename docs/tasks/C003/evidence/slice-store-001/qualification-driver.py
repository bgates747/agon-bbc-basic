"""Retained prototype orchestration; no language or arithmetic implementation."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess

ROOT=Path('/Agon/mystuff/bbc-basic-v-adl')
TASK=ROOT/'docs/tasks/C003'
EVIDENCE=TASK/'evidence/slice-store-001'
PYTHON=ROOT/'.venv/bin/python'
CLI='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
COMPILER=TASK/'slice-store/compiler.bas'
RUNTIME=TASK/'build/slice-store-runtime'


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
    run('abi','docs/tasks/C003/tools/test_slice_store_abi.py',
        ['--runtime',str(RUNTIME)],TASK/'build/slice-store-abi')
    run('storage','docs/tasks/C003/tools/test_string_storage.py',
        ['--compiler',str(COMPILER),'--slice-store'],
        TASK/'build/slice-store-storage')
    run('baseline','compiler/tools/test_compiler.py',
        ['--compiler',str(COMPILER)],ROOT/'compiler/build')
    for p in [COMPILER,TASK/'slice-store/strings.s',
              TASK/'slice-store/abi.s',ROOT/'compiler/tools/build_strings_runtime.py',
              TASK/'tools/test_slice_store.py',TASK/'tools/test_slice_store_abi.py',
              TASK/'tools/test_string_storage.py']:
        shutil.copy2(p,EVIDENCE/p.name)
    shutil.copy2(TASK/'slice-store/AUDIT.md',EVIDENCE/'AUDIT.md')
    archive(RUNTIME,EVIDENCE/'runtime')
    shutil.copy2(RUNTIME/'runtime-0.bin',EVIDENCE/'runtime/runtime-0.dat')
    shutil.copy2(TASK/'build/slice-store-abi/probe.bin',EVIDENCE/'abi/probe.dat')
    manifest()
