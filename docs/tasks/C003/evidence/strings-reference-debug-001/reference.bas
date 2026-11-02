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
470 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx":b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy":c$=a$+b$:PRINT LEN(c$)
480 PRINT LEN(c$+""):d$=c$:c$="z":PRINT LEN(d$);":";LEN(c$)
490 PRINT "REF_END_4"
500 CLEAR
510 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
520 PRINT "REF_BEGIN_5"
530 PROCerror5
540 PRINT "REF_END_5"
550 CLEAR
560 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
570 PRINT "REF_BEGIN_6"
580 PROCerror6
590 PRINT "REF_END_6"
600 CLEAR
610 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
620 PRINT "REF_BEGIN_7"
630 PROCerror7
640 PRINT "REF_END_7"
650 CLEAR
660 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
670 PRINT "REF_BEGIN_8"
680 PROCerror8
690 PRINT "REF_END_8"
700 CLEAR
710 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
720 PRINT "REF_BEGIN_9"
730 PROCerror9
740 PRINT "REF_END_9"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
10500 DEF PROCerror5:LOCAL ERROR
10501 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10502 PRINT missing$
10590 ENDPROC
10600 DEF PROCerror6:LOCAL ERROR
10601 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10602 PRINT LEN(missing$)
10690 ENDPROC
10700 DEF PROCerror7:LOCAL ERROR
10701 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10702 PRINT CHR$(2147483648)
10790 ENDPROC
10800 DEF PROCerror8:LOCAL ERROR
10801 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10802 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx":b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy":c$=a$+b$
10890 ENDPROC
10900 DEF PROCerror9:LOCAL ERROR
10901 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10902 a$="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx":b$="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy":PRINT a$+(b$+CHR$(1/0))
10990 ENDPROC
