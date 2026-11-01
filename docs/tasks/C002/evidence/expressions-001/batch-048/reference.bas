10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 ch%=OPENOUT("expr-oracle.dat")
100 byte%=65:BPUT#ch%,byte%
110 byte%=321:BPUT#ch%,byte%
120 byte%=-191:BPUT#ch%,byte%
130 byte%=131/2:BPUT#ch%,byte%
140 byte%=-381/2+256:BPUT#ch%,byte%
5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"
