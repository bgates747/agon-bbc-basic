10 PRINT "ERROR_CASE_BEGIN_3"
20 s$="outer"
30 ON ERROR PRINT ;ERR;":";ERL;":";LEN s$;":";ASC s$:PROCoverwrite:PRINT ;LEN s$;":";ASC RIGHT$(s$):END
40 PROCfail
50 END
1000 DEF PROCfail:LOCAL s$:s$="small":LOCAL s$:s$=STRING$(255,"q"):ERROR 100,"lost"
1010 DEF PROCoverwrite:LOCAL t$:t$=STRING$(255,"x"):ENDPROC
