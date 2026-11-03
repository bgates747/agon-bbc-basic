"""Run the BBC compiler on its source and retain the first bootstrap gap."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005';PROFILE=ROOT/'.emulator'
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--compiler',type=Path,default=ROOT/'compiler/compiler.bas');parser.add_argument('--evidence',default='initial-gap-001');parser.add_argument('--timeout',type=float,default=1800);args=parser.parse_args()
 e=TASK/'evidence'/args.evidence;assert not e.exists(),'Preserve prior evidence';e.mkdir(parents=True);source=args.compiler.read_text();shutil.copy2(args.compiler,e/'compiler.bas')
 driver='10 ON ERROR PRINT "BOOTSTRAP_GAP":REPORT:PRINT:CLOSE#0:PRINT "BOOTSTRAP_GAP_DONE":OSCLI "BYE"\n20 PROCinit\n30 PROCcompile("bootstrap-source.bas","bootstrap-gap.bin")\n40 PRINT "UNEXPECTED_BOOTSTRAP_SUCCESS":PRINT "BOOTSTRAP_GAP_DONE":OSCLI "BYE"\n1000 DEF'+source.split('1000 DEF',1)[1]
 (e/'driver.bas').write_text(driver);(PROFILE/'sdcard/bootstrap-gap-driver.bas').write_text(driver);(PROFILE/'sdcard/bootstrap-source.bas').write_text(source)
 sentinel=b'Bootstrap gap preserves the old output';(PROFILE/'sdcard/bootstrap-gap.bin').write_bytes(sentinel)
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 start=time.monotonic();log=h.run_profile(PROFILE,'load /bin/basic.bin\nrun . /bootstrap-gap-driver.bas\n','BOOTSTRAP_GAP_DONE','bootstrap-gap.log',timeout_seconds=args.timeout);(e/'native-host.log').write_text(log)
 assert 'BOOTSTRAP_GAP\n' in log and 'UNEXPECTED_BOOTSTRAP_SUCCESS' not in log
 assert (PROFILE/'sdcard/bootstrap-gap.bin').read_bytes()==sentinel
 report=dict(scope='Initial bootstrap-gap probe, not self-hosting',compiler_sha256=hashlib.sha256(source.encode()).hexdigest(),diagnostic=log.split('BOOTSTRAP_GAP\n',1)[1].split('BOOTSTRAP_GAP_DONE',1)[0],existing_output_preserved=True,duration_seconds=round(time.monotonic()-start,3),human_hardware_validation=False)
 (e/'results.json').write_text(json.dumps(report,indent=2)+'\n');(e/'manifest.json').write_text(json.dumps({q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in e.iterdir() if q.is_file() and q.name!='manifest.json'},indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
