"""Final source, provenance, manifest and repository checks; no emulation."""
from pathlib import Path
import ast
import hashlib
import json
import re
import subprocess

ROOT=Path('/Agon/mystuff/bbc-basic-v-adl')
TASK=ROOT/'docs/tasks/C003'
EVIDENCE=TASK/'evidence/slice-store-promotion-001'

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT,text=True).strip()

source=(ROOT/'compiler/compiler.bas').read_text();lines=source.splitlines()
assert (ROOT/'compiler/build/string-runtime/runtime-0.bin').read_bytes()[:533]==(TASK/'evidence/search-repeat-promotion-001/string-runtime/runtime-0.dat').read_bytes()
previous=git('show','HEAD:compiler/compiler.bas')
assert source.split('20000 DATA',1)[1].split('30000 DATA',1)[0]==previous.split('20000 DATA',1)[1].split('30000 DATA',1)[0]
ids=[int(line.split()[0]) for line in lines]
assert ids==sorted(set(ids)) and max(len(line.split(' ',1)[1]) for line in lines)<=255
assert sha(ROOT/'compiler/compiler.bas')=='928a46a060fa8b72dbbbc40484561c67b6736ba5cf69eaa7ced932e5409a8617'
assert (ROOT/'compiler/compiler.bas').read_bytes()==(TASK/'evidence/slice-store-001/compiler.bas').read_bytes()==(EVIDENCE/'compiler.bas').read_bytes()
assert (ROOT/'compiler/runtime/strings.s').read_bytes()==(TASK/'evidence/slice-store-001/strings.s').read_bytes()==(EVIDENCE/'strings.s').read_bytes()
assert '20000 DATA'+source.split('20000 DATA',1)[1].split('30000 DATA',1)[0]==(ROOT/'compiler/build/numeric-runtime/runtime_data.bas').read_text()
assert '30000 DATA'+source.split('30000 DATA',1)[1]==(ROOT/'compiler/build/string-runtime/runtime_data.bas').read_text()
for name in ['compiler.bas','strings.s']:assert not (TASK/'slice-store'/name).exists()
assert (ROOT/'compiler/examples/slice-store.bas').read_text()==json.loads((TASK/'evidence/slice-store-001/transcripts/cases.json').read_text())[0]['source']
expected={
 'compiler/runtime/numeric.s':'406b7c0cc54bead665e009ba189f28139c5b6f15ac0c71699866b8f9233d5c3a',
 'compiler/runtime/vendor/MATH.Z80':'1f92ffc352b22051ff77f0a48d206d04012fb5e404c0a70e47d76342ce7aece3',
 'compiler/runtime/vendor/LICENSE.txt':'cc8e92d92cf12fb1d04ddae0b573367f14188df5fcd6c7909d36486ff53a108a',
 'compiler/runtime/expression_runtime.s':'0c0d5d0e2af066a0d29e837be99593c061f2748d79b984ea6dd3b12f6ef9f440',
 'bin/basic.bin':'a1ae6d381d9861abbc5d87550c683827499d5a8cbe1de49fd9dfa3687382653d'}
for name,digest in expected.items():assert sha(ROOT/name)==digest,name
pyfiles=[ROOT/'compiler/tools/build_strings_runtime.py',TASK/'tools/test_slice_store.py',TASK/'tools/test_slice_store_abi.py',TASK/'tools/test_string_storage.py',ROOT/'docs/tasks/C002/tools/test_output.py',ROOT/'docs/tasks/C002/tools/test_expressions.py',TASK/'tools/test_slices.py']
for p in pyfiles:ast.parse(p.read_text())
docs=set(git('diff','--name-only','--','*.md').splitlines())|{'docs/tasks/C003/SLICE-STORE.md','docs/tasks/C003/SLICES.md'}
for name in docs:
 p=ROOT/name
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if ':' in target or target.startswith('#'):continue
  target=target.split('#',1)[0]
  assert not target or (p.parent/target).exists(),(name,target)
manifest_count=member_count=0
for path in (TASK/'evidence').glob('*/manifest.json'):
 if path.parent==EVIDENCE:continue
 members=json.loads(path.read_text())
 for name,digest in members.items():assert sha(path.parent/name)==digest,(path,name)
 manifest_count+=1;member_count+=len(members)
newfiles=[p for folder in (TASK/'evidence').glob('slice-store-*') for p in folder.rglob('*') if p.is_file()]
ignored=subprocess.run(['git','check-ignore','--stdin'],cwd=ROOT,input='\n'.join(str(p.relative_to(ROOT)) for p in newfiles)+'\n',text=True,capture_output=True)
assert ignored.returncode==1,ignored.stdout+ignored.stderr
for p in newfiles:
 if p.suffix=='.json':json.loads(p.read_text())
assert not any(n.startswith(('include/','src/','bin/')) or n in ('Makefile','license.txt') for n in git('diff','--name-only').splitlines())
assert git('rev-parse','--abbrev-ref','HEAD')=='codex/native-bbc-compiler'
assert git('rev-parse','HEAD')==git('rev-parse','@{upstream}')=='0094ab09ed369fbf0d7140bc248da169fe9da63a'
assert git('rev-parse','main')=='2998edd4ceb6030d6840cb4e3d587e75d94dc44c'
subprocess.run(['git','diff','--check'],cwd=ROOT,check=True)
report=dict(ordered_loader_safe_lines=len(lines),maximum_line_body_bytes=max(len(line.split(' ',1)[1]) for line in lines),
            byte_identical_promotion=True,both_data_sections_match=True,no_maintained_compiler_fork=True,
            unchanged_source_hashes=expected,python_syntax=True,document_links=True,
            previous_manifests_checked=manifest_count,previous_manifest_members_checked=member_count,
            new_evidence_files_stageable=len(newfiles),json_parsing=True,whitespace=True,
            interpreter_sources_unchanged=True,head_and_upstream=git('rev-parse','HEAD'),main_unchanged=git('rev-parse','main'))
(EVIDENCE/'static-results.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
