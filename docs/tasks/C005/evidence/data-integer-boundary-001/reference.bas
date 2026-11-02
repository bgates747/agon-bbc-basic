10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 RESTORE 40000
140 READ a%,b&,x,y,z:PRINT ;a%;":";b&;":";x;":";y;":";z
150 PRINT ;?(^x+4);":";?(^y+4);":";?(^z+4)
160 READ s$,t$,u$,v$,w$:PRINT ;LEN s$;":";s$;":";t$;":";u$;":";v$;":";LEN w$
170 RESTORE 40000:READ a%:PRINT ;a%:RESTORE 40001:READ s$:PRINT s$
180 PRINT "REF_END_0"
190 CLEAR
200 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
210 PRINT "REF_BEGIN_1"
220 RESTORE 40100
230 DIM a%(1),b&(1),x(1),s$(1)
240 READ a%(0),b&(0),x(0),s$(0):READ a%(1),b&(1),x(1),s$(1)
250 PRINT ;a%(0);":";b&(0);":";x(0);":";s$(0)
260 PRINT ;a%(1);":";b&(1);":";x(1);":";LEN s$(1)
270 s$(0)="changed":PRINT ;LEN s$(1)
280 PRINT "REF_END_1"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DATA -123,257,1.0,1E-3,&FFFFFFFF
40001 DATA  leading and trailing  ,"a,b:c","a""b", 123  ,""
40100 DATA -2147483648,257,1E-20,"first",2147483647,-1,.0,"last"
