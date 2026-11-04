"""Combine pinned allocation inventory and actual BBC metadata observations.

This is a storage lower bound. Headers, peak temporaries and allocator effects
are still omitted; only actual native self-compilation can establish fit.
"""
from pathlib import Path
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
OLD = ROOT/'docs/tasks/C005/evidence/packed-source-002'
NEW = TASK/'evidence/meta-symbol-layout-001'
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
for directory in [OLD,NEW]:
    for filename,expected in json.loads((directory/'manifest.json').read_text()).items():
        assert digest(directory/filename) == expected,(directory,filename)
source = TASK/'candidate-meta.bas'
assert digest(source) == '70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e'
assert digest(OLD/'compiler.bas') == '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8'
declarations = lambda p: [s for s in p.read_text().splitlines() if re.search(r'(?:^\d+ |:)DIM ',s)]
assert declarations(OLD/'compiler.bas') == declarations(source)
baseline = json.loads((OLD/'storage-lower-bound.json').read_text())
prior = json.loads((OLD/'results.json').read_text())
current = json.loads((NEW/'results.json').read_text())
assert current['completed'] and current['old_output_preserved']
# All nine modules/relocation catalogs are exactly unchanged, independently
# rebuilt by the completed ten-packer cohort.
repack = TASK/'evidence/meta-repack-001'
for filename,expected in json.loads((repack/'manifest.json').read_text()).items():
    assert digest(repack/filename) == expected
assert json.loads((repack/'results.json').read_text())['all_identical']
fixed = baseline['minimum_private_allocation_bytes']+256*(current['pages']-prior['allocated_target_pages'])
mandatory = fixed+current['symbol_bytes']+current['other_strings']
available = baseline['executable_and_heap_limit']-baseline['user_origin']-current['image_bytes']
result = dict(source_sha256=digest(source),image_layout_bytes=current['image_bytes'],
    explicit_allocation_lower_bound=fixed,observed_symbol_contents=current['symbol_bytes'],
    observed_other_metadata_contents=current['other_strings'],mandatory_observed_lower_bound=mandatory,
    available_heap_from_layout=available,residual_before_omitted_costs=available-mandatory,
    prefix_symbol_content_savings=current['prefix_bytes_saved'],
    prior_residual_before_omitted_costs=baseline['available_heap_bytes']-(baseline['minimum_private_allocation_bytes']+
        prior['symbol_content_bytes']+prior['metadata_string_content_bytes']),
    omitted=['array headers','allocator effects','other allocations and peak temporaries'],
    native_fit_proven=False,scope='Pinned storage analysis; not a native execution or self-build result')
evidence = TASK/'evidence/metadata-bounds-001'
evidence.mkdir(parents=True,exist_ok=False)
for path,name in [(OLD/'results.json','prior-observation.json'),
                  (OLD/'storage-lower-bound.json','prior-fixed-inventory.json'),
                  (NEW/'results.json','new-observation.json'),(Path(__file__),'metadata_bounds.py')]:
    shutil.copyfile(path,evidence/name)
(evidence/'unchanged-dim-declarations.json').write_text(json.dumps(declarations(source),indent=2)+'\n')
(evidence/'results.json').write_text(json.dumps(result,indent=2)+'\n')
(evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
    for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
print(json.dumps(result),flush=True)
