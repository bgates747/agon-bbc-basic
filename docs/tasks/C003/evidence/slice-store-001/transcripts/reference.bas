10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 a$="abcdef":LEFT$(a$)="XYZ":PRINT a$
140 a$="abcdef":RIGHT$(a$)="XYZ":PRINT a$
150 a$="abcdef":MID$(a$,2)="XYZ":PRINT a$
160 a$="abcdef":MID$(a$,0)="XYZ":PRINT a$
170 a$="abcdef":MID$(a$,0,2)="XYZ":PRINT a$
180 PRINT "REF_END_0"
190 CLEAR
200 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
210 PRINT "REF_BEGIN_1"
220 a$="abcdef":LEFT$(a$,0)="XYZ":PRINT a$
230 a$="abcdef":LEFT$(a$,1)="XYZ":PRINT a$
240 a$="abcdef":LEFT$(a$,2)="XYZ":PRINT a$
250 a$="abcdef":LEFT$(a$,5)="XYZ":PRINT a$
260 a$="abcdef":LEFT$(a$,6)="XYZ":PRINT a$
270 a$="abcdef":LEFT$(a$,7)="XYZ":PRINT a$
280 a$="abcdef":LEFT$(a$,-1)="XYZ":PRINT a$
290 a$="abcdef":LEFT$(a$,-256)="XYZ":PRINT a$
300 a$="abcdef":LEFT$(a$,255)="XYZ":PRINT a$
310 a$="abcdef":LEFT$(a$,256)="XYZ":PRINT a$
320 a$="abcdef":LEFT$(a$,257)="XYZ":PRINT a$
330 a$="abcdef":LEFT$(a$,511)="XYZ":PRINT a$
340 a$="abcdef":LEFT$(a$,65536)="XYZ":PRINT a$
350 a$="abcdef":LEFT$(a$,16777217)="XYZ":PRINT a$
360 a$="abcdef":LEFT$(a$,1.9)="XYZ":PRINT a$
370 a$="abcdef":LEFT$(a$,-1.9)="XYZ":PRINT a$
380 PRINT "REF_END_1"
390 CLEAR
400 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
410 PRINT "REF_BEGIN_2"
420 a$="abcdef":RIGHT$(a$,0)="XYZ":PRINT a$
430 a$="abcdef":RIGHT$(a$,1)="XYZ":PRINT a$
440 a$="abcdef":RIGHT$(a$,2)="XYZ":PRINT a$
450 a$="abcdef":RIGHT$(a$,5)="XYZ":PRINT a$
460 a$="abcdef":RIGHT$(a$,6)="XYZ":PRINT a$
470 a$="abcdef":RIGHT$(a$,7)="XYZ":PRINT a$
480 a$="abcdef":RIGHT$(a$,-1)="XYZ":PRINT a$
490 a$="abcdef":RIGHT$(a$,-256)="XYZ":PRINT a$
500 a$="abcdef":RIGHT$(a$,255)="XYZ":PRINT a$
510 a$="abcdef":RIGHT$(a$,256)="XYZ":PRINT a$
520 a$="abcdef":RIGHT$(a$,257)="XYZ":PRINT a$
530 a$="abcdef":RIGHT$(a$,511)="XYZ":PRINT a$
540 a$="abcdef":RIGHT$(a$,65536)="XYZ":PRINT a$
550 a$="abcdef":RIGHT$(a$,16777217)="XYZ":PRINT a$
560 a$="abcdef":RIGHT$(a$,1.9)="XYZ":PRINT a$
570 a$="abcdef":RIGHT$(a$,-1.9)="XYZ":PRINT a$
580 PRINT "REF_END_2"
590 CLEAR
600 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
610 PRINT "REF_BEGIN_3"
620 a$="abcdef":MID$(a$,0)="XYZ":PRINT a$
630 a$="abcdef":MID$(a$,1)="XYZ":PRINT a$
640 a$="abcdef":MID$(a$,2)="XYZ":PRINT a$
650 a$="abcdef":MID$(a$,5)="XYZ":PRINT a$
660 a$="abcdef":MID$(a$,6)="XYZ":PRINT a$
670 a$="abcdef":MID$(a$,7)="XYZ":PRINT a$
680 a$="abcdef":MID$(a$,-1)="XYZ":PRINT a$
690 a$="abcdef":MID$(a$,-256)="XYZ":PRINT a$
700 a$="abcdef":MID$(a$,0,2)="XYZ":PRINT a$
710 a$="abcdef":MID$(a$,1,2)="XYZ":PRINT a$
720 a$="abcdef":MID$(a$,2,2)="XYZ":PRINT a$
730 a$="abcdef":MID$(a$,5,2)="XYZ":PRINT a$
740 a$="abcdef":MID$(a$,6,2)="XYZ":PRINT a$
750 a$="abcdef":MID$(a$,7,2)="XYZ":PRINT a$
760 a$="abcdef":MID$(a$,-1,2)="XYZ":PRINT a$
770 a$="abcdef":MID$(a$,-256,2)="XYZ":PRINT a$
780 PRINT "REF_END_3"
790 CLEAR
800 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
810 PRINT "REF_BEGIN_4"
820 a$="abcdef":MID$(a$,255)="XYZ":PRINT a$
830 a$="abcdef":MID$(a$,256)="XYZ":PRINT a$
840 a$="abcdef":MID$(a$,257)="XYZ":PRINT a$
850 a$="abcdef":MID$(a$,511)="XYZ":PRINT a$
860 a$="abcdef":MID$(a$,65536)="XYZ":PRINT a$
870 a$="abcdef":MID$(a$,16777217)="XYZ":PRINT a$
880 a$="abcdef":MID$(a$,1.9)="XYZ":PRINT a$
890 a$="abcdef":MID$(a$,-1.9)="XYZ":PRINT a$
900 a$="abcdef":MID$(a$,255,2)="XYZ":PRINT a$
910 a$="abcdef":MID$(a$,256,2)="XYZ":PRINT a$
920 a$="abcdef":MID$(a$,257,2)="XYZ":PRINT a$
930 a$="abcdef":MID$(a$,511,2)="XYZ":PRINT a$
940 a$="abcdef":MID$(a$,65536,2)="XYZ":PRINT a$
950 a$="abcdef":MID$(a$,16777217,2)="XYZ":PRINT a$
960 a$="abcdef":MID$(a$,1.9,2)="XYZ":PRINT a$
970 a$="abcdef":MID$(a$,-1.9,2)="XYZ":PRINT a$
980 PRINT "REF_END_4"
990 CLEAR
1000 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1010 PRINT "REF_BEGIN_5"
1020 a$="abcdef":MID$(a$,2,0)="XYZ":PRINT a$
1030 a$="abcdef":MID$(a$,2,1)="XYZ":PRINT a$
1040 a$="abcdef":MID$(a$,2,2)="XYZ":PRINT a$
1050 a$="abcdef":MID$(a$,2,5)="XYZ":PRINT a$
1060 a$="abcdef":MID$(a$,2,6)="XYZ":PRINT a$
1070 a$="abcdef":MID$(a$,2,7)="XYZ":PRINT a$
1080 a$="abcdef":MID$(a$,2,-1)="XYZ":PRINT a$
1090 a$="abcdef":MID$(a$,2,-256)="XYZ":PRINT a$
1100 a$="abcdef":MID$(a$,2,255)="XYZ":PRINT a$
1110 a$="abcdef":MID$(a$,2,256)="XYZ":PRINT a$
1120 a$="abcdef":MID$(a$,2,257)="XYZ":PRINT a$
1130 a$="abcdef":MID$(a$,2,511)="XYZ":PRINT a$
1140 a$="abcdef":MID$(a$,2,65536)="XYZ":PRINT a$
1150 a$="abcdef":MID$(a$,2,16777217)="XYZ":PRINT a$
1160 a$="abcdef":MID$(a$,2,1.9)="XYZ":PRINT a$
1170 a$="abcdef":MID$(a$,2,-1.9)="XYZ":PRINT a$
1180 PRINT "REF_END_5"
1190 CLEAR
1200 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1210 PRINT "REF_BEGIN_6"
1220 a$=STRING$(255,"x"):MID$(a$,2,255)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1230 a$=STRING$(255,"x"):MID$(a$,3,254)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1240 a$=STRING$(255,"x"):MID$(a$,255,2)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1250 a$=STRING$(255,"x"):MID$(a$,255,3)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1260 a$=STRING$(255,"x"):MID$(a$,0,255)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1270 a$=STRING$(255,"x"):MID$(a$,0,0)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1280 a$=STRING$(255,"x"):MID$(a$,0,1)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1290 a$=STRING$(255,"x"):MID$(a$,256,2)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1300 a$=STRING$(255,"x"):MID$(a$,1,255)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1310 a$=STRING$(255,"x"):MID$(a$,2,256)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1320 a$=STRING$(255,"x"):MID$(a$,257,255)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1330 a$=STRING$(255,"x"):MID$(a$,-1,2)="YZ":PRINT ;LEN a$;":";LEFT$(a$,4);":";RIGHT$(a$,4)
1340 PRINT "REF_END_6"
1350 CLEAR
1360 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1370 PRINT "REF_BEGIN_7"
1380 a$="":LEFT$(a$)="x":RIGHT$(a$)="x":MID$(a$,0,2)="x":PRINT "[";a$;"]"
1390 a$="x":LEFT$(a$)="y":PRINT a$:LEFT$(a$,1)="":PRINT a$
1400 a$="xy":RIGHT$(a$,255)="A":PRINT a$:MID$(a$,1,0)="B":PRINT a$
1410 RIGHT$(a$,255)="":PRINT a$:LEFT$(a$,255)="ABCDEF":PRINT a$
1420 PRINT "REF_END_7"
1430 CLEAR
1440 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1450 PRINT "REF_BEGIN_8"
1460 a$="abcdef":LEFT$(a$,3)=RIGHT$(a$,3):PRINT a$
1470 a$="abcdef":RIGHT$(a$,4)=LEFT$(a$,2):PRINT a$
1480 a$="abcdef":MID$(a$,2,3)=a$:PRINT a$
1490 b$=a$:MID$(a$,2,LEN(a$)-2)=STRING$(2,"Z"):PRINT a$;":";b$
1500 LEFT$(a$,LEN(a$))=STR$ INSTR(a$,"a"):PRINT a$
1510 PRINT "REF_END_8"
1520 CLEAR
1530 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1540 PRINT "REF_BEGIN_9"
1550 a$=CHR$(0)+CHR$(128)+CHR$(255):b$=a$
1560 MID$(a$,2,1)=CHR$(0):PRINT ;LEN a$;":";ASC MID$(a$,2);":";ASC RIGHT$(a$)
1570 RIGHT$(a$,2)=CHR$(255):PRINT ;ASC RIGHT$(a$);":";(b$=CHR$(0)+CHR$(128)+CHR$(255))
1580 LEFT$(a$,1)=CHR$(128):PRINT ;ASC a$;":";LEN a$
1590 PRINT "REF_END_9"
1600 CLEAR
1610 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1620 PRINT "REF_BEGIN_10"
1630 PROCerror10
1640 PRINT "REF_END_10"
1650 CLEAR
1660 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1670 PRINT "REF_BEGIN_11"
1680 PROCerror11
1690 PRINT "REF_END_11"
1700 CLEAR
1710 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1720 PRINT "REF_BEGIN_12"
1730 PROCerror12
1740 PRINT "REF_END_12"
1750 CLEAR
1760 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1770 PRINT "REF_BEGIN_13"
1780 PROCerror13
1790 PRINT "REF_END_13"
1800 CLEAR
1810 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1820 PRINT "REF_BEGIN_14"
1830 PROCerror14
1840 PRINT "REF_END_14"
1850 CLEAR
1860 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1870 PRINT "REF_BEGIN_15"
1880 PROCerror15
1890 PRINT "REF_END_15"
1900 CLEAR
1910 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1920 PRINT "REF_BEGIN_16"
1930 PROCerror16
1940 PRINT "REF_END_16"
1950 CLEAR
1960 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
1970 PRINT "REF_BEGIN_17"
1980 PROCerror17
1990 PRINT "REF_END_17"
2000 CLEAR
2010 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
2020 PRINT "REF_BEGIN_18"
2030 PROCerror18
2040 PRINT "REF_END_18"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
11000 DEF PROCerror10:LOCAL ERROR
11001 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11002 LEFT$(missing$,1/0)=CHR$(1/0)
11090 ENDPROC
11100 DEF PROCerror11:LOCAL ERROR
11101 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11102 RIGHT$(missing$)="x"
11190 ENDPROC
11200 DEF PROCerror12:LOCAL ERROR
11201 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11202 MID$(missing$,2147483648)="x"
11290 ENDPROC
11300 DEF PROCerror13:LOCAL ERROR
11301 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11302 a$="x":LEFT$(a$,2147483648)=missing$
11390 ENDPROC
11400 DEF PROCerror14:LOCAL ERROR
11401 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11402 a$="":MID$(a$,1/0,2147483648)=missing$
11490 ENDPROC
11500 DEF PROCerror15:LOCAL ERROR
11501 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11502 a$="":MID$(a$,1,2147483648)=missing$
11590 ENDPROC
11600 DEF PROCerror16:LOCAL ERROR
11601 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11602 a$="":LEFT$(a$,0)=missing$
11690 ENDPROC
11700 DEF PROCerror17:LOCAL ERROR
11701 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11702 a$="x":MID$(a$,0)=CHR$(1/0)
11790 ENDPROC
11800 DEF PROCerror18:LOCAL ERROR
11801 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11802 a$="":RIGHT$(a$,0)=STRING$(128,"ab")
11890 ENDPROC
