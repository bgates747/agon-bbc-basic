10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 PROCshared(4):PRINT ;FNshared(5);":";n%
140 PRINT "REF_END_0"
150 CLEAR
160 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
170 PRINT "REF_BEGIN_1"
180 PRINT FNpack(7,8,FNjoin("a",FNdecorate("b")))
190 PRINT FNjoin(FNdecorate("c"),FNdecorate("d"))
200 PRINT "REF_END_1"
210 CLEAR
220 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
230 PRINT "REF_BEGIN_2"
240 PRINT ;FNfactorial(15);":";FNexact(1/3)=1/3
250 PRINT ;FNmaximum=STRING$(255,"q")
260 PRINT "REF_END_2"
270 CLEAR
280 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
290 PRINT "REF_BEGIN_3"
300 s$=FNcarrier:PRINT RIGHT$(s$);":";RIGHT$(FNcarrier+"");":";RIGHT$(LEFT$(FNcarrier,2));":";RIGHT$(MID$(FNcarrier,1))
310 PRINT STRING$(2,FNcarrier+"");":";STRING$(2,LEFT$(FNcarrier,3))
320 PRINT "REF_END_3"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DEF PROCshared(n%):PRINT ;n%:ENDPROC
40001 DEF FNshared(n%)=n%+1
40100 DEF FNpack(a%,b%,s$)=STR$ a%+":"+STR$ b%+":"+s$
40101 DEF FNjoin(a$,b$)=a$+b$
40102 DEF FNdecorate(s$)=STR$ LEN(s$)+s$
40200 DEF FNfactorial(n%):IF n%=0 THEN =1 ELSE =n%*FNfactorial(n%-1)
40201 DEF FNexact(x)=x
40202 DEF FNmaximum=STRING$(255,"q")
40300 DEF FNcarrier="ABC"
