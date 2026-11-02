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
5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"
