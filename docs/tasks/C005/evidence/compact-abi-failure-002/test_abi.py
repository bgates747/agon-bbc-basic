"""Execute compact native adapters with real NUM and explicit bridge observations."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,subprocess,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005';HERE=Path(__file__).resolve().parent

def main():
 p=argparse.ArgumentParser();p.add_argument('--cli',type=Path,required=True);a=p.parse_args();b=TASK/'build/compact-abi';b.mkdir(parents=True,exist_ok=True);tc=Path('/Agon/agondev/release/bin');rt=TASK/'build/compact-runtime';num=ROOT/'compiler/build/numeric-runtime/runtime.o'
 subprocess.run([str(tc/'ez80-none-elf-as'),'-march=ez80+full',f'-al={b/"probe.lst"}','-o',str(b/'probe.o'),str(HERE/'abi.s')],check=True)
 subprocess.run([str(tc/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','entry','--oformat=binary','-o',str(b/'probe.bin'),str(b/'probe.o'),str(rt/'runtime.o'),str(num)],check=True)
 profile=ROOT/'.emulator';assert (profile/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True);shutil.copy2(b/'probe.bin',profile/'sdcard/compact-abi.bin');spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h);start=time.monotonic();log=h.run_profile(profile,'try /compact-abi.bin\necho COMPACT_ABI_STATUS:<Try$ReturnCode>\n','COMPACT_ABI_STATUS:','compact-abi.log',timeout_seconds=60);(b/'native.log').write_text(log)
 assert 'COMPACT_ABI_STATUS:0\n' in log and 'COMPACT_ABI_OK\n' in log,log
 paths=[HERE/'runtime.s',HERE/'ABI.md',HERE/'abi.s',HERE/'test_abi.py',rt/'runtime-0.bin',rt/'runtime.json',num,b/'probe.bin'];report=dict(scope='Native fixed-operand adapter ABI; real NUM, observation stubs for MEM/ACT; no frontend integration',stages=17,entry_points=13,hardware_validation=False,controller_seconds=round(time.monotonic()-start,3),hashes={str(q.relative_to(ROOT)):hashlib.sha256(q.read_bytes()).hexdigest() for q in paths});(b/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
