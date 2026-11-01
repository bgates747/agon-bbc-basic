10 REM Native BBC BASIC compiler, bootstrap milestone C001
20 REM Compiler implementation is BBC BASIC; input is plain text.
30 ON ERROR REPORT:PRINT:CLOSE#0:END
40 PROCinit
50 INPUT LINE "Source file: "cinput$
60 INPUT LINE "Output file: "coutput$
70 PROCcompile(cinput$,coutput$)
80 PRINT "Wrote ";coutput$
90 END
1000 DEF PROCinit
1010 DIM ccode% 65535,csname$(1023),csaddr%(1023)
1020 DIM crname$(2047),craddr%(2047),crline%(2047),crcol%(2047)
1030 ENDPROC
1040 DEF PROCcompile(csource$,ctarget$)
1050 LOCAL ci%,cj%,cn%,cfh%,coh%
1060 cpc%=0:csnum%=0:crnum%=0:clnum%=0:cpos%=1:clast%=-1:ccr%=FALSE
1070 IF csource$=ctarget$ PROCbad("Source and output must differ")
1080 cfh%=OPENIN(csource$)
1090 IF cfh%=0 PROCbad("Cannot open source")
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
1520 LOCAL cn%,cw$,ct%
1530 PROCspace
1540 IF FNdigit(FNpeek) PROCnumberlabel
1570 PROCspace
1580 WHILE FNpeek<>""
1590 WHILE FNpeek=":":cpos%=cpos%+1:PROCspace:ENDWHILE
1595 IF FNpeek<>"" PROCstatement
1600 PROCspace
1610 IF FNpeek<>"" AND FNpeek<>":" PROCbad("Unexpected text after statement")
1615 ENDWHILE
1620 ENDPROC
1622 DEF PROCnumberlabel
1624 LOCAL cn%
1626 cn%=FNnumber(65279):IF cn%<=clast% PROCbad("Line numbers must increase")
1628 clast%=cn%:PROClabel("#"+STR$(cn%))
1630 ENDPROC
1632 DEF PROCstatement
1640 LOCAL cw$,ct%,cn$,csuppress%
1650 IF FNpeek="@" THEN cpos%=cpos%+1:cn$=FNname:PROCexpect(":"):PROClabel("@"+cn$):cpos%=cpos%-1:ENDPROC
1660 cw$=FNname
1670 IF cw$="REM" THEN cpos%=LEN(cline$)+1:ENDPROC
1680 IF cw$="PRINT" THEN PROCprint:ENDPROC
1690 IF cw$="VDU" THEN PROCvdu:ENDPROC
1700 IF cw$="CLS" THEN PROCcharacter(12):ENDPROC
1710 IF cw$="END" THEN PROCaddr("C3","$end"):ENDPROC
1720 IF cw$="RETURN" THEN PROCaddr("C3","$return"):ENDPROC
1730 IF cw$="GOTO" OR cw$="GOSUB" THEN PROCbranch(cw$):ENDPROC
1740 IF cw$="EVAL" PROCbad("EVAL is deliberately unsupported")
1750 PROCbad("Unsupported statement "+cw$)
1760 ENDPROC
1770 DEF PROCbranch(cw$)
1780 LOCAL cn$
1790 PROCspace
1800 IF FNpeek="@" THEN cpos%=cpos%+1:cn$="@"+FNname ELSE cn$="#"+STR$(FNnumber(65279))
1810 IF cw$="GOTO" THEN PROCaddr("C3",cn$) ELSE PROCaddr("21",cn$):PROCaddr("CD","$gosub")
1820 ENDPROC
1830 DEF PROCprint
1840 LOCAL cs$,cmore%,csuppress%
1850 PROCspace:csuppress%=FALSE
1860 IF FNpeek="" OR FNpeek=":" THEN PROCnewline:ENDPROC
1870 REPEAT
1880 IF FNpeek<>CHR$(34) PROCbad("PRINT requires a string literal; expressions and EVAL are unsupported")
1890 cs$=FNstring:PROCtext(cs$):PROCspace:cmore%=FALSE
1900 IF FNpeek=";" THEN cpos%=cpos%+1:PROCspace:csuppress%=TRUE:cmore%=(FNpeek<>"" AND FNpeek<>":")
1910 IF cmore% THEN csuppress%=FALSE
1920 UNTIL NOT cmore%
1930 IF NOT csuppress% PROCnewline
1940 ENDPROC
1950 DEF PROCvdu
1960 LOCAL cv%,cmore%
1970 REPEAT
1980 PROCspace:cv%=FNnumber(255):PROCcharacter(cv%):PROCspace
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
2510 LOCAL ci%,cfound%
2520 ci%=0:cfound%=-1
2530 WHILE ci%<csnum%
2532 IF csname$(ci%)=cn$ cfound%=ci%
2534 ci%=ci%+1
2540 ENDWHILE
2550 =cfound%
2560 DEF PROClabel(cn$)
2570 IF FNsymbol(cn$)>=0 PROCbad("Duplicate target "+cn$)
2580 IF csnum%=1024 PROCbad("Too many labels")
2590 csname$(csnum%)=cn$:csaddr%(csnum%)=&40000+cpc%:csnum%=csnum%+1
2600 ENDPROC
2610 DEF PROCaddr(ch$,cn$)
2620 PROCbytes(ch$)
2630 IF crnum%=2048 PROCbad("Too many address fixups")
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
3030 PROCaddr("32","$depth"):PROCbytes("E9")
3040 PROClabel("$return")
3050 PROCaddr("3A","$depth"):PROCbytes("B7")
3060 PROCaddr("CA","$badreturn"):PROCbytes("3D")
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
3230 ENDPROC
3240 DEF PROCbad(cm$)
3250 ERROR 100,LEFT$(csource$,80)+":"+STR$(clnum%)+":"+STR$(cpos%)+": "+LEFT$(cm$,130)
3260 ENDPROC
