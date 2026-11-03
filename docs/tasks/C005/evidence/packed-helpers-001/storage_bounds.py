"""Inventory explicit private allocations, not a BASIC parser/compiler.

The handwritten shapes mirror the pinned compiler's DIM declarations. Counts
exclude all array headers, strings' contents and allocator overhead, so this is
a lower bound, never proof that initialization or self-compilation fits.
"""
from pathlib import Path
import argparse
import hashlib
import json

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'
SHAPES = {
    'sname$': (5, 4096), 'saddr%': (4, 4096), 'sort%': (4, 4096),
    'pname$': (5, 256), 'pline%': (4, 256), 'parcnt&': (1, 256),
    'par&': (1, 256, 16), 'argkind&': (1, 32, 16),
    'argindex&': (1, 32, 16), 'pkind&': (1, 256), 'pret%': (4, 256),
    'return$': (5, 512), 'retdef&': (1, 512), 'retline%': (4, 512),
    'retcol%': (4, 512), 'vname$': (5, 256), 'vsize&': (1, 256),
    'vstatic%': (4, 256), 'vtype%': (4, 256), 'vdim&': (1, 256),
    'kwords$': (5, 5), 'sunsafe%': (4, 16), 'ifid$': (5, 32),
    'bid$': (5, 32), 'belse%': (4, 32), 'lkind%': (4, 32),
    'lname$': (5, 32), 'lvar%': (4, 32),
    'eentry%': (4, 24), 'xentry%': (4, 26),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler', type=Path, default=TASK / 'compact/integrated.bas')
    parser.add_argument('--image-bytes', type=int)
    parser.add_argument('--target-pages', type=int, default=0)
    args = parser.parse_args()
    compiler = args.compiler
    digest = hashlib.sha256(compiler.read_bytes()).hexdigest()
    candidates = {
        '2f81c6fb3987f92973de1a532367ac2e74f3398c2bb361fa336b028e5164cebf': 8657,
        '14e56cee04b1fc53068b5f3ad76314014925e5894798890d4acd3421b78cc4ef': 465,
        '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8': 465,
    }
    assert digest in candidates
    packed = digest.startswith('6597a0df')
    assert 0 <= args.target_pages <= 64 and (packed or args.target_pages == 0)
    shapes = dict(SHAPES)
    if packed:
        del shapes['saddr%'], shapes['sort%']
        shapes['lrefs%'] = (4, 64)
    arrays = {}
    for name, shape in shapes.items():
        count = 1
        for size in shape[1:]:
            count *= size
        arrays[name] = dict(element_bytes=shape[0], dimensions=shape[1:],
                            payload_bytes=count*shape[0])
    raw = {'lrefs': 16384, 'dpacket': 5}
    if packed:
        del raw['lrefs']
        raw.update(saddr=12288, sort=8192, target_pages=256*args.target_pages)
    relocations = {}
    for name in ['numeric', 'string', 'control', 'procedure', 'memory', 'io', 'data', 'error', 'compact']:
        build = (TASK / f'build/{name}-runtime' if name in ['error', 'compact']
                 else ROOT / f'compiler/build/{name}-runtime')
        metadata = json.loads((build / 'runtime.json').read_text())
        raw[name] = metadata['bytes']
        if name == 'control':
            raw[name] = candidates[digest]
        # String and DATA loaders allocate nrelocs+1 rather than nrelocs.
        relocations[name] = (metadata['relocations'] + (name in ['string', 'data'])) * 4
    total = sum(row['payload_bytes'] for row in arrays.values()) + sum(raw.values()) + sum(relocations.values())
    result = dict(compiler_sha256=digest, scope='Static lower bound from explicit pinned private declarations',
                  array_payloads=arrays, raw_allocations=raw, relocation_payloads=relocations,
                  minimum_private_allocation_bytes=total,
                  omitted=['array headers', 'owned string contents', 'allocator alignment/metadata',
                           'other dynamic allocations'],
                  executable_and_heap_limit=0xAFF00-32768,
                  user_origin=0x40000,
                  activation_arena_bytes=32768,
                  native_initialization_executed=False)
    if args.image_bytes is not None:
        available = result['executable_and_heap_limit']-0x40000-args.image_bytes
        result.update(measured_image_bytes=args.image_bytes, available_heap_bytes=available,
                      minimum_allocation_deficit_bytes=max(0, total-available))
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
