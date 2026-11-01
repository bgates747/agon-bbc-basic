10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 ch%=OPENOUT("expr-oracle.dat")
100 byte%=65-((1+2*3)=(7)):BPUT#ch%,byte%
110 byte%=65-(((1+2)*3)=(9)):BPUT#ch%,byte%
120 byte%=65-((10-3-2)=(5)):BPUT#ch%,byte%
130 byte%=65-((2^3^2)=(64)):BPUT#ch%,byte%
140 byte%=65-((-2^2)=(4)):BPUT#ch%,byte%
150 byte%=65-((-(2^2))=(-4)):BPUT#ch%,byte%
160 byte%=65-((2^-2)=(1/4)):BPUT#ch%,byte%
170 byte%=65-((--7)=(7)):BPUT#ch%,byte%
180 byte%=65-((+-7)=(-7)):BPUT#ch%,byte%
190 byte%=65-((7 DIV 3)=(2)):BPUT#ch%,byte%
200 byte%=65-((-7 DIV 3)=(-2)):BPUT#ch%,byte%
210 byte%=65-((7 DIV -3)=(-2)):BPUT#ch%,byte%
220 byte%=65-((-7 MOD 3)=(-1)):BPUT#ch%,byte%
230 byte%=65-((7 MOD -3)=(1)):BPUT#ch%,byte%
240 byte%=65-((1 OR 2 EOR 3)=(0)):BPUT#ch%,byte%
250 byte%=65-((1 EOR 2 OR 4)=(7)):BPUT#ch%,byte%
260 byte%=65-((1 OR 2 AND 0)=(1)):BPUT#ch%,byte%
270 byte%=65-((NOT 1)=(-2)):BPUT#ch%,byte%
280 byte%=65-((NOT (7/2))=(-4)):BPUT#ch%,byte%
290 byte%=65-((TRUE)=(-1)):BPUT#ch%,byte%
300 byte%=65-((FALSE)=(0)):BPUT#ch%,byte%
310 byte%=65-((1<2)=(TRUE)):BPUT#ch%,byte%
320 byte%=65-((2>1)=(TRUE)):BPUT#ch%,byte%
330 byte%=65-((2<=2)=(TRUE)):BPUT#ch%,byte%
340 byte%=65-((2>=2)=(TRUE)):BPUT#ch%,byte%
350 byte%=65-((2<>3)=(TRUE)):BPUT#ch%,byte%
360 byte%=65-((2=3)=(FALSE)):BPUT#ch%,byte%
370 byte%=65-((1<2 AND 3>2)=(TRUE)):BPUT#ch%,byte%
380 byte%=65-((&FFFFFF)=(16777215)):BPUT#ch%,byte%
390 byte%=65-((&1000000)=(16777216)):BPUT#ch%,byte%
400 byte%=65-((&7FFFFFFF)=(2147483647)):BPUT#ch%,byte%
410 byte%=65-((&80000000)=(-2147483648)):BPUT#ch%,byte%
420 byte%=65-((&FFFFFFFF)=(-1)):BPUT#ch%,byte%
430 byte%=65-((-&80000000)=(&80000000)):BPUT#ch%,byte%
440 byte%=65-((&7FFFFFFF+1)=(2147483648)):BPUT#ch%,byte%
450 byte%=65-((&80000000-1)=(-2147483649)):BPUT#ch%,byte%
460 byte%=65-((65536*65536)=(2147483648*2)):BPUT#ch%,byte%
470 byte%=65-((16777216.0+1)=(16777217)):BPUT#ch%,byte%
480 byte%=65-((2147483648.0+1)=(2147483649)):BPUT#ch%,byte%
490 byte%=65-(((2147483648.0*2)+1)=((2147483648.0*2)+2)):BPUT#ch%,byte%
500 byte%=65-(((2147483648.0*2)+3)=((2147483648.0*2)+2)):BPUT#ch%,byte%
510 byte%=65-((4294967295)=((2147483648.0*2)-1)):BPUT#ch%,byte%
520 byte%=65-((4294967296)=(2147483648.0*2)):BPUT#ch%,byte%
530 byte%=65-((1/2+1/4)=(3/4)):BPUT#ch%,byte%
540 byte%=65-((-1/2)=(0-1/2)):BPUT#ch%,byte%
550 byte%=65-((1DIV2)=(0)):BPUT#ch%,byte%
560 byte%=65-((1AND2)=(0)):BPUT#ch%,byte%
570 byte%=65-((2147483648.0*2)=(2147483648.0*2)):BPUT#ch%,byte%
580 byte%=65:BPUT#ch%,byte%
590 byte%=321:BPUT#ch%,byte%
600 byte%=-191:BPUT#ch%,byte%
610 byte%=131/2:BPUT#ch%,byte%
620 byte%=-381/2+256:BPUT#ch%,byte%
5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"
