"""Compare complete graphics/key images across the private-prefix substitution."""
from pathlib import Path
import hashlib
import json
import shutil

TASK = Path(__file__).resolve().parent
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
def retained(name):
    directory = TASK/'evidence'/name
    for filename,expected in json.loads((directory/'manifest.json').read_text()).items():
        assert digest(directory/filename) == expected,(name,filename)
    report = json.loads((directory/'results.json').read_text())
    assert report['completed']
    return directory,report

result = dict(scope='Exact fixtures and complete emitted images, not new CPU executions',
    prior_source_sha256='b8afbfdb51de803e7c8e670d4c00e434371e3f2d0af4ce354ce29f3580cdd875',
    source_sha256='70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e',
    groups=[],completed=False,
    initial_fixture_note='Initial13c2 basic fixtures used60/70 terminators; later fixtures use900/910. Identity uses the exact corresponding b8afbfdb fixtures.')
for stage in ['', 'native-']:
    for suite in ['basic','bounded','errors','interactions']:
        old,previous = retained('fit-'+stage+'wire-'+suite+'-001')
        new,current = retained('meta-'+stage+'wire-'+suite+'-001')
        assert previous['compiler_source_sha256'] == result['prior_source_sha256']
        assert current['compiler_source_sha256'] == result['source_sha256']
        assert [c['name'] for c in previous['cases']] == [c['name'] for c in current['cases']]
        cases = []
        for case in current['cases']:
            name = case['name']
            for suffix in ['.bas','.dat']:
                assert (old/(name+suffix)).read_bytes() == (new/(name+suffix)).read_bytes(),(new.name,name,suffix)
            cases.append(dict(name=name,source_sha256=digest(new/(name+'.bas')),
                image_sha256=digest(new/(name+'.dat')),bytes=(new/(name+'.dat')).stat().st_size))
        result['groups'].append(dict(prior=old.name,current=new.name,cases=cases,
            all_exact_sources_and_images_equal=True))
assert sum(len(g['cases']) for g in result['groups']) == 36
result.update(completed=True,image_comparisons=36)
evidence = TASK/'evidence/metadata-image-identity-001'
evidence.mkdir(parents=True,exist_ok=False)
shutil.copyfile(__file__,evidence/'compare_metadata_images.py')
(evidence/'results.json').write_text(json.dumps(result,indent=2)+'\n')
(evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
    for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
print(json.dumps(dict(completed=True,image_comparisons=36)),flush=True)
