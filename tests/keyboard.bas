   10 REM
   20 key=INKEY(100)
   30 IF key<>-1 THEN
   40   PRINT CHR$(key)
   60 ELSE
   70   PRINT "TIMEOUT"
   80 ENDIF
   90 GOTO 10
