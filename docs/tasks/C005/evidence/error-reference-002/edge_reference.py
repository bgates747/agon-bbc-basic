"""Additional reference handler boundaries, including actual fatal/OFF REPL exits."""
from pathlib import Path
import hashlib,importlib.util,json,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def main():
 d=TASK/'evidence/error-reference-002';assert not d.exists();d.mkdir(parents=True);profile=ROOT/'.emulator'
 h=mod('h',ROOT/'compiler/tools/test_compiler.py');interactive=mod('interactive',TASK/'io/interactive.py');start=time.monotonic();observations={}
 normal=[
 ('local-at-root',['ON ERROR LOCAL PRINT "ROOT=";ERR:OSCLI "BYE"','ERROR 100,"root"'],[]),
 ('local-under-loop',['PROCloop','OSCLI "BYE"'],['DEF PROCloop:FOR i%=0 TO 0','ON ERROR LOCAL PRINT "LOOP=";ERR:OSCLI "BYE"','ERROR 100,"loop"']),
 ('retained-strings',['s$="outer":t$="old"','r%=FNouter:PRINT ;r%;":";s$;":";t$:OSCLI "BYE"'],
  ['DEF FNouter:LOCAL s$:s$="before"','ON ERROR LOCAL PRINT s$;":";t$:PROCoverwrite:PRINT s$;":";t$:=42',
   'PROCinner:=0','DEF PROCinner:LOCAL t$:t$="after":ERROR 100,"inner"',
   'DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"q"):ENDPROC']),
 ('local-off-restores',['ON ERROR PRINT "RESTORED=";ERR:OSCLI "BYE"','PROCp:ERROR 100,"again"'],['DEF PROCp:ON ERROR LOCAL OFF:ENDPROC']),
 ('code-conversion-order',['ON ERROR PRINT "CODE=";ERR:OSCLI "BYE"','ERROR 1E20,FNmsg'],['DEF FNmsg:PRINT "WRONG":="msg"']),
 ]
 for i,(name,body,defs) in enumerate(normal):
  s='\n'.join([f'{10+j*10} {x}' for j,x in enumerate(body)]+[f'{1000+j*10} {x}' for j,x in enumerate(defs)])+'\n'
  (d/(name+'.bas')).write_text(s);(profile/'sdcard/error-edge.bas').write_text(s)
  log=h.run_profile(profile,'load /bin/basic.bin\nrun . /error-edge.bas\necho ERROR_EDGE_DONE\n','ERROR_EDGE_DONE','error-edge.log',timeout_seconds=60)
  assert 'WRONG' not in log;observations[name]=log;(d/(name+'.log')).write_text(log)
 for name,code,off in [('fatal-zero',0,False),('fatal-wrap',256,False),('off',100,True)]:
  msg='MSG_'+name
  body=['ON ERROR PRINT "WRONG":OSCLI "BYE"']+(['ON ERROR OFF'] if off else [])+[f'ERROR {code},"{msg}"']
  s='\n'.join(f'{10+j*10} {x}' for j,x in enumerate(body))+'\n';(d/(name+'.bas')).write_text(s);(profile/'sdcard/error-edge.bas').write_text(s)
  log=interactive.run(profile,'load /bin/basic.bin\nrun . /error-edge.bas\necho ERROR_EDGE_DONE\n',[(msg+' at line','*BYE')],'ERROR_EDGE_DONE','error-edge.log',timeout_seconds=60)
  assert 'WRONG' not in log;observations[name]=log;(d/(name+'.log')).write_text(log)
 report=dict(scope='Actual reference only; includes keyboard exit from untrapped BASIC',observations=observations,duration_seconds=round(time.monotonic()-start,3),basic_sha256=hashlib.sha256((ROOT/'bin/basic.bin').read_bytes()).hexdigest())
 (d/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
