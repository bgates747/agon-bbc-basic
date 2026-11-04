10 REM C011 broad paired benchmark v1 - same source under both engines
20 REM Experimental: no target execution claimed. See readme.txt.
30 ON ERROR PRINT "FAILED ERR=";ERR;" ERL=";ERL:REPORT:CLOSE #0:END
40 DIM ba&(63),ia%(63),va(7,7),sa$(7),hist%(32)
50 DIM bases%(42),names$(42)
60 DIM raw% 63
70 hex$="0123456789ABCDEF"
80 FOR case%=1 TO 42:READ names$(case%),bases%(case%):NEXT
90 fh%=OPENIN("clock.dat")
100 IF fh%=0 PRINT "Run clock.bin from this directory first":END
110 magic$="":FOR j%=1 TO 4:magic$=magic$+CHR$(BGET#fh%):NEXT
120 IF magic$<>"C011" CLOSE #fh%:PRINT "Wrong clock.dat":END
130 clock%=BGET#fh%:clock%=clock%+256*BGET#fh%:clock%=clock%+65536*BGET#fh%
140 IF NOT EOF#fh% CLOSE #fh%:PRINT "Wrong clock.dat size":END
150 CLOSE #fh%
160 IF clock%<256 PRINT "Invalid clock pointer":END
170 PRINT "C011 v1. Run clock.bin again after reboot or MOS change."
180 PRINT "First run: cases 1..42, scale 1, repetitions 1. No speed claim yet."
190 INPUT LINE "Result filename (fresh, e.g. ref001.csv): " out$
200 fh%=OPENIN(out$)
210 IF fh%<>0 CLOSE #fh%:PRINT "Preserve existing result; choose fresh name":END
220 INPUT LINE "Engine tag (ref or native): " engine$
230 IF engine$<>"ref" AND engine$<>"native" PRINT "Use ref or native":END
240 INPUT LINE "First case (1..42): " in$:first%=VAL(in$)
250 INPUT LINE "Last case (first..42): " in$:last%=VAL(in$)
260 INPUT LINE "Scale (1..1000; SAME for both engines): " in$:scale%=VAL(in$)
270 INPUT LINE "Measured repetitions (1 pilot, 5 or more measured): " in$:reps%=VAL(in$)
280 IF first%<1 OR last%>42 OR first%>last% PRINT "Invalid case range":END
290 IF scale%<1 OR scale%>1000 OR reps%<1 OR reps%>20 PRINT "Invalid scale/repetitions":END
300 log%=OPENOUT(out$)
310 IF log%=0 PRINT "Cannot create result":END
320 line$="C011,1,"+engine$+","+STR$(first%)+","+STR$(last%)+","+STR$(scale%)+","+STR$(reps%)
330 BPUT #log%,line$
340 REM Bounded clock-advancement check; observed units, not millisecond claims.
350 before=FNtick:gran%=2147483647:edges%=0:polls%=0
360 REPEAT
370 now=FNtick:polls%=polls%+1
380 IF now<>before THEN
390 jump=FNdelta(before,now)
400 IF jump<gran% gran%=jump
410 edges%=edges%+1:before=now
420 ENDIF
430 UNTIL edges%=8 OR polls%=20000
440 IF edges%<8 PRINT "Clock did not advance enough; discard run":CLOSE #log%:END
450 PRINT "Observed minimum clock increment (centiseconds): ";gran%
460 line$="CLOCK,"+STR$(clock%)+","+STR$(gran%)+","+STR$(polls%)
470 BPUT #log%,line$
480 FOR case%=first% TO last%
490 work%=bases%(case%)*scale%
500 PRINT "Case ";case%;" ";names$(case%);" n=";work%
510 REM sample zero is a warmup, logged but excluded from measured statistics.
520 FOR sample%=0 TO reps%
530 PROCsetup(case%)
540 tick0=FNtick
550 PROCrun(case%,work%)
560 tick1=FNtick
570 elapsed=FNdelta(tick0,tick1)
580 PROCcollect(case%,work%)
590 state$=STR$(acc%)+":"+FNmemory(^z,5)+":"+FNhstring(s$)
600 line$="S,"+STR$(case%)+","+STR$(sample%)+","+STR$(work%)+","+STR$~tick0+","+STR$~tick1+","+STR$~elapsed+","+state$
610 BPUT #log%,line$
620 PRINT "  sample ";sample%;" cs=";elapsed;" state=";state$
630 IF elapsed<1000 PRINT "  SHORT: increase SAME scale in a fresh pair for precise timing"
640 NEXT
650 NEXT
660 BPUT #log%,"DONE"
670 CLOSE #log%
680 PRINT "Finished. Preserve both logs; compare states before using timings."
690 END
700 DEF FNtick
710 LOCAL aa%,bb%,tries%
720 tries%=0
730 REPEAT
740 aa%=!clock% AND &7FFFFFFF:bb%=!clock% AND &7FFFFFFF:tries%=tries%+1
750 UNTIL aa%=bb% OR tries%=100
760 IF aa%<>bb% ERROR 100,"Clock read unstable"
770 =bb%
780 DEF FNdelta(aa,bb)
790 LOCAL dd
800 dd=bb-aa:IF dd<0 dd=dd+2147483648
810 =dd
820 DEF FNmemory(ptr%,len%)
830 LOCAL t$,jj%,v%
840 t$=""
850 FOR jj%=0 TO len%-1
860 v%=ptr%?jj%:t$=t$+MID$(hex$,v% DIV 16+1,1)+MID$(hex$,v% MOD 16+1,1)
870 NEXT
880 =t$
890 DEF FNhstring(text$)
900 LOCAL t$,jj%,v%
910 t$=""
920 FOR jj%=1 TO LEN(text$)
930 v%=ASC MID$(text$,jj%,1):t$=t$+MID$(hex$,v% DIV 16+1,1)+MID$(hex$,v% MOD 16+1,1)
940 NEXT
950 =t$
960 DEF PROCsetup(kk%)
970 acc%=0:z=0:s$="":x%=7:y%=3:x=0.5:y=0.25:factor=1.000001:flag%=0
980 saved%=77:held$="outer":one=12.5:two%=91:word$="abcdefghijklmnop":record$="12,ALPHA,34,BETA"
990 FOR ii%=0 TO 63:ba&(ii%)=ii%:ia%(ii%)=63-ii%:raw%?ii%=ii%:NEXT
1000 FOR ii%=0 TO 7
1010 sa$(ii%)=CHR$(65+ii%):FOR jj%=0 TO 7:va(ii%,jj%)=ii%*8+jj%:NEXT
1020 NEXT
1030 FOR ii%=0 TO 32:hist%(ii%)=0:NEXT
1040 IF kk%=35 THEN
1050 io%=OPENIN("input.dat")
1060 IF io%=0 ERROR 101,"Missing input.dat"
1070 ENDIF
1080 IF kk%=36 THEN
1090 io%=OPENOUT("scratch.dat")
1100 IF io%=0 ERROR 101,"Cannot create scratch.dat"
1110 ENDIF
1120 IF kk%=38 MODE 8
1130 ENDPROC
1140 DEF PROCrun(kk%,nn%)
1150 IF kk%=1 PROCempty(nn%)
1160 IF kk%=2 PROCinteger(nn%)
1170 IF kk%=3 PROCvariant(nn%)
1180 IF kk%=4 PROCbyte(nn%)
1190 IF kk%=5 PROCbranch(nn%)
1200 IF kk%=6 PROCwhile(nn%)
1210 IF kk%=7 PROCrepeat(nn%)
1220 IF kk%=8 PROCgosub(nn%)
1230 IF kk%=9 PROCcalls(nn%)
1240 IF kk%=10 PROClocals(nn%)
1250 IF kk%=11 PROCfnnum(nn%)
1260 IF kk%=12 PROCfnstr(nn%)
1270 IF kk%=13 PROCrecurse(nn%)
1280 IF kk%=14 PROCfloat1(nn%)
1290 IF kk%=15 PROCfloat4(nn%)
1300 IF kk%=16 PROCfloat16(nn%)
1310 IF kk%=17 PROCmuldiv(nn%)
1320 IF kk%=18 PROCbits(nn%)
1330 IF kk%=19 PROCtrig(nn%)
1340 IF kk%=20 PROClogpow(nn%)
1350 IF kk%=21 PROCconvert(nn%)
1360 IF kk%=22 PROCbytearray(nn%)
1370 IF kk%=23 PROCintarray(nn%)
1380 IF kk%=24 PROCmulti(nn%)
1390 IF kk%=25 PROCraw(nn%)
1400 IF kk%=26 PROCdata(nn%)
1410 IF kk%=27 PROCcopy(nn%)
1420 IF kk%=28 PROCslice(nn%)
1430 IF kk%=29 PROCsearch(nn%)
1440 IF kk%=30 PROCparse(nn%)
1450 IF kk%=31 PROCsort(nn%)
1460 IF kk%>=32 AND kk%<=34 PROCmandel(nn%,kk%-32)
1470 IF kk%=35 PROCread(nn%)
1480 IF kk%=36 PROCwrite(nn%)
1490 IF kk%=37 PROCformat(nn%)
1500 IF kk%=38 PROCgraphics(nn%)
1510 IF kk%=39 PROCint4(nn%)
1520 IF kk%=40 PROCint16(nn%)
1530 IF kk%=41 PROCfinecalls(nn%)
1540 IF kk%=42 PROCcoarsecalls(nn%)
1550 ENDPROC
1560 DEF PROCcollect(kk%,nn%)
1570 IF kk%=35 CLOSE #io%
1580 IF kk%=36 THEN
1590 CLOSE #io%:io%=OPENIN("scratch.dat")
1600 IF io%=0 ERROR 101,"Missing scratch.dat"
1610 acc%=0
1620 FOR ii%=1 TO nn%
1630 IF EOF#io% ERROR 101,"Short scratch.dat"
1640 bb%=BGET#io%:IF bb%<>(ii% AND 255) ERROR 101,"Wrong scratch byte"
1650 acc%=(acc%+bb%) AND &7FFFFFFF
1660 NEXT
1670 IF NOT EOF#io% ERROR 101,"Long scratch.dat"
1680 CLOSE #io%
1690 ENDIF
1700 IF kk%=38 MODE 1
1710 IF kk%=1 acc%=ii%
1720 IF kk%=3 z=x
1730 IF kk%=4 acc%=byte&
1740 IF kk%=14 OR kk%=15 OR kk%=16 OR kk%=19 OR kk%=20 z=x
1750 IF kk%=22 THEN
1760 acc%=0:FOR ii%=0 TO 63:acc%=acc%+ba&(ii%):NEXT
1770 ENDIF
1780 IF kk%=23 THEN
1790 acc%=0:FOR ii%=0 TO 63:acc%=acc%+ia%(ii%):NEXT
1800 ENDIF
1810 IF kk%=24 THEN
1820 acc%=0:FOR ii%=0 TO 7
1830 FOR jj%=0 TO 7:acc%=acc%+va(ii%,jj%):NEXT
1840 NEXT
1850 s$=sa$(nn% AND 7)
1860 ENDIF
1870 IF kk%=25 THEN
1880 acc%=0:FOR ii%=0 TO 63:acc%=acc%+raw%?ii%:NEXT
1890 ENDIF
1900 IF kk%=31 THEN
1910 acc%=0:FOR ii%=0 TO 63
1920 IF ii%>0 IF ia%(ii%)<ia%(ii%-1) ERROR 101,"Sort order"
1930 acc%=acc%+ia%(ii%)
1940 NEXT
1950 IF acc%<>2016 ERROR 101,"Sort sum"
1960 ENDIF
1970 IF kk%>=32 AND kk%<=34 THEN
1980 s$="":FOR ii%=0 TO 32:s$=s$+CHR$(hist%(ii%)):NEXT
1990 ENDIF
2000 IF kk%=2 OR kk%=6 OR kk%=7 OR kk%=8 OR kk%=9 OR kk%=10 OR kk%=11 THEN
2010 IF acc%<>nn% ERROR 101,"Counter check"
2020 ENDIF
2030 IF kk%=10 THEN
2040 IF saved%<>77 OR held$<>"outer" OR one<>12.5 OR two%<>91 ERROR 101,"LOCAL restoration"
2050 ENDIF
2060 IF kk%=13 IF acc%<>nn%*8 ERROR 101,"Recursion check"
2070 IF kk%=39 OR kk%=40 OR kk%=41 OR kk%=42 THEN
2080 IF acc%<>7 ERROR 101,"Integer identity"
2090 ENDIF
2100 ENDPROC
2110 DEF PROCempty(nn%)
2120 FOR ii%=1 TO nn%:NEXT
2130 ENDPROC
2140 DEF PROCinteger(nn%)
2150 FOR ii%=1 TO nn%:acc%=acc%+1:NEXT
2160 ENDPROC
2170 DEF PROCvariant(nn%)
2180 FOR ii%=1 TO nn%:x=x+y:NEXT
2190 ENDPROC
2200 DEF PROCbyte(nn%)
2210 byte&=0:FOR ii%=1 TO nn%:byte&=byte&+1:NEXT
2220 ENDPROC
2230 DEF PROCbranch(nn%)
2240 FOR ii%=1 TO nn%
2250 IF (ii% AND 3)=0 THEN
2260 acc%=acc%+3
2270 ELSE
2280 IF ii% MOD 2=0 acc%=acc%+2 ELSE acc%=acc%-1
2290 ENDIF
2300 NEXT
2310 ENDPROC
2320 DEF PROCwhile(nn%)
2330 ii%=0:WHILE ii%<nn%:ii%=ii%+1:acc%=acc%+1:ENDWHILE
2340 ENDPROC
2350 DEF PROCrepeat(nn%)
2360 ii%=0:REPEAT:ii%=ii%+1:acc%=acc%+1:UNTIL ii%=nn%
2370 ENDPROC
2380 DEF PROCgosub(nn%)
2390 FOR ii%=1 TO nn%:GOSUB 2420:NEXT
2400 GOTO 2440
2410 REM LABEL gosub
2420 acc%=acc%+1:RETURN
2430 REM LABEL gosub_end
2440 ENDPROC
2450 DEF PROCleaf
2460 acc%=acc%+1
2470 ENDPROC
2480 DEF PROCcalls(nn%)
2490 FOR ii%=1 TO nn%:PROCleaf:NEXT
2500 ENDPROC
2510 DEF PROCbound(v%)
2520 LOCAL saved%,held$,"one",two%
2530 saved%=v%:held$="local":one=1:two%=2:acc%=acc%+1
2540 ENDPROC
2550 DEF PROClocals(nn%)
2560 FOR ii%=1 TO nn%:PROCbound(ii%):NEXT
2570 ENDPROC
2580 DEF FNplus(v%)=v%+1
2590 DEF PROCfnnum(nn%)
2600 FOR ii%=1 TO nn%:acc%=FNplus(acc%):NEXT
2610 ENDPROC
2620 DEF FNword$(v$)=v$+"!"
2630 DEF PROCfnstr(nn%)
2640 FOR ii%=1 TO nn%:s$=FNword$(word$):NEXT
2650 ENDPROC
2660 DEF PROCdepth(v%)
2670 LOCAL held%
2680 held%=v%:IF v%>0 PROCdepth(v%-1)
2690 acc%=acc%+1
2700 ENDPROC
2710 DEF PROCrecurse(nn%)
2720 FOR ii%=1 TO nn%:PROCdepth(7):NEXT
2730 ENDPROC
2740 DEF PROCfloat1(nn%)
2750 FOR ii%=1 TO nn%:x=x*factor:NEXT
2760 ENDPROC
2770 DEF PROCfloat4(nn%)
2780 FOR ii%=1 TO nn%:x=x*factor*factor*factor*factor:NEXT
2790 ENDPROC
2800 DEF PROCfloat16(nn%)
2810 FOR ii%=1 TO nn%
2820 x=x*factor*factor*factor*factor
2830 x=x*factor*factor*factor*factor
2840 x=x*factor*factor*factor*factor
2850 x=x*factor*factor*factor*factor
2860 NEXT
2870 ENDPROC
2880 DEF PROCmuldiv(nn%)
2890 FOR ii%=1 TO nn%:x%=(x%*13+5) MOD 997:acc%=x% DIV y%:NEXT
2900 ENDPROC
2910 DEF PROCbits(nn%)
2920 FOR ii%=1 TO nn%
2930 x%=(x% EOR ii%) AND 65535:acc%=(NOT x%) OR (ii% AND 7)
2940 NEXT
2950 ENDPROC
2960 DEF PROCtrig(nn%)
2970 FOR ii%=1 TO nn%
2980 x=SIN(y)+COS(y)+TAN(y)+ASN(y)+ACS(y)+ATN(y)
2990 NEXT
3000 ENDPROC
3010 DEF PROClogpow(nn%)
3020 FOR ii%=1 TO nn%
3030 x=SQR(y)+EXP(y)+LN(y)+LOG(y)+y^y
3040 x=x+ABS(-y)+SGN(y)+INT(y)+DEG(y)+RAD(y)+PI
3050 NEXT
3060 ENDPROC
3070 DEF PROCconvert(nn%)
3080 FOR ii%=1 TO nn%:s$=STR$(VAL("123.25tail"))+STR$~x%:acc%=ASC CHR$(ii% AND 255):NEXT
3090 ENDPROC
3100 DEF PROCbytearray(nn%)
3110 FOR ii%=1 TO nn%:jj%=ii% AND 63:ba&(jj%)=ba&(jj%)+1:NEXT
3120 ENDPROC
3130 DEF PROCintarray(nn%)
3140 FOR ii%=1 TO nn%:jj%=ii% AND 63:ia%(jj%)=ia%(jj%)+1:NEXT
3150 ENDPROC
3160 DEF PROCmulti(nn%)
3170 FOR ii%=1 TO nn%
3180 jj%=ii% AND 7:va(jj%,jj%)=va(jj%,jj%)+1:sa$(jj%)=CHR$(65+jj%)+"x"
3190 NEXT
3200 ENDPROC
3210 DEF PROCraw(nn%)
3220 FOR ii%=1 TO nn%
3230 jj%=ii% AND 15:raw%!(jj%*4)=raw%!(jj%*4) EOR &01010101
3240 NEXT
3250 ENDPROC
3260 DEF PROCdata(nn%)
3270 FOR ii%=1 TO nn%:RESTORE 4330:READ aa%,"bb",cc$:acc%=aa%+bb:s$=cc$:NEXT
3280 ENDPROC
3290 DEF PROCcopy(nn%)
3300 FOR ii%=1 TO nn%:s$=word$:s$=s$:s$=s$+"xy"+CHR$(0):NEXT
3310 ENDPROC
3320 DEF PROCslice(nn%)
3330 FOR ii%=1 TO nn%
3340 s$=word$:LEFT$(s$,2)="XY":RIGHT$(s$,2)="ZZ":MID$(s$,4,3)="123"
3350 s$=LEFT$(s$,6)+MID$(s$,7,4)+RIGHT$(s$,4)
3360 IF s$<>"XYc123ghijmnZZ" ERROR 101,"Slice check"
3370 NEXT
3380 ENDPROC
3390 DEF PROCsearch(nn%)
3400 FOR ii%=1 TO nn%
3410 s$=STRING$(3,"ab")+word$:acc%=INSTR(s$,"def",3)+LEN(s$)
3420 IF s$<word$ flag%=TRUE ELSE flag%=FALSE
3430 NEXT
3440 ENDPROC
3450 DEF PROCparse(nn%)
3460 FOR ii%=1 TO nn%
3470 aa%=INSTR(record$,","):bb%=INSTR(record$,",",aa%+1):cc%=INSTR(record$,",",bb%+1)
3480 acc%=VAL(LEFT$(record$,aa%-1))+VAL(MID$(record$,bb%+1,cc%-bb%-1))
3490 s$=MID$(record$,aa%+1,bb%-aa%-1)+RIGHT$(record$,LEN(record$)-cc%)
3500 NEXT
3510 ENDPROC
3520 DEF PROCsort(nn%)
3530 FOR rr%=1 TO nn%
3540 FOR ii%=0 TO 63:ia%(ii%)=(ii%*37+13) MOD 64:NEXT
3550 FOR ii%=1 TO 63
3560 key%=ia%(ii%):jj%=ii%-1:move%=TRUE
3570 WHILE jj%>=0 AND move%
3580 IF ia%(jj%)>key% THEN
3590 ia%(jj%+1)=ia%(jj%):jj%=jj%-1
3600 ELSE
3610 move%=FALSE
3620 ENDIF
3630 ENDWHILE
3640 ia%(jj%+1)=key%
3650 NEXT
3660 NEXT
3670 ENDPROC
3680 DEF PROCmandel(nn%,region%)
3690 LOCAL cr,"ci","zr","zi",zr2,zi2,"nextz",it%,pixel%
3700 FOR rr%=1 TO nn%
3710 FOR pixel%=0 TO 15
3720 cr=-2+region%*0.75+(pixel% AND 3)*0.01:ci=0.1+(pixel% DIV 4)*0.01
3730 zr=0:zi=0:zr2=0:zi2=0:it%=0
3740 REPEAT
3750 nextz=zr2-zi2+cr:zi=2*zr*zi+ci:zr=nextz
3760 zr2=zr*zr:zi2=zi*zi:it%=it%+1
3770 UNTIL it%=32 OR zr2+zi2>=4
3780 acc%=acc%+it%
3790 REM Keep histogram small enough for exact binary-string encoding after timing.
3800 IF rr%=1 hist%(it%)=hist%(it%)+1
3810 NEXT
3820 NEXT
3830 ENDPROC
3840 DEF PROCread(nn%)
3850 FOR ii%=1 TO nn%
3860 IF EOF#io% ERROR 101,"input.dat too short"
3870 acc%=(acc%+BGET#io%) AND &7FFFFFFF
3880 NEXT
3890 ENDPROC
3900 DEF PROCwrite(nn%)
3910 FOR ii%=1 TO nn%:BPUT #io%,ii% AND 255:NEXT
3920 ENDPROC
3930 DEF PROCformat(nn%)
3940 FOR ii%=1 TO nn%:PRINT ;y;":";x%;":";word$:NEXT
3950 ENDPROC
3960 DEF PROCgraphics(nn%)
3970 FOR ii%=1 TO nn%:GCOL 0,ii% AND 15:PLOT 69,ii% MOD 320,ii% MOD 240:NEXT
3980 ENDPROC
3990 DEF PROCint4(nn%)
4000 acc%=7:FOR ii%=1 TO nn%:acc%=((acc%+y%)-y%+y%)-y%:NEXT
4010 ENDPROC
4020 DEF PROCint16(nn%)
4030 acc%=7:FOR ii%=1 TO nn%
4040 acc%=((acc%+y%)-y%+y%)-y%
4050 acc%=((acc%+y%)-y%+y%)-y%
4060 acc%=((acc%+y%)-y%+y%)-y%
4070 acc%=((acc%+y%)-y%+y%)-y%
4080 NEXT
4090 ENDPROC
4100 DEF FNadd(v%,w%)=v%+w%
4110 DEF FNgroup(v%,w%)=((v%+w%)-w%+w%)-w%
4120 DEF PROCfinecalls(nn%)
4130 acc%=7:FOR ii%=1 TO nn%
4140 acc%=FNadd(acc%,y%):acc%=FNadd(acc%,-y%)
4150 acc%=FNadd(acc%,y%):acc%=FNadd(acc%,-y%)
4160 NEXT
4170 ENDPROC
4180 DEF PROCcoarsecalls(nn%)
4190 acc%=7:FOR ii%=1 TO nn%:acc%=FNgroup(acc%,y%):NEXT
4200 ENDPROC
4210 DATA "loop",10000,"int-increment",10000,"variant-add",10000,"byte-wrap",10000
4220 DATA "branch-mixed",10000,"while",10000,"repeat",10000,"gosub",10000
4230 DATA "proc-leaf",10000,"proc-local",1000,"fn-number",10000,"fn-string",1000
4240 DATA "recursion",100,"float-one",1000,"float-four",1000,"float-sixteen",1000
4250 DATA "mul-div-mod",1000,"boolean",1000,"trigonometry",100,"log-power",100
4260 DATA "conversions",100,"byte-array",10000,"int-array",10000,"multi-array",1000
4270 DATA "raw-indirection",10000,"data-restore",1000,"string-copy",1000,"string-slices",1000
4280 DATA "search-repeat",1000,"record-parser",1000,"sort",1,"mandel-region-a",1
4290 DATA "mandel-region-b",1,"mandel-region-c",1,"file-read",4096,"file-write",4096
4300 DATA "print-format",10,"graphics-enqueue",100,"int-four",10000,"int-sixteen",10000
4310 DATA "fine-calls",1000,"coarse-calls",1000
4320 REM LABEL data
4330 DATA 17,2.5,"datum"
