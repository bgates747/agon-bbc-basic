10 ON ERROR PRINT "REF_ERR=";ERR;":";ERL:REPORT:PRINT:OSCLI "BYE"
100 READ a$,b$,c$,d$,e$:PRINT ;LEN a$;":";a$;":";LEN b$;":";b$;":";LEN c$;":";c$;":";LEN d$;":";d$;":";LEN e$
490 OSCLI "BYE"
500 DATA   leading and trailing  ,"a,b:c","a""b", 123  ,""
