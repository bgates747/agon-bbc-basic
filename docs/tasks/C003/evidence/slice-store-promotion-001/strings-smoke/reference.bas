10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 a$="hello":b$=a$:a$="x":PRINT a$;":";b$:a$=a$+"y":PRINT a$
140 PRINT "REF_END_0"
150 CLEAR
160 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
170 PRINT "REF_BEGIN_1"
180 empty$="":PRINT "[";empty$;"]":fresh$=fresh$+"a":PRINT fresh$:PRINT LEN(fresh$)
190 PRINT "REF_END_1"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
