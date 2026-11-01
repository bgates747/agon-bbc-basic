10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 ch%=OPENOUT("expr-oracle.dat")
100 byte%=65-((-7 MOD 3)=(-1)):BPUT#ch%,byte%
110 byte%=65-((7 MOD -3)=(1)):BPUT#ch%,byte%
120 byte%=65-((1 OR 2 EOR 3)=(0)):BPUT#ch%,byte%
130 byte%=65-((1 EOR 2 OR 4)=(7)):BPUT#ch%,byte%
140 byte%=65-((1 OR 2 AND 0)=(1)):BPUT#ch%,byte%
150 byte%=65-((NOT 1)=(-2)):BPUT#ch%,byte%
160 byte%=65-((NOT (7/2))=(-4)):BPUT#ch%,byte%
170 byte%=65-((TRUE)=(-1)):BPUT#ch%,byte%
180 byte%=65-((FALSE)=(0)):BPUT#ch%,byte%
190 byte%=65-((1<2)=(TRUE)):BPUT#ch%,byte%
200 byte%=65-((2>1)=(TRUE)):BPUT#ch%,byte%
210 byte%=65-((2<=2)=(TRUE)):BPUT#ch%,byte%
5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"
