10 defaultleft$="abcdef":LEFT$(defaultleft$)="XYZ"
20 rightshort$="abcdef":RIGHT$(rightshort$,5)="XY"
30 midzero$="abcdef":MID$(midzero$,0,2)="YZ"
40 lastmarker$=STRING$(255,"x"):MID$(lastmarker$,255,2)="YZ"
50 clamped$=STRING$(255,"x"):MID$(clamped$,255,3)="YZ"
60 allbutlast$=STRING$(255,"x"):MID$(allbutlast$,2,255)=STRING$(255,"z")
70 alias$="abcdef":MID$(alias$,2,3)=alias$
80 bytes$=CHR$(0)+CHR$(128)+CHR$(255):copy$=bytes$
90 MID$(bytes$,2,1)=CHR$(0):LEFT$(bytes$,1)=CHR$(128)
100 empty$="":RIGHT$(empty$,3)=CHR$(255)
110 nop$="abc":LEFT$(nop$,0)=STRING$(1,"Y")
120 length%=LEN allbutlast$:first%=ASC bytes$:last%=ASC RIGHT$(clamped$)
900 GOTO 1000
910 PRINT missing$
1000 PROCcapture:OSCLI "BYE"
2000 DEF PROCcapture:LOCAL ch%,p%,q%,i%,n%
2010 ch%=OPENOUT("string-expected.dat")
2020 p%=^defaultleft$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2030 p%=^rightshort$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2040 p%=^midzero$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2050 p%=^lastmarker$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2060 p%=^clamped$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2070 p%=^allbutlast$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2080 p%=^alias$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2090 p%=^bytes$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2100 p%=^copy$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2110 p%=^empty$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2120 p%=^nop$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
3000 p%=^length%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
3010 p%=^first%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
3020 p%=^last%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
4000 CLOSE#ch%:PRINT "STRING_STORAGE_REFERENCE_DONE":ENDPROC
