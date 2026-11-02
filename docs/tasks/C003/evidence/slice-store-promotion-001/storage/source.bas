10 defaultleft$="abcdef":LEFT$(defaultleft$)="XYZ"
20 rightshort$="abcdef":RIGHT$(rightshort$,5)="XY"
30 midzero$="abcdef":MID$(midzero$,0,2)="YZ"
40 lastmarker$=STRING$(255,"x"):MID$(lastmarker$,255,2)="YZ"
50 clamped$=STRING$(255,"x"):MID$(clamped$,255,3)="YZ"
60 allbutlast$=STRING$(255,"x"):MID$(allbutlast$,2,255)=STRING$(255,"z")
70 alias$="abcdef":MID$(alias$,2,3)=alias$
80 bytes$=CHR$(0)+CHR$(128)+CHR$(255):copy$=bytes$
90 MID$(bytes$,2,1)=CHR$(0):LEFT$(bytes$,1)=CHR$(128)
100 empty$="":RIGHT$(empty$,3)=CHR$(255)
110 nop$="abc":LEFT$(nop$,0)=STRING$(1,"Y")
120 length%=LEN allbutlast$:first%=ASC bytes$:last%=ASC RIGHT$(clamped$)
900 GOTO 1000
910 PRINT missing$
1000 END
