h%=OPENOUT("native-test.dat"):BPUT#h%,255:BPUT#h%,"text";:CLOSE#h%
h%=OPENIN("native-test.dat"):PRINT ;BGET#h%;":";BGET#h%;":";EOF#h%:CLOSE#h%:END
