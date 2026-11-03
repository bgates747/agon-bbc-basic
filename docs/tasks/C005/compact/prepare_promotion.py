"""Rehearse runtime/source promotion in an isolated disposable tree.

This rebuilds assembly DATA and checks exact compiler-source identity. It never
parses BASIC programs, runs an emulator, or changes the live compiler.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def change(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    assert re.fullmatch(r'[a-z0-9-]+', args.name)
    source = TASK / 'compact/packed.bas'
    expected = '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8'
    assert digest(source) == expected
    live_before = digest(ROOT / 'compiler/compiler.bas')
    stage = TASK / 'build' / args.name
    assert not stage.exists(), 'Preserve an existing preparation'
    stage.mkdir(parents=True)
    shutil.copytree(ROOT / 'compiler/runtime', stage / 'compiler/runtime')
    shutil.copytree(ROOT / 'compiler/tools', stage / 'compiler/tools',
                    ignore=shutil.ignore_patterns('__pycache__'))
    for name in ['include/bbc-ez80/MAIN.Z80', 'include/bbc-ez80/TOKENIDS.Z80',
                 'bin/basic.bin', 'bin/basic.map', 'license.txt']:
        dest = stage / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / name, dest)
    compiler = stage / 'compiler/compiler.bas'
    shutil.copy2(source, compiler)
    shutil.copy2(TASK / 'compact/runtime.s', stage / 'compiler/runtime/compact.s')
    compact = (TASK / 'compact/build_runtime.py').read_text()
    compact = change(compact, 'ROOT=Path(__file__).resolve().parents[4]',
                     'ROOT=Path(__file__).resolve().parents[2]')
    compact = change(compact, "ROOT/'docs/tasks/C005/compact/runtime.s'",
                     "ROOT/'compiler/runtime/compact.s'")
    compact = change(compact, "ROOT/'docs/tasks/C005/build/compact-runtime'",
                     "ROOT/'compiler/build/compact-runtime'")
    (stage / 'compiler/tools/build_compact_runtime.py').write_text(compact)

    control = stage / 'compiler/tools/build_control_runtime.py'
    text = control.read_text()
    insertion = '''    prefix=syms['ctl_frames']
    assert syms['ctl_frames_end']==len(template)
    assert template[prefix:]==bytes(len(template)-prefix)
    assert all(off+3<=prefix for off in relocations)
    assert syms['ctl_numslot']+3<=prefix
    prefix_rows=[rows[0]]
    prefix_rows+=['"'+template[i:min(i+40,prefix)].hex().upper()+'"' for i in range(0,prefix,40)]
    prefix_rows+=[','.join(map(str,relocations[i:i+20])) for i in range(0,len(relocations),20)]
    prefix_data='\\n'.join(f'{40000+i*10} DATA {row}' for i,row in enumerate(prefix_rows))+'\\n'
    (build/'prefix_data.bas').write_text(prefix_data)
    selected=data
    if args.compiler and 'DIM timage% tframes%-1' in args.compiler.read_text():selected=prefix_data
'''
    text = change(text, '    if args.compiler:\n', insertion+'    if args.compiler:\n')
    text = change(text, 'args.compiler.write_text(original+data+procedures)',
                  'args.compiler.write_text(original+selected+procedures)')
    text = change(text, "[source,build/'runtime_data.bas',build/'runtime-0.bin']",
                  "[source,build/'runtime_data.bas',build/'prefix_data.bas',build/'runtime-0.bin']")
    control.write_text(text)

    errors = stage / 'compiler/tools/build_error_runtime.py'
    text = errors.read_text()
    text = change(text, "        args.compiler.write_text(original+data)",
                  "        suffix=args.compiler.read_text()\n"
                  "        following='64000 DATA'+suffix.split('64000 DATA',1)[1] if '64000 DATA' in suffix else ''\n"
                  "        args.compiler.write_text(original+data+following)")
    errors.write_text(text)

    def run(name, *options):
        command = [str(ROOT / '.venv/bin/python'),
                   str(stage / f'compiler/tools/{name}.py'), *map(str, options)]
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        (stage / f'{name}.log').write_text(result.stdout)

    run('build_report_keywords')
    assert (stage / 'compiler/runtime/report_keywords.inc').read_bytes() == (ROOT / 'compiler/runtime/report_keywords.inc').read_bytes()
    packages = ['numeric', 'strings', 'control', 'procedure', 'memory', 'io', 'data', 'error', 'compact']
    for name in packages:
        options = ['--compiler', compiler]
        if name == 'numeric':
            options += ['--update-compiler']
        run('build_'+name+'_runtime', *options)
    assert digest(compiler) == expected, 'Full regeneration changed the qualified source'
    for name in packages:
        options = ['--compiler', compiler]
        if name == 'numeric':
            options += ['--update-compiler']
        run('build_'+name+'_runtime', *options)
        assert digest(compiler) == expected, (name, 'independent repack changed source')
    modules = {}
    for name in packages:
        directory = 'string' if name == 'strings' else name
        assembled = stage / f'compiler/build/{directory}-runtime/runtime-0.bin'
        prior = (TASK / f'build/{directory}-runtime/runtime-0.bin' if name == 'compact'
                 else ROOT / f'compiler/build/{directory}-runtime/runtime-0.bin')
        assert assembled.read_bytes() == prior.read_bytes(), name
        modules[name] = dict(bytes=assembled.stat().st_size, sha256=digest(assembled))
    legacy = stage / 'compiler/legacy.bas'
    shutil.copy2(ROOT / 'compiler/compiler.bas', legacy)
    for name in ['control', 'error']:
        run('build_'+name+'_runtime', '--compiler', legacy)
        assert digest(legacy) == live_before, (name, 'changed the old full-template compiler')
    assert digest(ROOT / 'compiler/compiler.bas') == live_before
    report = dict(scope='Isolated promotion rehearsal; live compiler and emulator unchanged',
                  candidate_sha256=expected, regenerated_source_sha256=digest(compiler),
                  individual_repackers_preserve_source=True, modules=modules,
                  legacy_full_template_source_preserved=True,
                  modified_tools={name:digest(stage / f'compiler/tools/{name}.py') for name in
                                  ['build_control_runtime', 'build_error_runtime', 'build_compact_runtime']},
                  live_compiler_sha256=live_before, hardware_validation=False)
    (stage / 'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
