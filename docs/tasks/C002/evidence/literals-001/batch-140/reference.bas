10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 @%=&90A:ch%=OPENOUT("literal.dat")
30 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=1:PROCsave(value)
40 readertext$="1175494350411750848498575285975059276464197940186073280724616226271463"
50 readertext$=readertext$+"6606588899415959392769082114682532846927642822265625.0E-159"
60 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
70 PRINT "LITERAL_0:";value
80 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=2:PROCsave(value)
90 readertext$="2350988700823501696997150571950118552928395880372146561449232452542927"
100 readertext$=readertext$+"321317779883191878553816422936506569385528564453125.0E-158"
110 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
120 PRINT "LITERAL_1:";value
130 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=28:PROCsave(value)
140 readertext$="1577721809891010633875509861205227207523485208740546529803641835620897"
150 readertext$=readertext$+"637681991909630596637725830078125.0E-132"
160 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
170 PRINT "LITERAL_2:";value
180 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=127:PROCsave(value)
190 readertext$="999999999650754034519195556640625.0E-33"
200 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
210 PRINT "LITERAL_3:";value
220 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=128:PROCsave(value)
230 readertext$="199999999930150806903839111328125.0E-32"
240 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
250 PRINT "LITERAL_4:";value
260 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=129:PROCsave(value)
270 readertext$="39999999986030161380767822265625.0E-31"
280 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
290 PRINT "LITERAL_5:";value
300 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=158:PROCsave(value)
310 readertext$="214748364725.0E-2"
320 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
330 PRINT "LITERAL_6:";value
340 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
350 readertext$="42949672945.0E-1"
360 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
370 PRINT "LITERAL_7:";value
380 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=160:PROCsave(value)
390 readertext$="8589934589.0"
400 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
410 PRINT "LITERAL_8:";value
420 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=228:PROCsave(value)
430 readertext$="2535301199571015087455347933184.0"
440 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
450 PRINT "LITERAL_9:";value
460 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=255:PROCsave(value)
470 readertext$="340282366802096219691978101041452285952.0"
480 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
490 PRINT "LITERAL_10:";value
500 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=1:PROCsave(value)
510 readertext$="1175494350685441954812016120139850210700509684576749441247373212942766"
520 readertext$=readertext$+"0598561147624330214256360704894177615642547607421875.0E-159"
530 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
540 PRINT "LITERAL_11:";value
550 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=2:PROCsave(value)
560 readertext$="2350988701370883909624032240279700421401019369153498882494746425885532"
570 readertext$=readertext$+"119712229524866042851272140978835523128509521484375.0E-158"
580 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
590 PRINT "LITERAL_12:";value
600 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=28:PROCsave(value)
610 readertext$="1577721810258352618507474707445457375405436983058879516294919186092382"
620 readertext$=readertext$+"545893997303210198879241943359375.0E-132"
630 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
640 PRINT "LITERAL_13:";value
650 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=127:PROCsave(value)
660 readertext$="999999999883584678173065185546875.0E-33"
670 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
680 PRINT "LITERAL_14:";value
690 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=128:PROCsave(value)
700 readertext$="199999999976716935634613037109375.0E-32"
710 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
720 PRINT "LITERAL_15:";value
730 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=129:PROCsave(value)
740 readertext$="39999999995343387126922607421875.0E-31"
750 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
760 PRINT "LITERAL_16:";value
770 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=158:PROCsave(value)
780 readertext$="214748364775.0E-2"
790 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
800 PRINT "LITERAL_17:";value
810 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
820 readertext$="42949672955.0E-1"
830 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
840 PRINT "LITERAL_18:";value
850 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=160:PROCsave(value)
860 readertext$="8589934591.0"
870 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
880 PRINT "LITERAL_19:";value
890 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=228:PROCsave(value)
900 readertext$="2535301200161310897814053584896.0"
910 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
920 PRINT "LITERAL_20:";value
930 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=255:PROCsave(value)
940 readertext$="340282366881324382206242438634996236288.0"
950 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
960 PRINT "LITERAL_21:";value
970 CLOSE#ch%:PRINT "LITERAL_REFERENCE_DONE":OSCLI "BYE"
10000 DEF PROCsave(v):LOCAL p%,i%:p%=^v
10010 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT:ENDPROC
10100 DEF PROCreader(s$):LOCAL ERROR
10110 reader=0:reader%=0:ON ERROR LOCAL reader%=ERR:ENDPROC
10120 reader=VAL(s$):ENDPROC
