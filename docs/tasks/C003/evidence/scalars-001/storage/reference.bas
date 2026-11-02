10 integer=1
20 floating=1.0
30 fraction=1/3
40 copy=fraction
50 large=4294967296.0
60 positive%=&7FFFFFFF
70 negative%=&80000000
80 byte&=-1.5
90 fraction%=-7/2
100 A%=-1
110 fresh=fresh+1
120 upper=1:UPPER=2:upper%=3:upper&=4
130 _test9=5
140 floatcopy=floating
150 converted%=floating
160 small&=321
170 Z%=Z%
900 GOTO 1000
910 PRINT ;never
1000 PROCcapture:OSCLI "BYE"
2000 DEF PROCcapture:LOCAL ch%,p%,i%
2010 ch%=OPENOUT("scalar-expected.dat")
2020 p%=^integer:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2030 p%=^floating:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2040 p%=^fraction:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2050 p%=^copy:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2060 p%=^large:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2070 p%=^positive%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
2080 p%=^negative%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
2090 p%=^byte&:FOR i%=0 TO 0:BPUT#ch%,p%?i%:NEXT
2100 p%=^fraction%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
2110 p%=^A%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
2120 p%=^fresh:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2130 p%=^upper:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2140 p%=^UPPER:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2150 p%=^upper%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
2160 p%=^upper&:FOR i%=0 TO 0:BPUT#ch%,p%?i%:NEXT
2170 p%=^_test9:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2180 p%=^floatcopy:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT
2190 p%=^converted%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
2200 p%=^small&:FOR i%=0 TO 0:BPUT#ch%,p%?i%:NEXT
2210 p%=^Z%:FOR i%=0 TO 3:BPUT#ch%,p%?i%:NEXT
4000 CLOSE#ch%:PRINT "STORAGE_REFERENCE_DONE":ENDPROC
