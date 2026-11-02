10 ON ERROR PRINT "REF_ERR=";ERR;":";ERL:REPORT:PRINT:OSCLI "BYE"
100 READ a%,b&,x,y,z:PRINT ;a%;":";b&;":";x;":";y;":";z
110 PRINT ;?(^x+4);":";?(^y+4);":";?(^z+4)
490 OSCLI "BYE"
500 DATA -123,257,1.0,1/3,&FFFFFFFF
