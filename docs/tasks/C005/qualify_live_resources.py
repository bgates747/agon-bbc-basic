"""Sequential live resource checkpoint; each suite owns the shared CLI fixture."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
TASK = ROOT/'docs/tasks/C005'


def main():
    evidence = TASK/'evidence/resources-promotion-001'
    evidence.mkdir(parents=True, exist_ok=True)
    for label, script, arguments, build in [
        ('baseline', 'compiler/tools/test_compiler.py', [], ROOT/'compiler/build'),
        ('resources', 'docs/tasks/C005/test_resources.py', ['--smoke', '--string-runtime',
          str(ROOT/'compiler/build/string-runtime')], TASK/'build/output-integration'),
        ('carriers', 'docs/tasks/C004/tools/test_function_carriers.py', [],
          ROOT/'docs/tasks/C004/build/output-integration'),
    ]:
        result = subprocess.run([str(ROOT/'.venv/bin/python'), script, '--cli',
          '/tmp/bbc-compiler-cli-target/release/agon-cli-emulator', *arguments], cwd=ROOT,
          text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (evidence/f'{label}.log').write_text(result.stdout)
        destination = evidence/label
        destination.mkdir(exist_ok=True)
        for path in build.iterdir():
            if path.is_file() and path.suffix in ('.json', '.bas', '.log', '.txt', '.dat'):
                shutil.copy2(path, destination/path.name)
        print(label+': '+result.stdout, flush=True)
        if result.returncode:
            raise SystemExit(result.returncode)
    files = ['compiler/compiler.bas', 'compiler/runtime/strings.s',
             'compiler/tools/build_strings_runtime.py', 'docs/tasks/C005/qualify_live_resources.py']
    (evidence/'promotion.json').write_text(json.dumps(dict(
        prototype='docs/tasks/C005/evidence/resources-indexed-001/compiler.bas',
        files={name: hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in files},
        human_hardware_validation=False), indent=2)+'\n')
    (evidence/'manifest.json').write_text(json.dumps({str(p.relative_to(evidence)):
        hashlib.sha256(p.read_bytes()).hexdigest() for p in evidence.rglob('*')
        if p.is_file() and p.name != 'manifest.json'}, indent=2)+'\n')


if __name__ == '__main__':
    main()
