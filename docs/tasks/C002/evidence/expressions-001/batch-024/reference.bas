10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 ch%=OPENOUT("expr-oracle.dat")
100 byte%=65-((2>=2)=(TRUE)):BPUT#ch%,byte%
110 byte%=65-((2<>3)=(TRUE)):BPUT#ch%,byte%
120 byte%=65-((2=3)=(FALSE)):BPUT#ch%,byte%
130 byte%=65-((1<2 AND 3>2)=(TRUE)):BPUT#ch%,byte%
140 byte%=65-((&FFFFFF)=(16777215)):BPUT#ch%,byte%
150 byte%=65-((&1000000)=(16777216)):BPUT#ch%,byte%
160 byte%=65-((&7FFFFFFF)=(2147483647)):BPUT#ch%,byte%
170 byte%=65-((&80000000)=(-2147483648)):BPUT#ch%,byte%
180 byte%=65-((&FFFFFFFF)=(-1)):BPUT#ch%,byte%
190 byte%=65-((-&80000000)=(&80000000)):BPUT#ch%,byte%
200 byte%=65-((&7FFFFFFF+1)=(2147483648)):BPUT#ch%,byte%
210 byte%=65-((&80000000-1)=(-2147483649)):BPUT#ch%,byte%
5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"
