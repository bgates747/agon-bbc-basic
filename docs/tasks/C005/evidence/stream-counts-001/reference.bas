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
210 a$="abracadabra":PRINT ;INSTR(a$,"abra");":";INSTR(a$,"abra",2)
220 b$=STRING$(3,"ab"):PRINT b$;":";STR$ INSTR(b$,"ba")
230 PRINT "[";STRING$(0,"x");"]:[";STRING$(2.9,"xy");"]"
240 PRINT ;INSTR(STRING$(4,"ab"),"ab",INSTR("123","2"))
250 PRINT STRING$(INSTR("abc","b"),STR$ ASC "A")
260 PRINT "REF_END_1"
270 CLEAR
280 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
290 PRINT "REF_BEGIN_2"
300 a$="abcdef":LEFT$(a$,3)=RIGHT$(a$,3):PRINT a$
310 a$="abcdef":RIGHT$(a$,4)=LEFT$(a$,2):PRINT a$
320 a$="abcdef":MID$(a$,2,3)=a$:PRINT a$
330 b$=a$:MID$(a$,2,LEN(a$)-2)=STRING$(2,"Z"):PRINT a$;":";b$
340 LEFT$(a$,LEN(a$))=STR$ INSTR(a$,"a"):PRINT a$
350 PRINT "REF_END_2"
360 CLEAR
370 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
380 PRINT "REF_BEGIN_3"
390 a$="abcdef":LEFT$(a$,0)="XYZ":PRINT a$
400 a$="abcdef":LEFT$(a$,1)="XYZ":PRINT a$
410 a$="abcdef":LEFT$(a$,2)="XYZ":PRINT a$
420 a$="abcdef":LEFT$(a$,5)="XYZ":PRINT a$
430 a$="abcdef":LEFT$(a$,6)="XYZ":PRINT a$
440 a$="abcdef":LEFT$(a$,7)="XYZ":PRINT a$
450 a$="abcdef":LEFT$(a$,-1)="XYZ":PRINT a$
460 a$="abcdef":LEFT$(a$,-256)="XYZ":PRINT a$
470 a$="abcdef":LEFT$(a$,255)="XYZ":PRINT a$
480 a$="abcdef":LEFT$(a$,256)="XYZ":PRINT a$
490 a$="abcdef":LEFT$(a$,257)="XYZ":PRINT a$
500 a$="abcdef":LEFT$(a$,511)="XYZ":PRINT a$
510 a$="abcdef":LEFT$(a$,65536)="XYZ":PRINT a$
520 a$="abcdef":LEFT$(a$,16777217)="XYZ":PRINT a$
530 a$="abcdef":LEFT$(a$,1.9)="XYZ":PRINT a$
540 a$="abcdef":LEFT$(a$,-1.9)="XYZ":PRINT a$
550 PRINT "REF_END_3"
560 CLEAR
570 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
580 PRINT "REF_BEGIN_4"
590 PROCerror4
600 PRINT "REF_END_4"
610 CLEAR
620 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
630 PRINT "REF_BEGIN_5"
640 PROCerror5
650 PRINT "REF_END_5"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
10400 DEF PROCerror4:LOCAL ERROR
10401 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10402 PRINT LEFT$("abc",2147483648)
10490 ENDPROC
10500 DEF PROCerror5:LOCAL ERROR
10501 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10502 PRINT STRING$(2147483648,missing$)
10590 ENDPROC
