10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 @%=&90A:ch%=OPENOUT("literal.dat")
30 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=1:PROCsave(value)
40 readertext$="5877471754111437539843682686111228389093327783860437607543758531392086"
50 readertext$=readertext$+"29727363586425781250000000000000000000000000000000.0E-158"
60 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
70 PRINT "LITERAL_0:";value
80 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=2:PROCsave(value)
90 readertext$="1175494350822287507968736537222245677818665556772087521508751706278417"
100 readertext$=readertext$+"25945472717285156250000000000000000000000000000000.0E-157"
110 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
120 PRINT "LITERAL_1:";value
130 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=28:PROCsave(value)
140 readertext$="7888609052210118054117285652827862296732064351090230047702789306640625"
150 readertext$=readertext$+"0000000000000000000000000000000.0E-131"
160 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
170 PRINT "LITERAL_2:";value
180 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=127:PROCsave(value)
190 readertext$="50000000000000000000000000000000.0E-32"
200 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
210 PRINT "LITERAL_3:";value
220 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
230 readertext$="10000000000000000000000000000000.0E-31"
240 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
250 PRINT "LITERAL_4:";value
260 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=129:PROCsave(value)
270 readertext$="2000000000000000000000000000000.0E-30"
280 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
290 PRINT "LITERAL_5:";value
300 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=158:PROCsave(value)
310 readertext$="10737418240.0E-1"
320 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
330 PRINT "LITERAL_6:";value
340 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=159:PROCsave(value)
350 readertext$="2147483648.0"
360 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
370 PRINT "LITERAL_7:";value
380 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
390 readertext$="4294967296.0"
400 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
410 PRINT "LITERAL_8:";value
420 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=228:PROCsave(value)
430 readertext$="1267650600228229401496703205376.0"
440 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
450 PRINT "LITERAL_9:";value
460 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=0:p%?4=255:PROCsave(value)
470 readertext$="170141183460469231731687303715884105728.0"
480 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
490 PRINT "LITERAL_10:";value
500 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=1:PROCsave(value)
510 readertext$="5877471756848348602978091027759137731456445227767199212771328398105110"
520 readertext$=readertext$+"28924588407262863398727859021164476871490478515625.0E-158"
530 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
540 PRINT "LITERAL_11:";value
550 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=2:PROCsave(value)
560 readertext$="1175494351369669720595618205551827546291289045553439842554265679621022"
570 readertext$=readertext$+"05784917681452572679745571804232895374298095703125.0E-157"
580 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
590 PRINT "LITERAL_12:";value
600 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=28:PROCsave(value)
610 readertext$="7888609055883537900436934115230163975551582094273559912615562811355474"
620 readertext$=readertext$+"0821200539357960224151611328125.0E-131"
630 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
640 PRINT "LITERAL_13:";value
650 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=127:PROCsave(value)
660 readertext$="50000000023283064365386962890625.0E-32"
670 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
680 PRINT "LITERAL_14:";value
690 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
700 readertext$="10000000004656612873077392578125.0E-31"
710 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
720 PRINT "LITERAL_15:";value
730 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=129:PROCsave(value)
740 readertext$="2000000000931322574615478515625.0E-30"
750 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
760 PRINT "LITERAL_16:";value
770 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=158:PROCsave(value)
780 readertext$="10737418245.0E-1"
790 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
800 PRINT "LITERAL_17:";value
810 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=159:PROCsave(value)
820 readertext$="2147483649.0"
830 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
840 PRINT "LITERAL_18:";value
850 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
860 readertext$="4294967298.0"
870 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
880 PRINT "LITERAL_19:";value
890 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=228:PROCsave(value)
900 readertext$="1267650600818525211855408857088.0"
910 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
920 PRINT "LITERAL_20:";value
930 value=0:p%=^value:p%?0=1:p%?1=0:p%?2=0:p%?3=0:p%?4=255:PROCsave(value)
940 readertext$="170141183539697394245951641309428056064.0"
950 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
960 PRINT "LITERAL_21:";value
970 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=1:PROCsave(value)
980 readertext$="5877471759585259666112499369407047073819562671673960817998898264818134"
990 readertext$=readertext$+"28121813228099945547455718042328953742980957031250.0E-158"
1000 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1010 PRINT "LITERAL_22:";value
1020 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=2:PROCsave(value)
1030 readertext$="1175494351917051933222499873881409414763912534334792163599779652963626"
1040 readertext$=readertext$+"85624362645619989109491143608465790748596191406250.0E-157"
1050 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1060 PRINT "LITERAL_23:";value
1070 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=28:PROCsave(value)
1080 readertext$="7888609059556957746756582577632465654371099837456889777528336316070323"
1090 readertext$=readertext$+"1642401078715920448303222656250.0E-131"
1100 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1110 PRINT "LITERAL_24:";value
1120 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=127:PROCsave(value)
1130 readertext$="50000000046566128730773925781250.0E-32"
1140 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1150 PRINT "LITERAL_25:";value
1160 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=128:PROCsave(value)
1170 readertext$="10000000009313225746154785156250.0E-31"
1180 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1190 PRINT "LITERAL_26:";value
1200 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=129:PROCsave(value)
1210 readertext$="2000000001862645149230957031250.0E-30"
1220 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1230 PRINT "LITERAL_27:";value
1240 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=158:PROCsave(value)
1250 readertext$="10737418250.0E-1"
1260 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1270 PRINT "LITERAL_28:";value
1280 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=159:PROCsave(value)
1290 readertext$="2147483650.0"
1300 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1310 PRINT "LITERAL_29:";value
1320 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=160:PROCsave(value)
1330 readertext$="4294967300.0"
1340 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1350 PRINT "LITERAL_30:";value
1360 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=228:PROCsave(value)
1370 readertext$="1267650601408821022214114508800.0"
1380 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1390 PRINT "LITERAL_31:";value
1400 value=0:p%=^value:p%?0=2:p%?1=0:p%?2=0:p%?3=0:p%?4=255:PROCsave(value)
1410 readertext$="170141183618925556760215978902972006400.0"
1420 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1430 PRINT "LITERAL_32:";value
1440 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=1:PROCsave(value)
1450 readertext$="8816207631167156309765524029166842583639991675790656411315637797088129"
1460 readertext$=readertext$+"44591045379638671875000000000000000000000000000000.0E-158"
1470 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1480 PRINT "LITERAL_33:";value
1490 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=2:PROCsave(value)
1500 readertext$="1763241526233431261953104805833368516727998335158131282263127559417625"
1510 readertext$=readertext$+"88918209075927734375000000000000000000000000000000.0E-157"
1520 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1530 PRINT "LITERAL_34:";value
1540 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=28:PROCsave(value)
1550 readertext$="1183291357831517708117592847924179344509809652663534507155418395996093"
1560 readertext$=readertext$+"75000000000000000000000000000000.0E-131"
1570 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1580 PRINT "LITERAL_35:";value
1590 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=127:PROCsave(value)
1600 readertext$="75000000000000000000000000000000.0E-32"
1610 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1620 PRINT "LITERAL_36:";value
1630 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=128:PROCsave(value)
1640 readertext$="15000000000000000000000000000000.0E-31"
1650 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1660 PRINT "LITERAL_37:";value
1670 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=129:PROCsave(value)
1680 readertext$="3000000000000000000000000000000.0E-30"
1690 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1700 PRINT "LITERAL_38:";value
1710 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=158:PROCsave(value)
1720 readertext$="16106127360.0E-1"
1730 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1740 PRINT "LITERAL_39:";value
1750 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=159:PROCsave(value)
1760 readertext$="3221225472.0"
1770 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1780 PRINT "LITERAL_40:";value
1790 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=160:PROCsave(value)
1800 readertext$="6442450944.0"
1810 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1820 PRINT "LITERAL_41:";value
1830 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=228:PROCsave(value)
1840 readertext$="1901475900342344102245054808064.0"
1850 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1860 PRINT "LITERAL_42:";value
1870 value=0:p%=^value:p%?0=0:p%?1=0:p%?2=0:p%?3=64:p%?4=255:PROCsave(value)
1880 readertext$="255211775190703847597530955573826158592.0"
1890 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1900 PRINT "LITERAL_43:";value
1910 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=1:PROCsave(value)
1920 readertext$="1175494350274905295341854868892663809346042067990735200463237732935812"
1930 readertext$=readertext$+"461060277531177398202544281957671046257019042968750.0E-158"
1940 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
1950 PRINT "LITERAL_44:";value
1960 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=2:PROCsave(value)
1970 readertext$="2350988700549810590683709737785327618692084135981470400926475465871624"
1980 readertext$=readertext$+"92212055506235479640508856391534209251403808593750.0E-157"
1990 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2000 PRINT "LITERAL_45:";value
2010 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=28:PROCsave(value)
2020 readertext$="1577721809707339641559527438085112123582509321581380036558003160385155"
2030 readertext$=readertext$+"18357598921284079551696777343750.0E-131"
2040 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2050 PRINT "LITERAL_46:";value
2060 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=127:PROCsave(value)
2070 readertext$="99999999953433871269226074218750.0E-32"
2080 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2090 PRINT "LITERAL_47:";value
2100 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=128:PROCsave(value)
2110 readertext$="19999999990686774253845214843750.0E-31"
2120 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2130 PRINT "LITERAL_48:";value
2140 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=129:PROCsave(value)
2150 readertext$="3999999998137354850769042968750.0E-30"
2160 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2170 PRINT "LITERAL_49:";value
2180 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=158:PROCsave(value)
2190 readertext$="21474836470.0E-1"
2200 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2210 PRINT "LITERAL_50:";value
2220 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
2230 readertext$="4294967294.0"
2240 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2250 PRINT "LITERAL_51:";value
2260 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=160:PROCsave(value)
2270 readertext$="8589934588.0"
2280 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2290 PRINT "LITERAL_52:";value
2300 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=228:PROCsave(value)
2310 readertext$="2535301199275867182275995107328.0"
2320 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2330 PRINT "LITERAL_53:";value
2340 value=0:p%=^value:p%?0=254:p%?1=255:p%?2=255:p%?3=127:p%?4=255:PROCsave(value)
2350 readertext$="340282366762482138434845932244680310784.0"
2360 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2370 PRINT "LITERAL_54:";value
2380 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=1:PROCsave(value)
2390 readertext$="1175494350548596401655295703057454743582353812381411360985994719607114"
2400 readertext$=readertext$+"860257502352014480351272140978835523128509521484375.0E-158"
2410 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2420 PRINT "LITERAL_55:";value
2430 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=2:PROCsave(value)
2440 readertext$="2350988701097192803310591406114909487164707624762822721971989439214229"
2450 readertext$=readertext$+"72051500470402896070254428195767104625701904296875.0E-157"
2460 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2470 PRINT "LITERAL_56:";value
2480 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=28:PROCsave(value)
2490 readertext$="1577721810074681626191492284325342291464461095899713023049280510856640"
2500 readertext$=readertext$+"09178799460642039775848388671875.0E-131"
2510 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2520 PRINT "LITERAL_57:";value
2530 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=127:PROCsave(value)
2540 readertext$="99999999976716935634613037109375.0E-32"
2550 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2560 PRINT "LITERAL_58:";value
2570 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=128:PROCsave(value)
2580 readertext$="19999999995343387126922607421875.0E-31"
2590 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2600 PRINT "LITERAL_59:";value
2610 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=129:PROCsave(value)
2620 readertext$="3999999999068677425384521484375.0E-30"
2630 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2640 PRINT "LITERAL_60:";value
2650 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=158:PROCsave(value)
2660 readertext$="21474836475.0E-1"
2670 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2680 PRINT "LITERAL_61:";value
2690 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=159:PROCsave(value)
2700 readertext$="4294967295.0"
2710 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2720 PRINT "LITERAL_62:";value
2730 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=160:PROCsave(value)
2740 readertext$="8589934590.0"
2750 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2760 PRINT "LITERAL_63:";value
2770 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=228:PROCsave(value)
2780 readertext$="2535301199866162992634700759040.0"
2790 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2800 PRINT "LITERAL_64:";value
2810 value=0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=255:PROCsave(value)
2820 readertext$="340282366841710300949110269838224261120.0"
2830 PROCreader(readertext$):PROCsave(reader):BPUT#ch%,reader%
2840 PRINT "LITERAL_65:";value
2850 CLOSE#ch%:PRINT "LITERAL_REFERENCE_DONE":OSCLI "BYE"
10000 DEF PROCsave(v):LOCAL p%,i%:p%=^v
10010 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT:ENDPROC
10100 DEF PROCreader(s$):LOCAL ERROR
10110 reader=0:reader%=0:ON ERROR LOCAL reader%=ERR:ENDPROC
10120 reader=VAL(s$):ENDPROC
