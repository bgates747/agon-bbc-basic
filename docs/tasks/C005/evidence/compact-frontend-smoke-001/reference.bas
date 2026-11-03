10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 a%=7:b&=257:c=2.75
140 PRINT ;a%;":";b&;":";c;":";(a%+b&)*(c-1)
150 a%=c:b&=-1:c=a%+0.5:PRINT ;a%;":";b&;":";c
160 PRINT "REF_END_0"
170 CLEAR
180 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
190 PRINT "REF_BEGIN_1"
200 DIM a%(1,1),b&(1),f(1),s$(1)
210 a%(1,1)=-123:b&(1)=257:f(1)=2.75:s$(1)="array"
220 PRINT ;a%(1,1);":";b&(1);":";f(1);":";s$(1)
230 PRINT "REF_END_1"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
