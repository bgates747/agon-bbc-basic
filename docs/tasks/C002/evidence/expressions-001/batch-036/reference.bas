10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 ch%=OPENOUT("expr-oracle.dat")
100 byte%=65-((65536*65536)=(2147483648*2)):BPUT#ch%,byte%
110 byte%=65-((16777216.0+1)=(16777217)):BPUT#ch%,byte%
120 byte%=65-((2147483648.0+1)=(2147483649)):BPUT#ch%,byte%
130 byte%=65-(((2147483648.0*2)+1)=((2147483648.0*2)+2)):BPUT#ch%,byte%
140 byte%=65-(((2147483648.0*2)+3)=((2147483648.0*2)+2)):BPUT#ch%,byte%
150 byte%=65-((4294967295)=((2147483648.0*2)-1)):BPUT#ch%,byte%
160 byte%=65-((2147483648.0*2)=(2147483648.0*2)):BPUT#ch%,byte%
170 byte%=65-((1/2+1/4)=(3/4)):BPUT#ch%,byte%
180 byte%=65-((-1/2)=(0-1/2)):BPUT#ch%,byte%
190 byte%=65-((1DIV2)=(0)):BPUT#ch%,byte%
200 byte%=65-((1AND2)=(0)):BPUT#ch%,byte%
210 byte%=65-((2147483648.0*2)=(2147483648.0*2)):BPUT#ch%,byte%
5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"
