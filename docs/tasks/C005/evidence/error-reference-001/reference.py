"""Observe pinned BBC handler stack/binding behavior before designing native recovery."""
from pathlib import Path
import hashlib,importlib.util,json,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def cases():
 return [
 ('global-numeric', ['x%=7','ON ERROR PRINT "ERR=";ERR;":";ERL;":";x%:REPORT:PRINT:OSCLI "BYE"',
   'PROCfail','PRINT "WRONG":OSCLI "BYE"'],
  ['DEF PROCfail:LOCAL x%:x%=99:ERROR 100,"boom"']),
 ('global-string', ['s$="outer"','ON ERROR PRINT s$:PROCoverwrite:PRINT s$:OSCLI "BYE"',
   'PROCfail','PRINT "WRONG":OSCLI "BYE"'],
  ['DEF PROCfail:LOCAL s$:s$="inner":ERROR 100,"boom"',
   'DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"q"):ENDPROC']),
 ('local-before', ['x%=7','r%=FNlocal:PRINT ;r%;":";x%:OSCLI "BYE"'],
  ['DEF FNlocal:LOCAL x%:x%=99',
   'ON ERROR LOCAL PRINT "ERR=";ERR;":";ERL;":";x%:=42',
   'ERROR 100,"boom"']),
 ('local-after', ['x%=7','r%=FNlocal:PRINT ;r%;":";x%:OSCLI "BYE"'],
  ['DEF FNlocal','ON ERROR LOCAL PRINT "ERR=";ERR;":";ERL;":";x%:=42',
   'LOCAL x%:x%=99:ERROR 100,"boom"']),
 ('local-string-after', ['s$="outer"','r%=FNlocal:PRINT ;r%;":";s$:PROCoverwrite:PRINT s$:OSCLI "BYE"'],
  ['DEF FNlocal','ON ERROR LOCAL PRINT s$:PROCoverwrite:PRINT s$:=42',
   'LOCAL s$:s$="inner":ERROR 100,"boom"',
   'DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"q"):ENDPROC']),
 ('retained-handler', ['n%=0','ON ERROR n%=n%+1:PRINT ;ERR;":";n%:IF n%<2 THEN GOTO 40 ELSE OSCLI "BYE"',
   'REM skip','ERROR 100,"again"'], []),
 ('local-error-nop', ['x%=7','ON ERROR PRINT ;ERR;":";x%:OSCLI "BYE"','PROCfail','OSCLI "BYE"'],
  ['DEF PROCfail:LOCAL ERROR:LOCAL x%:x%=99:ERROR 100,"nop"']),
 ('code-and-report', ['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:OSCLI "BYE"',
   'ERROR 257,"one"+CHR$(0)+"tail"'], []),
 ('negative-code', ['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:OSCLI "BYE"','ERROR -1,"negative"'], []),
 ]
def main():
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 dest=TASK/'evidence/error-reference-001';dest.mkdir(parents=True,exist_ok=True)
 profile=ROOT/'.emulator';auto='';names=[]
 for i,(name,body,defs) in enumerate(cases()):
  text='\n'.join([f'{10+j*10} {x}' for j,x in enumerate(body)]+[f'{1000+j*10} {x}' for j,x in enumerate(defs)])+'\n'
  (dest/(name+'.bas')).write_text(text);(profile/'sdcard'/f'error-ref-{i}.bas').write_text(text)
  auto+=f'echo ERROR_BEGIN_{i}\nload /bin/basic.bin\nrun . /error-ref-{i}.bas\necho ERROR_END_{i}\n';names.append(name)
 auto+='echo ERROR_REFERENCE_DONE\n';start=time.monotonic()
 log=h.run_profile(profile,auto,'ERROR_REFERENCE_DONE','error-reference.log',timeout_seconds=120)
 (dest/'reference.log').write_text(log)
 observations={name:log.split(f'ERROR_BEGIN_{i}\n',1)[1].split(f'ERROR_END_{i}\n',1)[0] for i,name in enumerate(names)}
 assert 'WRONG' not in log
 report=dict(scope='Actual interpreted reference; no native recovery implementation',observations=observations,duration_seconds=round(time.monotonic()-start,3),basic_sha256=hashlib.sha256((ROOT/'bin/basic.bin').read_bytes()).hexdigest())
 (dest/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
