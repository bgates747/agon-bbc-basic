"""Run the BBC compiler on its source and retain the first bootstrap gap."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005';PROFILE=ROOT/'.emulator'
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--compiler',type=Path,default=ROOT/'compiler/compiler.bas');parser.add_argument('--evidence',default='initial-gap-001');args=parser.parse_args()
 e=TASK/'evidence'/args.evidence;e.mkdir(parents=True,exist_ok=True);source=args.compiler.read_text()
 driver='10 PROCinit\n20 ON ERROR PRINT "BOOTSTRAP_GAP":REPORT:PRINT:CLOSE#0:PRINT "BOOTSTRAP_GAP_DONE":OSCLI "BYE"\n30 PROCcompile("bootstrap-source.bas","bootstrap-gap.bin")\n40 PRINT "UNEXPECTED_BOOTSTRAP_SUCCESS":PRINT "BOOTSTRAP_GAP_DONE":OSCLI "BYE"\n1000 DEF'+source.split('1000 DEF',1)[1]
 (e/'driver.bas').write_text(driver);(PROFILE/'sdcard/bootstrap-gap-driver.bas').write_text(driver);(PROFILE/'sdcard/bootstrap-source.bas').write_text(source)
 sentinel=b'Bootstrap gap preserves the old output';(PROFILE/'sdcard/bootstrap-gap.bin').write_bytes(sentinel)
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 start=time.monotonic();log=h.run_profile(PROFILE,'load /bin/basic.bin\nrun . /bootstrap-gap-driver.bas\n','BOOTSTRAP_GAP_DONE','bootstrap-gap.log',timeout_seconds=900);(e/'native-host.log').write_text(log)
 assert 'BOOTSTRAP_GAP\n' in log and 'UNEXPECTED_BOOTSTRAP_SUCCESS' not in log
 assert (PROFILE/'sdcard/bootstrap-gap.bin').read_bytes()==sentinel
 report=dict(scope='Initial bootstrap-gap probe, not self-hosting',compiler_sha256=hashlib.sha256(source.encode()).hexdigest(),diagnostic=log.split('BOOTSTRAP_GAP\n',1)[1].split('BOOTSTRAP_GAP_DONE',1)[0],existing_output_preserved=True,duration_seconds=round(time.monotonic()-start,3),human_hardware_validation=False)
 (e/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
