"""Qualify the exact private BBC helpers as ordinary compiled BASIC routines."""
from pathlib import Path
import hashlib
import importlib.util
import sys

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT / 'docs/tasks/C005'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def programs():
    source = (TASK / 'compact/packed.bas').read_text()
    assert hashlib.sha256(source.encode()).hexdigest() == '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8'
    helpers = []
    for row in source.splitlines():
        number, body = row.split(' ', 1)
        if 19580 <= int(number) <= 19622 or 19226 <= int(number) <= 19232:
            helpers.append(body)
    body = '''DIM addrbuf% 12289,sortbuf% 8193,lrefs%(63),saved%(63)
saddr%=addrbuf%+1:sort%=sortbuf%+1
addrbuf%?0=&A5:addrbuf%?12289=&A5:sortbuf%?0=&A5:sortbuf%?8193=&A5
FOR i%=0 TO 4095
v%=i%*173:IF i%=4095 v%=&B0000
PROCsymboladdr(i%,v%):PROCsortindex(i%,4095-i%)
NEXT
FOR i%=0 TO 4095
v%=i%*173:IF i%=4095 v%=&B0000
IF FNsymboladdr(i%)<>v% ERROR 100,"address cell"
IF FNsortindex(i%)<>4095-i% ERROR 100,"sorted cell"
NEXT
IF addrbuf%?0<>&A5 OR addrbuf%?12289<>&A5 ERROR 100,"address guard"
IF sortbuf%?0<>&A5 OR sortbuf%?8193<>&A5 ERROR 100,"sorted guard"
FOR i%=0 TO 63
IF lrefs%(i%)<>0 ERROR 100,"page initialization"
n%=(i% MOD 32)*2048+2047:IF i% MOD 32=31 n%=65279
IF FNlineref(n%,i% DIV 32,FALSE) ERROR 100,"absent page"
IF NOT FNlineref(n%,i% DIV 32,TRUE) ERROR 100,"page write"
IF NOT FNlineref(n%,i% DIV 32,FALSE) ERROR 100,"page read"
saved%(i%)=lrefs%(i%)
IF i%<32 THEN IF FNlineref(n%,1,FALSE) ERROR 100,"branch data separation"
NEXT
IF FNlineref(2048,0,FALSE) OR FNlineref(2048,1,FALSE) ERROR 100,"unwritten boundary bit"
IF NOT FNlineref(2048,0,TRUE) ERROR 100,"first bit of next page"
IF FNlineref(2048,1,FALSE) ERROR 100,"boundary data separation"
PROCclearrefs
FOR i%=0 TO 63
IF saved%(i%)<>lrefs%(i%) ERROR 100,"page reuse"
n%=(i% MOD 32)*2048+2047:IF i% MOD 32=31 n%=65279
IF FNlineref(n%,i% DIV 32,FALSE) ERROR 100,"page clearing"
IF NOT FNlineref(n%,i% DIV 32,TRUE) ERROR 100,"page rewrite"
IF saved%(i%)<>lrefs%(i%) ERROR 100,"page leaked"
NEXT
PROCclearrefs
IF FNlineref(2047,0,FALSE) OR FNlineref(2048,0,FALSE) OR FNlineref(65279,1,FALSE) ERROR 100,"second clear"
PRINT "4096 packed cells and 64 reusable pages":END
'''
    return [dict(source=body+'\n'.join(helpers)+'\n', reference=True,
                 reference_source=body.replace(':END\n', '\n'),
                 reference_definitions=helpers, status=0)]


def main():
    harness = module('maps', TASK / 'compact/maps_harness.py').load()
    harness.programs = programs
    sys.argv += ['--skip-legacy', '--isolate-reference', '--string-runtime',
                 str(ROOT / 'compiler/build/string-runtime')]
    harness.main()
    module('links', TASK / 'compact/check_images.py').check(TASK / 'build/output-integration')


if __name__ == '__main__':
    main()
