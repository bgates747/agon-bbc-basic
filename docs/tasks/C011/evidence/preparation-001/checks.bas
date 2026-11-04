10 REM C011 supplementary correctness cases; not a throughput benchmark
20 ON ERROR PRINT "CHECK ERR=";ERR;" ERL=";ERL:REPORT:GOTO 200
30 REM Human input is checked only after deliberate error recovery.
40 MODE 1:CLS:VDU 67,48,49,49,13,10
50 DIM p% 15
60 ?p%=255:p%!1=&12345678:|(p%+5)=1.25
70 IF ?p%<>255 OR p%!1<>&12345678 OR |(p%+5)<>1.25 ERROR 101,"Raw memory"
80 u%=1:v%=3:FOR i%=1 TO 5 STEP 2:u%=u%+i%:NEXT
90 IF u%<>10 ERROR 101,"FOR STEP"
100 IF NOT (1<2 AND 2<=2 AND 3>2 AND 3>=3 AND 1<>2 AND 2=2) ERROR 101,"Relations"
110 IF NOT ("a"<"b" AND "a"<="a" AND "b">"a" AND "b">="b" AND "a"<>"b" AND "a"="a") ERROR 101,"String relations"
112 f%=OPENOUT("checkio.dat")
114 IF f%=0 ERROR 101,"Open output"
116 BPUT #f%,"ABC":CLOSE #f%:f%=OPENUP("checkio.dat")
117 IF f%=0 ERROR 101,"Open update"
118 BPUT #f%,90:CLOSE #f%:f%=OPENIN("checkio.dat")
119 IF f%=0 ERROR 101,"Open input"
120 IF BGET#f%<>90 OR BGET#f%<>66 OR BGET#f%<>67 OR BGET#f%<>10 ERROR 101,"String/update I/O"
121 IF NOT EOF#f% ERROR 101,"File size"
122 CLOSE #f%
124 PRINT "Core checks passed; deliberate ERROR 123 follows."
130 ERROR 123,"C011 deliberate error"
140 PRINT "FAIL: ERROR did not transfer":END
200 IF ERR<>123 PRINT "FAIL: unexpected error":END
210 IF ERL<>130 PRINT "FAIL: wrong ERL":END
220 ON ERROR OFF
230 PRINT "Error and ERL checks passed."
240 INPUT LINE "Type C011 then Enter: " typed$
250 IF typed$<>"C011" PRINT "Input mismatch":END
260 PRINT "Press Space once (not Escape).":key%=GET
270 IF key%<>32 PRINT "Key mismatch":END
280 PRINT "PASS: supplementary checks. Not a timing result."
290 END
