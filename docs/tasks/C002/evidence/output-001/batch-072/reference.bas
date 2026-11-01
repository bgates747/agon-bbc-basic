10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 ch%=OPENOUT("expr-oracle.dat")
170 byte%=65-(1.00=1.0):BPUT#ch%,byte%
180 byte%=65-(0.0=FALSE):BPUT#ch%,byte%
190 byte%=65-((1<2)=(2<3)):BPUT#ch%,byte%
200 byte%=65-((-(1/2))=(0-1/2)):BPUT#ch%,byte%
210 byte%=65-((+(1/2))=(1/2)):BPUT#ch%,byte%
5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"
