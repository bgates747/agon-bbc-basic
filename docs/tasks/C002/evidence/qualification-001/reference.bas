10 ON ERROR PRINT "REFERENCE_SETUP_ERROR ";ERR:REPORT:PRINT:CLOSE#0:OSCLI "BYE"
20 ch%=OPENOUT("cases.dat")
30 IF ch%=0 ERROR 100,"Cannot create cases"
100 left=0:right=0
110 opcode%=0:alias%=0
120 PROCinputs
130 status%=0
140 ON ERROR status%=ERR:PROCfinish:GOTO 180
150 result=left AND right
160 PROCfinish
170 REM case 0 complete
180 left=1:right=1
190 opcode%=0:alias%=0
200 PROCinputs
210 status%=0
220 ON ERROR status%=ERR:PROCfinish:GOTO 260
230 result=left AND right
240 PROCfinish
250 REM case 1 complete
260 left=-7:right=3
270 opcode%=0:alias%=0
280 PROCinputs
290 status%=0
300 ON ERROR status%=ERR:PROCfinish:GOTO 340
310 result=left AND right
320 PROCfinish
330 REM case 2 complete
340 left=7:right=-3
350 opcode%=0:alias%=0
360 PROCinputs
370 status%=0
380 ON ERROR status%=ERR:PROCfinish:GOTO 420
390 result=left AND right
400 PROCfinish
410 REM case 3 complete
420 left=&7FFFFFFF:right=1
430 opcode%=0:alias%=0
440 PROCinputs
450 status%=0
460 ON ERROR status%=ERR:PROCfinish:GOTO 500
470 result=left AND right
480 PROCfinish
490 REM case 4 complete
500 left=&80000000:right=-1
510 opcode%=0:alias%=0
520 PROCinputs
530 status%=0
540 ON ERROR status%=ERR:PROCfinish:GOTO 580
550 result=left AND right
560 PROCfinish
570 REM case 5 complete
580 left=&00FFFFFF:right=1
590 opcode%=0:alias%=0
600 PROCinputs
610 status%=0
620 ON ERROR status%=ERR:PROCfinish:GOTO 660
630 result=left AND right
640 PROCfinish
650 REM case 6 complete
660 left=65536:right=65536
670 opcode%=0:alias%=0
680 PROCinputs
690 status%=0
700 ON ERROR status%=ERR:PROCfinish:GOTO 740
710 result=left AND right
720 PROCfinish
730 REM case 7 complete
740 left=0.5:right=0.25
750 opcode%=0:alias%=0
760 PROCinputs
770 status%=0
780 ON ERROR status%=ERR:PROCfinish:GOTO 820
790 result=left AND right
800 PROCfinish
810 REM case 8 complete
820 left=1.5:right=2
830 opcode%=0:alias%=0
840 PROCinputs
850 status%=0
860 ON ERROR status%=ERR:PROCfinish:GOTO 900
870 result=left AND right
880 PROCfinish
890 REM case 9 complete
900 left=0.1:right=0.2
910 opcode%=0:alias%=0
920 PROCinputs
930 status%=0
940 ON ERROR status%=ERR:PROCfinish:GOTO 980
950 result=left AND right
960 PROCfinish
970 REM case 10 complete
980 left=1E38:right=10
990 opcode%=0:alias%=0
1000 PROCinputs
1010 status%=0
1020 ON ERROR status%=ERR:PROCfinish:GOTO 1060
1030 result=left AND right
1040 PROCfinish
1050 REM case 11 complete
1060 left=1E-38:right=100
1070 opcode%=0:alias%=0
1080 PROCinputs
1090 status%=0
1100 ON ERROR status%=ERR:PROCfinish:GOTO 1140
1110 result=left AND right
1120 PROCfinish
1130 REM case 12 complete
1140 left=-0.5:right=0.25
1150 opcode%=0:alias%=0
1160 PROCinputs
1170 status%=0
1180 ON ERROR status%=ERR:PROCfinish:GOTO 1220
1190 result=left AND right
1200 PROCfinish
1210 REM case 13 complete
1220 left=0:right=0
1230 opcode%=1:alias%=0
1240 PROCinputs
1250 status%=0
1260 ON ERROR status%=ERR:PROCfinish:GOTO 1300
1270 result=left DIV right
1280 PROCfinish
1290 REM case 14 complete
1300 left=1:right=1
1310 opcode%=1:alias%=0
1320 PROCinputs
1330 status%=0
1340 ON ERROR status%=ERR:PROCfinish:GOTO 1380
1350 result=left DIV right
1360 PROCfinish
1370 REM case 15 complete
1380 left=-7:right=3
1390 opcode%=1:alias%=0
1400 PROCinputs
1410 status%=0
1420 ON ERROR status%=ERR:PROCfinish:GOTO 1460
1430 result=left DIV right
1440 PROCfinish
1450 REM case 16 complete
1460 left=7:right=-3
1470 opcode%=1:alias%=0
1480 PROCinputs
1490 status%=0
1500 ON ERROR status%=ERR:PROCfinish:GOTO 1540
1510 result=left DIV right
1520 PROCfinish
1530 REM case 17 complete
1540 left=&7FFFFFFF:right=1
1550 opcode%=1:alias%=0
1560 PROCinputs
1570 status%=0
1580 ON ERROR status%=ERR:PROCfinish:GOTO 1620
1590 result=left DIV right
1600 PROCfinish
1610 REM case 18 complete
1620 left=&80000000:right=-1
1630 opcode%=1:alias%=0
1640 PROCinputs
1650 status%=0
1660 ON ERROR status%=ERR:PROCfinish:GOTO 1700
1670 result=left DIV right
1680 PROCfinish
1690 REM case 19 complete
1700 left=&00FFFFFF:right=1
1710 opcode%=1:alias%=0
1720 PROCinputs
1730 status%=0
1740 ON ERROR status%=ERR:PROCfinish:GOTO 1780
1750 result=left DIV right
1760 PROCfinish
1770 REM case 20 complete
1780 left=65536:right=65536
1790 opcode%=1:alias%=0
1800 PROCinputs
1810 status%=0
1820 ON ERROR status%=ERR:PROCfinish:GOTO 1860
1830 result=left DIV right
1840 PROCfinish
1850 REM case 21 complete
1860 left=0.5:right=0.25
1870 opcode%=1:alias%=0
1880 PROCinputs
1890 status%=0
1900 ON ERROR status%=ERR:PROCfinish:GOTO 1940
1910 result=left DIV right
1920 PROCfinish
1930 REM case 22 complete
1940 left=1.5:right=2
1950 opcode%=1:alias%=0
1960 PROCinputs
1970 status%=0
1980 ON ERROR status%=ERR:PROCfinish:GOTO 2020
1990 result=left DIV right
2000 PROCfinish
2010 REM case 23 complete
2020 left=0.1:right=0.2
2030 opcode%=1:alias%=0
2040 PROCinputs
2050 status%=0
2060 ON ERROR status%=ERR:PROCfinish:GOTO 2100
2070 result=left DIV right
2080 PROCfinish
2090 REM case 24 complete
2100 left=1E38:right=10
2110 opcode%=1:alias%=0
2120 PROCinputs
2130 status%=0
2140 ON ERROR status%=ERR:PROCfinish:GOTO 2180
2150 result=left DIV right
2160 PROCfinish
2170 REM case 25 complete
2180 left=1E-38:right=100
2190 opcode%=1:alias%=0
2200 PROCinputs
2210 status%=0
2220 ON ERROR status%=ERR:PROCfinish:GOTO 2260
2230 result=left DIV right
2240 PROCfinish
2250 REM case 26 complete
2260 left=-0.5:right=0.25
2270 opcode%=1:alias%=0
2280 PROCinputs
2290 status%=0
2300 ON ERROR status%=ERR:PROCfinish:GOTO 2340
2310 result=left DIV right
2320 PROCfinish
2330 REM case 27 complete
2340 left=0:right=0
2350 opcode%=2:alias%=0
2360 PROCinputs
2370 status%=0
2380 ON ERROR status%=ERR:PROCfinish:GOTO 2420
2390 result=left EOR right
2400 PROCfinish
2410 REM case 28 complete
2420 left=1:right=1
2430 opcode%=2:alias%=0
2440 PROCinputs
2450 status%=0
2460 ON ERROR status%=ERR:PROCfinish:GOTO 2500
2470 result=left EOR right
2480 PROCfinish
2490 REM case 29 complete
2500 left=-7:right=3
2510 opcode%=2:alias%=0
2520 PROCinputs
2530 status%=0
2540 ON ERROR status%=ERR:PROCfinish:GOTO 2580
2550 result=left EOR right
2560 PROCfinish
2570 REM case 30 complete
2580 left=7:right=-3
2590 opcode%=2:alias%=0
2600 PROCinputs
2610 status%=0
2620 ON ERROR status%=ERR:PROCfinish:GOTO 2660
2630 result=left EOR right
2640 PROCfinish
2650 REM case 31 complete
2660 left=&7FFFFFFF:right=1
2670 opcode%=2:alias%=0
2680 PROCinputs
2690 status%=0
2700 ON ERROR status%=ERR:PROCfinish:GOTO 2740
2710 result=left EOR right
2720 PROCfinish
2730 REM case 32 complete
2740 left=&80000000:right=-1
2750 opcode%=2:alias%=0
2760 PROCinputs
2770 status%=0
2780 ON ERROR status%=ERR:PROCfinish:GOTO 2820
2790 result=left EOR right
2800 PROCfinish
2810 REM case 33 complete
2820 left=&00FFFFFF:right=1
2830 opcode%=2:alias%=0
2840 PROCinputs
2850 status%=0
2860 ON ERROR status%=ERR:PROCfinish:GOTO 2900
2870 result=left EOR right
2880 PROCfinish
2890 REM case 34 complete
2900 left=65536:right=65536
2910 opcode%=2:alias%=0
2920 PROCinputs
2930 status%=0
2940 ON ERROR status%=ERR:PROCfinish:GOTO 2980
2950 result=left EOR right
2960 PROCfinish
2970 REM case 35 complete
2980 left=0.5:right=0.25
2990 opcode%=2:alias%=0
3000 PROCinputs
3010 status%=0
3020 ON ERROR status%=ERR:PROCfinish:GOTO 3060
3030 result=left EOR right
3040 PROCfinish
3050 REM case 36 complete
3060 left=1.5:right=2
3070 opcode%=2:alias%=0
3080 PROCinputs
3090 status%=0
3100 ON ERROR status%=ERR:PROCfinish:GOTO 3140
3110 result=left EOR right
3120 PROCfinish
3130 REM case 37 complete
3140 left=0.1:right=0.2
3150 opcode%=2:alias%=0
3160 PROCinputs
3170 status%=0
3180 ON ERROR status%=ERR:PROCfinish:GOTO 3220
3190 result=left EOR right
3200 PROCfinish
3210 REM case 38 complete
3220 left=1E38:right=10
3230 opcode%=2:alias%=0
3240 PROCinputs
3250 status%=0
3260 ON ERROR status%=ERR:PROCfinish:GOTO 3300
3270 result=left EOR right
3280 PROCfinish
3290 REM case 39 complete
3300 left=1E-38:right=100
3310 opcode%=2:alias%=0
3320 PROCinputs
3330 status%=0
3340 ON ERROR status%=ERR:PROCfinish:GOTO 3380
3350 result=left EOR right
3360 PROCfinish
3370 REM case 40 complete
3380 left=-0.5:right=0.25
3390 opcode%=2:alias%=0
3400 PROCinputs
3410 status%=0
3420 ON ERROR status%=ERR:PROCfinish:GOTO 3460
3430 result=left EOR right
3440 PROCfinish
3450 REM case 41 complete
3460 left=0:right=0
3470 opcode%=3:alias%=0
3480 PROCinputs
3490 status%=0
3500 ON ERROR status%=ERR:PROCfinish:GOTO 3540
3510 result=left MOD right
3520 PROCfinish
3530 REM case 42 complete
3540 left=1:right=1
3550 opcode%=3:alias%=0
3560 PROCinputs
3570 status%=0
3580 ON ERROR status%=ERR:PROCfinish:GOTO 3620
3590 result=left MOD right
3600 PROCfinish
3610 REM case 43 complete
3620 left=-7:right=3
3630 opcode%=3:alias%=0
3640 PROCinputs
3650 status%=0
3660 ON ERROR status%=ERR:PROCfinish:GOTO 3700
3670 result=left MOD right
3680 PROCfinish
3690 REM case 44 complete
3700 left=7:right=-3
3710 opcode%=3:alias%=0
3720 PROCinputs
3730 status%=0
3740 ON ERROR status%=ERR:PROCfinish:GOTO 3780
3750 result=left MOD right
3760 PROCfinish
3770 REM case 45 complete
3780 left=&7FFFFFFF:right=1
3790 opcode%=3:alias%=0
3800 PROCinputs
3810 status%=0
3820 ON ERROR status%=ERR:PROCfinish:GOTO 3860
3830 result=left MOD right
3840 PROCfinish
3850 REM case 46 complete
3860 left=&80000000:right=-1
3870 opcode%=3:alias%=0
3880 PROCinputs
3890 status%=0
3900 ON ERROR status%=ERR:PROCfinish:GOTO 3940
3910 result=left MOD right
3920 PROCfinish
3930 REM case 47 complete
3940 left=&00FFFFFF:right=1
3950 opcode%=3:alias%=0
3960 PROCinputs
3970 status%=0
3980 ON ERROR status%=ERR:PROCfinish:GOTO 4020
3990 result=left MOD right
4000 PROCfinish
4010 REM case 48 complete
4020 left=65536:right=65536
4030 opcode%=3:alias%=0
4040 PROCinputs
4050 status%=0
4060 ON ERROR status%=ERR:PROCfinish:GOTO 4100
4070 result=left MOD right
4080 PROCfinish
4090 REM case 49 complete
4100 left=0.5:right=0.25
4110 opcode%=3:alias%=0
4120 PROCinputs
4130 status%=0
4140 ON ERROR status%=ERR:PROCfinish:GOTO 4180
4150 result=left MOD right
4160 PROCfinish
4170 REM case 50 complete
4180 left=1.5:right=2
4190 opcode%=3:alias%=0
4200 PROCinputs
4210 status%=0
4220 ON ERROR status%=ERR:PROCfinish:GOTO 4260
4230 result=left MOD right
4240 PROCfinish
4250 REM case 51 complete
4260 left=0.1:right=0.2
4270 opcode%=3:alias%=0
4280 PROCinputs
4290 status%=0
4300 ON ERROR status%=ERR:PROCfinish:GOTO 4340
4310 result=left MOD right
4320 PROCfinish
4330 REM case 52 complete
4340 left=1E38:right=10
4350 opcode%=3:alias%=0
4360 PROCinputs
4370 status%=0
4380 ON ERROR status%=ERR:PROCfinish:GOTO 4420
4390 result=left MOD right
4400 PROCfinish
4410 REM case 53 complete
4420 left=1E-38:right=100
4430 opcode%=3:alias%=0
4440 PROCinputs
4450 status%=0
4460 ON ERROR status%=ERR:PROCfinish:GOTO 4500
4470 result=left MOD right
4480 PROCfinish
4490 REM case 54 complete
4500 left=-0.5:right=0.25
4510 opcode%=3:alias%=0
4520 PROCinputs
4530 status%=0
4540 ON ERROR status%=ERR:PROCfinish:GOTO 4580
4550 result=left MOD right
4560 PROCfinish
4570 REM case 55 complete
4580 left=0:right=0
4590 opcode%=4:alias%=0
4600 PROCinputs
4610 status%=0
4620 ON ERROR status%=ERR:PROCfinish:GOTO 4660
4630 result=left OR right
4640 PROCfinish
4650 REM case 56 complete
4660 left=1:right=1
4670 opcode%=4:alias%=0
4680 PROCinputs
4690 status%=0
4700 ON ERROR status%=ERR:PROCfinish:GOTO 4740
4710 result=left OR right
4720 PROCfinish
4730 REM case 57 complete
4740 left=-7:right=3
4750 opcode%=4:alias%=0
4760 PROCinputs
4770 status%=0
4780 ON ERROR status%=ERR:PROCfinish:GOTO 4820
4790 result=left OR right
4800 PROCfinish
4810 REM case 58 complete
4820 left=7:right=-3
4830 opcode%=4:alias%=0
4840 PROCinputs
4850 status%=0
4860 ON ERROR status%=ERR:PROCfinish:GOTO 4900
4870 result=left OR right
4880 PROCfinish
4890 REM case 59 complete
4900 left=&7FFFFFFF:right=1
4910 opcode%=4:alias%=0
4920 PROCinputs
4930 status%=0
4940 ON ERROR status%=ERR:PROCfinish:GOTO 4980
4950 result=left OR right
4960 PROCfinish
4970 REM case 60 complete
4980 left=&80000000:right=-1
4990 opcode%=4:alias%=0
5000 PROCinputs
5010 status%=0
5020 ON ERROR status%=ERR:PROCfinish:GOTO 5060
5030 result=left OR right
5040 PROCfinish
5050 REM case 61 complete
5060 left=&00FFFFFF:right=1
5070 opcode%=4:alias%=0
5080 PROCinputs
5090 status%=0
5100 ON ERROR status%=ERR:PROCfinish:GOTO 5140
5110 result=left OR right
5120 PROCfinish
5130 REM case 62 complete
5140 left=65536:right=65536
5150 opcode%=4:alias%=0
5160 PROCinputs
5170 status%=0
5180 ON ERROR status%=ERR:PROCfinish:GOTO 5220
5190 result=left OR right
5200 PROCfinish
5210 REM case 63 complete
5220 left=0.5:right=0.25
5230 opcode%=4:alias%=0
5240 PROCinputs
5250 status%=0
5260 ON ERROR status%=ERR:PROCfinish:GOTO 5300
5270 result=left OR right
5280 PROCfinish
5290 REM case 64 complete
5300 left=1.5:right=2
5310 opcode%=4:alias%=0
5320 PROCinputs
5330 status%=0
5340 ON ERROR status%=ERR:PROCfinish:GOTO 5380
5350 result=left OR right
5360 PROCfinish
5370 REM case 65 complete
5380 left=0.1:right=0.2
5390 opcode%=4:alias%=0
5400 PROCinputs
5410 status%=0
5420 ON ERROR status%=ERR:PROCfinish:GOTO 5460
5430 result=left OR right
5440 PROCfinish
5450 REM case 66 complete
5460 left=1E38:right=10
5470 opcode%=4:alias%=0
5480 PROCinputs
5490 status%=0
5500 ON ERROR status%=ERR:PROCfinish:GOTO 5540
5510 result=left OR right
5520 PROCfinish
5530 REM case 67 complete
5540 left=1E-38:right=100
5550 opcode%=4:alias%=0
5560 PROCinputs
5570 status%=0
5580 ON ERROR status%=ERR:PROCfinish:GOTO 5620
5590 result=left OR right
5600 PROCfinish
5610 REM case 68 complete
5620 left=-0.5:right=0.25
5630 opcode%=4:alias%=0
5640 PROCinputs
5650 status%=0
5660 ON ERROR status%=ERR:PROCfinish:GOTO 5700
5670 result=left OR right
5680 PROCfinish
5690 REM case 69 complete
5700 left=0:right=0
5710 opcode%=5:alias%=0
5720 PROCinputs
5730 status%=0
5740 ON ERROR status%=ERR:PROCfinish:GOTO 5780
5750 result=left <= right
5760 PROCfinish
5770 REM case 70 complete
5780 left=1:right=1
5790 opcode%=5:alias%=0
5800 PROCinputs
5810 status%=0
5820 ON ERROR status%=ERR:PROCfinish:GOTO 5860
5830 result=left <= right
5840 PROCfinish
5850 REM case 71 complete
5860 left=-7:right=3
5870 opcode%=5:alias%=0
5880 PROCinputs
5890 status%=0
5900 ON ERROR status%=ERR:PROCfinish:GOTO 5940
5910 result=left <= right
5920 PROCfinish
5930 REM case 72 complete
5940 left=7:right=-3
5950 opcode%=5:alias%=0
5960 PROCinputs
5970 status%=0
5980 ON ERROR status%=ERR:PROCfinish:GOTO 6020
5990 result=left <= right
6000 PROCfinish
6010 REM case 73 complete
6020 left=&7FFFFFFF:right=1
6030 opcode%=5:alias%=0
6040 PROCinputs
6050 status%=0
6060 ON ERROR status%=ERR:PROCfinish:GOTO 6100
6070 result=left <= right
6080 PROCfinish
6090 REM case 74 complete
6100 left=&80000000:right=-1
6110 opcode%=5:alias%=0
6120 PROCinputs
6130 status%=0
6140 ON ERROR status%=ERR:PROCfinish:GOTO 6180
6150 result=left <= right
6160 PROCfinish
6170 REM case 75 complete
6180 left=&00FFFFFF:right=1
6190 opcode%=5:alias%=0
6200 PROCinputs
6210 status%=0
6220 ON ERROR status%=ERR:PROCfinish:GOTO 6260
6230 result=left <= right
6240 PROCfinish
6250 REM case 76 complete
6260 left=65536:right=65536
6270 opcode%=5:alias%=0
6280 PROCinputs
6290 status%=0
6300 ON ERROR status%=ERR:PROCfinish:GOTO 6340
6310 result=left <= right
6320 PROCfinish
6330 REM case 77 complete
6340 left=0.5:right=0.25
6350 opcode%=5:alias%=0
6360 PROCinputs
6370 status%=0
6380 ON ERROR status%=ERR:PROCfinish:GOTO 6420
6390 result=left <= right
6400 PROCfinish
6410 REM case 78 complete
6420 left=1.5:right=2
6430 opcode%=5:alias%=0
6440 PROCinputs
6450 status%=0
6460 ON ERROR status%=ERR:PROCfinish:GOTO 6500
6470 result=left <= right
6480 PROCfinish
6490 REM case 79 complete
6500 left=0.1:right=0.2
6510 opcode%=5:alias%=0
6520 PROCinputs
6530 status%=0
6540 ON ERROR status%=ERR:PROCfinish:GOTO 6580
6550 result=left <= right
6560 PROCfinish
6570 REM case 80 complete
6580 left=1E38:right=10
6590 opcode%=5:alias%=0
6600 PROCinputs
6610 status%=0
6620 ON ERROR status%=ERR:PROCfinish:GOTO 6660
6630 result=left <= right
6640 PROCfinish
6650 REM case 81 complete
6660 left=1E-38:right=100
6670 opcode%=5:alias%=0
6680 PROCinputs
6690 status%=0
6700 ON ERROR status%=ERR:PROCfinish:GOTO 6740
6710 result=left <= right
6720 PROCfinish
6730 REM case 82 complete
6740 left=-0.5:right=0.25
6750 opcode%=5:alias%=0
6760 PROCinputs
6770 status%=0
6780 ON ERROR status%=ERR:PROCfinish:GOTO 6820
6790 result=left <= right
6800 PROCfinish
6810 REM case 83 complete
6820 left=0:right=0
6830 opcode%=6:alias%=0
6840 PROCinputs
6850 status%=0
6860 ON ERROR status%=ERR:PROCfinish:GOTO 6900
6870 result=left <> right
6880 PROCfinish
6890 REM case 84 complete
6900 left=1:right=1
6910 opcode%=6:alias%=0
6920 PROCinputs
6930 status%=0
6940 ON ERROR status%=ERR:PROCfinish:GOTO 6980
6950 result=left <> right
6960 PROCfinish
6970 REM case 85 complete
6980 left=-7:right=3
6990 opcode%=6:alias%=0
7000 PROCinputs
7010 status%=0
7020 ON ERROR status%=ERR:PROCfinish:GOTO 7060
7030 result=left <> right
7040 PROCfinish
7050 REM case 86 complete
7060 left=7:right=-3
7070 opcode%=6:alias%=0
7080 PROCinputs
7090 status%=0
7100 ON ERROR status%=ERR:PROCfinish:GOTO 7140
7110 result=left <> right
7120 PROCfinish
7130 REM case 87 complete
7140 left=&7FFFFFFF:right=1
7150 opcode%=6:alias%=0
7160 PROCinputs
7170 status%=0
7180 ON ERROR status%=ERR:PROCfinish:GOTO 7220
7190 result=left <> right
7200 PROCfinish
7210 REM case 88 complete
7220 left=&80000000:right=-1
7230 opcode%=6:alias%=0
7240 PROCinputs
7250 status%=0
7260 ON ERROR status%=ERR:PROCfinish:GOTO 7300
7270 result=left <> right
7280 PROCfinish
7290 REM case 89 complete
7300 left=&00FFFFFF:right=1
7310 opcode%=6:alias%=0
7320 PROCinputs
7330 status%=0
7340 ON ERROR status%=ERR:PROCfinish:GOTO 7380
7350 result=left <> right
7360 PROCfinish
7370 REM case 90 complete
7380 left=65536:right=65536
7390 opcode%=6:alias%=0
7400 PROCinputs
7410 status%=0
7420 ON ERROR status%=ERR:PROCfinish:GOTO 7460
7430 result=left <> right
7440 PROCfinish
7450 REM case 91 complete
7460 left=0.5:right=0.25
7470 opcode%=6:alias%=0
7480 PROCinputs
7490 status%=0
7500 ON ERROR status%=ERR:PROCfinish:GOTO 7540
7510 result=left <> right
7520 PROCfinish
7530 REM case 92 complete
7540 left=1.5:right=2
7550 opcode%=6:alias%=0
7560 PROCinputs
7570 status%=0
7580 ON ERROR status%=ERR:PROCfinish:GOTO 7620
7590 result=left <> right
7600 PROCfinish
7610 REM case 93 complete
7620 left=0.1:right=0.2
7630 opcode%=6:alias%=0
7640 PROCinputs
7650 status%=0
7660 ON ERROR status%=ERR:PROCfinish:GOTO 7700
7670 result=left <> right
7680 PROCfinish
7690 REM case 94 complete
7700 left=1E38:right=10
7710 opcode%=6:alias%=0
7720 PROCinputs
7730 status%=0
7740 ON ERROR status%=ERR:PROCfinish:GOTO 7780
7750 result=left <> right
7760 PROCfinish
7770 REM case 95 complete
7780 left=1E-38:right=100
7790 opcode%=6:alias%=0
7800 PROCinputs
7810 status%=0
7820 ON ERROR status%=ERR:PROCfinish:GOTO 7860
7830 result=left <> right
7840 PROCfinish
7850 REM case 96 complete
7860 left=-0.5:right=0.25
7870 opcode%=6:alias%=0
7880 PROCinputs
7890 status%=0
7900 ON ERROR status%=ERR:PROCfinish:GOTO 7940
7910 result=left <> right
7920 PROCfinish
7930 REM case 97 complete
7940 left=0:right=0
7950 opcode%=7:alias%=0
7960 PROCinputs
7970 status%=0
7980 ON ERROR status%=ERR:PROCfinish:GOTO 8020
7990 result=left >= right
8000 PROCfinish
8010 REM case 98 complete
8020 left=1:right=1
8030 opcode%=7:alias%=0
8040 PROCinputs
8050 status%=0
8060 ON ERROR status%=ERR:PROCfinish:GOTO 8100
8070 result=left >= right
8080 PROCfinish
8090 REM case 99 complete
8100 left=-7:right=3
8110 opcode%=7:alias%=0
8120 PROCinputs
8130 status%=0
8140 ON ERROR status%=ERR:PROCfinish:GOTO 8180
8150 result=left >= right
8160 PROCfinish
8170 REM case 100 complete
8180 left=7:right=-3
8190 opcode%=7:alias%=0
8200 PROCinputs
8210 status%=0
8220 ON ERROR status%=ERR:PROCfinish:GOTO 8260
8230 result=left >= right
8240 PROCfinish
8250 REM case 101 complete
8260 left=&7FFFFFFF:right=1
8270 opcode%=7:alias%=0
8280 PROCinputs
8290 status%=0
8300 ON ERROR status%=ERR:PROCfinish:GOTO 8340
8310 result=left >= right
8320 PROCfinish
8330 REM case 102 complete
8340 left=&80000000:right=-1
8350 opcode%=7:alias%=0
8360 PROCinputs
8370 status%=0
8380 ON ERROR status%=ERR:PROCfinish:GOTO 8420
8390 result=left >= right
8400 PROCfinish
8410 REM case 103 complete
8420 left=&00FFFFFF:right=1
8430 opcode%=7:alias%=0
8440 PROCinputs
8450 status%=0
8460 ON ERROR status%=ERR:PROCfinish:GOTO 8500
8470 result=left >= right
8480 PROCfinish
8490 REM case 104 complete
8500 left=65536:right=65536
8510 opcode%=7:alias%=0
8520 PROCinputs
8530 status%=0
8540 ON ERROR status%=ERR:PROCfinish:GOTO 8580
8550 result=left >= right
8560 PROCfinish
8570 REM case 105 complete
8580 left=0.5:right=0.25
8590 opcode%=7:alias%=0
8600 PROCinputs
8610 status%=0
8620 ON ERROR status%=ERR:PROCfinish:GOTO 8660
8630 result=left >= right
8640 PROCfinish
8650 REM case 106 complete
8660 left=1.5:right=2
8670 opcode%=7:alias%=0
8680 PROCinputs
8690 status%=0
8700 ON ERROR status%=ERR:PROCfinish:GOTO 8740
8710 result=left >= right
8720 PROCfinish
8730 REM case 107 complete
8740 left=0.1:right=0.2
8750 opcode%=7:alias%=0
8760 PROCinputs
8770 status%=0
8780 ON ERROR status%=ERR:PROCfinish:GOTO 8820
8790 result=left >= right
8800 PROCfinish
8810 REM case 108 complete
8820 left=1E38:right=10
8830 opcode%=7:alias%=0
8840 PROCinputs
8850 status%=0
8860 ON ERROR status%=ERR:PROCfinish:GOTO 8900
8870 result=left >= right
8880 PROCfinish
8890 REM case 109 complete
8900 left=1E-38:right=100
8910 opcode%=7:alias%=0
8920 PROCinputs
8930 status%=0
8940 ON ERROR status%=ERR:PROCfinish:GOTO 8980
8950 result=left >= right
8960 PROCfinish
8970 REM case 110 complete
8980 left=-0.5:right=0.25
8990 opcode%=7:alias%=0
9000 PROCinputs
9010 status%=0
9020 ON ERROR status%=ERR:PROCfinish:GOTO 9060
9030 result=left >= right
9040 PROCfinish
9050 REM case 111 complete
9060 left=0:right=0
9070 opcode%=8:alias%=0
9080 PROCinputs
9090 status%=0
9100 ON ERROR status%=ERR:PROCfinish:GOTO 9140
9110 result=left < right
9120 PROCfinish
9130 REM case 112 complete
9140 left=1:right=1
9150 opcode%=8:alias%=0
9160 PROCinputs
9170 status%=0
9180 ON ERROR status%=ERR:PROCfinish:GOTO 9220
9190 result=left < right
9200 PROCfinish
9210 REM case 113 complete
9220 left=-7:right=3
9230 opcode%=8:alias%=0
9240 PROCinputs
9250 status%=0
9260 ON ERROR status%=ERR:PROCfinish:GOTO 9300
9270 result=left < right
9280 PROCfinish
9290 REM case 114 complete
9300 left=7:right=-3
9310 opcode%=8:alias%=0
9320 PROCinputs
9330 status%=0
9340 ON ERROR status%=ERR:PROCfinish:GOTO 9380
9350 result=left < right
9360 PROCfinish
9370 REM case 115 complete
9380 left=&7FFFFFFF:right=1
9390 opcode%=8:alias%=0
9400 PROCinputs
9410 status%=0
9420 ON ERROR status%=ERR:PROCfinish:GOTO 9460
9430 result=left < right
9440 PROCfinish
9450 REM case 116 complete
9460 left=&80000000:right=-1
9470 opcode%=8:alias%=0
9480 PROCinputs
9490 status%=0
9500 ON ERROR status%=ERR:PROCfinish:GOTO 9540
9510 result=left < right
9520 PROCfinish
9530 REM case 117 complete
9540 left=&00FFFFFF:right=1
9550 opcode%=8:alias%=0
9560 PROCinputs
9570 status%=0
9580 ON ERROR status%=ERR:PROCfinish:GOTO 9620
9590 result=left < right
9600 PROCfinish
9610 REM case 118 complete
9620 left=65536:right=65536
9630 opcode%=8:alias%=0
9640 PROCinputs
9650 status%=0
9660 ON ERROR status%=ERR:PROCfinish:GOTO 9700
9670 result=left < right
9680 PROCfinish
9690 REM case 119 complete
9700 left=0.5:right=0.25
9710 opcode%=8:alias%=0
9720 PROCinputs
9730 status%=0
9740 ON ERROR status%=ERR:PROCfinish:GOTO 9780
9750 result=left < right
9760 PROCfinish
9770 REM case 120 complete
9780 left=1.5:right=2
9790 opcode%=8:alias%=0
9800 PROCinputs
9810 status%=0
9820 ON ERROR status%=ERR:PROCfinish:GOTO 9860
9830 result=left < right
9840 PROCfinish
9850 REM case 121 complete
9860 left=0.1:right=0.2
9870 opcode%=8:alias%=0
9880 PROCinputs
9890 status%=0
9900 ON ERROR status%=ERR:PROCfinish:GOTO 9940
9910 result=left < right
9920 PROCfinish
9930 REM case 122 complete
9940 left=1E38:right=10
9950 opcode%=8:alias%=0
9960 PROCinputs
9970 status%=0
9980 ON ERROR status%=ERR:PROCfinish:GOTO 10020
9990 result=left < right
10000 PROCfinish
10010 REM case 123 complete
10020 left=1E-38:right=100
10030 opcode%=8:alias%=0
10040 PROCinputs
10050 status%=0
10060 ON ERROR status%=ERR:PROCfinish:GOTO 10100
10070 result=left < right
10080 PROCfinish
10090 REM case 124 complete
10100 left=-0.5:right=0.25
10110 opcode%=8:alias%=0
10120 PROCinputs
10130 status%=0
10140 ON ERROR status%=ERR:PROCfinish:GOTO 10180
10150 result=left < right
10160 PROCfinish
10170 REM case 125 complete
10180 left=0:right=0
10190 opcode%=9:alias%=0
10200 PROCinputs
10210 status%=0
10220 ON ERROR status%=ERR:PROCfinish:GOTO 10260
10230 result=left = right
10240 PROCfinish
10250 REM case 126 complete
10260 left=1:right=1
10270 opcode%=9:alias%=0
10280 PROCinputs
10290 status%=0
10300 ON ERROR status%=ERR:PROCfinish:GOTO 10340
10310 result=left = right
10320 PROCfinish
10330 REM case 127 complete
10340 left=-7:right=3
10350 opcode%=9:alias%=0
10360 PROCinputs
10370 status%=0
10380 ON ERROR status%=ERR:PROCfinish:GOTO 10420
10390 result=left = right
10400 PROCfinish
10410 REM case 128 complete
10420 left=7:right=-3
10430 opcode%=9:alias%=0
10440 PROCinputs
10450 status%=0
10460 ON ERROR status%=ERR:PROCfinish:GOTO 10500
10470 result=left = right
10480 PROCfinish
10490 REM case 129 complete
10500 left=&7FFFFFFF:right=1
10510 opcode%=9:alias%=0
10520 PROCinputs
10530 status%=0
10540 ON ERROR status%=ERR:PROCfinish:GOTO 10580
10550 result=left = right
10560 PROCfinish
10570 REM case 130 complete
10580 left=&80000000:right=-1
10590 opcode%=9:alias%=0
10600 PROCinputs
10610 status%=0
10620 ON ERROR status%=ERR:PROCfinish:GOTO 10660
10630 result=left = right
10640 PROCfinish
10650 REM case 131 complete
10660 left=&00FFFFFF:right=1
10670 opcode%=9:alias%=0
10680 PROCinputs
10690 status%=0
10700 ON ERROR status%=ERR:PROCfinish:GOTO 10740
10710 result=left = right
10720 PROCfinish
10730 REM case 132 complete
10740 left=65536:right=65536
10750 opcode%=9:alias%=0
10760 PROCinputs
10770 status%=0
10780 ON ERROR status%=ERR:PROCfinish:GOTO 10820
10790 result=left = right
10800 PROCfinish
10810 REM case 133 complete
10820 left=0.5:right=0.25
10830 opcode%=9:alias%=0
10840 PROCinputs
10850 status%=0
10860 ON ERROR status%=ERR:PROCfinish:GOTO 10900
10870 result=left = right
10880 PROCfinish
10890 REM case 134 complete
10900 left=1.5:right=2
10910 opcode%=9:alias%=0
10920 PROCinputs
10930 status%=0
10940 ON ERROR status%=ERR:PROCfinish:GOTO 10980
10950 result=left = right
10960 PROCfinish
10970 REM case 135 complete
10980 left=0.1:right=0.2
10990 opcode%=9:alias%=0
11000 PROCinputs
11010 status%=0
11020 ON ERROR status%=ERR:PROCfinish:GOTO 11060
11030 result=left = right
11040 PROCfinish
11050 REM case 136 complete
11060 left=1E38:right=10
11070 opcode%=9:alias%=0
11080 PROCinputs
11090 status%=0
11100 ON ERROR status%=ERR:PROCfinish:GOTO 11140
11110 result=left = right
11120 PROCfinish
11130 REM case 137 complete
11140 left=1E-38:right=100
11150 opcode%=9:alias%=0
11160 PROCinputs
11170 status%=0
11180 ON ERROR status%=ERR:PROCfinish:GOTO 11220
11190 result=left = right
11200 PROCfinish
11210 REM case 138 complete
11220 left=-0.5:right=0.25
11230 opcode%=9:alias%=0
11240 PROCinputs
11250 status%=0
11260 ON ERROR status%=ERR:PROCfinish:GOTO 11300
11270 result=left = right
11280 PROCfinish
11290 REM case 139 complete
11300 left=0:right=0
11310 opcode%=10:alias%=0
11320 PROCinputs
11330 status%=0
11340 ON ERROR status%=ERR:PROCfinish:GOTO 11380
11350 result=left * right
11360 PROCfinish
11370 REM case 140 complete
11380 left=1:right=1
11390 opcode%=10:alias%=0
11400 PROCinputs
11410 status%=0
11420 ON ERROR status%=ERR:PROCfinish:GOTO 11460
11430 result=left * right
11440 PROCfinish
11450 REM case 141 complete
11460 left=-7:right=3
11470 opcode%=10:alias%=0
11480 PROCinputs
11490 status%=0
11500 ON ERROR status%=ERR:PROCfinish:GOTO 11540
11510 result=left * right
11520 PROCfinish
11530 REM case 142 complete
11540 left=7:right=-3
11550 opcode%=10:alias%=0
11560 PROCinputs
11570 status%=0
11580 ON ERROR status%=ERR:PROCfinish:GOTO 11620
11590 result=left * right
11600 PROCfinish
11610 REM case 143 complete
11620 left=&7FFFFFFF:right=1
11630 opcode%=10:alias%=0
11640 PROCinputs
11650 status%=0
11660 ON ERROR status%=ERR:PROCfinish:GOTO 11700
11670 result=left * right
11680 PROCfinish
11690 REM case 144 complete
11700 left=&80000000:right=-1
11710 opcode%=10:alias%=0
11720 PROCinputs
11730 status%=0
11740 ON ERROR status%=ERR:PROCfinish:GOTO 11780
11750 result=left * right
11760 PROCfinish
11770 REM case 145 complete
11780 left=&00FFFFFF:right=1
11790 opcode%=10:alias%=0
11800 PROCinputs
11810 status%=0
11820 ON ERROR status%=ERR:PROCfinish:GOTO 11860
11830 result=left * right
11840 PROCfinish
11850 REM case 146 complete
11860 left=65536:right=65536
11870 opcode%=10:alias%=0
11880 PROCinputs
11890 status%=0
11900 ON ERROR status%=ERR:PROCfinish:GOTO 11940
11910 result=left * right
11920 PROCfinish
11930 REM case 147 complete
11940 left=0.5:right=0.25
11950 opcode%=10:alias%=0
11960 PROCinputs
11970 status%=0
11980 ON ERROR status%=ERR:PROCfinish:GOTO 12020
11990 result=left * right
12000 PROCfinish
12010 REM case 148 complete
12020 left=1.5:right=2
12030 opcode%=10:alias%=0
12040 PROCinputs
12050 status%=0
12060 ON ERROR status%=ERR:PROCfinish:GOTO 12100
12070 result=left * right
12080 PROCfinish
12090 REM case 149 complete
12100 left=0.1:right=0.2
12110 opcode%=10:alias%=0
12120 PROCinputs
12130 status%=0
12140 ON ERROR status%=ERR:PROCfinish:GOTO 12180
12150 result=left * right
12160 PROCfinish
12170 REM case 150 complete
12180 left=1E38:right=10
12190 opcode%=10:alias%=0
12200 PROCinputs
12210 status%=0
12220 ON ERROR status%=ERR:PROCfinish:GOTO 12260
12230 result=left * right
12240 PROCfinish
12250 REM case 151 complete
12260 left=1E-38:right=100
12270 opcode%=10:alias%=0
12280 PROCinputs
12290 status%=0
12300 ON ERROR status%=ERR:PROCfinish:GOTO 12340
12310 result=left * right
12320 PROCfinish
12330 REM case 152 complete
12340 left=-0.5:right=0.25
12350 opcode%=10:alias%=0
12360 PROCinputs
12370 status%=0
12380 ON ERROR status%=ERR:PROCfinish:GOTO 12420
12390 result=left * right
12400 PROCfinish
12410 REM case 153 complete
12420 left=0:right=0
12430 opcode%=11:alias%=0
12440 PROCinputs
12450 status%=0
12460 ON ERROR status%=ERR:PROCfinish:GOTO 12500
12470 result=left + right
12480 PROCfinish
12490 REM case 154 complete
12500 left=1:right=1
12510 opcode%=11:alias%=0
12520 PROCinputs
12530 status%=0
12540 ON ERROR status%=ERR:PROCfinish:GOTO 12580
12550 result=left + right
12560 PROCfinish
12570 REM case 155 complete
12580 left=-7:right=3
12590 opcode%=11:alias%=0
12600 PROCinputs
12610 status%=0
12620 ON ERROR status%=ERR:PROCfinish:GOTO 12660
12630 result=left + right
12640 PROCfinish
12650 REM case 156 complete
12660 left=7:right=-3
12670 opcode%=11:alias%=0
12680 PROCinputs
12690 status%=0
12700 ON ERROR status%=ERR:PROCfinish:GOTO 12740
12710 result=left + right
12720 PROCfinish
12730 REM case 157 complete
12740 left=&7FFFFFFF:right=1
12750 opcode%=11:alias%=0
12760 PROCinputs
12770 status%=0
12780 ON ERROR status%=ERR:PROCfinish:GOTO 12820
12790 result=left + right
12800 PROCfinish
12810 REM case 158 complete
12820 left=&80000000:right=-1
12830 opcode%=11:alias%=0
12840 PROCinputs
12850 status%=0
12860 ON ERROR status%=ERR:PROCfinish:GOTO 12900
12870 result=left + right
12880 PROCfinish
12890 REM case 159 complete
12900 left=&00FFFFFF:right=1
12910 opcode%=11:alias%=0
12920 PROCinputs
12930 status%=0
12940 ON ERROR status%=ERR:PROCfinish:GOTO 12980
12950 result=left + right
12960 PROCfinish
12970 REM case 160 complete
12980 left=65536:right=65536
12990 opcode%=11:alias%=0
13000 PROCinputs
13010 status%=0
13020 ON ERROR status%=ERR:PROCfinish:GOTO 13060
13030 result=left + right
13040 PROCfinish
13050 REM case 161 complete
13060 left=0.5:right=0.25
13070 opcode%=11:alias%=0
13080 PROCinputs
13090 status%=0
13100 ON ERROR status%=ERR:PROCfinish:GOTO 13140
13110 result=left + right
13120 PROCfinish
13130 REM case 162 complete
13140 left=1.5:right=2
13150 opcode%=11:alias%=0
13160 PROCinputs
13170 status%=0
13180 ON ERROR status%=ERR:PROCfinish:GOTO 13220
13190 result=left + right
13200 PROCfinish
13210 REM case 163 complete
13220 left=0.1:right=0.2
13230 opcode%=11:alias%=0
13240 PROCinputs
13250 status%=0
13260 ON ERROR status%=ERR:PROCfinish:GOTO 13300
13270 result=left + right
13280 PROCfinish
13290 REM case 164 complete
13300 left=1E38:right=10
13310 opcode%=11:alias%=0
13320 PROCinputs
13330 status%=0
13340 ON ERROR status%=ERR:PROCfinish:GOTO 13380
13350 result=left + right
13360 PROCfinish
13370 REM case 165 complete
13380 left=1E-38:right=100
13390 opcode%=11:alias%=0
13400 PROCinputs
13410 status%=0
13420 ON ERROR status%=ERR:PROCfinish:GOTO 13460
13430 result=left + right
13440 PROCfinish
13450 REM case 166 complete
13460 left=-0.5:right=0.25
13470 opcode%=11:alias%=0
13480 PROCinputs
13490 status%=0
13500 ON ERROR status%=ERR:PROCfinish:GOTO 13540
13510 result=left + right
13520 PROCfinish
13530 REM case 167 complete
13540 left=0:right=0
13550 opcode%=12:alias%=0
13560 PROCinputs
13570 status%=0
13580 ON ERROR status%=ERR:PROCfinish:GOTO 13620
13590 result=left > right
13600 PROCfinish
13610 REM case 168 complete
13620 left=1:right=1
13630 opcode%=12:alias%=0
13640 PROCinputs
13650 status%=0
13660 ON ERROR status%=ERR:PROCfinish:GOTO 13700
13670 result=left > right
13680 PROCfinish
13690 REM case 169 complete
13700 left=-7:right=3
13710 opcode%=12:alias%=0
13720 PROCinputs
13730 status%=0
13740 ON ERROR status%=ERR:PROCfinish:GOTO 13780
13750 result=left > right
13760 PROCfinish
13770 REM case 170 complete
13780 left=7:right=-3
13790 opcode%=12:alias%=0
13800 PROCinputs
13810 status%=0
13820 ON ERROR status%=ERR:PROCfinish:GOTO 13860
13830 result=left > right
13840 PROCfinish
13850 REM case 171 complete
13860 left=&7FFFFFFF:right=1
13870 opcode%=12:alias%=0
13880 PROCinputs
13890 status%=0
13900 ON ERROR status%=ERR:PROCfinish:GOTO 13940
13910 result=left > right
13920 PROCfinish
13930 REM case 172 complete
13940 left=&80000000:right=-1
13950 opcode%=12:alias%=0
13960 PROCinputs
13970 status%=0
13980 ON ERROR status%=ERR:PROCfinish:GOTO 14020
13990 result=left > right
14000 PROCfinish
14010 REM case 173 complete
14020 left=&00FFFFFF:right=1
14030 opcode%=12:alias%=0
14040 PROCinputs
14050 status%=0
14060 ON ERROR status%=ERR:PROCfinish:GOTO 14100
14070 result=left > right
14080 PROCfinish
14090 REM case 174 complete
14100 left=65536:right=65536
14110 opcode%=12:alias%=0
14120 PROCinputs
14130 status%=0
14140 ON ERROR status%=ERR:PROCfinish:GOTO 14180
14150 result=left > right
14160 PROCfinish
14170 REM case 175 complete
14180 left=0.5:right=0.25
14190 opcode%=12:alias%=0
14200 PROCinputs
14210 status%=0
14220 ON ERROR status%=ERR:PROCfinish:GOTO 14260
14230 result=left > right
14240 PROCfinish
14250 REM case 176 complete
14260 left=1.5:right=2
14270 opcode%=12:alias%=0
14280 PROCinputs
14290 status%=0
14300 ON ERROR status%=ERR:PROCfinish:GOTO 14340
14310 result=left > right
14320 PROCfinish
14330 REM case 177 complete
14340 left=0.1:right=0.2
14350 opcode%=12:alias%=0
14360 PROCinputs
14370 status%=0
14380 ON ERROR status%=ERR:PROCfinish:GOTO 14420
14390 result=left > right
14400 PROCfinish
14410 REM case 178 complete
14420 left=1E38:right=10
14430 opcode%=12:alias%=0
14440 PROCinputs
14450 status%=0
14460 ON ERROR status%=ERR:PROCfinish:GOTO 14500
14470 result=left > right
14480 PROCfinish
14490 REM case 179 complete
14500 left=1E-38:right=100
14510 opcode%=12:alias%=0
14520 PROCinputs
14530 status%=0
14540 ON ERROR status%=ERR:PROCfinish:GOTO 14580
14550 result=left > right
14560 PROCfinish
14570 REM case 180 complete
14580 left=-0.5:right=0.25
14590 opcode%=12:alias%=0
14600 PROCinputs
14610 status%=0
14620 ON ERROR status%=ERR:PROCfinish:GOTO 14660
14630 result=left > right
14640 PROCfinish
14650 REM case 181 complete
14660 left=0:right=0
14670 opcode%=13:alias%=0
14680 PROCinputs
14690 status%=0
14700 ON ERROR status%=ERR:PROCfinish:GOTO 14740
14710 result=left - right
14720 PROCfinish
14730 REM case 182 complete
14740 left=1:right=1
14750 opcode%=13:alias%=0
14760 PROCinputs
14770 status%=0
14780 ON ERROR status%=ERR:PROCfinish:GOTO 14820
14790 result=left - right
14800 PROCfinish
14810 REM case 183 complete
14820 left=-7:right=3
14830 opcode%=13:alias%=0
14840 PROCinputs
14850 status%=0
14860 ON ERROR status%=ERR:PROCfinish:GOTO 14900
14870 result=left - right
14880 PROCfinish
14890 REM case 184 complete
14900 left=7:right=-3
14910 opcode%=13:alias%=0
14920 PROCinputs
14930 status%=0
14940 ON ERROR status%=ERR:PROCfinish:GOTO 14980
14950 result=left - right
14960 PROCfinish
14970 REM case 185 complete
14980 left=&7FFFFFFF:right=1
14990 opcode%=13:alias%=0
15000 PROCinputs
15010 status%=0
15020 ON ERROR status%=ERR:PROCfinish:GOTO 15060
15030 result=left - right
15040 PROCfinish
15050 REM case 186 complete
15060 left=&80000000:right=-1
15070 opcode%=13:alias%=0
15080 PROCinputs
15090 status%=0
15100 ON ERROR status%=ERR:PROCfinish:GOTO 15140
15110 result=left - right
15120 PROCfinish
15130 REM case 187 complete
15140 left=&00FFFFFF:right=1
15150 opcode%=13:alias%=0
15160 PROCinputs
15170 status%=0
15180 ON ERROR status%=ERR:PROCfinish:GOTO 15220
15190 result=left - right
15200 PROCfinish
15210 REM case 188 complete
15220 left=65536:right=65536
15230 opcode%=13:alias%=0
15240 PROCinputs
15250 status%=0
15260 ON ERROR status%=ERR:PROCfinish:GOTO 15300
15270 result=left - right
15280 PROCfinish
15290 REM case 189 complete
15300 left=0.5:right=0.25
15310 opcode%=13:alias%=0
15320 PROCinputs
15330 status%=0
15340 ON ERROR status%=ERR:PROCfinish:GOTO 15380
15350 result=left - right
15360 PROCfinish
15370 REM case 190 complete
15380 left=1.5:right=2
15390 opcode%=13:alias%=0
15400 PROCinputs
15410 status%=0
15420 ON ERROR status%=ERR:PROCfinish:GOTO 15460
15430 result=left - right
15440 PROCfinish
15450 REM case 191 complete
15460 left=0.1:right=0.2
15470 opcode%=13:alias%=0
15480 PROCinputs
15490 status%=0
15500 ON ERROR status%=ERR:PROCfinish:GOTO 15540
15510 result=left - right
15520 PROCfinish
15530 REM case 192 complete
15540 left=1E38:right=10
15550 opcode%=13:alias%=0
15560 PROCinputs
15570 status%=0
15580 ON ERROR status%=ERR:PROCfinish:GOTO 15620
15590 result=left - right
15600 PROCfinish
15610 REM case 193 complete
15620 left=1E-38:right=100
15630 opcode%=13:alias%=0
15640 PROCinputs
15650 status%=0
15660 ON ERROR status%=ERR:PROCfinish:GOTO 15700
15670 result=left - right
15680 PROCfinish
15690 REM case 194 complete
15700 left=-0.5:right=0.25
15710 opcode%=13:alias%=0
15720 PROCinputs
15730 status%=0
15740 ON ERROR status%=ERR:PROCfinish:GOTO 15780
15750 result=left - right
15760 PROCfinish
15770 REM case 195 complete
15780 left=0:right=0
15790 opcode%=15:alias%=0
15800 PROCinputs
15810 status%=0
15820 ON ERROR status%=ERR:PROCfinish:GOTO 15860
15830 result=left / right
15840 PROCfinish
15850 REM case 196 complete
15860 left=1:right=1
15870 opcode%=15:alias%=0
15880 PROCinputs
15890 status%=0
15900 ON ERROR status%=ERR:PROCfinish:GOTO 15940
15910 result=left / right
15920 PROCfinish
15930 REM case 197 complete
15940 left=-7:right=3
15950 opcode%=15:alias%=0
15960 PROCinputs
15970 status%=0
15980 ON ERROR status%=ERR:PROCfinish:GOTO 16020
15990 result=left / right
16000 PROCfinish
16010 REM case 198 complete
16020 left=7:right=-3
16030 opcode%=15:alias%=0
16040 PROCinputs
16050 status%=0
16060 ON ERROR status%=ERR:PROCfinish:GOTO 16100
16070 result=left / right
16080 PROCfinish
16090 REM case 199 complete
16100 left=&7FFFFFFF:right=1
16110 opcode%=15:alias%=0
16120 PROCinputs
16130 status%=0
16140 ON ERROR status%=ERR:PROCfinish:GOTO 16180
16150 result=left / right
16160 PROCfinish
16170 REM case 200 complete
16180 left=&80000000:right=-1
16190 opcode%=15:alias%=0
16200 PROCinputs
16210 status%=0
16220 ON ERROR status%=ERR:PROCfinish:GOTO 16260
16230 result=left / right
16240 PROCfinish
16250 REM case 201 complete
16260 left=&00FFFFFF:right=1
16270 opcode%=15:alias%=0
16280 PROCinputs
16290 status%=0
16300 ON ERROR status%=ERR:PROCfinish:GOTO 16340
16310 result=left / right
16320 PROCfinish
16330 REM case 202 complete
16340 left=65536:right=65536
16350 opcode%=15:alias%=0
16360 PROCinputs
16370 status%=0
16380 ON ERROR status%=ERR:PROCfinish:GOTO 16420
16390 result=left / right
16400 PROCfinish
16410 REM case 203 complete
16420 left=0.5:right=0.25
16430 opcode%=15:alias%=0
16440 PROCinputs
16450 status%=0
16460 ON ERROR status%=ERR:PROCfinish:GOTO 16500
16470 result=left / right
16480 PROCfinish
16490 REM case 204 complete
16500 left=1.5:right=2
16510 opcode%=15:alias%=0
16520 PROCinputs
16530 status%=0
16540 ON ERROR status%=ERR:PROCfinish:GOTO 16580
16550 result=left / right
16560 PROCfinish
16570 REM case 205 complete
16580 left=0.1:right=0.2
16590 opcode%=15:alias%=0
16600 PROCinputs
16610 status%=0
16620 ON ERROR status%=ERR:PROCfinish:GOTO 16660
16630 result=left / right
16640 PROCfinish
16650 REM case 206 complete
16660 left=1E38:right=10
16670 opcode%=15:alias%=0
16680 PROCinputs
16690 status%=0
16700 ON ERROR status%=ERR:PROCfinish:GOTO 16740
16710 result=left / right
16720 PROCfinish
16730 REM case 207 complete
16740 left=1E-38:right=100
16750 opcode%=15:alias%=0
16760 PROCinputs
16770 status%=0
16780 ON ERROR status%=ERR:PROCfinish:GOTO 16820
16790 result=left / right
16800 PROCfinish
16810 REM case 208 complete
16820 left=-0.5:right=0.25
16830 opcode%=15:alias%=0
16840 PROCinputs
16850 status%=0
16860 ON ERROR status%=ERR:PROCfinish:GOTO 16900
16870 result=left / right
16880 PROCfinish
16890 REM case 209 complete
16900 left=2:right=10
16910 opcode%=14:alias%=0
16920 PROCinputs
16930 status%=0
16940 ON ERROR status%=ERR:PROCfinish:GOTO 16980
16950 result=left ^ right
16960 PROCfinish
16970 REM case 210 complete
16980 left=-2:right=3
16990 opcode%=14:alias%=0
17000 PROCinputs
17010 status%=0
17020 ON ERROR status%=ERR:PROCfinish:GOTO 17060
17030 result=left ^ right
17040 PROCfinish
17050 REM case 211 complete
17060 left=0:right=0
17070 opcode%=14:alias%=0
17080 PROCinputs
17090 status%=0
17100 ON ERROR status%=ERR:PROCfinish:GOTO 17140
17110 result=left ^ right
17120 PROCfinish
17130 REM case 212 complete
17140 left=-2:right=0.5
17150 opcode%=14:alias%=0
17160 PROCinputs
17170 status%=0
17180 ON ERROR status%=ERR:PROCfinish:GOTO 17220
17190 result=left ^ right
17200 PROCfinish
17210 REM case 213 complete
17220 left=10:right=38
17230 opcode%=14:alias%=0
17240 PROCinputs
17250 status%=0
17260 ON ERROR status%=ERR:PROCfinish:GOTO 17300
17270 result=left ^ right
17280 PROCfinish
17290 REM case 214 complete
17300 left=10:right=39
17310 opcode%=14:alias%=0
17320 PROCinputs
17330 status%=0
17340 ON ERROR status%=ERR:PROCfinish:GOTO 17380
17350 result=left ^ right
17360 PROCfinish
17370 REM case 215 complete
17380 left=0.25:right=0.5
17390 opcode%=14:alias%=0
17400 PROCinputs
17410 status%=0
17420 ON ERROR status%=ERR:PROCfinish:GOTO 17460
17430 result=left ^ right
17440 PROCfinish
17450 REM case 216 complete
17460 left=0:right=0
17470 opcode%=38:alias%=0
17480 PROCinputs
17490 status%=0
17500 ON ERROR status%=ERR:PROCfinish:GOTO 17540
17510 converted%=left:result=converted%
17520 PROCfinish
17530 REM case 217 complete
17540 left=1:right=0
17550 opcode%=38:alias%=0
17560 PROCinputs
17570 status%=0
17580 ON ERROR status%=ERR:PROCfinish:GOTO 17620
17590 converted%=left:result=converted%
17600 PROCfinish
17610 REM case 218 complete
17620 left=-1:right=0
17630 opcode%=38:alias%=0
17640 PROCinputs
17650 status%=0
17660 ON ERROR status%=ERR:PROCfinish:GOTO 17700
17670 converted%=left:result=converted%
17680 PROCfinish
17690 REM case 219 complete
17700 left=3.9:right=0
17710 opcode%=38:alias%=0
17720 PROCinputs
17730 status%=0
17740 ON ERROR status%=ERR:PROCfinish:GOTO 17780
17750 converted%=left:result=converted%
17760 PROCfinish
17770 REM case 220 complete
17780 left=-3.9:right=0
17790 opcode%=38:alias%=0
17800 PROCinputs
17810 status%=0
17820 ON ERROR status%=ERR:PROCfinish:GOTO 17860
17830 converted%=left:result=converted%
17840 PROCfinish
17850 REM case 221 complete
17860 left=&7FFFFFFF:right=0
17870 opcode%=38:alias%=0
17880 PROCinputs
17890 status%=0
17900 ON ERROR status%=ERR:PROCfinish:GOTO 17940
17910 converted%=left:result=converted%
17920 PROCfinish
17930 REM case 222 complete
17940 left=&80000000:right=0
17950 opcode%=38:alias%=0
17960 PROCinputs
17970 status%=0
17980 ON ERROR status%=ERR:PROCfinish:GOTO 18020
17990 converted%=left:result=converted%
18000 PROCfinish
18010 REM case 223 complete
18020 left=2147483648.0:right=0
18030 opcode%=38:alias%=0
18040 PROCinputs
18050 status%=0
18060 ON ERROR status%=ERR:PROCfinish:GOTO 18100
18070 converted%=left:result=converted%
18080 PROCfinish
18090 REM case 224 complete
18100 left=1E38:right=0
18110 opcode%=38:alias%=0
18120 PROCinputs
18130 status%=0
18140 ON ERROR status%=ERR:PROCfinish:GOTO 18180
18150 converted%=left:result=converted%
18160 PROCfinish
18170 REM case 225 complete
18180 left=-1E38:right=0
18190 opcode%=38:alias%=0
18200 PROCinputs
18210 status%=0
18220 ON ERROR status%=ERR:PROCfinish:GOTO 18260
18230 converted%=left:result=converted%
18240 PROCfinish
18250 REM case 226 complete
18260 left=1E-38:right=0
18270 opcode%=38:alias%=0
18280 PROCinputs
18290 status%=0
18300 ON ERROR status%=ERR:PROCfinish:GOTO 18340
18310 converted%=left:result=converted%
18320 PROCfinish
18330 REM case 227 complete
18340 left=0:right=0
18350 opcode%=39:alias%=0
18360 PROCinputs
18370 status%=0
18380 ON ERROR status%=ERR:PROCfinish:GOTO 18420
18390 result=left/1
18400 PROCfinish
18410 REM case 228 complete
18420 left=1:right=0
18430 opcode%=39:alias%=0
18440 PROCinputs
18450 status%=0
18460 ON ERROR status%=ERR:PROCfinish:GOTO 18500
18470 result=left/1
18480 PROCfinish
18490 REM case 229 complete
18500 left=-1:right=0
18510 opcode%=39:alias%=0
18520 PROCinputs
18530 status%=0
18540 ON ERROR status%=ERR:PROCfinish:GOTO 18580
18550 result=left/1
18560 PROCfinish
18570 REM case 230 complete
18580 left=3.9:right=0
18590 opcode%=39:alias%=0
18600 PROCinputs
18610 status%=0
18620 ON ERROR status%=ERR:PROCfinish:GOTO 18660
18630 result=left/1
18640 PROCfinish
18650 REM case 231 complete
18660 left=-3.9:right=0
18670 opcode%=39:alias%=0
18680 PROCinputs
18690 status%=0
18700 ON ERROR status%=ERR:PROCfinish:GOTO 18740
18710 result=left/1
18720 PROCfinish
18730 REM case 232 complete
18740 left=&7FFFFFFF:right=0
18750 opcode%=39:alias%=0
18760 PROCinputs
18770 status%=0
18780 ON ERROR status%=ERR:PROCfinish:GOTO 18820
18790 result=left/1
18800 PROCfinish
18810 REM case 233 complete
18820 left=&80000000:right=0
18830 opcode%=39:alias%=0
18840 PROCinputs
18850 status%=0
18860 ON ERROR status%=ERR:PROCfinish:GOTO 18900
18870 result=left/1
18880 PROCfinish
18890 REM case 234 complete
18900 left=2147483648.0:right=0
18910 opcode%=39:alias%=0
18920 PROCinputs
18930 status%=0
18940 ON ERROR status%=ERR:PROCfinish:GOTO 18980
18950 result=left/1
18960 PROCfinish
18970 REM case 235 complete
18980 left=1E38:right=0
18990 opcode%=39:alias%=0
19000 PROCinputs
19010 status%=0
19020 ON ERROR status%=ERR:PROCfinish:GOTO 19060
19030 result=left/1
19040 PROCfinish
19050 REM case 236 complete
19060 left=-1E38:right=0
19070 opcode%=39:alias%=0
19080 PROCinputs
19090 status%=0
19100 ON ERROR status%=ERR:PROCfinish:GOTO 19140
19110 result=left/1
19120 PROCfinish
19130 REM case 237 complete
19140 left=1E-38:right=0
19150 opcode%=39:alias%=0
19160 PROCinputs
19170 status%=0
19180 ON ERROR status%=ERR:PROCfinish:GOTO 19220
19190 result=left/1
19200 PROCfinish
19210 REM case 238 complete
19220 left=-7:right=-7
19230 opcode%=10:alias%=1
19240 PROCinputs
19250 status%=0
19260 ON ERROR status%=ERR:PROCfinish:GOTO 19300
19270 result=left * right
19280 PROCfinish
19290 REM case 239 complete
19300 left=0.1:right=0.1
19310 opcode%=10:alias%=1
19320 PROCinputs
19330 status%=0
19340 ON ERROR status%=ERR:PROCfinish:GOTO 19380
19350 result=left * right
19360 PROCfinish
19370 REM case 240 complete
19380 left=-7:right=-7
19390 opcode%=11:alias%=1
19400 PROCinputs
19410 status%=0
19420 ON ERROR status%=ERR:PROCfinish:GOTO 19460
19430 result=left + right
19440 PROCfinish
19450 REM case 241 complete
19460 left=0.1:right=0.1
19470 opcode%=11:alias%=1
19480 PROCinputs
19490 status%=0
19500 ON ERROR status%=ERR:PROCfinish:GOTO 19540
19510 result=left + right
19520 PROCfinish
19530 REM case 242 complete
19540 left=-7:right=-7
19550 opcode%=13:alias%=1
19560 PROCinputs
19570 status%=0
19580 ON ERROR status%=ERR:PROCfinish:GOTO 19620
19590 result=left - right
19600 PROCfinish
19610 REM case 243 complete
19620 left=0.1:right=0.1
19630 opcode%=13:alias%=1
19640 PROCinputs
19650 status%=0
19660 ON ERROR status%=ERR:PROCfinish:GOTO 19700
19670 result=left - right
19680 PROCfinish
19690 REM case 244 complete
19700 left=-7:right=-7
19710 opcode%=15:alias%=1
19720 PROCinputs
19730 status%=0
19740 ON ERROR status%=ERR:PROCfinish:GOTO 19780
19750 result=left / right
19760 PROCfinish
19770 REM case 245 complete
19780 left=0.1:right=0.1
19790 opcode%=15:alias%=1
19800 PROCinputs
19810 status%=0
19820 ON ERROR status%=ERR:PROCfinish:GOTO 19860
19830 result=left / right
19840 PROCfinish
19850 REM case 246 complete
19860 left=16777216.0:right=1
19870 opcode%=11:alias%=0
19880 PROCinputs
19890 status%=0
19900 ON ERROR status%=ERR:PROCfinish:GOTO 19940
19910 result=left + right
19920 PROCfinish
19930 REM case 247 complete
19940 left=2147483648.0:right=1
19950 opcode%=11:alias%=0
19960 PROCinputs
19970 status%=0
19980 ON ERROR status%=ERR:PROCfinish:GOTO 20020
19990 result=left + right
20000 PROCfinish
20010 REM case 248 complete
20020 left=2147483648.0*2:right=1
20030 opcode%=11:alias%=0
20040 PROCinputs
20050 status%=0
20060 ON ERROR status%=ERR:PROCfinish:GOTO 20100
20070 result=left + right
20080 PROCfinish
20090 REM case 249 complete
20100 left=2147483648.0*2:right=3
20110 opcode%=11:alias%=0
20120 PROCinputs
20130 status%=0
20140 ON ERROR status%=ERR:PROCfinish:GOTO 20180
20150 result=left + right
20160 PROCfinish
20170 REM case 250 complete
20180 left=7:right=3
20190 opcode%=16:alias%=0
20200 PROCinputs
20210 status%=0
20220 ON ERROR status%=ERR:PROCfinish:GOTO 20260
20230 status%=1:result=left
20240 PROCfinish
20250 REM case 251 complete
20260 left=7:right=3
20270 opcode%=35:alias%=0
20280 PROCinputs
20290 status%=0
20300 ON ERROR status%=ERR:PROCfinish:GOTO 20340
20310 status%=1:result=left
20320 PROCfinish
20330 REM case 252 complete
20340 left=7:right=3
20350 opcode%=36:alias%=0
20360 PROCinputs
20370 status%=0
20380 ON ERROR status%=ERR:PROCfinish:GOTO 20420
20390 status%=1:result=left
20400 PROCfinish
20410 REM case 253 complete
20420 left=7:right=3
20430 opcode%=37:alias%=0
20440 PROCinputs
20450 status%=0
20460 ON ERROR status%=ERR:PROCfinish:GOTO 20500
20470 status%=1:result=left
20480 PROCfinish
20490 REM case 254 complete
20500 left=7:right=3
20510 opcode%=40:alias%=0
20520 PROCinputs
20530 status%=0
20540 ON ERROR status%=ERR:PROCfinish:GOTO 20580
20550 status%=1:result=left
20560 PROCfinish
20570 REM case 255 complete
20580 left=7:right=3
20590 opcode%=255:alias%=0
20600 PROCinputs
20610 status%=0
20620 ON ERROR status%=ERR:PROCfinish:GOTO 20660
20630 status%=1:result=left
20640 PROCfinish
20650 REM case 256 complete
20660 CLOSE#ch%:PRINT "REFERENCE_DONE":OSCLI "BYE"
50000 DEF PROCinputs
50010 LOCAL i%,p%
50020 BPUT#ch%,opcode%:BPUT#ch%,alias%
50030 p%=^left:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
50040 p%=^right:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
50050 ENDPROC
50100 DEF PROCfinish
50110 LOCAL i%,p%
50120 BPUT#ch%,status%
50130 IF status%=0 THEN p%=^result ELSE p%=^left
50140 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
50150 ENDPROC
