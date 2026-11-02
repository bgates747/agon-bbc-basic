"""Actual BASIC activation probes; fixture preparation only."""
from pathlib import Path
import importlib.util,json
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C004';profile=ROOT/'.emulator'
CASES=[
 ('swapped', ['A%=7:B%=8:PROCswap(A%,B%):PRINT ;A%;":";B%'], ['DEF PROCswap(B%,A%):PRINT ;A%;":";B%:ENDPROC']),
 ('new-local', ['PROCnew:PRINT ;fresh%;":";LEN fresh$'], ['DEF PROCnew:LOCAL fresh%,fresh$:fresh%=4:fresh$="x":ENDPROC']),
 ('staged', ['x%=7:y%=8:PROCstage(3,x%):PRINT ;x%;":";y%'], ['DEF PROCstage(x%,y%):PRINT ;x%;":";y%:ENDPROC']),
 ('snapshot', ['x%=7:PROCtake(FNside):PRINT ;x%'], ['DEF PROCtake(x%):PRINT ;x%:ENDPROC','DEF FNside:x%=9:=1']),
 ('recursive-string', ['PRINT "a"+FNrepeat(3)+"b"'], ['DEF FNrepeat(n%):IF n%=0 THEN ="x" ELSE =FNrepeat(n%-1)+"x"']),
 ('local-through-callee', ['text$="outer":PROCouter:PRINT text$'], ['DEF PROCouter:LOCAL text$:text$="inner":PROCsee:ENDPROC','DEF PROCsee:PRINT text$:ENDPROC']),
 ('repeat-local', ['v%=7:PROCtwice:PRINT ;v%'], ['DEF PROCtwice:LOCAL v%:v%=3:LOCAL v%:PRINT ;v%:v%=4:ENDPROC']),
 ('local-in-loop', ['PROCbad'], ['DEF PROCbad:FOR i%=1 TO 1:LOCAL x%:NEXT:ENDPROC']),
 ('exit-in-loop', ['PROCbad'], ['DEF PROCbad:FOR i%=1 TO 1:ENDPROC:NEXT']),
 ('fn-exit-in-loop', ['PRINT FNbad'], ['DEF FNbad:FOR i%=1 TO 1:=1:NEXT']),
 ('local-top', ['LOCAL x%'], []),
 ('return-top', ['=1'], []),
 ('declaration-inline', ['DEF PROCunused:PRINT "bad":ENDPROC','PRINT "after"'], []),
 ('declaration-fallthrough', ['DEF PROCunused','PRINT "body"','ENDPROC'], []),
]

def main():
 spec=importlib.util.spec_from_file_location('harness',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
 folder=TASK/'activations';records=[]
 for i,(name,main,defs) in enumerate(CASES):
  marker=f'ACTIVATION_ORACLE_{i}_DONE'
  lines=[f'10 ON ERROR REPORT:PRINT:PRINT "{marker}":OSCLI "BYE"']
  lines += [f'{20+j*10} {line}' for j,line in enumerate(main)]
  lines += [f'{20+len(main)*10} PRINT "{marker}":OSCLI "BYE"']
  lines += [f'{1000+j*10} {line}' for j,line in enumerate(defs)]
  source='\n'.join(lines)+'\n';(folder/f'{name}.bas').write_text(source);(profile/'sdcard/activation-oracle.bas').write_text(source)
  log=h.run_profile(profile,'load /bin/basic.bin\nrun . /activation-oracle.bas\n',marker,'activation-oracle.log')
  (folder/f'{name}.log').write_text(log);records.append(dict(name=name,source=source,log=log))
  print(name+': '+log.split('Arthur\n',1)[-1].strip(),flush=True)
 (folder/'oracles.json').write_text(json.dumps(records,indent=2)+'\n')
if __name__=='__main__':main()
