10 REM C002 native numeric expression experiment, based on C001
20 REM Compiler implementation is BBC BASIC; input is plain text.
30 ON ERROR REPORT:PRINT:CLOSE#0:END
40 PROCinit
50 INPUT LINE "Source file: "input$
60 INPUT LINE "Output file: "output$
70 PROCcompile(input$,output$)
80 PRINT "Wrote ";output$
90 END
1000 DEF PROCinit
1010 DIM sname$(4095),saddr% 12287,sort% 8191,lrefs%(63)
1020 REM Output streams after layout and validation; no code/fixup buffers.
1021 DIM pname$(255),pline%(255),parcnt&(255),par&(255,15),argkind&(31,15),argindex&(31,15),pkind&(255),pret%(255),return$(511),retdef&(511),retline%(511),retcol%(511)
1022 PROCloadnumbers
1023 PROCloadacts
1024 DIM vname$(255),vsize&(255),vstatic%(255),vtype%(255),vdim&(255),kwords$(4)
1025 DIM sunsafe%(15)
1026 PROCkeywords
1027 PROCloadcontrol
1028 PROCloadstrings:PROCloadmemory:PROCloadio:PROCloaddata:PROCloaderrors:PROCloadcompact
1029 DIM ifid$(31),bid$(31),belse%(31),lkind%(31),lname$(31),lvar%(31)
1030 ENDPROC
1040 DEF PROCcompile(source$,target$)
1050 LOCAL i%,j%,n%,fh%,oh%
1060 pc%=0:snum%=0:lnum%=0:pos%=1:last%=-1:cr%=FALSE:phase%=1
1061 PROCclearrefs
1062 numeric%=FALSE:nslots%=0:nparse%=0:ndepth%=0:vnum%=0:strings%=FALSE:sdepth%=0:sslots%=0:svars%=0:valuekind%=0
1063 memory%=FALSE:dimparse%=0:io%=FALSE:fileio%=FALSE:compact%=FALSE
1064 flow%=0:bnum%=0
1065 dataused%=FALSE:dnumeric%=FALSE:dcapture%=FALSE:errors%=FALSE
1066 loops%=FALSE:ltop%=0:structure$=""
1068 acts%=FALSE:functions%=FALSE:pnum%=0:scope%=0:retnum%=0:calldepth%=0:kinddepth%=0
1070 IF source$=target$ PROCbad("Source and output must differ")
1080 fh%=OPENIN(source$)
1090 IF fh%=0 PROCbad("Cannot open source")
1092 PROCprocscan(fh%):CLOSE#fh%
1094 IF errors% PROCuseerrors
1095 FOR phase%=1 TO 3
1096 IF phase%=3 THEN oh%=OPENOUT(target$):IF oh%=0 PROCbad("Cannot open output")
1097 PROCpass
1098 NEXT:CLOSE#oh%:ENDPROC
1099 DEF PROCpass
1100 fh%=OPENIN(source$):IF fh%=0 PROCbad("Cannot reopen source")
1101 pc%=0:lnum%=0:pos%=1:last%=-1:cr%=FALSE:flow%=0:bnum%=0:ltop%=0:structure$="":scope%=0:ndepth%=0:sdepth%=0:calldepth%=0:kinddepth%=0
1102 PROCaddr("C3","$start")
1110 REPEAT:PROCbyte(0):UNTIL pc%=64
1120 PROCbytes("4D4F530001")
1130 start%=&40000+pc%
1140 REM Preserve MOS registers; saved SP occupies exactly three bytes.
1150 PROCbytes("F5C5D5DDE5FDE5")
1160 PROCaddr("ED73","$savedsp")
1170 PROCbytes("AF"):PROCaddr("32","$depth")
1180 WHILE NOT EOF#fh%
1190 lnum%=lnum%+1:pos%=1
1200 PROCreadline(fh%)
1210 PROCline
1220 ENDWHILE
1230 CLOSE#fh%:fh%=0
1232 IF bnum%<>0 PROCbad("Missing ENDIF")
1234 IF ltop%<>0 PROCbad("Missing loop terminator")
1240 PROCaddr("C3","$end")
1250 PROCruntime
1260 PROCdefine("$start",start%)
1270 ENDPROC
1370 DEF PROCreadline(h%)
1380 LOCAL b%,done%
1390 line$="":done%=FALSE
1400 WHILE NOT EOF#h% AND NOT done%
1410 b%=BGET#h%
1420 IF cr% AND b%=10 THEN
1422 cr%=FALSE
1424 ELSE
1426 IF b%=10 OR b%=13 THEN
1428 done%=TRUE
1430 ELSE
1432 IF b%=0 PROCbad("NUL byte in source")
1434 IF LEN(line$)=255 THEN pos%=256:PROCbad("Source line exceeds 255 bytes")
1436 line$=line$+CHR$(b%)
1438 ENDIF
1440 cr%=(b%=13)
1442 ENDIF
1444 ENDWHILE
1446 ENDPROC
1510 DEF PROCline
1520 LOCAL n%,w$,t%,inum%,leid$,cont%,first%,inseen%,declskip$,hskip$
1522 inum%=0:leid$="":first%=TRUE:inseen%=FALSE:declskip$="":hskip$="":basicline%=0:PROCprocscope
1530 PROCspace
1540 IF FNdigit(FNpeek) PROCnumberlabel
1570 PROCspace
1580 WHILE FNpeek<>""
1590 WHILE FNpeek=":":pos%=pos%+1:PROCspace:ENDWHILE
1595 cont%=FALSE:IF FNpeek<>"" PROCstatement
1600 PROCspace
1605 first%=FALSE
1610 IF FNpeek<>"" AND FNpeek<>":" AND NOT cont% AND NOT FNword("ELSE") PROCbad("Unexpected text after statement")
1615 ENDWHILE
1618 PROCiffalse:IF leid$<>"" PROClabel(leid$)
1619 IF declskip$<>"" PROClabel(declskip$)
1620 IF hskip$<>"" PROClabel(hskip$)
1621 ENDPROC
1622 DEF PROCnumberlabel
1624 LOCAL n%
1626 n%=FNnumber(65279):IF n%<=last% PROCbad("Line numbers must increase")
1628 last%=n%:basicline%=n%:IF FNlineref(n%,0,FALSE) PROClabel(FNtarget("#"+STR$(n%)))
1630 ENDPROC
1632 DEF PROCstatement
1640 LOCAL w$,t%,n$,suppress%
1641 PROCerrmark
1642 IF FNpeek="?" OR FNpeek="!" OR FNpeek="|" THEN PROCmemassign(FNpeek):ENDPROC
1645 IF FNpeek="=" THEN pos%=pos%+1:PROCfnreturn:ENDPROC
1650 IF FNpeek="@" THEN pos%=pos%+1:n$=FNname:PROCexpect(":"):PROClabel(FNtarget("@"+n$)):PROCerrmark:pos%=pos%-1:ENDPROC
1655 IF MID$(line$,pos%,4)="PROC" THEN pos%=pos%+4:PROCproccall:ENDPROC
1660 w$=FNname
1662 IF (w$="LEFT" OR w$="RIGHT" OR w$="MID") AND FNpeek="$" THEN pos%=pos%+1:PROCstrsliceassign(w$):ENDPROC
1663 IF w$="ON" THEN PROCerrorinstall:ENDPROC
1664 IF w$="IF" THEN PROCif:ENDPROC
1666 IF w$="ELSE" THEN PROCelse:ENDPROC
1668 IF w$="ENDIF" THEN PROCendif:ENDPROC
1669 IF w$="REPEAT" OR w$="WHILE" OR w$="FOR" THEN PROCloop(w$):ENDPROC
1670 IF w$="REM" THEN pos%=LEN(line$)+1:ENDPROC
1672 IF w$="UNTIL" OR w$="ENDWHILE" OR w$="NEXT" THEN PROCloopend(w$):ENDPROC
1673 IF w$="DIM" THEN PROCdim:ENDPROC
1674 IF w$="DEF" THEN PROCdefinition:ENDPROC
1676 IF w$="LOCAL" THEN PROClocal:ENDPROC
1678 IF w$="ENDPROC" THEN PROCuseacts:PROCaddr("CD","$actleave"):PROCaddr("DA","$acterror"):PROCbyte(&C9):ENDPROC
1679 IF w$="INPUT" THEN PROCinputline:ENDPROC
1680 IF w$="PRINT" THEN PROCprint:ENDPROC
1682 IF w$="CLOSE" THEN PROCclosestatement:ENDPROC
1684 IF w$="BPUT" THEN PROCbput:ENDPROC
1686 IF w$="DATA" THEN PROCdatastatement:ENDPROC
1687 IF w$="READ" THEN PROCreadstatement:ENDPROC
1688 IF w$="RESTORE" THEN PROCrestoredata:ENDPROC
1689 IF w$="ERROR" THEN PROCerrorstatement:ENDPROC
1690 IF w$="VDU" THEN PROCvdu:ENDPROC
1692 IF w$="REPORT" THEN PROCaddr("CD","$errreport"):ENDPROC
1700 IF w$="CLS" THEN PROCcharacter(12):ENDPROC
1710 IF w$="END" THEN PROCaddr("C3","$end"):ENDPROC
1720 IF w$="RETURN" THEN PROCaddr("C3","$return"):ENDPROC
1730 IF w$="GOTO" OR w$="GOSUB" THEN PROCbranch(w$):ENDPROC
1740 IF w$="EVAL" PROCbad("EVAL is deliberately unsupported")
1742 IF w$="LET" THEN w$=FNname:PROCassign(w$):ENDPROC
1744 IF FNreserved(w$) PROCbad("Unsupported statement "+w$)
1750 PROCassign(w$)
1760 ENDPROC
1770 DEF PROCbranch(w$)
1780 LOCAL n$
1790 PROCspace
1800 IF FNpeek="@" THEN pos%=pos%+1:n$="@"+FNname ELSE n$="#"+STR$(FNnumber(65279))
1805 n$=FNtarget(n$)
1810 IF w$="GOTO" THEN PROCaddr("C3",n$) ELSE PROCaddr("21",n$):PROCaddr("CD","$gosub"):PROCerrmark
1820 ENDPROC
1830 DEF PROCprint
1840 LOCAL s$,more%,suppress%,width%
1850 PROCspace:suppress%=FALSE:width%=10
1860 IF FNstmtend THEN PROCnewline:ENDPROC
1870 REPEAT
1872 WHILE FNpeek=";":pos%=pos%+1:PROCspace:suppress%=TRUE:width%=0:ENDWHILE
1874 more%=FALSE
1880 IF NOT FNstmtend THEN suppress%=FALSE:PROCprintitem
1920 UNTIL NOT more%
1930 IF NOT suppress% PROCnewline
1940 ENDPROC
1941 DEF PROCprintitem
1942 IF FNpeek=CHR$(34) THEN PROCprintstring ELSE PROCprintnumber
1943 PROCspace:more%=(FNpeek=";")
1944 ENDPROC
1945 DEF PROCprintnumber
1946 ndepth%=0:sdepth%=0:PROCexpr(1)
1947 IF valuekind%=1 THEN PROCprintstrvalue:ENDPROC
1948 PROCaddr("DD21","$v0"):PROCbyte(&3E):PROCbyte(width%):PROCaddr("CD","$numprint")
1949 PROCaddr("DA","$numerror"):ndepth%=0:ENDPROC
1950 DEF PROCvdu
1960 LOCAL v%,more%
1970 REPEAT
1980 PROCspace:ndepth%=0:PROCexpr(1):IF valuekind%<>0 PROCbad("Expected a numeric item")
1981 PROCnumindices(0,0)
1982 PROCnumcall(38):PROCbytes("DD7E0049D7"):ndepth%=0:PROCspace
1990 more%=(FNpeek=",")
2000 IF more% pos%=pos%+1
2010 UNTIL NOT more%
2020 ENDPROC
2030 DEF FNstring
2040 LOCAL s$,c$,done%,quote%
2050 PROCexpect(CHR$(34)):s$="":done%=FALSE
2060 REPEAT
2070 c$=FNpeek
2080 IF c$="" PROCbad("Unterminated string")
2090 pos%=pos%+1
2092 IF ASC(c$)<32 PROCbad("Use CHR$ for control bytes in strings")
2100 quote%=(c$=CHR$(34))
2105 IF quote% done%=(FNpeek<>CHR$(34))
2107 IF quote% AND NOT done% pos%=pos%+1
2110 IF NOT done% s$=s$+c$
2120 UNTIL done%
2130 =s$
2140 DEF FNname
2150 LOCAL n$
2160 PROCspace:n$=""
2170 IF NOT FNalpha(FNpeek) PROCbad("Expected a name")
2180 WHILE FNalpha(FNpeek) OR FNdigit(FNpeek)
2190 n$=n$+FNpeek:pos%=pos%+1
2200 ENDWHILE
2210 IF LEN(n$)>32 PROCbad("Name exceeds 32 characters")
2220 =n$
2230 DEF FNnumber(max%)
2240 LOCAL n%,base%,d%,c$,nread%
2250 PROCspace:n%=0:base%=10:nread%=0
2260 IF FNpeek="&" THEN base%=16:pos%=pos%+1
2270 REPEAT
2280 c$=FNpeek:d%=-1
2290 IF c$<>"" d%=INSTR("0123456789ABCDEF",c$)-1
2300 IF d%>=base% d%=-1
2310 IF d%>=0 THEN n%=n%*base%+d%:pos%=pos%+1:nread%=nread%+1
2320 IF n%>max% PROCbad("Number outside supported range")
2330 UNTIL d%<0
2340 IF nread%=0 PROCbad("Expected an unsigned integer constant")
2350 =n%
2360 DEF FNalpha(c$)
2370 =(LEN(c$)=1 AND INSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_",c$)>0)
2380 DEF FNdigit(c$)
2390 =(LEN(c$)=1 AND INSTR("0123456789",c$)>0)
2400 DEF FNpeek
2410 =MID$(line$,pos%,1)
2420 DEF PROCspace
2430 WHILE FNpeek=" " OR FNpeek=CHR$(9):pos%=pos%+1:ENDWHILE
2440 ENDPROC
2450 DEF PROCexpect(c$)
2460 PROCspace
2470 IF FNpeek<>c$ PROCbad("Expected "+c$)
2480 pos%=pos%+1
2490 ENDPROC
2500 DEF FNsymbol(n$)
2502 LOCAL lo%,hi%,mid%,i%,found%
2510 lo%=0:hi%=snum%-1:found%=-1
2520 WHILE lo%<=hi% AND found%<0
2522 mid%=(lo%+hi%) DIV 2:i%=FNsortindex(mid%)
2530 IF sname$(i%)=n$ THEN found%=i% ELSE IF sname$(i%)<n$ THEN lo%=mid%+1 ELSE hi%=mid%-1
2540 ENDWHILE
2542 sinsert%=lo%
2550 =found%
2560 DEF PROClabel(n$)
2570 PROCdefine(n$,&40000+pc%):ENDPROC
2610 DEF PROCaddr(h$,n$)
2620 LOCAL i%,v%:IF h$<>"" PROCbytes(h$)
2630 v%=0:IF phase%>1 THEN i%=FNsymbol(n$):IF i%<0 PROCbad("Undefined target "+n$)
2640 IF phase%>1 v%=FNsymboladdr(i%)
2650 PROCword24(v%):ENDPROC
2720 DEF PROCbyte(v%)
2730 IF &40000+pc%>=&B0000 PROCbad("Executable exceeds user RAM")
2740 IF phase%=3 BPUT#oh%,v%
2750 pc%=pc%+1:ENDPROC
2760 DEF PROCbytes(h$)
2770 LOCAL i%,a%,b%
2772 IF h$="" ENDPROC
2774 PROCcodecount(LEN(h$) DIV 2):IF phase%<>3 ENDPROC
2780 FOR i%=1 TO LEN(h$) STEP 2
2790 a%=INSTR("0123456789ABCDEF",MID$(h$,i%,1))-1
2800 b%=INSTR("0123456789ABCDEF",MID$(h$,i%+1,1))-1
2810 BPUT#oh%,a%*16+b%
2820 NEXT
2830 ENDPROC
2840 DEF PROCcharacter(v%)
2850 PROCbyte(&3E):PROCbyte(v%):PROCbytes("49D7")
2860 ENDPROC
2870 DEF PROCnewline
2880 PROCcharacter(13):PROCcharacter(10)
2890 ENDPROC
2900 DEF PROCtext(s$)
2910 LOCAL i%
2915 IF s$="" ENDPROC
2920 PROCaddr("CD","$print"):PROCbyte(LEN(s$))
2930 PROCstringbytes(s$)
2940 ENDPROC
2950 DEF PROCruntime
2960 PROClabel("$print")
2970 REM pop hl; ld bc,0; ld c,(hl); inc hl; push hl; add hl,bc
2980 REM ex (sp),hl; ld a,c; or a; ret z; rst.lis 18h; ret
2990 PROCbytes("E1010000004E23E509E379B7C849DFC9")
3000 PROClabel("$gosub")
3010 PROCaddr("3A","$depth"):PROCbytes("FEFF")
3020 PROCaddr("CA","$full"):PROCbytes("3C")
3025 IF loops% THEN PROCbytes("F5E53E04"):PROCaddr("CD","$ctlpush"):PROCbyte(&E1):PROCaddr("DA","$flowerror"):PROCbyte(&F1)
3030 PROCaddr("32","$depth"):PROCbytes("E9")
3040 PROClabel("$return")
3050 PROCaddr("3A","$depth"):PROCbytes("B7")
3060 PROCaddr("CA","$badreturn"):PROCbytes("3D")
3065 IF loops% THEN PROCbyte(&F5):PROCflowcheck(4):PROCaddr("CD","$ctlpop"):PROCbyte(&F1)
3070 PROCaddr("32","$depth"):PROCbytes("C9")
3080 PROClabel("$badreturn")
3090 PROCerrorconstant(38,"No GOSUB")
3110 PROClabel("$full")
3120 IF errors% THEN PROCerrorconstant(0,"Too many GOSUBs") ELSE PROCtext("Too many GOSUBs"):PROCnewline
3130 PROClabel("$error")
3140 PROCbytes("21010000"):PROCaddr("C3","$exit")
3150 PROClabel("$end")
3160 PROCbytes("21000000")
3170 PROClabel("$exit")
3180 REM ADL24 OK: saved SP is a three-byte address, not a BASIC integer.
3185 IF fileio% THEN PROCbytes("E5AF"):PROCaddr("CD","$ioclose"):PROCbyte(&E1)
3190 PROCaddr("ED7B","$savedsp")
3200 PROCbytes("FDE1DDE1D1C1F1C9")
3210 PROClabel("$savedsp"):PROCbytes("000000")
3220 PROClabel("$depth"):PROCbyte(0)
3221 IF numeric% PROCnumruntime
3222 IF io% PROCIOruntime
3223 IF dataused% PROCdataruntime
3224 IF vnum%>0 PROCvarruntime
3225 IF loops% PROCflowruntime
3226 IF acts% PROCactruntime
3227 IF errors% PROCerrorruntime
3228 IF dataused% PROCdatatable
3229 IF compact% PROCcompactruntime
3230 IF strings% PROCstrruntime
3231 IF memory% PROCmemoryruntime
3232 IF memory% PROCmemoryworkspace
3233 IF acts% PROCactworkspace
3234 ENDPROC
3240 DEF PROCbad(m$)
3250 ERROR 100,LEFT$(source$,80)+":"+STR$(lnum%)+":"+STR$(pos%)+": "+LEFT$(m$,130)
3260 ENDPROC
4000 DEF PROCloadnumbers
4010 LOCAL i%,j%,s$,a%,b%
4020 RESTORE 20000:READ nsize%,nrelocs%,nentry%,nliteral%,nnegate%,nprintnum%,nval%,nstrnum%,nstrhex%
4030 DIM nimage% nsize%-1,nreloc%(nrelocs%-1)
4040 FOR i%=0 TO nsize%-1 STEP 40
4050 READ s$
4060 FOR j%=1 TO LEN(s$) STEP 2
4062 a%=INSTR("0123456789ABCDEF",MID$(s$,j%,1))-1
4064 b%=INSTR("0123456789ABCDEF",MID$(s$,j%+1,1))-1
4070 nimage%?(i%+(j%-1) DIV 2)=a%*16+b%
4080 NEXT:NEXT
4090 FOR i%=0 TO nrelocs%-1:READ nreloc%(i%):NEXT
4100 ENDPROC
4110 DEF PROCnumslot
4120 IF ndepth%=32 PROCbad("Expression value stack exceeds 32")
4130 ndepth%=ndepth%+1:numeric%=TRUE
4140 IF ndepth%>nslots% nslots%=ndepth%
4150 ENDPROC
4160 DEF PROCvalue(v)
4170 LOCAL i%,p%
4172 IF dcapture% THEN PROCcapturenumber(v):ENDPROC
4180 PROCnumslot:valuekind%=0:PROCusecompact:PROCaddr("CD","$cplit"):PROCbyte(ndepth%-1)
4190 p%=^v
4200 PROCblob(p%,5)
4210 ENDPROC
4220 DEF PROCnumindices(l%,r%)
4230 PROCaddr("DD21","$v"+STR$(l%)):PROCaddr("FD21","$v"+STR$(r%))
4240 ENDPROC
4250 DEF PROCnumcall(o%)
4260 PROCbyte(&3E):PROCbyte(o%):PROCaddr("CD","$numop")
4270 PROCaddr("DA","$numerror")
4280 ENDPROC
4290 DEF PROCbinary(o%)
4300 PROCnumoperation(ndepth%-2,ndepth%-1,o%)
4310 ndepth%=ndepth%-1
4320 ENDPROC
4330 DEF PROCexpr(min%)
4340 LOCAL p%,o%,w%,done%,rel%,type%,frame%
4350 frame%=1:IF FNstringstart frame%=0
4352 nparse%=nparse%+frame%:IF nparse%>32 PROCbad("Expression nesting exceeds 32")
4360 PROCitem:type%=valuekind%:done%=FALSE:rel%=FALSE
4370 REPEAT
4380 o%=FNoperator:p%=nprec%:w%=nwidth%
4390 IF o%<0 OR p%<min% THEN done%=TRUE ELSE PROCexprtail
4400 UNTIL done%
4410 nparse%=nparse%-frame%
4420 ENDPROC
4430 DEF PROCexprtail
4440 IF p%=3 AND rel% PROCbad("Chained comparisons require parentheses")
4450 IF p%=3 rel%=TRUE
4460 pos%=pos%+w%:PROCexpr(p%+1):PROCtypedbinary:type%=valuekind%
4470 ENDPROC
4480 DEF FNoperator
4490 LOCAL s$,o%
4500 PROCspace:nprec%=0:nwidth%=0:s$=MID$(line$,pos%,3)
4510 IF LEFT$(s$,2)="<<" OR LEFT$(s$,2)=">>" PROCbad("Shift operators are unsupported")
4520 o%=-1
4530 IF LEFT$(s$,3)="EOR" THEN o%=2:nprec%=1:nwidth%=3
4540 IF LEFT$(s$,2)="OR" THEN o%=4:nprec%=1:nwidth%=2
4550 IF LEFT$(s$,3)="AND" THEN o%=0:nprec%=2:nwidth%=3
4560 IF LEFT$(s$,2)="<=" THEN o%=5:nprec%=3:nwidth%=2
4570 IF LEFT$(s$,2)="<>" THEN o%=6:nprec%=3:nwidth%=2
4580 IF LEFT$(s$,2)=">=" THEN o%=7:nprec%=3:nwidth%=2
4590 IF o%>=0 THEN =o%
4600 IF LEFT$(s$,1)="<" THEN o%=8:nprec%=3:nwidth%=1
4610 IF LEFT$(s$,1)="=" THEN o%=9:nprec%=3:nwidth%=1
4620 IF LEFT$(s$,1)=">" THEN o%=12:nprec%=3:nwidth%=1
4630 IF LEFT$(s$,1)="+" THEN o%=11:nprec%=4:nwidth%=1
4640 IF LEFT$(s$,1)="-" THEN o%=13:nprec%=4:nwidth%=1
4650 IF LEFT$(s$,1)="*" THEN o%=10:nprec%=5:nwidth%=1
4660 IF LEFT$(s$,1)="/" THEN o%=15:nprec%=5:nwidth%=1
4670 IF LEFT$(s$,3)="DIV" THEN o%=1:nprec%=5:nwidth%=3
4680 IF LEFT$(s$,3)="MOD" THEN o%=3:nprec%=5:nwidth%=3
4690 IF LEFT$(s$,1)="^" THEN o%=14:nprec%=6:nwidth%=1
4700 =o%
4710 DEF PROCitem
4720 LOCAL c$,done%
4730 nparse%=nparse%+1:IF nparse%>32 PROCbad("Expression nesting exceeds 32")
4740 PROCspace:c$=FNpeek:done%=FALSE:valuekind%=0
4750 IF c$="+" OR c$="-" THEN pos%=pos%+1:PROCitem:PROCneednumber:done%=TRUE
4760 IF c$="-" THEN PROCaddr("DD21","$v"+STR$(ndepth%-1)):PROCaddr("CD","$numneg")
4770 IF c$="(" THEN pos%=pos%+1:PROCexpr(1):PROCexpect(")"):done%=TRUE
4780 IF c$="&" OR c$="." OR FNdigit(c$) THEN PROCconstant:done%=TRUE
4782 IF NOT done% THEN IF c$="^" OR c$="?" OR c$="!" OR c$="|" THEN PROCmemitem(c$):done%=TRUE
4785 IF NOT done% AND MID$(line$,pos%,2)="FN" THEN pos%=pos%+2:PROCfncall:done%=TRUE
4790 IF NOT done% PROCtypeditem
4800 nparse%=nparse%-1
4810 ENDPROC
4820 DEF PROCworditem
4830 LOCAL w$,i%,f%,l%
4832 f%=-1
4833 FOR i%=0 TO 15
4834 w$=MID$("ABSACSASNATNCOSDEGEXPINTLN LOGNOTRADSGNSINSQRTAN",i%*3+1,3)
4835 IF RIGHT$(w$,1)=" " w$=LEFT$(w$,2)
4836 l%=LEN(w$)
4837 IF MID$(line$,pos%,l%)=w$ AND NOT FNalpha(MID$(line$,pos%+l%,1)) f%=i%+16
4838 IF f%>=0 i%=15
4839 NEXT
4840 IF f%>=0 THEN pos%=pos%+l%:PROCitem:PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,f%):ENDPROC
4842 IF NOT FNalpha(FNpeek) PROCbad("Expected a numeric item")
4850 w$=FNname
4860 IF w$="TRUE" THEN PROCvalue(-1):ENDPROC
4870 IF w$="FALSE" THEN PROCvalue(0):ENDPROC
4872 IF w$="LEN" THEN PROCstrlen:ENDPROC
4874 IF w$="VAL" THEN PROCstrval:ENDPROC
4876 IF w$="ASC" THEN PROCstrasc:ENDPROC
4878 IF w$="INSTR" THEN PROCstrinstr:ENDPROC
4880 IF w$="PI" THEN PROCvalue(0):PROCnumoperation(ndepth%-1,ndepth%-1,35):ENDPROC
4882 IF w$="OPENIN" OR w$="OPENOUT" OR w$="OPENUP" OR w$="BGET" OR w$="EOF" THEN PROCioitem(w$):ENDPROC
4884 IF w$="ERR" OR w$="ERL" THEN PROCerritem(w$):ENDPROC
4890 IF w$="EVAL" PROCbad("EVAL is deliberately unsupported")
4892 IF FNreserved(w$) PROCbad("Unsupported numeric item "+w$)
4900 PROCvariable(w$)
4910 ENDPROC
4920 DEF PROCconstant
4930 IF FNpeek<>"&" THEN PROCdecimal:ENDPROC
4940 LOCAL v,d%,c$,n%
4950 v=0:n%=0:pos%=pos%+1
4960 REPEAT
4970 c$=FNpeek:d%=-1
4980 IF c$<>"" d%=INSTR("0123456789ABCDEF",c$)-1
4990 IF d%>=0 THEN v=v*16+d%:n%=n%+1:pos%=pos%+1
5000 IF n%>8 PROCbad("Hex literal exceeds eight digits")
5020 UNTIL d%<0
5030 IF n%=0 PROCbad("Expected digits in numeric literal")
5050 PROCpacked(v,0)
5100 ENDPROC
5101 DEF PROCdecimal
5102 LOCAL s%,v
5103 s%=pos%
5104 WHILE FNdigit(FNpeek):pos%=pos%+1:ENDWHILE
5105 IF FNpeek="." THEN pos%=pos%+1:WHILE FNdigit(FNpeek):pos%=pos%+1:ENDWHILE
5106 IF FNpeek="E" AND MID$(line$,pos%,3)<>"EOR" PROCdecexponent
5107 numerr%=0:v=FNreaddecimal(MID$(line$,s%,pos%-s%)):PROCvalue(v)
5108 IF numerr%<>0 AND NOT dcapture% THEN PROCbyte(&3E):PROCbyte(numerr%):PROCaddr("C3","$numerror")
5109 ENDPROC
5110 DEF PROCdecexponent
5111 pos%=pos%+1
5112 WHILE FNpeek=" ":pos%=pos%+1:ENDWHILE
5113 IF FNpeek="+" OR FNpeek="-" pos%=pos%+1
5114 WHILE FNdigit(FNpeek):pos%=pos%+1:ENDWHILE
5115 IF FNalpha(FNpeek) PROCbad("Unsupported crunched text after exponent")
5116 ENDPROC
5120 DEF FNreaddecimal(s$)
5121 LOCAL ERROR
5122 ON ERROR LOCAL numerr%=ERR:=0
5123 =VAL(s$)
5184 DEF PROCpacked(v,e%)
5185 LOCAL i%,q
5186 IF dcapture% THEN PROCcapturepacked(v,e%):ENDPROC
5187 PROCnumslot:PROCusecompact:PROCaddr("CD","$cplit"):PROCbyte(ndepth%-1)
5188 PROCcodecount(5):IF phase%<>3 ENDPROC
5189 FOR i%=0 TO 3:q=INT(v/256):BPUT#oh%,v-q*256:v=q:NEXT
5190 BPUT#oh%,e%
5191 ENDPROC
5193 DEF PROCnumruntime
5194 LOCAL i%,p%,v%,base%,n$,m$
5200 base%=pc%:PROCtemplate(nimage%,nsize%,nrelocs%,0)
5270 PROCdefine("$numop",&40000+base%+nentry%)
5280 PROCdefine("$numlit",&40000+base%+nliteral%)
5290 PROCdefine("$numneg",&40000+base%+nnegate%)
5292 PROCdefine("$numprint",&40000+base%+nprintnum%)
5294 PROCdefine("$numval",&40000+base%+nval%)
5296 PROCdefine("$numstr",&40000+base%+nstrnum%)
5298 PROCdefine("$numhex",&40000+base%+nstrhex%)
5300 FOR i%=0 TO nslots%-1
5310 PROClabel("$v"+STR$(i%)):PROCbytes("0000000000")
5320 NEXT
5330 PROClabel("$numerror")
5340 FOR i%=0 TO 5
5350 PROCbytes("FE"):PROCbyte(18+i%+ABS(i%>0))
5360 PROCaddr("CA","$ne"+STR$(i%))
5370 NEXT
5380 PROCerrorconstant(-1,"Numeric error")
5390 FOR i%=0 TO 5
5400 PROClabel("$ne"+STR$(i%))
5410 m$=MID$("Division by zero Number too big   -ve root         Log range        Accuracy lost    Exponent range   ",i%*17+1,17)
5420 WHILE RIGHT$(m$,1)=" ":m$=LEFT$(m$,LEN(m$)-1):ENDWHILE
5430 PROCerrorconstant(18+i%+ABS(i%>0),m$)
5440 NEXT
5450 ENDPROC
6000 DEF FNvariable(n$)
6010 LOCAL i%,f%,t%,s%,w%
6020 t%=5:s%=FALSE
6030 IF FNpeek="%" THEN t%=4:s%=(LEN(n$)=1 AND INSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ",n$)>0)
6040 IF FNpeek="&" t%=1
6042 IF FNpeek="$" t%=129
6044 IF t%=129 AND FNstrreserved(n$) PROCbad("Unsupported string item "+n$)
6050 IF t%<>5 THEN n$=n$+FNpeek:pos%=pos%+1
6060 IF FNpeek="$" PROCbad("Unsupported string suffix")
6070 IF FNpeek="(" THEN n$=n$+"(":t%=t%+256:s%=FALSE
6080 IF FNpeek="%" OR FNpeek="&" OR FNpeek="#" PROCbad("Unsupported numeric suffix")
6090 IF FNpeek="|" PROCbad("Binary variant indirection is unsupported")
6100 f%=-1:i%=0
6102 WHILE i%<vnum%
6104 IF vname$(i%)=n$ f%=i%
6106 i%=i%+1
6110 ENDWHILE
6120 IF f%>=0 THEN =f%
6130 IF vnum%=256 PROCbad("Variable limit exceeds 256")
6140 w%=t% AND 255:IF w%=129 THEN w%=5:strings%=TRUE:svars%=svars%+1
6141 IF t%>255 w%=3
6142 f%=vnum%:vname$(f%)=n$:vsize&(f%)=w%:vtype%(f%)=t%:vstatic%(f%)=s%:vdim&(f%)=0:vnum%=vnum%+1
6150 =f%
6160 DEF PROCassign(n$)
6170 LOCAL i%,t%
6180 IF FNreserved(n$) PROCbad("Unsupported variable name "+n$)
6190 i%=FNvariable(n$):t%=vtype%(i%)
6191 IF t%>255 THEN PROCarrayassign(i%):ENDPROC
6192 IF FNpeek="?" OR FNpeek="!" THEN PROCindirectassign(i%):ENDPROC
6193 PROCexpect("=")
6194 IF t%=129 THEN PROCstrassign(i%):ENDPROC
6200 REM ASSIGN creates a missing destination before the RHS is evaluated.
6210 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%))
6220 ndepth%=0:PROCexpr(1):PROCneednumber
6230 PROCusecompact:PROCaddr("CD","$cpstore"+STR$(t%))
6240 PROCaddr("","$var"+STR$(i%)):ndepth%=0
6250 ENDPROC
6260 DEF PROCvariable(n$)
6270 LOCAL i%:i%=FNvariable(n$)
6280 IF vtype%(i%)>255 THEN PROCarrayread(i%):ENDPROC
6290 PROCreadscalar(i%):PROCmemtail
6330 ENDPROC
6340 DEF PROCvarcopy(f$,t$,n%)
6350 PROCaddr("21",f$):PROCaddr("11",t$)
6360 PROCbyte(&01):PROCbyte(n%):PROCbytes("0000EDB0")
6370 ENDPROC
6380 DEF PROCvarruntime
6390 LOCAL i%,j%
6400 PROClabel("$novar"):PROCerrorconstant(26,"No such variable")
6410 FOR i%=0 TO vnum%-1
6420 PROClabel("$bind"+STR$(i%)):PROCbyte(ABS(vstatic%(i%)))
6430 PROClabel("$var"+STR$(i%)):PROCzeros(vsize&(i%))
6440 NEXT
6450 ENDPROC
6460 DEF PROCkeywords:LOCAL i%
6461 FOR i%=0 TO 4:kwords$(i%)="~|":NEXT
6462 kwords$(0)="AND|ABS|ACS|ADVAL|ASC|ASN|ATN|BGET!|BPUT!|BY!|COLOUR|COLOR|CALL|CASE|CHAIN|CLEAR!|CLOSE!|CLG!|CLS!|COS|COUNT!|CIRCLE|DATA|DEG|DEF|DIV|DIM|DRAW|ENDPROC!|ENDWHILE!|ENDCASE!|ENDIF!|END!|ENVELOPE|ELSE|EVAL|ERL!|"
6464 kwords$(1)="ERROR|EOF!|EOR|ERR!|EXIT!|EXP|EXT!|ELLIPSE|FOR|FALSE!|FILL|FN|GOTO|GET|GOSUB|GCOL|HIMEM|INPUT|INSTR|IF|INKEY|INT|INSTALL|LINE|LOMEM|LOCAL|LEN|LET|LOG|LN|MODE|MOD|MOVE|MOUSE|NEXT|NOT|ON|OFF!|OF!|ORIGIN|OR|OPENIN|"
6466 kwords$(2)="OPENOUT|OPENUP|OSCLI|OTHERWISE|PRINT|PAGE|PTR|PI!|PLOT|POINT!|PROC|POS!|PUT|QUIT!|RETURN!|REPEAT|REPORT!|READ|REM|RUN!|RAD|RESTORE|RND!|RECTANGLE|STEP|SGN|SIN|SQR|SPC|SOUND|STOP!|SUM|SWAP|SYS|TAN|THEN|TIME|"
6468 kwords$(3)="TO|TRACE|TRUE!|UNTIL|USR|VDU|VAL|VPOS!|WHILE|WHEN|WAIT!|WIDTH|"
6480 ENDPROC
6500 DEF FNreserved(n$)
6510 LOCAL k$,i%,j%,w$,b%,k%,f%
6512 IF ASC(n$)<65 OR ASC(n$)>90 THEN =FALSE
6514 f%=FALSE
6520 FOR k%=0 TO 4
6530 k$=kwords$(k%):i%=1
6540 REPEAT
6550 j%=INSTR(k$,"|",i%):w$=MID$(k$,i%,j%-i%):b%=(RIGHT$(w$,1)="!")
6560 IF b% w$=LEFT$(w$,LEN(w$)-1)
6570 IF LEFT$(n$,LEN(w$))=w$ AND (NOT b% OR LEN(n$)=LEN(w$)) f%=TRUE
6580 i%=j%+1
6590 UNTIL i%>LEN(k$)
6600 NEXT
6610 =f%
7000 DEF PROCloadstrings
7010 LOCAL i%,j%,s$,a%,b%
7020 RESTORE 30000:READ ssize%,srelocs%,sliteral%,sload%,scat%,sstore%,sprint%,sleft%,sright%,smid%,scmp%,sinstr%,srepeat%,swrite%,scopy%
7030 DIM simage% ssize%-1,sreloc%(srelocs%)
7040 FOR i%=0 TO ssize%-1 STEP 40
7050 READ s$
7060 FOR j%=1 TO LEN(s$) STEP 2
7070 a%=INSTR("0123456789ABCDEF",MID$(s$,j%,1))-1:b%=INSTR("0123456789ABCDEF",MID$(s$,j%+1,1))-1
7080 simage%?(i%+(j%-1) DIV 2)=a%*16+b%:NEXT:NEXT
7090 IF srelocs%>0 THEN FOR i%=0 TO srelocs%-1:READ sreloc%(i%):NEXT
7100 ENDPROC
7110 DEF FNstringstart
7120 LOCAL p%,c$
7130 p%=pos%
7140 WHILE MID$(line$,p%,1)=" " OR MID$(line$,p%,1)=CHR$(9) OR MID$(line$,p%,1)="(":p%=p%+1:ENDWHILE
7150 c$=MID$(line$,p%,1)
7155 IF MID$(line$,p%,2)="FN" THEN =FNfnstring(p%)
7160 IF c$=CHR$(34) OR MID$(line$,p%,4)="CHR$" THEN =TRUE
7170 WHILE FNalpha(MID$(line$,p%,1)) OR FNdigit(MID$(line$,p%,1)):p%=p%+1:ENDWHILE
7180 =(MID$(line$,p%,1)="$")
7190 DEF PROCprintstring
7200 LOCAL p%,s$
7210 p%=pos%
7220 IF FNpeek<>CHR$(34) THEN PROCprintnumber:ENDPROC
7230 s$=FNstring:PROCspace
7240 IF FNstmtend OR FNpeek=";" THEN PROCtext(s$):ENDPROC
7250 pos%=p%:PROCprintnumber
7260 ENDPROC
7270 DEF PROCprintstrvalue
7280 PROCaddr("DD21","$s"+STR$(sdepth%-1)):PROCaddr("CD","$strprint"):sdepth%=sdepth%-1
7290 ENDPROC
7300 DEF PROCstrslot
7310 IF sdepth%=16 PROCbad("String temporary limit exceeds 16")
7320 sdepth%=sdepth%+1:strings%=TRUE
7322 IF sdepth%>sslots% sslots%=sdepth%
7324 sunsafe%(sdepth%-1)=FALSE
7330 ENDPROC
7340 DEF PROCstrexpr
7350 PROCexpr(1):IF valuekind%<>1 PROCbad("Expected a string item")
7410 ENDPROC
7420 DEF PROCstritem
7430 PROCitem:IF valuekind%<>1 PROCbad("Expected a string item")
7440 ENDPROC
7460 DEF PROCstratom
7470 LOCAL s$,i%,j%
7480 IF FNpeek="(" THEN pos%=pos%+1:PROCstrexpr:PROCexpect(")"):ENDPROC
7490 IF MID$(line$,pos%,4)="CHR$" THEN pos%=pos%+4:PROCstrchr:ENDPROC
7491 IF MID$(line$,pos%,4)="STR$" THEN pos%=pos%+4:PROCstrnum:ENDPROC
7492 IF MID$(line$,pos%,5)="LEFT$" THEN pos%=pos%+5:PROCslice(0):ENDPROC
7494 IF MID$(line$,pos%,6)="RIGHT$" THEN pos%=pos%+6:PROCslice(1):ENDPROC
7496 IF MID$(line$,pos%,4)="MID$" THEN pos%=pos%+4:PROCslice(2):ENDPROC
7498 IF MID$(line$,pos%,7)="STRING$" THEN pos%=pos%+7:PROCstrrepeat:ENDPROC
7500 IF FNpeek=CHR$(34) THEN PROCstrliteral:ENDPROC
7510 IF NOT FNalpha(FNpeek) PROCbad("Expected a string item")
7520 s$=FNname:IF FNreserved(s$) PROCbad("Unsupported string item "+s$)
7530 i%=FNvariable(s$)
7532 IF vtype%(i%)>255 THEN PROCarrayread(i%):ENDPROC
7534 IF vtype%(i%)<>129 PROCbad("Expected a string variable")
7540 PROCaddr("3A","$bind"+STR$(i%)):PROCbyte(&B7):PROCaddr("CA","$novar")
7550 PROCstrslot:PROCaddr("DD21","$s"+STR$(sdepth%-1)):PROCaddr("FD21","$var"+STR$(i%)):PROCaddr("CD","$strload")
7560 ENDPROC
7570 DEF PROCstrliteral
7580 LOCAL s$,i%
7590 s$=FNstring:PROCstrslot:PROCaddr("DD21","$s"+STR$(sdepth%-1)):PROCaddr("CD","$strlit")
7600 PROCbyte(LEN(s$)):PROCstringbytes(s$)
7610 ENDPROC
7620 DEF PROCstrchr
7630 PROCitem:PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38):PROCstrslot
7640 PROCaddr("21","$s"+STR$(sdepth%-1)):PROCbytes("360123")
7650 PROCaddr("3A","$v"+STR$(ndepth%-1)):PROCbyte(&77):ndepth%=ndepth%-1
7660 ENDPROC
7670 DEF PROCstrlen
7680 PROCstritem:PROCvalue(0)
7690 PROCaddr("3A","$s"+STR$(sdepth%-1)):PROCaddr("32","$v"+STR$(ndepth%-1)):sdepth%=sdepth%-1
7700 ENDPROC
7710 DEF PROCstrassign(i%)
7720 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%)):PROCstrexpr
7730 PROCaddr("DD21","$var"+STR$(i%)):PROCaddr("FD21","$s"+STR$(sdepth%-1)):PROCaddr("21","$sheapctx")
7740 PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):sdepth%=sdepth%-1
7750 ENDPROC
7760 DEF PROCstrruntime
7770 LOCAL i%,j%,p%,v%,base%
7780 base%=pc%:PROCtemplate(simage%,ssize%,srelocs%,1)
7810 PROCdefine("$strlit",&40000+base%+sliteral%)
7820 PROCdefine("$strload",&40000+base%+sload%)
7830 PROCdefine("$strcat",&40000+base%+scat%)
7840 PROCdefine("$strstore",&40000+base%+sstore%)
7850 PROCdefine("$strprint",&40000+base%+sprint%)
7852 PROCdefine("$strleft",&40000+base%+sleft%)
7854 PROCdefine("$strright",&40000+base%+sright%)
7856 PROCdefine("$strmid",&40000+base%+smid%)
7858 PROCdefine("$strcmp",&40000+base%+scmp%)
7859 PROCdefine("$strinstr",&40000+base%+sinstr%)
7860 PROCdefine("$strrepeat",&40000+base%+srepeat%)
7861 PROCdefine("$strwrite",&40000+base%+swrite%)
7862 PROClabel("$strerror"):PROCbytes("FE13"):PROCaddr("CA","$strlong")
7863 PROCdefine("$strcopy",&40000+base%+scopy%)
7870 PROCerrorconstant(0,"No room")
7880 PROClabel("$strlong"):PROCerrorconstant(19,"String too long")
7890 FOR i%=0 TO sslots%-1
7900 PROClabel("$s"+STR$(i%)):PROCzeros(256)
7910 NEXT
7920 IF NOT memory% THEN PROClabel("$sheapctx"):PROCaddr("","$sheap"):PROCaddr("","$sheapend")
7930 IF NOT memory% THEN PROClabel("$sheap"):PROCdefine("$sheapend",&40000+pc%+1024*svars%)
7940 IF NOT memory% AND &40000+pc%+1024*svars%>&B0000 PROCbad("String workspace exceeds user RAM")
7950 ENDPROC
8010 DEF FNstrreserved(n$)
8020 =(INSTR("|CHR|STR|STRING|LEFT|RIGHT|MID|GET|INKEY|","|"+n$+"|")>0)
8100 DEF PROCneednumber
8110 IF valuekind%<>0 PROCbad("String value used as a numeric item")
8120 ENDPROC
8130 DEF PROCtypedbinary
8140 IF type%<>valuekind% PROCbad("Numeric/string type mismatch")
8150 IF type%=0 THEN PROCbinary(o%):ENDPROC
8160 IF p%=3 THEN PROCstrcompare(o%):ENDPROC
8170 IF o%<>11 PROCbad("Only concatenation and comparisons support strings")
8180 PROCaddr("DD21","$s"+STR$(sdepth%-2)):PROCaddr("FD21","$s"+STR$(sdepth%-1))
8190 PROCaddr("CD","$strcat"):PROCaddr("DA","$strerror"):sdepth%=sdepth%-1:valuekind%=1
8195 sunsafe%(sdepth%-1)=FALSE
8200 ENDPROC
8210 DEF PROCstrcompare(o%)
8220 LOCAL c%,j%
8230 PROCvalue(0):PROCaddr("DD21","$s"+STR$(sdepth%-2)):PROCaddr("FD21","$s"+STR$(sdepth%-1))
8240 PROCaddr("CD","$strcmp"):c%=0:j%=&28
8250 IF o%=6 j%=&20
8260 IF o%=8 OR o%=7 c%=255
8270 IF o%=12 OR o%=5 c%=1
8280 IF o%=5 OR o%=7 j%=&20
8290 PROCbyte(&FE):PROCbyte(c%):PROCbyte(j%):PROCbytes("03AF18023EFF")
8300 PROCaddr("21","$v"+STR$(ndepth%-1)):PROCbytes("77237723772377")
8310 sdepth%=sdepth%-2:valuekind%=0:ENDPROC
8320 DEF PROCslice(t%)
8330 LOCAL i%,r$
8340 PROCexpect("("):PROCstrexpr:i%=sdepth%-1:PROCspace
8350 IF t%=2 THEN PROCexpect(","):PROCcount:PROCaddr("DD21","$s"+STR$(i%)):PROCaddr("CD","$strmid"):PROCspace:sunsafe%(i%)=FALSE
8360 IF FNpeek="," THEN pos%=pos%+1:PROCcount:PROCslicecount(t%,i%):PROCexpect(")"):sunsafe%(i%)=FALSE:ENDPROC
8370 PROCexpect(")"):PROCaddr("DD21","$s"+STR$(i%))
8375 IF t%=1 AND sunsafe%(i%) PROCbad("Omitted RIGHT$ on a FN string result is unqualified; use an explicit count")
8380 IF t%=0 PROCbytes("DD7E00B728043DDD7700")
8390 IF t%=1 THEN PROCbytes("3E01"):PROCaddr("CD","$strright")
8400 ENDPROC
8410 DEF PROCcount
8420 PROCexpr(1):PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38)
8430 PROCaddr("3A","$v"+STR$(ndepth%-1)):ndepth%=ndepth%-1:ENDPROC
8440 DEF PROCslicecount(t%,i%)
8450 LOCAL r$:r$="$strleft":IF t%=1 r$="$strright"
8460 PROCaddr("DD21","$s"+STR$(i%)):PROCaddr("CD",r$):ENDPROC
8470 DEF PROCtypeditem
8480 IF FNstringstart THEN PROCstratom:valuekind%=1:ENDPROC
8490 PROCworditem:ENDPROC
8500 DEF PROCstrval
8510 PROCstritem:PROCvalue(0)
8520 PROCaddr("DD21","$v"+STR$(ndepth%-1)):PROCaddr("FD21","$s"+STR$(sdepth%-1))
8530 PROCaddr("CD","$numval"):PROCaddr("DA","$numerror"):sdepth%=sdepth%-1:valuekind%=0:ENDPROC
8540 DEF PROCstrnum
8550 LOCAL r$:r$="$numstr":PROCspace
8560 IF FNpeek="~" THEN pos%=pos%+1:r$="$numhex"
8570 PROCitem:PROCneednumber:PROCstrslot
8580 PROCaddr("DD21","$v"+STR$(ndepth%-1)):PROCaddr("FD21","$s"+STR$(sdepth%-1))
8590 PROCaddr("CD",r$):PROCaddr("DA","$numerror"):ndepth%=ndepth%-1:ENDPROC
8600 DEF PROCstrasc
8610 PROCstritem:PROCvalue(-1)
8620 PROCaddr("DD21","$s"+STR$(sdepth%-1)):PROCbytes("DD7E00B7280FDD7E01")
8630 PROCaddr("21","$v"+STR$(ndepth%-1)):PROCbytes("7723AF7723772377")
8640 sdepth%=sdepth%-1:valuekind%=0:ENDPROC
8700 DEF PROCstrinstr
8710 LOCAL m%,n%,v%
8720 PROCexpect("("):PROCstrexpr:m%=sdepth%-1:PROCexpect(","):PROCstrexpr:n%=sdepth%-1
8730 PROCvalue(0):v%=ndepth%-1:PROCsearchstart:PROCexpect(")")
8740 PROCaddr("DD21","$s"+STR$(m%)):PROCaddr("FD21","$s"+STR$(n%)):PROCaddr("CD","$strinstr")
8750 PROCaddr("32","$v"+STR$(v%)):sdepth%=sdepth%-2:valuekind%=0:ENDPROC
8760 DEF PROCsearchstart
8770 PROCspace:IF FNpeek<>"," THEN PROCbytes("3E01"):ENDPROC
8780 pos%=pos%+1:PROCcount:ENDPROC
8790 DEF PROCstrrepeat
8800 PROCexpect("("):PROCcount:PROCbyte(&F5):PROCexpect(","):PROCstrexpr:PROCexpect(")")
8805 IF sunsafe%(sdepth%-1) PROCbad("STRING$ on a FN string result is unqualified; establish a string value first")
8810 PROCbyte(&F1):PROCaddr("DD21","$s"+STR$(sdepth%-1)):PROCaddr("CD","$strrepeat"):PROCaddr("DA","$strerror"):ENDPROC
8900 DEF PROCstrsliceassign(t$)
8910 LOCAL n$,i%
8920 PROCexpect("("):n$=FNname:i%=FNvariable(n$)
8922 IF vtype%(i%)>255 PROCbad("Array slice assignment is unsupported")
8930 IF vtype%(i%)<>129 PROCbad("Expected a string variable")
8940 PROCaddr("3A","$bind"+STR$(i%)):PROCbyte(&B7):PROCaddr("CA","$novar")
8950 ndepth%=0:sdepth%=0
8960 IF t$="MID" THEN PROCexpect(","):PROCcount:PROCbytes("3D2100FE006F")
8970 IF t$="LEFT" PROCbytes("2100FF00")
8980 IF t$="RIGHT" PROCbytes("21FFFF00")
8990 PROCspace:IF FNpeek="," PROCwriterange
9000 PROCexpect(")"):PROCexpect("="):PROCbyte(&E5):PROCstrexpr:PROCbyte(&E1)
9010 PROCaddr("DD21","$var"+STR$(i%)):PROCaddr("FD21","$s"+STR$(sdepth%-1)):PROCaddr("CD","$strwrite")
9020 sdepth%=sdepth%-1:ENDPROC
9030 DEF PROCwriterange
9040 pos%=pos%+1:PROCbyte(&E5):PROCcount:PROCbyte(&E1)
9050 PROCbytes("B7280D3D8567300C7D3C280826FE180421010000"):ENDPROC
9100 DEF FNword(w$)
9110 =MID$(line$,pos%,LEN(w$))=w$ AND NOT FNalpha(MID$(line$,pos%+LEN(w$),1)) AND NOT FNdigit(MID$(line$,pos%+LEN(w$),1))
9120 DEF FNstmtend
9130 =(FNpeek="" OR FNpeek=":" OR FNword("ELSE"))
9140 DEF FNflow
9150 flow%=flow%+1:="$if"+STR$(flow%)
9160 DEF PROCcondition
9170 ndepth%=0:sdepth%=0:PROCexpr(1):PROCneednumber:PROCnumoperation(0,0,38)
9180 PROCbytes("DD7E00DDB601DDB602DDB603"):ndepth%=0
9190 ENDPROC
9200 DEF PROCif
9210 LOCAL id$,then%
9220 PROCcondition:id$=FNflow:PROCspace:then%=FNword("THEN")
9230 IF then% THEN pos%=pos%+4:PROCspace
9240 IF then% AND FNpeek="" THEN PROCifblock(id$):ENDPROC
9250 IF inum%=32 PROCbad("Inline IF nesting exceeds 32")
9260 ifid$(inum%)=id$:inum%=inum%+1:inseen%=TRUE
9270 PROCaddr("CA",id$):cont%=TRUE
9280 IF then% AND FNdigit(FNpeek) PROCbranch("GOTO"):cont%=FALSE
9290 ENDPROC
9300 DEF PROCifblock(id$)
9310 IF inum%<>0 PROCbad("Multiline IF inside inline IF is unsupported")
9320 IF LEN(structure$)=32 PROCbad("Block nesting exceeds 32")
9325 structure$=structure$+"I"
9330 bid$(bnum%)=id$:belse%(bnum%)=FALSE:bnum%=bnum%+1:PROCaddr("CA",id$)
9340 ENDPROC
9350 DEF PROCiffalse
9360 WHILE inum%>0:inum%=inum%-1:PROClabel(ifid$(inum%)):ENDWHILE
9370 ENDPROC
9380 DEF PROCelse
9390 IF NOT first% THEN PROCinlineelse:ENDPROC
9400 IF bnum%=0 PROCbad("ELSE without multiline IF")
9405 IF RIGHT$(structure$,1)<>"I" PROCbad("ELSE crosses a loop boundary")
9410 IF belse%(bnum%-1) PROCbad("Duplicate multiline ELSE")
9420 PROCaddr("C3",bid$(bnum%-1)+"e"):PROClabel(bid$(bnum%-1)):belse%(bnum%-1)=TRUE:cont%=TRUE
9430 ENDPROC
9440 DEF PROCinlineelse
9450 IF NOT inseen% PROCbad("ELSE without inline IF")
9460 IF leid$="" leid$=FNflow
9470 PROCaddr("C3",leid$):PROCiffalse:cont%=TRUE:PROCspace
9475 IF FNdigit(FNpeek) PROCbranch("GOTO"):cont%=FALSE
9480 ENDPROC
9490 DEF PROCendif
9500 IF NOT first% PROCbad("ENDIF must begin a statement line")
9510 IF bnum%=0 PROCbad("ENDIF without multiline IF")
9515 IF RIGHT$(structure$,1)<>"I" PROCbad("ENDIF crosses a loop boundary")
9520 bnum%=bnum%-1:IF belse%(bnum%) THEN PROClabel(bid$(bnum%)+"e") ELSE PROClabel(bid$(bnum%))
9525 structure$=LEFT$(structure$,LEN(structure$)-1)
9530 ENDPROC
11000 DEF PROCloadcontrol
11010 LOCAL i%,j%,s$
11020 RESTORE 40000:READ tsize%,trelocs%,tinit%,tpush%,tcheck%,tpop%,tuntil%,tagain%,tfor%,tnext%,tnumslot%,ttop%,tframes%,tend%
11030 DIM timage% tframes%-1,treloc%(trelocs%-1)
11040 FOR i%=0 TO tframes%-1 STEP 40:READ s$
11050 FOR j%=1 TO LEN(s$) STEP 2:timage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
11060 IF trelocs%>0 THEN FOR i%=0 TO trelocs%-1:READ treloc%(i%):NEXT
11070 ENDPROC
11080 DEF FNhexbyte(s$)
11090 =(INSTR("0123456789ABCDEF",LEFT$(s$,1))-1)*16+INSTR("0123456789ABCDEF",RIGHT$(s$,1))-1
11100 DEF PROCflowcheck(t%)
11110 PROCbyte(&3E):PROCbyte(t%):PROCaddr("CD","$ctlcheck"):PROCaddr("DA","$flowerror")
11120 ENDPROC
11130 DEF PROCloop(w$)
11140 LOCAL k%,i%,n$,id$,p%
11150 IF LEN(structure$)=32 PROCbad("Block nesting exceeds 32")
11160 k%=1:IF w$="WHILE" k%=2
11170 IF w$="FOR" k%=3
11180 id$=FNflow:lkind%(ltop%)=k%:lname$(ltop%)=id$:ltop%=ltop%+1:loops%=TRUE
11190 structure$=structure$+MID$("RWF",k%,1)
11200 IF k%=3 THEN PROCfor(id$):ENDPROC
11210 PROCaddr("21",id$+"b"):PROCbyte(&3E):PROCbyte(k%):PROCaddr("CD","$ctlpush"):PROCaddr("DA","$flowerror")
11220 PROClabel(id$+"b"):IF k%<>2 PROCerrmark
11230 IF k%=2 THEN PROCcondition:PROCaddr("C2",id$+"t"):PROCaddr("CD","$ctlpop"):PROCaddr("C3",id$+"e"):PROClabel(id$+"t")
11240 ENDPROC
11250 DEF PROCfor(id$)
11260 LOCAL n$,i%,p%
11270 n$=FNname:p%=pos%:i%=FNvariable(n$):IF vtype%(i%)=129 PROCbad("FOR needs a numeric variable")
11272 IF vtype%(i%)>255 PROCbad("Array FOR variables are unsupported")
11280 lvar%(ltop%-1)=i%:pos%=p%:PROCassign(n$):PROCexpectword("TO")
11290 ndepth%=0:PROCexpr(1):PROCneednumber:PROCspace
11300 IF FNword("STEP") THEN pos%=pos%+4:PROCexpr(1):PROCneednumber ELSE PROCvalue(1)
11310 PROCnumindices(0,1):PROCaddr("21",id$+"b"):PROCaddr("11","$var"+STR$(i%)):PROCbyte(&06):PROCbyte(vsize&(i%))
11320 PROCaddr("CD","$ctlfor"):PROCaddr("DA","$flowerror"):ndepth%=0:PROClabel(id$+"b")
11330 ENDPROC
11340 DEF PROCexpectword(w$)
11350 PROCspace:IF NOT FNword(w$) PROCbad("Expected "+w$)
11360 pos%=pos%+LEN(w$):ENDPROC
11370 DEF PROCloopend(w$)
11380 LOCAL k%,id$
11390 k%=1:IF w$="ENDWHILE" k%=2
11400 IF w$="NEXT" THEN PROCnext:ENDPROC
11410 IF ltop%=0 PROCbad("Loop terminator without loop")
11420 IF lkind%(ltop%-1)<>k% OR RIGHT$(structure$,1)<>MID$("RW",k%,1) PROCbad("Mismatched loop terminator")
11430 id$=lname$(ltop%-1):PROCflowcheck(k%)
11440 IF k%=1 THEN PROCcondition:PROCaddr("CD","$ctluntil") ELSE PROCaddr("CD","$ctlagain")
11450 PROCaddr("DA","$flowerror"):IF k%=2 PROClabel(id$+"e")
11460 ltop%=ltop%-1:structure$=LEFT$(structure$,LEN(structure$)-1)
11470 ENDPROC
11480 DEF PROCnext
11490 LOCAL i%,n$,more%,found%,j%
11500 REPEAT
11510 IF ltop%=0 PROCbad("NEXT without FOR")
11520 IF RIGHT$(structure$,1)<>"F" PROCbad("NEXT crosses another block")
11530 PROCspace:i%=-1
11540 IF FNalpha(FNpeek) AND NOT FNword("ELSE") THEN n$=FNname:i%=FNvariable(n$)
11550 j%=ltop%-1:IF i%<0 i%=lvar%(j%)
11560 found%=FALSE:WHILE j%>=0 AND NOT found%
11562 IF lkind%(j%)<>3 PROCbad("NEXT crosses another loop")
11564 IF lvar%(j%)=i% THEN found%=TRUE ELSE j%=j%-1
11566 ENDWHILE
11570 IF j%<0 PROCbad("NEXT variable has no matching FOR")
11580 IF lkind%(j%)<>3 PROCbad("NEXT crosses another loop")
11590 PROCaddr("11","$var"+STR$(i%)):PROCaddr("CD","$ctlnext"):PROCaddr("DA","$flowerror")
11600 structure$=LEFT$(structure$,LEN(structure$)-(ltop%-j%)):ltop%=j%:PROCspace:more%=(FNpeek=",")
11610 IF more% pos%=pos%+1
11620 UNTIL NOT more%
11630 ENDPROC
11700 DEF PROCflowruntime
11710 LOCAL b%,i%,p%,v%,n$,e%,save%
11720 b%=pc%:PROCtemplate(timage%,tsize%,trelocs%,2)
11740 PROCctlexport("$ctlinit",b%+tinit%):PROCctlexport("$ctlpush",b%+tpush%):PROCctlexport("$ctlcheck",b%+tcheck%):PROCctlexport("$ctlpop",b%+tpop%)
11750 PROCctlexport("$ctluntil",b%+tuntil%):PROCctlexport("$ctlagain",b%+tagain%):PROCctlexport("$ctlfor",b%+tfor%):PROCctlexport("$ctlnext",b%+tnext%)
11755 IF errors% THEN PROCctlexport("$ctltop",b%+ttop%):PROCctlexport("$ctlframes",b%+tframes%)
11760 REM Numeric bridge emitted with control template.
11770 FOR i%=0 TO 5
11780 e%=VAL(MID$("004346323338",i%*2+1,2)):n$=MID$("No room                 Not in a REPEAT loop    Not in a WHILE loop     Not in a FOR loop       Can't match FOR         No GOSUB                ",i%*24+1,24)
11790 PROClabel("$flowerr"+STR$(i%)):PROCerrorconstant(e%,FNtrim(n$))
11800 NEXT
11810 PROClabel("$flowerror"):PROCbytes("B7"):PROCaddr("CA","$flowerr0")
11820 PROCbytes("FE2B"):PROCaddr("CA","$flowerr1"):PROCbytes("FE2E"):PROCaddr("CA","$flowerr2")
11830 PROCbytes("FE20"):PROCaddr("CA","$flowerr3"):PROCbytes("FE21"):PROCaddr("CA","$flowerr4"):PROCbytes("FE26"):PROCaddr("CA","$flowerr5")
11840 PROCaddr("C3","$numerror")
11850 p%=start%:start%=&40000+pc%:PROCaddr("CD","$ctlinit")
11852 IF acts% THEN PROCbyte(&D5):PROCaddr("21","$actbase"):PROCaddr("11","$actlimit"):PROCaddr("CD","$actinit"):PROCbyte(&D1)
11853 IF errors% PROCaddr("CD","$errinit")
11855 PROCbyte(&C3)
11860 PROCbyte(p% MOD 256):PROCbyte((p% DIV 256) MOD 256):PROCbyte(p% DIV 65536)
11870 ENDPROC
11880 DEF PROCctlexport(n$,p%)
11890 PROCdefine(n$,&40000+p%):ENDPROC
11900 DEF FNtrim(s$)
11910 WHILE RIGHT$(s$,1)=" ":s$=LEFT$(s$,LEN(s$)-1):ENDWHILE
11920 =s$
13000 DEF PROCloadacts
13010 LOCAL i%,j%,s$
13020 RESTORE 50000:READ asize%,arelocs%,ainit%,abegin%,asave%,ainstall%,abind%,aleave%,apushslot%,acheckslot%,apopslot%,anumslot%,atop%,afnbegin%,afnleave%
13030 DIM aimage% asize%-1,areloc%(arelocs%-1)
13040 FOR i%=0 TO asize%-1 STEP 40:READ s$
13050 FOR j%=1 TO LEN(s$) STEP 2:aimage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
13060 IF arelocs%>0 THEN FOR i%=0 TO arelocs%-1:READ areloc%(i%):NEXT
13070 ENDPROC
13080 DEF PROCuseacts
13090 acts%=TRUE:loops%=TRUE:numeric%=TRUE:IF nslots%=0 nslots%=1
13100 ENDPROC
13110 DEF FNprocfind(n$)
13120 LOCAL i%,f%:i%=0:f%=-1
13130 WHILE i%<pnum%:IF pname$(i%)=n$ f%=i%
13140 i%=i%+1:ENDWHILE
13150 =f%
13160 DEF PROCprocscan(h%)
13170 LOCAL i%,n$,function%:function%=-1
13180 WHILE NOT EOF#h%
13190 lnum%=lnum%+1:pos%=1:PROCreadline(h%):PROCspace
13200 IF FNdigit(FNpeek) i%=FNnumber(65279)
13210 PROCspace:PROCtargetscan:PROCerrorscan:IF FNword("DEF") PROCscandef
13214 IF FNword("DATA") OR FNword("REM") pos%=LEN(line$)+1
13215 IF function%>=0 PROCcollectreturns(function%,pos%)
13220 ENDWHILE
13225 PROCinferreturns
13230 ENDPROC
13240 DEF PROCscandef
13250 LOCAL n$,i%,k%
13260 pos%=pos%+3:PROCspace
13270 k%=0:IF MID$(line$,pos%,2)="FN" k%=1
13272 IF k%=0 AND MID$(line$,pos%,4)<>"PROC" PROCbad("Expected PROC or FN after DEF")
13280 pos%=pos%+4-2*k%:n$=FNcallname(k%):IF FNprocfind(MID$("PF",k%+1,1)+n$)>=0 PROCbad("Duplicate definition "+n$)
13290 IF pnum%=256 PROCbad("Procedure limit exceeds 256")
13300 i%=pnum%:pnum%=pnum%+1:pname$(i%)=MID$("PF",k%+1,1)+n$:pline%(i%)=lnum%:pkind&(i%)=k%:pret%(i%)=-1:PROCprocparams(i%,TRUE)
13305 function%=-1:IF k%=1 function%=i%
13310 ENDPROC
13320 DEF PROCprocparams(i%,save%)
13330 LOCAL n$,j%,k%,v%,more%
13340 j%=0:PROCspace:IF FNpeek<>"(" THEN IF save% parcnt&(i%)=0
13342 IF FNpeek<>"(" ENDPROC
13350 pos%=pos%+1:PROCspace:IF FNpeek=")" PROCbad("Empty formal parameter lists are unsupported")
13360 REPEAT
13370 IF j%=16 PROCbad("Procedure argument limit exceeds 16")
13380 n$=FNname:IF FNreserved(n$) PROCbad("Unsupported formal parameter "+n$)
13390 v%=FNvariable(n$):k%=0
13392 IF vtype%(v%)>255 PROCbad("Array formal parameters are unsupported")
13400 WHILE k%<j%:IF par&(i%,k%)=v% PROCbad("Duplicate formal parameter")
13410 k%=k%+1:ENDWHILE
13420 IF save% THEN par&(i%,j%)=v% ELSE IF par&(i%,j%)<>v% PROCbad("Procedure signature changed")
13430 j%=j%+1:PROCspace:more%=(FNpeek=","):IF more% pos%=pos%+1
13440 UNTIL NOT more%
13450 PROCexpect(")"):IF save% THEN parcnt&(i%)=j% ELSE IF parcnt&(i%)<>j% PROCbad("Procedure signature changed")
13460 ENDPROC
13470 DEF PROCprocscope
13480 LOCAL i%:i%=scope%
13490 IF i%>=pnum% ENDPROC
13500 IF pline%(i%)<>lnum% ENDPROC
13510 IF structure$<>"" PROCbad("Definition crosses an open block")
13520 scope%=i%+1
13530 ENDPROC
13540 DEF FNtarget(n$)
13550 IF scope%=0 THEN =n$
13560 ="$p"+STR$(scope%)+n$
13570 DEF PROCdefinition
13580 LOCAL n$,i%,k%
13590 PROCspace:k%=0:IF MID$(line$,pos%,2)="FN" k%=1
13595 IF k%=0 AND MID$(line$,pos%,4)<>"PROC" PROCbad("Expected PROC or FN after DEF")
13600 pos%=pos%+4-2*k%:n$=FNcallname(k%):i%=FNprocfind(MID$("PF",k%+1,1)+n$)
13610 IF i%<0 PROCbad("DEF must begin its physical statement line")
13620 IF pline%(i%)<>lnum% PROCbad("DEF must begin its physical statement line")
13630 PROCprocparams(i%,FALSE):declskip$=FNflow:PROCaddr("C3",declskip$):PROClabel("$proc"+STR$(i%)):PROCerrmark
13635 PROCspace:IF k%=1 AND FNpeek="=" cont%=TRUE
13640 ENDPROC
13650 DEF PROCproccall
13660 LOCAL n$,i%,j%,v%,count%,k%,frame%
13670 n$=FNname:i%=FNprocfind("P"+n$):IF i%<0 PROCbad("Undefined PROC "+n$)
13675 frame%=calldepth%:calldepth%=calldepth%+1:IF calldepth%>32 PROCbad("Call expression nesting exceeds 32")
13680 PROCuseacts:PROCusecompact:PROCaddr("CD","$cpbegin"):count%=parcnt&(i%)
13690 IF count%>0 THEN FOR j%=0 TO count%-1:PROCsavebinding(par&(i%,j%)):NEXT
13700 ndepth%=0:sdepth%=0:PROCspace
13710 IF count%=0 AND FNpeek="(" PROCbad("Empty call argument lists are unsupported")
13720 IF count%>0 THEN PROCexpect("("):FOR j%=0 TO count%-1:PROCprocarg(i%,j%):NEXT:PROCexpect(")")
13730 IF count%>0 THEN FOR j%=count%-1 TO 0 STEP -1:PROCprocbind(j%,count%-1-j%):NEXT
13740 PROCaddr("CD","$proc"+STR$(i%)):ndepth%=0:sdepth%=0:PROCerrmark
13745 calldepth%=calldepth%-1
13750 ENDPROC
13760 DEF PROCprocarg(i%,j%)
13770 LOCAL v%,k%
13780 IF j%>0 PROCexpect(",")
13790 PROCexpr(1):v%=par&(i%,j%):k%=ABS(vtype%(v%)=129)
13800 IF valuekind%<>k% PROCbad("Procedure argument type mismatch")
13810 argkind&(frame%,j%)=k%:IF k%=0 THEN argindex&(frame%,j%)=ndepth%-1 ELSE argindex&(frame%,j%)=sdepth%-1
13820 ENDPROC
13830 DEF PROCprocbind(i%,o%)
13840 PROCusecompact:PROCaddr("CD","$cpbind")
13850 PROCbyte(o%):PROCbyte(argkind&(frame%,i%)):PROCbyte(argindex&(frame%,i%))
13860 ENDPROC
13870 DEF PROCsavebinding(i%)
13880 PROCusecompact:PROCaddr("CD","$cpsave"):PROCaddr("","$bind"+STR$(i%)):PROCbyte(vtype%(i%))
13890 ENDPROC
13900 DEF PROClocal
13910 LOCAL n$,i%,more%
13915 PROCspace:IF FNword("ERROR") THEN pos%=pos%+5:ENDPROC
13920 PROCuseacts
13930 REPEAT
13940 n$=FNname:IF FNreserved(n$) PROCbad("Unsupported LOCAL form "+n$)
13950 i%=FNvariable(n$)
13952 IF vtype%(i%)>255 PROCbad("LOCAL arrays are unsupported")
13954 PROCsavebinding(i%):PROCaddr("CD","$actinstall")
13960 PROCspace:more%=(FNpeek=","):IF more% pos%=pos%+1
13970 UNTIL NOT more%
13980 ENDPROC
14000 DEF PROCactruntime
14010 LOCAL b%,i%,p%,v%,save%
14020 b%=pc%:PROCtemplate(aimage%,asize%,arelocs%,3)
14050 PROCctlexport("$actinit",b%+ainit%):PROCctlexport("$actbegin",b%+abegin%):PROCctlexport("$actsave",b%+asave%)
14060 PROCctlexport("$actinstall",b%+ainstall%):PROCctlexport("$actbind",b%+abind%):PROCctlexport("$actleave",b%+aleave%)
14065 PROCctlexport("$fnbegin",b%+afnbegin%):PROCctlexport("$fnleave",b%+afnleave%)
14067 IF errors% PROCctlexport("$acttop",b%+atop%)
14070 REM Control/numeric bridges emitted with activation template.
14090 PROClabel("$acterror"):PROCbytes("B7"):PROCaddr("CA","$flowerr0")
14100 PROCbytes("FE0C"):PROCaddr("CA","$notlocal"):PROCbytes("FE0D"):PROCaddr("CA","$notproc"):PROCbytes("FE07"):PROCaddr("CA","$notfn"):PROCaddr("C3","$numerror")
14105 REM Act error7 must be dispatched before falling through to numeric error.
14110 PROClabel("$notlocal"):PROCerrorconstant(12,"Not in a FN or PROC")
14120 PROClabel("$notproc"):PROCerrorconstant(13,"Not in a PROC")
14125 PROClabel("$notfn"):PROCerrorconstant(7,"Not in a FN")
14127 IF functions% THEN PROClabel("$fnnum"):PROCbytes("0000000000"):PROClabel("$fnstr"):PROCzeros(256)
14130 ENDPROC
14140 DEF PROCactworkspace
14150 LOCAL p%,i%
14160 p%=&40000+pc%:IF strings% OR memory% p%=FNsymboladdr(FNsymbol("$sheapend"))
14170 PROCdefine("$actbase",p%):PROCdefine("$actlimit",p%+32768)
14180 IF p%+32768>&B0000 PROCbad("Activation workspace exceeds user RAM")
14190 ENDPROC
15000 DEF FNcallname(k%)
15010 LOCAL n$:n$=FNname
15020 IF k%=1 AND FNpeek="$" THEN n$=n$+"$":pos%=pos%+1
15030 =n$
15040 DEF FNfnstring(p%)
15050 LOCAL s%,i%:s%=pos%:pos%=p%+2:i%=FNprocfind("F"+FNcallname(1)):pos%=s%
15060 IF i%<0 THEN =FALSE
15070 =(pret%(i%)=1)
15080 DEF PROCfncall
15090 LOCAL n$,i%,j%,count%,frame%,nstart%,sstart%,k%
15095 IF dimparse%>0 PROCbad("FN calls in array DIM expressions are unqualified")
15100 n$=FNcallname(1):i%=FNprocfind("F"+n$):IF i%<0 PROCbad("Undefined FN "+n$)
15110 PROCuseacts:functions%=TRUE:nstart%=ndepth%:sstart%=sdepth%:frame%=calldepth%:calldepth%=calldepth%+1
15120 IF calldepth%>32 PROCbad("Call expression nesting exceeds 32")
15130 IF nstart%>0 THEN PROCaddr("DD21","$v0") ELSE PROCbytes("DD21000000")
15140 IF sstart%>0 THEN PROCaddr("FD21","$s0") ELSE PROCbytes("FD21000000")
15150 PROCbytes("0100000006"):PROCbyte(nstart%):PROCbyte(&0E):PROCbyte(sstart%):PROCaddr("CD","$fnbegin"):PROCaddr("DA","$acterror")
15160 count%=parcnt&(i%):IF count%>0 THEN FOR j%=0 TO count%-1:PROCsavebinding(par&(i%,j%)):NEXT
15170 PROCspace:IF count%=0 AND FNpeek="(" PROCbad("Empty call argument lists are unsupported")
15180 IF count%>0 THEN PROCexpect("("):FOR j%=0 TO count%-1:PROCprocarg(i%,j%):NEXT:PROCexpect(")")
15190 IF count%>0 THEN FOR j%=count%-1 TO 0 STEP -1:PROCprocbind(j%,count%-1-j%):NEXT
15200 PROCaddr("CD","$proc"+STR$(i%)):ndepth%=nstart%:sdepth%=sstart%
15210 IF pret%(i%)=0 THEN PROCnumslot:PROCvarcopy("$fnnum","$v"+STR$(ndepth%-1),5) ELSE PROCstrslot:PROCcopystr("$fnstr","$s"+STR$(sdepth%-1))
15215 IF pret%(i%)=1 sunsafe%(sdepth%-1)=TRUE
15220 valuekind%=pret%(i%):calldepth%=calldepth%-1:PROCerrmark:ENDPROC
15230 DEF PROCcopystr(f$,t$)
15240 PROCaddr("21",f$):PROCaddr("11",t$):PROCaddr("CD","$strcopy"):ENDPROC
15250 DEF PROCfnreturn
15260 PROCuseacts:functions%=TRUE:ndepth%=0:sdepth%=0:PROCexpr(1)
15270 IF scope%>0 THEN IF pkind&(scope%-1)=1 AND pret%(scope%-1)<>valuekind% PROCbad("Mixed numeric/string FN results are unsupported")
15280 IF valuekind%=0 THEN PROCvarcopy("$v0","$fnnum",5) ELSE PROCcopystr("$s0","$fnstr")
15290 PROCaddr("CD","$fnleave"):PROCaddr("DA","$acterror"):PROCbyte(&C9):ndepth%=0:sdepth%=0:ENDPROC
15300 DEF PROCcollectreturns(i%,s%)
15310 LOCAL p%,q%,d%,e%,c$
15320 p%=s%:q%=FALSE:d%=0
15330 WHILE p%<=LEN(line$)
15340 c$=MID$(line$,p%,1)
15350 IF c$=CHR$(34) THEN q%=NOT q%
15355 IF NOT q% AND d%=0 THEN IF FNkindword(line$,p%,"REM") OR FNkindword(line$,p%,"DATA") p%=LEN(line$)+1
15360 IF NOT q% THEN IF c$="=" AND d%=0 AND FNreturnmark(p%,s%) THEN e%=FNreturnend(p%+1):PROCrememberreturn(i%,MID$(line$,p%+1,e%-p%-1),p%+1):p%=e%-1
15370 IF NOT q% THEN IF c$="(" d%=d%+1
15380 IF NOT q% THEN IF c$=")" d%=d%-1
15390 p%=p%+1:ENDWHILE
15400 ENDPROC
15410 DEF FNreturnmark(p%,s%)
15420 p%=p%-1:WHILE p%>=s% AND (MID$(line$,p%,1)=" " OR MID$(line$,p%,1)=CHR$(9)):p%=p%-1:ENDWHILE
15430 IF p%<s% OR MID$(line$,p%,1)=":" THEN =TRUE
15435 IF p%<4 THEN =FALSE
15440 =FNkindword(line$,p%-3,"THEN") OR FNkindword(line$,p%-3,"ELSE")
15450 DEF FNreturnend(p%)
15460 LOCAL q%,d%,c%,f%:q%=FALSE:d%=0:f%=FALSE
15470 WHILE p%<=LEN(line$) AND NOT f%
15480 c%=ASC(MID$(line$,p%,1)):IF c%=34 q%=NOT q%
15490 IF NOT q% AND d%=0 THEN IF c%=58 OR FNkindword(line$,p%,"ELSE") f%=TRUE
15500 IF NOT q% THEN IF c%=40 d%=d%+1
15510 IF NOT q% THEN IF c%=41 d%=d%-1
15520 IF NOT f% p%=p%+1
15530 ENDWHILE
15540 =p%
15550 DEF PROCrememberreturn(i%,s$,col%)
15560 IF retnum%=512 PROCbad("FN result expression limit exceeds 512")
15570 return$(retnum%)=s$:retdef&(retnum%)=i%:retline%(retnum%)=lnum%:retcol%(retnum%)=col%:retnum%=retnum%+1:ENDPROC
15580 DEF PROCinferreturns
15590 LOCAL i%,j%,k%,change%
15600 REPEAT
15610 change%=FALSE:i%=0
15620 WHILE i%<retnum%
15625 lnum%=retline%(i%):pos%=retcol%(i%)
15630 j%=retdef&(i%):k%=FNinferkind(return$(i%))
15640 IF k%>=0 AND pret%(j%)>=0 AND k%<>pret%(j%) PROCbad("Mixed numeric/string FN results are unsupported")
15650 IF k%>=0 AND pret%(j%)<0 THEN pret%(j%)=k%:change%=TRUE
15660 i%=i%+1:ENDWHILE
15670 UNTIL NOT change%
15680 i%=0:WHILE i%<pnum%
15690 IF pkind&(i%)=1 AND pret%(i%)<0 THEN lnum%=pline%(i%):pos%=1:PROCbad("Unresolved FN result kind "+pname$(i%))
15700 i%=i%+1:ENDWHILE
15710 ENDPROC
15720 DEF FNinferkindcore(s$)
15730 LOCAL p%,d%,q%,c$,o%,i%,k%,l%,r%,n$
15740 s$=FNkindtrim(s$):IF s$="" PROCbad("Missing FN result expression")
15750 WHILE LEFT$(s$,1)="(" AND FNkindouter(s$):s$=FNkindtrim(MID$(s$,2,LEN(s$)-2)):ENDWHILE
15760 p%=1:d%=0:q%=FALSE:o%=0
15770 WHILE p%<=LEN(s$)
15780 c$=MID$(s$,p%,1):IF c$=CHR$(34) q%=NOT q%
15790 IF NOT q% AND d%=0 AND INSTR("<>=*/^-",c$)>0 o%=1
15800 IF NOT q% AND d%=0 THEN IF FNkindword(s$,p%,"AND") OR FNkindword(s$,p%,"OR") OR FNkindword(s$,p%,"EOR") OR FNkindword(s$,p%,"DIV") OR FNkindword(s$,p%,"MOD") o%=1
15810 IF NOT q% THEN IF c$="(" d%=d%+1
15820 IF NOT q% THEN IF c$=")" d%=d%-1
15830 p%=p%+1:ENDWHILE
15840 IF o%=1 THEN =0
15845 IF LEFT$(s$,1)="+" THEN =0
15850 p%=FNkindplus(s$):IF p%>0 THEN l%=FNinferkind(LEFT$(s$,p%-1)):r%=FNinferkind(MID$(s$,p%+1)):PROCkindpair: =k%
15860 IF LEFT$(s$,1)=CHR$(34) THEN =1
15870 IF LEFT$(s$,2)="FN" THEN p%=3:n$=FNkindname(s$,p%):i%=FNprocfind("F"+n$):IF i%<0 PROCbad("Undefined FN "+n$)
15880 IF LEFT$(s$,2)="FN" THEN =pret%(i%)
15890 p%=1:n$=FNkindname(s$,p%):IF RIGHT$(n$,1)="$" THEN =1
15900 =0
15910 DEF PROCkindpair
15920 k%=l%:IF k%<0 k%=r%
15930 IF l%>=0 AND r%>=0 AND l%<>r% PROCbad("Numeric/string type mismatch in FN result")
15940 ENDPROC
15950 DEF FNkindname(s$,p%)
15960 LOCAL n$:n$=""
15970 WHILE FNalpha(MID$(s$,p%,1)) OR FNdigit(MID$(s$,p%,1)):n$=n$+MID$(s$,p%,1):p%=p%+1:ENDWHILE
15980 IF MID$(s$,p%,1)="$" n$=n$+"$"
15990 =n$
16000 DEF FNkindtrim(s$)
16010 WHILE LEFT$(s$,1)=" " OR LEFT$(s$,1)=CHR$(9):s$=MID$(s$,2):ENDWHILE
16020 WHILE RIGHT$(s$,1)=" " OR RIGHT$(s$,1)=CHR$(9):s$=LEFT$(s$,LEN(s$)-1):ENDWHILE
16030 =s$
16040 DEF FNkindouter(s$)
16050 LOCAL p%,d%,q%,f%,c$:p%=1:d%=0:q%=FALSE:f%=TRUE
16060 WHILE p%<=LEN(s$)
16070 c$=MID$(s$,p%,1):IF c$=CHR$(34) q%=NOT q%
16080 IF NOT q% THEN IF c$="(" d%=d%+1
16090 IF NOT q% THEN IF c$=")" d%=d%-1
16100 IF NOT q% AND d%=0 AND p%<LEN(s$) f%=FALSE
16110 p%=p%+1:ENDWHILE
16120 =(f% AND d%=0)
16130 DEF FNkindword(s$,p%,w$)
16135 LOCAL b$,a$:b$="":IF p%>1 b$=MID$(s$,p%-1,1)
16137 a$=MID$(s$,p%+LEN(w$),1)
16140 =(MID$(s$,p%,LEN(w$))=w$ AND NOT FNalpha(b$) AND NOT FNdigit(b$) AND NOT FNalpha(a$) AND NOT FNdigit(a$))
16150 DEF FNkindplus(s$)
16160 LOCAL p%,d%,q%,f%,c$:p%=1:d%=0:q%=FALSE:f%=0
16170 WHILE p%<=LEN(s$) AND f%=0
16180 c$=MID$(s$,p%,1):IF c$=CHR$(34) q%=NOT q%
16190 IF NOT q% AND d%=0 AND c$="+" f%=p%
16200 IF NOT q% THEN IF c$="(" d%=d%+1
16210 IF NOT q% THEN IF c$=")" d%=d%-1
16220 p%=p%+1:ENDWHILE
16230 =f%
16300 DEF FNinferkind(s$)
16310 LOCAL k%:kinddepth%=kinddepth%+1:IF kinddepth%>32 PROCbad("FN kind expression nesting exceeds 32")
16320 k%=FNinferkindcore(s$):kinddepth%=kinddepth%-1:=k%
16400 DEF PROCloadmemory
16402 LOCAL i%,j%,s$
16404 RESTORE 60000:READ msize%,mrelocs%,malloc%,mdim%,maddr%,mstep%,mprefix%
16406 DIM mimage% msize%-1,mreloc%(mrelocs%-1)
16408 FOR i%=0 TO msize%-1 STEP 40:READ s$
16410 FOR j%=1 TO LEN(s$) STEP 2:mimage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
16412 IF mrelocs%>0 THEN FOR i%=0 TO mrelocs%-1:READ mreloc%(i%):NEXT
16414 ENDPROC
16416 DEF PROCusememory
16418 memory%=TRUE:numeric%=TRUE:ENDPROC
16420 DEF PROCmemoryruntime
16422 LOCAL b%,i%,p%,v%,e%,m$
16424 b%=pc%:PROCtemplate(mimage%,msize%,mrelocs%,4)
16430 PROCctlexport("$memalloc",b%+malloc%):PROCctlexport("$arraydim",b%+mdim%):PROCctlexport("$arrayaddr",b%+maddr%)
16432 PROCctlexport("$dimstep",b%+mstep%):PROCctlexport("$arrayprefix",b%+mprefix%)
16434 PROClabel("$memerror")
16436 FOR i%=0 TO 6:e%=VAL(MID$("05101114151627",i%*2+1,2)):PROCbyte(&FE):PROCbyte(e%):PROCaddr("CA","$me"+STR$(e%)):NEXT
16438 PROCerrorconstant(0,"No room")
16440 FOR i%=0 TO 6:e%=VAL(MID$("05101114151627",i%*2+1,2)):m$=""
16442 IF e%=5 m$="Missing ,"
16444 IF e%=10 m$="Bad DIM"
16446 IF e%=11 m$="DIM space"
16448 IF e%=14 m$="Bad use of array"
16450 IF e%=15 m$="Bad subscript"
16452 IF e%=16 m$="Syntax error"
16454 IF e%=27 m$="Missing )"
16456 PROClabel("$me"+STR$(e%)):PROCerrorconstant(e%,m$):NEXT
16458 ENDPROC
16460 DEF PROCmemoryworkspace
16462 LOCAL p%
16464 PROClabel("$sheapctx"):PROCaddr("","$sheap"):PROCaddr("","$sheapend")
16466 PROClabel("$sheap"):p%=&AFF00-32768*ABS(acts%)
16468 IF p%<&40000+pc% PROCbad("Memory workspace exceeds user RAM")
16470 PROCdefine("$sheapend",p%):ENDPROC
16472 DEF FNmemwidth(i%)
16474 LOCAL t%:t%=vtype%(i%) AND 255:IF t%=129 t%=5
16476 =t%
16478 DEF PROCarrayarity(i%,n%)
16480 IF vdim&(i%)=0 vdim&(i%)=n%
16482 IF vdim&(i%)<>n% PROCbad("Array arity must be consistent in this compiler subset")
16484 ENDPROC
16486 DEF PROCarraycall(r$,i%,n%,s%)
16487 IF r$="$arrayprefix" OR r$="$arrayaddr" THEN
16488 PROCusecompact:IF r$="$arrayprefix" THEN PROCaddr("CD","$cpprefix") ELSE PROCaddr("CD","$cpaddr")
16489 PROCaddr("","$var"+STR$(i%)):PROCbyte(s%):PROCbyte(FNmemwidth(i%)):PROCbyte(n%):ENDPROC
16490 ENDIF
16491 PROCaddr("DD21","$var"+STR$(i%)):PROCaddr("FD21","$v"+STR$(s%))
16492 PROCbyte(&06):PROCbyte(FNmemwidth(i%)):PROCbyte(&3E):PROCbyte(n%)
16493 PROCaddr("CD",r$):PROCaddr("DA","$memerror"):ENDPROC
16494 DEF PROCarrayaddress(i%,w%)
16496 LOCAL p%,s%,n%,more%
16498 PROCusememory:PROCvalue(0):p%=ndepth%-1:s%=ndepth%:n%=0
16500 IF w% THEN PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%)) ELSE PROCaddr("3A","$bind"+STR$(i%)):PROCbyte(&B7):PROCaddr("CA","$novar")
16502 PROCexpect("("):IF FNpeek=")" PROCbad("Whole-array values are unsupported")
16504 PROCarraycall("$arrayprefix",i%,0,s%)
16506 REPEAT
16508 IF n%=16 PROCbad("Array dimension limit exceeds 16")
16510 IF n%>0 PROCexpect(",")
16512 PROCexpr(1):PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38)
16514 n%=n%+1:PROCarraycall("$arrayprefix",i%,n%,s%)
16516 PROCspace:more%=(FNpeek=",")
16518 UNTIL NOT more%
16520 PROCexpect(")"):PROCarrayarity(i%,n%):PROCarraycall("$arrayaddr",i%,n%,s%)
16522 PROCaddr("22","$v"+STR$(p%)):ndepth%=p%+1:ENDPROC
16524 DEF PROCarrayread(i%)
16526 LOCAL t%,p%,j%
16528 PROCarrayaddress(i%,FALSE):t%=vtype%(i%) AND 255:p%=ndepth%-1
16530 IF t%=129 THEN PROCstrslot:PROCaddr("DD21","$s"+STR$(sdepth%-1)):PROCaddr("FD2A","$v"+STR$(p%)):PROCaddr("CD","$strload"):ndepth%=p%:valuekind%=1:ENDPROC
16532 PROCaddr("2A","$v"+STR$(p%)):PROCaddr("11","$v"+STR$(p%))
16534 PROCbyte(&01):PROCbyte(t%):PROCbytes("0000EDB0")
16536 IF t%<5 THEN PROCbyte(&AF):FOR j%=t% TO 4:PROCbytes("1213"):NEXT
16538 valuekind%=0:ENDPROC
16540 DEF PROCarrayassign(i%)
16542 LOCAL t%:t%=vtype%(i%) AND 255:ndepth%=0:sdepth%=0:PROCarrayaddress(i%,TRUE):PROCexpect("=")
16544 PROCexpr(1)
16546 IF t%=129 THEN IF valuekind%<>1 PROCbad("Expected a string item")
16548 IF t%=129 THEN PROCaddr("DD2A","$v0"):PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):ndepth%=0:sdepth%=0:ENDPROC
16550 PROCneednumber:IF t%<>5 THEN PROCnumoperation(1,1,38)
16552 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(t%):PROCbytes("0000EDB0")
16554 ndepth%=0:sdepth%=0:ENDPROC
16556 DEF PROCdim
16558 LOCAL n$,i%,more%,t%,j%
16560 PROCusememory
16562 REPEAT
16564 n$=FNname:IF FNreserved(n$) PROCbad("Unsupported DIM target "+n$)
16566 i%=FNvariable(n$):t%=vtype%(i%):PROCspace
16568 IF t%>255 THEN PROCdimarray(i%) ELSE PROCdimblock(i%)
16570 PROCspace:more%=(FNpeek=","):IF more% pos%=pos%+1
16572 UNTIL NOT more%
16574 ENDPROC
16576 DEF PROCdimarray(i%)
16578 LOCAL n%,s%,more%,new$,t%
16580 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%))
16582 ndepth%=0:sdepth%=0:PROCvalue(1):PROCvalue(0):PROCaddr("2A","$var"+STR$(i%)):PROCaddr("22","$v1")
16584 s%=ndepth%:n%=0:PROCexpect("("):new$=FNflow:PROCdimbranch(new$,TRUE):PROCarraycall("$arrayprefix",i%,0,s%):PROClabel(new$)
16586 IF FNpeek=")" PROCbad("Empty DIM dimensions are unsupported")
16588 REPEAT
16590 IF n%=16 PROCbad("Array dimension limit exceeds 16")
16592 IF n%>0 PROCexpect(",")
16594 dimparse%=dimparse%+1:PROCexpr(1):dimparse%=dimparse%-1:PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38)
16596 n%=n%+1:PROCdimchoice(i%,n%,s%)
16598 PROCspace:more%=(FNpeek=",")
16600 UNTIL NOT more%
16602 PROCexpect(")"):PROCarrayarity(i%,n%):new$=FNflow:PROCdimbranch(new$,TRUE)
16604 PROCarraycall("$arrayaddr",i%,n%,s%):t%=vtype%(i%) AND 255
16606 IF t%=129 THEN PROCbytes("3E0A"):PROCaddr("C3","$memerror") ELSE PROCdimseed(t%):PROCbytes("3E10"):PROCaddr("C3","$memerror")
16608 PROClabel(new$):PROCaddr("21","$sheapctx"):PROCarraycall("$arraydim",i%,n%,s%):ndepth%=0:ENDPROC
16610 DEF PROCdimblock(i%)
16612 LOCAL t%,j%:t%=vtype%(i%)
16614 IF t%<>4 AND t%<>5 PROCbad("Raw DIM requires a four-byte or variant numeric target")
16616 IF FNword("LOCAL") PROCbad("DIM LOCAL storage is unsupported")
16618 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%)):PROCaddr("21","$var"+STR$(i%)):PROCdimseed(t%)
16620 ndepth%=0:sdepth%=0:PROCexpr(1):PROCneednumber:PROCnumoperation(0,0,38)
16622 PROCaddr("2A","$v0"):PROCbyte(&23):PROCaddr("DD21","$sheapctx"):PROCaddr("CD","$memalloc"):PROCaddr("DA","$memerror")
16624 PROCaddr("ED53","$var"+STR$(i%)):ndepth%=0:ENDPROC
16626 DEF PROCreadscalar(i%)
16628 LOCAL t%,s$,j%:t%=vsize&(i%)
16630 IF vtype%(i%)=129 PROCbad("String value used as a numeric item")
16632 PROCusecompact:PROCnumslot:PROCaddr("CD","$cpread"+STR$(t%))
16634 PROCaddr("","$bind"+STR$(i%)):PROCbyte(ndepth%-1)
16638 valuekind%=0:ENDPROC
16640 DEF PROCmemtail
16642 LOCAL t%:IF FNpeek<>"?" AND FNpeek<>"!" ENDPROC
16644 t%=1:IF FNpeek="!" t%=4
16646 pos%=pos%+1:PROCmemoffset:PROCmemload(t%):ENDPROC
16648 DEF PROCmemoffset
16650 LOCAL p%:p%=ndepth%-1:PROCnumoperation(p%,p%,38)
16652 PROCitem:PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38)
16654 PROCaddr("2A","$v"+STR$(p%)):PROCaddr("ED5B","$v"+STR$(ndepth%-1)):PROCbyte(&19)
16656 PROCaddr("22","$v"+STR$(p%)):PROCaddr("21","$v"+STR$(p%)):PROCbytes("232323AF772377")
16658 ndepth%=p%+1:ENDPROC
16660 DEF PROCmemload(t%)
16662 LOCAL p%,j%:p%=ndepth%-1:PROCusememory
16664 PROCaddr("2A","$v"+STR$(p%)):PROCaddr("11","$v"+STR$(p%))
16666 PROCbyte(&01):PROCbyte(t%):PROCbytes("0000EDB0")
16668 IF t%<5 THEN PROCbyte(&AF):FOR j%=t% TO 4:PROCbytes("1213"):NEXT
16670 valuekind%=0:ENDPROC
16672 DEF PROCmemitem(c$)
16674 LOCAL t%
16676 IF c$="^" THEN pos%=pos%+1:PROCaddress:ENDPROC
16678 t%=1:IF c$="!" t%=4
16680 IF c$="|" t%=5
16682 pos%=pos%+1:PROCitem:PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38)
16684 PROCmemload(t%):ENDPROC
16686 DEF PROCaddress
16688 LOCAL n$,i%,p%
16690 IF dimparse%>0 PROCbad("Address-of in array DIM expressions is unqualified")
16692 n$=FNname:IF FNreserved(n$) PROCbad("Unsupported address target "+n$)
16694 i%=FNvariable(n$):IF vtype%(i%)>255 THEN PROCarrayaddress(i%,TRUE):valuekind%=0:ENDPROC
16696 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%)):PROCvalue(0):p%=ndepth%-1
16698 PROCaddr("21","$var"+STR$(i%)):PROCaddr("22","$v"+STR$(p%)):valuekind%=0:ENDPROC
16700 DEF PROCindirectassign(i%)
16702 LOCAL t%:t%=1:IF FNpeek="!" t%=4
16704 ndepth%=0:sdepth%=0:PROCreadscalar(i%):pos%=pos%+1:PROCmemoffset:PROCmemstore(t%):ENDPROC
16706 DEF PROCmemassign(c$)
16708 LOCAL t%:t%=1:IF c$="!" t%=4
16710 IF c$="|" t%=5
16712 PROCusememory:ndepth%=0:sdepth%=0:pos%=pos%+1:PROCitem:PROCneednumber:PROCnumoperation(0,0,38)
16714 PROCmemstore(t%):ENDPROC
16716 DEF PROCmemstore(t%)
16718 PROCusememory:PROCexpect("="):PROCexpr(1):PROCneednumber
16720 IF t%<>5 THEN PROCnumoperation(1,1,38)
16722 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(t%):PROCbytes("0000EDB0")
16724 ndepth%=0:sdepth%=0:ENDPROC
16726 DEF PROCdimseed(t%)
16728 LOCAL j%
16730 IF t%=1 THEN PROCbytes("7D77"):ENDPROC
16732 PROCbytes("E5D173237223AF"):FOR j%=3 TO t%:PROCbytes("7723"):NEXT:ENDPROC
16734 DEF PROCdimbranch(n$,z%)
16736 LOCAL r$:r$="C2":IF z% r$="CA"
16738 PROCaddr("2A","$v1"):PROCbytes("01000000B7ED42"):PROCaddr(r$,n$):ENDPROC
16740 DEF PROCdimchoice(i%,n%,s%)
16742 LOCAL old$,end$:old$=FNflow:end$=FNflow:PROCdimbranch(old$,FALSE)
16744 PROCnumindices(0,ndepth%-1):PROCaddr("CD","$dimstep"):PROCaddr("DA","$memerror"):PROCaddr("C3",end$)
16746 PROClabel(old$):PROCarraycall("$arrayprefix",i%,n%,s%):PROClabel(end$):ENDPROC
17500 DEF PROCloadio
17502 LOCAL i%,j%,s$
17504 RESTORE 61000:READ isize%,irelocs%,iopen%,iget%,ieof%,iput%,iputs%,iclose%,iinput%
17506 DIM iimage% isize%-1,ireloc%(irelocs%-1)
17508 FOR i%=0 TO isize%-1 STEP 40:READ s$
17510 FOR j%=1 TO LEN(s$) STEP 2:iimage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
17512 IF irelocs%>0 THEN FOR i%=0 TO irelocs%-1:READ ireloc%(i%):NEXT
17514 ENDPROC
17516 DEF PROCchannel
17518 PROCexpect("#"):PROCitem:PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38)
17520 ENDPROC
17522 DEF PROCioitem(w$)
17524 LOCAL m%,p%:io%=TRUE:fileio%=TRUE
17526 IF w$="BGET" OR w$="EOF" THEN PROCchannel:p%=ndepth%-1:PROCaddr("3A","$v"+STR$(p%)):PROCaddr("DD21","$v"+STR$(p%)):PROCaddr("CD","$io"+w$):valuekind%=0:ENDPROC
17528 m%=1:IF w$="OPENOUT" m%=10
17530 IF w$="OPENUP" m%=3
17532 PROCstritem:IF sunsafe%(sdepth%-1) PROCbad("Direct FN filename carriers are unqualified")
17534 PROCnumslot:PROCaddr("DD21","$v"+STR$(ndepth%-1)):PROCaddr("FD21","$s"+STR$(sdepth%-1))
17536 PROCbyte(&3E):PROCbyte(m%):PROCaddr("CD","$ioopen"):sdepth%=sdepth%-1:valuekind%=0:ENDPROC
17538 DEF PROCclosestatement
17540 io%=TRUE:fileio%=TRUE:ndepth%=0:sdepth%=0:PROCchannel
17542 PROCaddr("3A","$v0"):PROCaddr("CD","$ioclose"):ndepth%=0:ENDPROC
17544 DEF PROCbput
17546 LOCAL f%:io%=TRUE:fileio%=TRUE:ndepth%=0:sdepth%=0:PROCchannel:PROCexpect(","):PROCexpr(1):PROCspace
17548 IF valuekind%=0 THEN PROCneednumber:PROCnumoperation(1,1,38):PROCaddr("3A","$v1"):PROCbyte(&47):PROCaddr("3A","$v0"):PROCaddr("CD","$ioput"):ndepth%=0:ENDPROC
17550 f%=1:IF FNpeek=";" THEN f%=0:pos%=pos%+1
17552 PROCaddr("FD21","$s0"):PROCbyte(&0E):PROCbyte(f%):PROCaddr("3A","$v0"):PROCaddr("CD","$ioputs"):ndepth%=0:sdepth%=0:ENDPROC
17554 DEF PROCinputline
17556 LOCAL p$,n$,i%:io%=TRUE:PROCspace:IF NOT FNword("LINE") PROCbad("Only INPUT LINE is supported")
17558 pos%=pos%+4:PROCspace:p$="? ":IF FNpeek=CHR$(34) p$=FNstring
17560 PROCspace:n$=FNname:IF FNreserved(n$) PROCbad("Unsupported INPUT LINE target")
17562 i%=FNvariable(n$):IF vtype%(i%)<>129 PROCbad("INPUT LINE requires one scalar string variable")
17564 PROCspace:IF NOT FNstmtend PROCbad("INPUT LINE separators and multiple targets are unsupported")
17566 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%)):PROCtext(p$):ndepth%=0:sdepth%=0:PROCstrslot
17568 PROCaddr("DD21","$s0"):PROCaddr("CD","$ioinput"):PROCaddr("DA","$ioerror")
17570 PROCaddr("DD21","$var"+STR$(i%)):PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):sdepth%=0:ENDPROC
17572 DEF PROCIOruntime
17574 LOCAL b%,i%,p%,v%
17576 b%=pc%:PROCtemplate(iimage%,isize%,irelocs%,5)
17580 PROCctlexport("$ioopen",b%+iopen%):PROCctlexport("$ioBGET",b%+iget%):PROCctlexport("$ioEOF",b%+ieof%)
17582 PROCctlexport("$ioput",b%+iput%):PROCctlexport("$ioputs",b%+iputs%):PROCctlexport("$ioclose",b%+iclose%):PROCctlexport("$ioinput",b%+iinput%)
17584 PROClabel("$ioerror"):PROCerrorconstant(17,"Escape")
17586 ENDPROC
18000 DEF PROCloaddata
18002 LOCAL i%,j%,s$
18004 RESTORE 62000:READ dsize%,drelocs%,dpeek%,dnumber%,dstring%,dcommit%
18006 DIM dimage% dsize%-1,dreloc%(drelocs%),dpacket% 4
18008 FOR i%=0 TO dsize%-1 STEP 40:READ s$
18010 FOR j%=1 TO LEN(s$) STEP 2:dimage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
18012 IF drelocs%>0 THEN FOR i%=0 TO drelocs%-1:READ dreloc%(i%):NEXT
18014 ENDPROC
18016 DEF PROCcapturenumber(v)
18018 LOCAL i%,p%:p%=^v:FOR i%=0 TO 4:dpacket%?i%=p%?i%:NEXT
18020 ENDPROC
18022 DEF PROCcapturepacked(v,e%)
18024 LOCAL i%,q:FOR i%=0 TO 3:q=INT(v/256):dpacket%?i%=v-q*256:v=q:NEXT:dpacket%?4=e%
18026 ENDPROC
18028 DEF PROCusedata
18030 dataused%=TRUE:numeric%=TRUE:ENDPROC
18032 DEF PROCdatastatement
18034 IF NOT first% PROCbad("DATA must lead a physical line")
18036 pos%=LEN(line$)+1:ENDPROC
18038 DEF PROCrestoredata
18040 LOCAL t$:PROCusedata:PROCspace:t$="$databegin"
18042 IF NOT FNstmtend t$="$data#"+STR$(FNnumber(65279))
18044 PROCaddr("21",t$):PROCaddr("22","$datactx"):ENDPROC
18046 DEF PROCreadstatement
18048 LOCAL n$,i%,t%,a%,s%,more%
18050 PROCusedata
18052 REPEAT
18054 ndepth%=0:sdepth%=0:PROCvalue(0):PROCaddr("DD21","$datactx"):PROCaddr("FD21","$v0"):PROCaddr("CD","$datapeek"):PROCaddr("DA","$dataerror")
18056 n$=FNname:IF FNreserved(n$) PROCbad("Unsupported READ target "+n$)
18058 i%=FNvariable(n$):t%=vtype%(i%) AND 255:a%=(vtype%(i%)>255)
18060 IF a% THEN PROCarrayaddress(i%,TRUE) ELSE PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(i%))
18062 IF t%=129 THEN PROCreadstring(i%,a%) ELSE PROCreadnumber(i%,a%,t%)
18064 PROCaddr("DD21","$datactx"):PROCaddr("FD2A","$v0"):PROCaddr("CD","$datacommit"):ndepth%=0:sdepth%=0
18066 PROCspace:more%=(FNpeek=","):IF more% pos%=pos%+1
18068 UNTIL NOT more%
18070 ENDPROC
18072 DEF PROCreadnumber(i%,a%,t%)
18074 LOCAL s%:dnumeric%=TRUE:PROCnumslot:s%=ndepth%-1
18076 PROCaddr("DD21","$v"+STR$(s%)):PROCaddr("FD2A","$v0"):PROCaddr("CD","$datanumber"):PROCaddr("DA","$dataerror")
18078 IF t%<>5 THEN PROCnumoperation(s%,s%,38)
18080 IF NOT a% THEN PROCvarcopy("$v"+STR$(s%),"$var"+STR$(i%),t%):ENDPROC
18082 PROCaddr("21","$v"+STR$(s%)):PROCaddr("ED5B","$v1"):PROCbyte(&01):PROCbyte(t%):PROCbytes("0000EDB0"):ENDPROC
18084 DEF PROCreadstring(i%,a%)
18086 PROCstrslot:PROCaddr("DD21","$s0"):PROCaddr("FD2A","$v0"):PROCaddr("CD","$datastring")
18088 IF a% THEN PROCaddr("DD2A","$v1") ELSE PROCaddr("DD21","$var"+STR$(i%))
18090 PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):ENDPROC
18092 DEF PROCdataruntime
18094 LOCAL b%,i%,p%,v%
18096 b%=pc%:PROCtemplate(dimage%,dsize%,drelocs%,6)
18098 PROCctlexport("$datapeek",b%+dpeek%):PROCctlexport("$datanumber",b%+dnumber%):PROCctlexport("$datastring",b%+dstring%):PROCctlexport("$datacommit",b%+dcommit%)
18100 PROClabel("$datactx"):PROCaddr("","$databegin"):PROCaddr("","$dataend")
18102 PROClabel("$dataerror"):PROCbytes("FE06"):PROCaddr("CA","$datatypemismatch"):PROCbytes("FE10"):PROCaddr("CA","$datasyntax"):PROCbytes("FE2A"):PROCaddr("CA","$dataempty"):PROCaddr("C3","$numerror")
18104 PROClabel("$datatypemismatch"):PROCerrorconstant(6,"Type mismatch")
18106 PROClabel("$datasyntax"):PROCerrorconstant(16,"Syntax error")
18108 PROClabel("$dataempty"):PROCerrorconstant(42,"Out of DATA")
18110 ENDPROC
18112 DEF PROCdatatable
18114 LOCAL h%,n%,i%,p%,lnum%,pos%,line$,cr%
18116 h%=OPENIN(source$):IF h%=0 PROCbad("Cannot reopen DATA source")
18118 lnum%=0:cr%=FALSE:PROClabel("$databegin")
18120 WHILE NOT EOF#h%
18122 lnum%=lnum%+1:pos%=1:PROCreadline(h%):PROCspace:n%=-1
18124 IF FNdigit(FNpeek) n%=FNnumber(65279)
18126 PROCspace:IF FNword("DATA") PROCdataline(n%)
18128 ENDWHILE
18130 CLOSE#h%:PROClabel("$dataend")
18132 p%=start%:start%=&40000+pc%
18134 PROCaddr("21","$databegin"):PROCaddr("22","$datactx"):PROCbyte(&C3):PROCbyte(p% MOD 256):PROCbyte((p% DIV 256) MOD 256):PROCbyte(p% DIV 65536)
18136 ENDPROC
18138 DEF PROCdataline(n%)
18140 LOCAL more%:IF n%>=0 THEN IF FNlineref(n%,1,FALSE) PROClabel("$data#"+STR$(n%))
18142 pos%=pos%+4
18144 REPEAT
18146 PROCdatafield:more%=(FNpeek=","):IF more% pos%=pos%+1
18148 UNTIL NOT more%
18150 ENDPROC
18152 DEF PROCdatafield
18154 LOCAL s$,p%,i%,e%,q%
18156 PROCspace:q%=(FNpeek=CHR$(34))
18158 IF q% THEN s$=FNstring:PROCspace:IF FNpeek<>"" AND FNpeek<>"," PROCbad("Trailing text after quoted DATA is unqualified")
18160 IF NOT q% THEN p%=pos%:WHILE FNpeek<>"" AND FNpeek<>",":pos%=pos%+1:ENDWHILE:s$=MID$(line$,p%,pos%-p%)
18162 e%=6:FOR i%=0 TO 4:dpacket%?i%=0:NEXT
18164 IF NOT q% e%=FNdataencode(s$)
18166 IF e%=-1 AND dnumeric% PROCbad("Numeric READ requires literal DATA fields")
18168 IF e%=-1 e%=16
18170 IF s$<>"" THEN
18172 FOR i%=1 TO LEN(s$)
18174 IF ASC(MID$(s$,i%,1))<32 PROCbad("Control bytes in DATA are unsupported")
18176 NEXT
18178 ENDIF
18180 PROCcodecount(8):IF phase%=3 THEN BPUT#oh%,LEN(s$):BPUT#oh%,e%:FOR i%=0 TO 4:BPUT#oh%,dpacket%?i%:NEXT:BPUT#oh%,0
18182 PROCstringbytes(s$)
18184 ENDPROC
18186 DEF FNdataencode(s$)
18188 LOCAL line$,pos%,sign%,v,i%,e%,p%:line$=s$:pos%=1:sign%=0:numerr%=0
18190 PROCspace:IF FNpeek="" THEN =16
18192 IF FNpeek="+" OR FNpeek="-" THEN sign%=(FNpeek="-"):pos%=pos%+1:PROCspace
18194 IF NOT FNdigit(FNpeek) AND FNpeek<>"&" AND FNpeek<>"." THEN =-1
18196 dcapture%=TRUE:PROCconstant:dcapture%=FALSE:PROCspace:IF FNpeek<>"" THEN =-1
18198 IF sign% AND numerr%=0 THEN v=|dpacket%:v=-v:p%=^v:FOR i%=0 TO 4:dpacket%?i%=p%?i%:NEXT
18200 =numerr%
18202 DEF PROCdatabytecheck(b%)
18204 IF b%<32 PROCbad("Control bytes in DATA are unsupported")
18206 ENDPROC
19000 DEF PROCloaderrors
19002 LOCAL i%,j%,s$
19004 DIM eentry%(23):RESTORE 63000:READ esize%,erelocs%:FOR i%=0 TO 23:READ eentry%(i%):NEXT
19006 DIM eimage% esize%-1,ereloc%(erelocs%-1)
19008 FOR i%=0 TO esize%-1 STEP 40:READ s$
19010 FOR j%=1 TO LEN(s$) STEP 2:eimage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
19012 IF erelocs%>0 THEN FOR i%=0 TO erelocs%-1:READ ereloc%(i%):NEXT
19014 ENDPROC
19016 DEF PROCuseerrors
19018 PROCuseacts:PROCusememory:strings%=TRUE:IF sslots%=0 sslots%=1
19020 ENDPROC
19022 DEF PROCerrorscan
19024 LOCAL p%,q%,c$
19026 IF FNword("DATA") OR FNword("REM") ENDPROC
19027 IF INSTR(line$,"ERR")=0 AND INSTR(line$,"ERL")=0 AND INSTR(line$,"REPORT")=0 ENDPROC
19028 p%=pos%:q%=FALSE
19030 WHILE p%<=LEN(line$)
19032 c$=MID$(line$,p%,1):IF c$=CHR$(34) q%=NOT q%
19034 IF NOT q% THEN IF FNkindword(line$,p%,"REM") p%=LEN(line$)+1
19036 IF NOT q% THEN IF FNkindword(line$,p%,"ERROR") OR FNkindword(line$,p%,"ERR") OR FNkindword(line$,p%,"ERL") OR FNkindword(line$,p%,"REPORT") errors%=TRUE
19038 p%=p%+1:ENDWHILE
19040 ENDPROC
19042 DEF PROCerrmark
19044 IF NOT errors% ENDPROC
19045 IF FNword("REM") OR FNword("DATA") ENDPROC
19046 PROCerrorline
19050 ENDPROC
19052 DEF PROCerrorinstall
19054 LOCAL m%,t$:PROCexpectword("ERROR"):PROCspace:m%=0
19056 IF FNword("LOCAL") THEN m%=1:pos%=pos%+5:PROCspace
19058 IF FNword("OFF") THEN pos%=pos%+3:PROCbytes("210000003E"):PROCbyte(m%):PROCaddr("CD","$errinstall"):PROCaddr("DA","$acterror"):ENDPROC
19060 IF inum%<>0 PROCbad("ON ERROR handler installation inside inline IF is unsupported")
19062 IF hskip$<>"" PROCbad("Only one ON ERROR handler body per physical line is supported")
19064 t$=FNflow:hskip$=FNflow
19066 PROCaddr("21",t$):PROCbyte(&3E):PROCbyte(m%):PROCaddr("CD","$errinstall"):PROCaddr("DA","$acterror")
19068 PROCaddr("C3",hskip$):PROClabel(t$):PROCerrorline:PROCaddr("CD","$errtrap"):cont%=TRUE
19070 ENDPROC
19072 DEF PROCerrorstatement
19074 ndepth%=0:sdepth%=0:PROCexpr(1):PROCneednumber:PROCnumoperation(0,0,38):PROCexpect(","):PROCstrexpr
19076 IF sunsafe%(sdepth%-1) PROCbad("Direct FN error-message carriers are unqualified")
19078 PROCaddr("3A","$v0"):PROCaddr("FD21","$s0"):PROCaddr("C3","$errraise"):ndepth%=0:sdepth%=0
19080 ENDPROC
19082 DEF PROCerritem(w$)
19084 LOCAL t%,s$:t%=1:s$="$errcode":IF w$="ERL" t%=4:s$="$errlastline"
19086 PROCvalue(0):PROCvarcopy(s$,"$v"+STR$(ndepth%-1),t%):ENDPROC
19088 DEF PROCerrorconstant(n%,s$)
19090 LOCAL i%
19092 IF NOT errors% THEN PROCtext(s$):PROCnewline:PROCaddr("C3","$error"):ENDPROC
19094 IF n%>=0 THEN PROCbyte(&3E):PROCbyte(n%)
19095 PROCaddr("CD","$errinline"):PROCbyte(LEN(s$))
19096 PROCstringbytes(s$)
19098 ENDPROC
19100 DEF PROCerrorruntime
19102 LOCAL b%,i%,p%,v%,s%,s$,j%
19104 b%=pc%:PROCtemplate(eimage%,esize%,erelocs%,7)
19108 s$="errinit|errinstall|errraise|errinline|errreport|errline|errcode|errcurrent|errlastline|errmsg|errstate|":p%=1
19110 FOR i%=0 TO 10:j%=INSTR(s$,"|",p%):PROCctlexport("$"+MID$(s$,p%,j%-p%),b%+eentry%(i%)):p%=j%+1:NEXT
19112 REM Error bridges emitted with error template.
19115 PROCctlexport("$errtrap",b%+eentry%(23))
19116 ENDPROC
19118 DEF PROCerrorline
19120 LOCAL i%,p%:PROCaddr("CD","$errline"):p%=basicline%
19122 FOR i%=0 TO 3:PROCbyte(p% AND 255):p%=p% DIV 256:NEXT
19124 ENDPROC
19200 DEF PROCdefine(n$,a%)
19202 LOCAL i%,j%:i%=FNsymbol(n$)
19204 IF phase%>1 THEN IF i%<0 PROCbad("Layout target disappeared "+n$)
19206 IF phase%>1 THEN IF FNsymboladdr(i%)<>a% PROCbad("Layout target moved "+n$)
19208 IF phase%>1 ENDPROC
19210 IF i%>=0 PROCbad("Duplicate target "+n$)
19212 IF snum%=4096 PROCbad("Too many labels")
19214 IF snum%>sinsert% THEN FOR j%=2*snum%-1 TO 2*sinsert% STEP -1:sort%?(j%+2)=sort%?j%:NEXT
19216 PROCsortindex(sinsert%,snum%):sname$(snum%)=n$:PROCsymboladdr(snum%,a%):snum%=snum%+1
19218 ENDPROC
19220 DEF PROCword24(v%)
19222 LOCAL i%:PROCcodecount(3):IF phase%<>3 ENDPROC
19223 BPUT#oh%,CHR$(v%)+CHR$(v% DIV 256)+CHR$(v% DIV 65536);
19224 ENDPROC
19226 DEF FNlineref(n%,m%,w%)
19228 LOCAL i%,b%,p%:p%=FNrefpage(n% DIV 2048+32*m%,w%):IF p%=0 THEN =FALSE
19229 i%=(n% DIV 8) AND 255:b%=2^(n% AND 7)
19230 IF w% p%?i%=p%?i% OR b%
19232 =(p%?i% AND b%)<>0
19234 DEF PROCtargetscan
19236 LOCAL p%,q%,c$,w$,s%,n%,m%
19238 IF FNword("DATA") OR FNword("REM") ENDPROC
19240 IF INSTR(line$,"GOTO")=0 AND INSTR(line$,"GOSUB")=0 AND INSTR(line$,"THEN")=0 AND INSTR(line$,"ELSE")=0 AND INSTR(line$,"RESTORE")=0 ENDPROC
19242 p%=pos%:q%=FALSE
19244 WHILE p%<=LEN(line$)
19246 c$=MID$(line$,p%,1):IF c$=CHR$(34) q%=NOT q%
19248 w$="":m%=0
19250 IF NOT q% AND FNkindword(line$,p%,"REM") p%=LEN(line$)+1
19252 IF NOT q% AND FNkindword(line$,p%,"GOTO") w$="GOTO"
19254 IF NOT q% AND FNkindword(line$,p%,"GOSUB") w$="GOSUB"
19256 IF NOT q% AND FNkindword(line$,p%,"THEN") w$="THEN"
19258 IF NOT q% AND FNkindword(line$,p%,"ELSE") w$="ELSE"
19260 IF NOT q% AND FNkindword(line$,p%,"RESTORE") THEN w$="RESTORE":m%=1
19262 IF w$<>"" THEN s%=pos%:pos%=p%+LEN(w$):PROCspace:IF FNdigit(FNpeek) OR (m%=1 AND FNpeek="&") n%=FNnumber(65279):n%=FNlineref(n%,m%,TRUE)
19264 IF w$<>"" pos%=s%
19266 p%=p%+1:ENDWHILE
19268 ENDPROC
19270 DEF FNrelocindex(k%,i%)
19272 IF k%=0 THEN =nreloc%(i%)
19274 IF k%=1 THEN =sreloc%(i%)
19276 IF k%=2 THEN =treloc%(i%)
19278 IF k%=3 THEN =areloc%(i%)
19280 IF k%=4 THEN =mreloc%(i%)
19282 IF k%=5 THEN =ireloc%(i%)
19284 IF k%=6 THEN =dreloc%(i%)
19286 IF k%=7 THEN =ereloc%(i%)
19287 =xreloc%(i%)
19288 DEF PROCtemplate(p%,s%,r%,k%)
19289 LOCAL i%,j%,b%,o%,v%,n$,t%,x%,e%
19290 IF &40000+pc%+s%>&B0000 PROCbad("Executable exceeds user RAM")
19291 IF phase%=1 THEN pc%=pc%+s%:ENDPROC
19292 i%=0:j%=0:b%=&40000+pc%:t%=0:IF k%=7 t%=11
19293 IF k%=8 t%=13
19294 x%=FNbridgeoffset(k%,t%):o%=-1:IF r%>0 o%=FNrelocindex(k%,0)
19295 WHILE i%<s%
19296 IF i%=x% THEN
19297 PROCaddr("",FNbridgename(k%,t%)):i%=i%+3:t%=t%+1:x%=FNbridgeoffset(k%,t%)
19298 ELSE
19299 IF i%=o% THEN
19300 v%=p%?i%+256*p%?(i%+1)+65536*p%?(i%+2):PROCword24(v%+b%):i%=i%+3:j%=j%+1:o%=-1
19301 IF j%<r% o%=FNrelocindex(k%,j%)
19302 ELSE
19303 e%=s%:IF o%>=0 AND o%<e% e%=o%
19304 IF x%>=0 AND x%<e% e%=x%
19305 IF k%=2 AND i%<tframes% AND e%>tframes% e%=tframes%
19306 IF e%<=i% PROCbad("Invalid runtime relocation order")
19307 IF k%=2 AND i%>=tframes% THEN
19308 PROCzeros(e%-i%)
19309 ELSE
19310 IF phase%=3 THEN FOR v%=i% TO e%-1:BPUT#oh%,p%?v%:NEXT
19311 pc%=pc%+e%-i%
19312 ENDIF
19313 i%=e%
19314 ENDIF
19315 ENDIF
19316 ENDWHILE
19317 IF j%<>r% PROCbad("Invalid runtime relocation order")
19318 ENDPROC
19336 DEF FNbridgeoffset(k%,i%)
19338 IF k%=2 AND i%=0 THEN =tnumslot%
19340 IF k%=3 AND i%=0 THEN =apushslot%
19342 IF k%=3 AND i%=1 THEN =acheckslot%
19344 IF k%=3 AND i%=2 THEN =apopslot%
19346 IF k%=3 AND i%=3 THEN =anumslot%
19348 IF k%=7 AND i%<=22 THEN =eentry%(i%)
19349 IF k%=8 AND i%<=25 THEN =xentry%(i%)
19350 =-1
19352 DEF FNerrorslot(i%)
19354 LOCAL s$,p%,j%,k%:s$="$ctlpush|$strload|$strstore|$error|$ctltop|$acttop|$ctlframes|$actbase|$actlimit|$savedsp|$depth|$sheapctx|":p%=1
19356 FOR k%=11 TO i%:j%=INSTR(s$,"|",p%):IF k%<i% p%=j%+1
19358 NEXT
19360 =MID$(s$,p%,j%-p%)
19362 DEF FNbridgename(k%,i%)
19364 IF k%=7 THEN =FNerrorslot(i%)
19365 IF k%=8 THEN =FNcompactbridge(i%)
19366 IF k%=2 OR i%=3 THEN ="$numop"
19368 IF i%=0 THEN ="$ctlpush"
19370 IF i%=1 THEN ="$ctlcheck"
19372 ="$ctlpop"
19400 DEF PROCcodecount(n%)
19402 IF &40000+pc%+n%>&B0000 PROCbad("Executable exceeds user RAM")
19404 pc%=pc%+n%:ENDPROC
19406 DEF PROCblob(p%,n%)
19408 LOCAL i%:IF n%=0 ENDPROC
19410 PROCcodecount(n%):IF phase%<>3 ENDPROC
19412 FOR i%=0 TO n%-1:BPUT#oh%,p%?i%:NEXT:ENDPROC
19414 DEF PROCstringbytes(s$)
19416 LOCAL i%:IF s$="" ENDPROC
19418 PROCcodecount(LEN(s$)):IF phase%<>3 ENDPROC
19420 BPUT#oh%,s$;
19421 ENDPROC
19422 DEF PROCzeros(n%)
19424 LOCAL i%:IF n%=0 ENDPROC
19426 PROCcodecount(n%):IF phase%<>3 ENDPROC
19428 FOR i%=1 TO n%:BPUT#oh%,0:NEXT:ENDPROC
19500 DEF PROCusecompact
19502 compact%=TRUE:numeric%=TRUE:ENDPROC
19504 DEF PROCnumoperation(l%,r%,o%)
19506 PROCusecompact:PROCaddr("CD","$cpnum"):PROCbyte(l%):PROCbyte(r%):PROCbyte(o%):ENDPROC
19510 DEF PROCloadcompact
19512 LOCAL i%,j%,s$
19514 RESTORE 64000:READ xsize%,xrelocs%:DIM xentry%(25)
19516 FOR i%=0 TO 25:READ xentry%(i%):NEXT
19518 DIM ximage% xsize%-1,xreloc%(xrelocs%-1)
19520 FOR i%=0 TO xsize%-1 STEP 40:READ s$
19522 FOR j%=1 TO LEN(s$) STEP 2:ximage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
19524 IF xrelocs%>0 THEN FOR i%=0 TO xrelocs%-1:READ xreloc%(i%):NEXT
19526 ENDPROC
19530 DEF PROCcompactruntime
19532 LOCAL b%,i%,s$,p%,j%
19534 b%=pc%:PROCtemplate(ximage%,xsize%,xrelocs%,8)
19536 s$="$cplit|$cpnum|$cpread1|$cpread4|$cpread5|$cpstore1|$cpstore4|$cpstore5|$cpprefix|$cpaddr|$cpsave|$cpbind|$cpbegin|":p%=1
19538 FOR i%=0 TO 12:j%=INSTR(s$,"|",p%):PROCctlexport(MID$(s$,p%,j%-p%),b%+xentry%(i%)):p%=j%+1:NEXT
19540 PROCdefine("$zero",0):ENDPROC
19544 DEF FNcompactbridge(i%)
19546 LOCAL s$:s$="$zero"
19548 IF i%=13 AND nslots%>0 s$="$v0"
19550 IF i%=14 AND sslots%>0 s$="$s0"
19552 IF i%=15 s$="$numop"
19554 IF i%=16 s$="$numerror"
19556 IF i%=17 s$="$numlit"
19558 IF i%=18 AND vnum%>0 s$="$novar"
19560 IF i%=19 AND memory% s$="$arrayprefix"
19562 IF i%=20 AND memory% s$="$arrayaddr"
19564 IF i%=21 AND memory% s$="$memerror"
19566 IF i%=22 AND acts% s$="$actsave"
19568 IF i%=23 AND acts% s$="$actbind"
19570 IF i%=24 AND acts% s$="$actbegin"
19572 IF i%=25 AND acts% s$="$acterror"
19574 =s$
19580 DEF FNsortindex(i%)
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
40120 DATA "E1DDE1C9FD2702FDE1DDE1D1E9C30000000000000000000000"
40130 DATA 1,5,17,21,56,74,78,87,130,141,150,158,170,183,196,251,256,281,287,297
40140 DATA 305,309,316,330,349,372,380,421,429,436
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
61000 DATA 788,7,0,47,66,120,150,135,195
61010 DATA "DDE5FDE5F5FDE5E1010000004E231114010079B72802EDB03E0D12F14F211401003E0A5BCFCD6700"
61020 DATA "00FDE1DDE1AFC9DDE5FDE54F3E0C5BCFCD670000FDE1DDE1AFC9DDE5FDE54F3E0E5BCFFE013E0020"
61030 DATA "013DDD7700DD7701DD7702DD7703AFDD7704FDE1DDE1C9DD7700AFDD7701DD7702DD7703DD7704C9"
61040 DATA "DDE5FDE54F3E0D5BCFFDE1DDE1AFC9DDE5FDE54F3E0B5BCFFDE1DDE1AFC9DDE5FDE5C55FFD56004B"
61050 DATA "FDE5E1237AB7280946233E0D5BCF1520F7C179B728074B060A3E0D5BCFFDE1DDE1AFC9DDE5FDE521"
61060 DATA "14020001000100110100003E095BCFF521140200010000007EB72807230C79FEFF20F5DD710079B7"
61070 DATA "280A21140200DDE5D113EDB03E0D49D73E0A49D7F1FE1BFDE1DDE12802AFC93E11B737C900000000"
61080 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61090 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61100 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61110 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61120 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61130 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61140 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61150 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61160 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61170 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61180 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61190 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
61200 DATA "00000000000000000000000000000000000000000000000000000000"
61210 DATA 15,30,38,57,200,217,243
62000 DATA 120,0,0,29,61,99
62010 DATA "DD2700DD1703E5B7ED52E1300BFD2F00AFFD7703FD7704C93E2AB737C9FD7E01B72018DDE5FDE5FD"
62020 DATA "E5E12323DDE5D101050000EDB0FDE1DDE1AFC937C9DDE5FDE501000000FD4E00DD710079B7280EFD"
62030 DATA "E5E11108000019DDE5D113EDB0FDE1DDE1AFC9FDE5E111000000FD5E00191108000019DD2F00AFC9"
63000 DATA 2530,128,0,107,340,338,789,94,1009,1010,1014,1018,985,946,950,954,958,961,964,967,970,973,976,979,982,2481
63010 DATA "F5C5D5E5DDE5FDE521D9030011DA0300011700003600EDB03E0132D9030032DF030032E5030032EB"
63020 DATA "0300AF32F1030032FA03002100000022F2030022F3030022F6030022F703002133060011FA030001"
63030 DATA "220000EDB0FDE1DDE1E1D1C1F1C9E111F2030001040000EDB0E5C922FA0400320005002103000039"
63040 DATA "22FD0400DDE5FDE5B7282CDD21D90300CDFC00003869DD21DF0300CDFC0000385EDD21E50300CDFC"
63050 DATA "00003853DD21EB0300CDFC000038482AFA040022DA03003A00050032DD0300B728272AFD040022E0"
63060 DATA "03002AC10300ED2722E603002AC40300ED2722EC03002AD303007E32DE0300180DAF32DE03002100"
63070 DATA "000022E00300AFFDE1DDE1C92AC40300ED27E5110E00001922010500ED5BCD0300B7ED52FDE13805"
63080 DATA "2803AF37C9DDE5E1FD2F0023FD2F03FD360605FDE5D11313131313131301050000EDB0FDE5E13E06"
63090 DATA "CDB10300D82AC40300ED5B010500ED1FAFC9FDE132F1030021F2030011F6030001040000EDB00100"
63100 DATA "0000FD4600FDE5E12311FB030078B7280A7EB728061223130C10F67932FA03002100000022040500"
63110 DATA "3AF10300B7283A2ADA030011000000B7ED52282D220405003ADD0300B728222AE00300220705002A"
63120 DATA "E60300220A05002AEC0300220D05003ADE030032100500181F2AD00300ED27220705002AC7030022"
63130 DATA "0A05002ACA0300220D0500AF321005002A04050011000000B7ED52CA4302002AC10300ED27221105"
63140 DATA "002A110500ED5B0A0500B7ED52282C2A11050011200000B7ED52221105007EFE0620DE2323ED27E5"
63150 DATA "DDE1DD7E06FE8120D0CD770200DADF020018C62AC10300ED5B0A0500ED1F2AC40300ED5B0D0500ED"
63160 DATA "1F2AD303003A10050077ED7B0705002A04050011000000B7ED52CAF90200E9DD2703221405002323"
63170 DATA "ED27ED5B0D0500B7ED5238512A1405002323ED27E52AC40300ED17E1B7ED52303CFD2A140500DD21"
63180 DATA "1C0500CDB50300210000002217050022190500DD21170500FD211C05002AD60300CDB90300D82117"
63190 DATA "0500ED5B14050001050000EDB0AFC9AF32F10300211C060011FA030001080000EDB02AD00300ED27"
63200 DATA "F93E0D49D73E0A49D7CD150300CD7003003E0D49D73E0A49D7C3BD0300DDE5FDE521FA0300462378"
63210 DATA "B7280C7EC5E5CD340300E1C12310F4FDE1DDE1C9FE0ACA690300FEA0EA690300C5E521550600015A"
63220 DATA "0300EDB1C469030006A0FE92EA590300047E23B8F5EC690300F1EA590300E1C1C9C5E549D7E1C1C9"
63230 DATA "2AF603007CB5C8212406000609CDA603002AF60300113206000E00AF0610522917FE0A3803D60A2C"
63240 DATA "10F4C6301B120C7CB520E8D5E1417EC5E549D7E1C12310F6C9C3000000C3000000C3000000C30000"
63250 DATA "00000000000000000000000000000000000000000000000000010000000000010000000000010000"
63260 DATA "00000001000000000000000000000000000000000000000000000000000000000000000000000000"
63270 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63280 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63290 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63300 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63310 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63320 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63330 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63340 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63350 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63360 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63370 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63380 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63390 DATA "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
63400 DATA "00000000074E6F20726F6F6D206174206C696E65200000000000A52128432920436F707972696768"
63410 DATA "7420522E542E52757373656C6C20323032350D0A0A80414E44944142539541435396414456414C97"
63420 DATA "4153439841534E9941544E9A4247455420D542505554200F425920FB434F4C4F5552FB434F4C4F52"
63430 DATA "D643414C4CC843415345D7434841494EBD43485224D8434C45415220D9434C4F534520DA434C4720"
63440 DATA "DB434C53209B434F539C434F554E542001434952434C45DC444154419D444547DD44454681444956"
63450 DATA "DE44494DDF44524157E1454E4450524F4320CE454E445748494C4520CB454E444341534520CD454E"
63460 DATA "44494620E0454E4420E2454E56454C4F50458B454C5345A04556414C9E45524C20854552524F52C5"
63470 DATA "454F462082454F529F45525220104558495420A1455850A24558542002454C4C49505345E3464F52"
63480 DATA "A346414C5345200346494C4CA4464EE5474F544FBE47455424A5474554E4474F535542E647434F4C"
63490 DATA "9348494D454D20E8494E505554E74946BF494E4B455924A6494E4B4559A8494E54A7494E53545228"
63500 DATA "0C494E5354414C4C864C494E45924C4F4D454D20EA4C4F43414CC04C4546542428A94C454EE94C45"
63510 DATA "54AB4C4F47AA4C4EC14D49442428EB4D4F4445834D4F44EC4D4F5645044D4F555345ED4E455854AC"
63520 DATA "4E4F54EE4F4E874F464620CA4F4620054F524947494E844F528E4F50454E494EAE4F50454E4F5554"
63530 DATA "AD4F50454E5550FF4F53434C49CC4F5448455257495345F15052494E549050414745208F50545220"
63540 DATA "AF504920F0504C4F54B0504F494E542811504F494E5420F250524F43B1504F53200E505554065155"
63550 DATA "495420F852455455524E20F5524550454154F65245504F525420F352454144F452454DF952554E20"
63560 DATA "B2524144F7524553544F5245C252494748542428B3524E44200752454354414E474C458853544550"
63570 DATA "B453474EB553494EB653515289535043C353545224C4535452494E472428D4534F554E44FA53544F"
63580 DATA "5020C653554D085357415009535953B754414E8A544142288C5448454E9154494D45200A54494E54"
63590 DATA "28B8544FFC5452414345B95452554520FD554E54494CBA555352EF564455BB56414CBC56504F5320"
63600 DATA "C75748494C45C95748454E0B5741495420FE5749445448CF505452D154494D45D348494D454DD24C"
63610 DATA "4F4D454DD050414745124E6F2073756368201342616420142072616E6765157661726961626C6516"
63620 DATA "4F7574206F66174E6F2018207370616365194E6F7420696E2061201A206C6F6F701B206E6F7420FF"
63630 DATA "FFDDE5FDE53E085BCFDD7E18FE012016DD7E05FE1B200FFDE1DDE1FD21DB09003E11C3540100FDE1"
63640 DATA "DDE1C906457363617065"
63650 DATA 9,13,27,31,35,39,44,48,56,60,64,68,72,76,96,108,112,121,133,137
63660 DATA 144,148,155,159,166,170,176,180,184,188,195,199,203,209,213,219,223,228,235,243
63670 DATA 253,265,270,321,326,331,341,345,349,370,389,397,401,408,421,425,432,436,440,444
63680 DATA 448,452,456,460,466,472,476,480,484,488,493,497,508,512,518,522,527,536,547,570
63690 DATA 574,580,585,591,596,602,606,612,616,627,635,644,653,662,675,680,684,692,696,701
63700 DATA 706,710,714,719,724,737,741,745,755,770,774,786,794,807,823,829,835,845,853,862
63710 DATA 867,881,888,894,898,902,2509,2515
64000 DATA 394,29,28,43,78,84,90,157,163,204,222,252,282,300,335,344,347,351,355,359,363,367,371,375,379,383,387,391
64010 DATA "210000006F2605ED6CED5B58010019C92100000067ED5B5B010019C9E17E23E5CD000000E5DDE1C3"
64020 DATA "660100E146234E237E23E5F578CD000000E5DDE179CD000000E5FDE1F1CD5E0100DA620100C90101"
64030 DATA "0000180A01040000180401050000E1ED172323237E23E5DDE5FDE5D5DDE1CD000000E5FDE1DD7E00"
64040 DATA "B7281ADDE5E123FDE5D13E0591EDB0B7280647AF121310FCFDE1DDE1C9FDE1DDE1C36A0100010100"
64050 DATA "00180401040000E1ED17232323E5C5D5DD2A580100DDE5FDE13E26CD5E0100D1C1DA6201002A5801"
64060 DATA "00EDB0C9E1ED17232323E52A58010001050000EDB0C9E1ED372323237E2346234E23E5CD000000E5"
64070 DATA "FDE179CD6E0100DA760100C9E1ED372323237E2346234E23E5CD000000E5FDE179CD720100DA7601"
64080 DATA "00C9E1ED372323237E23E5CD7A0100DA860100C9E146234E237E23E5CB412006CD0000001804CD10"
64090 DATA "0000E5FDE178CD7E0100DA860100C9CD820100DA860100C9000000000000C3000000C3000000C300"
64100 DATA "0000C3000000C3000000C3000000C3000000C3000000C3000000C3000000C3000000"
64110 DATA 11,23,33,40,54,62,70,74,111,154,178,188,194,198,212,236,244,248,266,274
64120 DATA 278,292,296,313,319,327,331,336,340
