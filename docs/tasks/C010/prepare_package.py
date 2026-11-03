"""Overlay qualified C010 artifacts on the portable manual package, preserving tests."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    base = args.base.resolve(strict=True)
    out = args.output.resolve()
    assert out.is_relative_to(TASK/'build') and not out.exists()
    assert digest(base/'manifest.json') == '7fe79c811878fc9e151d1689a8a5156e631e394dd66c75396e626868ed591b26'
    old = json.loads((base/'manifest.json').read_text())
    for name, expected in old['files'].items():
        assert digest(base/name) == expected, name
    promotion = json.loads((TASK/'evidence/live-promotion-001/results.json').read_text())
    native = json.loads((ROOT/'compiler/bin/manifest.json').read_text())
    assert native['image_sha256'] == promotion['promoted_image_sha256'] == digest(ROOT/'compiler/bin/compiler.bin')
    assert native['source_sha256'] == promotion['promoted_source_sha256'] == digest(ROOT/'compiler/compiler.bas')
    shutil.copytree(base, out)
    shutil.copyfile(ROOT/'compiler/bin/compiler.bin', out/'compiler.bin')
    shutil.copyfile(ROOT/'compiler/compiler.bas', out/'compiler.bas')
    public = dict(schema='bbc-compiler-provenance-v2', target=native['target'],
        image_file='compiler.bin', image_bytes=native['image_bytes'], image_sha256=native['image_sha256'],
        source_file='compiler.bas', source_sha256=native['source_sha256'],
        license_file='compiler-license.txt', license_sha256=native['license_sha256'],
        qualification=dict(emulator_generations=len(native['emulator_generations']),
            native_regressions=native['native_regressions'], physical_qualification=native['physical_qualification']),
        prior_release=dict(source_sha256=native['prior_qualified_release']['source_sha256'],
            image_sha256=native['prior_qualified_release']['image_sha256'],
            physical_qualification=native['prior_qualified_release']['physical_qualification']),
        human_optical_validation=False, performance_benchmark=False)
    (out/'compiler-provenance.json').write_text(json.dumps(public, indent=2)+'\n')
    matrix = (ROOT/'compiler/COMPATIBILITY.md').read_text()
    table = '\n'.join(line for line in matrix.splitlines() if line.startswith('|'))
    table = table.replace('compiler/bin/compiler.bin', 'compiler.bin')
    (out/'compatibility.md').write_text('# Compiler compatibility\n\n'
        'This describes the bundled compiler and its explicitly stated subset. '
        'For supported conventional programs, execution speed is the only intended '
        'observable behavioral difference. Automated command comparisons do not '
        'establish rendered or human acceptance.\n\n'+table+'\n')
    case = out/'tests/12-mandelbrot'
    case.mkdir(exist_ok=False)
    shutil.copyfile(TASK/'evidence/source-001/mandelbrot.bas', case/'mandelbrot.bas')
    shutil.copyfile(TASK/'evidence/native-mandelbrot-001/mandelbrot.dat', case/'mandelbrot-c010.bin')
    (case/'native-readme.txt').write_text(
        'Unchanged Mandelbrot by P. Mainwaring, March1990 (see source comments).\n'
        'Automated native/reference graphics commands match for the complete program.\n'
        'Rendered/human and physical results for this compiler version are pending.\n\n'
        'Start at the package root. To run the supplied native program:\n'
        '  LOAD tests/12-mandelbrot/mandelbrot-c010.bin\n  RUN .\n\n'
        'Expected: MODE8, the Mandelbrot drawing in four passes, then a key wait.\n'
        'Press Space when the drawing is complete. MODE1 is restored and MOS returns.\n'
        'Compare the drawing with the same source under the reference interpreter.\n'
        'Do not press Escape as a completion key; it intentionally raises Escape.\n\n'
        'To compile it yourself, start at the package root:\n'
        '  LOAD compiler.bin\n  CD tests/12-mandelbrot\n  RUN .\n'
        'Enter mandelbrot.bas, then a fresh destination such as built-c010.bin.\n'
        'Wait for Wrote and actual return to MOS, then:\n'
        '  LOAD built-c010.bin\n  RUN .\n'
        'Use CD ../.. to return to the package root afterward.\n\n'
        'Record the compiler hash/version, observed drawing, key wait, final mode\n'
        'and return. No elapsed-time or performance acceptance is implied.\n')
    readme = (out/'readme.txt').read_text()
    replacements = [
        ('In particular, general graphics/sound statements, RND, CASE, numeric INPUT,',
         'MODE, GCOL, PLOT and bare numeric GET support their documented forms.\n'
         'Other graphics/sound statements, RND, CASE, numeric INPUT,'),
        ('Each subdirectory has source.bas, expected.txt and its own readme.txt with\ncommands.',
         'Those twelve subdirectories have source.bas, expected.txt and readme.txt\nwith commands.'),
        ('These small programs have prior automated and physical Agon qualification.',
         'An earlier compiler version passed automated and physical checks of these\n'
         'small sources. This version has fresh automated checks; its physical and\n'
         'human qualification remain pending. See compiler-provenance.json.'),
        ('output name, for example self-new.bin. A physical Agon qualification self-build\ntook about99 minutes to observed completion;',
         'output name, for example self-new.bin. An earlier compiler version took\n'
         'about99 minutes to observed completion in physical Agon qualification;'),
        ('The qualified compiler is324275 bytes, SHA256:\n'
         '299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0',
         f'This compiler is {native["image_bytes"]} bytes, SHA256:\n{native["image_sha256"]}'),
    ]
    for old_text,new_text in replacements:
        assert readme.count(old_text) == 1,old_text
        readme = readme.replace(old_text,new_text)
    readme += ('\nFor unchanged Mandelbrot source and its supplied native program, read\n'
        'tests/12-mandelbrot/native-readme.txt. The twelve earlier tests remain.\n'
        'Compiler provenance separates this version from earlier physical tests.\n')
    (out/'readme.txt').write_text(readme)
    with (out/'tests/readme.txt').open('a') as file:
        file.write('\n12-mandelbrot: follow native-readme.txt in that directory.\n'
            'Command parity is qualified; rendered/human acceptance remains pending.\n')
    forbidden = re.compile(rb'/Agon/|/home/|/run/|/mystuff/|/tmp/|/Users/|/media/|'
        rb'Oryx|oryx|AGONC8|raspberrypi|docs/tasks/')
    for path in out.rglob('*'):
        if path.is_file() and path.name != 'manifest.json':
            assert not forbidden.search(path.read_bytes()), path
            if path.suffix == '.md':
                for link in re.findall(r'\[[^\]]+\]\(([^)]+)\)', path.read_text()):
                    if '://' not in link and not link.startswith('#'):
                        target = (path.parent/link.split('#')[0]).resolve()
                        assert target.is_relative_to(out) and target.exists(), (path, link)
    files = {str(p.relative_to(out)):digest(p) for p in sorted(out.rglob('*'))
        if p.is_file() and p.name != 'manifest.json'}
    package = dict(old, compiler_sha256=native['image_sha256'], source_sha256=native['source_sha256'],
        manual_validation=False, files=files)
    (out/'manifest.json').write_text(json.dumps(package, indent=2)+'\n')
    print(json.dumps(dict(files=len(files)+1, manifest_sha256=digest(out/'manifest.json'))))


if __name__ == '__main__':
    main()
