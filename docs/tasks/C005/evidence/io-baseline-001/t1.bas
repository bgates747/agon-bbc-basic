REM Unnumbered source, forward targets and separate GOSUB return handling.
PRINT "Native BBC BASIC on Agon"
GOSUB @greeting
GOTO @finished
@greeting:
PRINT "A quoted ""hello""";
PRINT " from ADL code"
RETURN
@finished:
END
