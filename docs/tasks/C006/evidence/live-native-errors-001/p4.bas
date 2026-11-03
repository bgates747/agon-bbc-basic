10 PRINT "ERROR_CASE_BEGIN_4"
20 s$="outer"
30 r%=FNstrlocal:PRINT ;r%;":";s$:PROCoverwrite:PRINT s$:END
1000 DEF FNstrlocal
1010 ON ERROR LOCAL PRINT s$:PROCoverwrite:PRINT s$:=42
1020 LOCAL s$:s$="after":ERROR 100,"lost"
1030 DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"q"):ENDPROC
