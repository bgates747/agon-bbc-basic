"""Prepare BBC-only streaming source from the separately qualified error source.
This edits compiler implementation text; it never parses or compiles a user's BASIC.
"""
from pathlib import Path
import hashlib,re
R=Path(__file__).resolve().parents[4];T=R/'docs/tasks/C005';s=(T/'compiler.bas').read_text()
assert hashlib.sha256(s.encode()).hexdigest()=='7cac4bba8644a047c38c496a5fc7cb0fc6c9118b892aad6c3314091867c7fe36'
def change(a,b):
 global s
 assert s.count(a)==1,a
 s=s.replace(a,b)
def block(a,b,replacement):
 global s
 start=s.index(a);end=s.index(b,start);s=s[:start]+replacement+'\n'+s[end:]
change('1010 DIM ccode% 65535,csname$(1023),csaddr%(1023),csort%(1023)','1010 DIM csname$(4095),csaddr%(4095),csort%(4095),clrefs% 16383')
change('1020 DIM crname$(4095),craddr%(4095),crline%(4095),crcol%(4095)','1020 REM Output streams after layout and validation; no code/fixup buffers.')
change('1060 cpc%=0:csnum%=0:crnum%=0:clnum%=0:cpos%=1:clast%=-1:ccr%=FALSE','1060 cpc%=0:csnum%=0:clnum%=0:cpos%=1:clast%=-1:ccr%=FALSE:cphase%=1\n1061 FOR ci%=0 TO 16383:clrefs%?ci%=0:NEXT')
change('1092 PROCprocscan(cfh%):CLOSE#cfh%:cfh%=OPENIN(csource$):clnum%=0:cpos%=1:ccr%=FALSE','1092 PROCprocscan(cfh%):CLOSE#cfh%')
change('1100 PROCaddr("C3","$start")','1095 FOR cphase%=1 TO 3\n1096 IF cphase%=3 THEN coh%=OPENOUT(ctarget$):IF coh%=0 PROCbad("Cannot open output")\n1097 PROCpass\n1098 NEXT:CLOSE#coh%:ENDPROC\n1099 DEF PROCpass\n1100 cfh%=OPENIN(csource$):IF cfh%=0 PROCbad("Cannot reopen source")\n1101 cpc%=0:clnum%=0:cpos%=1:clast%=-1:ccr%=FALSE:cflow%=0:cbnum%=0:cltop%=0:cstructure$="":cscope%=0:cndepth%=0:csdepth%=0:ccalldepth%=0:ckinddepth%=0\n1102 PROCaddr("C3","$start")')
change('1130 PROClabel("$start")','1130 cstart%=&40000+cpc%')
block('1260 FOR ci%=0 TO crnum%-1','1370 DEF PROCreadline','1260 PROCdefine("$start",cstart%)\n1270 ENDPROC')
change('1628 clast%=cn%:cbasicline%=cn%:PROClabel(FNtarget("#"+STR$(cn%)))','1628 clast%=cn%:cbasicline%=cn%:IF FNlineref(cn%,0,FALSE) PROClabel(FNtarget("#"+STR$(cn%)))')
block('2560 DEF PROClabel','2760 DEF PROCbytes','''2560 DEF PROClabel(cn$)
2570 PROCdefine(cn$,&40000+cpc%):ENDPROC
2610 DEF PROCaddr(ch$,cn$)
2620 LOCAL ci%,cv%:IF ch$<>"" PROCbytes(ch$)
2630 cv%=0:IF cphase%>1 THEN ci%=FNsymbol(cn$):IF ci%<0 PROCbad("Undefined target "+cn$)
2640 IF cphase%>1 cv%=csaddr%(ci%)
2650 PROCword24(cv%):ENDPROC
2720 DEF PROCbyte(cv%)
2730 IF &40000+cpc%>=&B0000 PROCbad("Executable exceeds user RAM")
2740 IF cphase%=3 BPUT#coh%,cv%
2750 cpc%=cpc%+1:ENDPROC''')
# Internal package copies become a single BBC emitter. Bridge operands are
# substituted at their original offsets; no seek/rewind or post-write patch.
block('5200 cbase%=cpc%','5270 PROClabel','5200 cbase%=cpc%:PROCtemplate(cnimage%,cnsize%,cnrelocs%,0)')
block('7780 cbase%=cpc%','7810 PROClabel','7780 cbase%=cpc%:PROCtemplate(csimage%,cssize%,csrelocs%,1)')
block('7960 DEF PROCstrrelocate','8010 DEF FNstrreserved','')
block('11720 cb%=cpc%','11740 PROCctlexport','11720 cb%=cpc%:PROCtemplate(ctimage%,ctsize%,ctrelocs%,2)')
change('11760 csave%=cpc%:cpc%=cb%+ctnumslot%:PROCaddr("","$numop"):cpc%=csave%','11760 REM Numeric bridge emitted with control template.')
block('14020 cb%=cpc%','14050 PROCctlexport','14020 cb%=cpc%:PROCtemplate(caimage%,casize%,carelocs%,3)')
block('14070 csave%=cpc%','14090 PROClabel','14070 REM Control/numeric bridges emitted with activation template.')
block('16424 cb%=cpc%','16430 PROCctlexport','16424 cb%=cpc%:PROCtemplate(cmimage%,cmsize%,cmrelocs%,4)')
block('17576 cb%=cpc%','17580 PROCctlexport','17576 cb%=cpc%:PROCtemplate(ciimage%,cisize%,cirelocs%,5)')
block('18096 cb%=cpc%','18100 PROCctlexport','18096 cb%=cpc%:PROCtemplate(cdimage%,cdsize%,cdrelocs%,6)')
block('19104 cb%=cpc%','19108 cs$=','19104 cb%=cpc%:PROCtemplate(ceimage%,cesize%,cerelocs%,7)')
block('19112 cs$=','19116 ENDPROC','19112 REM Error bridges emitted with error template.\n19115 PROCctlexport("$errtrap",cb%+ceentry%(23))')
# Every export defines its final address exactly once per pass.
s=re.sub(r'PROClabel\(("\$[^"]+")\):csaddr%\(csnum%-1\)=(&40000\+cbase%\+\w+%)',r'PROCdefine(\1,\2)',s)
change('11890 PROClabel(cn$):csaddr%(csnum%-1)=&40000+cp%:ENDPROC','11890 PROCdefine(cn$,&40000+cp%):ENDPROC')
change('11850 ci%=FNsymbol("$start"):cp%=csaddr%(ci%):csaddr%(ci%)=&40000+cpc%:PROCaddr("CD","$ctlinit")','11850 cp%=cstart%:cstart%=&40000+cpc%:PROCaddr("CD","$ctlinit")')
change('18134 ci%=FNsymbol("$start"):cp%=csaddr%(ci%):csaddr%(ci%)=&40000+cpc%','18134 cp%=cstart%:cstart%=&40000+cpc%')
change('7930 IF NOT cmemory% THEN PROClabel("$sheap"):PROClabel("$sheapend"):csaddr%(csnum%-1)=csaddr%(csnum%-1)+1024*csvars%','7930 IF NOT cmemory% THEN PROClabel("$sheap"):PROCdefine("$sheapend",&40000+cpc%+1024*csvars%)')
change('7940 IF NOT cmemory% AND csaddr%(csnum%-1)>&B0000 PROCbad("String workspace exceeds user RAM")','7940 IF NOT cmemory% AND &40000+cpc%+1024*csvars%>&B0000 PROCbad("String workspace exceeds user RAM")')
change('14170 PROClabel("$actbase"):csaddr%(csnum%-1)=cp%:PROClabel("$actlimit"):csaddr%(csnum%-1)=cp%+32768','14170 PROCdefine("$actbase",cp%):PROCdefine("$actlimit",cp%+32768)')
change('16470 PROClabel("$sheapend"):csaddr%(csnum%-1)=cp%:ENDPROC','16470 PROCdefine("$sheapend",cp%):ENDPROC')
change('18142 LOCAL cmore%:IF cn%>=0 PROClabel("$data#"+STR$(cn%))','18142 LOCAL cmore%:IF cn%>=0 THEN IF FNlineref(cn%,1,FALSE) PROClabel("$data#"+STR$(cn%))')
change('13210 PROCspace:PROCerrorscan:IF FNword("DEF") PROCscandef','13210 PROCspace:PROCtargetscan:PROCerrorscan:IF FNword("DEF") PROCscandef')
block('13480 LOCAL ci%','13540 DEF FNtarget',"""13480 LOCAL ci%:ci%=cscope%
13490 IF ci%>=cpnum% ENDPROC
13500 IF cpline%(ci%)<>clnum% ENDPROC
13510 IF cstructure$<>\"\" PROCbad(\"Definition crosses an open block\")
13520 cscope%=ci%+1
13530 ENDPROC""")
# Inline the existing character checks to avoid a BBC procedure invocation per
# source byte. CR/LF/CRLF, NUL and physical-length behavior remain unchanged.
block('1380 LOCAL cb%,cdone%','1510 DEF PROCline',"""1380 LOCAL cb%,cdone%
1390 cline$=\"\":cdone%=FALSE
1400 WHILE NOT EOF#ch% AND NOT cdone%
1410 cb%=BGET#ch%
1420 IF ccr% AND cb%=10 THEN
1422 ccr%=FALSE
1424 ELSE
1426 IF cb%=10 OR cb%=13 THEN
1428 cdone%=TRUE
1430 ELSE
1432 IF cb%=0 PROCbad(\"NUL byte in source\")
1434 IF LEN(cline$)=255 THEN cpos%=256:PROCbad(\"Source line exceeds 255 bytes\")
1436 cline$=cline$+CHR$(cb%)
1438 ENDIF
1440 ccr%=(cb%=13)
1442 ENDIF
1444 ENDWHILE
1446 ENDPROC""")
# Count fixed chunks during layout/validation; write their exact bytes only in
# the final pass. These are compiler opcode/data templates, not user evaluation.
block('2760 DEF PROCbytes','2840 DEF PROCcharacter',"""2760 DEF PROCbytes(ch$)
2770 LOCAL ci%,ca%,cb%
2772 IF ch$="" ENDPROC
2774 PROCcodecount(LEN(ch$) DIV 2):IF cphase%<>3 ENDPROC
2780 FOR ci%=1 TO LEN(ch$) STEP 2
2790 ca%=INSTR("0123456789ABCDEF",MID$(ch$,ci%,1))-1
2800 cb%=INSTR("0123456789ABCDEF",MID$(ch$,ci%+1,1))-1
2810 BPUT#coh%,ca%*16+cb%
2820 NEXT
2830 ENDPROC""")
change('2930 FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT','2930 PROCstringbytes(cs$)')
change('4200 FOR ci%=0 TO 4:PROCbyte(cp%?ci%):NEXT','4200 PROCblob(cp%,5)')
block('5188 FOR ci%=0 TO 3','5191 ENDPROC',"""5188 PROCcodecount(5):IF cphase%<>3 ENDPROC
5189 FOR ci%=0 TO 3:cq=INT(cv/256):BPUT#coh%,cv-cq*256:cv=cq:NEXT
5190 BPUT#coh%,ce%""")
change('7600 PROCbyte(LEN(cs$)):IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT','7600 PROCbyte(LEN(cs$)):PROCstringbytes(cs$)')
change('7900 PROClabel("$s"+STR$(ci%)):FOR cj%=0 TO 255:PROCbyte(0):NEXT','7900 PROClabel("$s"+STR$(ci%)):PROCzeros(256)')
change('6430 PROClabel("$var"+STR$(ci%)):FOR cj%=1 TO cvsize%(ci%):PROCbyte(0):NEXT','6430 PROClabel("$var"+STR$(ci%)):PROCzeros(cvsize%(ci%))')
change('14127 IF cfunctions% THEN PROClabel("$fnnum"):PROCbytes("0000000000"):PROClabel("$fnstr"):FOR ci%=0 TO 255:PROCbyte(0):NEXT','14127 IF cfunctions% THEN PROClabel("$fnnum"):PROCbytes("0000000000"):PROClabel("$fnstr"):PROCzeros(256)')
change('19096 IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT','19096 PROCstringbytes(cs$)')
change('18172 PROCbyte(LEN(cs$)):PROCbyte(ce%):FOR ci%=0 TO 4:PROCbyte(cdpacket%?ci%):NEXT:PROCbyte(0)','18172 PROCcodecount(8):IF cphase%=3 THEN BPUT#coh%,LEN(cs$):BPUT#coh%,ce%:FOR ci%=0 TO 4:BPUT#coh%,cdpacket%?ci%:NEXT:BPUT#coh%,0')
change('18174 IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT','18174 PROCstringbytes(cs$)')
# Preserve validation before writing; inlining the existing byte check avoids
# another BBC call per DATA character without changing its order or diagnostic.
change('18171 IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCdatabytecheck(ASC(MID$(cs$,ci%,1))):NEXT',"""18170 IF cs$<>"" THEN
181701 FOR ci%=1 TO LEN(cs$)
181702 IF ASC(MID$(cs$,ci%,1))<32 PROCbad("Control bytes in DATA are unsupported")
181703 NEXT
181704 ENDIF""")
a=s.index('18000 DEF PROCloaddata');b=s.index('19000 DEF PROCloaderrors',a);r=s[a:b].splitlines();s=s[:a]+'\n'.join(f'{18000+2*i} {row.split(" ",1)[1]}' for i,row in enumerate(r))+'\n'+s[b:]
a,b=s.split('20000 DATA',1);s=a+(T/'streaming/frontend.bas').read_text()+'20000 DATA'+b
assert not re.search(r'ccode%|crname\$|craddr%|crline%|crcol%|PROCpatch|csaddr%\(csnum%-1\)',s)
s='\n'.join(x for x in s.splitlines() if x.strip())+'\n';rows=s.splitlines();numbers=[int(x.split()[0]) for x in rows];assert numbers==sorted(set(numbers));assert max(len(x.split(' ',1)[1]) for x in rows)<=255
defs=re.findall(r'^\d+ DEF (PROC|FN)([A-Za-z_][A-Za-z0-9_]*[$%&]?)',s,re.M);assert len(defs)==len(set(defs)),'Compiler source needs unique routine names'
out=T/'streaming/compiler.bas';assert not out.exists(),'Preserve an existing candidate';out.write_text(s);print('Prepared',len(rows),'lines',hashlib.sha256(s.encode()).hexdigest())
