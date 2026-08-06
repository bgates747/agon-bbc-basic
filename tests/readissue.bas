   10 F$ = "TEST.$$$"
   20 F% = OPENOUT(F$)
   30 BPUT#F%, STRING$(128, CHR$(128))
   40 CLOSE #F%
   50 F% = OPENIN(F$)
   60 A$ = GET$#F% BY 128
   65 PRINT "Expecting 128, got ";LEN(A$)
   70 IF LEN(A$)<>128 PRINT "Failed" : STOP
   80 CLOSE #F%
