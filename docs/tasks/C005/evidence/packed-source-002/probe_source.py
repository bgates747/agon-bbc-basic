"""Measure exact source layout/compilation with optional BBC-only host progress.
Host progress PRINTs are not compiled into the supplied target compiler source.
This is C005 resource evidence, not an unmodified-main C006 generation claim.
"""
from pathlib import Path
import argparse,hashlib,importlib.util,json,re,shutil,time,signal,threading
ROOT=Path(__file__).resolve().parents[4];TASK=ROOT/'docs/tasks/C005';PROFILE=ROOT/'.emulator'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,default=TASK/'streaming/compiler.bas');p.add_argument('--name',required=True);p.add_argument('--timeout',type=float,default=7200);p.add_argument('--progress',action='store_true');p.add_argument('--private-name-map',type=Path);p.add_argument('--short-names',action='store_true');p.add_argument('--layout-only',action='store_true');p.add_argument('--private-storage',action='store_true');a=p.parse_args();d=TASK/'evidence'/a.name;assert not d.exists();d.mkdir(parents=True);source=a.compiler.read_text();body='1000 DEF'+source.split('1000 DEF',1)[1]
 mapping={}
 assert not (a.short_names and a.private_name_map)
 if a.short_names:
  assert 'DEF PROCcompile(source$,target$)' in source
  mapping={n:n[1:] for n in ['cpc%','csnum%','cpnum%','cvnum%','cphase%','clnum%','cpos%','cretnum%']}
 if a.private_name_map:
  record=json.loads(a.private_name_map.read_text());assert record['candidate_sha256']==digest(a.compiler);mapping=record['mapping'];shutil.copy2(a.private_name_map,d/'private-name-map.json')
 def names(t):return re.sub(r'"(?:[^"\n]|"")*"|[A-Za-z_][A-Za-z0-9_]*[$%&]?',lambda m:mapping.get(m.group(),m.group()),t)
 sd=PROFILE/'sdcard';shutil.copy2(a.compiler,d/'compiler.bas');shutil.copy2(__file__,d/'probe_source.py')
 if a.progress:
  rows=body.splitlines();new=[]
  for row in rows:
   if row.startswith('1101 '):row+=names(':PRINT "SOURCE_PASS_BEGIN:";cphase%')
   new.append(row)
   if row.startswith('1092 '):new.append(names('1093 PRINT "SOURCE_SCAN_DONE:";cpnum%;":";cretnum%;":";cvnum%'))
   if row.startswith('1190 '):new.append(names('1195 IF clnum% MOD 100=0 PRINT "SOURCE_LINE:";cphase%;":";clnum%;":";cpc%;":";csnum%;":";cvnum%'))
   if row.startswith('1260 '):new.append(names('1265 PRINT "SOURCE_PASS_END:";cphase%;":";cpc%;":";csnum%;":";cvnum%'))
   if row.startswith('13190 '):new.append(names('13195 IF clnum% MOD 250=0 PRINT "SOURCE_SCAN_LINE:";clnum%'))
  body='\n'.join(new)+'\n'
 if a.layout_only:
  assert body.count('1095 FOR cphase%=1 TO 3')==1;body=body.replace('1095 FOR cphase%=1 TO 3','1095 FOR cphase%=1 TO 1')
 main=['10 ON ERROR GOTO 100', '15 cpc%=0:csnum%=0:cpnum%=0:cvnum%=0:clnum%=0:cpos%=0:cphase%=0', '20 PROCinit:PRINT "SOURCE_INIT_DONE"', '30 PROCcompile("self-source.bas","self-probe.bin")', '40 PRINT "SOURCE_PROBE_SUCCESS"', '50 PRINT "SOURCE_COUNTERS:";cpc%;":";csnum%;":";cpnum%;":";cvnum%', '60 PRINT "SOURCE_POSITION:";cphase%;":";clnum%;":";cpos%', '70 CLOSE#0:PRINT "SOURCE_PROBE_DONE":OSCLI "BYE"', '100 PRINT "SOURCE_PROBE_ERROR":REPORT:PRINT', '110 PRINT "SOURCE_COUNTERS:";cpc%;":";csnum%;":";cpnum%;":";cvnum%', '120 PRINT "SOURCE_POSITION:";cphase%;":";clnum%;":";cpos%', '130 CLOSE#0:PRINT "SOURCE_PROBE_DONE":OSCLI "BYE"']
 observer=''
 if a.private_storage:
  assert 'DEF FNrefpage(i%,w%)' in source and 'DIM sname$(4095),saddr% 12287,sort% 8191,lrefs%(63)' in source
  assert body.count('1260 PROCdefine("$start",start%)')==1
  body=body.replace('1260 PROCdefine("$start",start%)','1260 PROCdefine("$start",start%)\n1262 IF phase%=1 PROCstorageobservation')
  observer='''500 DEF PROCstorageobservation
501 LOCAL i%,n%
502 n%=0:FOR i%=0 TO 63
503 IF lrefs%(i%)<>0 n%=n%+1
504 NEXT:PRINT "SOURCE_PRIVATE_PAGES:";n%
505 n%=0:FOR i%=0 TO 4095:n%=n%+LEN(sname$(i%)):NEXT
506 PRINT "SOURCE_SYMBOL_BYTES:";n%
507 n%=0:FOR i%=0 TO 255:n%=n%+LEN(pname$(i%))+LEN(vname$(i%)):NEXT
508 FOR i%=0 TO 511:n%=n%+LEN(return$(i%)):NEXT
509 FOR i%=0 TO 4:n%=n%+LEN(kwords$(i%)):NEXT
510 FOR i%=0 TO 31:n%=n%+LEN(ifid$(i%))+LEN(bid$(i%))+LEN(lname$(i%)):NEXT
511 PRINT "SOURCE_METADATA_STRING_BYTES:";n%
512 ENDPROC
'''
 driver='\n'.join(names(row) for row in main)+'\n'+observer+body;assert max(len(row.split(' ',1)[1]) for row in driver.splitlines())<=255;(d/'driver.bas').write_text(driver);(sd/'source-probe-driver.bas').write_text(driver);(sd/'self-source.bas').write_text(source);sentinel=b'Prior output survives source-resource failure';(sd/'self-probe.bin').write_bytes(sentinel);sp=importlib.util.spec_from_file_location('h',ROOT/'compiler/tools/test_compiler.py');h=importlib.util.module_from_spec(sp);sp.loader.exec_module(h);start=time.monotonic();report=dict(scope='Actual source-resource experiment, not C006 generation proof',source_sha256=digest(a.compiler),host_driver_sha256=digest(d/'driver.bas'),host_progress_instrumentation=a.progress,host_storage_observation=a.private_storage,host_counter_names=mapping,layout_only=a.layout_only,hardware_validation=False,inputs={str(q):digest(q) for q in [ROOT/"bin/basic.bin",PROFILE/"mos_platform.bin",PROFILE/"fab-agon-emulator.bin",PROFILE/"fab-agon-emulator"]})
 stop=threading.Event();watcher=None;profile_log=PROFILE/'source-probe.log'
 profile_log.unlink(missing_ok=True)
 def interrupt(signum,frame):
  report['interrupted_by_signal']=signum
  (d/'interruption.json').write_text(json.dumps(dict(signal=signum,observed_unix_time=time.time(),source_sha256=report['source_sha256']),indent=2)+'\n')
  if profile_log.exists():shutil.copy2(profile_log,d/'native-host.log')
  raise InterruptedError(f'Controller received signal {signum}')
 old_term=signal.signal(signal.SIGTERM,interrupt)
 if a.progress:
  def observe():
   seen=0
   while not stop.wait(2):
    if not profile_log.exists():continue
    rows=profile_log.read_text(errors='replace').split('\n')[:-1]
    for row in rows[seen:]:
     if row.startswith('SOURCE_'):print(row,flush=True)
    seen=len(rows)
  watcher=threading.Thread(target=observe,daemon=True);watcher.start()
 try:
  ks=importlib.util.spec_from_file_location('keyboard',TASK/'io/interactive.py');keyboard=importlib.util.module_from_spec(ks);ks.loader.exec_module(keyboard);log=keyboard.run(PROFILE,'load /bin/basic.bin\nrun . /source-probe-driver.bas\n',[],'SOURCE_PROBE_DONE','source-probe.log',timeout_seconds=a.timeout,abort_patterns=[(0,'\n>')]);(d/'native-host.log').write_text(log);report['source_compilation_succeeded']='SOURCE_PROBE_SUCCESS' in log;report['counters']=log.split('SOURCE_COUNTERS:',1)[1].splitlines()[0].strip();report['source_position']=log.split('SOURCE_POSITION:',1)[1].splitlines()[0].strip()
  if report['source_compilation_succeeded'] and not a.layout_only:
   blob=(sd/'self-probe.bin').read_bytes();assert blob[64:69]==b'MOS\x00\x01';shutil.copy2(sd/'self-probe.bin',d/'native-compiler.dat');report.update(image_bytes=len(blob),image_sha256=digest(d/'native-compiler.dat'))
  else:assert (sd/'self-probe.bin').read_bytes()==sentinel;report['old_output_preserved']=True
 except BaseException as err:
  report['failure']=repr(err)
  if (PROFILE/'source-probe.log').exists():shutil.copy2(PROFILE/'source-probe.log',d/'native-host.log')
  raise
 finally:
  stop.set()
  if watcher:watcher.join(timeout=3)
  if (d/'native-host.log').is_file():
   observed=(d/'native-host.log').read_text(errors='replace')
   for key,marker in [('layout_bytes','SOURCE_PASS_END:1'),('allocated_target_pages','SOURCE_PRIVATE_PAGES'),('symbol_content_bytes','SOURCE_SYMBOL_BYTES'),('metadata_string_content_bytes','SOURCE_METADATA_STRING_BYTES')]:
    found=re.search(re.escape(marker)+r':\s*(\d+)',observed)
    if found:report[key]=int(found[1])
  report['controller_seconds']=round(time.monotonic()-start,3);(d/'results.json').write_text(json.dumps(report,indent=2)+'\n');(d/'manifest.json').write_text(json.dumps({q.name:digest(q) for q in d.iterdir() if q.is_file() and q.name!='manifest.json'},indent=2)+'\n');signal.signal(signal.SIGTERM,old_term)
 print(json.dumps(report,indent=2))
if __name__=='__main__':main()
