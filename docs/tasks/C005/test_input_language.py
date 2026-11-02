"""Compile INPUT LINE in BBC, then compare actual keyboard-driven reference/native output."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,time
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def main():
 p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,default=TASK/'compiler.bas');p.add_argument('--cli',type=Path,required=True);a=p.parse_args()
 profile=ROOT/'.emulator';assert (profile/'fab-agon-emulator.bin').resolve()==a.cli.resolve(strict=True)
 b=TASK/'build/input-language';b.mkdir(parents=True,exist_ok=True)
 body=['s$="old"','INPUT LINE "FRONT_ALPHA:"s$:PRINT ;LEN s$;":";s$',
       'INPUT LINE "FRONT_EMPTY:"s$:PRINT ;LEN s$',
       'INPUT LINE "FRONT_MAX:"s$:PRINT ;LEN s$;":";ASC s$;":";ASC RIGHT$(s$)',
       'PRINT "FRONT_BARE:":INPUT LINE s$:PRINT ;LEN s$;":";s$',
       'PRINT "INPUT_LANGUAGE_DONE"']
 source='\n'.join(body)+'\n';(b/'source.bas').write_text(source);(profile/'sdcard/input-language.bas').write_text(source)
 defs=a.compiler.read_text().split('1000 DEF',1)[1]
 driver='10 ON ERROR REPORT:PRINT:CLOSE#0:PRINT "INPUT_COMPILE_FAILED":OSCLI "BYE"\n20 PROCinit:PROCcompile("input-language.bas","input-language.bin")\n30 PRINT "INPUT_COMPILE_DONE":OSCLI "BYE"\n1000 DEF'+defs
 (b/'driver.bas').write_text(driver);(profile/'sdcard/input-language-driver.bas').write_text(driver)
 h=mod('compile_input',ROOT/'compiler/tools/test_compiler.py');start=time.monotonic()
 log=h.run_profile(profile,'load /bin/basic.bin\nrun . /input-language-driver.bas\n','INPUT_COMPILE_', 'input-language-compile.log',timeout_seconds=600)
 (b/'compile.log').write_text(log);assert 'INPUT_COMPILE_DONE' in log,log
 shutil.copy2(profile/'sdcard/input-language.bin',b/'program.dat')
 ref='10 ON ERROR REPORT:PRINT:OSCLI "BYE"\n'+'\n'.join(f'{100+i*10} {line}' for i,line in enumerate(body))+f'\n{100+len(body)*10} OSCLI "BYE"\n'
 (b/'reference.bas').write_text(ref);(profile/'sdcard/input-language-reference.bas').write_text(ref)
 keyboard=mod('keyboard',TASK/'io/interactive.py');steps=[('FRONT_ALPHA:','alpha'),('FRONT_EMPTY:',''),('FRONT_MAX:','q'*255),('FRONT_BARE:','beta')]
 logs={}
 for name,auto in [('reference','load /bin/basic.bin\nrun . /input-language-reference.bas\necho INPUT_SESSION_DONE\n'),('native','try /input-language.bin\necho INPUT_NATIVE_STATUS:<Try$ReturnCode>\necho INPUT_SESSION_DONE\n')]:
  out=keyboard.run(profile,auto,steps,'INPUT_SESSION_DONE','input-language-'+name+'.log',timeout_seconds=120);(b/(name+'.log')).write_text(out)
  logs[name]=out.split('FRONT_ALPHA:',1)[1].split('INPUT_LANGUAGE_DONE',1)[0]
 assert logs['reference']==logs['native'],logs
 assert 'INPUT_NATIVE_STATUS:0\n' in (b/'native.log').read_text()
 report=dict(exact_prompt_and_output_match=True,ordinary_empty_max255_and_default_prompt=True,duration_seconds=round(time.monotonic()-start,3),source_sha256=hashlib.sha256(a.compiler.read_bytes()).hexdigest(),output=logs['native'])
 (b/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
