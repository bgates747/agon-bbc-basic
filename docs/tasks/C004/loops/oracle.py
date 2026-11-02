"""Reference marker probes for fixtures requiring numbered GOSUB/GOTO targets."""
from pathlib import Path
import importlib.util,json
ROOT=Path(__file__).resolve().parents[4];profile=ROOT/'.emulator'
CASES=[
 ('for-gosub',['FOR i%=1 TO 3:GOSUB 1000:NEXT:PRINT "done"'],['1000 PRINT ;i%:RETURN'],'1\n2\n3\ndone\n'),
 ('repeat-return',['GOSUB 1000'],['1000 REPEAT:RETURN:UNTIL 1'],'No GOSUB\n'),
 ('while-return',['GOSUB 1000'],['1000 WHILE 1:RETURN:ENDWHILE'],'No GOSUB\n'),
 ('repeat-enter',['GOTO 1010'],['1000 REPEAT','1010 PRINT "body":UNTIL 1'],'body\nNot in a REPEAT loop\n'),
 ('while-enter',['GOTO 1010'],['1000 WHILE 1','1010 PRINT "body":ENDWHILE'],'body\nNot in a WHILE loop\n'),
 ('for-enter',['GOTO 1010'],['1000 FOR i%=1 TO 1','1010 PRINT "body":NEXT'],'body\nNot in a FOR loop\n'),
]
def main():
 spec=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 folder=ROOT/'docs/tasks/C004/loops';records=[]
 for i,(name,main,defs,expected) in enumerate(CASES):
  begin=f'LOOP_REF_BEGIN_{i}';end=f'LOOP_REF_END_{i}'
  lines=[f'10 ON ERROR REPORT:PRINT:PRINT "{end}":OSCLI "BYE"',f'20 PRINT "{begin}"']
  lines += [f'{30+j*10} {line}' for j,line in enumerate(main)]
  lines += [f'{30+len(main)*10} PRINT "{end}":OSCLI "BYE"',*defs]
  source='\n'.join(lines)+'\n';(folder/f'{name}.bas').write_text(source);(profile/'sdcard/loop-oracle.bas').write_text(source)
  log=h.run_profile(profile,'load /bin/basic.bin\nrun . /loop-oracle.bas\n',end,'loop-oracle.log');(folder/f'{name}.log').write_text(log)
  actual=log.split(begin+'\n',1)[1].split(end+'\n',1)[0];assert actual==expected,(name,actual,expected)
  records.append(dict(name=name,source=source,expected=expected,actual=actual));print(name+': '+repr(actual),flush=True)
 (folder/'oracles.json').write_text(json.dumps(records,indent=2)+'\n')
if __name__=='__main__':main()
