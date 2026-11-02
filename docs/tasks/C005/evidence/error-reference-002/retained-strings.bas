10 s$="outer":t$="old"
20 r%=FNouter:PRINT ;r%;":";s$;":";t$:OSCLI "BYE"
1000 DEF FNouter:LOCAL s$:s$="before"
1010 ON ERROR LOCAL PRINT s$;":";t$:PROCoverwrite:PRINT s$;":";t$:=42
1020 PROCinner:=0
1030 DEF PROCinner:LOCAL t$:t$="after":ERROR 100,"inner"
1040 DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"q"):ENDPROC
