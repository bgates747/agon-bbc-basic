10 ndepth%=0:sdepth%=0:valuekind%=0:w$="":n$="":s$="":i%=0:j%=0:n%=0
20 PROCbyte(0):FOR q%=0 TO 0:NEXT:END
1000 DEF PROCexpr(a%):ENDPROC
1010 DEF PROCneednumber:ENDPROC
1020 DEF PROCnumoperation(a%,b%,c%):ENDPROC
1030 DEF PROCaddr(a$,b$):ENDPROC
1040 DEF PROCbyte(a%):ENDPROC
1050 DEF PROCbytes(a$):ENDPROC
1060 DEF PROCcharacter(a%):ENDPROC
1070 DEF PROCspace:ENDPROC
1080 DEF PROCexpect(a$):ENDPROC
1090 DEF PROCbad(a$):ENDPROC
1100 DEF PROCnumslot:ENDPROC
1110 DEF PROCerrorconstant(a%,a$):ENDPROC
1120 DEF FNpeek=""
1130 DEF FNflow=""
1500 DEF PROCdispatch
1510 IF w$="MODE" OR w$="GCOL" OR w$="PLOT" THEN PROCgraphics(w$):ENDPROC
1520 ENDPROC
1530 DEF PROCitemdispatch
1540 IF w$="GET" THEN PROCkeyvalue:ENDPROC
1550 ENDPROC
19630 DEF PROCgraphicarg
19632 PROCexpr(1):PROCneednumber:PROCnumoperation(ndepth%-1,ndepth%-1,38):ENDPROC
19634 DEF PROCgraphicbyte(i%,j%)
19636 PROCaddr("21","$v"+STR$(i%)):IF j%>0 PROCbyte(&23)
19638 PROCbytes("7E49D7"):ENDPROC
19640 DEF PROCgraphics(w$)
19642 LOCAL n%,i%
19644 IF w$="MODE" THEN PROCmode:ENDPROC
19646 ndepth%=0:sdepth%=0:PROCgraphicarg:n%=1:PROCspace
19648 IF FNpeek="," THEN PROCexpect(","):PROCgraphicarg:n%=2:PROCspace
19650 IF w$="GCOL" THEN
19652 PROCcharacter(18):IF n%=1 THEN PROCcharacter(0) ELSE PROCgraphicbyte(0,0)
19654 PROCgraphicbyte(n%-1,0):ndepth%=0:ENDPROC
19656 ENDIF
19658 IF n%<>2 PROCbad("PLOT needs two or three numeric arguments")
19660 IF FNpeek="," THEN PROCexpect(","):PROCgraphicarg:n%=3
19662 PROCcharacter(25):IF n%=2 THEN PROCcharacter(69) ELSE PROCgraphicbyte(0,0)
19664 FOR i%=n%-2 TO n%-1:PROCgraphicbyte(i%,0):PROCgraphicbyte(i%,1):NEXT
19666 ndepth%=0:ENDPROC
19670 DEF PROCmode
19672 PROCbytes("DDE53E0849CFDDCB04A6")
19674 ndepth%=0:sdepth%=0:PROCgraphicarg:PROCcharacter(22):PROCgraphicbyte(0,0)
19676 PROCbytes("3E0849CFDDCB046628FADDE1"):ndepth%=0:ENDPROC
19680 DEF PROCkeyvalue
19682 LOCAL n$,s$
19684 IF FNpeek="(" OR FNpeek="#" OR FNpeek="$" PROCbad("Only bare keyboard GET is supported")
19686 PROCnumslot:valuekind%=0:s$="$v"+STR$(ndepth%-1):n$=FNflow
19688 PROCbytes("DDE5FDE5AF49CFFDE1DDE1FE1B"):PROCaddr("C2",n$)
19690 PROCerrorconstant(17,"Escape"):PROClabel(n$)
19692 PROCaddr("21",s$):PROCbytes("7723AF77237723772377"):ENDPROC
