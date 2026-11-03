"""Prepare BBC-only graphics/GET emitter changes from the qualified baseline."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent
source = (ROOT / 'compiler/compiler.bas').read_text()
assert hashlib.sha256(source.encode()).hexdigest() == '6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8'
source = source.replace('1680 IF w$="PRINT" THEN PROCprint:ENDPROC\n',
    '1680 IF w$="PRINT" THEN PROCprint:ENDPROC\n'
    '1681 IF w$="MODE" OR w$="GCOL" OR w$="PLOT" THEN PROCgraphics(w$):ENDPROC\n')
source = source.replace('4884 IF w$="ERR" OR w$="ERL" THEN PROCerritem(w$):ENDPROC\n',
    '4884 IF w$="ERR" OR w$="ERL" THEN PROCerritem(w$):ENDPROC\n'
    '4886 IF w$="GET" THEN PROCkeyvalue:ENDPROC\n')
definitions = '''19630 DEF PROCgraphicarg
19632 PROCexpr(1):PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38):ENDPROC
19634 DEF PROCgraphicbyte(i%,j%)
19636 PROCaddr("21","$v"+STR$(i%)):IF j%>0 PROCbyte(&23)
19638 PROCbytes("7E49D7"):ENDPROC
19640 DEF PROCgraphics(w$)
19642 LOCAL n%,i%
19644 IF w$="MODE" THEN PROCmode:ENDPROC
19646 ndepth%=0:sdepth%=0:PROCgraphicarg:n%=1:PROCspace
19648 IF FNpeek="," THEN PROCexpect(","):PROCgraphicarg:n%=2:PROCspace
19650 IF w$="GCOL" THEN
19652 PROCcharacter(18):IF n%=1 THEN PROCcharacter(0) ELSE PROCgraphicbyte(0,0)
19654 PROCgraphicbyte(n%-1,0):ndepth%=0:ENDPROC
19656 ENDIF
19658 IF n%<>2 PROCbad("PLOT needs two or three numeric arguments")
19660 IF FNpeek="," THEN PROCexpect(","):PROCgraphicarg:n%=3
19662 PROCcharacter(25):IF n%=2 THEN PROCcharacter(69) ELSE PROCgraphicbyte(0,0)
19664 FOR i%=n%-2 TO n%-1:PROCgraphicbyte(i%,0):PROCgraphicbyte(i%,1):NEXT
19666 ndepth%=0:ENDPROC
19670 DEF PROCmode
19672 PROCbytes("DDE53E0849CFDDCB04A6")
19674 ndepth%=0:sdepth%=0:PROCgraphicarg:PROCcharacter(22):PROCgraphicbyte(0,0)
19676 PROCbytes("3E0849CFDDCB046628FADDE1"):ndepth%=0:ENDPROC
19680 DEF PROCkeyvalue
19682 LOCAL n$,s$
19684 IF FNpeek="(" OR FNpeek="#" OR FNpeek="$" PROCbad("Only bare keyboard GET is supported")
19686 PROCnumslot:valuekind%=0:s$="$v"+STR$(ndepth%-1):n$=FNflow
19688 PROCbytes("DDE5FDE5AF49CFFDE1DDE1FE1B"):PROCaddr("C2",n$)
19690 PROCerrorconstant(17,"Escape"):PROClabel(n$)
19692 PROCaddr("21",s$):PROCbytes("7723AF77237723772377"):ENDPROC
'''
source = source.replace('20000 DATA ', definitions + '20000 DATA ', 1)
(TASK / 'candidate.bas').write_text(source)
print(hashlib.sha256(source.encode()).hexdigest())
