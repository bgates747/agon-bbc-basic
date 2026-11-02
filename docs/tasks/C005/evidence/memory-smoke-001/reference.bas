10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 DIM a%(1,2),b&(2),x(1),s$(1),mem% 15
140 PRINT ;a%(0,0);":";b&(2);":";x(1);":";LEN s$(1)
150 a%(1,2)=-123:b&(2)=257:x(1)=1/3:s$(1)="ABC"
160 PRINT ;a%(1,2);":";b&(2);":";x(1)=1/3;":";LEN s$(1)
170 PRINT ;^a%(0,1)-^a%(0,0);":";^a%(1,0)-^a%(0,0)
180 PRINT ;^b&(1)-^b&(0);":";^x(1)-^x(0);":";^s$(1)-^s$(0)
190 mem%?0=17:!(mem%+4)=-77:|(mem%+9)=1/3
200 PRINT ;?mem%;":";mem%!(4);":";|(mem%+9)=1/3
210 copy$=s$(1):s$(1)="changed":PRINT copy$;":";s$(1)
220 PRINT ;FNtouch(1);":";a%(1,2)
230 PRINT "REF_END_0"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DEF FNtouch(i%):a%(i%,2)=a%(i%,2)+1:=a%(i%,2)
