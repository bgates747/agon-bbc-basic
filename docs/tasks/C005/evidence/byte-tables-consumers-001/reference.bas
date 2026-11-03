10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 text$="outer":PROCouter:PRINT text$
140 value=1.5:whole%=-7:byte&=255:s$="old":PROCtypes(2.5,9.9,257,"new"):PRINT ;value;":";whole%;":";byte&;":";s$
150 copy$="original":PROCslice(copy$):PRINT copy$
160 PROCrecursive(4):PRINT ;n%
170 PRINT "REF_END_0"
180 CLEAR
190 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
200 PRINT "REF_BEGIN_1"
210 PRINT LEFT$(FNletters);":";LEFT$(FNletters,2);":";RIGHT$(FNletters,2)
220 PRINT MID$(FNletters,2);":";MID$(FNletters,0);":";MID$(FNletters,2,3)
230 PRINT ;LEN FNletters;":";ASC FNletters;":";VAL FNdigits;":";INSTR(FNletters,FNneedle)
240 PRINT ;INSTR(FNletters,FNneedle,FNcount);":";(FNletters="ABCDEF");":";("ABCDEF"=FNletters)
250 PRINT ;ASC LEFT$(FNbytes);":";ASC MID$(FNbytes,0,1);":";ASC RIGHT$(FNbytes,1)
260 PRINT "["+LEFT$(FNletters)+"]";":";STRING$(2,STR$ FNnumber)
270 PRINT "REF_END_1"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DEF PROCouter:LOCAL text$:text$="inner":PROCsee:ENDPROC
40001 DEF PROCsee:PRINT text$:ENDPROC
40002 DEF PROCtypes(value,whole%,byte&,s$):PRINT ;value;":";whole%;":";byte&;":";s$:ENDPROC
40003 DEF PROCslice(s$):MID$(s$,2,2)="XY":PRINT s$:ENDPROC
40004 DEF PROCrecursive(n%):PRINT ;n%:IF n%>0 THEN PROCrecursive(n%-1)
40005 ENDPROC
40100 DEF FNletters="ABCDEF"
40101 DEF FNneedle="CD"
40102 DEF FNdigits="12.5"
40103 DEF FNcount:scratch$="changed":=2
40104 DEF FNbytes=CHR$(0)+CHR$(128)+CHR$(255)
40105 DEF FNnumber=3
