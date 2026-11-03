10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 a%=7:b&=257:c=2.75
140 PRINT ;a%;":";b&;":";c;":";(a%+b&)*(c-1)
150 a%=c:b&=-1:c=a%+0.5:PRINT ;a%;":";b&;":";c
160 PRINT "REF_END_0"
170 CLEAR
180 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
190 PRINT "REF_BEGIN_1"
200 DIM a%(1,1),b&(1),f(1),s$(1)
210 a%(1,1)=-123:b&(1)=257:f(1)=2.75:s$(1)="array"
220 PRINT ;a%(1,1);":";b&(1);":";f(1);":";s$(1)
230 PRINT "REF_END_1"
240 CLEAR
250 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
260 PRINT "REF_BEGIN_2"
270 text$="outer":PROCouter:PRINT text$
280 value=1.5:whole%=-7:byte&=255:s$="old":PROCtypes(2.5,9.9,257,"new"):PRINT ;value;":";whole%;":";byte&;":";s$
290 copy$="original":PROCslice(copy$):PRINT copy$
300 PROCrecursive(4):PRINT ;n%
310 PRINT "REF_END_2"
320 CLEAR
330 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
340 PRINT "REF_BEGIN_3"
350 PRINT ;1+FNwouter(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,FNwargs(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15))
360 PRINT "REF_END_3"
370 CLEAR
380 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
390 PRINT "REF_BEGIN_4"
400 a$="string only":PRINT a$
410 PRINT "REF_END_4"
420 CLEAR
430 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
440 PRINT "REF_BEGIN_5"
450 PROCerror5
460 PRINT "REF_END_5"
470 CLEAR
480 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
490 PRINT "REF_BEGIN_6"
500 PROCerror6
510 PRINT "REF_END_6"
520 CLEAR
530 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
540 PRINT "REF_BEGIN_7"
550 PROCerror7
560 PRINT "REF_END_7"
570 CLEAR
580 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
590 PRINT "REF_BEGIN_8"
600 PROCerror8
610 PRINT "REF_END_8"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40200 DEF PROCouter:LOCAL text$:text$="inner":PROCsee:ENDPROC
40201 DEF PROCsee:PRINT text$:ENDPROC
40202 DEF PROCtypes(value,whole%,byte&,s$):PRINT ;value;":";whole%;":";byte&;":";s$:ENDPROC
40203 DEF PROCslice(s$):MID$(s$,2,2)="XY":PRINT s$:ENDPROC
40204 DEF PROCrecursive(n%):PRINT ;n%:IF n%>0 THEN PROCrecursive(n%-1)
40205 ENDPROC
40300 DEF FNwouter(wo0%,wo1%,wo2%,wo3%,wo4%,wo5%,wo6%,wo7%,wo8%,wo9%,wo10%,wo11%,wo12%,wo13%,wo14%,wo15%)=wo0%+wo15%
40301 DEF FNwargs(w0%,w1%,w2%,w3%,w4%,w5%,w6%,w7%,w8%,w9%,w10%,w11%,w12%,w13%,w14%,w15%)=w0%+w15%
10500 DEF PROCerror5:LOCAL ERROR
10501 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10502 PRINT ;1/0
10590 ENDPROC
10600 DEF PROCerror6:LOCAL ERROR
10601 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10602 PRINT ;missing%
10690 ENDPROC
10700 DEF PROCerror7:LOCAL ERROR
10701 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10702 a%=2147483648
10790 ENDPROC
10800 DEF PROCerror8:LOCAL ERROR
10801 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10802 DIM a%(0):PRINT ;a%(1)
10890 ENDPROC
