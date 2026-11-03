"""Prepare the BBC source-handler experiment from the qualified DATA compiler."""
from pathlib import Path
import hashlib
R=Path(__file__).resolve().parents[4];T=R/'docs/tasks/C005';s=(R/'compiler/compiler.bas').read_text()
assert hashlib.sha256(s.encode()).hexdigest()=='55643c54bbbff7c0d36f139cad2e9824cec5e36a7078e9f7274b30ebf2d7b8fa'
assert (T/'compiler.bas').read_text()==s,'Preserve another prototype'
def change(a,b):
 global s
 assert s.count(a)==1,a
 s=s.replace(a,b)
change('1028 PROCloadstrings:PROCloadmemory:PROCloadio:PROCloaddata','1028 PROCloadstrings:PROCloadmemory:PROCloadio:PROCloaddata:PROCloaderrors')
change('1065 cdataused%=FALSE:cdnumeric%=FALSE:cdcapture%=FALSE','1065 cdataused%=FALSE:cdnumeric%=FALSE:cdcapture%=FALSE:cerrors%=FALSE')
change('1092 PROCprocscan(cfh%):CLOSE#cfh%:cfh%=OPENIN(csource$):clnum%=0:cpos%=1:ccr%=FALSE','1092 PROCprocscan(cfh%):CLOSE#cfh%:cfh%=OPENIN(csource$):clnum%=0:cpos%=1:ccr%=FALSE\n1094 IF cerrors% PROCuseerrors')
change('LOCAL cn%,cw$,ct%,cinum%,cleid$,ccont%,cfirst%,cinseen%,cdeclskip$','LOCAL cn%,cw$,ct%,cinum%,cleid$,ccont%,cfirst%,cinseen%,cdeclskip$,chskip$')
change('cdeclskip$="":PROCprocscope','cdeclskip$="":chskip$="":cbasicline%=0:PROCprocscope')
change('1619 IF cdeclskip$<>"" PROClabel(cdeclskip$)','1619 IF cdeclskip$<>"" PROClabel(cdeclskip$)\n1620 IF chskip$<>"" PROClabel(chskip$)')
# Renumber this small tail to leave ENDPROC before1622.
s=s.replace('1620 IF chskip$<>"" PROClabel(chskip$)\n1620 ENDPROC','1620 IF chskip$<>"" PROClabel(chskip$)\n1621 ENDPROC')
change('1628 clast%=cn%:PROClabel','1628 clast%=cn%:cbasicline%=cn%:PROClabel')
change('1640 LOCAL cw$,ct%,cn$,csuppress%','1640 LOCAL cw$,ct%,cn$,csuppress%\n1641 PROCerrmark')
change('PROClabel(FNtarget("@"+cn$)):cpos%=cpos%-1:ENDPROC','PROClabel(FNtarget("@"+cn$)):PROCerrmark:cpos%=cpos%-1:ENDPROC')
change('1664 IF cw$="IF"','1663 IF cw$="ON" THEN PROCerrorinstall:ENDPROC\n1664 IF cw$="IF"')
change('1690 IF cw$="VDU"','1689 IF cw$="ERROR" THEN PROCerrorstatement:ENDPROC\n1690 IF cw$="VDU"')
change('1700 IF cw$="CLS"','1692 IF cw$="REPORT" THEN PROCaddr("CD","$errreport"):ENDPROC\n1700 IF cw$="CLS"')
change('1810 IF cw$="GOTO" THEN PROCaddr("C3",cn$) ELSE PROCaddr("21",cn$):PROCaddr("CD","$gosub")','1810 IF cw$="GOTO" THEN PROCaddr("C3",cn$) ELSE PROCaddr("21",cn$):PROCaddr("CD","$gosub"):PROCerrmark')
change('3090 PROCtext("No GOSUB"):PROCnewline\n3100 PROCaddr("C3","$error")','3090 PROCerrorconstant(38,"No GOSUB")')
change('3120 PROCtext("Too many GOSUBs"):PROCnewline','3120 IF cerrors% THEN PROCerrorconstant(0,"Too many GOSUBs") ELSE PROCtext("Too many GOSUBs"):PROCnewline')
change('3227 IF cdataused% PROCdatatable','3227 IF cerrors% PROCerrorruntime\n32275 IF cdataused% PROCdatatable')
# Allocate contiguous numbers in the runtime dispatch block; no BASIC branch
# names target these implementation lines.
a=s.index('3220 PROClabel');b=s.index('3240 DEF PROCbad',a);rows=s[a:b].splitlines();s=s[:a]+'\n'.join(f'{3220+i} {x.split(" ",1)[1]}' for i,x in enumerate(rows))+'\n'+s[b:]
change('4890 IF cw$="EVAL"','4884 IF cw$="ERR" OR cw$="ERL" THEN PROCerritem(cw$):ENDPROC\n4890 IF cw$="EVAL"')
change('5380 PROCtext("Numeric error"):PROCnewline:PROCaddr("C3","$error")','5380 PROCerrorconstant(-1,"Numeric error")')
change('5430 PROCtext(cm$):PROCnewline:PROCaddr("C3","$error")','5430 PROCerrorconstant(18+ci%+ABS(ci%>0),cm$)')
change('6400 PROClabel("$novar"):PROCtext("No such variable"):PROCnewline:PROCaddr("C3","$error")','6400 PROClabel("$novar"):PROCerrorconstant(26,"No such variable")')
change('7870 PROCtext("No room"):PROCnewline:PROCaddr("C3","$error")','7870 PROCerrorconstant(0,"No room")')
change('7880 PROClabel("$strlong"):PROCtext("String too long"):PROCnewline:PROCaddr("C3","$error")','7880 PROClabel("$strlong"):PROCerrorconstant(19,"String too long")')
change('11220 PROClabel(cid$+"b")','11220 PROClabel(cid$+"b"):PROCerrmark')
change('11760 csave%=cpc%','11755 IF cerrors% THEN PROCctlexport("$ctltop",cb%+cttop%):PROCctlexport("$ctlframes",cb%+ctframes%)\n11760 csave%=cpc%')
change('11790 PROClabel("$flowerr"+STR$(ci%)):PROCtext(FNtrim(cn$)):PROCnewline:PROCaddr("C3","$error")','11790 PROClabel("$flowerr"+STR$(ci%)):PROCerrorconstant(ce%,FNtrim(cn$))')
change('11855 PROCbyte(&C3)','11853 IF cerrors% PROCaddr("CD","$errinit")\n11855 PROCbyte(&C3)')
change('13210 PROCspace:IF FNword("DEF") PROCscandef','13210 PROCspace:PROCerrorscan:IF FNword("DEF") PROCscandef')
change('PROClabel("$proc"+STR$(ci%))\n13635','PROClabel("$proc"+STR$(ci%)):PROCerrmark\n13635')
change('13740 PROCaddr("CD","$proc"+STR$(ci%)):cndepth%=0:csdepth%=0','13740 PROCaddr("CD","$proc"+STR$(ci%)):cndepth%=0:csdepth%=0:PROCerrmark')
change('13920 PROCuseacts','13915 PROCspace:IF FNword("ERROR") THEN cpos%=cpos%+5:ENDPROC\n13920 PROCuseacts')
change('14070 csave%=cpc%','14067 IF cerrors% PROCctlexport("$acttop",cb%+catop%)\n14070 csave%=cpc%')
for label,code,msg in [('notlocal',12,'Not in a FN or PROC'),('notproc',13,'Not in a PROC'),('notfn',7,'Not in a FN')]:
 change(f'PROClabel("${label}"):PROCtext("{msg}"):PROCnewline:PROCaddr("C3","$error")',f'PROClabel("${label}"):PROCerrorconstant({code},"{msg}")')
change('15220 cvaluekind%=cpret%(ci%):ccalldepth%=ccalldepth%-1:ENDPROC','15220 cvaluekind%=cpret%(ci%):ccalldepth%=ccalldepth%-1:PROCerrmark:ENDPROC')
change('16438 PROCtext("No room"):PROCnewline:PROCaddr("C3","$error")','16438 PROCerrorconstant(0,"No room")')
change('16456 PROClabel("$me"+STR$(ce%)):PROCtext(cm$):PROCnewline:PROCaddr("C3","$error"):NEXT','16456 PROClabel("$me"+STR$(ce%)):PROCerrorconstant(ce%,cm$):NEXT')
change('17584 PROClabel("$ioerror"):PROCtext("Escape"):PROCnewline:PROCaddr("C3","$error")','17584 PROClabel("$ioerror"):PROCerrorconstant(17,"Escape")')
for label,code,msg in [('datatypemismatch',6,'Type mismatch'),('datasyntax',16,'Syntax error'),('dataempty',42,'Out of DATA')]:
 change(f'PROClabel("${label}"):PROCtext("{msg}"):PROCnewline:PROCaddr("C3","$error")',f'PROClabel("${label}"):PROCerrorconstant({code},"{msg}")')
a,b=s.split('20000 DATA',1);s=a+(T/'errors/frontend.bas').read_text()+'20000 DATA'+b
ls=s.splitlines();ns=[int(x.split()[0]) for x in ls];assert ns==sorted(set(ns)),[(a,b) for a,b in zip(ns,ns[1:]) if a>=b];assert max(len(x.split(' ',1)[1]) for x in ls)<=255
(T/'compiler.bas').write_text(s);print('Prepared BBC source-error experiment',len(ls),'ordered lines; package DATA63000 afterward')
