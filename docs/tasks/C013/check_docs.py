"""Check local bench documentation and record changes without copying old recipes."""
from pathlib import Path
import ast,hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[3]
TASK=Path(__file__).resolve().parent
BASE='3b54b7db03d1b6e9b20c74856ea018dc97370caa'
GUIDE=Path('/Agon/mystuff/agon-extender/docs/operations/olimex-bench/README.md')
sha=lambda b:hashlib.sha256(b).hexdigest()

def main():
    files=subprocess.check_output(['git','ls-files'],text=True,cwd=ROOT).splitlines()
    changes=[]
    changed=set(subprocess.check_output(['git','diff','--name-only',BASE],text=True,cwd=ROOT).splitlines())
    for n in files:
        if n not in changed:continue
        old=subprocess.run(['git','show',BASE+':'+n],cwd=ROOT,capture_output=True)
        if old.returncode:continue
        p=ROOT/n;new=p.read_bytes() if p.exists() else None
        if new==old.stdout:continue
        if n.startswith('docs/tasks/C013') or n=='TODO.md':continue
        rec=dict(path=n,action='delete' if new is None else 'edit',before_sha256=sha(old.stdout),after_sha256=sha(new) if new is not None else None)
        if p.suffix=='.py':
            def code(data):
                t=ast.parse(data)
                if t.body and isinstance(t.body[0],ast.Expr) and isinstance(t.body[0].value,ast.Constant) and isinstance(t.body[0].value.value,str):t.body.pop(0)
                return ast.dump(t,include_attributes=False)
            assert code(old.stdout)==code(new),'Execution code changed: '+n
            rec['execution_ast_unchanged']=True
            rec['reason']='Replace obsolete module-level procedural documentation; execution code unchanged'
        if 'reason' not in rec:
            rec['reason']='Remove competing copied bench policy' if new is None else ('Remove embedded obsolete bench routing instruction' if n.endswith('verification.json') else 'Remove local bench instructions; retain historical/application facts and sole canonical reference')
        changes.append(rec)
    # Current/local human-readable instructions, including JSON policy records.
    banned=[r'cross-agent/olimex-bench',r'canonical.*reservation/grant',r'retained-custody policy',r'reserve this plan',r'assert (?:the |its |current )?(?:lease|token)',r'fresh explicit Extender grant',r'before any future finite plan/grant']
    hits=[];count=0;links=0
    for n in files:
        p=ROOT/n
        if not p.exists() or p.suffix.lower() not in ('.md','.txt','.json'):continue
        if n.startswith('docs/tasks/C013/'):continue
        s=p.read_text(errors='replace');count+=1
        for pattern in banned:
            if re.search(pattern,s,re.I):hits.append(dict(path=n,pattern=pattern))
        for target in re.findall(r'\]\(([^)]+operations/olimex-bench/README\.md)\)',s):
            assert (p.parent/target).resolve()==GUIDE,(n,target)
            links+=1
    assert not hits,hits
    assert links>=8 and GUIDE.is_file()
    (TASK/'changes.json').write_text(json.dumps(changes,indent=2)+'\n')
    # Original manifests remain original commitments, with explicit exceptions.
    integrity=[]
    bypath={c['path']:c for c in changes}
    for n in files:
        p=ROOT/n
        if p.name not in ('manifest.json','evidence-manifest.json') or not p.exists():continue
        try:m=json.loads(p.read_text())
        except ValueError:continue
        if not isinstance(m,dict):continue
        for rel,h in m.items():
            if not isinstance(h,str) or not re.fullmatch('[a-f0-9]{64}',h):continue
            candidate=str((p.parent/rel).relative_to(ROOT))
            if candidate in bypath:
                integrity.append(dict(manifest=n,entry=rel,original_sha256=h,actual_sha256=bypath[candidate]['after_sha256'],disposition='Historical manifest intentionally not rewritten; documentation removed/edited under C013'))
    (TASK/'integrity-exceptions.json').write_text(json.dumps(integrity,indent=2)+'\n')
    result=dict(document_files_scanned=count,canonical_guide_sha256_observed=sha(GUIDE.read_bytes()),canonical_links_verified=links,forbidden_procedural_hits=hits,
        files_changed=len(changes),module_docstrings_changed=sum('execution_ast_unchanged' in c for c in changes),
        manifest_exceptions=len(integrity),hardware_access=False,emulator_run=False,
        raw_binary_changes=[c['path'] for c in changes if Path(c['path']).suffix in ('.bin','.dat')])
    assert not result['raw_binary_changes']
    (TASK/'checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))

if __name__=='__main__':main()
