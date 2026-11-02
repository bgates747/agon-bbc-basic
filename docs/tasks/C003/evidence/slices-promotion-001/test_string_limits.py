"""Exercise string expression limits and the promoted string example."""
import importlib.util
from pathlib import Path
import sys

TASK=Path(__file__).resolve().parents[1]
ROOT=TASK.parents[2]


def programs():
    return [
        dict(source=(ROOT/'compiler/examples/strings.bas').read_text(),status=0,
             expected='Hello, Agon!\nHello stayed unchanged.\nLength: 11\nEmbedded-zero length: 2\nHello, Agon!\n'),
        dict(source='PRINT '+('"x"+('*16)+'"x"'+(')'*16)+'\n',
             diagnostic='String temporary limit exceeds 16'),
        dict(source='PRINT '+('('*33)+'"x"'+(')'*33)+'\n',
             diagnostic='Expression nesting exceeds 32'),
    ]


if __name__=='__main__':
    spec=importlib.util.spec_from_file_location('output_harness',ROOT/'docs/tasks/C002/tools/test_output.py')
    output=importlib.util.module_from_spec(spec);spec.loader.exec_module(output)
    output.TASK=TASK;output.programs=programs
    sys.argv+=['--isolate-reference','--skip-legacy','--string-runtime',str(ROOT/'compiler/build/string-runtime')]
    output.main()
