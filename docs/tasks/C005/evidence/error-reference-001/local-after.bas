10 x%=7
20 r%=FNlocal:PRINT ;r%;":";x%:OSCLI "BYE"
1000 DEF FNlocal
1010 ON ERROR LOCAL PRINT "ERR=";ERR;":";ERL;":";x%:=42
1020 LOCAL x%:x%=99:ERROR 100,"boom"
