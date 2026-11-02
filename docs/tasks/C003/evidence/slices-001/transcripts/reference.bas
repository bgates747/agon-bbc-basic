10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 a$="abc":PRINT LEFT$(a$);":";RIGHT$(a$);":";MID$(a$,2)
140 PRINT LEFT$(a$,2);":";RIGHT$(a$,2);":";MID$(a$,2,1)
150 PRINT ;("a"<"b");":";("abc"="abc");":";("a">="b")
160 n%=(("a"="a") AND ("ab">"a")):PRINT ;n%:VDU 65-("a"="b"),13,10
170 PRINT "REF_END_0"
180 CLEAR
190 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
200 PRINT "REF_BEGIN_1"
210 a$="abcd"
220 PRINT "[";LEFT$(a$,0);"]:[";RIGHT$(a$,0);"]"
230 PRINT "[";LEFT$(a$,1);"]:[";RIGHT$(a$,1);"]"
240 PRINT "[";LEFT$(a$,4);"]:[";RIGHT$(a$,4);"]"
250 PRINT "[";LEFT$(a$,5);"]:[";RIGHT$(a$,5);"]"
260 PRINT "[";LEFT$(a$,-1);"]:[";RIGHT$(a$,-1);"]"
270 PRINT "[";LEFT$(a$,-256);"]:[";RIGHT$(a$,-256);"]"
280 PRINT "[";LEFT$(a$,255);"]:[";RIGHT$(a$,255);"]"
290 PRINT "[";LEFT$(a$,256);"]:[";RIGHT$(a$,256);"]"
300 PRINT "[";LEFT$(a$,257);"]:[";RIGHT$(a$,257);"]"
310 PRINT "[";LEFT$(a$,511);"]:[";RIGHT$(a$,511);"]"
320 PRINT "[";LEFT$(a$,65536);"]:[";RIGHT$(a$,65536);"]"
330 PRINT "[";LEFT$(a$,16777217);"]:[";RIGHT$(a$,16777217);"]"
340 PRINT "REF_END_1"
350 CLEAR
360 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
370 PRINT "REF_BEGIN_2"
380 a$="abcd"
390 PRINT "[";MID$(a$,0);"]:[";MID$(a$,0,2);"]"
400 PRINT "[";MID$(a$,1);"]:[";MID$(a$,1,2);"]"
410 PRINT "[";MID$(a$,2);"]:[";MID$(a$,2,2);"]"
420 PRINT "[";MID$(a$,4);"]:[";MID$(a$,4,2);"]"
430 PRINT "[";MID$(a$,5);"]:[";MID$(a$,5,2);"]"
440 PRINT "[";MID$(a$,-1);"]:[";MID$(a$,-1,2);"]"
450 PRINT "[";MID$(a$,-256);"]:[";MID$(a$,-256,2);"]"
460 PRINT "[";MID$(a$,255);"]:[";MID$(a$,255,2);"]"
470 PRINT "[";MID$(a$,256);"]:[";MID$(a$,256,2);"]"
480 PRINT "[";MID$(a$,257);"]:[";MID$(a$,257,2);"]"
490 PRINT "[";MID$(a$,511);"]:[";MID$(a$,511,2);"]"
500 PRINT "[";MID$(a$,65536);"]:[";MID$(a$,65536,2);"]"
510 PRINT "[";MID$(a$,16777218);"]:[";MID$(a$,16777218,2);"]"
520 PRINT "REF_END_2"
530 CLEAR
540 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
550 PRINT "REF_BEGIN_3"
560 a$="abcd"
570 PRINT "[";MID$(a$,2,0);"]"
580 PRINT "[";MID$(a$,2,1);"]"
590 PRINT "[";MID$(a$,2,3);"]"
600 PRINT "[";MID$(a$,2,4);"]"
610 PRINT "[";MID$(a$,2,-1);"]"
620 PRINT "[";MID$(a$,2,255);"]"
630 PRINT "[";MID$(a$,2,256);"]"
640 PRINT "[";MID$(a$,2,257);"]"
650 PRINT "[";MID$(a$,2,511);"]"
660 PRINT "[";MID$(a$,2,-256);"]"
670 PRINT "REF_END_3"
680 CLEAR
690 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
700 PRINT "REF_BEGIN_4"
710 empty$="":PRINT "[";LEFT$(empty$);RIGHT$(empty$);MID$(empty$,0);"]"
720 PRINT LEN(LEFT$(empty$,255));":";LEN(RIGHT$(empty$,1));":";LEN(MID$(empty$,1,2))
730 a$="abc":PRINT LEFT$(a$,2.9);":";RIGHT$(a$,-1.9);":";MID$(a$,2.9,1.9)
740 PRINT LEFT$("a"+"bc",1+1)+RIGHT$("xyz",2)
750 PRINT MID$(LEFT$("abcdef",5),2,LEN(RIGHT$("abcd",2)))
760 PRINT "REF_END_4"
770 CLEAR
780 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
790 PRINT "REF_BEGIN_5"
800 a$="abc":b$=MID$(a$,2):a$="z":PRINT b$:b$=LEFT$(b$):PRINT b$
810 x$="abcdef":x$=MID$(x$,2,3):PRINT x$:x$=RIGHT$(x$,2):PRINT x$
820 PRINT ;LEN(LEFT$("abcd",2))+LEN(MID$("abcd",3))
830 PRINT ;("a"="a")+2;":";NOT("a"="b");":";ABS("a"="a")
840 PRINT ;(("a"<"b")=(1<2));":";(("a"="a") AND ("c">"b"))
850 PRINT "REF_END_5"
860 CLEAR
870 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
880 PRINT "REF_BEGIN_6"
890 a$=CHR$(0)+CHR$(128)+CHR$(255)
900 PRINT LEN(MID$(a$,1,1));":";LEN(RIGHT$(a$,2));":";LEN(LEFT$(a$,3))
910 PRINT ;(CHR$(0)<CHR$(1));":";(CHR$(255)>CHR$(128));":";(CHR$(128)>"z")
920 PRINT ;(CHR$(0)+"x"=CHR$(0)+"x");":";(CHR$(0)<CHR$(0)+"x")
930 PRINT "REF_END_6"
940 CLEAR
950 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
960 PRINT "REF_BEGIN_7"
970 PRINT ;(""="")
980 PRINT ;(""<>"")
990 PRINT ;(""<"")
1000 PRINT ;(""<="")
1010 PRINT ;("">"")
1020 PRINT ;("">="")
1030 PRINT "REF_END_7"
1040 CLEAR
1050 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1060 PRINT "REF_BEGIN_8"
1070 PRINT ;(""="a")
1080 PRINT ;(""<>"a")
1090 PRINT ;(""<"a")
1100 PRINT ;(""<="a")
1110 PRINT ;("">"a")
1120 PRINT ;("">="a")
1130 PRINT "REF_END_8"
1140 CLEAR
1150 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1160 PRINT "REF_BEGIN_9"
1170 PRINT ;("a"="")
1180 PRINT ;("a"<>"")
1190 PRINT ;("a"<"")
1200 PRINT ;("a"<="")
1210 PRINT ;("a">"")
1220 PRINT ;("a">="")
1230 PRINT "REF_END_9"
1240 CLEAR
1250 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1260 PRINT "REF_BEGIN_10"
1270 PRINT ;("a"="aa")
1280 PRINT ;("a"<>"aa")
1290 PRINT ;("a"<"aa")
1300 PRINT ;("a"<="aa")
1310 PRINT ;("a">"aa")
1320 PRINT ;("a">="aa")
1330 PRINT "REF_END_10"
1340 CLEAR
1350 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1360 PRINT "REF_BEGIN_11"
1370 PRINT ;("aa"="a")
1380 PRINT ;("aa"<>"a")
1390 PRINT ;("aa"<"a")
1400 PRINT ;("aa"<="a")
1410 PRINT ;("aa">"a")
1420 PRINT ;("aa">="a")
1430 PRINT "REF_END_11"
1440 CLEAR
1450 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1460 PRINT "REF_BEGIN_12"
1470 PRINT ;("abc"="abd")
1480 PRINT ;("abc"<>"abd")
1490 PRINT ;("abc"<"abd")
1500 PRINT ;("abc"<="abd")
1510 PRINT ;("abc">"abd")
1520 PRINT ;("abc">="abd")
1530 PRINT "REF_END_12"
1540 CLEAR
1550 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1560 PRINT "REF_BEGIN_13"
1570 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
1580 b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
1590 c$=a$+b$
1600 PRINT LEN(LEFT$(c$,255));":";LEN(RIGHT$(c$,255));":";LEN(MID$(c$,255,255))
1610 PRINT ;(LEFT$(c$,128)=a$);":";(RIGHT$(c$,127)=b$);":";(c$=a$+b$)
1620 PRINT "REF_END_13"
1630 CLEAR
1640 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1650 PRINT "REF_BEGIN_14"
1660 PRINT (((((((((((((((((((("deep"))))))))))))))))))))
1670 PRINT LEFT$("abc",("a"="a"));":";MID$("abc",("a"="b"),257)
1680 PRINT "REF_END_14"
1690 CLEAR
1700 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1710 PRINT "REF_BEGIN_15"
1720 PROCerror15
1730 PRINT "REF_END_15"
1740 CLEAR
1750 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1760 PRINT "REF_BEGIN_16"
1770 PROCerror16
1780 PRINT "REF_END_16"
1790 CLEAR
1800 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1810 PRINT "REF_BEGIN_17"
1820 PROCerror17
1830 PRINT "REF_END_17"
1840 CLEAR
1850 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1860 PRINT "REF_BEGIN_18"
1870 PROCerror18
1880 PRINT "REF_END_18"
1890 CLEAR
1900 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1910 PRINT "REF_BEGIN_19"
1920 PROCerror19
1930 PRINT "REF_END_19"
1940 CLEAR
1950 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1960 PRINT "REF_BEGIN_20"
1970 PROCerror20
1980 PRINT "REF_END_20"
1990 CLEAR
2000 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
2010 PRINT "REF_BEGIN_21"
2020 PROCerror21
2030 PRINT "REF_END_21"
2040 CLEAR
2050 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
2060 PRINT "REF_BEGIN_22"
2070 PROCerror22
2080 PRINT "REF_END_22"
2090 CLEAR
2100 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
2110 PRINT "REF_BEGIN_23"
2120 PROCerror23
2130 PRINT "REF_END_23"
2140 CLEAR
2150 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
2160 PRINT "REF_BEGIN_24"
2170 PROCerror24
2180 PRINT "REF_END_24"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
11500 DEF PROCerror15:LOCAL ERROR
11501 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11502 PRINT LEFT$("abc",2147483648)
11590 ENDPROC
11600 DEF PROCerror16:LOCAL ERROR
11601 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11602 PRINT RIGHT$("",2147483648)
11690 ENDPROC
11700 DEF PROCerror17:LOCAL ERROR
11701 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11702 PRINT MID$("abc",2147483648)
11790 ENDPROC
11800 DEF PROCerror18:LOCAL ERROR
11801 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11802 PRINT MID$("abc",1,2147483648)
11890 ENDPROC
11900 DEF PROCerror19:LOCAL ERROR
11901 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11902 PRINT LEFT$(missing$,1/0)
11990 ENDPROC
12000 DEF PROCerror20:LOCAL ERROR
12001 ON ERROR LOCAL REPORT:PRINT:ENDPROC
12002 PRINT MID$("abc",1/0,2147483648)
12090 ENDPROC
12100 DEF PROCerror21:LOCAL ERROR
12101 ON ERROR LOCAL REPORT:PRINT:ENDPROC
12102 PRINT MID$("",255,1/0)
12190 ENDPROC
12200 DEF PROCerror22:LOCAL ERROR
12201 ON ERROR LOCAL REPORT:PRINT:ENDPROC
12202 PRINT "a"=missing$
12290 ENDPROC
12300 DEF PROCerror23:LOCAL ERROR
12301 ON ERROR LOCAL REPORT:PRINT:ENDPROC
12302 PRINT "a"=CHR$(1/0)
12390 ENDPROC
12400 DEF PROCerror24:LOCAL ERROR
12401 ON ERROR LOCAL REPORT:PRINT:ENDPROC
12402 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
12403 b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
12404 PRINT a$+b$=""
12490 ENDPROC
