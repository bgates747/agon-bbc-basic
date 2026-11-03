10 PRINT "NREG_REFERENCE_BEGIN"
100 x%=7:PRINT ;FNsum(5);":";x%:OSCLI "BYE"
110 DEF FNsum(n%):LOCAL x%:x%=n%:IF n%<=1 THEN =1
120 =n%+FNsum(n%-1)
