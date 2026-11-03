"""Exact numbered reference/native source-handler programs; no shared BASIC state."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def programs():
 return [
  dict(main=['x%=7','ON ERROR PRINT ;ERR;":";ERL;":";x%:REPORT:PRINT:@EXIT@','PROCfail','PRINT "WRONG":@EXIT@'],defs=['DEF PROCfail:LOCAL x%:x%=99:ERROR 100,"boom"']),
  dict(main=['x%=7','r%=FNlocal:PRINT ;r%;":";x%;":";ERL:@EXIT@'],defs=['DEF FNlocal:LOCAL x%:x%=99','ON ERROR LOCAL PRINT ;ERR;":";ERL;":";x%:=42','ERROR 100,"boom"']),
  dict(main=['x%=7','r%=FNafter:PRINT ;r%;":";x%:@EXIT@'],defs=['DEF FNafter','ON ERROR LOCAL PRINT ;ERR;":";x%:=42','LOCAL x%:x%=99:ERROR 100,"boom"']),
  dict(main=['s$="outer"','ON ERROR PRINT ;ERR;":";ERL;":";LEN s$;":";ASC s$:PROCoverwrite:PRINT ;LEN s$;":";ASC RIGHT$(s$):@EXIT@','PROCfail','@EXIT@'],defs=['DEF PROCfail:LOCAL s$:s$="small":LOCAL s$:s$=STRING$(255,"q"):ERROR 100,"lost"','DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"x"):ENDPROC']),
  dict(main=['s$="outer"','r%=FNstrlocal:PRINT ;r%;":";s$:PROCoverwrite:PRINT s$:@EXIT@'],defs=['DEF FNstrlocal','ON ERROR LOCAL PRINT s$:PROCoverwrite:PRINT s$:=42','LOCAL s$:s$="after":ERROR 100,"lost"','DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"q"):ENDPROC']),
  dict(main=['n%=0','ON ERROR n%=n%+1:PRINT ;ERR;":";ERL;":";n%:IF n%<2 THEN GOTO 50 ELSE @EXIT@','REM handler stays enabled','ERROR 100,"again"'],defs=[]),
  dict(main=['x%=7','ON ERROR PRINT ;ERR;":";x%:@EXIT@','PROCnop','@EXIT@'],defs=['DEF PROCnop:LOCAL ERROR:LOCAL x%:x%=99:ERROR 100,"nop"']),
  dict(main=['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:@EXIT@','ERROR 257,"one"+CHR$(0)+"tail"'],defs=[]),
  dict(main=['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:@EXIT@','ERROR -1,"negative"'],defs=[]),
  dict(main=['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:@EXIT@','ERROR 1E20,FNmsg'],defs=['DEF FNmsg:PRINT "WRONG":="msg"']),
  dict(main=['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:@EXIT@','PRINT 1/0'],defs=[]),
  dict(main=['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:@EXIT@','DIM a%(0):PRINT a%(1)'],defs=[]),
  dict(main=['ON ERROR PRINT ;ERR;":";ERL:REPORT:PRINT:@EXIT@','READ x'],defs=[]),
  dict(main=['ON ERROR READ s$:PRINT ;ERR;":";ERL;":";s$:@EXIT@','READ x%'],defs=[],data=['"retry"']),
  dict(main=['ON ERROR READ s$:PRINT ;ERR;":";ERL;":";s$:@EXIT@','READ x%'],defs=[],data=['1E20']),
  dict(main=['PRINT ;100+FNnumbertrap;":";ERL:@EXIT@'],defs=['DEF FNnumbertrap','ON ERROR LOCAL =7','LOCAL x%:x%=99:PRINT 1/0:=0']),
  dict(main=['PRINT "prefix"+FNstringtrap;":";ERL:@EXIT@'],defs=['DEF FNstringtrap','ON ERROR LOCAL ="result"','LOCAL s$:s$="discard":ERROR 100,"string":="wrong"']),
  dict(main=['ON ERROR PRINT ;ERR;":";ERL:@EXIT@','PROCp:ERROR 100,"outer"'],defs=['DEF PROCp:ON ERROR LOCAL OFF:ENDPROC']),
  dict(main=['PROCloop','@EXIT@'],defs=['DEF PROCloop:FOR i%=0 TO 0','ON ERROR LOCAL PRINT ;ERR;":";ERL:@EXIT@','ERROR 100,"loop"','NEXT:ENDPROC']),
  dict(main=['ON ERROR LOCAL PRINT ;ERR;":";ERL:@EXIT@','ERROR 100,"root"'],defs=[]),
  dict(main=['ON ERROR PRINT "WRONG":@EXIT@','ERROR 0,"fatal-zero"'],defs=[],fatal='fatal-zero',status=1),
  dict(main=['ON ERROR PRINT "WRONG":@EXIT@','ERROR 256,"fatal-wrap"'],defs=[],fatal='fatal-wrap',status=1),
  dict(main=['ON ERROR PRINT "WRONG":@EXIT@','ON ERROR OFF','ERROR 100,"off"'],defs=[],fatal='off',status=1),
 ]
def source(case,i,reference=False):
 main=[f'PRINT "ERROR_CASE_BEGIN_{i}"',*case['main']];rows=[(10+j*10,x) for j,x in enumerate(main)]+[(1000+j*10,x) for j,x in enumerate(case['defs'])]+[(50000+j*10,'DATA '+x) for j,x in enumerate(case.get('data',[]))]
 text='\n'.join(f'{n} {x}' for n,x in rows)+'\n';text=text.replace('@EXIT@','OSCLI "BYE"' if reference else 'END');assert max(len(x.split(' ',1)[1]) for x in text.splitlines())<=255;return text

def main():
 p=argparse.ArgumentParser();p.add_argument('--cli',type=Path,required=True);p.add_argument('--compiler',type=Path,default=TASK/'compiler.bas');p.add_argument('--smoke',action='store_true');p.add_argument('--timeout',type=float,default=1800);a=p.parse_args();b=TASK/'build/errors-language';b.mkdir(parents=True,exist_ok=True);profile=ROOT/'.emulator';sd=profile/'sdcard';assert (profile/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True)
 cases=programs()[:2] if a.smoke else programs();h=module('h',ROOT/'compiler/tools/test_compiler.py');keyboard=module('keyboard',TASK/'io/interactive.py');start=time.monotonic();digest=hashlib.sha256(a.compiler.read_bytes()).hexdigest()
 for i,c in enumerate(cases):
  c['source']=source(c,i);c['reference_source']=source(c,i,True);(sd/f'error-{i}.bas').write_text(c['source']);(sd/f'error-reference-{i}.bas').write_text(c['reference_source']);(b/f'reference-{i}.bas').write_text(c['reference_source'])
  auto=f'load /bin/basic.bin\nrun . /error-reference-{i}.bas\necho ERROR_REF_END_{i}\n'
  if c.get('fatal'):
   log=keyboard.run(profile,auto,[(c['fatal']+' at line','*BYE')],f'ERROR_REF_END_{i}',f'error-reference-{i}.log',timeout_seconds=60)
  else:log=h.run_profile(profile,auto,f'ERROR_REF_END_{i}',f'error-reference-{i}.log',timeout_seconds=60)
  (b/f'reference-{i}.log').write_text(log);body=log.split(f'ERROR_CASE_BEGIN_{i}\n',1)[1].split(f'ERROR_REF_END_{i}\n',1)[0];body=body.replace('>*BYE\n','');assert 'WRONG' not in body,(i,body);c['expected']=body
 (b/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
 before,after=a.compiler.read_text().split('1000 DEF',1)[1].split('20000 DATA',1)
 driver=['10 ON ERROR REPORT:PRINT:CLOSE#0:PRINT "ERROR_COMPILE_FAILED":OSCLI "BYE"','20 PROCinit']+[f'{100+i*10} PROCcompile("error-{i}.bas","error-{i}.bin"):PRINT "OK:ERROR_{i}"' for i in range(len(cases))]+[f'{100+len(cases)*10} PROCcompile("error-0.bas","error-repeat.bin")',f'{110+len(cases)*10} PRINT "ERROR_COMPILE_DONE":OSCLI "BYE"']
 text='\n'.join(driver)+'\n1000 DEF'+before+'20000 DATA'+after;(b/'driver.bas').write_text(text);(sd/'error-driver.bas').write_text(text)
 log=h.run_profile(profile,'load /bin/basic.bin\nrun . /error-driver.bas\n','ERROR_COMPILE_','error-compile.log',timeout_seconds=a.timeout);(b/'compile.log').write_text(log);assert 'ERROR_COMPILE_DONE' in log,log
 assert (sd/'error-0.bin').read_bytes()==(sd/'error-repeat.bin').read_bytes()
 commands=[]
 for i in range(len(cases)):commands += [f'try /error-{i}.bin','echo ERROR_NATIVE_STATUS:<Try$ReturnCode>',f'echo ERROR_NATIVE_END_{i}']
 commands+=['echo ERROR_NATIVE_DONE'];native=h.run_profile(profile,'\n'.join(commands)+'\n','ERROR_NATIVE_DONE','error-native.log',timeout_seconds=120);(b/'native.log').write_text(native)
 for i,c in enumerate(cases):
  got=native.split(f'ERROR_CASE_BEGIN_{i}\n',1)[1].split(f'ERROR_NATIVE_END_{i}\n',1)[0];assert got==c['expected']+f'ERROR_NATIVE_STATUS:{c.get("status",0)}\n',(i,repr(got),c)
  shutil.copy2(sd/f'error-{i}.bin',b/f'p{i}.dat')
 assert hashlib.sha256(a.compiler.read_bytes()).hexdigest()==digest
 report=dict(programs=len(cases),fresh_reference_per_program=True,all_outputs_and_ERR_ERL_match=True,deterministic_repeat=True,duration_seconds=round(time.monotonic()-start,3),compiler_sha256=digest)
 (b/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
