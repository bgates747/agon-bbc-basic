10 PROCinit:RESTORE 10000
20 test%=0
30 test%=test%+1
40 IF test%>3 THEN PRINT "OUTPUT_COMPILE_DONE":OSCLI "BYE"
50 READ src$,dst$
60 ON ERROR PRINT "ERR:";src$:REPORT:PRINT " at ";ERL:CLOSE#0:GOTO 90
70 PROCcompile(src$,dst$)
80 PRINT "OK:";src$
90 GOTO 30
1000 DEF PROCinit
1010 DIM ccode% 65535,csname$(1023),csaddr%(1023),csort%(1023)
1020 DIM crname$(4095),craddr%(4095),crline%(4095),crcol%(4095)
1021 DIM cpname$(255),cpline%(255),cparcnt%(255),cpar%(255,15),cargkind%(31,15),cargindex%(31,15),cpkind%(255),cpret%(255),creturn$(511),cretdef%(511),cretline%(511),cretcol%(511)
1022 PROCloadnumbers
1023 PROCloadacts
1024 DIM cvname$(255),cvsize%(255),cvstatic%(255),cvtype%(255),cvdim%(255),ckwords$(4)
1025 DIM csunsafe%(15)
1026 PROCkeywords
1027 PROCloadcontrol
1028 PROCloadstrings:PROCloadmemory
1029 DIM cifid$(31),cbid$(31),cbelse%(31),clkind%(31),clname$(31),clvar%(31)
1030 ENDPROC
1040 DEF PROCcompile(csource$,ctarget$)
1050 LOCAL ci%,cj%,cn%,cfh%,coh%
1060 cpc%=0:csnum%=0:crnum%=0:clnum%=0:cpos%=1:clast%=-1:ccr%=FALSE
1062 cnumeric%=FALSE:cnslots%=0:cnparse%=0:cndepth%=0:cvnum%=0:cstrings%=FALSE:csdepth%=0:csslots%=0:csvars%=0:cvaluekind%=0
1063 cmemory%=FALSE:cdimparse%=0
1064 cflow%=0:cbnum%=0
1066 cloops%=FALSE:cltop%=0:cstructure$=""
1068 cacts%=FALSE:cfunctions%=FALSE:cpnum%=0:cscope%=0:cretnum%=0:ccalldepth%=0:ckinddepth%=0
1070 IF csource$=ctarget$ PROCbad("Source and output must differ")
1080 cfh%=OPENIN(csource$)
1090 IF cfh%=0 PROCbad("Cannot open source")
1092 PROCprocscan(cfh%):CLOSE#cfh%:cfh%=OPENIN(csource$):clnum%=0:cpos%=1:ccr%=FALSE
1100 PROCaddr("C3","$start")
1110 REPEAT:PROCbyte(0):UNTIL cpc%=64
1120 PROCbytes("4D4F530001")
1130 PROClabel("$start")
1140 REM Preserve MOS registers; saved SP occupies exactly three bytes.
1150 PROCbytes("F5C5D5DDE5FDE5")
1160 PROCaddr("ED73","$savedsp")
1170 PROCbytes("AF"):PROCaddr("32","$depth")
1180 WHILE NOT EOF#cfh%
1190 clnum%=clnum%+1:cpos%=1
1200 PROCreadline(cfh%)
1210 PROCline
1220 ENDWHILE
1230 CLOSE#cfh%:cfh%=0
1232 IF cbnum%<>0 PROCbad("Missing ENDIF")
1234 IF cltop%<>0 PROCbad("Missing loop terminator")
1240 PROCaddr("C3","$end")
1250 PROCruntime
1260 FOR ci%=0 TO crnum%-1
1270 cj%=FNsymbol(crname$(ci%))
1280 IF cj%<0 THEN clnum%=crline%(ci%):cpos%=crcol%(ci%):PROCbad("Undefined target "+crname$(ci%))
1290 cn%=csaddr%(cj%):PROCpatch(craddr%(ci%),cn%)
1300 NEXT
1310 REM No output is opened until the entire source and relocations validate.
1320 coh%=OPENOUT(ctarget$)
1330 IF coh%=0 PROCbad("Cannot open output")
1340 FOR ci%=0 TO cpc%-1:BPUT#coh%,ccode%?ci%:NEXT
1350 CLOSE#coh%
1360 ENDPROC
1370 DEF PROCreadline(ch%)
1380 LOCAL cb%,cdone%
1390 cline$="":cdone%=FALSE
1400 WHILE NOT EOF#ch% AND NOT cdone%
1410 cb%=BGET#ch%
1420 IF ccr% AND cb%=10 THEN ccr%=FALSE ELSE PROCreadchar(cb%):ccr%=(cb%=13)
1430 ENDWHILE
1440 ENDPROC
1450 DEF PROCreadchar(cb%)
1460 IF cb%=10 OR cb%=13 THEN cdone%=TRUE:ENDPROC
1470 IF cb%=0 PROCbad("NUL byte in source")
1480 IF LEN(cline$)=255 THEN cpos%=256:PROCbad("Source line exceeds 255 bytes")
1490 cline$=cline$+CHR$(cb%)
1500 ENDPROC
1510 DEF PROCline
1520 LOCAL cn%,cw$,ct%,cinum%,cleid$,ccont%,cfirst%,cinseen%,cdeclskip$
1522 cinum%=0:cleid$="":cfirst%=TRUE:cinseen%=FALSE:cdeclskip$="":PROCprocscope
1530 PROCspace
1540 IF FNdigit(FNpeek) PROCnumberlabel
1570 PROCspace
1580 WHILE FNpeek<>""
1590 WHILE FNpeek=":":cpos%=cpos%+1:PROCspace:ENDWHILE
1595 ccont%=FALSE:IF FNpeek<>"" PROCstatement
1600 PROCspace
1605 cfirst%=FALSE
1610 IF FNpeek<>"" AND FNpeek<>":" AND NOT ccont% AND NOT FNword("ELSE") PROCbad("Unexpected text after statement")
1615 ENDWHILE
1618 PROCiffalse:IF cleid$<>"" PROClabel(cleid$)
1619 IF cdeclskip$<>"" PROClabel(cdeclskip$)
1620 ENDPROC
1622 DEF PROCnumberlabel
1624 LOCAL cn%
1626 cn%=FNnumber(65279):IF cn%<=clast% PROCbad("Line numbers must increase")
1628 clast%=cn%:PROClabel(FNtarget("#"+STR$(cn%)))
1630 ENDPROC
1632 DEF PROCstatement
1640 LOCAL cw$,ct%,cn$,csuppress%
1642 IF FNpeek="?" OR FNpeek="!" OR FNpeek="|" THEN PROCmemassign(FNpeek):ENDPROC
1645 IF FNpeek="=" THEN cpos%=cpos%+1:PROCfnreturn:ENDPROC
1650 IF FNpeek="@" THEN cpos%=cpos%+1:cn$=FNname:PROCexpect(":"):PROClabel(FNtarget("@"+cn$)):cpos%=cpos%-1:ENDPROC
1655 IF MID$(cline$,cpos%,4)="PROC" THEN cpos%=cpos%+4:PROCproccall:ENDPROC
1660 cw$=FNname
1662 IF (cw$="LEFT" OR cw$="RIGHT" OR cw$="MID") AND FNpeek="$" THEN cpos%=cpos%+1:PROCstrsliceassign(cw$):ENDPROC
1664 IF cw$="IF" THEN PROCif:ENDPROC
1666 IF cw$="ELSE" THEN PROCelse:ENDPROC
1668 IF cw$="ENDIF" THEN PROCendif:ENDPROC
1669 IF cw$="REPEAT" OR cw$="WHILE" OR cw$="FOR" THEN PROCloop(cw$):ENDPROC
1670 IF cw$="REM" THEN cpos%=LEN(cline$)+1:ENDPROC
1672 IF cw$="UNTIL" OR cw$="ENDWHILE" OR cw$="NEXT" THEN PROCloopend(cw$):ENDPROC
1673 IF cw$="DIM" THEN PROCdim:ENDPROC
1674 IF cw$="DEF" THEN PROCdefinition:ENDPROC
1676 IF cw$="LOCAL" THEN PROClocal:ENDPROC
1678 IF cw$="ENDPROC" THEN PROCuseacts:PROCaddr("CD","$actleave"):PROCaddr("DA","$acterror"):PROCbyte(&C9):ENDPROC
1680 IF cw$="PRINT" THEN PROCprint:ENDPROC
1690 IF cw$="VDU" THEN PROCvdu:ENDPROC
1700 IF cw$="CLS" THEN PROCcharacter(12):ENDPROC
1710 IF cw$="END" THEN PROCaddr("C3","$end"):ENDPROC
1720 IF cw$="RETURN" THEN PROCaddr("C3","$return"):ENDPROC
1730 IF cw$="GOTO" OR cw$="GOSUB" THEN PROCbranch(cw$):ENDPROC
1740 IF cw$="EVAL" PROCbad("EVAL is deliberately unsupported")
1742 IF cw$="LET" THEN cw$=FNname:PROCassign(cw$):ENDPROC
1744 IF FNreserved(cw$) PROCbad("Unsupported statement "+cw$)
1750 PROCassign(cw$)
1760 ENDPROC
1770 DEF PROCbranch(cw$)
1780 LOCAL cn$
1790 PROCspace
1800 IF FNpeek="@" THEN cpos%=cpos%+1:cn$="@"+FNname ELSE cn$="#"+STR$(FNnumber(65279))
1805 cn$=FNtarget(cn$)
1810 IF cw$="GOTO" THEN PROCaddr("C3",cn$) ELSE PROCaddr("21",cn$):PROCaddr("CD","$gosub")
1820 ENDPROC
1830 DEF PROCprint
1840 LOCAL cs$,cmore%,csuppress%,cwidth%
1850 PROCspace:csuppress%=FALSE:cwidth%=10
1860 IF FNstmtend THEN PROCnewline:ENDPROC
1870 REPEAT
1872 WHILE FNpeek=";":cpos%=cpos%+1:PROCspace:csuppress%=TRUE:cwidth%=0:ENDWHILE
1874 cmore%=FALSE
1880 IF NOT FNstmtend THEN csuppress%=FALSE:PROCprintitem
1920 UNTIL NOT cmore%
1930 IF NOT csuppress% PROCnewline
1940 ENDPROC
1941 DEF PROCprintitem
1942 IF FNpeek=CHR$(34) THEN PROCprintstring ELSE PROCprintnumber
1943 PROCspace:cmore%=(FNpeek=";")
1944 ENDPROC
1945 DEF PROCprintnumber
1946 cndepth%=0:csdepth%=0:PROCexpr(1)
1947 IF cvaluekind%=1 THEN PROCprintstrvalue:ENDPROC
1948 PROCaddr("DD21","$v0"):PROCbyte(&3E):PROCbyte(cwidth%):PROCaddr("CD","$numprint")
1949 PROCaddr("DA","$numerror"):cndepth%=0:ENDPROC
1950 DEF PROCvdu
1960 LOCAL cv%,cmore%
1970 REPEAT
1980 PROCspace:cndepth%=0:PROCexpr(1):IF cvaluekind%<>0 PROCbad("Expected a numeric item")
1981 PROCnumindices(0,0)
1982 PROCnumcall(38):PROCbytes("DD7E0049D7"):cndepth%=0:PROCspace
1990 cmore%=(FNpeek=",")
2000 IF cmore% cpos%=cpos%+1
2010 UNTIL NOT cmore%
2020 ENDPROC
2030 DEF FNstring
2040 LOCAL cs$,cc$,cdone%,cquote%
2050 PROCexpect(CHR$(34)):cs$="":cdone%=FALSE
2060 REPEAT
2070 cc$=FNpeek
2080 IF cc$="" PROCbad("Unterminated string")
2090 cpos%=cpos%+1
2092 IF ASC(cc$)<32 PROCbad("Use CHR$ for control bytes in strings")
2100 cquote%=(cc$=CHR$(34))
2105 IF cquote% cdone%=(FNpeek<>CHR$(34))
2107 IF cquote% AND NOT cdone% cpos%=cpos%+1
2110 IF NOT cdone% cs$=cs$+cc$
2120 UNTIL cdone%
2130 =cs$
2140 DEF FNname
2150 LOCAL cn$
2160 PROCspace:cn$=""
2170 IF NOT FNalpha(FNpeek) PROCbad("Expected a name")
2180 WHILE FNalpha(FNpeek) OR FNdigit(FNpeek)
2190 cn$=cn$+FNpeek:cpos%=cpos%+1
2200 ENDWHILE
2210 IF LEN(cn$)>32 PROCbad("Name exceeds 32 characters")
2220 =cn$
2230 DEF FNnumber(cmax%)
2240 LOCAL cn%,cbase%,cd%,cc$,cnread%
2250 PROCspace:cn%=0:cbase%=10:cnread%=0
2260 IF FNpeek="&" THEN cbase%=16:cpos%=cpos%+1
2270 REPEAT
2280 cc$=FNpeek:cd%=-1
2290 IF cc$<>"" cd%=INSTR("0123456789ABCDEF",cc$)-1
2300 IF cd%>=cbase% cd%=-1
2310 IF cd%>=0 THEN cn%=cn%*cbase%+cd%:cpos%=cpos%+1:cnread%=cnread%+1
2320 IF cn%>cmax% PROCbad("Number outside supported range")
2330 UNTIL cd%<0
2340 IF cnread%=0 PROCbad("Expected an unsigned integer constant")
2350 =cn%
2360 DEF FNalpha(cc$)
2370 =(LEN(cc$)=1 AND INSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_",cc$)>0)
2380 DEF FNdigit(cc$)
2390 =(LEN(cc$)=1 AND INSTR("0123456789",cc$)>0)
2400 DEF FNpeek
2410 =MID$(cline$,cpos%,1)
2420 DEF PROCspace
2430 WHILE FNpeek=" " OR FNpeek=CHR$(9):cpos%=cpos%+1:ENDWHILE
2440 ENDPROC
2450 DEF PROCexpect(cc$)
2460 PROCspace
2470 IF FNpeek<>cc$ PROCbad("Expected "+cc$)
2480 cpos%=cpos%+1
2490 ENDPROC
2500 DEF FNsymbol(cn$)
2502 LOCAL clo%,chi%,cmid%,ci%,cfound%
2510 clo%=0:chi%=csnum%-1:cfound%=-1
2520 WHILE clo%<=chi% AND cfound%<0
2522 cmid%=(clo%+chi%) DIV 2:ci%=csort%(cmid%)
2530 IF csname$(ci%)=cn$ THEN cfound%=ci% ELSE IF csname$(ci%)<cn$ THEN clo%=cmid%+1 ELSE chi%=cmid%-1
2540 ENDWHILE
2542 csinsert%=clo%
2550 =cfound%
2560 DEF PROClabel(cn$)
2562 LOCAL ci%
2570 IF FNsymbol(cn$)>=0 PROCbad("Duplicate target "+cn$)
2580 IF csnum%=1024 PROCbad("Too many labels")
2582 IF csnum%>csinsert% THEN FOR ci%=csnum%-1 TO csinsert% STEP -1:csort%(ci%+1)=csort%(ci%):NEXT
2584 csort%(csinsert%)=csnum%
2590 csname$(csnum%)=cn$:csaddr%(csnum%)=&40000+cpc%:csnum%=csnum%+1
2600 ENDPROC
2610 DEF PROCaddr(ch$,cn$)
2620 IF ch$<>"" PROCbytes(ch$)
2630 IF crnum%=4096 PROCbad("Too many address fixups")
2640 crname$(crnum%)=cn$:craddr%(crnum%)=cpc%
2650 crline%(crnum%)=clnum%:crcol%(crnum%)=cpos%:crnum%=crnum%+1
2660 PROCbyte(0):PROCbyte(0):PROCbyte(0)
2670 ENDPROC
2680 DEF PROCpatch(cp%,cv%)
2690 LOCAL ci%
2700 FOR ci%=0 TO 2:ccode%?(cp%+ci%)=cv% MOD 256:cv%=cv% DIV 256:NEXT
2710 ENDPROC
2720 DEF PROCbyte(cv%)
2730 IF cpc%=65536 PROCbad("Executable exceeds 65536 bytes")
2740 ccode%?cpc%=cv%:cpc%=cpc%+1
2750 ENDPROC
2760 DEF PROCbytes(ch$)
2770 LOCAL ci%,ca%,cb%
2780 FOR ci%=1 TO LEN(ch$) STEP 2
2790 ca%=INSTR("0123456789ABCDEF",MID$(ch$,ci%,1))-1
2800 cb%=INSTR("0123456789ABCDEF",MID$(ch$,ci%+1,1))-1
2810 PROCbyte(ca%*16+cb%)
2820 NEXT
2830 ENDPROC
2840 DEF PROCcharacter(cv%)
2850 PROCbyte(&3E):PROCbyte(cv%):PROCbytes("49D7")
2860 ENDPROC
2870 DEF PROCnewline
2880 PROCcharacter(13):PROCcharacter(10)
2890 ENDPROC
2900 DEF PROCtext(cs$)
2910 LOCAL ci%
2915 IF cs$="" ENDPROC
2920 PROCaddr("CD","$print"):PROCbyte(LEN(cs$))
2930 FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT
2940 ENDPROC
2950 DEF PROCruntime
2960 PROClabel("$print")
2970 REM pop hl; ld bc,0; ld c,(hl); inc hl; push hl; add hl,bc
2980 REM ex (sp),hl; ld a,c; or a; ret z; rst.lis 18h; ret
2990 PROCbytes("E1010000004E23E509E379B7C849DFC9")
3000 PROClabel("$gosub")
3010 PROCaddr("3A","$depth"):PROCbytes("FEFF")
3020 PROCaddr("CA","$full"):PROCbytes("3C")
3025 IF cloops% THEN PROCbytes("F5E53E04"):PROCaddr("CD","$ctlpush"):PROCbyte(&E1):PROCaddr("DA","$flowerror"):PROCbyte(&F1)
3030 PROCaddr("32","$depth"):PROCbytes("E9")
3040 PROClabel("$return")
3050 PROCaddr("3A","$depth"):PROCbytes("B7")
3060 PROCaddr("CA","$badreturn"):PROCbytes("3D")
3065 IF cloops% THEN PROCbyte(&F5):PROCflowcheck(4):PROCaddr("CD","$ctlpop"):PROCbyte(&F1)
3070 PROCaddr("32","$depth"):PROCbytes("C9")
3080 PROClabel("$badreturn")
3090 PROCtext("No GOSUB"):PROCnewline
3100 PROCaddr("C3","$error")
3110 PROClabel("$full")
3120 PROCtext("Too many GOSUBs"):PROCnewline
3130 PROClabel("$error")
3140 PROCbytes("21010000"):PROCaddr("C3","$exit")
3150 PROClabel("$end")
3160 PROCbytes("21000000")
3170 PROClabel("$exit")
3180 REM ADL24 OK: saved SP is a three-byte address, not a BASIC integer.
3190 PROCaddr("ED7B","$savedsp")
3200 PROCbytes("FDE1DDE1D1C1F1C9")
3210 PROClabel("$savedsp"):PROCbytes("000000")
3220 PROClabel("$depth"):PROCbyte(0)
3222 IF cnumeric% PROCnumruntime
3224 IF cvnum%>0 PROCvarruntime
3225 IF cloops% PROCflowruntime
3226 IF cacts% PROCactruntime
3227 IF cstrings% PROCstrruntime
3228 IF cmemory% PROCmemoryruntime
3229 IF cmemory% PROCmemoryworkspace
3230 IF cacts% PROCactworkspace
3232 ENDPROC
3240 DEF PROCbad(cm$)
3250 ERROR 100,LEFT$(csource$,80)+":"+STR$(clnum%)+":"+STR$(cpos%)+": "+LEFT$(cm$,130)
3260 ENDPROC
4000 DEF PROCloadnumbers
4010 LOCAL ci%,cj%,cs$,ca%,cb%
4020 RESTORE 20000:READ cnsize%,cnrelocs%,cnentry%,cnliteral%,cnnegate%,cnprintnum%,cnval%,cnstrnum%,cnstrhex%
4030 DIM cnimage% cnsize%-1,cnreloc%(cnrelocs%-1)
4040 FOR ci%=0 TO cnsize%-1 STEP 40
4050 READ cs$
4060 FOR cj%=1 TO LEN(cs$) STEP 2
4062 ca%=INSTR("0123456789ABCDEF",MID$(cs$,cj%,1))-1
4064 cb%=INSTR("0123456789ABCDEF",MID$(cs$,cj%+1,1))-1
4070 cnimage%?(ci%+(cj%-1) DIV 2)=ca%*16+cb%
4080 NEXT:NEXT
4090 FOR ci%=0 TO cnrelocs%-1:READ cnreloc%(ci%):NEXT
4100 ENDPROC
4110 DEF PROCnumslot
4120 IF cndepth%=32 PROCbad("Expression value stack exceeds 32")
4130 cndepth%=cndepth%+1:cnumeric%=TRUE
4140 IF cndepth%>cnslots% cnslots%=cndepth%
4150 ENDPROC
4160 DEF PROCvalue(cv)
4170 LOCAL ci%,cp%
4180 PROCnumslot:cvaluekind%=0:PROCaddr("DD21","$v"+STR$(cndepth%-1))
4190 PROCaddr("CD","$numlit"):cp%=^cv
4200 FOR ci%=0 TO 4:PROCbyte(cp%?ci%):NEXT
4210 ENDPROC
4220 DEF PROCnumindices(cl%,cr%)
4230 PROCaddr("DD21","$v"+STR$(cl%)):PROCaddr("FD21","$v"+STR$(cr%))
4240 ENDPROC
4250 DEF PROCnumcall(co%)
4260 PROCbyte(&3E):PROCbyte(co%):PROCaddr("CD","$numop")
4270 PROCaddr("DA","$numerror")
4280 ENDPROC
4290 DEF PROCbinary(co%)
4300 PROCnumindices(cndepth%-2,cndepth%-1):PROCnumcall(co%)
4310 cndepth%=cndepth%-1
4320 ENDPROC
4330 DEF PROCexpr(cmin%)
4340 LOCAL cp%,co%,cw%,cdone%,crel%,ctype%,cframe%
4350 cframe%=1:IF FNstringstart cframe%=0
4352 cnparse%=cnparse%+cframe%:IF cnparse%>32 PROCbad("Expression nesting exceeds 32")
4360 PROCitem:ctype%=cvaluekind%:cdone%=FALSE:crel%=FALSE
4370 REPEAT
4380 co%=FNoperator:cp%=cnprec%:cw%=cnwidth%
4390 IF co%<0 OR cp%<cmin% THEN cdone%=TRUE ELSE PROCexprtail
4400 UNTIL cdone%
4410 cnparse%=cnparse%-cframe%
4420 ENDPROC
4430 DEF PROCexprtail
4440 IF cp%=3 AND crel% PROCbad("Chained comparisons require parentheses")
4450 IF cp%=3 crel%=TRUE
4460 cpos%=cpos%+cw%:PROCexpr(cp%+1):PROCtypedbinary:ctype%=cvaluekind%
4470 ENDPROC
4480 DEF FNoperator
4490 LOCAL cs$,co%
4500 PROCspace:cnprec%=0:cnwidth%=0:cs$=MID$(cline$,cpos%,3)
4510 IF LEFT$(cs$,2)="<<" OR LEFT$(cs$,2)=">>" PROCbad("Shift operators are unsupported")
4520 co%=-1
4530 IF LEFT$(cs$,3)="EOR" THEN co%=2:cnprec%=1:cnwidth%=3
4540 IF LEFT$(cs$,2)="OR" THEN co%=4:cnprec%=1:cnwidth%=2
4550 IF LEFT$(cs$,3)="AND" THEN co%=0:cnprec%=2:cnwidth%=3
4560 IF LEFT$(cs$,2)="<=" THEN co%=5:cnprec%=3:cnwidth%=2
4570 IF LEFT$(cs$,2)="<>" THEN co%=6:cnprec%=3:cnwidth%=2
4580 IF LEFT$(cs$,2)=">=" THEN co%=7:cnprec%=3:cnwidth%=2
4590 IF co%>=0 THEN =co%
4600 IF LEFT$(cs$,1)="<" THEN co%=8:cnprec%=3:cnwidth%=1
4610 IF LEFT$(cs$,1)="=" THEN co%=9:cnprec%=3:cnwidth%=1
4620 IF LEFT$(cs$,1)=">" THEN co%=12:cnprec%=3:cnwidth%=1
4630 IF LEFT$(cs$,1)="+" THEN co%=11:cnprec%=4:cnwidth%=1
4640 IF LEFT$(cs$,1)="-" THEN co%=13:cnprec%=4:cnwidth%=1
4650 IF LEFT$(cs$,1)="*" THEN co%=10:cnprec%=5:cnwidth%=1
4660 IF LEFT$(cs$,1)="/" THEN co%=15:cnprec%=5:cnwidth%=1
4670 IF LEFT$(cs$,3)="DIV" THEN co%=1:cnprec%=5:cnwidth%=3
4680 IF LEFT$(cs$,3)="MOD" THEN co%=3:cnprec%=5:cnwidth%=3
4690 IF LEFT$(cs$,1)="^" THEN co%=14:cnprec%=6:cnwidth%=1
4700 =co%
4710 DEF PROCitem
4720 LOCAL cc$,cdone%
4730 cnparse%=cnparse%+1:IF cnparse%>32 PROCbad("Expression nesting exceeds 32")
4740 PROCspace:cc$=FNpeek:cdone%=FALSE:cvaluekind%=0
4750 IF cc$="+" OR cc$="-" THEN cpos%=cpos%+1:PROCitem:PROCneednumber:cdone%=TRUE
4760 IF cc$="-" THEN PROCaddr("DD21","$v"+STR$(cndepth%-1)):PROCaddr("CD","$numneg")
4770 IF cc$="(" THEN cpos%=cpos%+1:PROCexpr(1):PROCexpect(")"):cdone%=TRUE
4780 IF cc$="&" OR cc$="." OR FNdigit(cc$) THEN PROCconstant:cdone%=TRUE
4782 IF NOT cdone% THEN IF cc$="^" OR cc$="?" OR cc$="!" OR cc$="|" THEN PROCmemitem(cc$):cdone%=TRUE
4785 IF NOT cdone% AND MID$(cline$,cpos%,2)="FN" THEN cpos%=cpos%+2:PROCfncall:cdone%=TRUE
4790 IF NOT cdone% PROCtypeditem
4800 cnparse%=cnparse%-1
4810 ENDPROC
4820 DEF PROCworditem
4830 LOCAL cw$,ci%,cf%,cl%
4832 cf%=-1
4833 FOR ci%=0 TO 15
4834 cw$=MID$("ABSACSASNATNCOSDEGEXPINTLN LOGNOTRADSGNSINSQRTAN",ci%*3+1,3)
4835 IF RIGHT$(cw$,1)=" " cw$=LEFT$(cw$,2)
4836 cl%=LEN(cw$)
4837 IF MID$(cline$,cpos%,cl%)=cw$ AND NOT FNalpha(MID$(cline$,cpos%+cl%,1)) cf%=ci%+16
4838 IF cf%>=0 ci%=15
4839 NEXT
4840 IF cf%>=0 THEN cpos%=cpos%+cl%:PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(cf%):ENDPROC
4842 IF NOT FNalpha(FNpeek) PROCbad("Expected a numeric item")
4850 cw$=FNname
4860 IF cw$="TRUE" THEN PROCvalue(-1):ENDPROC
4870 IF cw$="FALSE" THEN PROCvalue(0):ENDPROC
4872 IF cw$="LEN" THEN PROCstrlen:ENDPROC
4874 IF cw$="VAL" THEN PROCstrval:ENDPROC
4876 IF cw$="ASC" THEN PROCstrasc:ENDPROC
4878 IF cw$="INSTR" THEN PROCstrinstr:ENDPROC
4880 IF cw$="PI" THEN PROCvalue(0):PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(35):ENDPROC
4890 IF cw$="EVAL" PROCbad("EVAL is deliberately unsupported")
4892 IF FNreserved(cw$) PROCbad("Unsupported numeric item "+cw$)
4900 PROCvariable(cw$)
4910 ENDPROC
4920 DEF PROCconstant
4930 IF FNpeek<>"&" THEN PROCdecimal:ENDPROC
4940 LOCAL cv,cd%,cc$,cn%
4950 cv=0:cn%=0:cpos%=cpos%+1
4960 REPEAT
4970 cc$=FNpeek:cd%=-1
4980 IF cc$<>"" cd%=INSTR("0123456789ABCDEF",cc$)-1
4990 IF cd%>=0 THEN cv=cv*16+cd%:cn%=cn%+1:cpos%=cpos%+1
5000 IF cn%>8 PROCbad("Hex literal exceeds eight digits")
5020 UNTIL cd%<0
5030 IF cn%=0 PROCbad("Expected digits in numeric literal")
5050 PROCpacked(cv,0)
5100 ENDPROC
5101 DEF PROCdecimal
5102 LOCAL cs%,cv
5103 cs%=cpos%
5104 WHILE FNdigit(FNpeek):cpos%=cpos%+1:ENDWHILE
5105 IF FNpeek="." THEN cpos%=cpos%+1:WHILE FNdigit(FNpeek):cpos%=cpos%+1:ENDWHILE
5106 IF FNpeek="E" AND MID$(cline$,cpos%,3)<>"EOR" PROCdecexponent
5107 cnumerr%=0:cv=FNreaddecimal(MID$(cline$,cs%,cpos%-cs%)):PROCvalue(cv)
5108 IF cnumerr%<>0 THEN PROCbyte(&3E):PROCbyte(cnumerr%):PROCaddr("C3","$numerror")
5109 ENDPROC
5110 DEF PROCdecexponent
5111 cpos%=cpos%+1
5112 WHILE FNpeek=" ":cpos%=cpos%+1:ENDWHILE
5113 IF FNpeek="+" OR FNpeek="-" cpos%=cpos%+1
5114 WHILE FNdigit(FNpeek):cpos%=cpos%+1:ENDWHILE
5115 IF FNalpha(FNpeek) PROCbad("Unsupported crunched text after exponent")
5116 ENDPROC
5120 DEF FNreaddecimal(cs$)
5121 LOCAL ERROR
5122 ON ERROR LOCAL cnumerr%=ERR:=0
5123 =VAL(cs$)
5184 DEF PROCpacked(cv,ce%)
5185 LOCAL ci%,cq
5186 PROCnumslot:PROCaddr("DD21","$v"+STR$(cndepth%-1)):PROCaddr("CD","$numlit")
5187 FOR ci%=0 TO 3
5188 cq=INT(cv/256):PROCbyte(cv-cq*256):cv=cq
5189 NEXT:PROCbyte(ce%)
5190 ENDPROC
5192 DEF PROCnumruntime
5194 LOCAL ci%,cp%,cv%,cbase%,cn$,cm$
5200 cbase%=cpc%
5202 IF cpc%+cnsize%>65536 PROCbad("Executable exceeds 65536 bytes")
5210 FOR ci%=0 TO cnsize%-1:ccode%?(cbase%+ci%)=cnimage%?ci%:NEXT:cpc%=cpc%+cnsize%
5220 FOR ci%=0 TO cnrelocs%-1
5230 cp%=cbase%+cnreloc%(ci%)
5240 cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2)
5250 PROCpatch(cp%,cv%+&40000+cbase%)
5260 NEXT
5270 PROClabel("$numop"):csaddr%(csnum%-1)=&40000+cbase%+cnentry%
5280 PROClabel("$numlit"):csaddr%(csnum%-1)=&40000+cbase%+cnliteral%
5290 PROClabel("$numneg"):csaddr%(csnum%-1)=&40000+cbase%+cnnegate%
5292 PROClabel("$numprint"):csaddr%(csnum%-1)=&40000+cbase%+cnprintnum%
5294 PROClabel("$numval"):csaddr%(csnum%-1)=&40000+cbase%+cnval%
5296 PROClabel("$numstr"):csaddr%(csnum%-1)=&40000+cbase%+cnstrnum%
5298 PROClabel("$numhex"):csaddr%(csnum%-1)=&40000+cbase%+cnstrhex%
5300 FOR ci%=0 TO cnslots%-1
5310 PROClabel("$v"+STR$(ci%)):PROCbytes("0000000000")
5320 NEXT
5330 PROClabel("$numerror")
5340 FOR ci%=0 TO 5
5350 PROCbytes("FE"):PROCbyte(18+ci%+ABS(ci%>0))
5360 PROCaddr("CA","$ne"+STR$(ci%))
5370 NEXT
5380 PROCtext("Numeric error"):PROCnewline:PROCaddr("C3","$error")
5390 FOR ci%=0 TO 5
5400 PROClabel("$ne"+STR$(ci%))
5410 cm$=MID$("Division by zero Number too big   -ve root         Log range        Accuracy lost    Exponent range   ",ci%*17+1,17)
5420 WHILE RIGHT$(cm$,1)=" ":cm$=LEFT$(cm$,LEN(cm$)-1):ENDWHILE
5430 PROCtext(cm$):PROCnewline:PROCaddr("C3","$error")
5440 NEXT
5450 ENDPROC
6000 DEF FNvariable(cn$)
6010 LOCAL ci%,cf%,ct%,cs%,cw%
6020 ct%=5:cs%=FALSE
6030 IF FNpeek="%" THEN ct%=4:cs%=(LEN(cn$)=1 AND INSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ",cn$)>0)
6040 IF FNpeek="&" ct%=1
6042 IF FNpeek="$" ct%=129
6044 IF ct%=129 AND FNstrreserved(cn$) PROCbad("Unsupported string item "+cn$)
6050 IF ct%<>5 THEN cn$=cn$+FNpeek:cpos%=cpos%+1
6060 IF FNpeek="$" PROCbad("Unsupported string suffix")
6070 IF FNpeek="(" THEN cn$=cn$+"(":ct%=ct%+256:cs%=FALSE
6080 IF FNpeek="%" OR FNpeek="&" OR FNpeek="#" PROCbad("Unsupported numeric suffix")
6090 IF FNpeek="|" PROCbad("Binary variant indirection is unsupported")
6100 cf%=-1:ci%=0
6102 WHILE ci%<cvnum%
6104 IF cvname$(ci%)=cn$ cf%=ci%
6106 ci%=ci%+1
6110 ENDWHILE
6120 IF cf%>=0 THEN =cf%
6130 IF cvnum%=256 PROCbad("Variable limit exceeds 256")
6140 cw%=ct% AND 255:IF cw%=129 THEN cw%=5:cstrings%=TRUE:csvars%=csvars%+1
6141 IF ct%>255 cw%=3
6142 cf%=cvnum%:cvname$(cf%)=cn$:cvsize%(cf%)=cw%:cvtype%(cf%)=ct%:cvstatic%(cf%)=cs%:cvdim%(cf%)=0:cvnum%=cvnum%+1
6150 =cf%
6160 DEF PROCassign(cn$)
6170 LOCAL ci%,ct%
6180 IF FNreserved(cn$) PROCbad("Unsupported variable name "+cn$)
6190 ci%=FNvariable(cn$):ct%=cvtype%(ci%)
6191 IF ct%>255 THEN PROCarrayassign(ci%):ENDPROC
6192 IF FNpeek="?" OR FNpeek="!" THEN PROCindirectassign(ci%):ENDPROC
6193 PROCexpect("=")
6194 IF ct%=129 THEN PROCstrassign(ci%):ENDPROC
6200 REM ASSIGN creates a missing destination before the RHS is evaluated.
6210 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%))
6220 cndepth%=0:PROCexpr(1):PROCneednumber
6230 IF ct%<>5 THEN PROCnumindices(0,0):PROCnumcall(38)
6240 PROCvarcopy("$v0","$var"+STR$(ci%),ct%):cndepth%=0
6250 ENDPROC
6260 DEF PROCvariable(cn$)
6270 LOCAL ci%:ci%=FNvariable(cn$)
6280 IF cvtype%(ci%)>255 THEN PROCarrayread(ci%):ENDPROC
6290 PROCreadscalar(ci%):PROCmemtail
6330 ENDPROC
6340 DEF PROCvarcopy(cf$,ct$,cn%)
6350 PROCaddr("21",cf$):PROCaddr("11",ct$)
6360 PROCbyte(&01):PROCbyte(cn%):PROCbytes("0000EDB0")
6370 ENDPROC
6380 DEF PROCvarruntime
6390 LOCAL ci%,cj%
6400 PROClabel("$novar"):PROCtext("No such variable"):PROCnewline:PROCaddr("C3","$error")
6410 FOR ci%=0 TO cvnum%-1
6420 PROClabel("$bind"+STR$(ci%)):PROCbyte(ABS(cvstatic%(ci%)))
6430 PROClabel("$var"+STR$(ci%)):FOR cj%=1 TO cvsize%(ci%):PROCbyte(0):NEXT
6440 NEXT
6450 ENDPROC
6460 DEF PROCkeywords:LOCAL ci%
6461 FOR ci%=0 TO 4:ckwords$(ci%)="~|":NEXT
6462 ckwords$(0)="AND|ABS|ACS|ADVAL|ASC|ASN|ATN|BGET!|BPUT!|BY!|COLOUR|COLOR|CALL|CASE|CHAIN|CLEAR!|CLOSE!|CLG!|CLS!|COS|COUNT!|CIRCLE|DATA|DEG|DEF|DIV|DIM|DRAW|ENDPROC!|ENDWHILE!|ENDCASE!|ENDIF!|END!|ENVELOPE|ELSE|EVAL|ERL!|"
6464 ckwords$(1)="ERROR|EOF!|EOR|ERR!|EXIT!|EXP|EXT!|ELLIPSE|FOR|FALSE!|FILL|FN|GOTO|GET|GOSUB|GCOL|HIMEM|INPUT|INSTR|IF|INKEY|INT|INSTALL|LINE|LOMEM|LOCAL|LEN|LET|LOG|LN|MODE|MOD|MOVE|MOUSE|NEXT|NOT|ON|OFF!|OF!|ORIGIN|OR|OPENIN|"
6466 ckwords$(2)="OPENOUT|OPENUP|OSCLI|OTHERWISE|PRINT|PAGE|PTR|PI!|PLOT|POINT!|PROC|POS!|PUT|QUIT!|RETURN!|REPEAT|REPORT!|READ|REM|RUN!|RAD|RESTORE|RND!|RECTANGLE|STEP|SGN|SIN|SQR|SPC|SOUND|STOP!|SUM|SWAP|SYS|TAN|THEN|TIME|"
6468 ckwords$(3)="TO|TRACE|TRUE!|UNTIL|USR|VDU|VAL|VPOS!|WHILE|WHEN|WAIT!|WIDTH|"
6480 ENDPROC
6500 DEF FNreserved(cn$)
6510 LOCAL ck$,ci%,cj%,cw$,cb%,ck%,cf%
6512 IF ASC(cn$)<65 OR ASC(cn$)>90 THEN =FALSE
6514 cf%=FALSE
6520 FOR ck%=0 TO 4
6530 ck$=ckwords$(ck%):ci%=1
6540 REPEAT
6550 cj%=INSTR(ck$,"|",ci%):cw$=MID$(ck$,ci%,cj%-ci%):cb%=(RIGHT$(cw$,1)="!")
6560 IF cb% cw$=LEFT$(cw$,LEN(cw$)-1)
6570 IF LEFT$(cn$,LEN(cw$))=cw$ AND (NOT cb% OR LEN(cn$)=LEN(cw$)) cf%=TRUE
6580 ci%=cj%+1
6590 UNTIL ci%>LEN(ck$)
6600 NEXT
6610 =cf%
7000 DEF PROCloadstrings
7010 LOCAL ci%,cj%,cs$,ca%,cb%
7020 RESTORE 30000:READ cssize%,csrelocs%,csliteral%,csload%,cscat%,csstore%,csprint%,csleft%,csright%,csmid%,cscmp%,csinstr%,csrepeat%,cswrite%,cscopy%
7030 DIM csimage% cssize%-1,csreloc%(csrelocs%)
7040 FOR ci%=0 TO cssize%-1 STEP 40
7050 READ cs$
7060 FOR cj%=1 TO LEN(cs$) STEP 2
7070 ca%=INSTR("0123456789ABCDEF",MID$(cs$,cj%,1))-1:cb%=INSTR("0123456789ABCDEF",MID$(cs$,cj%+1,1))-1
7080 csimage%?(ci%+(cj%-1) DIV 2)=ca%*16+cb%:NEXT:NEXT
7090 IF csrelocs%>0 THEN FOR ci%=0 TO csrelocs%-1:READ csreloc%(ci%):NEXT
7100 ENDPROC
7110 DEF FNstringstart
7120 LOCAL cp%,cc$
7130 cp%=cpos%
7140 WHILE MID$(cline$,cp%,1)=" " OR MID$(cline$,cp%,1)=CHR$(9) OR MID$(cline$,cp%,1)="(":cp%=cp%+1:ENDWHILE
7150 cc$=MID$(cline$,cp%,1)
7155 IF MID$(cline$,cp%,2)="FN" THEN =FNfnstring(cp%)
7160 IF cc$=CHR$(34) OR MID$(cline$,cp%,4)="CHR$" THEN =TRUE
7170 WHILE FNalpha(MID$(cline$,cp%,1)) OR FNdigit(MID$(cline$,cp%,1)):cp%=cp%+1:ENDWHILE
7180 =(MID$(cline$,cp%,1)="$")
7190 DEF PROCprintstring
7200 LOCAL cp%,cs$
7210 cp%=cpos%
7220 IF FNpeek<>CHR$(34) THEN PROCprintnumber:ENDPROC
7230 cs$=FNstring:PROCspace
7240 IF FNstmtend OR FNpeek=";" THEN PROCtext(cs$):ENDPROC
7250 cpos%=cp%:PROCprintnumber
7260 ENDPROC
7270 DEF PROCprintstrvalue
7280 PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCaddr("CD","$strprint"):csdepth%=csdepth%-1
7290 ENDPROC
7300 DEF PROCstrslot
7310 IF csdepth%=16 PROCbad("String temporary limit exceeds 16")
7320 csdepth%=csdepth%+1:cstrings%=TRUE
7322 IF csdepth%>csslots% csslots%=csdepth%
7324 csunsafe%(csdepth%-1)=FALSE
7330 ENDPROC
7340 DEF PROCstrexpr
7350 PROCexpr(1):IF cvaluekind%<>1 PROCbad("Expected a string item")
7410 ENDPROC
7420 DEF PROCstritem
7430 PROCitem:IF cvaluekind%<>1 PROCbad("Expected a string item")
7440 ENDPROC
7460 DEF PROCstratom
7470 LOCAL cs$,ci%,cj%
7480 IF FNpeek="(" THEN cpos%=cpos%+1:PROCstrexpr:PROCexpect(")"):ENDPROC
7490 IF MID$(cline$,cpos%,4)="CHR$" THEN cpos%=cpos%+4:PROCstrchr:ENDPROC
7491 IF MID$(cline$,cpos%,4)="STR$" THEN cpos%=cpos%+4:PROCstrnum:ENDPROC
7492 IF MID$(cline$,cpos%,5)="LEFT$" THEN cpos%=cpos%+5:PROCslice(0):ENDPROC
7494 IF MID$(cline$,cpos%,6)="RIGHT$" THEN cpos%=cpos%+6:PROCslice(1):ENDPROC
7496 IF MID$(cline$,cpos%,4)="MID$" THEN cpos%=cpos%+4:PROCslice(2):ENDPROC
7498 IF MID$(cline$,cpos%,7)="STRING$" THEN cpos%=cpos%+7:PROCstrrepeat:ENDPROC
7500 IF FNpeek=CHR$(34) THEN PROCstrliteral:ENDPROC
7510 IF NOT FNalpha(FNpeek) PROCbad("Expected a string item")
7520 cs$=FNname:IF FNreserved(cs$) PROCbad("Unsupported string item "+cs$)
7530 ci%=FNvariable(cs$)
7532 IF cvtype%(ci%)>255 THEN PROCarrayread(ci%):ENDPROC
7534 IF cvtype%(ci%)<>129 PROCbad("Expected a string variable")
7540 PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
7550 PROCstrslot:PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCaddr("FD21","$var"+STR$(ci%)):PROCaddr("CD","$strload")
7560 ENDPROC
7570 DEF PROCstrliteral
7580 LOCAL cs$,ci%
7590 cs$=FNstring:PROCstrslot:PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCaddr("CD","$strlit")
7600 PROCbyte(LEN(cs$)):IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT
7610 ENDPROC
7620 DEF PROCstrchr
7630 PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38):PROCstrslot
7640 PROCaddr("21","$s"+STR$(csdepth%-1)):PROCbytes("360123")
7650 PROCaddr("3A","$v"+STR$(cndepth%-1)):PROCbyte(&77):cndepth%=cndepth%-1
7660 ENDPROC
7670 DEF PROCstrlen
7680 PROCstritem:PROCvalue(0)
7690 PROCaddr("3A","$s"+STR$(csdepth%-1)):PROCaddr("32","$v"+STR$(cndepth%-1)):csdepth%=csdepth%-1
7700 ENDPROC
7710 DEF PROCstrassign(ci%)
7720 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCstrexpr
7730 PROCaddr("DD21","$var"+STR$(ci%)):PROCaddr("FD21","$s"+STR$(csdepth%-1)):PROCaddr("21","$sheapctx")
7740 PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):csdepth%=csdepth%-1
7750 ENDPROC
7760 DEF PROCstrruntime
7770 LOCAL ci%,cj%,cp%,cv%,cbase%
7780 cbase%=cpc%
7790 FOR ci%=0 TO cssize%-1:PROCbyte(csimage%?ci%):NEXT
7800 IF csrelocs%>0 THEN FOR ci%=0 TO csrelocs%-1:PROCstrrelocate(cbase%,ci%):NEXT
7810 PROClabel("$strlit"):csaddr%(csnum%-1)=&40000+cbase%+csliteral%
7820 PROClabel("$strload"):csaddr%(csnum%-1)=&40000+cbase%+csload%
7830 PROClabel("$strcat"):csaddr%(csnum%-1)=&40000+cbase%+cscat%
7840 PROClabel("$strstore"):csaddr%(csnum%-1)=&40000+cbase%+csstore%
7850 PROClabel("$strprint"):csaddr%(csnum%-1)=&40000+cbase%+csprint%
7852 PROClabel("$strleft"):csaddr%(csnum%-1)=&40000+cbase%+csleft%
7854 PROClabel("$strright"):csaddr%(csnum%-1)=&40000+cbase%+csright%
7856 PROClabel("$strmid"):csaddr%(csnum%-1)=&40000+cbase%+csmid%
7858 PROClabel("$strcmp"):csaddr%(csnum%-1)=&40000+cbase%+cscmp%
7859 PROClabel("$strinstr"):csaddr%(csnum%-1)=&40000+cbase%+csinstr%
7860 PROClabel("$strrepeat"):csaddr%(csnum%-1)=&40000+cbase%+csrepeat%
7861 PROClabel("$strwrite"):csaddr%(csnum%-1)=&40000+cbase%+cswrite%
7862 PROClabel("$strerror"):PROCbytes("FE13"):PROCaddr("CA","$strlong")
7863 PROClabel("$strcopy"):csaddr%(csnum%-1)=&40000+cbase%+cscopy%
7870 PROCtext("No room"):PROCnewline:PROCaddr("C3","$error")
7880 PROClabel("$strlong"):PROCtext("String too long"):PROCnewline:PROCaddr("C3","$error")
7890 FOR ci%=0 TO csslots%-1
7900 PROClabel("$s"+STR$(ci%)):FOR cj%=0 TO 255:PROCbyte(0):NEXT
7910 NEXT
7920 IF NOT cmemory% THEN PROClabel("$sheapctx"):PROCaddr("","$sheap"):PROCaddr("","$sheapend")
7930 IF NOT cmemory% THEN PROClabel("$sheap"):PROClabel("$sheapend"):csaddr%(csnum%-1)=csaddr%(csnum%-1)+1024*csvars%
7940 IF NOT cmemory% AND csaddr%(csnum%-1)>&B0000 PROCbad("String workspace exceeds user RAM")
7950 ENDPROC
7960 DEF PROCstrrelocate(cb%,ci%)
7970 LOCAL cp%,cv%
7980 cp%=cb%+csreloc%(ci%):cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2)
7990 PROCpatch(cp%,cv%+&40000+cb%)
8000 ENDPROC
8010 DEF FNstrreserved(cn$)
8020 =(INSTR("|CHR|STR|STRING|LEFT|RIGHT|MID|GET|INKEY|","|"+cn$+"|")>0)
8100 DEF PROCneednumber
8110 IF cvaluekind%<>0 PROCbad("String value used as a numeric item")
8120 ENDPROC
8130 DEF PROCtypedbinary
8140 IF ctype%<>cvaluekind% PROCbad("Numeric/string type mismatch")
8150 IF ctype%=0 THEN PROCbinary(co%):ENDPROC
8160 IF cp%=3 THEN PROCstrcompare(co%):ENDPROC
8170 IF co%<>11 PROCbad("Only concatenation and comparisons support strings")
8180 PROCaddr("DD21","$s"+STR$(csdepth%-2)):PROCaddr("FD21","$s"+STR$(csdepth%-1))
8190 PROCaddr("CD","$strcat"):PROCaddr("DA","$strerror"):csdepth%=csdepth%-1:cvaluekind%=1
8195 csunsafe%(csdepth%-1)=FALSE
8200 ENDPROC
8210 DEF PROCstrcompare(co%)
8220 LOCAL cc%,cj%
8230 PROCvalue(0):PROCaddr("DD21","$s"+STR$(csdepth%-2)):PROCaddr("FD21","$s"+STR$(csdepth%-1))
8240 PROCaddr("CD","$strcmp"):cc%=0:cj%=&28
8250 IF co%=6 cj%=&20
8260 IF co%=8 OR co%=7 cc%=255
8270 IF co%=12 OR co%=5 cc%=1
8280 IF co%=5 OR co%=7 cj%=&20
8290 PROCbyte(&FE):PROCbyte(cc%):PROCbyte(cj%):PROCbytes("03AF18023EFF")
8300 PROCaddr("21","$v"+STR$(cndepth%-1)):PROCbytes("77237723772377")
8310 csdepth%=csdepth%-2:cvaluekind%=0:ENDPROC
8320 DEF PROCslice(ct%)
8330 LOCAL ci%,cr$
8340 PROCexpect("("):PROCstrexpr:ci%=csdepth%-1:PROCspace
8350 IF ct%=2 THEN PROCexpect(","):PROCcount:PROCaddr("DD21","$s"+STR$(ci%)):PROCaddr("CD","$strmid"):PROCspace:csunsafe%(ci%)=FALSE
8360 IF FNpeek="," THEN cpos%=cpos%+1:PROCcount:PROCslicecount(ct%,ci%):PROCexpect(")"):csunsafe%(ci%)=FALSE:ENDPROC
8370 PROCexpect(")"):PROCaddr("DD21","$s"+STR$(ci%))
8375 IF ct%=1 AND csunsafe%(ci%) PROCbad("Omitted RIGHT$ on a FN string result is unqualified; use an explicit count")
8380 IF ct%=0 PROCbytes("DD7E00B728043DDD7700")
8390 IF ct%=1 THEN PROCbytes("3E01"):PROCaddr("CD","$strright")
8400 ENDPROC
8410 DEF PROCcount
8420 PROCexpr(1):PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
8430 PROCaddr("3A","$v"+STR$(cndepth%-1)):cndepth%=cndepth%-1:ENDPROC
8440 DEF PROCslicecount(ct%,ci%)
8450 LOCAL cr$:cr$="$strleft":IF ct%=1 cr$="$strright"
8460 PROCaddr("DD21","$s"+STR$(ci%)):PROCaddr("CD",cr$):ENDPROC
8470 DEF PROCtypeditem
8480 IF FNstringstart THEN PROCstratom:cvaluekind%=1:ENDPROC
8490 PROCworditem:ENDPROC
8500 DEF PROCstrval
8510 PROCstritem:PROCvalue(0)
8520 PROCaddr("DD21","$v"+STR$(cndepth%-1)):PROCaddr("FD21","$s"+STR$(csdepth%-1))
8530 PROCaddr("CD","$numval"):PROCaddr("DA","$numerror"):csdepth%=csdepth%-1:cvaluekind%=0:ENDPROC
8540 DEF PROCstrnum
8550 LOCAL cr$:cr$="$numstr":PROCspace
8560 IF FNpeek="~" THEN cpos%=cpos%+1:cr$="$numhex"
8570 PROCitem:PROCneednumber:PROCstrslot
8580 PROCaddr("DD21","$v"+STR$(cndepth%-1)):PROCaddr("FD21","$s"+STR$(csdepth%-1))
8590 PROCaddr("CD",cr$):PROCaddr("DA","$numerror"):cndepth%=cndepth%-1:ENDPROC
8600 DEF PROCstrasc
8610 PROCstritem:PROCvalue(-1)
8620 PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCbytes("DD7E00B7280FDD7E01")
8630 PROCaddr("21","$v"+STR$(cndepth%-1)):PROCbytes("7723AF7723772377")
8640 csdepth%=csdepth%-1:cvaluekind%=0:ENDPROC
8700 DEF PROCstrinstr
8710 LOCAL cm%,cn%,cv%
8720 PROCexpect("("):PROCstrexpr:cm%=csdepth%-1:PROCexpect(","):PROCstrexpr:cn%=csdepth%-1
8730 PROCvalue(0):cv%=cndepth%-1:PROCsearchstart:PROCexpect(")")
8740 PROCaddr("DD21","$s"+STR$(cm%)):PROCaddr("FD21","$s"+STR$(cn%)):PROCaddr("CD","$strinstr")
8750 PROCaddr("32","$v"+STR$(cv%)):csdepth%=csdepth%-2:cvaluekind%=0:ENDPROC
8760 DEF PROCsearchstart
8770 PROCspace:IF FNpeek<>"," THEN PROCbytes("3E01"):ENDPROC
8780 cpos%=cpos%+1:PROCcount:ENDPROC
8790 DEF PROCstrrepeat
8800 PROCexpect("("):PROCcount:PROCbyte(&F5):PROCexpect(","):PROCstrexpr:PROCexpect(")")
8805 IF csunsafe%(csdepth%-1) PROCbad("STRING$ on a FN string result is unqualified; establish a string value first")
8810 PROCbyte(&F1):PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCaddr("CD","$strrepeat"):PROCaddr("DA","$strerror"):ENDPROC
8900 DEF PROCstrsliceassign(ct$)
8910 LOCAL cn$,ci%
8920 PROCexpect("("):cn$=FNname:ci%=FNvariable(cn$)
8922 IF cvtype%(ci%)>255 PROCbad("Array slice assignment is unsupported")
8930 IF cvtype%(ci%)<>129 PROCbad("Expected a string variable")
8940 PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
8950 cndepth%=0:csdepth%=0
8960 IF ct$="MID" THEN PROCexpect(","):PROCcount:PROCbytes("3D2100FE006F")
8970 IF ct$="LEFT" PROCbytes("2100FF00")
8980 IF ct$="RIGHT" PROCbytes("21FFFF00")
8990 PROCspace:IF FNpeek="," PROCwriterange
9000 PROCexpect(")"):PROCexpect("="):PROCbyte(&E5):PROCstrexpr:PROCbyte(&E1)
9010 PROCaddr("DD21","$var"+STR$(ci%)):PROCaddr("FD21","$s"+STR$(csdepth%-1)):PROCaddr("CD","$strwrite")
9020 csdepth%=csdepth%-1:ENDPROC
9030 DEF PROCwriterange
9040 cpos%=cpos%+1:PROCbyte(&E5):PROCcount:PROCbyte(&E1)
9050 PROCbytes("B7280D3D8567300C7D3C280826FE180421010000"):ENDPROC
9100 DEF FNword(cw$)
9110 =MID$(cline$,cpos%,LEN(cw$))=cw$ AND NOT FNalpha(MID$(cline$,cpos%+LEN(cw$),1)) AND NOT FNdigit(MID$(cline$,cpos%+LEN(cw$),1))
9120 DEF FNstmtend
9130 =(FNpeek="" OR FNpeek=":" OR FNword("ELSE"))
9140 DEF FNflow
9150 cflow%=cflow%+1:="$if"+STR$(cflow%)
9160 DEF PROCcondition
9170 cndepth%=0:csdepth%=0:PROCexpr(1):PROCneednumber:PROCnumindices(0,0):PROCnumcall(38)
9180 PROCbytes("DD7E00DDB601DDB602DDB603"):cndepth%=0
9190 ENDPROC
9200 DEF PROCif
9210 LOCAL cid$,cthen%
9220 PROCcondition:cid$=FNflow:PROCspace:cthen%=FNword("THEN")
9230 IF cthen% THEN cpos%=cpos%+4:PROCspace
9240 IF cthen% AND FNpeek="" THEN PROCifblock(cid$):ENDPROC
9250 IF cinum%=32 PROCbad("Inline IF nesting exceeds 32")
9260 cifid$(cinum%)=cid$:cinum%=cinum%+1:cinseen%=TRUE
9270 PROCaddr("CA",cid$):ccont%=TRUE
9280 IF cthen% AND FNdigit(FNpeek) PROCbranch("GOTO"):ccont%=FALSE
9290 ENDPROC
9300 DEF PROCifblock(cid$)
9310 IF cinum%<>0 PROCbad("Multiline IF inside inline IF is unsupported")
9320 IF LEN(cstructure$)=32 PROCbad("Block nesting exceeds 32")
9325 cstructure$=cstructure$+"I"
9330 cbid$(cbnum%)=cid$:cbelse%(cbnum%)=FALSE:cbnum%=cbnum%+1:PROCaddr("CA",cid$)
9340 ENDPROC
9350 DEF PROCiffalse
9360 WHILE cinum%>0:cinum%=cinum%-1:PROClabel(cifid$(cinum%)):ENDWHILE
9370 ENDPROC
9380 DEF PROCelse
9390 IF NOT cfirst% THEN PROCinlineelse:ENDPROC
9400 IF cbnum%=0 PROCbad("ELSE without multiline IF")
9405 IF RIGHT$(cstructure$,1)<>"I" PROCbad("ELSE crosses a loop boundary")
9410 IF cbelse%(cbnum%-1) PROCbad("Duplicate multiline ELSE")
9420 PROCaddr("C3",cbid$(cbnum%-1)+"e"):PROClabel(cbid$(cbnum%-1)):cbelse%(cbnum%-1)=TRUE:ccont%=TRUE
9430 ENDPROC
9440 DEF PROCinlineelse
9450 IF NOT cinseen% PROCbad("ELSE without inline IF")
9460 IF cleid$="" cleid$=FNflow
9470 PROCaddr("C3",cleid$):PROCiffalse:ccont%=TRUE:PROCspace
9475 IF FNdigit(FNpeek) PROCbranch("GOTO"):ccont%=FALSE
9480 ENDPROC
9490 DEF PROCendif
9500 IF NOT cfirst% PROCbad("ENDIF must begin a statement line")
9510 IF cbnum%=0 PROCbad("ENDIF without multiline IF")
9515 IF RIGHT$(cstructure$,1)<>"I" PROCbad("ENDIF crosses a loop boundary")
9520 cbnum%=cbnum%-1:IF cbelse%(cbnum%) THEN PROClabel(cbid$(cbnum%)+"e") ELSE PROClabel(cbid$(cbnum%))
9525 cstructure$=LEFT$(cstructure$,LEN(cstructure$)-1)
9530 ENDPROC
11000 DEF PROCloadcontrol
11010 LOCAL ci%,cj%,cs$
11020 RESTORE 40000:READ ctsize%,ctrelocs%,ctinit%,ctpush%,ctcheck%,ctpop%,ctuntil%,ctagain%,ctfor%,ctnext%,ctnumslot%,cttop%,ctframes%,ctend%
11030 DIM ctimage% ctsize%-1,ctreloc%(ctrelocs%-1)
11040 FOR ci%=0 TO ctsize%-1 STEP 40:READ cs$
11050 FOR cj%=1 TO LEN(cs$) STEP 2:ctimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
11060 IF ctrelocs%>0 THEN FOR ci%=0 TO ctrelocs%-1:READ ctreloc%(ci%):NEXT
11070 ENDPROC
11080 DEF FNhexbyte(cs$)
11090 =(INSTR("0123456789ABCDEF",LEFT$(cs$,1))-1)*16+INSTR("0123456789ABCDEF",RIGHT$(cs$,1))-1
11100 DEF PROCflowcheck(ct%)
11110 PROCbyte(&3E):PROCbyte(ct%):PROCaddr("CD","$ctlcheck"):PROCaddr("DA","$flowerror")
11120 ENDPROC
11130 DEF PROCloop(cw$)
11140 LOCAL ck%,ci%,cn$,cid$,cp%
11150 IF LEN(cstructure$)=32 PROCbad("Block nesting exceeds 32")
11160 ck%=1:IF cw$="WHILE" ck%=2
11170 IF cw$="FOR" ck%=3
11180 cid$=FNflow:clkind%(cltop%)=ck%:clname$(cltop%)=cid$:cltop%=cltop%+1:cloops%=TRUE
11190 cstructure$=cstructure$+MID$("RWF",ck%,1)
11200 IF ck%=3 THEN PROCfor(cid$):ENDPROC
11210 PROCaddr("21",cid$+"b"):PROCbyte(&3E):PROCbyte(ck%):PROCaddr("CD","$ctlpush"):PROCaddr("DA","$flowerror")
11220 PROClabel(cid$+"b")
11230 IF ck%=2 THEN PROCcondition:PROCaddr("C2",cid$+"t"):PROCaddr("CD","$ctlpop"):PROCaddr("C3",cid$+"e"):PROClabel(cid$+"t")
11240 ENDPROC
11250 DEF PROCfor(cid$)
11260 LOCAL cn$,ci%,cp%
11270 cn$=FNname:cp%=cpos%:ci%=FNvariable(cn$):IF cvtype%(ci%)=129 PROCbad("FOR needs a numeric variable")
11272 IF cvtype%(ci%)>255 PROCbad("Array FOR variables are unsupported")
11280 clvar%(cltop%-1)=ci%:cpos%=cp%:PROCassign(cn$):PROCexpectword("TO")
11290 cndepth%=0:PROCexpr(1):PROCneednumber:PROCspace
11300 IF FNword("STEP") THEN cpos%=cpos%+4:PROCexpr(1):PROCneednumber ELSE PROCvalue(1)
11310 PROCnumindices(0,1):PROCaddr("21",cid$+"b"):PROCaddr("11","$var"+STR$(ci%)):PROCbyte(&06):PROCbyte(cvsize%(ci%))
11320 PROCaddr("CD","$ctlfor"):PROCaddr("DA","$flowerror"):cndepth%=0:PROClabel(cid$+"b")
11330 ENDPROC
11340 DEF PROCexpectword(cw$)
11350 PROCspace:IF NOT FNword(cw$) PROCbad("Expected "+cw$)
11360 cpos%=cpos%+LEN(cw$):ENDPROC
11370 DEF PROCloopend(cw$)
11380 LOCAL ck%,cid$
11390 ck%=1:IF cw$="ENDWHILE" ck%=2
11400 IF cw$="NEXT" THEN PROCnext:ENDPROC
11410 IF cltop%=0 PROCbad("Loop terminator without loop")
11420 IF clkind%(cltop%-1)<>ck% OR RIGHT$(cstructure$,1)<>MID$("RW",ck%,1) PROCbad("Mismatched loop terminator")
11430 cid$=clname$(cltop%-1):PROCflowcheck(ck%)
11440 IF ck%=1 THEN PROCcondition:PROCaddr("CD","$ctluntil") ELSE PROCaddr("CD","$ctlagain")
11450 PROCaddr("DA","$flowerror"):IF ck%=2 PROClabel(cid$+"e")
11460 cltop%=cltop%-1:cstructure$=LEFT$(cstructure$,LEN(cstructure$)-1)
11470 ENDPROC
11480 DEF PROCnext
11490 LOCAL ci%,cn$,cmore%,cfound%,cj%
11500 REPEAT
11510 IF cltop%=0 PROCbad("NEXT without FOR")
11520 IF RIGHT$(cstructure$,1)<>"F" PROCbad("NEXT crosses another block")
11530 PROCspace:ci%=-1
11540 IF FNalpha(FNpeek) AND NOT FNword("ELSE") THEN cn$=FNname:ci%=FNvariable(cn$)
11550 cj%=cltop%-1:IF ci%<0 ci%=clvar%(cj%)
11560 cfound%=FALSE:WHILE cj%>=0 AND NOT cfound%
11562 IF clkind%(cj%)<>3 PROCbad("NEXT crosses another loop")
11564 IF clvar%(cj%)=ci% THEN cfound%=TRUE ELSE cj%=cj%-1
11566 ENDWHILE
11570 IF cj%<0 PROCbad("NEXT variable has no matching FOR")
11580 IF clkind%(cj%)<>3 PROCbad("NEXT crosses another loop")
11590 PROCaddr("11","$var"+STR$(ci%)):PROCaddr("CD","$ctlnext"):PROCaddr("DA","$flowerror")
11600 cstructure$=LEFT$(cstructure$,LEN(cstructure$)-(cltop%-cj%)):cltop%=cj%:PROCspace:cmore%=(FNpeek=",")
11610 IF cmore% cpos%=cpos%+1
11620 UNTIL NOT cmore%
11630 ENDPROC
11700 DEF PROCflowruntime
11710 LOCAL cb%,ci%,cp%,cv%,cn$,ce%,csave%
11720 cb%=cpc%:IF cpc%+ctsize%>65536 PROCbad("Executable exceeds 65536 bytes")
11725 FOR ci%=0 TO ctsize%-1:ccode%?(cb%+ci%)=ctimage%?ci%:NEXT:cpc%=cpc%+ctsize%
11730 IF ctrelocs%>0 THEN FOR ci%=0 TO ctrelocs%-1:cp%=cb%+ctreloc%(ci%):cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
11740 PROCctlexport("$ctlinit",cb%+ctinit%):PROCctlexport("$ctlpush",cb%+ctpush%):PROCctlexport("$ctlcheck",cb%+ctcheck%):PROCctlexport("$ctlpop",cb%+ctpop%)
11750 PROCctlexport("$ctluntil",cb%+ctuntil%):PROCctlexport("$ctlagain",cb%+ctagain%):PROCctlexport("$ctlfor",cb%+ctfor%):PROCctlexport("$ctlnext",cb%+ctnext%)
11760 csave%=cpc%:cpc%=cb%+ctnumslot%:PROCaddr("","$numop"):cpc%=csave%
11770 FOR ci%=0 TO 5
11780 ce%=VAL(MID$("004346323338",ci%*2+1,2)):cn$=MID$("No room                 Not in a REPEAT loop    Not in a WHILE loop     Not in a FOR loop       Can't match FOR         No GOSUB                ",ci%*24+1,24)
11790 PROClabel("$flowerr"+STR$(ci%)):PROCtext(FNtrim(cn$)):PROCnewline:PROCaddr("C3","$error")
11800 NEXT
11810 PROClabel("$flowerror"):PROCbytes("B7"):PROCaddr("CA","$flowerr0")
11820 PROCbytes("FE2B"):PROCaddr("CA","$flowerr1"):PROCbytes("FE2E"):PROCaddr("CA","$flowerr2")
11830 PROCbytes("FE20"):PROCaddr("CA","$flowerr3"):PROCbytes("FE21"):PROCaddr("CA","$flowerr4"):PROCbytes("FE26"):PROCaddr("CA","$flowerr5")
11840 PROCaddr("C3","$numerror")
11850 ci%=FNsymbol("$start"):cp%=csaddr%(ci%):csaddr%(ci%)=&40000+cpc%:PROCaddr("CD","$ctlinit")
11852 IF cacts% THEN PROCbyte(&D5):PROCaddr("21","$actbase"):PROCaddr("11","$actlimit"):PROCaddr("CD","$actinit"):PROCbyte(&D1)
11855 PROCbyte(&C3)
11860 PROCbyte(cp% MOD 256):PROCbyte((cp% DIV 256) MOD 256):PROCbyte(cp% DIV 65536)
11870 ENDPROC
11880 DEF PROCctlexport(cn$,cp%)
11890 PROClabel(cn$):csaddr%(csnum%-1)=&40000+cp%:ENDPROC
11900 DEF FNtrim(cs$)
11910 WHILE RIGHT$(cs$,1)=" ":cs$=LEFT$(cs$,LEN(cs$)-1):ENDWHILE
11920 =cs$
13000 DEF PROCloadacts
13010 LOCAL ci%,cj%,cs$
13020 RESTORE 50000:READ casize%,carelocs%,cainit%,cabegin%,casave%,cainstall%,cabind%,caleave%,capushslot%,cacheckslot%,capopslot%,canumslot%,catop%,cafnbegin%,cafnleave%
13030 DIM caimage% casize%-1,careloc%(carelocs%-1)
13040 FOR ci%=0 TO casize%-1 STEP 40:READ cs$
13050 FOR cj%=1 TO LEN(cs$) STEP 2:caimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
13060 IF carelocs%>0 THEN FOR ci%=0 TO carelocs%-1:READ careloc%(ci%):NEXT
13070 ENDPROC
13080 DEF PROCuseacts
13090 cacts%=TRUE:cloops%=TRUE:cnumeric%=TRUE:IF cnslots%=0 cnslots%=1
13100 ENDPROC
13110 DEF FNprocfind(cn$)
13120 LOCAL ci%,cf%:ci%=0:cf%=-1
13130 WHILE ci%<cpnum%:IF cpname$(ci%)=cn$ cf%=ci%
13140 ci%=ci%+1:ENDWHILE
13150 =cf%
13160 DEF PROCprocscan(ch%)
13170 LOCAL ci%,cn$,cfunction%:cfunction%=-1
13180 WHILE NOT EOF#ch%
13190 clnum%=clnum%+1:cpos%=1:PROCreadline(ch%):PROCspace
13200 IF FNdigit(FNpeek) ci%=FNnumber(65279)
13210 PROCspace:IF FNword("DEF") PROCscandef
13214 IF FNword("DATA") OR FNword("REM") cpos%=LEN(cline$)+1
13215 IF cfunction%>=0 PROCcollectreturns(cfunction%,cpos%)
13220 ENDWHILE
13225 PROCinferreturns
13230 ENDPROC
13240 DEF PROCscandef
13250 LOCAL cn$,ci%,ck%
13260 cpos%=cpos%+3:PROCspace
13270 ck%=0:IF MID$(cline$,cpos%,2)="FN" ck%=1
13272 IF ck%=0 AND MID$(cline$,cpos%,4)<>"PROC" PROCbad("Expected PROC or FN after DEF")
13280 cpos%=cpos%+4-2*ck%:cn$=FNcallname(ck%):IF FNprocfind(MID$("PF",ck%+1,1)+cn$)>=0 PROCbad("Duplicate definition "+cn$)
13290 IF cpnum%=256 PROCbad("Procedure limit exceeds 256")
13300 ci%=cpnum%:cpnum%=cpnum%+1:cpname$(ci%)=MID$("PF",ck%+1,1)+cn$:cpline%(ci%)=clnum%:cpkind%(ci%)=ck%:cpret%(ci%)=-1:PROCprocparams(ci%,TRUE)
13305 cfunction%=-1:IF ck%=1 cfunction%=ci%
13310 ENDPROC
13320 DEF PROCprocparams(ci%,csave%)
13330 LOCAL cn$,cj%,ck%,cv%,cmore%
13340 cj%=0:PROCspace:IF FNpeek<>"(" THEN IF csave% cparcnt%(ci%)=0
13342 IF FNpeek<>"(" ENDPROC
13350 cpos%=cpos%+1:PROCspace:IF FNpeek=")" PROCbad("Empty formal parameter lists are unsupported")
13360 REPEAT
13370 IF cj%=16 PROCbad("Procedure argument limit exceeds 16")
13380 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported formal parameter "+cn$)
13390 cv%=FNvariable(cn$):ck%=0
13392 IF cvtype%(cv%)>255 PROCbad("Array formal parameters are unsupported")
13400 WHILE ck%<cj%:IF cpar%(ci%,ck%)=cv% PROCbad("Duplicate formal parameter")
13410 ck%=ck%+1:ENDWHILE
13420 IF csave% THEN cpar%(ci%,cj%)=cv% ELSE IF cpar%(ci%,cj%)<>cv% PROCbad("Procedure signature changed")
13430 cj%=cj%+1:PROCspace:cmore%=(FNpeek=","):IF cmore% cpos%=cpos%+1
13440 UNTIL NOT cmore%
13450 PROCexpect(")"):IF csave% THEN cparcnt%(ci%)=cj% ELSE IF cparcnt%(ci%)<>cj% PROCbad("Procedure signature changed")
13460 ENDPROC
13470 DEF PROCprocscope
13480 LOCAL ci%:ci%=0
13490 WHILE ci%<cpnum%
13500 IF cpline%(ci%)=clnum% THEN IF cstructure$<>"" PROCbad("Definition crosses an open block")
13510 IF cpline%(ci%)=clnum% cscope%=ci%+1
13520 ci%=ci%+1:ENDWHILE
13530 ENDPROC
13540 DEF FNtarget(cn$)
13550 IF cscope%=0 THEN =cn$
13560 ="$p"+STR$(cscope%)+cn$
13570 DEF PROCdefinition
13580 LOCAL cn$,ci%,ck%
13590 PROCspace:ck%=0:IF MID$(cline$,cpos%,2)="FN" ck%=1
13595 IF ck%=0 AND MID$(cline$,cpos%,4)<>"PROC" PROCbad("Expected PROC or FN after DEF")
13600 cpos%=cpos%+4-2*ck%:cn$=FNcallname(ck%):ci%=FNprocfind(MID$("PF",ck%+1,1)+cn$)
13610 IF ci%<0 PROCbad("DEF must begin its physical statement line")
13620 IF cpline%(ci%)<>clnum% PROCbad("DEF must begin its physical statement line")
13630 PROCprocparams(ci%,FALSE):cdeclskip$=FNflow:PROCaddr("C3",cdeclskip$):PROClabel("$proc"+STR$(ci%))
13635 PROCspace:IF ck%=1 AND FNpeek="=" ccont%=TRUE
13640 ENDPROC
13650 DEF PROCproccall
13660 LOCAL cn$,ci%,cj%,cv%,ccount%,ck%,cframe%
13670 cn$=FNname:ci%=FNprocfind("P"+cn$):IF ci%<0 PROCbad("Undefined PROC "+cn$)
13675 cframe%=ccalldepth%:ccalldepth%=ccalldepth%+1:IF ccalldepth%>32 PROCbad("Call expression nesting exceeds 32")
13680 PROCuseacts:PROCaddr("CD","$actbegin"):PROCaddr("DA","$acterror"):ccount%=cparcnt%(ci%)
13690 IF ccount%>0 THEN FOR cj%=0 TO ccount%-1:PROCsavebinding(cpar%(ci%,cj%)):NEXT
13700 cndepth%=0:csdepth%=0:PROCspace
13710 IF ccount%=0 AND FNpeek="(" PROCbad("Empty call argument lists are unsupported")
13720 IF ccount%>0 THEN PROCexpect("("):FOR cj%=0 TO ccount%-1:PROCprocarg(ci%,cj%):NEXT:PROCexpect(")")
13730 IF ccount%>0 THEN FOR cj%=ccount%-1 TO 0 STEP -1:PROCprocbind(cj%,ccount%-1-cj%):NEXT
13740 PROCaddr("CD","$proc"+STR$(ci%)):cndepth%=0:csdepth%=0
13745 ccalldepth%=ccalldepth%-1
13750 ENDPROC
13760 DEF PROCprocarg(ci%,cj%)
13770 LOCAL cv%,ck%
13780 IF cj%>0 PROCexpect(",")
13790 PROCexpr(1):cv%=cpar%(ci%,cj%):ck%=ABS(cvtype%(cv%)=129)
13800 IF cvaluekind%<>ck% PROCbad("Procedure argument type mismatch")
13810 cargkind%(cframe%,cj%)=ck%:IF ck%=0 THEN cargindex%(cframe%,cj%)=cndepth%-1 ELSE cargindex%(cframe%,cj%)=csdepth%-1
13820 ENDPROC
13830 DEF PROCprocbind(ci%,co%)
13840 LOCAL cn$:cn$="$v":IF cargkind%(cframe%,ci%)=1 cn$="$s"
13850 PROCbyte(&3E):PROCbyte(co%):PROCaddr("FD21",cn$+STR$(cargindex%(cframe%,ci%))):PROCaddr("CD","$actbind"):PROCaddr("DA","$acterror")
13860 ENDPROC
13870 DEF PROCsavebinding(ci%)
13880 PROCaddr("DD21","$bind"+STR$(ci%)):PROCbyte(&3E):PROCbyte(cvtype%(ci%)):PROCaddr("CD","$actsave"):PROCaddr("DA","$acterror")
13890 ENDPROC
13900 DEF PROClocal
13910 LOCAL cn$,ci%,cmore%
13920 PROCuseacts
13930 REPEAT
13940 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported LOCAL form "+cn$)
13950 ci%=FNvariable(cn$)
13952 IF cvtype%(ci%)>255 PROCbad("LOCAL arrays are unsupported")
13954 PROCsavebinding(ci%):PROCaddr("CD","$actinstall")
13960 PROCspace:cmore%=(FNpeek=","):IF cmore% cpos%=cpos%+1
13970 UNTIL NOT cmore%
13980 ENDPROC
14000 DEF PROCactruntime
14010 LOCAL cb%,ci%,cp%,cv%,csave%
14020 cb%=cpc%:IF cpc%+casize%>65536 PROCbad("Executable exceeds 65536 bytes")
14030 FOR ci%=0 TO casize%-1:ccode%?(cb%+ci%)=caimage%?ci%:NEXT:cpc%=cpc%+casize%
14040 IF carelocs%>0 THEN FOR ci%=0 TO carelocs%-1:cp%=cb%+careloc%(ci%):cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
14050 PROCctlexport("$actinit",cb%+cainit%):PROCctlexport("$actbegin",cb%+cabegin%):PROCctlexport("$actsave",cb%+casave%)
14060 PROCctlexport("$actinstall",cb%+cainstall%):PROCctlexport("$actbind",cb%+cabind%):PROCctlexport("$actleave",cb%+caleave%)
14065 PROCctlexport("$fnbegin",cb%+cafnbegin%):PROCctlexport("$fnleave",cb%+cafnleave%)
14070 csave%=cpc%:cpc%=cb%+capushslot%:PROCaddr("","$ctlpush"):cpc%=cb%+cacheckslot%:PROCaddr("","$ctlcheck")
14080 cpc%=cb%+capopslot%:PROCaddr("","$ctlpop"):cpc%=cb%+canumslot%:PROCaddr("","$numop"):cpc%=csave%
14090 PROClabel("$acterror"):PROCbytes("B7"):PROCaddr("CA","$flowerr0")
14100 PROCbytes("FE0C"):PROCaddr("CA","$notlocal"):PROCbytes("FE0D"):PROCaddr("CA","$notproc"):PROCbytes("FE07"):PROCaddr("CA","$notfn"):PROCaddr("C3","$numerror")
14105 REM Act error7 must be dispatched before falling through to numeric error.
14110 PROClabel("$notlocal"):PROCtext("Not in a FN or PROC"):PROCnewline:PROCaddr("C3","$error")
14120 PROClabel("$notproc"):PROCtext("Not in a PROC"):PROCnewline:PROCaddr("C3","$error")
14125 PROClabel("$notfn"):PROCtext("Not in a FN"):PROCnewline:PROCaddr("C3","$error")
14127 IF cfunctions% THEN PROClabel("$fnnum"):PROCbytes("0000000000"):PROClabel("$fnstr"):FOR ci%=0 TO 255:PROCbyte(0):NEXT
14130 ENDPROC
14140 DEF PROCactworkspace
14150 LOCAL cp%,ci%
14160 cp%=&40000+cpc%:IF cstrings% OR cmemory% cp%=csaddr%(FNsymbol("$sheapend"))
14170 PROClabel("$actbase"):csaddr%(csnum%-1)=cp%:PROClabel("$actlimit"):csaddr%(csnum%-1)=cp%+32768
14180 IF cp%+32768>&B0000 PROCbad("Activation workspace exceeds user RAM")
14190 ENDPROC
15000 DEF FNcallname(ck%)
15010 LOCAL cn$:cn$=FNname
15020 IF ck%=1 AND FNpeek="$" THEN cn$=cn$+"$":cpos%=cpos%+1
15030 =cn$
15040 DEF FNfnstring(cp%)
15050 LOCAL cs%,ci%:cs%=cpos%:cpos%=cp%+2:ci%=FNprocfind("F"+FNcallname(1)):cpos%=cs%
15060 IF ci%<0 THEN =FALSE
15070 =(cpret%(ci%)=1)
15080 DEF PROCfncall
15090 LOCAL cn$,ci%,cj%,ccount%,cframe%,cnstart%,csstart%,ck%
15095 IF cdimparse%>0 PROCbad("FN calls in array DIM expressions are unqualified")
15100 cn$=FNcallname(1):ci%=FNprocfind("F"+cn$):IF ci%<0 PROCbad("Undefined FN "+cn$)
15110 PROCuseacts:cfunctions%=TRUE:cnstart%=cndepth%:csstart%=csdepth%:cframe%=ccalldepth%:ccalldepth%=ccalldepth%+1
15120 IF ccalldepth%>32 PROCbad("Call expression nesting exceeds 32")
15130 IF cnstart%>0 THEN PROCaddr("DD21","$v0") ELSE PROCbytes("DD21000000")
15140 IF csstart%>0 THEN PROCaddr("FD21","$s0") ELSE PROCbytes("FD21000000")
15150 PROCbytes("0100000006"):PROCbyte(cnstart%):PROCbyte(&0E):PROCbyte(csstart%):PROCaddr("CD","$fnbegin"):PROCaddr("DA","$acterror")
15160 ccount%=cparcnt%(ci%):IF ccount%>0 THEN FOR cj%=0 TO ccount%-1:PROCsavebinding(cpar%(ci%,cj%)):NEXT
15170 PROCspace:IF ccount%=0 AND FNpeek="(" PROCbad("Empty call argument lists are unsupported")
15180 IF ccount%>0 THEN PROCexpect("("):FOR cj%=0 TO ccount%-1:PROCprocarg(ci%,cj%):NEXT:PROCexpect(")")
15190 IF ccount%>0 THEN FOR cj%=ccount%-1 TO 0 STEP -1:PROCprocbind(cj%,ccount%-1-cj%):NEXT
15200 PROCaddr("CD","$proc"+STR$(ci%)):cndepth%=cnstart%:csdepth%=csstart%
15210 IF cpret%(ci%)=0 THEN PROCnumslot:PROCvarcopy("$fnnum","$v"+STR$(cndepth%-1),5) ELSE PROCstrslot:PROCcopystr("$fnstr","$s"+STR$(csdepth%-1))
15215 IF cpret%(ci%)=1 csunsafe%(csdepth%-1)=TRUE
15220 cvaluekind%=cpret%(ci%):ccalldepth%=ccalldepth%-1:ENDPROC
15230 DEF PROCcopystr(cf$,ct$)
15240 PROCaddr("21",cf$):PROCaddr("11",ct$):PROCaddr("CD","$strcopy"):ENDPROC
15250 DEF PROCfnreturn
15260 PROCuseacts:cfunctions%=TRUE:cndepth%=0:csdepth%=0:PROCexpr(1)
15270 IF cscope%>0 THEN IF cpkind%(cscope%-1)=1 AND cpret%(cscope%-1)<>cvaluekind% PROCbad("Mixed numeric/string FN results are unsupported")
15280 IF cvaluekind%=0 THEN PROCvarcopy("$v0","$fnnum",5) ELSE PROCcopystr("$s0","$fnstr")
15290 PROCaddr("CD","$fnleave"):PROCaddr("DA","$acterror"):PROCbyte(&C9):cndepth%=0:csdepth%=0:ENDPROC
15300 DEF PROCcollectreturns(ci%,cs%)
15310 LOCAL cp%,cq%,cd%,ce%,cc$
15320 cp%=cs%:cq%=FALSE:cd%=0
15330 WHILE cp%<=LEN(cline$)
15340 cc$=MID$(cline$,cp%,1)
15350 IF cc$=CHR$(34) THEN cq%=NOT cq%
15355 IF NOT cq% AND cd%=0 THEN IF FNkindword(cline$,cp%,"REM") OR FNkindword(cline$,cp%,"DATA") cp%=LEN(cline$)+1
15360 IF NOT cq% THEN IF cc$="=" AND cd%=0 AND FNreturnmark(cp%,cs%) THEN ce%=FNreturnend(cp%+1):PROCrememberreturn(ci%,MID$(cline$,cp%+1,ce%-cp%-1),cp%+1):cp%=ce%-1
15370 IF NOT cq% THEN IF cc$="(" cd%=cd%+1
15380 IF NOT cq% THEN IF cc$=")" cd%=cd%-1
15390 cp%=cp%+1:ENDWHILE
15400 ENDPROC
15410 DEF FNreturnmark(cp%,cs%)
15420 cp%=cp%-1:WHILE cp%>=cs% AND (MID$(cline$,cp%,1)=" " OR MID$(cline$,cp%,1)=CHR$(9)):cp%=cp%-1:ENDWHILE
15430 IF cp%<cs% OR MID$(cline$,cp%,1)=":" THEN =TRUE
15435 IF cp%<4 THEN =FALSE
15440 =FNkindword(cline$,cp%-3,"THEN") OR FNkindword(cline$,cp%-3,"ELSE")
15450 DEF FNreturnend(cp%)
15460 LOCAL cq%,cd%,cc%,cf%:cq%=FALSE:cd%=0:cf%=FALSE
15470 WHILE cp%<=LEN(cline$) AND NOT cf%
15480 cc%=ASC(MID$(cline$,cp%,1)):IF cc%=34 cq%=NOT cq%
15490 IF NOT cq% AND cd%=0 THEN IF cc%=58 OR FNkindword(cline$,cp%,"ELSE") cf%=TRUE
15500 IF NOT cq% THEN IF cc%=40 cd%=cd%+1
15510 IF NOT cq% THEN IF cc%=41 cd%=cd%-1
15520 IF NOT cf% cp%=cp%+1
15530 ENDWHILE
15540 =cp%
15550 DEF PROCrememberreturn(ci%,cs$,ccol%)
15560 IF cretnum%=512 PROCbad("FN result expression limit exceeds 512")
15570 creturn$(cretnum%)=cs$:cretdef%(cretnum%)=ci%:cretline%(cretnum%)=clnum%:cretcol%(cretnum%)=ccol%:cretnum%=cretnum%+1:ENDPROC
15580 DEF PROCinferreturns
15590 LOCAL ci%,cj%,ck%,cchange%
15600 REPEAT
15610 cchange%=FALSE:ci%=0
15620 WHILE ci%<cretnum%
15625 clnum%=cretline%(ci%):cpos%=cretcol%(ci%)
15630 cj%=cretdef%(ci%):ck%=FNinferkind(creturn$(ci%))
15640 IF ck%>=0 AND cpret%(cj%)>=0 AND ck%<>cpret%(cj%) PROCbad("Mixed numeric/string FN results are unsupported")
15650 IF ck%>=0 AND cpret%(cj%)<0 THEN cpret%(cj%)=ck%:cchange%=TRUE
15660 ci%=ci%+1:ENDWHILE
15670 UNTIL NOT cchange%
15680 ci%=0:WHILE ci%<cpnum%
15690 IF cpkind%(ci%)=1 AND cpret%(ci%)<0 THEN clnum%=cpline%(ci%):cpos%=1:PROCbad("Unresolved FN result kind "+cpname$(ci%))
15700 ci%=ci%+1:ENDWHILE
15710 ENDPROC
15720 DEF FNinferkindcore(cs$)
15730 LOCAL cp%,cd%,cq%,cc$,co%,ci%,ck%,cl%,cr%,cn$
15740 cs$=FNkindtrim(cs$):IF cs$="" PROCbad("Missing FN result expression")
15750 WHILE LEFT$(cs$,1)="(" AND FNkindouter(cs$):cs$=FNkindtrim(MID$(cs$,2,LEN(cs$)-2)):ENDWHILE
15760 cp%=1:cd%=0:cq%=FALSE:co%=0
15770 WHILE cp%<=LEN(cs$)
15780 cc$=MID$(cs$,cp%,1):IF cc$=CHR$(34) cq%=NOT cq%
15790 IF NOT cq% AND cd%=0 AND INSTR("<>=*/^-",cc$)>0 co%=1
15800 IF NOT cq% AND cd%=0 THEN IF FNkindword(cs$,cp%,"AND") OR FNkindword(cs$,cp%,"OR") OR FNkindword(cs$,cp%,"EOR") OR FNkindword(cs$,cp%,"DIV") OR FNkindword(cs$,cp%,"MOD") co%=1
15810 IF NOT cq% THEN IF cc$="(" cd%=cd%+1
15820 IF NOT cq% THEN IF cc$=")" cd%=cd%-1
15830 cp%=cp%+1:ENDWHILE
15840 IF co%=1 THEN =0
15845 IF LEFT$(cs$,1)="+" THEN =0
15850 cp%=FNkindplus(cs$):IF cp%>0 THEN cl%=FNinferkind(LEFT$(cs$,cp%-1)):cr%=FNinferkind(MID$(cs$,cp%+1)):PROCkindpair: =ck%
15860 IF LEFT$(cs$,1)=CHR$(34) THEN =1
15870 IF LEFT$(cs$,2)="FN" THEN cp%=3:cn$=FNkindname(cs$,cp%):ci%=FNprocfind("F"+cn$):IF ci%<0 PROCbad("Undefined FN "+cn$)
15880 IF LEFT$(cs$,2)="FN" THEN =cpret%(ci%)
15890 cp%=1:cn$=FNkindname(cs$,cp%):IF RIGHT$(cn$,1)="$" THEN =1
15900 =0
15910 DEF PROCkindpair
15920 ck%=cl%:IF ck%<0 ck%=cr%
15930 IF cl%>=0 AND cr%>=0 AND cl%<>cr% PROCbad("Numeric/string type mismatch in FN result")
15940 ENDPROC
15950 DEF FNkindname(cs$,cp%)
15960 LOCAL cn$:cn$=""
15970 WHILE FNalpha(MID$(cs$,cp%,1)) OR FNdigit(MID$(cs$,cp%,1)):cn$=cn$+MID$(cs$,cp%,1):cp%=cp%+1:ENDWHILE
15980 IF MID$(cs$,cp%,1)="$" cn$=cn$+"$"
15990 =cn$
16000 DEF FNkindtrim(cs$)
16010 WHILE LEFT$(cs$,1)=" " OR LEFT$(cs$,1)=CHR$(9):cs$=MID$(cs$,2):ENDWHILE
16020 WHILE RIGHT$(cs$,1)=" " OR RIGHT$(cs$,1)=CHR$(9):cs$=LEFT$(cs$,LEN(cs$)-1):ENDWHILE
16030 =cs$
16040 DEF FNkindouter(cs$)
16050 LOCAL cp%,cd%,cq%,cf%,cc$:cp%=1:cd%=0:cq%=FALSE:cf%=TRUE
16060 WHILE cp%<=LEN(cs$)
16070 cc$=MID$(cs$,cp%,1):IF cc$=CHR$(34) cq%=NOT cq%
16080 IF NOT cq% THEN IF cc$="(" cd%=cd%+1
16090 IF NOT cq% THEN IF cc$=")" cd%=cd%-1
16100 IF NOT cq% AND cd%=0 AND cp%<LEN(cs$) cf%=FALSE
16110 cp%=cp%+1:ENDWHILE
16120 =(cf% AND cd%=0)
16130 DEF FNkindword(cs$,cp%,cw$)
16135 LOCAL cb$,ca$:cb$="":IF cp%>1 cb$=MID$(cs$,cp%-1,1)
16137 ca$=MID$(cs$,cp%+LEN(cw$),1)
16140 =(MID$(cs$,cp%,LEN(cw$))=cw$ AND NOT FNalpha(cb$) AND NOT FNdigit(cb$) AND NOT FNalpha(ca$) AND NOT FNdigit(ca$))
16150 DEF FNkindplus(cs$)
16160 LOCAL cp%,cd%,cq%,cf%,cc$:cp%=1:cd%=0:cq%=FALSE:cf%=0
16170 WHILE cp%<=LEN(cs$) AND cf%=0
16180 cc$=MID$(cs$,cp%,1):IF cc$=CHR$(34) cq%=NOT cq%
16190 IF NOT cq% AND cd%=0 AND cc$="+" cf%=cp%
16200 IF NOT cq% THEN IF cc$="(" cd%=cd%+1
16210 IF NOT cq% THEN IF cc$=")" cd%=cd%-1
16220 cp%=cp%+1:ENDWHILE
16230 =cf%
16300 DEF FNinferkind(cs$)
16310 LOCAL ck%:ckinddepth%=ckinddepth%+1:IF ckinddepth%>32 PROCbad("FN kind expression nesting exceeds 32")
16320 ck%=FNinferkindcore(cs$):ckinddepth%=ckinddepth%-1:=ck%
16400 DEF PROCloadmemory
16402 LOCAL ci%,cj%,cs$
16404 RESTORE 60000:READ cmsize%,cmrelocs%,cmalloc%,cmdim%,cmaddr%,cmstep%,cmprefix%
16406 DIM cmimage% cmsize%-1,cmreloc%(cmrelocs%-1)
16408 FOR ci%=0 TO cmsize%-1 STEP 40:READ cs$
16410 FOR cj%=1 TO LEN(cs$) STEP 2:cmimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
16412 IF cmrelocs%>0 THEN FOR ci%=0 TO cmrelocs%-1:READ cmreloc%(ci%):NEXT
16414 ENDPROC
16416 DEF PROCusememory
16418 cmemory%=TRUE:cnumeric%=TRUE:ENDPROC
16420 DEF PROCmemoryruntime
16422 LOCAL cb%,ci%,cp%,cv%,ce%,cm$
16424 cb%=cpc%:FOR ci%=0 TO cmsize%-1:PROCbyte(cmimage%?ci%):NEXT
16426 FOR ci%=0 TO cmrelocs%-1:cp%=cb%+cmreloc%(ci%)
16428 cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
16430 PROCctlexport("$memalloc",cb%+cmalloc%):PROCctlexport("$arraydim",cb%+cmdim%):PROCctlexport("$arrayaddr",cb%+cmaddr%)
16432 PROCctlexport("$dimstep",cb%+cmstep%):PROCctlexport("$arrayprefix",cb%+cmprefix%)
16434 PROClabel("$memerror")
16436 FOR ci%=0 TO 6:ce%=VAL(MID$("05101114151627",ci%*2+1,2)):PROCbyte(&FE):PROCbyte(ce%):PROCaddr("CA","$me"+STR$(ce%)):NEXT
16438 PROCtext("No room"):PROCnewline:PROCaddr("C3","$error")
16440 FOR ci%=0 TO 6:ce%=VAL(MID$("05101114151627",ci%*2+1,2)):cm$=""
16442 IF ce%=5 cm$="Missing ,"
16444 IF ce%=10 cm$="Bad DIM"
16446 IF ce%=11 cm$="DIM space"
16448 IF ce%=14 cm$="Bad use of array"
16450 IF ce%=15 cm$="Bad subscript"
16452 IF ce%=16 cm$="Syntax error"
16454 IF ce%=27 cm$="Missing )"
16456 PROClabel("$me"+STR$(ce%)):PROCtext(cm$):PROCnewline:PROCaddr("C3","$error"):NEXT
16458 ENDPROC
16460 DEF PROCmemoryworkspace
16462 LOCAL cp%
16464 PROClabel("$sheapctx"):PROCaddr("","$sheap"):PROCaddr("","$sheapend")
16466 PROClabel("$sheap"):cp%=&AFF00-32768*ABS(cacts%)
16468 IF cp%<&40000+cpc% PROCbad("Memory workspace exceeds user RAM")
16470 PROClabel("$sheapend"):csaddr%(csnum%-1)=cp%:ENDPROC
16472 DEF FNmemwidth(ci%)
16474 LOCAL ct%:ct%=cvtype%(ci%) AND 255:IF ct%=129 ct%=5
16476 =ct%
16478 DEF PROCarrayarity(ci%,cn%)
16480 IF cvdim%(ci%)=0 cvdim%(ci%)=cn%
16482 IF cvdim%(ci%)<>cn% PROCbad("Array arity must be consistent in this compiler subset")
16484 ENDPROC
16486 DEF PROCarraycall(cr$,ci%,cn%,cs%)
16488 PROCaddr("DD21","$var"+STR$(ci%)):PROCaddr("FD21","$v"+STR$(cs%))
16490 PROCbyte(&06):PROCbyte(FNmemwidth(ci%)):PROCbyte(&3E):PROCbyte(cn%)
16492 PROCaddr("CD",cr$):PROCaddr("DA","$memerror"):ENDPROC
16494 DEF PROCarrayaddress(ci%,cw%)
16496 LOCAL cp%,cs%,cn%,cmore%
16498 PROCusememory:PROCvalue(0):cp%=cndepth%-1:cs%=cndepth%:cn%=0
16500 IF cw% THEN PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)) ELSE PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
16502 PROCexpect("("):IF FNpeek=")" PROCbad("Whole-array values are unsupported")
16504 PROCarraycall("$arrayprefix",ci%,0,cs%)
16506 REPEAT
16508 IF cn%=16 PROCbad("Array dimension limit exceeds 16")
16510 IF cn%>0 PROCexpect(",")
16512 PROCexpr(1):PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16514 cn%=cn%+1:PROCarraycall("$arrayprefix",ci%,cn%,cs%)
16516 PROCspace:cmore%=(FNpeek=",")
16518 UNTIL NOT cmore%
16520 PROCexpect(")"):PROCarrayarity(ci%,cn%):PROCarraycall("$arrayaddr",ci%,cn%,cs%)
16522 PROCaddr("22","$v"+STR$(cp%)):cndepth%=cp%+1:ENDPROC
16524 DEF PROCarrayread(ci%)
16526 LOCAL ct%,cp%,cj%
16528 PROCarrayaddress(ci%,FALSE):ct%=cvtype%(ci%) AND 255:cp%=cndepth%-1
16530 IF ct%=129 THEN PROCstrslot:PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCaddr("FD2A","$v"+STR$(cp%)):PROCaddr("CD","$strload"):cndepth%=cp%:cvaluekind%=1:ENDPROC
16532 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("11","$v"+STR$(cp%))
16534 PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16536 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16538 cvaluekind%=0:ENDPROC
16540 DEF PROCarrayassign(ci%)
16542 LOCAL ct%:ct%=cvtype%(ci%) AND 255:cndepth%=0:csdepth%=0:PROCarrayaddress(ci%,TRUE):PROCexpect("=")
16544 PROCexpr(1)
16546 IF ct%=129 THEN IF cvaluekind%<>1 PROCbad("Expected a string item")
16548 IF ct%=129 THEN PROCaddr("DD2A","$v0"):PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):cndepth%=0:csdepth%=0:ENDPROC
16550 PROCneednumber:IF ct%<>5 THEN PROCnumindices(1,1):PROCnumcall(38)
16552 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16554 cndepth%=0:csdepth%=0:ENDPROC
16556 DEF PROCdim
16558 LOCAL cn$,ci%,cmore%,ct%,cj%
16560 PROCusememory
16562 REPEAT
16564 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported DIM target "+cn$)
16566 ci%=FNvariable(cn$):ct%=cvtype%(ci%):PROCspace
16568 IF ct%>255 THEN PROCdimarray(ci%) ELSE PROCdimblock(ci%)
16570 PROCspace:cmore%=(FNpeek=","):IF cmore% cpos%=cpos%+1
16572 UNTIL NOT cmore%
16574 ENDPROC
16576 DEF PROCdimarray(ci%)
16578 LOCAL cn%,cs%,cmore%,cnew$,ct%
16580 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%))
16582 cndepth%=0:csdepth%=0:PROCvalue(1):PROCvalue(0):PROCaddr("2A","$var"+STR$(ci%)):PROCaddr("22","$v1")
16584 cs%=cndepth%:cn%=0:PROCexpect("("):cnew$=FNflow:PROCdimbranch(cnew$,TRUE):PROCarraycall("$arrayprefix",ci%,0,cs%):PROClabel(cnew$)
16586 IF FNpeek=")" PROCbad("Empty DIM dimensions are unsupported")
16588 REPEAT
16590 IF cn%=16 PROCbad("Array dimension limit exceeds 16")
16592 IF cn%>0 PROCexpect(",")
16594 cdimparse%=cdimparse%+1:PROCexpr(1):cdimparse%=cdimparse%-1:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16596 cn%=cn%+1:PROCdimchoice(ci%,cn%,cs%)
16598 PROCspace:cmore%=(FNpeek=",")
16600 UNTIL NOT cmore%
16602 PROCexpect(")"):PROCarrayarity(ci%,cn%):cnew$=FNflow:PROCdimbranch(cnew$,TRUE)
16604 PROCarraycall("$arrayaddr",ci%,cn%,cs%):ct%=cvtype%(ci%) AND 255
16606 IF ct%=129 THEN PROCbytes("3E0A"):PROCaddr("C3","$memerror") ELSE PROCdimseed(ct%):PROCbytes("3E10"):PROCaddr("C3","$memerror")
16608 PROClabel(cnew$):PROCaddr("21","$sheapctx"):PROCarraycall("$arraydim",ci%,cn%,cs%):cndepth%=0:ENDPROC
16610 DEF PROCdimblock(ci%)
16612 LOCAL ct%,cj%:ct%=cvtype%(ci%)
16614 IF ct%<>4 AND ct%<>5 PROCbad("Raw DIM requires a four-byte or variant numeric target")
16616 IF FNword("LOCAL") PROCbad("DIM LOCAL storage is unsupported")
16618 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCaddr("21","$var"+STR$(ci%)):PROCdimseed(ct%)
16620 cndepth%=0:csdepth%=0:PROCexpr(1):PROCneednumber:PROCnumindices(0,0):PROCnumcall(38)
16622 PROCaddr("2A","$v0"):PROCbyte(&23):PROCaddr("DD21","$sheapctx"):PROCaddr("CD","$memalloc"):PROCaddr("DA","$memerror")
16624 PROCaddr("ED53","$var"+STR$(ci%)):cndepth%=0:ENDPROC
16626 DEF PROCreadscalar(ci%)
16628 LOCAL ct%,cs$,cj%:ct%=cvsize%(ci%)
16630 IF cvtype%(ci%)=129 PROCbad("String value used as a numeric item")
16632 PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
16634 PROCnumslot:cs$="$v"+STR$(cndepth%-1):PROCvarcopy("$var"+STR$(ci%),cs$,ct%)
16636 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16638 cvaluekind%=0:ENDPROC
16640 DEF PROCmemtail
16642 LOCAL ct%:IF FNpeek<>"?" AND FNpeek<>"!" ENDPROC
16644 ct%=1:IF FNpeek="!" ct%=4
16646 cpos%=cpos%+1:PROCmemoffset:PROCmemload(ct%):ENDPROC
16648 DEF PROCmemoffset
16650 LOCAL cp%:cp%=cndepth%-1:PROCnumindices(cp%,cp%):PROCnumcall(38)
16652 PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16654 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("ED5B","$v"+STR$(cndepth%-1)):PROCbyte(&19)
16656 PROCaddr("22","$v"+STR$(cp%)):PROCaddr("21","$v"+STR$(cp%)):PROCbytes("232323AF772377")
16658 cndepth%=cp%+1:ENDPROC
16660 DEF PROCmemload(ct%)
16662 LOCAL cp%,cj%:cp%=cndepth%-1:PROCusememory
16664 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("11","$v"+STR$(cp%))
16666 PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16668 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16670 cvaluekind%=0:ENDPROC
16672 DEF PROCmemitem(cc$)
16674 LOCAL ct%
16676 IF cc$="^" THEN cpos%=cpos%+1:PROCaddress:ENDPROC
16678 ct%=1:IF cc$="!" ct%=4
16680 IF cc$="|" ct%=5
16682 cpos%=cpos%+1:PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16684 PROCmemload(ct%):ENDPROC
16686 DEF PROCaddress
16688 LOCAL cn$,ci%,cp%
16690 IF cdimparse%>0 PROCbad("Address-of in array DIM expressions is unqualified")
16692 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported address target "+cn$)
16694 ci%=FNvariable(cn$):IF cvtype%(ci%)>255 THEN PROCarrayaddress(ci%,TRUE):cvaluekind%=0:ENDPROC
16696 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCvalue(0):cp%=cndepth%-1
16698 PROCaddr("21","$var"+STR$(ci%)):PROCaddr("22","$v"+STR$(cp%)):cvaluekind%=0:ENDPROC
16700 DEF PROCindirectassign(ci%)
16702 LOCAL ct%:ct%=1:IF FNpeek="!" ct%=4
16704 cndepth%=0:csdepth%=0:PROCreadscalar(ci%):cpos%=cpos%+1:PROCmemoffset:PROCmemstore(ct%):ENDPROC
16706 DEF PROCmemassign(cc$)
16708 LOCAL ct%:ct%=1:IF cc$="!" ct%=4
16710 IF cc$="|" ct%=5
16712 PROCusememory:cndepth%=0:csdepth%=0:cpos%=cpos%+1:PROCitem:PROCneednumber:PROCnumindices(0,0):PROCnumcall(38)
16714 PROCmemstore(ct%):ENDPROC
16716 DEF PROCmemstore(ct%)
16718 PROCusememory:PROCexpect("="):PROCexpr(1):PROCneednumber
16720 IF ct%<>5 THEN PROCnumindices(1,1):PROCnumcall(38)
16722 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16724 cndepth%=0:csdepth%=0:ENDPROC
16726 DEF PROCdimseed(ct%)
16728 LOCAL cj%
16730 IF ct%=1 THEN PROCbytes("7D77"):ENDPROC
16732 PROCbytes("E5D173237223AF"):FOR cj%=3 TO ct%:PROCbytes("7723"):NEXT:ENDPROC
16734 DEF PROCdimbranch(cn$,cz%)
16736 LOCAL cr$:cr$="C2":IF cz% cr$="CA"
16738 PROCaddr("2A","$v1"):PROCbytes("01000000B7ED42"):PROCaddr(cr$,cn$):ENDPROC
16740 DEF PROCdimchoice(ci%,cn%,cs%)
16742 LOCAL cold$,cend$:cold$=FNflow:cend$=FNflow:PROCdimbranch(cold$,FALSE)
16744 PROCnumindices(0,cndepth%-1):PROCaddr("CD","$dimstep"):PROCaddr("DA","$memerror"):PROCaddr("C3",cend$)
16746 PROClabel(cold$):PROCarraycall("$arrayprefix",ci%,cn%,cs%):PROClabel(cend$):ENDPROC
10000 DATA "p0.bas","p0.bin"
10010 DATA "p1.bas","p1.bin"
10020 DATA "p0.bas","output-repeat.bin"
20000 DATA 4460,387,644,0,12,113,212,267,283
20010 DATA "E1DDE5D101050000EDB0E5C9DD7E04B72809DD7E03EE80DD7703C9DDE5E10604377E2FCE00772310"
20020 DATA "F8C9DDE5FDE50100000021000000DD6E02DD6603DD4E04D921000000DD6E00DD6601D9FDE5D1DD21"
20030 DATA "B000003E25CD410300380FAF12EBFDE5D1B7ED52FDE1DDE1AFC9FDE1DDE1B737C9DDE5FDE5F5FD21"
20040 DATA "B40000CD2A00003825F195380C47B728083E20C549D7C110F821B400007EB72807E549D7E12318F5"
20050 DATA "FDE1DDE1AFC957F17AFDE1DDE1B737C90A0900000000000000000000000000000000000000000000"
20060 DATA "000000000000000000000000DDE5FDE5FDE5E1010000004E231184010079B72802EDB0AF12DD2184"
20070 DATA "01003E24CD410300380AFDE1DDE1CDF50200AFC9FDE1DDE1B737C9FDE5FD23CD2A0000FDE1D8FD75"
20080 DATA "00AFC9DDE5FDE50100000021000000DD6E02DD6603DD4E04D921000000DD6E00DD6601D93E26CD41"
20090 DATA "030038C001080000FDE5D113C50604AFD95229D952ED6A1710F6C10DFA7301002806B72003B828E4"
20100 DATA "C69027CE402712134718D9EBFDE5D1B7ED522BFD7500FDE1DDE1AFC9000000000000000000000000"
20110 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
20120 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
20130 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
20140 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
20150 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
20160 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
20170 DATA "00000000FE203811FE23280DFE262809FE2728053E01B737C9DDE5FDE5F50100000021000000DD6E"
20180 DATA "02DD6603DD4E04D921000000DD6E00DD6601D9FDE5DDE1CDDB0200F1CD410300380AFDE1DDE1CDF5"
20190 DATA "0200AFC9FDE1DDE1B737C9DD4604D911000000DD5E00DD5601D911000000DD5E02DD5603C9DD7104"
20200 DATA "D9DD7500DD7401D9DD7502DD7403C97CB5D9B4B5D9C9DD4606D911000000DD5E00DD5601D9110000"
20210 DATA "00DD5E03DD5604C9DD7106D9DD7500DD7401AFDD7702D9DD7503DD7404DD7705C9FDE5FD21000000"
20220 DATA "FD39CD5A0300BFFDE1C93E01FDF9B73718F5FE3030F4FE1030080878B1C4AC0E0008E5217D0300C5"
20230 DATA "0103000047ED4C09ED27C1E3C94104009504005404007A04006704004307005207003607001B0700"
20240 DATA "5F0700E50500BE0400280700A504006F0600300500B407009A0B00D80A00080B00D30800E207008F"
20250 DATA "09003608002D0A00C20A00C00700EC0700070800E008004F0800AD0800320F00680900640700D407"
20260 DATA "001B0800A30B00E40D00BC0E000A0F00150F005203005203007107007107008007009207003D0400"
20270 DATA "9104005004007604006304003D07004C0700300700150700590700150600CB0400220700B20400E2"
20280 DATA "0600340500CDD80D007CA2677DA36FD97CA2677DA36FD9C9CDD80D007CAA677DAB6FD97CAA677DAB"
20290 DATA "6FD9C9CDD80D007CB2677DB36FD97CB2677DB36FD9C9CDD80D007CAACB7CCD4D11003EDFCD731000"
20300 DATA "D90E0008C8C3F40D00CDD80D00CD7A0400B7CDED0E000E00F0C3F40D00CD810F00E0CD790F00CDB0"
20310 DATA "0E007AEE805718137CEE8067180DCD790F00E0CD810F00CDB00E000504C80D0CCAED0E00D9010000"
20320 DATA "00D97CAAF578B9DCED0E0078CBFCC4C70D00F17ACBFAFAFE0400CD790F00DCF50E00CBFC180DCD81"
20330 DATA "0F00DC0C0E00CD8B0E002FD9EB21008000B752ED42EBD9CCE70E00DCD50E00DC020F00CBBC0D0CCA"
20340 DATA "320F00B7F0CBFCC9CDB00E0005043E12CA5403000D0CC87CAA08CBFACBFCC5424B11000000D9424B"
20350 DATA "110000003EE0CD731000D9CB7AD9CC921000EBD9CB38CB19B752ED423FEBCCE70E00DCD50E00C1DC"
20360 DATA "020F001F79983FC3550600D978B1B2B3D9205478B728067AB7281A184A7AB72802182B7B515FED5C"
20370 DATA "AFED62D9AFED62EBAFED62D9C97B515FED5C4FED4C7A81573E0088B7ED62D95FAF57ED62D9C97A51"
20380 DATA "ED5C414FED4C7A81573E0088B7ED62D95FAF57ED62D9C93EDFC3A810007CAACD4D1100CD830500D9"
20390 DATA "0EBFCD070300200FCB7A200BCDED0E004A08F0C3F40D000DCD1E1100F207060008F8CBBCC90504CA"
20400 DATA "320F000D0CC87CAA08CBFACBFCC5444DB7ED62D9444DED623EE0CDA81000DCBE1000D9E521008000"
20410 DATA "B752ED52E1CCE70E00DCD50E00C1DC020F001F79883806F2320F001804FA040F00C6804FCA320F00"
20420 DATA "08CBBCF0CBFCC9CDED0E00CB7CF5C4F40D00480620CD9E0F00380810F8F1D92CD94CC9F1C5EBE5D9"
20430 DATA "EBE5D9DD21000000DD39283BC5D9D5D9D5CDBC0E00CD140A00CD2803001821C5D9CB23CB12D5D9CB"
20440 DATA "13CB12D53E0AF5CDB20F00CD5A0300F1CD0E0300DC5A0300D1D9D1D979C14F10D6F1F1F1C9F1F1F1"
20450 DATA "1898CB7AF5CDED0E00CDC20F000D0C28EC3E9EB9380A3CCDC70D0008F2DD0600CDED0E00CD310A00"
20460 DATA "CDCB0F00F1CD150600C3930900CD3C0F001804CD2E0F00D01842CD3C0F001804CD2E0F00C8D81834"
20470 DATA "CD3C0F001804CD2E0F00D81827CD3C0F001804CD2E0F00281BD01818CD3C0F001804CD2E0F00C818"
20480 DATA "0BCD3C0F001804CD2E0F00C021FFFFFFD921FFFFFFD9AF4FC9CDA40700C8D95229D952ED6A10F7C9"
20490 DATA "CDA40700C8CB2CCB1DD9CB1CCB1DD910F4C9CDA40700C8CB3CCB1DD9CB1CCB1DD910F4C9CDD80D00"
20500 DATA "7AB3D9B27BD90620C047B7C9CB7CC80D0CCAF40D00CBBCC9CDE40D007C2F677D2F6FD97C2F677D2F"
20510 DATA "6FD9AFC9210F4900D921A2DA00D90E81AFC9CDF60700CD150600AFC9CDF60700CD340500AFC9CDBC"
20520 DATA "0E00112E6500D911D3E000D90685C9CD070300B1C8CB7CC2640700CD320F00C3D50E00CD3B1100F5"
20530 DATA "CD090D00F1FE2D3E00C00D0CCAF40D007CEE8067AFC90D0CC83E9F44CDC70D0008A0FCD50E0078B7"
20540 DATA "FCF40D00AF4FC9CDBC0E00CB7C3E15C25403000D0CC8CBFCCB41CCF50E0079D680CB2FC6804FC5EB"
20550 DATA "21000000444DD9EB21000000444D3EE1CDE01000D9CB78D9CCE01000CD011100B7CD921000CB1B60"
20560 DATA "69D96069DCD50E00C1DC020F001F9F814FCBBCAFC9CDBC0E00CDC20F00CDD70800CDCB0F00CDC20F"
20570 DATA "00CDED0E00CDE40800CDCB0F00CD340500AFC9CDBC0E00CD1C0E001C1C7B1810CDBC0E00E5CD1C0E"
20580 DATA "00F1070707E604ABF5CBBC1FCD820900DCB80400F1F5E603E2390900CDC20F00CDBA0F00CDFF0F00"
20590 DATA "B7A811366D26DE05D073C0808808799DAAAAAA7D0000000080CDCB0F00CDCB0F00CD150600C35E09"
20600 DATA "00CDBA0F00CDFF0F0071D5784C70AF9403B676C89CAA2A7BDDFFFFFF7E0000000080CDCB0F00F1E6"
20610 DATA "04C80D0CC8CBFCC921000000D921000000D90E80C911000000D911000000D90680C9110F4900D911"
20620 DATA "A2DA00D9067FC9CDBC0E00CD200A00D91D01CFD100D9E5CD2F0E00F1CB7B280B17DA320F003E18C3"
20630 DATA "540300E680B3F5CBBCCDC20F00CDFF0F0072402E9473656F4F2E76376D02887912E5A02A7B144FAA"
20640 DATA "AA7D56FDFF7F7EFEFFFFFF7F0000000080CDCB0F00F1F5F4140A00F1F2FC0900E67FED44C6808138"
20650 DATA "06F2320F001804FA040F00C680CA320F004FAFC9CD750900CDED0E00C334050011723100D911F817"
20660 DATA "00D9067FC9CDBC0E003E16CB7CC25403000C0DCA54030011043500D91133F300D9CD450F00790E80"
20670 DATA "38020D3CF5CDD70F00CDC20F00CDBA0F00CDFF0F0048CCFB747DAFAEFF117E8CD9CD4C7EE3A9AA2A"
20680 DATA "7F0000000081CDCB0F00CDCB0F00CD150600F1CDC20F0008CD320F0008D680281F30022F3C670E87"
20690 DATA "F5CD9E0E00CBBCCD200A00CD150600F13006FAB80A00CBFCCDCB0F00CDCB0400AFC9CD2D0A00115B"
20700 DATA "5E00D911A9D800D9067ECD150600AFC9CDBC0E00CDC20F00CDB20F00CD150600CD750900CDB80400"
20710 DATA "CD530800CDCB0F000C0D3E02D5CA820B00D1CD180A001804CDBC0E00E5CBBC11135400D911D0CC00"
20720 DATA "D9067ECD420F000600382211821A00D9119A7900D90681CD420F00380ACD140A000602C3450B00CD"
20730 DATA "D70F000601C5CDC20F00CDBA0F00CDFF0F0035F3D8377B916BB9AA7CDE4197617C7B9D37927D5A2A"
20740 DATA "CC4C7D5CA9AAAA7E0000000080CDCB0F00CDCB0F00CD150600F1CD8209001FF5DCCB0400F1041FDC"
20750 DATA "B80400F1B7F0CBFCAFC9CDD80A003E02F518DFCDBC0E000600CB7C2806CBBC3E2D1213AFB9284ED5"
20760 DATA "78F579FEA1301CFE9B30292FFEE138023EF8C61CCD2E1000F5CD150600F147F19018DED620CD2E10"
20770 DATA "00F5CD340500F147F18018CD3E09CD2E1000CD420F0079C14FCBFCDC6A0F00D1CBB93E00170C0878"
20780 DATA "DDCB024E2008AFDDBE01280B3EF6DD8601B7FA1F0C00AFF508CD9E0F008FFE0A3805D60AD92CD90D"
20790 DATA "20EF4F7CE63F67F1F2460C003C201C3E04B93E001815F579CE30FE302805FE3A3F3008E3CB75E320"
20800 DATA "053E303C3DF504CD0703000E203E0020B8F1F53E0038B2EB0EFF1601DD5E01DDCB02462035DDCB02"
20810 DATA "4E281278B72805FA8C0C00507ADD86015FFE0B38197811010100B7FAB20C00280DDD7E01B720023E"
20820 DATA "0AB83806505878C6814FCBFA1D7AB9300EF12804F2C90C00F51C1DFADA0C003E3015E2D10C00362E"
20830 DATA "2377231DF2B50C0018DFF10C4D2028364523783DF2ED0C00362D23ED4436302815FE0A473E3A3803"
20840 DATA "23363034BE200536302B342310F523EBC9CD320F000E00CD9D0D00FE2E0600CC9B0D00FE453E00CC"
20850 DATA "690D00CB7C2008B72005B82002B9C890810E9FCD9E0E00CBBCB7C8FA490D00CD2E1000CD150600AF"
20860 DATA "C9FEDA380CED44CD2E1000CD340500AFC9F53E26CD2E1000CD340500F1C62618E0C5470E02DD23CD"
20870 DATA "3B110008CD3111003818788787808747DD7E00DD23E60F80470DF2740D00066418E208FE2D78C1C0"
20880 DATA "ED44C9DD23CD311100D804DD23CD8B0F0038150D0C2011E60FD906004F5209D930E352237CB520DD"
20890 DATA "0CCDF00E0018D608AF08CBFCCDF50E00B9C830F8C3040F00CDED0E00CDE40D00CDED0E000D0CC8CB"
20900 DATA "7CF53E9FCDC70D00F10E00C8B7D9D5EB2100000052ED52D1D9D5EB2100000052ED52D1C9D92FE5B7"
20910 DATA "2100000052ED42444DE118DA3E96B93E17DA540300CD820900D901692100D9CBFACBFC790E00DD21"
20920 DATA "000000DDE5B83846D9E352ED42E352ED52D952ED52300CD9E35209E352ED5AD952ED5A3FCB113002"
20930 DATA "CBF93DB8381FE35229E3D952ED6AD952ED6A30CCB7D9E352ED42E352ED52D952ED52B718D63C594F"
20940 DATA "D9C1D9CB7CC0D9CB21CB1052ED6AD952ED6A0D20EEC9CB7CC0D95229D952ED6A0D20F3C908C63008"
20950 DATA "CDED0E00CDBC0E00CDED0E000D0CC0CD070300C87CB7FCF40D000E9FCD9E0E00B7F8CBBCC9D90101"
20960 DATA "00005209D9D0C5010100005209C1C9B7D9CBC5D9C9794847EBD9EBD9C9CDA70F00D9CB18CB1908B0"
20970 DATA "08D90CC03E14C3540300CD070300C87CE680F640C978B1200BCD2E0F003E00C83E801FC9CDB00E00"
20980 DATA "CD3C0F0018EFCD610F003E00D9676FD9676F4FC9CD530F0018F079B8C052ED525219C0D952ED5252"
20990 DATA "19D9C97CAA7C17F830E8CD420F00C83FC97CAAF2450F007C17C9050CCDB30F00CDA60F00CDA60F00"
21000 DATA "08D95219D952ED5AC9D9B752ED52D952ED52C9CDB30F00CD9E0F00D8CD9E0F00D8CD790F00D8D952"
21010 DATA "29D952ED6AC90CCB3CCB1DD9CB1CCB1DD9C941545DD9545DD9C9CDB20F00CD150600DDE1C5E5D9E5"
21020 DATA "D9DDE9DDE1D9D1D9D179C1414FDDE9CDC20F00CD750900CDCB0400CDCB0F00CDC20F00CDED0E00CD"
21030 DATA "750900CDB20400CDCB0F00C3340500DD21030000DD39DDE3CDDB0200CD15060011050000DD19CDDB"
21040 DATA "0200DDE30405FACB0400CDCB0400CD0E0300DDE318DE3C08E5D9E5D9CD750900CDED0E00AF083D28"
21050 DATA "26F2491000B9381F3C083CCBFCCD6C0F00300608CDA60F000808DCD50E000CFA3D1000C3040F00CD"
21060 DATA "ED0E00CBBAD9E1D9E108C9B752ED42D952ED42D930075209D952ED4AD93FCB13CB12D9CB13CB12D9"
21070 DATA "3CF052ED6AD952ED6AD930D8B752ED42D952ED42D93718DEB7D9CB1ACB1BD9CB1ACB1B30075209D9"
21080 DATA "52ED4AD93CF0D9CB1CCB1DD9CB1CCB1D18DF52ED42D952ED42D90C30090D5209D952ED4AD90D3CF0"
21090 DATA "CB21CB100CD9CB11CB10CD1E1100CD1E1100D930D5B752ED42D952ED42D90C18DD5229D952ED6AD9"
21100 DATA "38EB3C0C52ED42D952ED42D9D05209D952ED4AD90DC9D9CB23CB12D9CB13CB12D952ED6AD952ED6A"
21110 DATA "C9DD7E00FE3A3FD8FE30C9DD7E00DD23FE2028F7FE2BC8FE2DC8DD2BC908CB7CC4F40D00CDED0E00"
21120 DATA "CB7CC4F40D00444D21000000D9444D21000000C9"
21130 DATA 80,86,120,124,146,226,239,245,255,272,319,349,704,709,719,843,870,876,893,896
21140 DATA 899,902,905,908,911,914,917,920,923,926,929,932,935,938,941,944,947,950,953,956
21150 DATA 959,962,965,968,971,974,977,980,983,986,989,992,995,998,1001,1004,1007,1010,1013,1016
21160 DATA 1019,1022,1025,1028,1031,1034,1037,1040,1043,1046,1049,1052,1055,1058,1061,1064,1067,1070,1073,1076
21170 DATA 1079,1082,1086,1105,1124,1143,1151,1157,1166,1170,1174,1179,1186,1190,1195,1199,1215,1220,1224,1233
21180 DATA 1248,1255,1263,1267,1271,1279,1283,1287,1304,1308,1312,1320,1329,1337,1367,1375,1391,1395,1400,1408
21190 DATA 1506,1512,1516,1523,1533,1540,1545,1549,1560,1587,1591,1606,1610,1615,1624,1630,1637,1648,1655,1662
21200 DATA 1698,1702,1706,1728,1732,1737,1741,1766,1770,1784,1789,1793,1797,1801,1806,1810,1814,1820,1827,1833
21210 DATA 1841,1847,1854,1860,1869,1875,1882,1888,1906,1921,1939,1957,1978,1985,2019,2023,2029,2033,2039,2056
21220 DATA 2064,2068,2072,2076,2081,2093,2109,2115,2121,2128,2136,2147,2177,2185,2189,2194,2205,2210,2222,2226
21230 DATA 2230,2234,2238,2242,2246,2250,2254,2260,2264,2273,2278,2293,2297,2305,2309,2313,2317,2346,2350,2354
21240 DATA 2358,2362,2366,2395,2448,2452,2464,2474,2480,2490,2494,2538,2544,2549,2562,2568,2574,2581,2585,2589
21250 DATA 2606,2614,2620,2634,2646,2650,2654,2658,2687,2691,2695,2700,2705,2722,2728,2732,2739,2745,2749,2755
21260 DATA 2771,2777,2781,2785,2789,2793,2797,2801,2805,2814,2819,2825,2844,2864,2870,2876,2880,2887,2891,2895
21270 DATA 2934,2938,2942,2947,2953,2960,2971,2980,3021,3026,3038,3043,3055,3059,3068,3099,3106,3129,3168,3208
21280 DATA 3228,3261,3268,3275,3285,3301,3338,3344,3352,3360,3380,3388,3392,3396,3408,3412,3421,3425,3440,3445
21290 DATA 3467,3486,3494,3522,3533,3541,3545,3549,3553,3565,3618,3622,3761,3765,3769,3776,3783,3789,3830,3847
21300 DATA 3851,3866,3877,3881,3887,3901,3931,3940,3949,3953,3957,3980,3984,3989,3994,4027,4031,4056,4060,4064
21310 DATA 4068,4072,4076,4080,4084,4088,4092,4105,4109,4119,4127,4131,4135,4149,4153,4162,4174,4181,4187,4192
21320 DATA 4196,4200,4331,4335,4433,4437,4443
30000 DATA 633,2,0,14,37,82,234,264,272,283,326,369,481,533,623
30010 DATA "E1DDE5D1010000004E03EDB0E5C9FD7E00DD7700B7C8010000004FFD2702DDE5D113EDB0C9DD7E00"
30020 DATA "47FD4E0081381EDD770079B7C8DDE5E123110000005819EBFDE5E123010000004FEDB0AFC93E13B7"
30030 DATA "37C9DDE5FDE5E5DD7E01FDBE00306DFDE5E5FDE1FD1700FD2703FDE1E5D5DD270201000000DD4E01"
30040 DATA "09B7ED522816FD4E00DD7E01B728130E0179FDBE00300BCB210C18F5DD1702FD4E0079E1E1D5E5EB"
30050 DATA "010000004F09B7ED52380C280AE1E1E1FDE1DDE1AF37C919D1D1C1C5FDE5C5FDE1FD2F00FDE1DD77"
30060 DATA "01DD1F02FD7E00DD7700B7280E010000004FDD1702FDE5E123EDB0E1FDE1DDE1AFC9DD460078B7C8"
30070 DATA "DDE5FDE5DDE5E1237EC5E549D7E1C12310F6FDE1DDE1AFC9DDBE00D0DD7700C94FDD7E00B9D8C891"
30080 DATA "41180EB7C83D4FDD7E0091381C281A4779DD7000DDE5E123E5D1010000004F09DD4E0079B7C8EDB0"
30090 DATA "C9AFDD7700C9DD4600FD4E00DDE5E123FDE5D11378B7281079B728121ABE380E20092313050D18EC"
30100 DATA "79B7C83EFFC93E01C9F5DD7E00B7282AFD7E00B7282401000000DD4E00FD4600DDE5E123FDE5D113"
30110 DATA "F1B728013DE5CDA50100D12006B7ED527DC9F1AFC9C5010000004F09C191302EED444F1AC5F57901"
30120 DATA "0000004FF1EDB179C1201B4F05B8043815C5D5E5052808131ABE20032310F8E1D1C120D7AFC9F6FF"
30130 DATA "C9B7282D0100000047DD4E0079B7C8ED4C78B7C24D000079DD4600DD770090280E480600DDE5E123"
30140 DATA "E5D109EB4FEDB0AFC9DD7700C901000000444DC5E101000000FD4E00DD4600DD17027D3C200F2424"
30150 DATA "79BC30016778943001AF6F18127C3C200678D6023827677DB830227CB83803783D677C9538173CB9"
30160 DATA "38017901000000604FB72809EB19EBFDE5E123EDB0AFC9010000004E03EDB0AFC9"
30170 DATA 407,500
40000 DATA 8657,30,0,9,72,129,146,167,180,243,454,462,465,8657
40010 DATA "21D1010022CE0100C9DDE5E5C5D5F5DD2ACE010021D12100DDE5C1B7ED42281FF1D1C1E1DD7700DD"
40020 DATA "2F02DD1F05DD700801200000DD09DD22CE0100DDE1AFC9F1D1C1E1DDE1AF37C94F2ACE010011D101"
40030 DATA "00B7ED5228112ACE010011200000B7ED527EB92002AFC979FE013E2B281079FE023E2E280979FE03"
40040 DATA "3E2028023E26B737C92ACE010011200000B7ED5222CE0100AFC9F53E01CD480000C1D878B7C28100"
40050 DATA "002323ED27D1E93E02CD480000D82323ED27D1E93E03CD090000D8DDE5FDE5DDE5D1DD2ACE010001"
40060 DATA "E0FFFFDD09DDE5E10109000009EB01050000EDB0FDE5E101050000EDB0FD7E03E680DD7713FDE1DD"
40070 DATA "E1AFC9DDE5FDE5D53E03CD480000D1DAB70100E5FDE121000000B7ED52281DFD2705B7ED522815D5"
40080 DATA "CD8100003E03CD480000D130DE3E2137C3B701002100000022C9010022CB0100FD270511C9010001"
40090 DATA "000000FD4E08EDB0DD21C90100FDE5FDE5E1110E000019E5FDE13E0BCDC50100FDE13853FD7E08FE"
40100 DATA "052810FDE5DDE5FDE13E26CDC50100FDE1383C21C90100FD170501000000FD4E08EDB0FD7E13B73E"
40110 DATA "0C28023E08FDE5F5FDE5E11109000019E5FDE1F1CDC50100FDE1380B3AC90100B72809CD810000FD"
40120 DATA "E1DDE1C9FD2702FDE1DDE1D1E9C30000000000000000000000000000000000000000000000000000"
40130 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40140 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40150 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40160 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40170 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40180 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40190 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40200 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40210 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40220 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40230 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40240 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40250 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40260 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40270 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40280 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40290 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40300 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40310 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40320 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40330 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40340 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40350 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40360 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40370 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40380 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40390 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40400 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40410 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40420 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40430 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40440 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40450 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40460 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40470 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40480 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40490 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40500 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40510 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40520 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40530 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40540 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40550 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40560 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40570 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40580 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40590 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40600 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40610 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40620 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40630 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40640 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40650 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40660 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40670 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40680 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40690 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40700 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40710 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40720 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40730 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40740 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40750 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40760 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40770 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40780 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40790 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40800 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40810 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40820 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40830 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40840 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40850 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40860 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40870 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40880 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40890 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40900 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40910 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40920 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40930 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40940 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40950 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40960 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40970 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40980 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
40990 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41000 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41010 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41020 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41030 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41040 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41050 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41060 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41070 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41080 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41090 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41100 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41110 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41120 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41130 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41140 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41150 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41160 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41170 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41180 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41190 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41200 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41210 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41220 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41230 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41240 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41250 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41260 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41270 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41280 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41290 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41300 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41310 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41320 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41330 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41340 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41350 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41360 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41370 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41380 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41390 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41400 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41410 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41420 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41430 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41440 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41450 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41460 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41470 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41480 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41490 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41500 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41510 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41520 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41530 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41540 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41550 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41560 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41570 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41580 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41590 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41600 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41610 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41620 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41630 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41640 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41650 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41660 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41670 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41680 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41690 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41700 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41710 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41720 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41730 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41740 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41750 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41760 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41770 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41780 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41790 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41800 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41810 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41820 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41830 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41840 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41850 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41860 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41870 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41880 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41890 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41900 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41910 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41920 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41930 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41940 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41950 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41960 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41970 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41980 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
41990 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42000 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42010 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42020 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42030 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42040 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42050 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42060 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42070 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42080 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42090 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42100 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42110 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42120 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42130 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42140 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42150 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42160 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
42170 DATA "0000000000000000000000000000000000"
42180 DATA 1,5,17,21,56,74,78,87,130,141,150,158,170,183,196,251,256,281,287,297
42190 DATA 305,309,316,330,349,372,380,421,429,436
50000 DATA 783,58,0,10,20,215,268,397,747,751,755,759,762,556,401
50010 DATA "22FA0200ED53FD0200C92AFA02003E05C3EA0200DDE5FDE5F53E06CDEE020030123E05CDEE020030"
50020 DATA "0A3E07CDEE0200DAD10000F14F47FE8120020605DD7E00B7200DDD360001DDE5E123AF772310FC79"
50030 DATA "F5110E0000FE812004110D01002AFA020019ED5BFD0200B7ED5238092807F1AF37C3CC00002AFA02"
50040 DATA "00F1110E0000FE812004110D01001922000300FD2AFA0200DDE5E1FD2F0023FD2F03FD7706010000"
50050 DATA "004FFE8120020E05FDE5D113131313131313EDB02AFA02003E06CDEA0200380C2A00030022FA0200"
50060 DATA "FDE5E1AFFDE1DDE1C9F13E0C3718F5DDE5FDE5E5DDE1DD3103DD7E06FE81280B47FDE5E1AF772310"
50070 DATA "FC1813FD360000FD3601FFDDE5E1110E000019FD2F02FDE1DDE1AFC9DDE5FDE5F53E06CDEE0200C1"
50080 DATA "DA880100E521000000682929292929EBE1B7ED522323ED27E5DDE1CDD70000DD7E06FE812826FE05"
50090 DATA "2810DDE5FDE5DDE13E26CDF60200DDE1383101000000DD4E06DD1703FDE5E1EDB0AF181FFD7E00DD"
50100 DATA "170312B72815010000004FDDE5E1110E000019EBFDE5E123EDB0AFFDE1DDE1C93E0C3718F63E0518"
50110 DATA "023E0732030300DDE5FDE53E06CDEE0200382E2323ED27E5DDE122FA0200DD170301000000DD4E06"
50120 DATA "79FE8120020E05DDE5E123232323232323EDB0CDF2020018CA3A030300CDEE0200383FE5DDE13A03"
50130 DATA "0300FE072027DD2702DD1705DD7E08B7280B01000000470E05ED4CEDB0DD1709DD7E0CB728070100"
50140 DATA "000047EDB0DD270222FA0200CDF20200180D3A030300FE073E0728023E0D37FDE1DDE1C9DDE5FDE5"
50150 DATA "DD22040300FD2207030078320D030079320E03002AFA0200220A030011000000513A0D0300010000"
50160 DATA "00470E05ED4C091922000300ED5BFD0200B7ED5238082806AF37C3E502002A0A03003E07CDEA0200"
50170 DATA "DAE502003E07CDEE0200DAE50200E5DDE1ED5B040300DD1F053A0D0300DD7708ED5B070300DD1F09"
50180 DATA "3A0E0300DD770CED5B0A03002A0403003A0D0300B7280B01000000470E05ED4CEDB02A0703003A0E"
50190 DATA "0300B728070100000047EDB02A00030022FA0200AFFDE1DDE1C9C3000000C3000000C3000000C300"
50200 DATA "0000000000000000000000000000000000000000000000"
50210 DATA 1,6,11,17,28,36,44,48,94,100,114,118,136,141,181,187,193,197,276,281
50220 DATA 308,331,404,414,427,460,466,470,479,529,533,539,562,567,572,577,581,585,594,609
50230 DATA 614,627,631,637,641,647,651,659,666,674,681,689,693,697,715,719,733,737
60000 DATA 734,83,0,110,342,65,356
60010 DATA "E5DD170019380CE5DD0703B7ED4238092807E1E13E0BB737C9E1DD2F00C1D5E521000000B7ED4228"
60020 DATA "14EB3600E5D1130BE521000000B7ED42E12802EDB0E1D1AFC9FD7E03B7201DFD27002311000000B7"
60030 DATA "ED522815E5C1DD2700CD520200380ADD2F00AFC93E0AB737C93E0BB737C9DDE5FDE5DD2297020022"
60040 DATA "9A020032A9020032AA02007832AB0200DD270011000000B7ED52C24301003AA90200B7CA430100FE"
60050 DATA "11D243010032AD0200DD21AE020021010000229D0200FD7E03B7C2430100FD27002311000000B7ED"
60060 DATA "52CA470100DD2F00E5C12A9D0200CD520200DA470100229D020011050000FD19DD23DD23DD233AAA"
60070 DATA "02003D32AA020020BD010000003AAB02004FCD520200DA470100E5210003003AA902006FED6C2322"
60080 DATA "A30200D119DA470100DD2A9A0200CD000000DA4901002A970200ED1F21AD0200ED4BA30200EDB0C3"
60090 DATA "5001003E0A18023E0BFDE1DDE1B737C9FDE1DDE1AFC9DDE5FDE5F53E0132AC0200F1180BDDE5FDE5"
60100 DATA "F5AF32AC0200F132A9020032AA02007832AB0200DD270011020000B7ED52DA3A0200197EB7CA3A02"
60110 DATA "003AAC0200B728143AA90200BEDA460200C24C0200B7CA3A020018123AA90200BECABE0100D24C02"
60120 DATA "00B7CA50010023E5DDE121000000229D0200FD7E03B7C2400200FD270022A00200DD0700B7ED42D2"
60130 DATA "4002002A9D0200CD520200DA400200ED5BA0020019DA400200229D020011050000FD19DD23DD23DD"
60140 DATA "233AAA02003D32AA020020B63AAC0200B7CA500100010000003AAB02004FCD520200DA400200DDE5"
60150 DATA "D119DA400200C35001003E0EC34901003E0FC34901003E05C34901003E1BC3490100ED43A6020011"
60160 DATA "000000EB3AA60200CB47280219D83AA80200CB3F32A802003AA70200CB1F32A702003AA60200CB1F"
60170 DATA "32A602004F3AA70200B14F3AA80200B1C8EB29EBD818C50000000000000000000000000000000000"
60180 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
60190 DATA "0000000000000000000000000000"
60200 DATA 90,116,120,124,128,133,147,151,156,162,166,171,179,187,202,211,215,219,223,239
60210 DATA 244,254,259,263,272,280,286,291,295,299,303,309,314,320,350,363,368,372,377,391
60220 DATA 398,402,409,414,418,423,429,434,438,443,455,463,470,480,484,488,492,497,502,506
60230 DATA 522,527,533,538,546,551,555,563,567,573,579,585,591,596,605,615,621,625,631,635
60240 DATA 641,646,652
