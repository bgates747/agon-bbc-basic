10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 a$="abracadabra":PRINT ;INSTR(a$,"abra");":";INSTR(a$,"abra",2)
140 b$=STRING$(3,"ab"):PRINT b$;":";STR$ INSTR(b$,"ba")
150 PRINT "[";STRING$(0,"x");"]:[";STRING$(2.9,"xy");"]"
160 PRINT ;INSTR(STRING$(4,"ab"),"ab",INSTR("123","2"))
170 PRINT STRING$(INSTR("abc","b"),STR$ ASC "A")
180 PRINT "REF_END_0"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
