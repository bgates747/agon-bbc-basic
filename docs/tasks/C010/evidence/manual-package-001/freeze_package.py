"""Retain the complete portable package and verify every shipped byte/path."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--package',type=Path,required=True)
parser.add_argument('--name',required=True)
args = parser.parse_args()
assert args.name.replace('-','').isalnum()
package = args.package.resolve(strict=True)
assert package.is_relative_to(TASK/'build')
manifest = json.loads((package/'manifest.json').read_text())
native = json.loads((ROOT/'compiler/bin/manifest.json').read_text())
assert manifest['schema'] == 'bbc-manual-package-v2' and manifest['package_root'] == '.'
actual = {str(p.relative_to(package)) for p in package.rglob('*') if p.is_file()}
assert actual == set(manifest['files']) | {'manifest.json'} and len(actual) == 53
for filename,expected in manifest['files'].items():
    assert digest(package/filename) == expected,filename
prior = ROOT/'docs/tasks/C008/build/manual-004/manifest.json'
assert digest(prior) == '7fe79c811878fc9e151d1689a8a5156e631e394dd66c75396e626868ed591b26'
prior_tests = set()
for filename,expected in json.loads(prior.read_text())['files'].items():
    parts = Path(filename).parts
    if len(parts) >= 3 and parts[0] == 'tests':
        assert manifest['files'][filename] == expected,filename
        prior_tests.add(parts[1])
assert len(prior_tests) == 12
assert digest(package/'compiler.bin') == native['image_sha256'] == digest(ROOT/'compiler/bin/compiler.bin')
assert digest(package/'compiler.bas') == native['source_sha256'] == digest(ROOT/'compiler/compiler.bas')
assert digest(package/'compiler-license.txt') == native['license_sha256']
assert digest(package/'tests/12-mandelbrot/mandelbrot.bas') == '1eb897c8ef3aecc99910e0352eba6d32064ebc4aef9e7bd32e9952b0878b43de'
assert digest(package/'tests/12-mandelbrot/mandelbrot-c010.bin') == 'bad741db6adfc250c7c2f48c37687aec93e8271f77c48bd760f309548dada196'
forbidden = re.compile(rb'/Agon/|/home/|/run/|/mystuff/|/tmp/|/Users/|/media/|'
    rb'Oryx|oryx|AGONC8|raspberrypi|docs/tasks/')
for filename in sorted(actual):
    path = package/filename
    assert not path.is_symlink() and not forbidden.search(path.read_bytes()),filename
    if path.suffix == '.md':
        for link in re.findall(r'\[[^\]]+\]\(([^)]+)\)',path.read_text()):
            if '://' not in link and not link.startswith('#'):
                target = (path.parent/link.split('#')[0]).resolve(strict=True)
                assert target.is_relative_to(package)
provenance = json.loads((package/'compiler-provenance.json').read_text())
assert not provenance['human_optical_validation'] and not provenance['performance_benchmark']
assert provenance['qualification']['physical_qualification']['self_source_generations'] == 0
assert provenance['prior_release']['physical_qualification']['self_source_generations'] == 2
evidence = TASK/'evidence'/args.name
evidence.mkdir(parents=True,exist_ok=False)
shutil.copytree(package,evidence/'payload')
shutil.copyfile(__file__,evidence/'freeze_package.py')
shutil.copyfile(TASK/'prepare_package.py',evidence/'prepare_package.py')
result = dict(completed=True,files=len(actual),bytes=sum((package/n).stat().st_size for n in actual),
    package_manifest_sha256=digest(package/'manifest.json'),source_sha256=native['source_sha256'],
    image_sha256=native['image_sha256'],all_payload_paths_portable=True,
    all_local_markdown_links_shipped=True,prior_tests_preserved=12,added_mandelbrot=True,
    manual_validation=False,physical_validation=False,scope='Complete portable package, no target execution')
(evidence/'results.json').write_text(json.dumps(result,indent=2)+'\n')
(evidence/'manifest.json').write_text(json.dumps({str(p.relative_to(evidence)):digest(p)
    for p in sorted(evidence.rglob('*')) if p.is_file() and p != evidence/'manifest.json'},indent=2)+'\n')
print(json.dumps(result),flush=True)
