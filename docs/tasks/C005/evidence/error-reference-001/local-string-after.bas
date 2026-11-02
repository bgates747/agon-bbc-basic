10 s$="outer"
20 r%=FNlocal:PRINT ;r%;":";s$:PROCoverwrite:PRINT s$:OSCLI "BYE"
1000 DEF FNlocal
1010 ON ERROR LOCAL PRINT s$:PROCoverwrite:PRINT s$:=42
1020 LOCAL s$:s$="inner":ERROR 100,"boom"
1030 DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"q"):ENDPROC
