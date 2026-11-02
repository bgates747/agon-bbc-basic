10 empty$=""
20 zero$=CHR$(0)+"x"+CHR$(255)
30 original$="hello"
40 copy$=original$
50 original$="z"
60 copy$=copy$
70 tail$="a"
80 tail$=tail$+"bc"
90 block$="q"
100 tail$=tail$+"def"
110 tail$=""
120 tail$="xy"
130 Case$="UP"
140 case$="low"
150 fresh$=fresh$+"new"
160 left$="llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll"
170 right$="rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"
180 maximum$=left$+right$
190 independent$=maximum$
200 maximum$="m"
210 length%=LEN(independent$)
220 churn$="c"
230 barrier$="b"
240 barrier$=barrier$+"b"
250 churn$="cc"
260 barrier$="b"
270 barrier$=barrier$+"b"
280 churn$="cccc"
290 barrier$="b"
300 barrier$=barrier$+"b"
310 churn$="cccccccc"
320 barrier$="b"
330 barrier$=barrier$+"b"
340 churn$="cccccccccccccccc"
350 barrier$="b"
360 barrier$=barrier$+"b"
370 churn$="cccccccccccccccccccccccccccccccc"
380 barrier$="b"
390 barrier$=barrier$+"b"
400 churn$="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
410 barrier$="b"
420 barrier$=barrier$+"b"
430 churn$=""
440 churn$=left$
450 churn$="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
460 barrier$="b"
470 barrier$=barrier$+"b"
480 churn$=left$+right$
490 barrier$="b"
500 barrier$=barrier$+"b"
510 full$=left$+right$
520 cutleft$=LEFT$(full$,129)
530 cutright$=RIGHT$(full$,128)
540 cutmid$=MID$(full$,128,3)
550 lowzero$=LEFT$(zero$,1)
560 wrap$=MID$(full$,256,257)
570 chained$=RIGHT$(MID$(full$,128),2)
580 emptycut$=RIGHT$(full$,0)
590 cmpresult%=((full$=left$+right$)AND(LEFT$(full$,128)=left$))
900 GOTO 1000
910 PRINT missing$
1000 PROCcapture:OSCLI "BYE"
2000 DEF PROCcapture:LOCAL ch%,p%,q%,i%,n%
2010 ch%=OPENOUT("string-expected.dat")
2020 p%=^empty$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2030 p%=^zero$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2040 p%=^original$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2050 p%=^copy$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2060 p%=^tail$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2070 p%=^block$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2080 p%=^Case$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2090 p%=^case$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2100 p%=^fresh$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2110 p%=^left$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2120 p%=^right$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2130 p%=^maximum$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2140 p%=^independent$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2150 p%=^churn$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2160 p%=^barrier$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2170 p%=^full$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2180 p%=^cutleft$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2190 p%=^cutright$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2200 p%=^cutmid$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2210 p%=^lowzero$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2220 p%=^wrap$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2230 p%=^chained$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
2240 p%=^emptycut$:n%=?p%:BPUT#ch%,n%:q%=p%?2+256*(p%?3)+65536*(p%?4):IF n%>0 FOR i%=0 TO n%-1:BPUT#ch%,q%?i%:NEXT
4000 CLOSE#ch%:PRINT "STRING_STORAGE_REFERENCE_DONE":ENDPROC
