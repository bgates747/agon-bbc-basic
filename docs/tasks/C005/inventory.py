"""Static development inventory only: no BASIC compilation or numeric model."""
from pathlib import Path
import argparse,hashlib,json,re
ROOT=Path(__file__).resolve().parents[3]
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--source',type=Path,default=ROOT/'compiler/compiler.bas');parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();source=args.source.resolve(strict=True);assert not args.output.exists(),'Preserve historical inventories';text=source.read_text()
rows=[]
for line in text.splitlines():
 number,body=line.split(' ',1)
 if int(number)>=20000:continue
 # Remove quoted text only to keep source-language searches free of keyword tables.
 body=re.sub(r'"(?:""|[^"])*"','""',body)
 body=re.split(r'\bREM\b',body,maxsplit=1)[0]
 rows.append((int(number),body))
patterns={
 'definitions':r'\bDEF\s+(?:PROC|FN)',
 'arrays_and_blocks':r'\bDIM\b',
 'file_io':r'\b(?:OPENIN|OPENOUT|BGET|BPUT|EOF|CLOSE)\b',
 'interactive_input':r'\bINPUT\s+LINE\b',
 'data_runtime':r'\b(?:READ|RESTORE)\b',
 'error_facilities':r'\b(?:ERROR|REPORT|ERR|ERL)\b',
 'indirection':r'[?^!]',
}
report=dict(source=str(source.relative_to(ROOT)),source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),ordered_source_lines=len(text.splitlines()),procedure_definitions=sum(bool(re.search(r'\bDEF\s+PROC',s)) for _,s in rows),function_definitions=sum(bool(re.search(r'\bDEF\s+FN',s)) for _,s in rows),scope='Static search inventory; counts are not a compiler parser or feature qualification',matches={name:[dict(line=n,source=s) for n,s in rows if re.search(pattern,s)] for name,pattern in patterns.items()})
args.output.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='matches'},indent=2));print({k:len(v) for k,v in report['matches'].items()})
