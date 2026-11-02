16400 DEF PROCloadmemory
16402 LOCAL ci%,cj%,cs$
16404 RESTORE 60000:READ cmsize%,cmrelocs%,cmalloc%,cmdim%,cmaddr%,cmstep%,cmprefix%
16406 DIM cmimage% cmsize%-1,cmreloc%(cmrelocs%-1)
16408 FOR ci%=0 TO cmsize%-1 STEP 40:READ cs$
16410 FOR cj%=1 TO LEN(cs$) STEP 2:cmimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
16412 IF cmrelocs%>0 THEN FOR ci%=0 TO cmrelocs%-1:READ cmreloc%(ci%):NEXT
16414 ENDPROC
16416 DEF PROCusememory
16418 cmemory%=TRUE:cnumeric%=TRUE:ENDPROC
16420 DEF PROCmemoryruntime
16422 LOCAL cb%,ci%,cp%,cv%,ce%,cm$
16424 cb%=cpc%:FOR ci%=0 TO cmsize%-1:PROCbyte(cmimage%?ci%):NEXT
16426 FOR ci%=0 TO cmrelocs%-1:cp%=cb%+cmreloc%(ci%)
16428 cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
16430 PROCctlexport("$memalloc",cb%+cmalloc%):PROCctlexport("$arraydim",cb%+cmdim%):PROCctlexport("$arrayaddr",cb%+cmaddr%)
16432 PROCctlexport("$dimstep",cb%+cmstep%):PROCctlexport("$arrayprefix",cb%+cmprefix%)
16434 PROClabel("$memerror")
16436 FOR ci%=0 TO 6:ce%=VAL(MID$("05101114151627",ci%*2+1,2)):PROCbyte(&FE):PROCbyte(ce%):PROCaddr("CA","$me"+STR$(ce%)):NEXT
16438 PROCtext("No room"):PROCnewline:PROCaddr("C3","$error")
16440 FOR ci%=0 TO 6:ce%=VAL(MID$("05101114151627",ci%*2+1,2)):cm$=""
16442 IF ce%=5 cm$="Missing ,"
16444 IF ce%=10 cm$="Bad DIM"
16446 IF ce%=11 cm$="DIM space"
16448 IF ce%=14 cm$="Bad use of array"
16450 IF ce%=15 cm$="Bad subscript"
16452 IF ce%=16 cm$="Syntax error"
16454 IF ce%=27 cm$="Missing )"
16456 PROClabel("$me"+STR$(ce%)):PROCtext(cm$):PROCnewline:PROCaddr("C3","$error"):NEXT
16458 ENDPROC
16460 DEF PROCmemoryworkspace
16462 LOCAL cp%
16464 PROClabel("$sheapctx"):PROCaddr("","$sheap"):PROCaddr("","$sheapend")
16466 PROClabel("$sheap"):cp%=&AFF00-32768*ABS(cacts%)
16468 IF cp%<&40000+cpc% PROCbad("Memory workspace exceeds user RAM")
16470 PROClabel("$sheapend"):csaddr%(csnum%-1)=cp%:ENDPROC
16472 DEF FNmemwidth(ci%)
16474 LOCAL ct%:ct%=cvtype%(ci%) AND 255:IF ct%=129 ct%=5
16476 =ct%
16478 DEF PROCarrayarity(ci%,cn%)
16480 IF cvdim%(ci%)=0 cvdim%(ci%)=cn%
16482 IF cvdim%(ci%)<>cn% PROCbad("Array arity must be consistent in this compiler subset")
16484 ENDPROC
16486 DEF PROCarraycall(cr$,ci%,cn%,cs%)
16488 PROCaddr("DD21","$var"+STR$(ci%)):PROCaddr("FD21","$v"+STR$(cs%))
16490 PROCbyte(&06):PROCbyte(FNmemwidth(ci%)):PROCbyte(&3E):PROCbyte(cn%)
16492 PROCaddr("CD",cr$):PROCaddr("DA","$memerror"):ENDPROC
16494 DEF PROCarrayaddress(ci%,cw%)
16496 LOCAL cp%,cs%,cn%,cmore%
16498 PROCusememory:PROCvalue(0):cp%=cndepth%-1:cs%=cndepth%:cn%=0
16500 IF cw% THEN PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)) ELSE PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
16502 PROCexpect("("):IF FNpeek=")" PROCbad("Whole-array values are unsupported")
16504 PROCarraycall("$arrayprefix",ci%,0,cs%)
16506 REPEAT
16508 IF cn%=16 PROCbad("Array dimension limit exceeds 16")
16510 IF cn%>0 PROCexpect(",")
16512 PROCexpr(1):PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16514 cn%=cn%+1:PROCarraycall("$arrayprefix",ci%,cn%,cs%)
16516 PROCspace:cmore%=(FNpeek=",")
16518 UNTIL NOT cmore%
16520 PROCexpect(")"):PROCarrayarity(ci%,cn%):PROCarraycall("$arrayaddr",ci%,cn%,cs%)
16522 PROCaddr("22","$v"+STR$(cp%)):cndepth%=cp%+1:ENDPROC
16524 DEF PROCarrayread(ci%)
16526 LOCAL ct%,cp%,cj%
16528 PROCarrayaddress(ci%,FALSE):ct%=cvtype%(ci%) AND 255:cp%=cndepth%-1
16530 IF ct%=129 THEN PROCstrslot:PROCaddr("DD21","$s"+STR$(csdepth%-1)):PROCaddr("FD2A","$v"+STR$(cp%)):PROCaddr("CD","$strload"):cndepth%=cp%:cvaluekind%=1:ENDPROC
16532 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("11","$v"+STR$(cp%))
16534 PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16536 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16538 cvaluekind%=0:ENDPROC
16540 DEF PROCarrayassign(ci%)
16542 LOCAL ct%:ct%=cvtype%(ci%) AND 255:cndepth%=0:csdepth%=0:PROCarrayaddress(ci%,TRUE):PROCexpect("=")
16544 PROCexpr(1)
16546 IF ct%=129 THEN IF cvaluekind%<>1 PROCbad("Expected a string item")
16548 IF ct%=129 THEN PROCaddr("DD2A","$v0"):PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):cndepth%=0:csdepth%=0:ENDPROC
16550 PROCneednumber:IF ct%<>5 THEN PROCnumindices(1,1):PROCnumcall(38)
16552 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16554 cndepth%=0:csdepth%=0:ENDPROC
16556 DEF PROCdim
16558 LOCAL cn$,ci%,cmore%,ct%,cj%
16560 PROCusememory
16562 REPEAT
16564 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported DIM target "+cn$)
16566 ci%=FNvariable(cn$):ct%=cvtype%(ci%):PROCspace
16568 IF ct%>255 THEN PROCdimarray(ci%) ELSE PROCdimblock(ci%)
16570 PROCspace:cmore%=(FNpeek=","):IF cmore% cpos%=cpos%+1
16572 UNTIL NOT cmore%
16574 ENDPROC
16576 DEF PROCdimarray(ci%)
16578 LOCAL cn%,cs%,cmore%,cnew$,ct%
16580 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%))
16582 cndepth%=0:csdepth%=0:PROCvalue(1):PROCvalue(0):PROCaddr("2A","$var"+STR$(ci%)):PROCaddr("22","$v1")
16584 cs%=cndepth%:cn%=0:PROCexpect("("):cnew$=FNflow:PROCdimbranch(cnew$,TRUE):PROCarraycall("$arrayprefix",ci%,0,cs%):PROClabel(cnew$)
16586 IF FNpeek=")" PROCbad("Empty DIM dimensions are unsupported")
16588 REPEAT
16590 IF cn%=16 PROCbad("Array dimension limit exceeds 16")
16592 IF cn%>0 PROCexpect(",")
16594 cdimparse%=cdimparse%+1:PROCexpr(1):cdimparse%=cdimparse%-1:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16596 cn%=cn%+1:PROCdimchoice(ci%,cn%,cs%)
16598 PROCspace:cmore%=(FNpeek=",")
16600 UNTIL NOT cmore%
16602 PROCexpect(")"):PROCarrayarity(ci%,cn%):cnew$=FNflow:PROCdimbranch(cnew$,TRUE)
16604 PROCarraycall("$arrayaddr",ci%,cn%,cs%):ct%=cvtype%(ci%) AND 255
16606 IF ct%=129 THEN PROCbytes("3E0A"):PROCaddr("C3","$memerror") ELSE PROCdimseed(ct%):PROCbytes("3E10"):PROCaddr("C3","$memerror")
16608 PROClabel(cnew$):PROCaddr("21","$sheapctx"):PROCarraycall("$arraydim",ci%,cn%,cs%):cndepth%=0:ENDPROC
16610 DEF PROCdimblock(ci%)
16612 LOCAL ct%,cj%:ct%=cvtype%(ci%)
16614 IF ct%<>4 AND ct%<>5 PROCbad("Raw DIM requires a four-byte or variant numeric target")
16616 IF FNword("LOCAL") PROCbad("DIM LOCAL storage is unsupported")
16618 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCaddr("21","$var"+STR$(ci%)):PROCdimseed(ct%)
16620 cndepth%=0:csdepth%=0:PROCexpr(1):PROCneednumber:PROCnumindices(0,0):PROCnumcall(38)
16622 PROCaddr("2A","$v0"):PROCbyte(&23):PROCaddr("DD21","$sheapctx"):PROCaddr("CD","$memalloc"):PROCaddr("DA","$memerror")
16624 PROCaddr("ED53","$var"+STR$(ci%)):cndepth%=0:ENDPROC
16626 DEF PROCreadscalar(ci%)
16628 LOCAL ct%,cs$,cj%:ct%=cvsize%(ci%)
16630 IF cvtype%(ci%)=129 PROCbad("String value used as a numeric item")
16632 PROCaddr("3A","$bind"+STR$(ci%)):PROCbyte(&B7):PROCaddr("CA","$novar")
16634 PROCnumslot:cs$="$v"+STR$(cndepth%-1):PROCvarcopy("$var"+STR$(ci%),cs$,ct%)
16636 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16638 cvaluekind%=0:ENDPROC
16640 DEF PROCmemtail
16642 LOCAL ct%:IF FNpeek<>"?" AND FNpeek<>"!" ENDPROC
16644 ct%=1:IF FNpeek="!" ct%=4
16646 cpos%=cpos%+1:PROCmemoffset:PROCmemload(ct%):ENDPROC
16648 DEF PROCmemoffset
16650 LOCAL cp%:cp%=cndepth%-1:PROCnumindices(cp%,cp%):PROCnumcall(38)
16652 PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16654 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("ED5B","$v"+STR$(cndepth%-1)):PROCbyte(&19)
16656 PROCaddr("22","$v"+STR$(cp%)):PROCaddr("21","$v"+STR$(cp%)):PROCbytes("232323AF772377")
16658 cndepth%=cp%+1:ENDPROC
16660 DEF PROCmemload(ct%)
16662 LOCAL cp%,cj%:cp%=cndepth%-1:PROCusememory
16664 PROCaddr("2A","$v"+STR$(cp%)):PROCaddr("11","$v"+STR$(cp%))
16666 PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16668 IF ct%<5 THEN PROCbyte(&AF):FOR cj%=ct% TO 4:PROCbytes("1213"):NEXT
16670 cvaluekind%=0:ENDPROC
16672 DEF PROCmemitem(cc$)
16674 LOCAL ct%
16676 IF cc$="^" THEN cpos%=cpos%+1:PROCaddress:ENDPROC
16678 ct%=1:IF cc$="!" ct%=4
16680 IF cc$="|" ct%=5
16682 cpos%=cpos%+1:PROCitem:PROCneednumber:PROCnumindices(cndepth%-1,cndepth%-1):PROCnumcall(38)
16684 PROCmemload(ct%):ENDPROC
16686 DEF PROCaddress
16688 LOCAL cn$,ci%,cp%
16690 IF cdimparse%>0 PROCbad("Address-of in array DIM expressions is unqualified")
16692 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported address target "+cn$)
16694 ci%=FNvariable(cn$):IF cvtype%(ci%)>255 THEN PROCarrayaddress(ci%,TRUE):cvaluekind%=0:ENDPROC
16696 PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%)):PROCvalue(0):cp%=cndepth%-1
16698 PROCaddr("21","$var"+STR$(ci%)):PROCaddr("22","$v"+STR$(cp%)):cvaluekind%=0:ENDPROC
16700 DEF PROCindirectassign(ci%)
16702 LOCAL ct%:ct%=1:IF FNpeek="!" ct%=4
16704 cndepth%=0:csdepth%=0:PROCreadscalar(ci%):cpos%=cpos%+1:PROCmemoffset:PROCmemstore(ct%):ENDPROC
16706 DEF PROCmemassign(cc$)
16708 LOCAL ct%:ct%=1:IF cc$="!" ct%=4
16710 IF cc$="|" ct%=5
16712 PROCusememory:cndepth%=0:csdepth%=0:cpos%=cpos%+1:PROCitem:PROCneednumber:PROCnumindices(0,0):PROCnumcall(38)
16714 PROCmemstore(ct%):ENDPROC
16716 DEF PROCmemstore(ct%)
16718 PROCusememory:PROCexpect("="):PROCexpr(1):PROCneednumber
16720 IF ct%<>5 THEN PROCnumindices(1,1):PROCnumcall(38)
16722 PROCaddr("21","$v1"):PROCaddr("ED5B","$v0"):PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0")
16724 cndepth%=0:csdepth%=0:ENDPROC
16726 DEF PROCdimseed(ct%)
16728 LOCAL cj%
16730 IF ct%=1 THEN PROCbytes("7D77"):ENDPROC
16732 PROCbytes("E5D173237223AF"):FOR cj%=3 TO ct%:PROCbytes("7723"):NEXT:ENDPROC
16734 DEF PROCdimbranch(cn$,cz%)
16736 LOCAL cr$:cr$="C2":IF cz% cr$="CA"
16738 PROCaddr("2A","$v1"):PROCbytes("01000000B7ED42"):PROCaddr(cr$,cn$):ENDPROC
16740 DEF PROCdimchoice(ci%,cn%,cs%)
16742 LOCAL cold$,cend$:cold$=FNflow:cend$=FNflow:PROCdimbranch(cold$,FALSE)
16744 PROCnumindices(0,cndepth%-1):PROCaddr("CD","$dimstep"):PROCaddr("DA","$memerror"):PROCaddr("C3",cend$)
16746 PROClabel(cold$):PROCarraycall("$arrayprefix",ci%,cn%,cs%):PROClabel(cend$):ENDPROC
