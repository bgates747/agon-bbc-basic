19500 DEF PROCusecompact
19502 compact%=TRUE:numeric%=TRUE:ENDPROC
19504 DEF PROCnumoperation(l%,r%,o%)
19506 PROCusecompact:PROCaddr("CD","$cpnum"):PROCbyte(l%):PROCbyte(r%):PROCbyte(o%):ENDPROC
19510 DEF PROCloadcompact
19512 LOCAL i%,j%,s$
19514 RESTORE 64000:READ xsize%,xrelocs%:DIM xentry%(25)
19516 FOR i%=0 TO 25:READ xentry%(i%):NEXT
19518 DIM ximage% xsize%-1,xreloc%(xrelocs%-1)
19520 FOR i%=0 TO xsize%-1 STEP 40:READ s$
19522 FOR j%=1 TO LEN(s$) STEP 2:ximage%?(i%+(j%-1) DIV 2)=FNhexbyte(MID$(s$,j%,2)):NEXT:NEXT
19524 IF xrelocs%>0 THEN FOR i%=0 TO xrelocs%-1:READ xreloc%(i%):NEXT
19526 ENDPROC
19530 DEF PROCcompactruntime
19532 LOCAL b%,i%,s$,p%,j%
19534 b%=pc%:PROCtemplate(ximage%,xsize%,xrelocs%,8)
19536 s$="$cplit|$cpnum|$cpread1|$cpread4|$cpread5|$cpstore1|$cpstore4|$cpstore5|$cpprefix|$cpaddr|$cpsave|$cpbind|$cpbegin|":p%=1
19538 FOR i%=0 TO 12:j%=INSTR(s$,"|",p%):PROCctlexport(MID$(s$,p%,j%-p%),b%+xentry%(i%)):p%=j%+1:NEXT
19540 PROCdefine("$zero",0):ENDPROC
19544 DEF FNcompactbridge(i%)
19546 LOCAL s$:s$="$zero"
19548 IF i%=13 AND nslots%>0 s$="$v0"
19550 IF i%=14 AND sslots%>0 s$="$s0"
19552 IF i%=15 s$="$numop"
19554 IF i%=16 s$="$numerror"
19556 IF i%=17 s$="$numlit"
19558 IF i%=18 AND vnum%>0 s$="$novar"
19560 IF i%=19 AND memory% s$="$arrayprefix"
19562 IF i%=20 AND memory% s$="$arrayaddr"
19564 IF i%=21 AND memory% s$="$memerror"
19566 IF i%=22 AND acts% s$="$actsave"
19568 IF i%=23 AND acts% s$="$actbind"
19570 IF i%=24 AND acts% s$="$actbegin"
19572 IF i%=25 AND acts% s$="$acterror"
19574 =s$
