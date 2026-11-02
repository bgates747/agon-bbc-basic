10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 @%=&90A:ch%=OPENOUT("literal.dat")
30 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=1:PROCsave(value)
40 readertext$="5877471755479893071410886856935183060274886505813818410157543464748598"
50 readertext$=readertext$+"293259759968443223243639295105822384357452392578125.0E-159"
60 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
70 PRINT "LITERAL_0:";value
80 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=2:PROCsave(value)
90 readertext$="1175494351095978614282177371387036612054977301162763682031508692949719"
100 readertext$=readertext$+"658651951993688644648727859021164476871490478515625.0E-158"
110 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
120 PRINT "LITERAL_1:";value
130 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=28:PROCsave(value)
140 readertext$="7888609054046827977277109884029013136141823222681894980159176058998049"
150 readertext$=readertext$+"54106002696789801120758056640625.0E-132"
160 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
170 PRINT "LITERAL_2:";value
180 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=127:PROCsave(value)
190 readertext$="500000000116415321826934814453125.0E-33"
200 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
210 PRINT "LITERAL_3:";value
220 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
230 readertext$="100000000023283064365386962890625.0E-32"
240 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
250 PRINT "LITERAL_4:";value
260 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=129:PROCsave(value)
270 readertext$="20000000004656612873077392578125.0E-31"
280 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
290 PRINT "LITERAL_5:";value
300 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=158:PROCsave(value)
310 readertext$="107374182425.0E-2"
320 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
330 PRINT "LITERAL_6:";value
340 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=159:PROCsave(value)
350 readertext$="21474836485.0E-1"
360 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
370 PRINT "LITERAL_7:";value
380 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
390 readertext$="4294967297.0"
400 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
410 PRINT "LITERAL_8:";value
420 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=228:PROCsave(value)
430 readertext$="1267650600523377306676056031232.0"
440 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
450 PRINT "LITERAL_9:";value
460 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=255:PROCsave(value)
470 readertext$="170141183500083312988819472512656080896.0"
480 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
490 PRINT "LITERAL_10:";value
500 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=1:PROCsave(value)
510 readertext$="5877471758216804134545295198583092402638003949720580015385113331461622"
520 readertext$=readertext$+"285232008176814044730917885317467153072357177734375.0E-159"
530 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
540 PRINT "LITERAL_11:";value
550 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=2:PROCsave(value)
560 readertext$="1175494351643360826909059039716618480527600789944116003077022666292324"
570 readertext$=readertext$+"457046401635362808946183577063493430614471435546875.0E-158"
580 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
590 PRINT "LITERAL_12:";value
600 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=28:PROCsave(value)
610 readertext$="7888609057720247823596758346431314814961340965865224845071949563712898"
620 readertext$=readertext$+"62318008090369403362274169921875.0E-132"
630 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
640 PRINT "LITERAL_13:";value
650 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=127:PROCsave(value)
660 readertext$="500000000349245965480804443359375.0E-33"
670 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
680 PRINT "LITERAL_14:";value
690 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
700 readertext$="100000000069849193096160888671875.0E-32"
710 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
720 PRINT "LITERAL_15:";value
730 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=129:PROCsave(value)
740 readertext$="20000000013969838619232177734375.0E-31"
750 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
760 PRINT "LITERAL_16:";value
770 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=158:PROCsave(value)
780 readertext$="107374182475.0E-2"
790 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
800 PRINT "LITERAL_17:";value
810 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=159:PROCsave(value)
820 readertext$="21474836495.0E-1"
830 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
840 PRINT "LITERAL_18:";value
850 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
860 readertext$="4294967299.0"
870 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
880 PRINT "LITERAL_19:";value
890 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=228:PROCsave(value)
900 readertext$="1267650601113673117034761682944.0"
910 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
920 PRINT "LITERAL_20:";value
930 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=255:PROCsave(value)
940 readertext$="170141183579311475503083810106200031232.0"
950 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
960 PRINT "LITERAL_21:";value
970 CLOSE#ch%:PRINT "LITERAL_REFERENCE_DONE":OSCLI "BYE"
10000 DEF PROCsave(v):LOCAL p%,i%:p%=^v
10010 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT:ENDPROC
10100 DEF PROCreader(s$):LOCAL ERROR
10110 reader=0:reader%=0:ON ERROR LOCAL reader%=ERR:ENDPROC
10120 reader=VAL(s$):ENDPROC
