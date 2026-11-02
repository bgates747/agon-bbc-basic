REM Owned strings, embedded zeros, LEN and CHR$.
message$="Hello"
copy$=message$
message$=message$+", Agon"
PRINT message$;"!"
PRINT copy$;" stayed unchanged."
PRINT "Length: ";LEN(message$)
zero$=CHR$(0)+"x"
PRINT "Embedded-zero length: ";LEN(zero$)
GOSUB @append
PRINT message$
END
@append:
message$=message$+CHR$(33)
RETURN
