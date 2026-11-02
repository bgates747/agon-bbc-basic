"""Resume unchanged live source after correcting stale VAL/STR$ fixtures."""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import sys
sys.dont_write_bytecode=True
p=Path(__file__).with_name('qualification-driver.py')
s=importlib.util.spec_from_file_location('live',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
ROOT,TASK,EVIDENCE=m.ROOT,m.TASK,m.EVIDENCE
m.run('strings','docs/tasks/C003/tools/test_strings.py',[],TASK/'build/output-integration')
m.run('slice-smoke','docs/tasks/C003/tools/test_slices.py',['--smoke'],TASK/'build/output-integration')
m.run('string-limits','docs/tasks/C003/tools/test_string_limits.py',[],TASK/'build/output-integration')
m.run('core-abi','docs/tasks/C003/tools/test_string_abi.py',[],TASK/'build/string-abi')
m.run('slice-abi','docs/tasks/C003/tools/test_slice_abi.py',[],TASK/'build/slice-abi')
m.run('conversion-smoke','docs/tasks/C003/tools/test_conversions.py',['--smoke'],TASK/'build/output-integration')
m.run('expressions','docs/tasks/C002/tools/test_expressions.py',[],ROOT/'docs/tasks/C002/build/expressions/promotion/batch-000')
for p in [ROOT/'compiler/compiler.bas',ROOT/'compiler/runtime/strings.s',ROOT/'compiler/tools/build_strings_runtime.py',
          ROOT/'compiler/examples/search-repeat.bas',TASK/'tools/test_search_repeat.py',TASK/'tools/test_search_repeat_abi.py',
          TASK/'tools/test_string_storage.py',TASK/'tools/test_strings.py',TASK/'tools/test_slices.py',TASK/'tools/test_conversions.py',
          ROOT/'docs/tasks/C002/tools/test_expressions.py']:
    shutil.copy2(p,EVIDENCE/p.name)
for name in ['numeric-runtime','string-runtime']:
    m.archive(ROOT/f'compiler/build/{name}',EVIDENCE/name)
    shutil.copy2(ROOT/f'compiler/build/{name}/runtime-0.bin',EVIDENCE/name/'runtime-0.dat')
for label,directory in [('abi','search-repeat-abi'),('core-abi','string-abi'),('slice-abi','slice-abi')]:
    shutil.copy2(TASK/f'build/{directory}/probe.bin',EVIDENCE/label/'probe.dat')
(EVIDENCE/'manifest.json').write_text(json.dumps({str(p.relative_to(EVIDENCE)):hashlib.sha256(p.read_bytes()).hexdigest()
    for p in EVIDENCE.rglob('*') if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')
