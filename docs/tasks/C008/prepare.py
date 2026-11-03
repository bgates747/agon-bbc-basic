"""Copy qualified artifacts and retained test inputs into a manual SD package.

No BASIC compilation, emulator execution, firmware change or hardware run.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
UTILITIES = Path('/Agon/agon-utilities')
NAMES = ['00-smoke', '01-numeric', '02-loops', '03-functions', '04-local',
         '05-arrays', '06-indirection', '07-data', '08-files', '09-errors',
         '10-undefined-label', '11-eval-rejected']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    assert out.is_relative_to(TASK / 'build')
    manifest = json.loads((ROOT / 'compiler/bin/manifest.json').read_text())
    assert sha(ROOT / 'compiler/bin/compiler.bin') == manifest['image_sha256']
    assert sha(ROOT / 'compiler/compiler.bas') == manifest['source_sha256']
    editor = UTILITIES / 'mos/nano.bin'
    assert sha(editor) == '051fcacb92fc129c46ee235626cbef5631b5e74062dd8d5a40a03a326a6c9189'
    assert editor.read_bytes()[64:69] == b'MOS\x00\x01'
    cases_path = ROOT / 'docs/tasks/C006/evidence/live-regressions-001/cases.json'
    cases = json.loads(cases_path.read_text())
    assert len(cases) == len(NAMES) == 12
    # Each successful input already executed on the physical Olimex unchanged.
    old = ROOT / 'docs/tasks/C006/evidence/olimex-fixture-001/payload'
    for i, case in enumerate(cases):
        assert case['source'].encode() == (old / f'case-{i}.bas').read_bytes()
    out.mkdir(parents=True, exist_ok=False)
    copies = {
        'compiler.bin': ROOT / 'compiler/bin/compiler.bin',
        'compiler.bas': ROOT / 'compiler/compiler.bas',
        'compiler-license.txt': ROOT / 'compiler/bin/LICENSE.txt',
        'nano.bin': editor,
        'nano-license.txt': UTILITIES / 'LICENSE',
        'readme.txt': TASK / 'readme.txt',
    }
    for name, source in copies.items():
        shutil.copyfile(source, out / name)
    public = dict(schema='bbc-compiler-provenance-v1',
                  target=manifest['target'], image_file='compiler.bin',
                  image_bytes=manifest['image_bytes'], image_sha256=manifest['image_sha256'],
                  source_file='compiler.bas', source_sha256=manifest['source_sha256'],
                  license_file='compiler-license.txt', license_sha256=manifest['license_sha256'],
                  qualification=dict(emulator_generations=len(manifest['emulator_generations']),
                                     native_regressions=manifest['native_regressions'],
                                     physical_qualification=manifest['physical_qualification']),
                  human_optical_validation=False, performance_benchmark=False)
    (out / 'compiler-provenance.json').write_text(json.dumps(public, indent=2) + '\n')
    compatibility = (ROOT / 'compiler/COMPATIBILITY.md').read_text()
    table = '\n'.join(line for line in compatibility.splitlines() if line.startswith('|'))
    table = table.replace('compiler/bin/compiler.bin', 'compiler.bin')
    (out / 'compatibility.md').write_text(
        '# Compiler compatibility\n\n'
        'This describes the bundled compiler, not the reference interpreter. '
        'Support is limited to each stated scope; self-hosting does not imply '
        'complete BBC BASIC coverage. For supported conventional programs, '
        'execution speed is the only intended observable behavioral difference.\n\n' + table + '\n')
    (out / 'hello.bas').write_bytes(cases[0]['source'].encode())
    (out / 'editor.txt').write_text(
        'Bundled editor: Lennart Benschop agon-utilities nano, unmodified.\n'
        'Source: https://github.com/lennart-benschop/agon-utilities\n'
        'Checkout:56d448534a1702973808dbc6156fac2e3b7e7910\n'
        'MOSLET address&B0000; invoke using the root readme instructions.\n'
        'Ctrl-O save; Ctrl-X exit; Ctrl-G help;253-character lines; CRLF output.\n'
        'It may select mode3 for an80-column display.\n'
        'These are upstream documented controls. See nano-license.txt.\n')
    tests = out / 'tests'
    tests.mkdir()
    (tests / 'readme.txt').write_text(
        'Manual tests: previously qualified sources and expected outputs.\n'
        'Copying this package does not establish a test pass on your machine.\n\n' +
        '\n'.join(NAMES) + '\n\n'
        'Follow each subdirectory readme. For numeric/array checks compare exact\n'
        'text, including scientific notation. Source errors intentionally test\n'
        'the reference LOCAL/handler behavior, not an improved error unwind.\n'
        'The compiler reports no intermediate progress. Hardware timing is not\n'
        'qualified per case. Wait for Wrote and actual MOS return.\n'
        'If a small compile/run remains unclear after several minutes, retain\n'
        'the observed state/error and report it; do not mark the case passed.\n')
    for i, (name, case) in enumerate(zip(NAMES, cases)):
        d = tests / name
        d.mkdir()
        (d / 'source.bas').write_bytes(case['source'].encode())
        prefix = (f'{name}\n\nStart in the package root. At MOS:\n'
                  f'  LOAD compiler.bin\n  CD tests/{name}\n  RUN .\n\n'
                  'At Source file: enter source.bas\n')
        if 'diagnostic' in case:
            (d / 'preserve.dat').write_bytes((old / f'reject-{i}.dat').read_bytes())
            (d / 'expected.txt').write_text(case['diagnostic'] + '\n')
            suffix = ('At Output file: enter preserve.dat\n\nExpected diagnostic contains:\n' +
                      case['diagnostic'] + '\n\nThere must be no Wrote message. Return to MOS is expected.\n'
                      'The existing42-byte preserve.dat must remain unchanged:\n'
                      'Native rejection preserves previous output\n'
                      'It is text, not an executable. Do not LOAD/RUN it.\n'
                      'Inspect it with the bundled editor without saving, or\n'
                      'compare bytes on your computer with the card mounted.\n')
        else:
            (d / 'expected.txt').write_text(case['expected'])
            suffix = ('At Output file: enter built.bin\n'
                      'Wait for Wrote built.bin and return to MOS, then:\n'
                      '  LOAD built.bin\n  RUN .\n\nExpected program output:\n' +
                      case['expected'] + '\nThe program must return to MOS.\n'
                      'Read expected.txt without saving if comparing onscreen.\n')
            if i == 8:
                suffix += ('The program creates/overwrites only native-test.dat in this directory.\n'
                           'Its exact five expected bytes are FF 74 65 78 74.\n')
            if i == 9:
                suffix += ('The recovery diagnostic is intentional.100:100:99 preserves\n'
                           'the reference handler/LOCAL state; recovery is its error text.\n')
        (d / 'readme.txt').write_text(prefix + suffix +
            '\nNo intermediate compiler progress is printed. Compare visible output\n'
            'and actual return, not just a delivered command. See ../readme.txt\n'
            'for duration/observation limits. No automatic timing/pass assertion.\n'
            'After finishing, CD ../.. returns from this test to the package root.\n')
    # Distribution content must not depend on the maintainer's machine or tree.
    forbidden = re.compile(rb'/Agon/|/home/|/run/|/mystuff/|/tmp/|/Users/|/media/|'
                           rb'Oryx|oryx|AGONC8|raspberrypi|docs/tasks/')
    for p in out.rglob('*'):
        if not p.is_file():
            continue
        assert not forbidden.search(p.read_bytes()), p
        if p.suffix == '.md':
            for link in re.findall(r'\[[^\]]+\]\(([^)]+)\)', p.read_text()):
                if '://' not in link and not link.startswith('#'):
                    target = (p.parent / link.split('#')[0]).resolve()
                    assert target.is_relative_to(out) and target.exists(), (p, link)
    files = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file()}
    package = dict(schema='bbc-manual-package-v2', package_root='.',
                   compiler_sha256=manifest['image_sha256'], source_sha256=manifest['source_sha256'],
                   editor_sha256=sha(editor), cases_source_sha256=sha(cases_path),
                   manual_validation=False, files=files)
    (out / 'manifest.json').write_text(json.dumps(package, indent=2) + '\n')
    print(json.dumps(dict(package=str(out), files=len(files) + 1,
                          bytes=sum(p.stat().st_size for p in out.rglob('*') if p.is_file()),
                          manifest_sha256=sha(out / 'manifest.json')), indent=2))


if __name__ == '__main__':
    main()
