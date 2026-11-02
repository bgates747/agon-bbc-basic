16400 DEF PROCloadmemory
16405 LOCAL ci%,cj%,cs$
16410 RESTORE 60000:READ cmsize%,cmrelocs%,cmalloc%,cmdim%,cmaddr%,cmstep%,cmprefix%
16415 DIM cmimage% cmsize%-1,cmreloc%(cmrelocs%-1)
16420 FOR ci%=0 TO cmsize%-1 STEP 40:READ cs$
16425 FOR cj%=1 TO LEN(cs$) STEP 2:cmimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
16430 IF cmrelocs%>0 THEN FOR ci%=0 TO cmrelocs%-1:READ cmreloc%(ci%):NEXT
16435 ENDPROC
16440 DEF PROCusememory
16445 cmemory%=TRUE:cnumeric%=TRUE:ENDPROC
16450 DEF PROCmemoryruntime
16455 LOCAL cb%,ci%,cp%,cv%,ce%,cm$
16460 cb%=cpc%:FOR ci%=0 TO cmsize%-1:PROCbyte(cmimage%?ci%):NEXT
16465 FOR ci%=0 TO cmrelocs%-1:cp%=cb%+cmreloc%(ci%)
16470 cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
16475 PROCctlexport("$memalloc",cb%+cmalloc%):PROCctlexport("$arraydim",cb%+cmdim%):PROCctlexport("$arrayaddr",cb%+cmaddr%)
16480 PROCctlexport("$dimstep",cb%+cmstep%):PROCctlexport("$arrayprefix",cb%+cmprefix%)
16485 PROClabel("$memerror")
16490 FOR ci%=0 TO 5:ce%=VAL(MID$("051011141527",ci%*2+1,2)):PROCbyte(&FE):PROCbyte(ce%):PROCaddr("CA","$me"+STR$(ce%)):NEXT
16495 PROCtext("No room"):PROCnewline:PROCaddr("C3","$error")
16500 FOR ci%=0 TO 5:ce%=VAL(MID$("051011141527",ci%*2+1,2)):cm$=""
16505 IF ce%=5 cm$="Missing ,"
16510 IF ce%=10 cm$="Bad DIM"
16515 IF ce%=11 cm$="DIM space"
16520 IF ce%=14 cm$="Bad use of array"
16525 IF ce%=15 cm$="Bad subscript"
16530 IF ce%=27 cm$="Missing )"
16535 PROClabel("$me"+STR$(ce%)):PROCtext(cm$):PROCnewline:PROCaddr("C3","$error"):NEXT
16540 ENDPROC
16545 DEF PROCmemoryworkspace
16550 LOCAL cp%
16555 PROClabel("$sheapctx"):PROCaddr("","$sheap"):PROCaddr("","$sheapend")
16560 PROClabel("$sheap"):cp%=&AFF00-32768*ABS(cacts%)
16565 IF cp%<&40000+cpc% PROCbad("Memory workspace exceeds user RAM")
16570 PROClabel("$sheapend"):csaddr%(csnum%-1)=cp%:ENDPROC
16575 DEF FNmemwidth(ci%)
16580 LOCAL ct%:ct%=cvtype%(ci%) AND 255:IF ct%=129 ct%=5
16585 =ct%
16590 DEF PROCarrayarity(ci%,cn%)
16595 IF cvdim%(ci%)=0 cvdim%(ci%)=cn%
16600 IF cvdim%(ci%)<>cn% PROCbad("Array arity must be consistent in this compiler subset")
16605 ENDPROC
16610 DEF PROCarraycall(cr$,ci%,cn%,cs%)
16615 PROCaddr("DD21","$var"+STR$(ci%)):PROCaddr("FD21","$v"+STR$(cs%))
16620 PROCbyte(&06):PROCbyte(FNmemwidth(ci%)):PROCbyte(&3E):PROCbyte(cn%)
16625 PROCaddr("CD",cr$):PROCaddr("DA","$memerror"):ENDPROC
16630 DEF PROCarrayaddress(ci%,cw%)
16635 LOCAL cp%,cs%,cn%,cmore%
16640 PROCusememory:PROCvalue(0):cp%=cndepth%-1:cs%=cndepth%:cn%=0
16645 IF cw% THEN PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)) ELSE PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
16650 PROCexpect("("):IF FNpeek=")" PROCbad("Whole-array values are unsupported")
16655 PROCarraycall("$arrayprefix",ci%,0,cs%)
16660 REPEAT
16665 IF cn%=16 PROCbad("Array dimension limit exceeds 16")
16670 IF cn%>0 PROCexpect(",")
16675 PROCexpr(1):PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16680 cn%=cn%+1:PROCarraycall("$arrayprefix",ci%,cn%,cs%)
16685 PROCspace:cmore%=(FNpeek=",")
16690 UNTIL NOT cmore%
16695 PROCexpect(")"):PROCarrayarity(ci%,cn%):PROCarraycall("$arrayaddr",ci%,cn%,cs%)
16700 PROCaddr("22","$v"+STR$(cp%)):cndepth%=cp%+1:ENDPROC
16705 DEF PROCarrayread(ci%)
16710 LOCAL ct%,cp%,cj%
16715 PROCarrayaddress(ci%,FALSE):ct%=cvtype%(ci%) AND 255:cp%=cndepth%-1
16720 IF ct%=129 THEN PROCstrslot:PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCaddr("FD2A","$v"+STR$(cp%)):PROCaddr("CD","$strload"):cndepth%=cp%:cvaluekind%=1:ENDPROC
16725 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("11","$v"+STR$(cp%))
16730 PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16735 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16740 cvaluekind%=0:ENDPROC
16745 DEF PROCarrayassign(ci%)
16750 LOCAL ct%:ct%=cvtype%(ci%) AND 255:cndepth%=0:csdepth%=0:PROCarrayaddress(ci%,TRUE):PROCexpect("=")
16755 PROCexpr(1)
16760 IF ct%=129 THEN IF cvaluekind%<>1 PROCbad("Expected a string item")
16765 IF ct%=129 THEN PROCaddr("DD2A","$v0"):PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):cndepth%=0:csdepth%=0:ENDPROC
16770 PROCneednumber:IF ct%<>5 THEN PROCnumindices(1,1):PROCnumcall(38)
16775 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16780 cndepth%=0:csdepth%=0:ENDPROC
16785 DEF PROCdim
16790 LOCAL cn$,ci%,cmore%,ct%,cj%
16795 PROCusememory
16800 REPEAT
16805 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported DIM target "+cn$)
16810 ci%=FNvariable(cn$):ct%=cvtype%(ci%):PROCspace
16815 IF ct%>255 THEN PROCdimarray(ci%) ELSE PROCdimblock(ci%)
16820 PROCspace:cmore%=(FNpeek=","):IF cmore% cpos%=cpos%+1
16825 UNTIL NOT cmore%
16830 ENDPROC
16835 DEF PROCdimarray(ci%)
16840 LOCAL cn%,cs%,cmore%
16845 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%))
16850 PROCaddr("2A","$var"+STR$(ci%)):PROCbytes("01000000B7ED423E0A"):PROCaddr("C2","$memerror")
16855 cndepth%=0:csdepth%=0:PROCvalue(1):cs%=cndepth%:cn%=0:PROCexpect("(")
16860 IF FNpeek=")" PROCbad("Empty DIM dimensions are unsupported")
16865 REPEAT
16870 IF cn%=16 PROCbad("Array dimension limit exceeds 16")
16875 IF cn%>0 PROCexpect(",")
16880 PROCexpr(1):PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16885 PROCnumindices(0,cndepth%-1):PROCaddr("CD","$dimstep"):PROCaddr("DA","$memerror"):cn%=cn%+1
16890 PROCspace:cmore%=(FNpeek=",")
16895 UNTIL NOT cmore%
16900 PROCexpect(")"):PROCarrayarity(ci%,cn%)
16905 PROCaddr("21","$sheapctx"):PROCarraycall("$arraydim",ci%,cn%,cs%):cndepth%=0:ENDPROC
16910 DEF PROCdimblock(ci%)
16915 LOCAL ct%,cj%:ct%=cvtype%(ci%)
16920 IF ct%<>4 AND ct%<>5 PROCbad("Raw DIM requires a four-byte or variant numeric target")
16925 IF FNword("LOCAL") PROCbad("DIM LOCAL storage is unsupported")
16930 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCaddr("21","$var"+STR$(ci%)):PROCbyte(&AF)
16935 FOR cj%=1 TO ct%:PROCbytes("7723"):NEXT
16940 cndepth%=0:csdepth%=0:PROCexpr(1):PROCneednumber:PROCnumindices(0,0):PROCnumcall(38)
16945 PROCaddr("2A","$v0"):PROCbyte(&23):PROCaddr("DD21","$sheapctx"):PROCaddr("CD","$memalloc"):PROCaddr("DA","$memerror")
16950 PROCaddr("ED53","$var"+STR$(ci%)):cndepth%=0:ENDPROC
16955 DEF PROCreadscalar(ci%)
16960 LOCAL ct%,cs$,cj%:ct%=cvsize%(ci%)
16965 IF cvtype%(ci%)=129 PROCbad("String value used as a numeric item")
16970 PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
16975 PROCnumslot:cs$="$v"+STR$(cndepth%-1):PROCvarcopy("$var"+STR$(ci%),cs$,ct%)
16980 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16985 cvaluekind%=0:ENDPROC
16990 DEF PROCmemtail
16995 LOCAL ct%:PROCspace:IF FNpeek<>"?" AND FNpeek<>"!" ENDPROC
17000 ct%=1:IF FNpeek="!" ct%=4
17005 cpos%=cpos%+1:PROCmemoffset:PROCmemload(ct%):ENDPROC
17010 DEF PROCmemoffset
17015 LOCAL cp%:cp%=cndepth%-1:PROCnumindices(cp%,cp%):PROCnumcall(38)
17020 PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
17025 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("ED5B","$v"+STR$(cndepth%-1)):PROCbyte(&19)
17030 PROCaddr("22","$v"+STR$(cp%)):PROCaddr("21","$v"+STR$(cp%)):PROCbytes("232323AF772377")
17035 cndepth%=cp%+1:ENDPROC
17040 DEF PROCmemload(ct%)
17045 LOCAL cp%,cj%:cp%=cndepth%-1:PROCusememory
17050 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("11","$v"+STR$(cp%))
17055 PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
17060 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
17065 cvaluekind%=0:ENDPROC
17070 DEF PROCmemitem(cc$)
17075 LOCAL ct%
17080 IF cc$="^" THEN cpos%=cpos%+1:PROCaddress:ENDPROC
17085 ct%=1:IF cc$="!" ct%=4
17090 IF cc$="|" ct%=5
17095 cpos%=cpos%+1:PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
17100 PROCmemload(ct%):ENDPROC
17105 DEF PROCaddress
17110 LOCAL cn$,ci%,cp%
17115 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported address target "+cn$)
17120 ci%=FNvariable(cn$):IF cvtype%(ci%)>255 THEN PROCarrayaddress(ci%,TRUE):cvaluekind%=0:ENDPROC
17125 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCvalue(0):cp%=cndepth%-1
17130 PROCaddr("21","$var"+STR$(ci%)):PROCaddr("22","$v"+STR$(cp%)):cvaluekind%=0:ENDPROC
17135 DEF PROCindirectassign(ci%)
17140 LOCAL ct%:ct%=1:IF FNpeek="!" ct%=4
17145 cndepth%=0:csdepth%=0:PROCreadscalar(ci%):cpos%=cpos%+1:PROCmemoffset:PROCmemstore(ct%):ENDPROC
17150 DEF PROCmemassign(cc$)
17155 LOCAL ct%:ct%=1:IF cc$="!" ct%=4
17160 IF cc$="|" ct%=5
17165 PROCusememory:cndepth%=0:csdepth%=0:cpos%=cpos%+1:PROCitem:PROCneednumber:PROCnumindices(0,0):PROCnumcall(38)
17170 PROCmemstore(ct%):ENDPROC
17175 DEF PROCmemstore(ct%)
17180 PROCusememory:PROCexpect("="):PROCexpr(1):PROCneednumber
17185 IF ct%<>5 THEN PROCnumindices(1,1):PROCnumcall(38)
17190 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
17195 cndepth%=0:csdepth%=0:ENDPROC
