"""Test native error checkpoints, discarded locals and string ownership."""
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
    build = TASK/'build/error-abi'
    build.mkdir(parents=True, exist_ok=True)
    runtime = TASK/'build/error-runtime'
    tc = Path('/Agon/agondev/release/bin')
    source = TASK/'errors/abi.s'
    subprocess.run([str(tc/'ez80-none-elf-as'), '-march=ez80+full', '-o', str(build/'probe.o'), str(source)], check=True)
    subprocess.run([str(tc/'ez80-none-elf-ld'), '-Ttext=0x40000', '-e', 'entry', '--oformat=binary',
                    '-o', str(build/'probe.bin'), str(build/'probe.o'), str(runtime/'runtime.o'),
                    str(ROOT/'compiler/build/control-runtime/runtime.o'),
                    str(ROOT/'compiler/build/procedure-runtime/runtime.o'),
                    str(ROOT/'compiler/build/string-runtime/runtime.o')], check=True)
    profile = ROOT/'.emulator'
    assert (profile/'fab-agon-emulator.bin').resolve() == args.cli.resolve(strict=True)
    shutil.copy2(build/'probe.bin', profile/'sdcard/error-abi.bin')
    spec = importlib.util.spec_from_file_location('h', ROOT/'compiler/tools/test_compiler.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    start = time.monotonic()
    log = h.run_profile(profile, 'try /error-abi.bin\necho ERROR_ABI_STATUS:<Try$ReturnCode>\n',
        'ERROR_ABI_STATUS:', 'error-abi.log', timeout_seconds=60)
    (build/'native.log').write_text(log)
    assert 'ERROR_ABI_STATUS:0\n' in log, log
    assert '(C) Copyright R.T.Russell 2025\n\nboom\nboom\n\nfatal-zero at line 65279\n' in log, log
    report = dict(scope='Native error adapter ABI; no source-handler language yet',
        global_and_local_stack_transfer=True, root_and_loop_installation=True, handler_retained=True, fatal_zero_bypasses=True,
        discarded_numeric_values_remain=True, retained_local_normal_restoration=True,
        repeated_and_maximum_string_rescue=True, empty_descriptor_future_growth=True,
        report_NUL_and_full_line_packet=True, subsequent_local_arena_overwrite=True,
        duration_seconds=round(time.monotonic()-start,3),
        hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                for p in [source, build/'probe.bin', runtime/'runtime-0.bin']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
