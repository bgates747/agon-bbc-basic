"""Test standalone DATA helper boundaries, cursor atomicity and register preservation."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = ROOT/'docs/tasks/C005'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--cli', required=True, type=Path)
    args = parser.parse_args()
    build = TASK/'build/data-abi'
    build.mkdir(parents=True, exist_ok=True)
    runtime = TASK/'build/data-runtime'
    tc = Path('/Agon/agondev/release/bin')
    source = TASK/'data/abi.s'
    subprocess.run([str(tc/'ez80-none-elf-as'), '-march=ez80+full', '-o', str(build/'probe.o'), str(source)], check=True)
    subprocess.run([str(tc/'ez80-none-elf-ld'), '-Ttext=0x40000', '-e', 'entry', '--oformat=binary',
                    '-o', str(build/'probe.bin'), str(build/'probe.o'), str(runtime/'runtime.o')], check=True)
    profile = ROOT/'.emulator'
    assert (profile/'fab-agon-emulator.bin').resolve() == args.cli.resolve(strict=True)
    shutil.copy2(build/'probe.bin', profile/'sdcard/data-abi.bin')
    spec = importlib.util.spec_from_file_location('h', ROOT/'compiler/tools/test_compiler.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    start = time.monotonic()
    log = h.run_profile(profile, 'try /data-abi.bin\necho DATA_ABI_STATUS:<Try$ReturnCode>\n',
        'DATA_ABI_STATUS:', 'data-abi.log', timeout_seconds=60)
    (build/'native.log').write_text(log)
    assert 'DATA_ABI_STATUS:0\n' in log, log
    report = dict(scope='Native DATA helper ABI, not frontend language qualification',
        exhaustion_before_destination=True, deferred_error_atomicity=True,
        empty_binary_and_maximum_strings=True, captured_cursor_commit=True,
        guards_and_index_stack_preservation=True,
        duration_seconds=round(time.monotonic()-start,3),
        hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                for p in [source, build/'probe.bin', runtime/'runtime-0.bin']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
