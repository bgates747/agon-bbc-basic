"""Test actual MOS keyboard/line editing and the standalone input helper ABI."""
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
    build = TASK/'build/input-abi'
    build.mkdir(parents=True, exist_ok=True)
    runtime = TASK/'build/io-runtime'
    tc = Path('/Agon/agondev/release/bin')
    source = TASK/'io/input-abi.s'
    subprocess.run([str(tc/'ez80-none-elf-as'), '-march=ez80+full', '-o', str(build/'probe.o'), str(source)], check=True)
    subprocess.run([str(tc/'ez80-none-elf-ld'), '-Ttext=0x40000', '-e', 'entry', '--oformat=binary',
                    '-o', str(build/'probe.bin'), str(build/'probe.o'), str(runtime/'runtime.o')], check=True)
    profile = ROOT/'.emulator'
    assert (profile/'fab-agon-emulator.bin').resolve() == args.cli.resolve(strict=True)
    shutil.copy2(build/'probe.bin', profile/'sdcard/input-abi.bin')
    spec = importlib.util.spec_from_file_location('interactive', TASK/'io/interactive.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    start = time.monotonic()
    log = h.run(profile, 'try /input-abi.bin\necho INPUT_ABI_STATUS:<Try$ReturnCode>\n',
        [('INPUT_ALPHA', 'alpha'), ('INPUT_EMPTY', ''), ('INPUT_MAXIMUM', 'q'*255),
         ('INPUT_ESCAPE', '\x1b')], 'INPUT_ABI_STATUS:', 'input-abi.log')
    (build/'native.log').write_text(log)
    assert 'INPUT_ABI_STATUS:0\n' in log, log
    report = dict(scope='Actual MOS input helper with keyboard injection, not human review',
        ordinary_empty_and_maximal_input=True, escape_status=True, guards=True,
        index_and_stack_preservation=True, logical_tail_unchanged=True,
        duration_seconds=round(time.monotonic()-start,3),
        hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                for p in [source, TASK/'io/interactive.py', build/'probe.bin', runtime/'runtime-0.bin']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
