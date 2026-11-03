10 PRINT "ERROR_CASE_BEGIN_5"
20 n%=0
30 ON ERROR n%=n%+1:PRINT ;ERR;":";ERL;":";n%:IF n%<2 THEN GOTO 50 ELSE OSCLI "BYE"
40 REM handler stays enabled
50 ERROR 100,"again"
