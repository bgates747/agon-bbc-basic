"""Observe REPORT's token-byte expansion and LF special case in pinned BASIC."""
from pathlib import Path
import hashlib,importlib.util,json,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def main():
 d=TASK/'evidence/errors-report-token-reference-001';assert not d.exists();d.mkdir(parents=True);p=ROOT/'.emulator';tests=[('and',[128]),('abs',[148]),('compressed',[18,21]),('low-token',[1]),('oscli',[255]),('linefeed',[10]),('nul',[128,0,148])];auto=''
 for i,(name,values) in enumerate(tests):
  expr='"["+'+'+'.join(f'CHR$({v})' for v in values)+'+"]"';src=f'10 ON ERROR REPORT:PRINT:OSCLI "BYE"\n20 ERROR 100,{expr}\n';(d/(name+'.bas')).write_text(src);(p/'sdcard'/f'report-token-{i}.bas').write_text(src);auto+=f'echo REPORT_TOKEN_BEGIN_{i}\nload /bin/basic.bin\nrun . /report-token-{i}.bas\necho REPORT_TOKEN_END_{i}\n'
 auto+='echo REPORT_TOKENS_DONE\n';sp=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);start=time.monotonic();log=h.run_profile(p,auto,'REPORT_TOKENS_DONE','report-tokens.log',timeout_seconds=60);(d/'reference.log').write_text(log)
 observed={name:log.split(f'REPORT_TOKEN_BEGIN_{i}\n',1)[1].split(f'REPORT_TOKEN_END_{i}\n',1)[0] for i,(name,_) in enumerate(tests)}
 report=dict(scope='Actual REPORT output; no intended-output oracle',observed=observed,duration_seconds=round(time.monotonic()-start,3),basic_sha256=hashlib.sha256((ROOT/'bin/basic.bin').read_bytes()).hexdigest());(d/'results.json').write_text(json.dumps(report,indent=2)+'\n');(d/'manifest.json').write_text(json.dumps({q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in d.iterdir() if q.name!='manifest.json'},indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
