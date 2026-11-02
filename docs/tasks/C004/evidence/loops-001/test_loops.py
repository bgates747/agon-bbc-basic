"""Differential native loop qualification; Python only runs actual BASIC."""
from pathlib import Path
import importlib.util,sys,json,subprocess
TASK=Path(__file__).resolve().parents[1];ROOT=TASK.parents[2]
def programs():
 groups=[
 ['i%=0:REPEAT:i%=i%+1:PRINT ;i%:UNTIL i%=3','WHILE i%>0:i%=i%-1:PRINT ;i%:ENDWHILE','FOR i%=1 TO 3:PRINT ;i%:NEXT:PRINT "done"'],
 ['i%=0:REPEAT','i%=i%+1:IF i%=2 THEN PRINT "middle"','UNTIL i%>=3','PRINT ;i%','WHILE FALSE:PRINT "bad":ENDWHILE','PRINT "zero while"'],
 ['FOR i%=3 TO 1:PRINT ;i%:NEXT','FOR i%=1 TO 3 STEP -1:PRINT ;i%:NEXT','FOR i%=3 TO 1 STEP -1:PRINT ;i%:NEXT','FOR i%=1 TO 1:PRINT ;i%:NEXT','PRINT ;i%'],
 ['FOR x=0 TO 1 STEP .25:PRINT ;x:NEXT','FOR x=1 TO 0 STEP -.25:PRINT ;x:NEXT','FOR i%=0 TO 3 STEP 1.9:PRINT ;i%:NEXT','FOR i%=3 TO 0 STEP -1.9:PRINT ;i%:NEXT'],
 ['FOR b&=254 TO 255:PRINT ;b&:NEXT','FOR b&=1 TO 0 STEP -1:PRINT ;b&:NEXT','PRINT ;b&'],
 ['total%=0:FOR i%=1 TO 2:FOR j%=1 TO 3:total%=total%+i%*j%:NEXT j%,i%:PRINT ;total%', 'i%=0:WHILE i%<2:j%=0:REPEAT:j%=j%+1:UNTIL j%=2:i%=i%+1:ENDWHILE:PRINT ;i%;":";j%'],
 ['limit%=2:step%=1:FOR i%=1 TO limit% STEP step%:PRINT ;i%:limit%=0:step%=5:NEXT:PRINT ;i%','i%=0:REPEAT:i%=i%+1:UNTIL i%/3:PRINT ;i%','i%=3:WHILE i%/3:PRINT ;i%:i%=i%-1:ENDWHILE'],
 ['FOR i%=1 TO 2','IF i%=1 THEN','PRINT "first"','ELSE','PRINT "second"','ENDIF','NEXT i%','FOR i%=1 TO 2:FOR j%=1 TO 2:PRINT ;i%;":";j%:NEXT i%'],
 ]
 result=[dict(source='\n'.join(g)+'\n',reference=True,status=0) for g in groups]
 result += [dict(source=s,reference=True,reference_error=True,status=1) for s in [
 'WHILE 1/0:ENDWHILE\n','REPEAT:UNTIL 2147483648\n','FOR i%=0 TO 1 STEP 1/0:NEXT\n','FOR i%=2147483648 TO 2:NEXT\n','FOR i%=0 TO missing:NEXT\n','FOR i%=0 TO 1 STEP missing:NEXT\n']]
 result += [dict(source=s,expected=e,status=status) for s,e,status in [
 ('FOR i%=1 TO 3:GOSUB @sub:NEXT:PRINT "done":END\n@sub:PRINT ;i%:RETURN\n','1\n2\n3\ndone\n',0),
 ('GOSUB @sub:END\n@sub:REPEAT:RETURN:UNTIL 1\n','No GOSUB\n',1),
 ('GOSUB @sub:END\n@sub:WHILE 1:RETURN:ENDWHILE\n','No GOSUB\n',1),
 ('GOTO @inside\nREPEAT\n@inside:PRINT "body":UNTIL 1\n','body\nNot in a REPEAT loop\n',1),
 ('GOTO @inside\nWHILE 1\n@inside:PRINT "body":ENDWHILE\n','body\nNot in a WHILE loop\n',1),
 ('GOTO @inside\nFOR i%=1 TO 1\n@inside:PRINT "body":NEXT\n','body\nNot in a FOR loop\n',1),
 ]]
 result += [dict(source=s,diagnostic=d) for s,d in [
 ('REPEAT\n','Missing loop terminator'),('WHILE 1\n','Missing loop terminator'),('FOR i%=1 TO 2\n','Missing loop terminator'),('UNTIL 1\n','Loop terminator without loop'),('ENDWHILE\n','Loop terminator without loop'),('NEXT\n','NEXT without FOR'),('REPEAT:ENDWHILE\n','Mismatched loop terminator'),('FOR a$="x" TO 2:NEXT\n','FOR needs a numeric variable'),('FOR i%=1 STEP 2:NEXT\n','Expected TO'),('FOR i%=1 TO 2:NEXT j%\n','NEXT variable has no matching FOR'),('IF 1 THEN\nWHILE 0\nENDIF\nENDWHILE\n','ENDIF crosses a loop boundary'),('WHILE 1\nIF 1 THEN\nENDWHILE\nENDIF\n','Mismatched loop terminator')]]
 return result
def check_control_images():
 build=TASK/'build/output-integration';runtime=TASK/'build/control-runtime'
 metadata=json.loads((runtime/'runtime.json').read_text());template=(runtime/'runtime-0.bin').read_bytes()
 numeric=(ROOT/'compiler/build/numeric-runtime/runtime-0.bin').read_bytes();exports=metadata['exports'];observed=[]
 for i,case in enumerate(json.loads((build/'cases.json').read_text())):
  if 'diagnostic' in case:continue
  image=(ROOT/'.emulator/sdcard'/f'p{i}.bin').read_bytes()
  found=image.find(template[9:15]);position=found-9
  if found<0:continue
  base=0x40000+position;linked=build/f'control-{base:x}.dat'
  subprocess.run(['/Agon/agondev/release/bin/ez80-none-elf-ld',f'-Ttext=0x{base:x}','-e','ctl_init','--oformat=binary','-o',str(linked),str(runtime/'runtime.o')],check=True)
  expected=bytearray(linked.read_bytes());numpos=image.find(numeric[:20]);assert numpos>=0
  slot=exports['ctl_numslot'];numaddr=0x40000+numpos+json.loads((ROOT/'compiler/build/numeric-runtime/runtime.json').read_text())['exports']['rt_numeric']
  expected[slot:slot+3]=numaddr.to_bytes(3,'little');assert image[position:position+len(expected)]==expected,(i,position)
  start=int.from_bytes(image[1:4],'little')-0x40000
  assert image[start:start+8]==bytes([0xcd])+(base+exports['ctl_init']).to_bytes(3,'little')+bytes([0xc3])+bytes([0x45,0,4])
  observed.append(base)
 report=json.loads((build/'results.json').read_text());report['independent_control_link_bases']=observed;report['control_numeric_bridge_checked']=True;report['control_entry_reset_checked']=True
 (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
 print('Independent control links:',observed)

if __name__=='__main__':
 smoke='--smoke' in sys.argv
 if smoke:sys.argv.remove('--smoke')
 spec=importlib.util.spec_from_file_location('output',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 compiler=Path(sys.argv[sys.argv.index('--compiler')+1]) if '--compiler' in sys.argv else ROOT/'compiler/compiler.bas'
 lines=compiler.read_text().splitlines();ids=[int(l.split()[0]) for l in lines];assert ids==sorted(set(ids)) and max(len(l.split(' ',1)[1]) for l in lines)<=255
 h.TASK=TASK;h.programs=(lambda:programs()[:1]) if smoke else programs
 sys.argv+=['--isolate-reference','--skip-legacy']
 if '--string-runtime' not in sys.argv:sys.argv+=['--string-runtime',str(ROOT/'compiler/build/string-runtime')]
 h.main()
 check_control_images()
