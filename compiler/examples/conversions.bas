a$="  -12.5suffix":n=VAL(a$):PRINT ;n
PRINT "[";STR$(n);"]:[";STR$~(-12.9);"]"
PRINT ;ASC "";":";ASC CHR$(0);":";ASC CHR$(255)
PRINT ;VAL STR$(1/3);":";LEN STR$ 1/3
b$=STR$(VAL("12")+1)+STR$~255:PRINT b$
