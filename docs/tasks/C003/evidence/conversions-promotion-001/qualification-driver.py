"""Retained sequential live-location qualification; Python only orchestrates."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess

ROOT=Path('/Agon/mystuff/bbc-basic-v-adl')
TASK=ROOT/'docs/tasks/C003'
EVIDENCE=TASK/'evidence/conversions-promotion-001'
PYTHON=ROOT/'.venv/bin/python'
CLI='/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'


def archive(source,destination):
    destination.mkdir(parents=True,exist_ok=True)
    for p in source.iterdir():
        if p.is_file() and p.suffix in ('.json','.log','.bas','.txt','.dat'):
            shutil.copy2(p,destination/p.name)


def run(label,script,arguments,build):
    result=subprocess.run([str(PYTHON),script,'--cli',CLI,*arguments],cwd=ROOT,
                          text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (EVIDENCE/f'{label}.log').write_text(result.stdout)
    archive(build,EVIDENCE/label)
    if result.returncode:
        raise SystemExit(result.stdout)
    print(label+': '+result.stdout,flush=True)


if __name__=='__main__':
    run('baseline','compiler/tools/test_compiler.py',[],ROOT/'compiler/build')
    run('conversion-smoke','docs/tasks/C003/tools/test_conversions.py',['--smoke'],TASK/'build/output-integration')
    run('abi','docs/tasks/C003/tools/test_conversion_abi.py',[],TASK/'build/conversion-abi')
    run('storage','docs/tasks/C003/tools/test_string_storage.py',['--conversions'],TASK/'build/conversion-storage')
    run('slice-smoke','docs/tasks/C003/tools/test_slices.py',['--smoke'],TASK/'build/output-integration')
    run('string-limits','docs/tasks/C003/tools/test_string_limits.py',[],TASK/'build/output-integration')
    run('numeric-abi','docs/tasks/C002/tools/test_numeric.py',[],ROOT/'docs/tasks/C002/build')
    run('formatter','docs/tasks/C002/tools/test_format.py',[],ROOT/'docs/tasks/C002/build/format')
    run('numeric-output','docs/tasks/C002/tools/test_output.py',[],ROOT/'docs/tasks/C002/build/output-integration')
    run('expressions','docs/tasks/C002/tools/test_expressions.py',[],ROOT/'docs/tasks/C002/build/expressions/promotion/batch-000')
    for p in [ROOT/'compiler/compiler.bas',ROOT/'compiler/runtime/expression_runtime.s',
              ROOT/'compiler/tools/build_numeric_runtime.py',ROOT/'compiler/examples/conversions.bas',
              TASK/'tools/test_conversions.py',TASK/'tools/test_conversion_abi.py',TASK/'tools/test_string_storage.py']:
        shutil.copy2(p,EVIDENCE/p.name)
    for name in ['numeric-runtime','string-runtime']:
        archive(ROOT/f'compiler/build/{name}',EVIDENCE/name)
        shutil.copy2(ROOT/f'compiler/build/{name}/runtime-0.bin',EVIDENCE/name/'runtime-0.dat')
    shutil.copy2(TASK/'build/conversion-abi/probe.bin',EVIDENCE/'abi/probe.dat')
    members={str(p.relative_to(EVIDENCE)):hashlib.sha256(p.read_bytes()).hexdigest()
             for p in EVIDENCE.rglob('*') if p.is_file() and p.name!='manifest.json'}
    (EVIDENCE/'manifest.json').write_text(json.dumps(members,indent=2)+'\n')
