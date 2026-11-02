10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 PROCcreated(newformal%):PRINT ;newformal%
140 PRINT "REF_END_0"
150 CLEAR
160 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
170 PRINT "REF_BEGIN_1"
180 a$="A":b$="B":PROCexchange(a$,b$):PRINT a$;":";b$;":";saved$
190 PRINT "REF_END_1"
200 CLEAR
210 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
220 PRINT "REF_BEGIN_2"
230 s$="old":PROCappend(s$+"new"):PRINT s$
240 PRINT "REF_END_2"
250 CLEAR
260 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
270 PRINT "REF_BEGIN_3"
280 PROCerror3
290 PRINT "REF_END_3"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DEF PROCcreated(newformal%):PRINT ;newformal%:ENDPROC
40100 DEF PROCexchange(b$,a$):LOCAL scratch$:scratch$=a$+b$:saved$=scratch$:PRINT scratch$:ENDPROC
40200 DEF PROCappend(s$):PRINT s$:ENDPROC
40300 DEF PROCstageerror(n%,s$):ENDPROC
10300 DEF PROCerror3:LOCAL ERROR
10301 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10302 PROCstageerror(2147483648,STRING$(128,"ab"))
10390 ENDPROC
