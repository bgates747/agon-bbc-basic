"""Compile-time exclusions and output preservation for the handler admission."""
from pathlib import Path
import importlib.util,sys
ROOT=Path(__file__).resolve().parents[3];TASK=ROOT/'docs/tasks/C005'
def programs():
 return [dict(source='PRINT "ERROR ERR ERL REPORT":END\n',reference_source='PRINT "ERROR ERR ERL REPORT"\n',reference=True,status=0)]+[dict(source=s,diagnostic=d) for s,d in [
  ('IF 1 THEN ON ERROR PRINT "bad"\n','ON ERROR handler installation inside inline IF is unsupported'),
  ('ON ERROR PRINT "first":ON ERROR PRINT "second"\n','Only one ON ERROR handler body per physical line is supported'),
  ('ERROR 100,FNtext\nEND\nDEF FNtext="text"\n','Direct FN error-message carriers are unqualified'),
  ('LOCAL DATA\n','Unsupported LOCAL form DATA'),
  ('ON 1 GOTO 100\n100 END\n','Expected ERROR'),
  ('RESTORE ERROR\n','Expected an unsigned integer constant'),
  ('PRINT REPORT$\n','Unsupported string item REPORT'),
  ('ERROR 100\n','Expected ,'),
  ('PRINT EVAL("1")\n','EVAL is deliberately unsupported'),
 ]]
def main():
 sp=importlib.util.spec_from_file_location('h',ROOT/'docs/tasks/C002/tools/test_output.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);h.TASK=TASK;h.programs=programs;sys.argv+=['--skip-legacy'];h.main()
 assert (ROOT/'.emulator/sdcard/p0.bin').stat().st_size<1024,'Quoted words must not enable error-runtime instrumentation'
if __name__=='__main__':main()
