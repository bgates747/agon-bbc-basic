"""Replay the three isolated EOF oracles; shared DATA cannot represent exhaustion."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def main():
 a=argparse.ArgumentParser();a.add_argument('--evidence',default='data-exhaustion-reference-rerun');args=a.parse_args();d=TASK/'evidence'/args.evidence;assert not d.exists();d.mkdir(parents=True);profile=ROOT/'.emulator'
 cases=[('no-fields',['READ x'],[]),('one-field',['RESTORE 50000','READ a,b'],['50000 DATA 1']),('before-index',['DIM a%(0)','READ a%(FNneverindex)'],['1000 DEF FNneverindex:PRINT "WRONG":=0'])];auto=''
 for i,(name,body,extra) in enumerate(cases):
  text='10 ON ERROR REPORT:PRINT:OSCLI "BYE"\n'+'\n'.join(f'{100+j*10} {x}' for j,x in enumerate(body))+'\n490 OSCLI "BYE"\n'+'\n'.join(extra)+'\n';(d/(name+'.bas')).write_text(text);(profile/'sdcard'/f'data-eof-{i}.bas').write_text(text);auto+=f'echo DATA_EOF_BEGIN_{i}\nload /bin/basic.bin\nrun . /data-eof-{i}.bas\necho DATA_EOF_END_{i}\n'
 auto+='echo DATA_EXHAUSTION_DONE\n';sp=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);start=time.monotonic();log=h.run_profile(profile,auto,'DATA_EXHAUSTION_DONE','data-exhaustion.log',timeout_seconds=60);(d/'reference.log').write_text(log)
 for i in range(3):assert log.split(f'DATA_EOF_BEGIN_{i}\n',1)[1].split(f'DATA_EOF_END_{i}\n',1)[0]=='Out of DATA\n'
 assert 'WRONG' not in log
 (d/'results.json').write_text(json.dumps(dict(cases=3,all_observed='Out of DATA\n',index_not_evaluated=True,duration_seconds=round(time.monotonic()-start,3)),indent=2)+'\n');(d/'manifest.json').write_text(json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in d.iterdir() if p.name!='manifest.json'},indent=2)+'\n')
if __name__=='__main__':main()
