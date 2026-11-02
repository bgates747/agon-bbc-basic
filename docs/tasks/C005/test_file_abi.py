"""Execute the standalone file helper and verify exact bytes/ABI through MOS."""
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
    build = TASK/'build/file-abi'
    build.mkdir(parents=True, exist_ok=True)
    runtime = TASK/'build/io-runtime'
    tc = Path('/Agon/agondev/release/bin')
    source = TASK/'io/file-abi.s'
    subprocess.run([str(tc/'ez80-none-elf-as'), '-march=ez80+full', '-o', str(build/'probe.o'), str(source)], check=True)
    subprocess.run([str(tc/'ez80-none-elf-ld'), '-Ttext=0x40000', '-e', 'entry', '--oformat=binary',
                    '-o', str(build/'probe.bin'), str(build/'probe.o'), str(runtime/'runtime.o')], check=True)
    profile = ROOT/'.emulator'
    assert (profile/'fab-agon-emulator.bin').resolve() == args.cli.resolve(strict=True)
    (profile/'sdcard/io-abi-in.dat').write_bytes(bytes([0,127,128,255]))
    (profile/'sdcard/io-abi-out.dat').unlink(missing_ok=True)
    shutil.copy2(build/'probe.bin', profile/'sdcard/file-abi.bin')
    spec = importlib.util.spec_from_file_location('h', ROOT/'compiler/tools/test_compiler.py')
    h = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(h)
    start = time.monotonic()
    log = h.run_profile(profile, 'try /file-abi.bin\necho FILE_ABI_STATUS:<Try$ReturnCode>\n',
                        'FILE_ABI_STATUS:', 'file-abi.log', timeout_seconds=60)
    (build/'native.log').write_text(log)
    assert 'FILE_ABI_STATUS:0\n' in log, log
    data = (profile/'sdcard/io-abi-out.dat').read_bytes()
    assert data == bytes([0,255,0,128,255,10,10])+b'q'*255, data
    (build/'written.dat').write_bytes(data)
    report = dict(scope='Direct MOS helper ABI, not BASIC frontend qualification',
        binary_reads=True, eof_boolean=True, handle_wrap_and_invalid_api=True,
        byte_and_string_writes=True, empty_and_maximum_strings=True,
        maximum_filename_copy_guards=True, index_and_stack_preservation=True,
        duration_seconds=round(time.monotonic()-start,3),
        hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                for p in [source, build/'probe.bin', build/'written.dat', runtime/'runtime-0.bin']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
