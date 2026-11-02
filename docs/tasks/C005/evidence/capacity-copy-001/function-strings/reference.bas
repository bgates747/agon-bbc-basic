10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 PRINT LEFT$(FNletters);":";LEFT$(FNletters,2);":";RIGHT$(FNletters,2)
140 PRINT MID$(FNletters,2);":";MID$(FNletters,0);":";MID$(FNletters,2,3)
150 PRINT ;LEN FNletters;":";ASC FNletters;":";VAL FNdigits;":";INSTR(FNletters,FNneedle)
160 PRINT ;INSTR(FNletters,FNneedle,FNcount);":";(FNletters="ABCDEF");":";("ABCDEF"=FNletters)
170 PRINT ;ASC LEFT$(FNbytes);":";ASC MID$(FNbytes,0,1);":";ASC RIGHT$(FNbytes,1)
180 PRINT "["+LEFT$(FNletters)+"]";":";STRING$(2,STR$ FNnumber)
190 PRINT "REF_END_0"
200 CLEAR
210 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
220 PRINT "REF_BEGIN_1"
230 s$="abcdef":MID$(s$,2,3)=FNchange:PRINT s$
240 s$="abcdef":MID$(s$,FNstart,2)="XY":PRINT s$
250 s$="abcdef":guard$="guard":MID$(s$,2,2)=FNreallocate:PRINT s$;":";guard$
260 PRINT "REF_END_1"
270 CLEAR
280 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
290 PRINT "REF_BEGIN_2"
300 PROCerror2
310 PRINT "REF_END_2"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DEF FNletters="ABCDEF"
40001 DEF FNneedle="CD"
40002 DEF FNdigits="12.5"
40003 DEF FNcount:scratch$="changed":=2
40004 DEF FNbytes=CHR$(0)+CHR$(128)+CHR$(255)
40005 DEF FNnumber=3
40100 DEF FNchange:s$="1234":="XY"
40101 DEF FNstart:s$="12":=2
40102 DEF FNreallocate:s$=STRING$(12,"q"):="YZ"
40200 DEF FNcreate:missing$="new":PRINT "called":="x"
10200 DEF PROCerror2:LOCAL ERROR
10201 ON ERROR LOCAL REPORT:PRINT:ENDPROC
10202 MID$(missing$,1)=FNcreate
10290 ENDPROC
