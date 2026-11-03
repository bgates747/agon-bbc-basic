"""Run unchanged Mandelbrot on the CPU; compare VDU streams, never render pixels."""
from pathlib import Path
import argparse
import importlib.util
import hashlib
import json
import os
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    parser.add_argument('--mode', choices=['reference', 'native'], required=True)
    parser.add_argument('--image', type=Path, default=TASK/'evidence/compile-001/mandelbrot.dat')
    parser.add_argument('--timeout', type=float, default=7200)
    args = parser.parse_args()
    profile = ROOT/f'.emulator/c010-full-{args.mode}'
    assert args.name.replace('-', '').isalnum()
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True, exist_ok=False)
    setup = module('setup', Path('/Agon/mystuff/agon-dev-env/scripts/setup_emulator.py'))
    sd = setup.link_shared_runtime(profile, Path('/Agon/fab-agon-emulator'))
    observer = TASK/'build/observer-target/release/agon-cli-emulator'
    setup.replace_symlink(profile/'fab-agon-emulator.bin', observer)
    (profile/'.compiler-tests').write_text('C010 automated UART observer; not rendered/human validation\n')
    source = TASK/'evidence/source-001/mandelbrot.bas'
    assert digest(source) == '1eb897c8ef3aecc99910e0352eba6d32064ebc4aef9e7bd32e9952b0878b43de'
    shutil.copyfile(source, sd/'mandelbrot.bas')
    shutil.copyfile(ROOT/'bin/basic.bin', sd/'bin/basic.bin')
    shutil.copyfile(source, evidence/'mandelbrot.bas')
    if args.mode == 'native':
        shutil.copyfile(args.image, sd/'mandelbrot.bin')
        shutil.copyfile(args.image, evidence/'mandelbrot.dat')
        launch = 'try /mandelbrot.bin\necho C010_STATUS:<Try$ReturnCode>\n'
    else:
        launch = 'load /bin/basic.bin\nrun . /mandelbrot.bas\n'
    auto = 'echo C010_FULL_BEGIN\n'+launch+'echo C010_FULL_DONE\n'
    (sd/'autoexec.txt').write_bytes(auto.replace('\n', '\r\n').encode())
    wire_path = evidence/'wire.dat'
    env = dict(os.environ, BBC_C010_WIRE=str(wire_path))
    report = dict(mode=args.mode, source_sha256=digest(source),
        image_sha256=digest(args.image) if args.mode == 'native' else None,
        reference_sha256=digest(ROOT/'bin/basic.bin'), observer_sha256=digest(observer),
        mos_sha256=digest(profile/'mos_platform.bin'), completed=False,
        rendered_validation=False, human_validation=False, performance_benchmark=False)
    start = time.monotonic()
    progress = []
    try:
        with (evidence/'console.log').open('w') as log:
            process = subprocess.Popen(['./fab-agon-emulator', '-u', '-z'], cwd=profile,
                stdin=subprocess.PIPE, stdout=log, stderr=subprocess.STDOUT, env=env)
            sent_key = sent_bye = False
            last_report = start
            try:
                while time.monotonic()-start < args.timeout:
                    wire = wire_path.read_bytes() if wire_path.exists() else b''
                    console = (evidence/'console.log').read_text(errors='replace')
                    # The last pass plots x1280,y1021. This exact selector/coordinate
                    # packet cannot appear in the other three pass lattices.
                    # Input is supplied only after actual execution reaches it.
                    if not sent_key and bytes.fromhex('19450005fd03') in wire:
                        process.stdin.write(b'Q\n'); process.stdin.flush()
                        sent_key = True
                        report['key_supplied_after_final_plot'] = True
                    if args.mode == 'reference' and sent_key and not sent_bye and b'\x16\x01' in wire and '>' in console:
                        process.stdin.write(b'*BYE\n'); process.stdin.flush()
                        sent_bye = True
                    if 'C010_FULL_DONE' in console:
                        assert sent_key
                        if args.mode == 'native':
                            assert 'C010_STATUS:0\n' in console, console
                        break
                    if process.poll() is not None:
                        raise AssertionError(f'CLI exited before completion: {console}')
                    now = time.monotonic()
                    if now-last_report >= 30:
                        progress.append(dict(controller_seconds=round(now-start, 3), wire_bytes=len(wire)))
                        print(json.dumps(progress[-1]), flush=True)
                        last_report = now
                    time.sleep(0.2)
                else:
                    raise TimeoutError('Full-program execution guard expired; no completion inferred')
            finally:
                process.stdin.close()
                try:
                    process.wait(timeout=4)
                except subprocess.TimeoutExpired:
                    process.terminate()
                    process.wait(timeout=4)
        wire = wire_path.read_bytes()
        # Parse complete known packets. Never search for control bytes inside a
        # graphics coordinate or normalize CR/LF bytes in the captured stream.
        begin = wire.index(b'C010_FULL_BEGIN\r\n')+len(b'C010_FULL_BEGIN\r\n')
        offset = wire.index(b'\x16\x08', begin)
        packet_start = offset
        plots = colours = 0
        while True:
            command = wire[offset]
            if command == 22:
                mode = wire[offset+1]
                offset += 2
                if mode == 1:
                    break
                assert mode == 8
            elif command == 18:
                colours += 1
                offset += 3
            elif command == 25:
                assert wire[offset+1] == 69
                plots += 1
                offset += 6
            else:
                raise AssertionError((offset, wire[offset:offset+20].hex()))
        body = wire[packet_start:offset]
        (evidence/'graphics.dat').write_bytes(body)
        report.update(completed=True, plots=plots, gcol_commands=colours,
            graphics_bytes=len(body), graphics_sha256=hashlib.sha256(body).hexdigest())
    finally:
        report['controller_seconds'] = round(time.monotonic()-start, 3)
        report['progress'] = progress
        (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
        shutil.copyfile(__file__, evidence/'full_mandelbrot.py')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'}, indent=2)+'\n')
        print(json.dumps(report), flush=True)


if __name__ == '__main__':
    main()
