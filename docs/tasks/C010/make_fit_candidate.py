"""Factor private BBC compiler bookkeeping; preserve emitted program sequences.

The initial feature candidate leaves96674 heap bytes, below the earlier
97366-byte observed mandatory self-source lower bound, before new metadata.
Only repeated zero assignments and pure equal-index SFIX calls are factored.
"""
from pathlib import Path
import hashlib
import json
import re

TASK = Path(__file__).resolve().parent
source = (TASK/'candidate.bas').read_text()
assert hashlib.sha256(source.encode()).hexdigest() == '13c2a48802718040b1056921b1aedea3e5da9f6f36e946d990ccf36be92396b9'
for name in ['PROCresetnum','PROCresetstr','PROCnumberkind','PROCresetexpr','PROCfixslot']:
    assert name not in source
changes = []
def reset(match):
    prefix,name = match.groups()
    changes.append(dict(kind='zero_assignment',text=match.group(0)))
    return prefix+{'ndepth%':'PROCresetnum','sdepth%':'PROCresetstr','valuekind%':'PROCnumberkind'}[name]
# Assignment positions only. IF comparisons and larger expressions are retained.
pattern = r'(^\d+ |:[ \t]*|THEN |ELSE )(ndepth%|sdepth%|valuekind%)=0(?=:|\n| ELSE |$)'
source = re.sub(pattern,reset,source,flags=re.MULTILINE)
pairs = source.count('PROCresetnum:PROCresetstr')
source = source.replace('PROCresetnum:PROCresetstr','PROCresetexpr')
def fix(match):
    a,b = match.groups()
    assert a == b,(a,b)
    assert re.fullmatch(r'(?:[a-z]+%|[01])(?:-1)?',a),a
    changes.append(dict(kind='equal_index_sfix',text=match.group(0)))
    return 'PROCfixslot('+a+')'
source = re.sub(r'PROCnumoperation\(([^,()]+),([^,()]+),38\)',fix,source)
definitions = '''19694 DEF PROCresetnum:ndepth%=FALSE:ENDPROC
19696 DEF PROCresetstr:sdepth%=FALSE:ENDPROC
19698 DEF PROCnumberkind:valuekind%=FALSE:ENDPROC
19700 DEF PROCresetexpr:PROCresetnum:PROCresetstr:ENDPROC
19702 DEF PROCfixslot(i%):PROCnumoperation(i%,i%,38):ENDPROC
'''
source = source.replace('20000 DATA ',definitions+'20000 DATA ',1)
output = TASK/'candidate-fit.bas'
output.write_text(source)
report = dict(source_sha256=hashlib.sha256(source.encode()).hexdigest(),
    original_source_sha256='13c2a48802718040b1056921b1aedea3e5da9f6f36e946d990ccf36be92396b9',
    combined_pairs=pairs,changes=changes,
    scope='Private compiler implementation factoring; no runtime/numeric representation or language change')
(TASK/'fit-transform.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='changes'}))
