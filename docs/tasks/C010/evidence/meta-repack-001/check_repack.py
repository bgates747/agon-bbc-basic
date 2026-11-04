"""Verify all ten assembly/REPORT packers preserve the BBC candidate exactly."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    parser.add_argument('--source', type=Path, default=TASK/'candidate-fit.bas')
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True, exist_ok=False)
    stage = TASK/'build'/args.name
    stage.mkdir(parents=True, exist_ok=False)
    for name in ['compiler/runtime', 'compiler/tools']:
        shutil.copytree(ROOT/name, stage/name, ignore=shutil.ignore_patterns('__pycache__'))
    for name in ['include/bbc-ez80/MAIN.Z80', 'include/bbc-ez80/TOKENIDS.Z80',
                 'bin/basic.bin', 'bin/basic.map', 'license.txt']:
        target = stage/name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT/name, target)
    source = stage/'compiler/compiler.bas'
    shutil.copyfile(args.source, source)
    expected = digest(source)
    report = dict(candidate_sha256=expected, completed=[], modules={}, all_identical=False)
    packages = ['report_keywords', 'numeric_runtime', 'strings_runtime', 'control_runtime',
        'procedure_runtime', 'memory_runtime', 'io_runtime', 'data_runtime', 'error_runtime', 'compact_runtime']
    try:
        for package in packages:
            command = [str(ROOT/'.venv/bin/python'), str(stage/f'compiler/tools/build_{package}.py')]
            if package != 'report_keywords':
                command += ['--compiler', str(source)]
            if package == 'numeric_runtime':
                command += ['--update-compiler']
            with (evidence/f'{package}.log').open('w') as log:
                subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, check=True)
            assert digest(source) == expected, package
            report['completed'].append(package)
        assert (stage/'compiler/runtime/report_keywords.inc').read_bytes() == (ROOT/'compiler/runtime/report_keywords.inc').read_bytes()
        for name in ['numeric', 'string', 'control', 'procedure', 'memory', 'io', 'data', 'error', 'compact']:
            image = stage/f'compiler/build/{name}-runtime/runtime-0.bin'
            baseline = ROOT/f'compiler/build/{name}-runtime/runtime-0.bin'
            assert image.read_bytes() == baseline.read_bytes(), name
            report['modules'][name] = dict(bytes=image.stat().st_size, sha256=digest(image))
        report['all_identical'] = True
    finally:
        (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
        shutil.copyfile(__file__, evidence/'check_repack.py')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'}, indent=2)+'\n')
        print(json.dumps(report), flush=True)


if __name__ == '__main__':
    main()
