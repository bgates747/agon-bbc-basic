"""Observe the standalone MOS helper on the reference's stalled255-byte path."""
from pathlib import Path
import hashlib,importlib.util,json,shutil,subprocess,time
R=Path(__file__).resolve().parents[4];T=R/'docs/tasks/C005'
def main():
 b=T/'build/long-path-native';b.mkdir(parents=True,exist_ok=True);d=T/'evidence/long-path-native-001';assert not d.exists();d.mkdir(parents=True)
 tc=Path('/Agon/agondev/release/bin');src=T/'io/long-path.s'
 subprocess.run([str(tc/'ez80-none-elf-as'),'-march=ez80+full','-o',str(b/'probe.o'),str(src)],check=True)
 subprocess.run([str(tc/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','entry','--oformat=binary','-o',str(b/'probe.bin'),str(b/'probe.o'),str(T/'build/io-runtime/runtime.o')],check=True)
 profile=R/'.emulator';shutil.copy2(b/'probe.bin',profile/'sdcard/long-path-native.bin')
 spec=importlib.util.spec_from_file_location('h',R/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h);start=time.monotonic();returned=False
 try:
  log=h.run_profile(profile,'echo LONG_PATH_NATIVE_BEGIN\ntry /long-path-native.bin\necho LONG_PATH_NATIVE_STATUS:<Try$ReturnCode>\n','LONG_PATH_NATIVE_STATUS:','long-path-native.log',timeout_seconds=20);returned=True
 except AssertionError as exc:
  log=(profile/'long-path-native.log').read_text(errors='replace');print(str(exc))
 (d/'native.log').write_text(log);shutil.copy2(src,d/'probe.s');shutil.copy2(b/'probe.bin',d/'probe.dat')
 report=dict(scope='Direct native MOS helper; bounded observation, no proven hang root cause',returned_within_guard=returned,guard_seconds=20,elapsed_seconds=round(time.monotonic()-start,3))
 (d/'results.json').write_text(json.dumps(report,indent=2)+'\n');(d/'manifest.json').write_text(json.dumps({x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in d.iterdir() if x.name!='manifest.json'},indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
