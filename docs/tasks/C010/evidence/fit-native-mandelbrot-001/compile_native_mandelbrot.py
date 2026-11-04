"""Drive the new native compiler's normal prompts on exact Mandelbrot bytes."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import time

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
PROFILE = ROOT/'.emulator/c010-fit'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native', type=Path, required=True)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    evidence = TASK/'evidence'/args.name
    evidence.mkdir(parents=True, exist_ok=False)
    sd = PROFILE/'sdcard'
    source = TASK/'evidence/source-001/mandelbrot.bas'
    shutil.copyfile(source, sd/'native-mandelbrot.bas')
    shutil.copyfile(source, evidence/'mandelbrot.bas')
    shutil.copyfile(args.native, sd/'mandel-compiler.bin')
    spec = importlib.util.spec_from_file_location('keyboard', ROOT/'docs/tasks/C005/io/interactive.py')
    keyboard = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(keyboard)
    report = dict(compiler_source_sha256=digest(TASK/'candidate-fit.bas'),
        native_compiler_sha256=digest(args.native), source_sha256=digest(source),
        observer_sha256=digest(PROFILE/'fab-agon-emulator.bin'), completed=False)
    start = time.monotonic()
    try:
        log = keyboard.run(PROFILE, 'try /mandel-compiler.bin\necho C010_STATUS:<Try$ReturnCode>\n'
            'echo C010_NATIVE_MANDEL_DONE\n', [('Source file: ', 'native-mandelbrot.bas'),
            ('Output file: ', 'native-mandelbrot.bin')], 'C010_NATIVE_MANDEL_DONE',
            'c010-native-mandelbrot.log', timeout_seconds=300)
        assert 'Wrote native-mandelbrot.bin\n' in log and 'C010_STATUS:0\n' in log, log
        image = sd/'native-mandelbrot.bin'
        assert image.read_bytes() == (TASK/'evidence/admissions-001/mandelbrot.dat').read_bytes()
        shutil.copyfile(image, evidence/'mandelbrot.dat')
        report.update(completed=True, exact_source_and_complete_image_match_hosted=True,
            image_sha256=digest(image), image_bytes=image.stat().st_size)
    finally:
        if (PROFILE/'c010-native-mandelbrot.log').exists():
            shutil.copyfile(PROFILE/'c010-native-mandelbrot.log', evidence/'console.log')
        report['controller_seconds'] = round(time.monotonic()-start, 3)
        (evidence/'results.json').write_text(json.dumps(report, indent=2)+'\n')
        shutil.copyfile(__file__, evidence/'compile_native_mandelbrot.py')
        (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
            for p in sorted(evidence.iterdir()) if p.name!='manifest.json'}, indent=2)+'\n')
        print(json.dumps(report), flush=True)


if __name__ == '__main__':
    main()
