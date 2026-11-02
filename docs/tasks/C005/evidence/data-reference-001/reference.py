"""Observe DATA boundaries, values, destination order and cursor behavior in BBC."""
from pathlib import Path
import hashlib,importlib.util,json,time
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def cases():
 return [
 ('numeric', ['READ a%,b&,x,y,z:PRINT ;a%;":";b&;":";x;":";y;":";z',
   'PRINT ;?(^x+4);":";?(^y+4);":";?(^z+4)'], ['500 DATA -123,257,1.0,1/3,&FFFFFFFF']),
 ('strings', ['READ a$,b$,c$,d$,e$:PRINT ;LEN a$;":";a$;":";LEN b$;":";b$;":";LEN c$;":";c$;":";LEN d$;":";d$;":";LEN e$'],
   ['500 DATA   leading and trailing  ,"a,b:c","a""b", 123  ,""']),
 ('empty-strings', ['READ a$,b$,c$,d$:PRINT ;LEN a$;":";LEN b$;":";LEN c$;":";LEN d$'],['500 DATA ,, ,']),
 ('empty-numeric', ['READ x:PRINT x'],['500 DATA ,1']),
 ('blank-data', ['READ a$:PRINT ;LEN a$:READ b$:PRINT ;LEN b$'],['500 DATA','510 DATA "b"']),
 ('quoted-numeric', ['READ x:PRINT x'],['500 DATA "123"']),
 ('numeric-expression', ['a%=7:READ x,y:PRINT ;x;":";y'],['500 DATA a%+1,2^3']),
 ('colon-unquoted', ['READ a$,b$:PRINT a$;":";b$'],['500 DATA abc:def,ghi']),
 ('colon-numeric', ['READ x,y:PRINT ;x;":";y'],['500 DATA 1:ignored,2']),
 ('restore', ['READ a%:RESTORE:READ b%:RESTORE 510:READ c%:RESTORE 520:READ d%:PRINT ;a%;":";b%;":";c%;":";d%'],
   ['500 DATA 11','510 REM not DATA','520 DATA 22','530 DATA 33']),
 ('nonleading', ['READ a%:PRINT ;a%'],['500 REM ignored:DATA 1','510 PRINT "skip":DATA 2','520 DATA 3']),
 ('empty-target-order', ['DIM a%(0):READ a%(FNidx)'],['1000 DEF FNidx:PRINT "INDEX_CALLED":=0']),
 ('nested-cursor', ['DIM a%(0):READ a%(FNidx):READ b%:PRINT ;a%(0);":";b%'],
   ['500 DATA 11,22,33','1000 DEF FNidx:READ z%:PRINT ;z%:RESTORE:=0']),
 ('numeric-overflow-string', ['READ s$:PRINT s$'],['500 DATA 1E1000']),
 ('numeric-overflow', ['READ x'],['500 DATA 1E1000']),
 ('trailing-quoted', ['READ a$,b$:PRINT a$;":";b$'],['500 DATA "a"x,b']),
 ('retry-conversion', ['ON ERROR PRINT ;ERR:READ s$:PRINT s$:OSCLI "BYE"','READ a%'],['500 DATA "retry"']),
 ('retry-store', ['ON ERROR PRINT ;ERR:READ s$:PRINT s$:OSCLI "BYE"','READ a%'],['500 DATA 1E20']),
 ]
def main():
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 dest=TASK/'evidence/data-reference-001';dest.mkdir(parents=True,exist_ok=True);profile=ROOT/'.emulator';auto='';names=[]
 for i,(name,body,extra) in enumerate(cases()):
  lines=['10 ON ERROR PRINT "REF_ERR=";ERR;":";ERL:REPORT:PRINT:OSCLI "BYE"']+[f'{100+j*10} {x}' for j,x in enumerate(body)]+['490 OSCLI "BYE"']+extra
  ns=[int(x.split()[0]) for x in lines];assert ns==sorted(set(ns))
  text='\n'.join(lines)+'\n';(dest/(name+'.bas')).write_text(text);(profile/'sdcard'/f'data-ref-{i}.bas').write_text(text)
  auto+=f'echo DATA_BEGIN_{i}\nload /bin/basic.bin\nrun . /data-ref-{i}.bas\necho DATA_END_{i}\n';names.append(name)
 auto+='echo DATA_REFERENCE_DONE\n';start=time.monotonic()
 log=h.run_profile(profile,auto,'DATA_REFERENCE_DONE','data-reference.log',timeout_seconds=120);(dest/'reference.log').write_text(log)
 report=dict(scope='Actual interpreted DATA observations only',observations={name:log.split(f'DATA_BEGIN_{i}\n',1)[1].split(f'DATA_END_{i}\n',1)[0] for i,name in enumerate(names)},duration_seconds=round(time.monotonic()-start,3),basic_sha256=hashlib.sha256((ROOT/'bin/basic.bin').read_bytes()).hexdigest())
 (dest/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
