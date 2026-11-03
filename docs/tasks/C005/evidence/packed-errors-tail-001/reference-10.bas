10 PRINT "ERROR_CASE_BEGIN_10"
20 PRINT "prefix"+FNstringtrap;":";ERL:OSCLI "BYE"
1000 DEF FNstringtrap
1010 ON ERROR LOCAL ="result"
1020 LOCAL s$:s$="discard":ERROR 100,"string":="wrong"
