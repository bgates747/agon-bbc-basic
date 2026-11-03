"""Prepare an ordinary BBC source revision with private names across hash chains.
This renames implementation identifiers; it never compiles user BASIC.
"""
from pathlib import Path
import hashlib,json,re
T=Path(__file__).resolve().parent
source=(T/'compiler.bas').read_text()
assert hashlib.sha256(source.encode()).hexdigest()=='d5144921dda86fade54cc4e7bf82c257bcde744884ebcac9cf12b10cca341f5e'
token=re.compile(r'"(?:[^"\n]|"")*"|&[0-9A-Fa-f]+|[A-Za-z_][A-Za-z0-9_]*[$%&]?|.',re.DOTALL)
mapping={};rows=[]
for row in source.splitlines():
 number,body=row.split(' ',1)
 if body.startswith(('REM','DATA')):rows.append(row);continue
 output=[]
 for m in token.finditer(body):
  word=m.group()
  if word=='REM':output.append(body[m.start():]);break
  if re.fullmatch(r'c[a-z][A-Za-z0-9_]*[$%&]?',word):mapping[word]=word[1:];word=word[1:]
  output.append(word)
 rows.append(number+' '+''.join(output))
assert len(set(mapping.values()))==len(mapping)
out=T/'names.bas';assert not out.exists(),'Preserve an existing candidate';out.write_text('\n'.join(rows)+'\n')
(T/'private-name-map.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256(source.encode()).hexdigest(),candidate_sha256=hashlib.sha256(out.read_bytes()).hexdigest(),mapping=dict(sorted(mapping.items()))),indent=2)+'\n')
print('Prepared',len(rows),'lines,',len(mapping),'renamed identifiers,',hashlib.sha256(out.read_bytes()).hexdigest())
