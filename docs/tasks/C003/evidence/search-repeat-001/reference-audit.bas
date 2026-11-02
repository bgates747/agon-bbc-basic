10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A:a$=STRING$(255,"a")
30 PRINT ;INSTR("","");":";INSTR("a","");":";INSTR(a$,"")
40 PRINT ;INSTR(a$,"",0);":";INSTR(a$,"",255);":";INSTR(a$,"",256)
50 PRINT ;INSTR("abc","a",0);":";INSTR("abc","a",256);":";INSTR("abc","b",257)
60 PRINT ;INSTR(a$,"a",-1);":";INSTR(a$,"a",511);":";INSTR("abc","a",-256)
70 PRINT ;LEN STRING$(256,"a");":";LEN STRING$(-1,"a");":";LEN STRING$(-256,"a")
80 PRINT "SEARCH_REPEAT_AUDIT_DONE":OSCLI "BYE"
