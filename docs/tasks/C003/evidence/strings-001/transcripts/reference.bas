10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 a$="hello":PRINT a$:LET b$=a$:PRINT b$
140 a$="x":PRINT a$;":";b$
150 a$=a$+"y":PRINT a$
160 b$=b$:PRINT b$
170 PRINT "REF_END_0"
180 CLEAR
190 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
200 PRINT "REF_BEGIN_1"
210 empty$="":PRINT "[";empty$;"]"
220 fresh$=fresh$+"a":PRINT fresh$
230 PRINT LEN(empty$);":";LEN(fresh$)
240 PRINT ("a"+("b"+"c"))
250 PRINT "a"+CHR$(65+1)+"c"
260 PRINT LEN(CHR$(0))
270 PRINT "REF_END_1"
280 CLEAR
290 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
300 PRINT "REF_BEGIN_2"
310 n%=65:a$=CHR$(n%):PRINT a$;":";LEN(a$)
320 PRINT CHR$65;CHR$(321);CHR$65.9
330 PRINT LEN("a"+"bc")+LEN "d"
340 PRINT CHR$(64+LEN("a"));":";CHR$(LEN(CHR$(65))+64)
350 text$="a:b""c":PRINT text$
360 PRINT "REF_END_2"
370 CLEAR
380 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
390 PRINT "REF_BEGIN_3"
400 a$="a":b$="b":a$="longer":b$="longest":PRINT a$;":";b$
410 a$="x":a$="same":a$="":a$="up":PRINT a$;":";b$
420 s$="a":s=7:s%=8:s&=9:PRINT s$;s;s%;s&
430 PRINT "REF_END_3"
440 CLEAR
450 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
460 PRINT "REF_BEGIN_4"
470 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
480 b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
490 c$=a$+b$:PRINT LEN(c$)
500 PRINT LEN(c$+""):d$=c$:c$="z":PRINT LEN(d$);":";LEN(c$)
510 PRINT "REF_END_4"
520 CLEAR
530 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
540 PRINT "REF_BEGIN_5"
550 reused$="one":PRINT reused$
560 PRINT "REF_END_5"
570 CLEAR
580 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
590 PRINT "REF_BEGIN_6"
600 reused$="two":PRINT reused$
610 PRINT "REF_END_6"
620 CLEAR
630 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
640 PRINT "REF_BEGIN_7"
650 PROCerror7
660 PRINT "REF_END_7"
670 CLEAR
680 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
690 PRINT "REF_BEGIN_8"
700 PROCerror8
710 PRINT "REF_END_8"
720 CLEAR
730 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
740 PRINT "REF_BEGIN_9"
750 PROCerror9
760 PRINT "REF_END_9"
770 CLEAR
780 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
790 PRINT "REF_BEGIN_10"
800 PROCerror10
810 PRINT "REF_END_10"
820 CLEAR
830 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
840 PRINT "REF_BEGIN_11"
850 PROCerror11
860 PRINT "REF_END_11"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
10700 DEF PROCerror7:LOCAL ERROR
10701 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10702 PRINT missing$
10790 ENDPROC
10800 DEF PROCerror8:LOCAL ERROR
10801 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10802 PRINT LEN(missing$)
10890 ENDPROC
10900 DEF PROCerror9:LOCAL ERROR
10901 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10902 PRINT CHR$(2147483648)
10990 ENDPROC
11000 DEF PROCerror10:LOCAL ERROR
11001 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11002 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
11003 b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
11004 c$=a$+b$
11090 ENDPROC
11100 DEF PROCerror11:LOCAL ERROR
11101 ON ERROR LOCAL REPORT:PRINT:ENDPROC
11102 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
11103 b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
11104 PRINT a$+(b$+CHR$(1/0))
11190 ENDPROC
