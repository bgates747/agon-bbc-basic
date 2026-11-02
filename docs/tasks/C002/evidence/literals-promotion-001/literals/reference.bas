10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 @%=&90A:ch%=OPENOUT("literal.dat")
30 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
40 readertext$="4294967295"
50 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
60 PRINT "LITERAL_0:";value
70 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
80 readertext$="4294967296"
90 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
100 PRINT "LITERAL_1:";value
110 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
120 readertext$="4294967297"
130 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
140 PRINT "LITERAL_2:";value
150 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
160 readertext$="4294967298"
170 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
180 PRINT "LITERAL_3:";value
190 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
200 readertext$="4294967299"
210 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
220 PRINT "LITERAL_4:";value
230 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
240 readertext$="4294967300"
250 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
260 PRINT "LITERAL_5:";value
270 value=0:p%=^value:p%?0=3:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
280 readertext$="4294967301"
290 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
300 PRINT "LITERAL_6:";value
310 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
320 readertext$="4294967295.5"
330 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
340 PRINT "LITERAL_7:";value
350 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
360 readertext$="4294967295.75"
370 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
380 PRINT "LITERAL_8:";value
390 value=0:p%=^value:p%?0=128:p%?1=0:p%?2=0:p%?3=0:p%?4=152:PROCsave(value)
400 readertext$="16777217.0"
410 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
420 PRINT "LITERAL_9:";value
430 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=1:PROCsave(value)
440 readertext$="5.87747175411143754E-39"
450 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
460 PRINT "LITERAL_10:";value
470 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
480 readertext$="5.87747175411143753E-39"
490 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
500 PRINT "LITERAL_11:";value
510 CLOSE#ch%:PRINT "LITERAL_REFERENCE_DONE":OSCLI "BYE"
10000 DEF PROCsave(v):LOCAL p%,i%:p%=^v
10010 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT:ENDPROC
10100 DEF PROCreader(s$):LOCAL ERROR
10110 reader=0:reader%=0:ON ERROR LOCAL reader%=ERR:ENDPROC
10120 reader=VAL(s$):ENDPROC
