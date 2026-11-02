"""Prepare a BBC I/O frontend experiment from the qualified memory source."""
from pathlib import Path
import hashlib
R=Path(__file__).resolve().parents[4];T=R/'docs/tasks/C005'
s=(R/'compiler/compiler.bas').read_text()
assert hashlib.sha256(s.encode()).hexdigest()=='d0368b1ea7ebc0ac26da0f13d07c3f40d6c776c9f5f2b0c4a2c31bc78576ab1c'
assert (T/'compiler.bas').read_text()==s,'Preserve prior experiments'
def change(a,b):
 global s
 assert s.count(a)==1,a
 s=s.replace(a,b)
change('1028 PROCloadstrings:PROCloadmemory','1028 PROCloadstrings:PROCloadmemory:PROCloadio')
change('1063 cmemory%=FALSE:cdimparse%=0','1063 cmemory%=FALSE:cdimparse%=0:cio%=FALSE:cfileio%=FALSE')
change('1680 IF cw$="PRINT"','1679 IF cw$="INPUT" THEN PROCinputline:ENDPROC\n1680 IF cw$="PRINT"')
change('1690 IF cw$="VDU"','1682 IF cw$="CLOSE" THEN PROCclosestatement:ENDPROC\n1684 IF cw$="BPUT" THEN PROCbput:ENDPROC\n1690 IF cw$="VDU"')
change('3190 PROCaddr("ED7B"','3185 IF cfileio% THEN PROCbytes("E5AF"):PROCaddr("CD","$ioclose"):PROCbyte(&E1)\n3190 PROCaddr("ED7B"')
change('3224 IF cvnum%>0','3223 IF cio% PROCIOruntime\n3224 IF cvnum%>0')
change('4890 IF cw$="EVAL"','4882 IF cw$="OPENIN" OR cw$="OPENOUT" OR cw$="OPENUP" OR cw$="BGET" OR cw$="EOF" THEN PROCioitem(cw$):ENDPROC\n4890 IF cw$="EVAL"')
a,b=s.split('20000 DATA',1);s=a+(T/'io/frontend.bas').read_text()+'20000 DATA'+b
ls=s.splitlines();ns=[int(x.split()[0]) for x in ls]
assert ns==sorted(set(ns));assert max(len(x.split(' ',1)[1]) for x in ls)<=255
(T/'compiler.bas').write_text(s);print('BBC I/O experiment:',len(ls),'lines before DATA61000')
