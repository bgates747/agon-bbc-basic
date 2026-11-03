text$="outer":PROCouter:PRINT text$
value=1.5:whole%=-7:byte&=255:s$="old":PROCtypes(2.5,9.9,257,"new"):PRINT ;value;":";whole%;":";byte&;":";s$
copy$="original":PROCslice(copy$):PRINT copy$
PROCrecursive(4):PRINT ;n%
END
DEF PROCouter:LOCAL text$:text$="inner":PROCsee:ENDPROC
DEF PROCsee:PRINT text$:ENDPROC
DEF PROCtypes(value,whole%,byte&,s$):PRINT ;value;":";whole%;":";byte&;":";s$:ENDPROC
DEF PROCslice(s$):MID$(s$,2,2)="XY":PRINT s$:ENDPROC
DEF PROCrecursive(n%):PRINT ;n%:IF n%>0 THEN PROCrecursive(n%-1)
ENDPROC
