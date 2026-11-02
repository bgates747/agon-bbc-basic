10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 @%=&90A:ch%=OPENOUT("literal.dat")
30 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
40 readertext$="1.00000000023283064365386962890625"
50 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
60 PRINT "LITERAL_0:";value
70 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
80 readertext$="1.00000000023283064365386962890624"
90 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
100 PRINT "LITERAL_1:";value
110 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
120 readertext$="1.00000000023283064365386962890626"
130 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
140 PRINT "LITERAL_2:";value
150 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
160 readertext$="1.00000000069849193096160888671875"
170 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
180 PRINT "LITERAL_3:";value
190 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
200 readertext$="4294967295.50000000000000000000000000000000000000000000000000000000000"
210 readertext$=readertext$+"00000000000000000000001"
220 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
230 PRINT "LITERAL_4:";value
240 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
250 readertext$="4294967295.49999999999999999999999999999999999999999999999999999999999"
260 readertext$=readertext$+"9999999999999999999999"
270 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
280 PRINT "LITERAL_5:";value
290 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
300 readertext$="000.000E+999"
310 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
320 PRINT "LITERAL_6:";value
330 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
340 readertext$="1.E-0"
350 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
360 PRINT "LITERAL_7:";value
370 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
380 readertext$="0001.0000E-000"
390 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
400 PRINT "LITERAL_8:";value
410 value=PI:PROCsave(value)
420 readertext$="3.1415926535897932384626433832795028841971693993751"
430 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
440 PRINT "LITERAL_9:";value
450 value=1/3:PROCsave(value)
460 readertext$="0.33333333333333333333333333333333333333333333"
470 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
480 PRINT "LITERAL_10:";value
490 value=1/7:PROCsave(value)
500 readertext$="0.14285714285714285714285714285714285714285714"
510 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
520 PRINT "LITERAL_11:";value
530 CLOSE#ch%:PRINT "LITERAL_REFERENCE_DONE":OSCLI "BYE"
10000 DEF PROCsave(v):LOCAL p%,i%:p%=^v
10010 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT:ENDPROC
10100 DEF PROCreader(s$):LOCAL ERROR
10110 reader=0:reader%=0:ON ERROR LOCAL reader%=ERR:ENDPROC
10120 reader=VAL(s$):ENDPROC
