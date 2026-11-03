10 PRINT "C010_BEGIN"
20 s$="outer":x%=7
30 PRINT "C010_WAIT"
40 PRINT ;FNkey(100);":";x%;":";s$
900 PRINT "C010_END"
910 END
1000 DEF FNkey(n%)
1010 LOCAL x%,s$
1020 x%=9:s$="inner"
1030 =n%+GET
