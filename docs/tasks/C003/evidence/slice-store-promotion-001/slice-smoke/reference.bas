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
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
