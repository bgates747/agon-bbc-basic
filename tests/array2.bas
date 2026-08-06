   10 DIM a&(66000), b&(66000)
   20 a&() = 0,1,2,3,4
   30 a&(65999) = 255
   40 b&() = a&()
   50 IF b&(65999) = a&(65999) THEN
   55   PRINT "PASS"
   60 ELSE
   65   PRINT "FAIL"
   66   END
   70 ENDIF
   80 a&() = 7
   90 b&() = a&()
  100 FOR i = 0 TO 66000
  110   IF b&(i) <> 7 THEN
  120     PRINT "FAIL 2"
  130   ENDIF
  140 NEXT i
  150 PRINT "PASS 2"
