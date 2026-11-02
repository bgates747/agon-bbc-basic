a$="abracadabra":PRINT ;INSTR(a$,"abra");":";INSTR(a$,"abra",2)
b$=STRING$(3,"ab"):PRINT b$;":";STR$ INSTR(b$,"ba")
PRINT "[";STRING$(0,"x");"]:[";STRING$(2.9,"xy");"]"
PRINT ;INSTR(STRING$(4,"ab"),"ab",INSTR("123","2"))
PRINT STRING$(INSTR("abc","b"),STR$ ASC "A")
