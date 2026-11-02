"""Run a direct eZ80 search/repetition ABI probe."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import time

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cli',required=True,type=Path)
    parser.add_argument('--runtime',type=Path,default=ROOT/'compiler/build/string-runtime')
    args=parser.parse_args()
    build=TASK/'build/search-repeat-abi';build.mkdir(parents=True,exist_ok=True)
    tc=Path('/Agon/agondev/release/bin');source=TASK/'search-repeat/abi.s'
    subprocess.run([str(tc/'ez80-none-elf-as'),'-march=ez80+full','-o',str(build/'probe.o'),str(source)],check=True)
    subprocess.run([str(tc/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','entry','--oformat=binary',
                    '-o',str(build/'probe.bin'),str(build/'probe.o'),str(args.runtime/'runtime.o')],check=True)
    spec=importlib.util.spec_from_file_location('harness',ROOT/'compiler/tools/test_compiler.py')
    h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
    profile=ROOT/'.emulator';assert (profile/'fab-agon-emulator.bin').resolve()==args.cli.resolve(strict=True)
    (profile/'sdcard/search-repeat-abi.bin').write_bytes((build/'probe.bin').read_bytes())
    start=time.monotonic()
    log=h.run_profile(profile,'try /search-repeat-abi.bin\necho SEARCH_REPEAT_ABI_STATUS:<Try$ReturnCode>\n',
                      'SEARCH_REPEAT_ABI_STATUS:','search-repeat-abi.log')
    (build/'native.log').write_text(log);assert 'SEARCH_REPEAT_ABI_STATUS:0\n' in log,log
    report=dict(poisoned_upper_bc=True,checked_index_and_stack_preservation=True,
                maximum_and_empty_search=True,empty_needle_returns_zero=True,
                aliased_search_operands=True,unsigned_and_nul_bytes=True,
                search_inputs_read_only=True,overlapping_candidates=True,
                repetition_overflow_unchanged=True,page_crossing_buffer=True,
                zero_counts_do_not_copy=True,buffer_guards_unchanged=True,
                duration_seconds=round(time.monotonic()-start,3),
                hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in [source,build/'probe.bin',args.runtime/'runtime-0.bin']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))


if __name__=='__main__':main()
