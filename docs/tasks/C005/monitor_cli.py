"""Read only this profile's native CLI CPU time and selected emulated file offsets."""
from pathlib import Path
import argparse,json,os
ROOT=Path(__file__).resolve().parents[3]
def main():
 p=argparse.ArgumentParser();p.add_argument('--names',nargs='*',default=['p9.bas','p9.bin','self-source.bas','bootstrap-source.bas']);a=p.parse_args();profile=(ROOT/'.emulator').resolve();rows=[];ticks=os.sysconf('SC_CLK_TCK');uptime=float(Path('/proc/uptime').read_text().split()[0])
 for q in Path('/proc').iterdir():
  if not q.name.isdigit():continue
  try:
   if (q/'cwd').resolve()!=profile or (q/'exe').resolve().name!='agon-cli-emulator':continue
   fields=(q/'stat').read_text().rsplit(')',1)[1].split();files=[]
   for fd in (q/'fd').iterdir():
    try:
     path=fd.resolve()
     if path.name not in a.names or not path.is_relative_to(ROOT.resolve()):continue
     info=dict(line.split(':',1) for line in (q/'fdinfo'/fd.name).read_text().splitlines() if ':' in line);files.append(dict(name=path.name,position=int(info['pos']),bytes=path.stat().st_size))
    except (PermissionError,FileNotFoundError,ProcessLookupError):pass
   rows.append(dict(pid=int(q.name),state=fields[0],cpu_seconds=round((int(fields[11])+int(fields[12]))/ticks,2),elapsed_seconds=round(uptime-int(fields[19])/ticks,2),files=files))
  except (PermissionError,FileNotFoundError,ProcessLookupError):pass
 print(json.dumps(dict(profile=str(profile),cli_processes=rows),indent=2))
if __name__=='__main__':main()
