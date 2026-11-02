10 REM Independent exact decimal fixtures: decimal digit strings, not CON/VAL.
20 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"
30 ch%=OPENOUT("literal-generated.tsv")
40 FOR row%=1 TO 10
50 READ coefficient$,payload$,bits%
60 FOR index%=0 TO 10
70 exponent%=-127:IF index%>0 exponent%=-126
80 IF index%=2 exponent%=-100
90 IF index%=3 exponent%=-1
100 IF index%=4 exponent%=0
110 IF index%=5 exponent%=1
120 IF index%=6 exponent%=30
130 IF index%=7 exponent%=31
140 IF index%=8 exponent%=32
150 IF index%=9 exponent%=100
160 IF index%=10 exponent%=127
170 shift%=exponent%-bits%:digits$=coefficient$
180 multiplier%=2:IF shift%<0 multiplier%=5
190 IF shift%<>0 THEN FOR step%=1 TO ABS(shift%):PROCtimes(multiplier%):NEXT
200 literal$=digits$+".0":IF shift%<0 literal$=literal$+"E-"+STR$(0-shift%)
210 line$=literal$+"|"+payload$+FNhexbyte(exponent%+128)
220 FOR i%=1 TO LEN(line$):BPUT#ch%,ASC(MID$(line$,i%,1)):NEXT:BPUT#ch%,10
230 NEXT:NEXT
240 CLOSE#ch%:PRINT "LITERAL_GENERATION_DONE":OSCLI "BYE"
1000 DEF PROCtimes(multiplier%)
1010 LOCAL i%,carry%,digit%,result$
1020 carry%=0:result$=""
1030 FOR i%=LEN(digits$) TO 1 STEP -1
1040 digit%=(ASC(MID$(digits$,i%,1))-48)*multiplier%+carry%
1050 result$=CHR$(48+digit% MOD 10)+result$:carry%=digit% DIV 10
1060 NEXT
1070 IF carry% result$=CHR$(48+carry%)+result$
1080 digits$=result$:ENDPROC
1100 DEF FNhexbyte(v%)
1110 =MID$("0123456789ABCDEF",v% DIV 16+1,1)+MID$("0123456789ABCDEF",v% MOD 16+1,1)
2000 DATA "2147483648","00000000",31
2010 DATA "2147483649","01000000",31
2020 DATA "2147483650","02000000",31
2030 DATA "3221225472","00000040",31
2040 DATA "4294967294","FEFFFF7F",31
2050 DATA "4294967295","FFFFFF7F",31
2060 DATA "4294967297","01000000",32
2070 DATA "4294967299","01000000",32
2080 DATA "8589934589","FFFFFF7F",32
2090 DATA "8589934591","FFFFFF7F",32
