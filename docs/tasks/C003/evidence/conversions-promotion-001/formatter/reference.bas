10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 @%=&90A:ch%=OPENOUT("format.dat")
100 value=0:text$=STR$(value):PROCsave
120 value=1:text$=STR$(value):PROCsave
140 value=-1:text$=STR$(value):PROCsave
160 value=&7FFFFFFF:text$=STR$(value):PROCsave
180 value=&80000000:text$=STR$(value):PROCsave
200 value=16777217:text$=STR$(value):PROCsave
220 value=2147483648.0:text$=STR$(value):PROCsave
240 value=2147483648.0*2:text$=STR$(value):PROCsave
260 value=(2147483648.0*2)+3:text$=STR$(value):PROCsave
280 value=1/10:text$=STR$(value):PROCsave
300 value=-1/10:text$=STR$(value):PROCsave
320 value=1/3:text$=STR$(value):PROCsave
340 value=-1/3:text$=STR$(value):PROCsave
360 value=1E38:text$=STR$(value):PROCsave
380 value=-1E38:text$=STR$(value):PROCsave
400 value=1E-38:text$=STR$(value):PROCsave
420 value=-1E-38:text$=STR$(value):PROCsave
440 value=9.99999999:text$=STR$(value):PROCsave
460 value=999999999:text$=STR$(value):PROCsave
480 value=9999999999:text$=STR$(value):PROCsave
500 value=0.000000001:text$=STR$(value):PROCsave
520 value=0.0000000001:text$=STR$(value):PROCsave
540 value=0.9999999999:text$=STR$(value):PROCsave
560 value=PI:text$=STR$(value):PROCsave
580 value=SQR(2):text$=STR$(value):PROCsave
600 value=10^(-38):text$=STR$(value):PROCsave
620 value=10^(-33):text$=STR$(value):PROCsave
640 value=10^(-28):text$=STR$(value):PROCsave
660 value=10^(-23):text$=STR$(value):PROCsave
680 value=10^(-18):text$=STR$(value):PROCsave
700 value=10^(-13):text$=STR$(value):PROCsave
720 value=10^(-8):text$=STR$(value):PROCsave
740 value=10^(-3):text$=STR$(value):PROCsave
760 value=10^(2):text$=STR$(value):PROCsave
780 value=10^(7):text$=STR$(value):PROCsave
800 value=10^(12):text$=STR$(value):PROCsave
820 value=10^(17):text$=STR$(value):PROCsave
840 value=10^(22):text$=STR$(value):PROCsave
860 value=10^(27):text$=STR$(value):PROCsave
880 value=10^(32):text$=STR$(value):PROCsave
900 value=10^(37):text$=STR$(value):PROCsave
920 value=0:p%=^value:p%?4=1:text$=STR$(value):PROCsave
940 value=0:p%=^value:p%?3=128:p%?4=1:text$=STR$(value):PROCsave
960 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=255:text$=STR$(value):PROCsave
980 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=255:p%?4=255:text$=STR$(value):PROCsave
10000 CLOSE#ch%:PRINT "FORMAT_REFERENCE_DONE":OSCLI "BYE"
11000 DEF PROCsave:LOCAL i%,p%
11010 p%=^value:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
11020 IF LEN(text$)>31 ERROR 100,"Format too long"
11030 BPUT#ch%,LEN(text$):FOR i%=1 TO 32
11040 IF i%<=LEN(text$) THEN BPUT#ch%,ASC(MID$(text$,i%,1)) ELSE BPUT#ch%,0
11050 NEXT:ENDPROC
