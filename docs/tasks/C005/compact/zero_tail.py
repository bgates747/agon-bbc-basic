"""Prepare a BBC loader/emitter that streams the unchanged control zero tail.

Only private assembly-template packaging changes; this never compiles BASIC.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BASE = HERE / 'integrated.bas'
OUT = HERE / 'zero_tail.bas'
BUILD = HERE.parent / 'build/zero-tail-control'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    assert digest(BASE) == '2f81c6fb3987f92973de1a532367ac2e74f3398c2bb361fa336b028e5164cebf'
    assert not OUT.exists(), 'Preserve existing candidates and evidence'
    subprocess.run([str(ROOT / '.venv/bin/python'),
                    str(ROOT / 'compiler/tools/build_control_runtime.py'),
                    '--output', str(BUILD)], check=True, capture_output=True)
    metadata = json.loads((BUILD / 'runtime.json').read_text())
    template = (BUILD / 'runtime-0.bin').read_bytes()
    prefix = metadata['exports']['ctl_frames']
    assert len(template) == metadata['exports']['ctl_frames_end'] == 8657
    assert prefix == 465 and template[prefix:] == bytes(8192)
    data = (BUILD / 'runtime_data.bas').read_text().splitlines()
    relocations = []
    for row in data[1:]:
        payload = row.split(' DATA ', 1)[1]
        if not payload.startswith('"'):
            relocations.extend(map(int, payload.split(',')))
    assert len(relocations) == metadata['relocations']
    assert all(0 <= offset and offset + 3 <= prefix for offset in relocations)
    assert metadata['exports']['ctl_numslot'] + 3 <= prefix
    payloads = [data[0].split(' DATA ', 1)[1]]
    payloads += ['"' + template[i:min(i+40, prefix)].hex().upper() + '"'
                 for i in range(0, prefix, 40)]
    payloads += [','.join(map(str, relocations[i:i+20]))
                 for i in range(0, len(relocations), 20)]
    packed = ''.join(f'{40000+i*10} DATA {body}\n' for i, body in enumerate(payloads))
    (BUILD / 'prefix_data.bas').write_text(packed)
    source = BASE.read_text()
    before, rest = source.split('40000 DATA', 1)
    _, after = rest.split('50000 DATA', 1)
    source = before + packed + '50000 DATA' + after
    replacements = {
        '11030 DIM timage% tsize%-1,treloc%(trelocs%-1)':
        '11030 DIM timage% tframes%-1,treloc%(trelocs%-1)',
        '11040 FOR i%=0 TO tsize%-1 STEP 40:READ s$':
        '11040 FOR i%=0 TO tframes%-1 STEP 40:READ s$',
    }
    for old, new in replacements.items():
        assert source.count(old) == 1
        source = source.replace(old, new)
    start = source.index('19288 DEF PROCtemplate(')
    end = source.index('19336 DEF FNbridgeoffset(', start)
    rows = source[start:end].splitlines()
    bodies = [row.split(' ', 1)[1] for row in rows]
    location = bodies.index('IF e%<=i% PROCbad("Invalid runtime relocation order")')
    bodies.insert(location, 'IF k%=2 AND i%<tframes% AND e%>tframes% e%=tframes%')
    location = bodies.index('IF phase%=3 THEN FOR v%=i% TO e%-1:BPUT#oh%,p%?v%:NEXT')
    bodies.insert(location, 'IF k%=2 AND i%>=tframes% THEN')
    bodies.insert(location+1, 'PROCzeros(e%-i%)')
    bodies.insert(location+2, 'ELSE')
    # PROCzeros advances pc itself; ordinary raw spans retain their old count.
    location = bodies.index('pc%=pc%+e%-i%:i%=e%')
    bodies[location:location+1] = ['pc%=pc%+e%-i%', 'ENDIF', 'i%=e%']
    assert 19288 + len(bodies) < 19336
    source = source[:start] + ''.join(f'{19288+i} {body}\n' for i, body in enumerate(bodies)) + source[end:]
    numbers = [int(row.split(' ', 1)[0]) for row in source.splitlines()]
    assert numbers == sorted(set(numbers)) and max(numbers) <= 65279
    assert all(len(row.split(' ', 1)[1]) <= 255 for row in source.splitlines())
    definitions = re.findall(r'\bDEF\s+(PROC|FN)(\w+)', source)
    assert len(definitions) == len(set(definitions)) == 213
    OUT.write_text(source)
    report = dict(source_sha256=digest(BASE), candidate_sha256=digest(OUT),
                  control_template_sha256=digest(BUILD / 'runtime-0.bin'),
                  full_bytes=len(template), stored_prefix_bytes=prefix,
                  private_template_bytes_saved=len(template)-prefix,
                  compiler_source_bytes_saved=BASE.stat().st_size-OUT.stat().st_size,
                  relocations=len(relocations),
                  scope='Private zero-tail storage; full emitted control image unchanged')
    (HERE / 'zero-tail.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
