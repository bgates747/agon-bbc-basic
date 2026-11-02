"""Execute the native bounded string-copy probe; no BASIC implementation."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,subprocess,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--cli',required=True,type=Path);args=parser.parse_args()
 build=TASK/'build/copy-abi';build.mkdir(parents=True,exist_ok=True);tc=Path('/Agon/agondev/release/bin');source=TASK/'copy/abi.s';runtime=TASK/'build/string-runtime'
 subprocess.run([str(tc/'ez80-none-elf-as'),'-march=ez80+full','-o',str(build/'probe.o'),str(source)],check=True)
 subprocess.run([str(tc/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','entry','--oformat=binary','-o',str(build/'probe.bin'),str(build/'probe.o'),str(runtime/'runtime.o')],check=True)
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 profile=ROOT/'.emulator';assert (profile/'fab-agon-emulator.bin').resolve()==args.cli.resolve(strict=True)
 (profile/'sdcard/copy-abi.bin').write_bytes((build/'probe.bin').read_bytes());start=time.monotonic();log=h.run_profile(profile,'try /copy-abi.bin\necho COPY_ABI_STATUS:<Try$ReturnCode>\n','COPY_ABI_STATUS:','copy-abi.log');(build/'native.log').write_text(log);assert 'COPY_ABI_STATUS:0\n' in log,log
 report=dict(empty_copies_header_only=True,maximum_256_byte_transfer=True,logical_tail_unchanged=True,source_read_only=True,page_crossing=True,poisoned_upper_bc=True,index_and_stack_preservation=True,guards_unchanged=True,identical_buffer=True,duration_seconds=round(time.monotonic()-start,3),hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [source,build/'probe.bin',runtime/'runtime-0.bin']})
 (build/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
