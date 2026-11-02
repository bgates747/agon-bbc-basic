"""Reference differential DATA/READ/RESTORE programs; BBC performs all compilation."""
from pathlib import Path
import importlib.util,json,re,subprocess,sys
TASK=Path(__file__).resolve().parent;ROOT=TASK.parents[2]
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def programs():
 out=[]
 def case(main,data,defs=(),error=False):
  # Explicit fixture line mapping for common reference harness's DATA footer.
  refbase=40000+len(out)*100
  def replace(rows,base):return [x.replace('@DATA@',str(base)).replace('@NEXTDATA@',str(base+10)) for x in rows]
  native_main=(['RESTORE @DATA@'] if data else [])+list(main)
  src='\n'.join([*replace(native_main,50000),'END',*defs,*[f'{50000+j*10} DATA {x}' for j,x in enumerate(data)]])+'\n'
  # CLEAR does not reset DATPTR. Each shared-reference fixture starts at its
  # own explicit footer, and bare RESTORE in its main/definitions uses that
  # same fixture origin. Programs with no DATA use the separately observed42
  # oracle; shared global DATA cannot represent a no-DATA program.
  def reference_line(x):
   x=x.replace('@DATA@',str(refbase)).replace('@NEXTDATA@',str(refbase+1))
   return re.sub(r'\bRESTORE(?=[:\n]|$)',f'RESTORE {refbase}',x)
  ref='\n'.join(reference_line(x) for x in native_main)+'\n'
  result=dict(source=src,reference_source=ref,reference_definitions=['DATA '+x for x in data]+[reference_line(x) for x in defs],reference=bool(data),status=int(error))
  if error and data:result['reference_error']=True
  if not data:result['expected']='Out of DATA\n'
  out.append(result)
 case(['READ a%,b&,x,y,z:PRINT ;a%;":";b&;":";x;":";y;":";z',
       'PRINT ;?(^x+4);":";?(^y+4);":";?(^z+4)',
       'READ s$,t$,u$,v$,w$:PRINT ;LEN s$;":";s$;":";t$;":";u$;":";v$;":";LEN w$',
       'RESTORE:READ a%:PRINT ;a%:RESTORE @NEXTDATA@:READ s$:PRINT s$'],
      ['-123,257,1.0,1E-3,&FFFFFFFF',' leading and trailing  ,"a,b:c","a""b", 123  ,""'])
 case(['DIM a%(1),b&(1),x(1),s$(1)',
       'READ a%(0),b&(0),x(0),s$(0):READ a%(1),b&(1),x(1),s$(1)',
       'PRINT ;a%(0);":";b&(0);":";x(0);":";s$(0)',
       'PRINT ;a%(1);":";b&(1);":";x(1);":";LEN s$(1)',
       's$(0)="changed":PRINT ;LEN s$(1)'],
      ['&80000000,257,1E-20,"first",2147483647,-1,.0,"last"'])
 case(['READ a$,b$,c$,d$:PRINT ;LEN a$;":";LEN b$;":";LEN c$;":";LEN d$'],[',, ,'])
 case(['READ a$,b$:PRINT ;LEN a$;":";b$'],['','"b"'])
 case(['READ a$,b$:PRINT a$;":";b$'],['abc:def,ghi'])
 case(['READ a$,b$:PRINT a$;":";b$'],['1E1000,a%+2'])
 case(['DIM a%(0):READ a%(FNreadindex):READ b%:PRINT ;a%(0);":";b%'],['11,22,33'],
      ['DEF FNreadindex:READ z%:PRINT ;z%:RESTORE:=0'])
 case(['DIM s$(0):READ s$(FNstrreadindex):READ b$:PRINT s$(0);":";b$'],['"one","two","three"'],
      ['DEF FNstrreadindex:READ z$:PRINT z$:RESTORE:=0'])
 case(['READ x:PROClocalread:READ y:PRINT ;x;":";y'],['1,2,3'],
      ['DEF PROClocalread:LOCAL x:READ x:PRINT ;x:ENDPROC'])
 case(['RESTORE @NEXTDATA@:READ x:RESTORE @DATA@:READ y:PRINT ;x;":";y'],['17','23'])
 case(['PRINT ;FNdatarec(3)'],['1,2,3,4'],
      ['DEF FNdatarec(n%):LOCAL x:READ x:IF n%=0 THEN =x ELSE =x+FNdatarec(n%-1)'])
 case(['READ a,b,c,d,e:PRINT ;a;":";b;":";c;":";d;":";e',
       'PRINT ;?(^a+4);":";?(^b+4);":";?(^c+4);":";?(^d+4);":";?(^e+4)'],
      ['-&80000000,+&FFFFFFFF,-0.0,-1E-50,4294967296.0'])
 # Real runtime loader row shape: numeric metadata, byte-exact hex string and
 # relocation list, consumed through scalar and indexed READ in generated code.
 case(['READ n%,r%,e%:READ raw$:DIM reloc%(1):READ reloc%(0),reloc%(1)',
       'PRINT ;n%;":";r%;":";e%;":";raw$;":";reloc%(0);":";reloc%(1)'],
      ['633,2,0','"E1DDE5D1010000004E03EDB0E5C9"','407,500'])
 for main,data,defs in [
  (['READ x'],[],()),(['READ x'],[''],()),(['READ x'],['"123"'],()),
  (['READ x'],['1E1000'],()),(['READ x%'],['-2147483648'],()),(['READ x%'],['1E20'],()),
  (['READ a,b'],['1'],()),(['DIM a%(0):READ a%(1)'],['1'],()),
  (['DIM a%(0):READ a%(FNneverindex)'],[],['DEF FNneverindex:PRINT "WRONG":=0']),
 ]:case(main,data,defs,error=True)
 out += [dict(source=s,diagnostic=d) for s,d in [
  ('READ x\nDATA 1+2\n','Numeric READ requires literal DATA fields'),
  ('READ x\nDATA name\n','Numeric READ requires literal DATA fields'),
  ('PRINT "x":DATA 1\n','DATA must lead a physical line'),
  ('READ s$\nDATA "a"junk\n','Trailing text after quoted DATA is unqualified'),
  ('RESTORE variable\n','Expected an unsigned integer constant'),
  ('RESTORE +1\n','Expected an unsigned integer constant'),
  ('RESTORE LOCAL\n','Expected an unsigned integer constant'),
  ('RESTORE 500\n','Undefined target $data#500'),
  ('READ ?p%\n','Expected a name'),
  ('READ s$\nDATA ab\x01cd\n','Control bytes in DATA are unsupported'),
 ]]
 return out

def main():
 h=mod('output_data',ROOT/'docs/tasks/C002/tools/test_output.py');h.TASK=TASK
 smoke='--smoke' in sys.argv
 if smoke:sys.argv.remove('--smoke')
 h.programs=(lambda:programs()[:2]) if smoke else programs
 sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main();b=TASK/'build/output-integration';rt=TASK/'build/data-runtime';template=(rt/'runtime-0.bin').read_bytes();rows=[]
 for i,c in enumerate(json.loads((b/'cases.json').read_text())):
  if 'diagnostic' in c:continue
  data=(ROOT/'.emulator/sdcard'/f'p{i}.bin').read_bytes();pos=data.find(template)
  if pos<0:continue
  rows.append(dict(program=i,base=0x40000+pos,bytes=len(template)))
 assert len(rows)==sum('diagnostic' not in c for c in json.loads((b/'cases.json').read_text()))
 (b/'data-links.json').write_text(json.dumps(rows,indent=2)+'\n');print('Exact position-independent DATA helpers:',rows)
if __name__=='__main__':main()
