"""Independently check a complete all-feature compiler image before execution.

Only assembled runtime objects and emitted machine bytes are inspected. This
does not parse BASIC or calculate program addresses from BASIC source.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--image', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    image_path = args.image.resolve(strict=True)
    image = image_path.read_bytes()
    assert image[64:69] == b'MOS\x00\x01'
    output = args.output.resolve()
    assert not output.exists(), 'Preserve previous image qualification'
    output.mkdir(parents=True)
    (output / 'cases.json').write_text('[{}]\n')
    spec = importlib.util.spec_from_file_location('standard', TASK / 'check_error_images.py')
    standard = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(standard)
    # The shared checker accepts an absolute image pattern; one synthetic case
    # selects this exact image without editing or copying it onto the CLI SD.
    standard.check(output, str(image_path))
    links = json.loads((output / 'runtime-links.json').read_text())[0]
    bases = links['bases']
    rt = TASK / 'build/compact-runtime'
    metadata = json.loads((rt / 'runtime.json').read_text())
    template = (rt / 'runtime-0.bin').read_bytes()
    relocations = [int(match[1], 16) for line in (rt / 'relocations.txt').read_text().splitlines()
                   if (match := re.match(r'\s*([0-9a-f]{8})\s+[0-9a-f]{8}\s+R_Z80_24', line))]
    assert len(relocations) == metadata['relocations']
    prefix = template[:min(relocations)]
    assert len(prefix) >= 8
    fields = metadata['external_bridge_fields']
    matches = []
    offset = image.find(prefix)
    while offset >= 0:
        base = 0x40000+offset
        target = output / f'compact-candidate-{base:x}.dat'
        subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',
                        f'-Ttext=0x{base:x}', '-e', 'cp_literal', '--oformat=binary',
                        '-o', str(target), str(rt / 'runtime.o')], check=True)
        expected = bytearray(target.read_bytes())
        observed = {}
        for name, field in fields.items():
            value = image[offset+field:offset+field+3]
            expected[field:field+3] = value
            observed[name] = int.from_bytes(value, 'little')
        if image[offset:offset+len(expected)] == expected:
            target.write_bytes(expected)
            matches.append((base, observed))
        else:
            target.unlink()
        offset = image.find(prefix, offset+1)
    assert len(matches) == 1, matches
    base, observed = matches[0]
    # In this all-feature compiler the compact module immediately precedes STR,
    # whose following pools precede the heap. This rules out the earlier overlap.
    assert base+len(template) == bases['strings']
    independent = {
        'cp_slot_numeric': ('numeric', 'rt_numeric'),
        'cp_slot_literal': ('numeric', 'rt_literal'),
        'cp_slot_prefix': ('memory', 'array_prefix'),
        'cp_slot_addr': ('memory', 'array_addr'),
        'cp_slot_save': ('procedure', 'act_save'),
        'cp_slot_bind': ('procedure', 'act_bind'),
        'cp_slot_begin': ('procedure', 'act_begin'),
    }
    for field, (module, entry) in independent.items():
        directory = 'numeric' if module == 'numeric' else module
        meta = json.loads((ROOT / f'compiler/build/{directory}-runtime/runtime.json').read_text())
        assert observed[field] == bases[module]+meta['exports'][entry], field
    for field, size in [('cp_num_base', 5), ('cp_str_base', 256)]:
        address = observed[field]
        position = address-0x40000
        assert 0 <= position <= len(image)-size, field
        assert image[position:position+size] == bytes(size), field
    for field in ['cp_slot_numerror', 'cp_slot_novar', 'cp_slot_memerror', 'cp_slot_acterror']:
        assert 0x40000 <= observed[field] < 0x40000+len(image), field
    result = dict(image_sha256=hashlib.sha256(image).hexdigest(), image_bytes=len(image),
                  complete_standard_runtimes_and_entry_checked=True,
                  compact_base=base, compact_bytes=len(template),
                  compact_PIC_matches_GNU=True, external_fields=observed,
                  independently_anchored_export_fields=list(independent),
                  other_checks='two zeroed-pool ranges, four compiled-error-wrapper ranges, STR adjacency',
                  native_execution_performed=False,
                  scope='Machine-image qualification; native behavioral/generation tests remain separate')
    (output / 'compiler-image-checks.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
