"""Resume the final batches after the recorded old 180s guard expired."""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import sys
sys.dont_write_bytecode=True

p=Path(__file__).with_name('qualification-driver.py')
spec=importlib.util.spec_from_file_location('live',p)
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
ROOT,TASK,EVIDENCE=m.ROOT,m.TASK,m.EVIDENCE
m.run('numeric-output','docs/tasks/C002/tools/test_output.py',['--timeout','360'],ROOT/'docs/tasks/C002/build/output-integration')
m.run('expressions','docs/tasks/C002/tools/test_expressions.py',[],ROOT/'docs/tasks/C002/build/expressions/promotion/batch-000')
for p in [ROOT/'compiler/compiler.bas',ROOT/'compiler/runtime/expression_runtime.s',
          ROOT/'compiler/tools/build_numeric_runtime.py',ROOT/'compiler/examples/conversions.bas',
          TASK/'tools/test_conversions.py',TASK/'tools/test_conversion_abi.py',TASK/'tools/test_string_storage.py',
          ROOT/'docs/tasks/C002/tools/test_output.py',ROOT/'docs/tasks/C002/tools/test_expressions.py']:
    shutil.copy2(p,EVIDENCE/p.name)
for name in ['numeric-runtime','string-runtime']:
    m.archive(ROOT/f'compiler/build/{name}',EVIDENCE/name)
    shutil.copy2(ROOT/f'compiler/build/{name}/runtime-0.bin',EVIDENCE/name/'runtime-0.dat')
shutil.copy2(TASK/'build/conversion-abi/probe.bin',EVIDENCE/'abi/probe.dat')
members={str(p.relative_to(EVIDENCE)):hashlib.sha256(p.read_bytes()).hexdigest()
         for p in EVIDENCE.rglob('*') if p.is_file() and p.name!='manifest.json'}
(EVIDENCE/'manifest.json').write_text(json.dumps(members,indent=2)+'\n')
