17500 DEF PROCloadio
17502 LOCAL ci%,cj%,cs$
17504 RESTORE 61000:READ cisize%,cirelocs%,ciopen%,ciget%,cieof%,ciput%,ciputs%,ciclose%,ciinput%
17506 DIM ciimage% cisize%-1,cireloc%(cirelocs%-1)
17508 FOR ci%=0 TO cisize%-1 STEP 40:READ cs$
17510 FOR cj%=1 TO LEN(cs$) STEP 2:ciimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
17512 IF cirelocs%>0 THEN FOR ci%=0 TO cirelocs%-1:READ cireloc%(ci%):NEXT
17514 ENDPROC
17516 DEF PROCchannel
17518 PROCexpect("#"):PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
17520 ENDPROC
17522 DEF PROCioitem(cw$)
17524 LOCAL cm%,cp%:cio%=TRUE:cfileio%=TRUE
17526 IF cw$="BGET" OR cw$="EOF" THEN PROCchannel:cp%=cndepth%-1:PROCaddr("3A","$v"+STR$(cp%)):PROCaddr("DD21","$v"+STR$(cp%)):PROCaddr("CD","$io"+cw$):cvaluekind%=0:ENDPROC
17528 cm%=1:IF cw$="OPENOUT" cm%=10
17530 IF cw$="OPENUP" cm%=3
17532 PROCstritem:IF csunsafe%(csdepth%-1) PROCbad("Direct FN filename carriers are unqualified")
17534 PROCnumslot:PROCaddr("DD21","$v"+STR$(cndepth%-1)):PROCaddr("FD21","$s"+STR$(csdepth%-1))
17536 PROCbyte(&3E):PROCbyte(cm%):PROCaddr("CD","$ioopen"):csdepth%=csdepth%-1:cvaluekind%=0:ENDPROC
17538 DEF PROCclosestatement
17540 cio%=TRUE:cfileio%=TRUE:cndepth%=0:csdepth%=0:PROCchannel
17542 PROCaddr("3A","$v0"):PROCaddr("CD","$ioclose"):cndepth%=0:ENDPROC
17544 DEF PROCbput
17546 LOCAL cf%:cio%=TRUE:cfileio%=TRUE:cndepth%=0:csdepth%=0:PROCchannel:PROCexpect(","):PROCexpr(1):PROCspace
17548 IF cvaluekind%=0 THEN PROCneednumber:PROCnumindices(1,1):PROCnumcall(38):PROCaddr("3A","$v1"):PROCbyte(&47):PROCaddr("3A","$v0"):PROCaddr("CD","$ioput"):cndepth%=0:ENDPROC
17550 cf%=1:IF FNpeek=";" THEN cf%=0:cpos%=cpos%+1
17552 PROCaddr("FD21","$s0"):PROCbyte(&0E):PROCbyte(cf%):PROCaddr("3A","$v0"):PROCaddr("CD","$ioputs"):cndepth%=0:csdepth%=0:ENDPROC
17554 DEF PROCinputline
17556 LOCAL cp$,cn$,ci%:cio%=TRUE:PROCspace:IF NOT FNword("LINE") PROCbad("Only INPUT LINE is supported")
17558 cpos%=cpos%+4:PROCspace:cp$="? ":IF FNpeek=CHR$(34) cp$=FNstring
17560 PROCspace:cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported INPUT LINE target")
17562 ci%=FNvariable(cn$):IF cvtype%(ci%)<>129 PROCbad("INPUT LINE requires one scalar string variable")
17564 PROCspace:IF NOT FNstmtend PROCbad("INPUT LINE separators and multiple targets are unsupported")
17566 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCtext(cp$):cndepth%=0:csdepth%=0:PROCstrslot
17568 PROCaddr("DD21","$s0"):PROCaddr("CD","$ioinput"):PROCaddr("DA","$ioerror")
17570 PROCaddr("DD21","$var"+STR$(ci%)):PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):csdepth%=0:ENDPROC
17572 DEF PROCIOruntime
17574 LOCAL cb%,ci%,cp%,cv%
17576 cb%=cpc%:FOR ci%=0 TO cisize%-1:PROCbyte(ciimage%?ci%):NEXT
17578 FOR ci%=0 TO cirelocs%-1:cp%=cb%+cireloc%(ci%):cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
17580 PROCctlexport("$ioopen",cb%+ciopen%):PROCctlexport("$ioBGET",cb%+ciget%):PROCctlexport("$ioEOF",cb%+cieof%)
17582 PROCctlexport("$ioput",cb%+ciput%):PROCctlexport("$ioputs",cb%+ciputs%):PROCctlexport("$ioclose",cb%+ciclose%):PROCctlexport("$ioinput",cb%+ciinput%)
17584 PROClabel("$ioerror"):PROCtext("Escape"):PROCnewline:PROCaddr("C3","$error")
17586 ENDPROC
