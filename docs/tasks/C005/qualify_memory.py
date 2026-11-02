"""Sequential qualification of one exact BBC memory/resource prototype."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = ROOT/'docs/tasks/C005'


def main():
    live = '--live' in sys.argv
    evidence = TASK/('evidence/memory-promotion-001' if live else 'evidence/memory-capacity-001')
    evidence.mkdir(parents=True, exist_ok=True)
    source = ROOT/'compiler/compiler.bas' if live else TASK/'compiler.bas'
    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    shutil.copy2(source, evidence/'compiler.bas')
    cli = '/tmp/bbc-compiler-cli-target/release/agon-cli-emulator'
    stages = [
        ('bindings', 'docs/tasks/C005/test_bindings.py', ['--timeout', '1800'], TASK/'build/output-integration'),
        ('memory', 'docs/tasks/C005/test_memory.py', ['--timeout', '2400'], TASK/'build/output-integration'),
        ('baseline', 'compiler/tools/test_compiler.py', [], ROOT/'compiler/build'),
        ('functions', 'docs/tasks/C004/tools/test_functions.py', ['--smoke'], ROOT/'docs/tasks/C004/build/output-integration'),
    ]
    if live:
        stages = [
            ('baseline', 'compiler/tools/test_compiler.py', [], ROOT/'compiler/build'),
            ('memory', 'docs/tasks/C005/test_memory.py', ['--smoke', '--memory-runtime', str(ROOT/'compiler/build/memory-runtime')], TASK/'build/output-integration'),
            ('loops', 'docs/tasks/C004/tools/test_loops.py', ['--smoke'], ROOT/'docs/tasks/C004/build/output-integration'),
        ]
    for label, script, arguments, build in stages:
        start = time.time()
        result = subprocess.run([str(ROOT/'.venv/bin/python'), script, '--cli', cli,
            '--compiler', str(source), *arguments], cwd=ROOT, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        assert hashlib.sha256(source.read_bytes()).hexdigest() == digest
        destination = evidence/label
        destination.mkdir(exist_ok=True)
        (destination/'controller.log').write_text(result.stdout)
        shutil.copy2(ROOT/script, destination/Path(script).name)
        names = ['cases.json', 'driver.bas', 'reference.bas', 'reference.log',
                 'compile.log', 'native.log', 'results.json', 'test-results.json']
        if label == 'memory' and result.returncode == 0:
            names += ['memory-links.json', 'procedure-links.json']
        for name in names:
            path = build/name
            if path.is_file() and path.stat().st_mtime >= start-1:
                shutil.copy2(path, destination/name)
        if result.returncode == 0 and label != 'baseline':
            cases = json.loads((build/'cases.json').read_text())
            for i, case in enumerate(cases):
                if 'diagnostic' not in case:
                    shutil.copy2(ROOT/'.emulator/sdcard'/f'p{i}.bin', destination/f'p{i}.dat')
            shutil.copy2(ROOT/'.emulator/sdcard/output-repeat.bin', destination/'repeat.dat')
            report = json.loads((build/'results.json').read_text())
            for prefix, key in [('runtime', 'independent_link_bases'), ('strings', 'string_link_bases')]:
                for base in set(report[key]):
                    shutil.copy2(build/f'{prefix}-{base:x}.bin', destination/f'{prefix}-{base:x}.dat')
            if label == 'memory':
                for row in json.loads((build/'memory-links.json').read_text()):
                    base = row['base']
                    shutil.copy2(build/f'memory-{base:x}.bin', destination/f'memory-{base:x}.dat')
                for row in json.loads((build/'procedure-links.json').read_text())['independent_control_and_procedure_links']:
                    for name in ('control', 'procedure'):
                        base = row[name]
                        shutil.copy2(build/f'{name}-verified-{base:x}.dat', destination/f'{name}-{base:x}.dat')
        (destination/'status.json').write_text(json.dumps(dict(exit_code=result.returncode,
            source_sha256=digest, elapsed_seconds=round(time.time()-start, 3)), indent=2)+'\n')
        (destination/'manifest.json').write_text(json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest()
            for p in destination.iterdir() if p.is_file() and p.name != 'manifest.json'}, indent=2)+'\n')
        print(label+': '+result.stdout, flush=True)
        if result.returncode:
            raise SystemExit(result.returncode)
    (evidence/'manifest.json').write_text(json.dumps({str(p.relative_to(evidence)):
        hashlib.sha256(p.read_bytes()).hexdigest() for p in evidence.rglob('*')
        if p.is_file() and p.name != 'manifest.json'}, indent=2)+'\n')


if __name__ == '__main__':
    main()
