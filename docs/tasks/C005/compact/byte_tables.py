"""Prepare bounded BBC byte-array fields; no user BASIC compilation occurs here."""
from pathlib import Path
import hashlib,json,re
T=Path(__file__).resolve().parent;BASE=T.parent/'streaming/names.bas';s=BASE.read_text()
assert hashlib.sha256(s.encode()).hexdigest()=='508a74f28f56aca3faf716aef021162ba24d73d9a5d01552deb9c4d12f3def4e'
schema={'par':(4096,255),'argkind':(512,1),'argindex':(512,31),'parcnt':(256,16),'pkind':(256,1),'vsize':(256,5),'vdim':(256,16),'retdef':(512,255)}
mapping={n+'%':n+'&' for n in schema};token=re.compile(r'"(?:[^"\n]|"")*"|&[0-9A-Fa-f]+|[A-Za-z_][A-Za-z0-9_]*[$%&]?|.',re.DOTALL);rows=[];counts={n:0 for n in mapping}
for row in s.splitlines():
 number,body=row.split(' ',1)
 if body.startswith(('REM','DATA')):rows.append(row);continue
 out=[]
 for m in token.finditer(body):
  word=m.group()
  if word=='REM':out.append(body[m.start():]);break
  if word in mapping:
   assert body[m.end():].lstrip().startswith('('),word
   counts[word]+=1;word=mapping[word]
  out.append(word)
 rows.append(number+' '+''.join(out))
assert all(counts.values())
out=T/'compiler.bas';assert not out.exists(),'Preserve an existing candidate';out.write_text('\n'.join(rows)+'\n')
report=dict(source_sha256=hashlib.sha256(BASE.read_bytes()).hexdigest(),candidate_sha256=hashlib.sha256(out.read_bytes()).hexdigest(),native_element_bytes_saved=sum(n*3 for n,_ in schema.values()),fields={n:dict(elements=count,maximum_value=maximum,old_element_bytes=4,new_element_bytes=1,replacements=counts[n+'%']) for n,(count,maximum) in schema.items()},scope='Private metadata representation; public BASIC values and code generation unchanged')
(T/'table-widths.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
