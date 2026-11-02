10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 @%=&90A:ch%=OPENOUT("literal.dat")
30 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
40 readertext$="0"
50 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
60 PRINT "LITERAL_0:";value
70 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
80 readertext$="1"
90 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
100 PRINT "LITERAL_1:";value
110 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
120 readertext$="1.0"
130 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
140 PRINT "LITERAL_2:";value
150 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=127:PROCsave(value)
160 readertext$=".5"
170 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
180 PRINT "LITERAL_3:";value
190 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
200 readertext$="1."
210 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
220 PRINT "LITERAL_4:";value
230 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
240 readertext$="1E0"
250 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
260 PRINT "LITERAL_5:";value
270 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
280 readertext$="1.E0"
290 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
300 PRINT "LITERAL_6:";value
310 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
320 readertext$=".0"
330 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
340 PRINT "LITERAL_7:";value
350 value=0:p%=^value:p%?0=205:p%?1=204:p%?2=204:p%?3=76:p%?4=124:PROCsave(value)
360 readertext$="0.1"
370 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
380 PRINT "LITERAL_8:";value
390 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=128:PROCsave(value)
400 readertext$="1.5"
410 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
420 PRINT "LITERAL_9:";value
430 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=0:PROCsave(value)
440 readertext$="2147483647"
450 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
460 PRINT "LITERAL_10:";value
470 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=159:PROCsave(value)
480 readertext$="2147483648"
490 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
500 PRINT "LITERAL_11:";value
510 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
520 readertext$="4294967295"
530 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
540 PRINT "LITERAL_12:";value
550 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
560 readertext$="4294967296"
570 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
580 PRINT "LITERAL_13:";value
590 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
600 readertext$="4294967297"
610 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
620 PRINT "LITERAL_14:";value
630 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
640 readertext$="4294967298"
650 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
660 PRINT "LITERAL_15:";value
670 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
680 readertext$="4294967299"
690 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
700 PRINT "LITERAL_16:";value
710 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
720 readertext$="4294967300"
730 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
740 PRINT "LITERAL_17:";value
750 value=0:p%=^value:p%?0=3:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
760 readertext$="4294967301"
770 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
780 PRINT "LITERAL_18:";value
790 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
800 readertext$="4294967295.5"
810 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
820 PRINT "LITERAL_19:";value
830 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
840 readertext$="4294967295.75"
850 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
860 PRINT "LITERAL_20:";value
870 value=0:p%=^value:p%?0=128:p%?1=0:p%?2=0:p%?3=0:p%?4=152:PROCsave(value)
880 readertext$="16777217.0"
890 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
900 PRINT "LITERAL_21:";value
910 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=1:PROCsave(value)
920 readertext$="5.87747175411143754E-39"
930 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
940 PRINT "LITERAL_22:";value
950 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
960 readertext$="5.87747175411143753E-39"
970 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
980 PRINT "LITERAL_23:";value
990 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=255:PROCsave(value)
1000 readertext$="340282366841710300949110269838224261120"
1010 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1020 PRINT "LITERAL_24:";value
1030 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=255:PROCsave(value)
1040 readertext$="340282366881324382206242438634996236288"
1050 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1060 PRINT "LITERAL_25:";value
1070 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
1080 readertext$="0E999"
1090 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1100 PRINT "LITERAL_26:";value
1110 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
1120 readertext$="1E-999"
1130 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1140 PRINT "LITERAL_27:";value
1150 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
1160 readertext$="0.00000000000000000000000000000000000000001"
1170 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1180 PRINT "LITERAL_28:";value
1190 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=122:p%?4=137:PROCsave(value)
1200 readertext$="1e+3"
1210 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1220 PRINT "LITERAL_29:";value
1230 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
1240 readertext$="1E-0"
1250 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1260 PRINT "LITERAL_30:";value
1270 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
1280 readertext$="000000000000000000000000000000000000000001"
1290 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1300 PRINT "LITERAL_31:";value
1310 value=1/4:PROCsave(value)
1320 readertext$=".25"
1330 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1340 PRINT "LITERAL_32:";value
1350 value=1/8:PROCsave(value)
1360 readertext$=".125"
1370 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1380 PRINT "LITERAL_33:";value
1390 value=51/4:PROCsave(value)
1400 readertext$="12.75"
1410 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1420 PRINT "LITERAL_34:";value
1430 value=1/100:PROCsave(value)
1440 readertext$=".01"
1450 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1460 PRINT "LITERAL_35:";value
1470 value=1/1000:PROCsave(value)
1480 readertext$=".001"
1490 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1500 PRINT "LITERAL_36:";value
1510 value=1001/1000:PROCsave(value)
1520 readertext$="1.001"
1530 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1540 PRINT "LITERAL_37:";value
1550 value=123456789/1000000:PROCsave(value)
1560 readertext$="123.456789"
1570 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1580 PRINT "LITERAL_38:";value
1590 value=123456789/1000:PROCsave(value)
1600 readertext$="123456.789"
1610 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1620 PRINT "LITERAL_39:";value
1630 value=1000/1:PROCsave(value)
1640 readertext$="1E3"
1650 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1660 PRINT "LITERAL_40:";value
1670 value=1000/1:PROCsave(value)
1680 readertext$="1.E+3"
1690 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1700 PRINT "LITERAL_41:";value
1710 value=1/1000:PROCsave(value)
1720 readertext$="1e-3"
1730 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1740 PRINT "LITERAL_42:";value
1750 value=5/1:PROCsave(value)
1760 readertext$=".5E+1"
1770 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1780 PRINT "LITERAL_43:";value
1790 value=1/2:PROCsave(value)
1800 readertext$="500E-3"
1810 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1820 PRINT "LITERAL_44:";value
1830 value=1/1:PROCsave(value)
1840 readertext$="1.0E0"
1850 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1860 PRINT "LITERAL_45:";value
1870 value=123/1:PROCsave(value)
1880 readertext$="000123.000"
1890 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1900 PRINT "LITERAL_46:";value
1910 value=1000/1:PROCsave(value)
1920 readertext$="1E000003"
1930 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1940 PRINT "LITERAL_47:";value
1950 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=0:PROCsave(value)
1960 readertext$="0000000000000000000000000000000000000000000000000000000000000000000000"
1970 readertext$=readertext$+"0000000000000000000000000000000000000000000000000000000000000000000000"
1980 readertext$=readertext$+"0000000000000000000000000000000000000000000000000000000000000000000000"
1990 readertext$=readertext$+"000000000000000000001"
2000 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2010 PRINT "LITERAL_48:";value
2020 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
2030 readertext$="1000000000000000000000000000000000000000000000000000000000000000000000"
2040 readertext$=readertext$+"0000000000000000000000000000000000000000000000000000000000000000000000"
2050 readertext$=readertext$+"0000000000000000000000000000000000000000000000000000000000000000000000"
2060 readertext$=readertext$+"000000000000000000000000000000E-239"
2070 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2080 PRINT "LITERAL_49:";value
2090 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
2100 readertext$="0.00000000000000000000000000000000000000000000000000000000000000000000"
2110 readertext$=readertext$+"0000000000000000000000000000000000000000000000000000000000000000000000"
2120 readertext$=readertext$+"000000000000000000000000000000000000000000000000000000000000001E+201"
2130 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2140 PRINT "LITERAL_50:";value
2150 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=128:PROCsave(value)
2160 readertext$="1500000000000000000000000000000000000000000000000000000000000000000000"
2170 readertext$=readertext$+"0000000000000000000000000000000000000000000000000000000000000000000000"
2180 readertext$=readertext$+"0000000000000000000000000000000000000000000000000000000000000000000000"
2190 readertext$=readertext$+"0000000000000000000000.0E-231"
2200 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2210 PRINT "LITERAL_51:";value
2220 CLOSE#ch%:PRINT "LITERAL_REFERENCE_DONE":OSCLI "BYE"
10000 DEF PROCsave(v):LOCAL p%,i%:p%=^v
10010 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT:ENDPROC
10100 DEF PROCreader(s$):LOCAL ERROR
10110 reader=0:reader%=0:ON ERROR LOCAL reader%=ERR:ENDPROC
10120 reader=VAL(s$):ENDPROC
