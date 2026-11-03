"""Prepare BBC private symbol cells and reusable sparse target pages.

Guarded text preparation only: the compiler and all table operations are BASIC.
"""
from pathlib import Path
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
BASE = HERE / 'zero_tail.bas'
OUT = HERE / 'packed.bas'


def main():
    assert hashlib.sha256(BASE.read_bytes()).hexdigest() == '14e56cee04b1fc53068b5f3ad76314014925e5894798890d4acd3421b78cc4ef'
    assert not OUT.exists(), 'Preserve previous candidates'
    source = BASE.read_text()

    def change(old, new):
        nonlocal source
        assert source.count(old) == 1, old
        source = source.replace(old, new)

    change('1010 DIM sname$(4095),saddr%(4095),sort%(4095),lrefs% 16383',
           '1010 DIM sname$(4095),saddr% 12287,sort% 8191,lrefs%(63)')
    change('1061 FOR i%=0 TO 16383:lrefs%?i%=0:NEXT', '1061 PROCclearrefs')
    change('2522 mid%=(lo%+hi%) DIV 2:i%=sort%(mid%)',
           '2522 mid%=(lo%+hi%) DIV 2:i%=FNsortindex(mid%)')
    change('2640 IF phase%>1 v%=saddr%(i%)',
           '2640 IF phase%>1 v%=FNsymboladdr(i%)')
    change('p%=saddr%(FNsymbol("$sheapend"))',
           'p%=FNsymboladdr(FNsymbol("$sheapend"))')
    change('IF saddr%(i%)<>a%', 'IF FNsymboladdr(i%)<>a%')
    change('19214 IF snum%>sinsert% THEN FOR j%=snum%-1 TO sinsert% STEP -1:sort%(j%+1)=sort%(j%):NEXT',
           '19214 IF snum%>sinsert% THEN FOR j%=2*snum%-1 TO 2*sinsert% STEP -1:sort%?(j%+2)=sort%?j%:NEXT')
    change('19216 sort%(sinsert%)=snum%:sname$(snum%)=n$:saddr%(snum%)=a%:snum%=snum%+1',
           '19216 PROCsortindex(sinsert%,snum%):sname$(snum%)=n$:PROCsymboladdr(snum%,a%):snum%=snum%+1')
    change('19228 LOCAL i%,b%:i%=n% DIV 8+8192*m%:b%=2^(n% AND 7)',
           '19228 LOCAL i%,b%,p%:p%=FNrefpage(n% DIV 2048+32*m%,w%):IF p%=0 THEN =FALSE\n19229 i%=(n% DIV 8) AND 255:b%=2^(n% AND 7)')
    change('19230 IF w% lrefs%?i%=lrefs%?i% OR b%',
           '19230 IF w% p%?i%=p%?i% OR b%')
    change('19232 =(lrefs%?i% AND b%)<>0', '19232 =(p%?i% AND b%)<>0')
    helpers = '''19580 DEF FNsortindex(i%)
19582 LOCAL p%:p%=2*i%
19584 =sort%?p%+256*sort%?(p%+1)
19586 DEF PROCsortindex(i%,v%)
19588 LOCAL p%:p%=2*i%:sort%?p%=v%:sort%?(p%+1)=v% DIV 256:ENDPROC
19590 DEF FNsymboladdr(i%)
19592 LOCAL p%:p%=3*i%
19594 =saddr%?p%+256*saddr%?(p%+1)+65536*saddr%?(p%+2)
19596 DEF PROCsymboladdr(i%,v%)
19598 LOCAL p%:p%=3*i%:saddr%?p%=v%:saddr%?(p%+1)=v% DIV 256:saddr%?(p%+2)=v% DIV 65536:ENDPROC
19600 DEF FNrefpage(i%,w%)
19602 LOCAL p%,j%:p%=lrefs%(i%):IF p%<>0 OR NOT w% THEN =p%
19604 DIM p% 255:FOR j%=0 TO 255:p%?j%=0:NEXT:lrefs%(i%)=p%
19606 =p%
19610 DEF PROCclearrefs
19612 LOCAL i%,j%,p%
19614 FOR i%=0 TO 63
19616 IF lrefs%(i%)<>0 THEN
19618 p%=lrefs%(i%):FOR j%=0 TO 255:p%?j%=0:NEXT
19620 ENDIF
19622 NEXT:ENDPROC
'''
    change('20000 DATA', helpers+'20000 DATA')
    assert not re.search(r'\b(?:saddr|sort)%\(', source)
    numbers = [int(row.split(' ', 1)[0]) for row in source.splitlines()]
    assert numbers == sorted(set(numbers)) and max(numbers) <= 65279
    assert all(len(row.split(' ', 1)[1]) <= 255 for row in source.splitlines())
    definitions = re.findall(r'\bDEF\s+(PROC|FN)(\w+)', source)
    assert len(definitions) == len(set(definitions)) == 219
    OUT.write_text(source)
    report = dict(source_sha256=hashlib.sha256(BASE.read_bytes()).hexdigest(),
                  candidate_sha256=hashlib.sha256(OUT.read_bytes()).hexdigest(),
                  lines=len(numbers), definitions=len(definitions),
                  symbol_capacity=4096, address_cell_bytes=3, sorted_index_cell_bytes=2,
                  symbol_payload_bytes_saved=12288,
                  target_page_pointer_bytes=256, target_page_bytes=256,
                  maximum_target_pages=64, target_range=[0, 65279],
                  scope='Private compiler storage only; output and public values unchanged')
    (HERE / 'packed.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
