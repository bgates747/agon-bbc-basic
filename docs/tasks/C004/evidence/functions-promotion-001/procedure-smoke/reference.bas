10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 A%=7:B%=8:PROCswap(A%,B%):PRINT ;A%;":";B%
140 x%=7:y%=8:PROCstaged(3,x%):PRINT ;x%;":";y%
150 PROCnew:PRINT ;fresh%;":";LEN fresh$
160 v%=7:PROCtwice:PRINT ;v%
170 PRINT "REF_END_0"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DEF PROCswap(B%,A%):PRINT ;A%;":";B%:ENDPROC
40001 DEF PROCstaged(x%,y%):PRINT ;x%;":";y%:ENDPROC
40002 DEF PROCnew:LOCAL fresh%,fresh$:fresh%=4:fresh$="x":ENDPROC
40003 DEF PROCtwice:LOCAL v%:v%=3:LOCAL v%:PRINT ;v%:v%=4:ENDPROC
