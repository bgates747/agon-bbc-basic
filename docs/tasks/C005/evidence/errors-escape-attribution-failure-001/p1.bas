10 ON ERROR PRINT ;BGET#h%:END
20 FOR i%=1 TO 8:h%=OPENIN("error-file.dat"):NEXT
30 ERROR 100,"caught"
