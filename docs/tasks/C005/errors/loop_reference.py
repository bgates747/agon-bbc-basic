"""Observe CURLIN attribution for initial/repeated conditions and loop body reentry."""
from pathlib import Path
import hashlib,importlib.util,json,time
ROOT=Path(__file__).resolve().parents[4];T=ROOT/'docs/tasks/C005'
def main():
 d=T/'evidence/errors-loop-reference-001';assert not d.exists();d.mkdir(parents=True);p=ROOT/'.emulator';cases=[
 ('while-direct',['WHILE n%<1 OR 1/(1-n%)','n%=n%+1','ENDWHILE'],[]),
 ('while-fn-return',['WHILE n%<1 OR FNvalue/(1-n%)','n%=n%+1','ENDWHILE'],['DEF FNvalue=1']),
 ('while-body-colon',['WHILE n%<2:n%=n%+1:PRINT 1/(2-n%)','ENDWHILE'],[]),
 ('repeat-body-colon',['REPEAT:n%=n%+1:PRINT 1/(2-n%)','UNTIL n%>3'],[]),
 ('for-body-colon',['FOR n%=1 TO 2:PRINT 1/(2-n%)','NEXT'],[]),
 ];auto=''
 for i,(name,body,defs) in enumerate(cases):
  main=[f'PRINT "LOOP_REF_BEGIN_{i}"','ON ERROR PRINT ;ERR;":";ERL;":";n%:OSCLI "BYE"','n%=0',*body,'OSCLI "BYE"'];src='\n'.join([*[f'{10+j*10} {x}' for j,x in enumerate(main)],*[f'{1000+j*10} {x}' for j,x in enumerate(defs)]])+'\n';(d/(name+'.bas')).write_text(src);(p/'sdcard'/f'error-loop-ref-{i}.bas').write_text(src);auto+=f'load /bin/basic.bin\nrun . /error-loop-ref-{i}.bas\necho LOOP_REF_END_{i}\n'
 auto+='echo LOOP_REF_DONE\n';sp=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);start=time.monotonic();log=h.run_profile(p,auto,'LOOP_REF_DONE','error-loop-reference.log',timeout_seconds=60);(d/'reference.log').write_text(log);observed={name:log.split(f'LOOP_REF_BEGIN_{i}\n',1)[1].split(f'LOOP_REF_END_{i}\n',1)[0] for i,(name,*_) in enumerate(cases)};report=dict(observed=observed,duration_seconds=round(time.monotonic()-start,3),basic_sha256=hashlib.sha256((ROOT/'bin/basic.bin').read_bytes()).hexdigest());(d/'results.json').write_text(json.dumps(report,indent=2)+'\n');(d/'manifest.json').write_text(json.dumps({q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in d.iterdir() if q.name!='manifest.json'},indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
