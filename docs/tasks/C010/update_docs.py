"""Update live admissions only after the exact fit source/image promotion."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def once(text,old,new):
    assert text.count(old) == 1,old
    return text.replace(old,new)


def main():
    manifest = json.loads((ROOT/'compiler/bin/manifest.json').read_text())
    promotion = json.loads((TASK/'evidence/live-promotion-001/results.json').read_text())
    source_hash = digest(ROOT/'compiler/compiler.bas')
    image_hash = digest(ROOT/'compiler/bin/compiler.bin')
    assert source_hash == manifest['source_sha256'] == promotion['promoted_source_sha256']
    assert source_hash == 'b8afbfdb51de803e7c8e670d4c00e434371e3f2d0af4ce354ce29f3580cdd875'
    assert image_hash == manifest['image_sha256'] == promotion['promoted_image_sha256']
    size = manifest['image_bytes']
    changes = {}
    path = ROOT/'compiler/COMPATIBILITY.md'
    text = path.read_text()
    row = '| VDU and CLS | Partial | Numeric byte expressions use SFIX and low-byte wrapping; no word/zero-fill forms |'
    added = '''
| MODE | Partial | Numeric expression, reference SFIX/low8, VDU22 and acknowledgement wait; inherits MOS/VDP mode support |
| GCOL | Partial | One colour argument (action0) or action,colour; per-argument SFIX and low8 bytes |
| PLOT | Partial | Two coordinates (selector69) or selector,x,y; per-argument SFIX, low8 selector and low16 coordinates; BY and other graphics statements unsupported |
| Numeric GET | Partial | Bare keyboard GET waits and returns unsigned0..255; Escape17 through existing error policy; GET(port), GET#, GET$ and general asynchronous Escape remain unsupported/unqualified |'''
    text = once(text,row,row+added)
    text = text.replace('RND and OS functions remain unsupported','RND and other OS functions remain unsupported')
    old = next(line for line in text.splitlines() if line.startswith('| Self-compilation |'))
    new = (f'| Self-compilation | Implemented for qualified source | Exact source{source_hash[:8]} produces '
        f'{size}-byte image{image_hash[:8]} from the prior qualified native seed; its fresh native self-build '
        'matches completely. Native baseline39, representative12, error39 and18 graphics/key pairs pass. '
        'Earlier hardware results describe the prior source/image; this version awaits physical/human results |')
    text = once(text,old,new)
    changes[path] = text
    path = ROOT/'compiler/SPECIFICATION.md'
    text = path.read_text()
    old = '''`compiler/compiler.bas`. C006 qualifies self-compilation in the emulator and
two physical Olimex generations with complete identical images. The qualified
development executable is `compiler/bin/compiler.bin`, copied unchanged from
the second hardware output. These remain on the development branch; promotion
to main is separate. No human optical or performance acceptance is claimed.'''
    new = '''`compiler/compiler.bas`. C006 qualified the earlier source6597a0df/image299a3119
with four emulator images and two physical generations. C010 adds MODE, GCOL,
PLOT and bare numeric GET for unchanged Mandelbrot, with exact reference graphics
output. Its current native compiler derives from that qualified seed and
reproduces its complete image in a fresh native self-build. The development
executable and exact version/qualification are in `compiler/bin/manifest.json`.
This version's physical/human and performance results remain unclaimed. Main
promotion is separate.'''
    text = once(text,old,new)
    old = '   and zero-fill forms remain unsupported. `CLS` emits VDU 12.'
    new = old+'''

   `MODE expression` preserves the reference SFIX/low8 command and its MOS mode
   acknowledgement wait, including clearing the flag before expression
   evaluation. `GCOL colour` defaults to action0; `GCOL action,colour` converts
   both arguments in order and emits their low bytes. `PLOT x,y` defaults to
   selector69; `PLOT selector,x,y` converts arguments in order, then emits the
   low8 selector and two low16 coordinates, little-endian. PLOT BY and related
   graphics/sound statements remain outside the admitted scope.

   Bare numeric `GET` waits for a MOS keyboard byte and returns an unsigned
   integer0..255; Escape raises error17 through the existing error policy.
   GET(port), GET#, GET$ and broader asynchronous Escape are not admitted here.'''
    text = once(text,old,new)
    old = '   late completion remain explicit in the retained evidence.'
    text = once(text,old,old+'''
   C010 extends that exact qualified native lineage with a new source/image
   and a fresh byte-identical native self-build. It does not relabel the older
   interpreted four-stage or physical results as tests of the new version.''')
    changes[path] = text
    path = ROOT/'compiler/README.md'
    text = path.read_text()
    marker = 'It currently\n'
    assert marker in text
    text = '# Native BBC BASIC compiler — development\n\n'+(
        'The compiler is written in BBC BASIC and emits standalone native eZ80 ADL code. '
        'This build adds MODE, GCOL, PLOT and bare numeric GET for the unchanged '
        'Mandelbrot program. Its complete graphics stream matches the reference. '
        f'The current {size}-byte native compiler reproduces itself byte for byte. '
        'Native baseline39, representative12, error39 and18 graphics/key pairs pass.\n\n'
        'The earlier C006 four-stage and physical results retain their exact older '
        'source6597a0df/image299a3119. This version awaits physical/human validation; '
        'no paired performance benchmark is claimed. The current executable and '
        'provenance are in [`bin/`](bin/README.md).\n\n')+marker+text.split(marker,1)[1]
    old = '''adapters and bounded private metadata. Its324275-byte self-source image matches
the interpreter-produced seed exactly in the first native preflight. See the
[compaction record](../docs/tasks/C005/COMPACTION.md) and
[generation contract](../docs/tasks/C006/BOOTSTRAP.md) for evidence and the
remaining repeated-generation/physical boundary.'''
    new = '''adapters and bounded private metadata. C005/C006's earlier324275-byte image
matches its interpreted seed and subsequent native/physical generations.
C010 preserves those resource limits; its private bookkeeping factoring keeps
the graphics-enabled compiler within the same memory map. See the
[compaction record](../docs/tasks/C005/COMPACTION.md),
[earlier generation contract](../docs/tasks/C006/BOOTSTRAP.md) and
[current qualification](../docs/tasks/C010.md) for their exact versions.'''
    text = once(text,old,new)
    old = '''The completed generation record is live-bootstrap-resume-001. It preserves the'''
    text = once(text,old,'''The earlier C006 generation record is live-bootstrap-resume-001. It preserves the''')
    old = '''Both hardware slots are cleanly released. The unchanged second output is the
qualified development executable at bin/compiler.bin, with its exact notice
and provenance; the initial C006 scope is complete.'''
    new = '''Both hardware slots are cleanly released. That unchanged second output was
the qualified development executable before C010. Its physical evidence remains
bound to source6597a0df/image299a3119; the initial C006 scope is complete.
The current executable's manifest records its fresh automated qualification
and retains that earlier release's provenance separately.'''
    text = once(text,old,new)
    text += '''

[Mandelbrot](examples/mandelbrot.bas) preserves the Author-validated source bytes.
Compile it normally, then load/run its output from MOS. It draws in MODE8,
waits for a key, restores MODE1 and returns. The [C010 audit](../docs/tasks/C010/AUDIT.md)
documents conversions, MOS calling conventions, actual full-stream parity and
the protocol-only CLI observer's rendering limits. The private bookkeeping
refactor retains self-hosting fit while preserving generated program images.
'''
    changes[path] = text
    example = ROOT/'compiler/examples/mandelbrot.bas'
    assert not example.exists()
    for path,text in changes.items():
        path.write_text(text)
    shutil.copyfile(TASK/'evidence/source-001/mandelbrot.bas',example)
    print(json.dumps(dict(updated=[str(p.relative_to(ROOT)) for p in changes],
        example_sha256=digest(example),source_sha256=source_hash,image_sha256=image_hash)))


if __name__ == '__main__':
    main()
