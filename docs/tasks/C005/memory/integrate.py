"""Prepare a BBC-source experiment from the qualified live source; not a compiler."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[4]
TASK = ROOT/'docs/tasks/C005'
source = (ROOT/'compiler/compiler.bas').read_text()
assert hashlib.sha256(source.encode()).hexdigest() == '0f0884ca11790d51c991cee68d8caa180e21f0fdecf512b7dcf341bbc7fafc4c'
target = TASK/'compiler.bas'
assert target.read_text() == source, 'Preserve an existing experiment before preparing another'


def change(old, new):
    global source
    assert source.count(old) == 1, old
    source = source.replace(old, new)


change('1020 DIM crname$(2047),craddr%(2047),crline%(2047),crcol%(2047)',
       '1020 DIM crname$(4095),craddr%(4095),crline%(4095),crcol%(4095)')
change('2630 IF crnum%=2048', '2630 IF crnum%=4096')
change('1024 DIM cvname$(127),cvsize%(127),cvstatic%(127),cvtype%(127),ckwords$(4)',
       '1024 DIM cvname$(255),cvsize%(255),cvstatic%(255),cvtype%(255),cvdim%(255),ckwords$(4)')
change('1028 PROCloadstrings', '1028 PROCloadstrings:PROCloadmemory')
change('1064 cflow%=0:cbnum%=0', '1063 cmemory%=FALSE:cdimparse%=0\n1064 cflow%=0:cbnum%=0')
change('1645 IF FNpeek="="', '1642 IF FNpeek="?" OR FNpeek="!" OR FNpeek="|" THEN PROCmemassign(FNpeek):ENDPROC\n1645 IF FNpeek="="')
change('1674 IF cw$="DEF"', '1673 IF cw$="DIM" THEN PROCdim:ENDPROC\n1674 IF cw$="DEF"')
change('3228 IF cacts% PROCactworkspace\n3230 ENDPROC',
       '3228 IF cmemory% PROCmemoryruntime\n3229 IF cmemory% PROCmemoryworkspace\n3230 IF cacts% PROCactworkspace\n3232 ENDPROC')
change('4785 IF NOT cdone% AND MID$',
       '4782 IF NOT cdone% THEN IF cc$="^" OR cc$="?" OR cc$="!" OR cc$="|" THEN PROCmemitem(cc$):cdone%=TRUE\n4785 IF NOT cdone% AND MID$')
change('6070 IF FNpeek="(" PROCbad("Arrays and function calls are not yet supported")',
       '6070 IF FNpeek="(" THEN cn$=cn$+"(":ct%=ct%+256:cs%=FALSE')
change('6090 IF FNpeek="!" OR FNpeek="?" OR FNpeek="|" PROCbad("Variable indirection is not yet supported")',
       '6090 IF FNpeek="|" PROCbad("Binary variant indirection is unsupported")')
change('6130 IF cvnum%=128 PROCbad("Scalar variable limit exceeds 128")',
       '6130 IF cvnum%=256 PROCbad("Variable limit exceeds 256")')
change('6140 cw%=ct%:IF ct%=129 THEN cw%=5:cstrings%=TRUE:csvars%=csvars%+1',
       '6140 cw%=ct% AND 255:IF cw%=129 THEN cw%=5:cstrings%=TRUE:csvars%=csvars%+1\n6141 IF ct%>255 cw%=3')
change('cvstatic%(cf%)=cs%:cvnum%=cvnum%+1', 'cvstatic%(cf%)=cs%:cvdim%(cf%)=0:cvnum%=cvnum%+1')
change('6190 ci%=FNvariable(cn$):ct%=cvtype%(ci%):PROCexpect("=")',
       '6190 ci%=FNvariable(cn$):ct%=cvtype%(ci%)\n6191 IF ct%>255 THEN PROCarrayassign(ci%):ENDPROC\n61912 IF FNpeek="?" OR FNpeek="!" THEN PROCindirectassign(ci%):ENDPROC\n61914 PROCexpect("=")')
# The inserted statement numbers below are assigned within the existing gap.
source = source.replace('61912 ', '61915 ').replace('61914 ', '61918 ')
# Renumber this tiny original6190..6192 region consecutively; all other numbers
# remain unchanged until the final order check below.
source = source.replace('6191 IF ct%>255', '61901 IF ct%>255')
start = source.index('6190 ci%=FNvariable')
end = source.index('6200 REM', start)
body = [line.split(' ', 1)[1] for line in source[start:end].splitlines()]
source = source[:start]+'\n'.join(f'{6190+i} {line}' for i, line in enumerate(body))+'\n'+source[end:]
start = source.index('6260 DEF PROCvariable')
end = source.index('6340 DEF PROCvarcopy', start)
source = source[:start]+'''6260 DEF PROCvariable(cn$)
6270 LOCAL ci%:ci%=FNvariable(cn$)
6280 IF cvtype%(ci%)>255 THEN PROCarrayread(ci%):ENDPROC
6290 PROCreadscalar(ci%):PROCmemtail
6330 ENDPROC
'''+source[end:]
change('7530 ci%=FNvariable(cs$):IF cvtype%(ci%)<>129 PROCbad("Expected a string variable")',
       '7530 ci%=FNvariable(cs$)\n7532 IF cvtype%(ci%)>255 THEN PROCarrayread(ci%):ENDPROC\n7534 IF cvtype%(ci%)<>129 PROCbad("Expected a string variable")')
change('7920 PROClabel("$sheapctx")', '7920 IF NOT cmemory% THEN PROClabel("$sheapctx")')
change('7930 PROClabel("$sheap")', '7930 IF NOT cmemory% THEN PROClabel("$sheap")')
change('7940 IF csaddr%(csnum%-1)>&B0000', '7940 IF NOT cmemory% AND csaddr%(csnum%-1)>&B0000')
change('8930 IF cvtype%(ci%)<>129', '8922 IF cvtype%(ci%)>255 PROCbad("Array slice assignment is unsupported")\n8930 IF cvtype%(ci%)<>129')
change('11280 clvar%', '11272 IF cvtype%(ci%)>255 PROCbad("Array FOR variables are unsupported")\n11280 clvar%')
change('13390 cv%=FNvariable(cn$):ck%=0',
       '13390 cv%=FNvariable(cn$):ck%=0\n13392 IF cvtype%(cv%)>255 PROCbad("Array formal parameters are unsupported")')
change('13950 ci%=FNvariable(cn$):PROCsavebinding(ci%):PROCaddr("CD","$actinstall")',
       '13950 ci%=FNvariable(cn$)\n13952 IF cvtype%(ci%)>255 PROCbad("LOCAL arrays are unsupported")\n13954 PROCsavebinding(ci%):PROCaddr("CD","$actinstall")')
change('IF cstrings% cp%=csaddr%(FNsymbol("$sheapend"))',
       'IF cstrings% OR cmemory% cp%=csaddr%(FNsymbol("$sheapend"))')
change('15100 cn$=FNcallname(1)',
       '15095 IF cdimparse%>0 PROCbad("FN calls in array DIM expressions are unqualified")\n15100 cn$=FNcallname(1)')
body, data = source.split('20000 DATA', 1)
source = body+(TASK/'memory/frontend.bas').read_text()+'20000 DATA'+data
lines = source.splitlines()
numbers = [int(line.split()[0]) for line in lines]
assert numbers == sorted(set(numbers))
assert max(len(line.split(' ', 1)[1]) for line in lines) <= 255
target.write_text(source)
print('Prepared BBC memory experiment:', len(lines), 'ordered lines; runtime DATA60000 still to package')
