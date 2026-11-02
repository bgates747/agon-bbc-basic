10 pattern$=CHR$(0)+CHR$(128)+CHR$(255)
20 repeated$=STRING$(3,pattern$)
30 full$=STRING$(85,pattern$)
40 empty$=STRING$(0,pattern$)
50 wrapped$=STRING$(257,"ab")
60 negative$=STRING$(-1,"x")
70 fraction$=STRING$(2.9,"ab")
80 nested$=STRING$(2,STRING$(3,"xy"))
90 copy$=repeated$
100 repeated$=STRING$(2,"q")
110 created$=STRING$(2,created$+"z")
120 text$=STRING$(3,"12")
130 converted$=STR$ INSTR("abc","b")
140 result0=INSTR(full$,pattern$)
150 result1=INSTR(full$,pattern$,2)
160 result2=INSTR(full$,pattern$,253)
170 result3=INSTR(full$,pattern$,254)
180 result4=INSTR(full$,CHR$(255),255)
190 result5=INSTR(full$,"")
200 result6=INSTR("",pattern$)
210 result7=INSTR(negative$,"x",-1)
220 result8=INSTR(negative$,"x",256)
230 result9=INSTR("aaaaab","aaab")
240 result10=INSTR("abc","z")
250 result11=INSTR(nested$,"xy",INSTR("123","2"))
260 result12=VAL text$
270 position%=INSTR(full$,CHR$(255),255)
280 byte&=INSTR(full$,CHR$(255),255)
290 length%=LEN full$
900 GOTO 1000
910 PRINT missing$
1000 PROCcapture:OSCLI "BYE"
2000 DEF PROCcapture:LOCAL ch%,p%,q%,i%,n%
2010 ch%=OPENOUT("string-expected.dat")
2020 p%=^pattern$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2030 p%=^repeated$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2040 p%=^full$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2050 p%=^empty$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2060 p%=^wrapped$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2070 p%=^negative$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2080 p%=^fraction$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2090 p%=^nested$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2100 p%=^copy$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2110 p%=^created$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2120 p%=^text$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2130 p%=^converted$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
3000 p%=^result0:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3010 p%=^result1:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3020 p%=^result2:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3030 p%=^result3:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3040 p%=^result4:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3050 p%=^result5:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3060 p%=^result6:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3070 p%=^result7:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3080 p%=^result8:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3090 p%=^result9:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3100 p%=^result10:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3110 p%=^result11:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3120 p%=^result12:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
3130 p%=^position%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
3140 p%=^byte&:FOR i%=0 TO 0:BPUT#ch%,p%?i%:NEXT
3150 p%=^length%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
4000 CLOSE#ch%:PRINT "STRING_STORAGE_REFERENCE_DONE":ENDPROC
