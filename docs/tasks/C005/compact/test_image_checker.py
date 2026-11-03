"""Reject independently corrupted native-image fixtures; never execute them."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    assert re.fullmatch(r'[a-z0-9-]+', args.name)
    build = TASK / 'build' / args.name
    assert not build.exists()
    build.mkdir(parents=True)
    reference = TASK / 'evidence/packed-helpers-001/p0.dat'
    original = reference.read_bytes()
    checker = TASK / 'compact/check_compiler_image.py'
    command = [str(ROOT / '.venv/bin/python'), str(checker)]
    passed = subprocess.run(command+['--image', str(reference), '--output', str(build/'positive')],
                            check=True, capture_output=True, text=True)
    (build/'positive.log').write_text(passed.stdout)
    checked = json.loads((build/'positive/compiler-image-checks.json').read_text())
    compact_offset = checked['compact_base']-0x40000
    metadata = json.loads((TASK/'build/compact-runtime/runtime.json').read_text())
    relocations = [int(match[1], 16) for row in (TASK/'build/compact-runtime/relocations.txt').read_text().splitlines()
                   if (match := re.match(r'\s*([0-9a-f]{8})\s+[0-9a-f]{8}\s+R_Z80_24', row))]
    corruptions = {
        'internal-PIC': compact_offset+relocations[0],
        'external-numeric-entry': compact_offset+metadata['exports']['cp_slot_numeric'],
        'initial-numeric-pool': checked['external_fields']['cp_num_base']-0x40000,
    }
    failures = {}
    for name, offset in corruptions.items():
        blob = bytearray(original)
        blob[offset] ^= 1
        image = build/(name+'.dat')
        image.write_bytes(blob)
        result = subprocess.run(command+['--image', str(image), '--output', str(build/name)],
                                capture_output=True, text=True)
        (build/(name+'.log')).write_text(result.stdout+result.stderr)
        assert result.returncode != 0, name
        assert 'AssertionError' in result.stderr, (name, result.stderr)
        failures[name] = dict(changed_offset=offset,
                              sha256=hashlib.sha256(blob).hexdigest(), rejected=True)
    report = dict(scope='Machine-image validator qualification; corrupt fixtures never executed',
                  reference_sha256=hashlib.sha256(original).hexdigest(),
                  original_passes=True, corruptions=failures,
                  hardware_validation=False, native_compiler_claim=False)
    (build/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
