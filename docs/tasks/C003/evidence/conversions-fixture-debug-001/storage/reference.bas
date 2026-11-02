10 empty$=STR$(0)
20 zero$=STR$ ASC CHR$(0)
30 third$=STR$(1/3)
40 large$=STR$(1E38)
50 small$=STR$(1E-38)
60 negative$=STR$(-1/3)
70 hexzero$=STR$~0
80 hexmax$=STR$~&FFFFFFFF
90 hexmin$=STR$~&80000000
100 nested$=STR$ VAL "12.5"
110 left$="                                                                                                                                "
120 right$="                                                                                                                             12"
130 maximum$=left$+right$
140 copy$=nested$
150 nested$=STR$~(-12.9)
160 value0=VAL("0")
170 value1=VAL("-0")
180 value2=VAL("1.0")
190 value3=VAL("-1.0")
200 value4=VAL("2147483647")
210 value5=VAL("2147483648")
220 value6=VAL("4294967295")
230 value7=VAL("4294967296")
240 value8=VAL("-2147483648")
250 value9=VAL("1.234567890123456789")
260 value10=VAL("1E-38")
270 value11=VAL("1E-99")
280 value12=VAL("1E 2")
290 value13=VAL("1E+ 2")
300 value14=VAL("1e2")
310 value15=VAL("&FF")
320 value16=VAL("words")
330 maximumval=VAL maximum$
340 nulval=VAL("12"+CHR$(0)+"34")
350 asempty%=ASC ""
360 ashigh%=ASC CHR$(255)
370 asnul%=ASC CHR$(0)
900 GOTO 1000
910 PRINT missing$
1000 PROCcapture:OSCLI "BYE"
2000 DEF PROCcapture:LOCAL ch%,p%,q%,i%,n%
2010 ch%=OPENOUT("string-expected.dat")
2020 p%=^empty$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2030 p%=^zero$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2040 p%=^third$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2050 p%=^large$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2060 p%=^small$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2070 p%=^negative$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2080 p%=^hexzero$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2090 p%=^hexmax$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2100 p%=^hexmin$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2110 p%=^nested$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2120 p%=^left$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2130 p%=^right$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2140 p%=^maximum$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2150 p%=^copy$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
3000 p%=^value0:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3010 p%=^value1:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3020 p%=^value2:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3030 p%=^value3:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3040 p%=^value4:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3050 p%=^value5:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3060 p%=^value6:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3070 p%=^value7:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3080 p%=^value8:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3090 p%=^value9:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3100 p%=^value10:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3110 p%=^value11:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3120 p%=^value12:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3130 p%=^value13:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3140 p%=^value14:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3150 p%=^value15:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3160 p%=^value16:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3170 p%=^maximumval:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3180 p%=^nulval:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3190 p%=^asempty%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
3200 p%=^ashigh%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
3210 p%=^asnul%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
4000 CLOSE#ch%:PRINT "STRING_STORAGE_REFERENCE_DONE":ENDPROC
