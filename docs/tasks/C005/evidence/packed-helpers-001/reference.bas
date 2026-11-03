10 ON ERROR REPORT:PRINT:OSCLI "BYE"
20 @%=&90A
100 CLEAR
110 A%=0:B%=0:C%=0:D%=0:E%=0:F%=0:G%=0:H%=0:I%=0:J%=0:K%=0:L%=0:M%=0:N%=0:O%=0:P%=0:Q%=0:R%=0:S%=0:T%=0:U%=0:V%=0:W%=0:X%=0:Y%=0:Z%=0
120 PRINT "REF_BEGIN_0"
130 DIM addrbuf% 12289,sortbuf% 8193,lrefs%(63),saved%(63)
140 saddr%=addrbuf%+1:sort%=sortbuf%+1
150 addrbuf%?0=&A5:addrbuf%?12289=&A5:sortbuf%?0=&A5:sortbuf%?8193=&A5
160 FOR i%=0 TO 4095
170 v%=i%*173:IF i%=4095 v%=&B0000
180 PROCsymboladdr(i%,v%):PROCsortindex(i%,4095-i%)
190 NEXT
200 FOR i%=0 TO 4095
210 v%=i%*173:IF i%=4095 v%=&B0000
220 IF FNsymboladdr(i%)<>v% ERROR 100,"address cell"
230 IF FNsortindex(i%)<>4095-i% ERROR 100,"sorted cell"
240 NEXT
250 IF addrbuf%?0<>&A5 OR addrbuf%?12289<>&A5 ERROR 100,"address guard"
260 IF sortbuf%?0<>&A5 OR sortbuf%?8193<>&A5 ERROR 100,"sorted guard"
270 FOR i%=0 TO 63
280 IF lrefs%(i%)<>0 ERROR 100,"page initialization"
290 n%=(i% MOD 32)*2048+2047:IF i% MOD 32=31 n%=65279
300 IF FNlineref(n%,i% DIV 32,FALSE) ERROR 100,"absent page"
310 IF NOT FNlineref(n%,i% DIV 32,TRUE) ERROR 100,"page write"
320 IF NOT FNlineref(n%,i% DIV 32,FALSE) ERROR 100,"page read"
330 saved%(i%)=lrefs%(i%)
340 IF i%<32 THEN IF FNlineref(n%,1,FALSE) ERROR 100,"branch data separation"
350 NEXT
360 IF FNlineref(2048,0,FALSE) OR FNlineref(2048,1,FALSE) ERROR 100,"unwritten boundary bit"
370 IF NOT FNlineref(2048,0,TRUE) ERROR 100,"first bit of next page"
380 IF FNlineref(2048,1,FALSE) ERROR 100,"boundary data separation"
390 PROCclearrefs
400 FOR i%=0 TO 63
410 IF saved%(i%)<>lrefs%(i%) ERROR 100,"page reuse"
420 n%=(i% MOD 32)*2048+2047:IF i% MOD 32=31 n%=65279
430 IF FNlineref(n%,i% DIV 32,FALSE) ERROR 100,"page clearing"
440 IF NOT FNlineref(n%,i% DIV 32,TRUE) ERROR 100,"page rewrite"
450 IF saved%(i%)<>lrefs%(i%) ERROR 100,"page leaked"
460 NEXT
470 PROCclearrefs
480 IF FNlineref(2047,0,FALSE) OR FNlineref(2048,0,FALSE) OR FNlineref(65279,1,FALSE) ERROR 100,"second clear"
490 PRINT "4096 packed cells and 64 reusable pages"
500 PRINT "REF_END_0"
9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"
40000 DEF FNlineref(n%,m%,w%)
40001 LOCAL i%,b%,p%:p%=FNrefpage(n% DIV 2048+32*m%,w%):IF p%=0 THEN =FALSE
40002 i%=(n% DIV 8) AND 255:b%=2^(n% AND 7)
40003 IF w% p%?i%=p%?i% OR b%
40004 =(p%?i% AND b%)<>0
40005 DEF FNsortindex(i%)
40006 LOCAL p%:p%=2*i%
40007 =sort%?p%+256*sort%?(p%+1)
40008 DEF PROCsortindex(i%,v%)
40009 LOCAL p%:p%=2*i%:sort%?p%=v%:sort%?(p%+1)=v% DIV 256:ENDPROC
40010 DEF FNsymboladdr(i%)
40011 LOCAL p%:p%=3*i%
40012 =saddr%?p%+256*saddr%?(p%+1)+65536*saddr%?(p%+2)
40013 DEF PROCsymboladdr(i%,v%)
40014 LOCAL p%:p%=3*i%:saddr%?p%=v%:saddr%?(p%+1)=v% DIV 256:saddr%?(p%+2)=v% DIV 65536:ENDPROC
40015 DEF FNrefpage(i%,w%)
40016 LOCAL p%,j%:p%=lrefs%(i%):IF p%<>0 OR NOT w% THEN =p%
40017 DIM p% 255:FOR j%=0 TO 255:p%?j%=0:NEXT:lrefs%(i%)=p%
40018 =p%
40019 DEF PROCclearrefs
40020 LOCAL i%,j%,p%
40021 FOR i%=0 TO 63
40022 IF lrefs%(i%)<>0 THEN
40023 p%=lrefs%(i%):FOR j%=0 TO 255:p%?j%=0:NEXT
40024 ENDIF
40025 NEXT:ENDPROC
