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
1000 END
