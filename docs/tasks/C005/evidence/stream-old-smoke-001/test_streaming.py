"""BBC streaming resource and referenced-target tests; Python only builds fixtures."""
from pathlib import Path
import importlib.util,sys,json
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005'
def programs():
 return [
  dict(source='10 GOTO 100\n20 PRINT "WRONG"\n100 GOSUB 300\n110 IF 1 THEN 200 ELSE 200\n200 PRINT "targets":END\n300 RETURN\n',reference=True,status=0),
  dict(source='10 PROCp:END\n100 DEF PROCp:GOTO 130\n110 PRINT "WRONG":ENDPROC\n130 PRINT "scoped":ENDPROC\n',reference=True,status=0),
  dict(source='10 DATA 1,"text"\n20 READ a,s$:PRINT ;a;":";s$:RESTORE 10:READ a:PRINT ;a:END\n',reference=True,status=0),
  dict(source='PRINT "GOTO 65279 GOSUB 0 THEN 2 ELSE 3 RESTORE 4":END\nREM GOTO 1\n',reference=True,status=0),
  dict(source='10 GOTO 100\n20 END\n',diagnostic='Undefined target #100'),
  dict(source='10 PROCp:END\n100 DEF PROCp:GOTO 20\n110 ENDPROC\n',diagnostic='Undefined target $p1#20'),
  dict(source='10 DATA 1\n20 RESTORE 30:END\n30 PRINT "not DATA"\n',diagnostic='Undefined target $data#30'),
  dict(source='@same:\n@same:\n',diagnostic='Duplicate target @same'),
  dict(source='10 PRINT "one"\n10 PRINT "two"\n',diagnostic='Line numbers must increase'),
  dict(source='READ s$:PRINT s$:FOR i%=1 TO 300:READ s$:NEXT\nPRINT ;LEN s$:RESTORE:READ s$:PRINT s$:END\nDATA "first"\n'+('DATA "'+'q'*248+'"\n')*300,expected='first\n248\nfirst\n',status=0,reference=False),
  dict(source='PRINT "many-labels":END\n'+''.join(f'@L{i:04d}:\n' for i in range(2048)),expected='many-labels\n',status=0,reference=False),
  dict(source=''.join(f'@L{i:04d}:\n' for i in range(4097)),diagnostic='Too many labels'),
 ]
def main():
 sp=importlib.util.spec_from_file_location('h',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);h.TASK=TASK;cases=programs()
 if '--smoke' in sys.argv:sys.argv.remove('--smoke');cases=cases[:5]
 # Numeric targets must retain their actual BASIC numbers; the shared harness
 # otherwise assigns its own. Probe these conventional sources independently.
 spec=importlib.util.spec_from_file_location('host',ROOT/'compiler/tools/test_compiler.py');host=importlib.util.module_from_spec(spec);spec.loader.exec_module(host);b=TASK/'build/output-integration';b.mkdir(parents=True,exist_ok=True);sd=ROOT/'.emulator/sdcard';oracles=[]
 for i,c in enumerate(cases):
  if not c.get('reference'):continue
  rows=c['source'].splitlines()
  if not rows[0][0].isdigit():rows=[f'{10+j*10} {row}' for j,row in enumerate(rows)]
  text='1 PRINT "STREAM_REFERENCE_BEGIN"\n'+'\n'.join(rows).replace(':END\n',':OSCLI "BYE"\n')+'\n'
  # The last statement line can end without a following newline before join.
  text=text.replace(':END\n',':OSCLI "BYE"\n');(b/f'stream-reference-{i}.bas').write_text(text);(sd/f'stream-reference-{i}.bas').write_text(text)
  out=host.run_profile(ROOT/'.emulator',f'echo STREAM_REF_BEGIN\nload /bin/basic.bin\nrun . /stream-reference-{i}.bas\necho STREAM_REF_END\n','STREAM_REF_END',f'stream-reference-{i}.log',timeout_seconds=120);(b/f'stream-reference-{i}.log').write_text(out);c['expected']=out.split('STREAM_REFERENCE_BEGIN\n',1)[1].split('STREAM_REF_END\n',1)[0];c['reference']=False;oracles.append(i)
 (b/'stream-reference-probes.json').write_text(json.dumps(oracles)+'\n')
 if '--compiler' not in sys.argv:sys.argv+=['--compiler',str(TASK/'streaming/compiler.bas')]
 h.programs=lambda:cases;sys.argv+=['--skip-legacy','--string-runtime',str(ROOT/'compiler/build/string-runtime')];h.main()
 if len(cases)>9:assert (ROOT/'.emulator/sdcard/p9.bin').stat().st_size>65536,'Large output must actually exceed the old buffer'
if __name__=='__main__':main()
