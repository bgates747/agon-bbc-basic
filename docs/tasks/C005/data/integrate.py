"""Prepare DATA BBC experiment from the exact qualified I/O source; no parsing in Python."""
from pathlib import Path
import hashlib
R=Path(__file__).resolve().parents[4];T=R/'docs/tasks/C005'
s=(T/'compiler.bas').read_text()
assert hashlib.sha256(s.encode()).hexdigest()=='483e17305c6448f513f0408ca0cbc6a2e36570f75ba2f7693045ca62f78c2cf1','Preserve a different prototype'
def change(a,b):
 global s
 assert s.count(a)==1,a
 s=s.replace(a,b)
change('1028 PROCloadstrings:PROCloadmemory:PROCloadio','1028 PROCloadstrings:PROCloadmemory:PROCloadio:PROCloaddata')
change('1064 cflow%=0:cbnum%=0','1064 cflow%=0:cbnum%=0\n1065 cdataused%=FALSE:cdnumeric%=FALSE:cdcapture%=FALSE')
change('1690 IF cw$="VDU"','1686 IF cw$="DATA" THEN PROCdatastatement:ENDPROC\n1687 IF cw$="READ" THEN PROCreadstatement:ENDPROC\n1688 IF cw$="RESTORE" THEN PROCrestoredata:ENDPROC\n1690 IF cw$="VDU"')
change('4170 LOCAL ci%,cp%','4170 LOCAL ci%,cp%\n4172 IF cdcapture% THEN PROCcapturenumber(cv):ENDPROC')
change('5185 LOCAL ci%,cq','5185 LOCAL ci%,cq\n51851 IF cdcapture% THEN PROCcapturepacked(cv,ce%):ENDPROC')
# Renumber the tightly packed literal helper, preserving DATA addresses.
a=s.index('5184 DEF PROCpacked');b=s.index('5192 DEF PROCnumruntime',a)
lines=s[a:b].splitlines();s=s[:a]+'\n'.join(f'{5184+i} {x.split(" ",1)[1]}' for i,x in enumerate(lines))+'\n'+s[b:]
# Nine lines require5184..5192; give numruntime its adjacent unused5193 number.
s=s.replace('5192 DEF PROCnumruntime','5193 DEF PROCnumruntime')
change('5108 IF cnumerr%<>0 THEN','5108 IF cnumerr%<>0 AND NOT cdcapture% THEN')
a=s.index('3220 PROClabel');b=s.index('3240 DEF PROCbad',a)
lines=s[a:b].splitlines();body=[x.split(' ',1)[1] for x in lines]
body.insert(body.index('IF cvnum%>0 PROCvarruntime'),'IF cdataused% PROCdataruntime')
body.insert(body.index('IF cstrings% PROCstrruntime'),'IF cdataused% PROCdatatable')
s=s[:a]+'\n'.join(f'{3220+i} {x}' for i,x in enumerate(body))+'\n'+s[b:]
a,b=s.split('20000 DATA',1);s=a+(T/'data/frontend.bas').read_text()+'20000 DATA'+b
ls=s.splitlines();ns=[int(x.split()[0]) for x in ls];assert ns==sorted(set(ns)),[(a,b) for a,b in zip(ns,ns[1:]) if a>=b]
assert max(len(x.split(' ',1)[1]) for x in ls)<=255
(T/'compiler.bas').write_text(s);print('Prepared BBC DATA experiment',len(ls),'ordered lines; package DATA62000 afterward')
