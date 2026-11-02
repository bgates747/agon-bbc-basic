"""Run a direct eZ80 FN prefix ABI probe."""
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
    parser.add_argument('--runtime',type=Path,default=ROOT/'compiler/build/procedure-runtime')
    args=parser.parse_args()
    args.runtime=args.runtime.resolve(strict=True)
    build=TASK/'build/function-abi';build.mkdir(parents=True,exist_ok=True)
    tc=Path('/Agon/agondev/release/bin');source=TASK/'functions/abi.s'
    subprocess.run([str(tc/'ez80-none-elf-as'),'-march=ez80+full','-o',str(build/'probe.o'),str(source)],check=True)
    subprocess.run([str(tc/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','entry','--oformat=binary',
                    '-o',str(build/'probe.bin'),str(build/'probe.o'),str(args.runtime/'runtime.o'),str(ROOT/'compiler/build/control-runtime/runtime.o'),str(ROOT/'compiler/build/numeric-runtime/runtime.o')],check=True)
    spec=importlib.util.spec_from_file_location('harness',ROOT/'compiler/tools/test_compiler.py')
    h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
    profile=ROOT/'.emulator';assert (profile/'fab-agon-emulator.bin').resolve()==args.cli.resolve(strict=True)
    (profile/'sdcard/function-abi.bin').write_bytes((build/'probe.bin').read_bytes())
    start=time.monotonic()
    log=h.run_profile(profile,'try /function-abi.bin\necho FUNCTION_ABI_STATUS:<Try$ReturnCode>\n',
                      'FUNCTION_ABI_STATUS:','function-abi.log')
    (build/'native.log').write_text(log);assert 'FUNCTION_ABI_STATUS:0\n' in log,log
    report=dict(checked_index_and_stack_preservation=True,poisoned_upper_bc=True,
                numeric_and_string_prefix_restoration=True,nested_prefixes=True,
                local_restoration_under_fn=True,distinct_proc_fn_markers=True,
                zero_counts_and_null_pools=True,exact_arena_capacity_checked=True,
                duration_seconds=round(time.monotonic()-start,3),
                hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in [source,build/'probe.bin',args.runtime/'runtime-0.bin']})
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))


if __name__=='__main__':main()
