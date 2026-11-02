18000 DEF PROCloaddata
18002 LOCAL ci%,cj%,cs$
18004 RESTORE 62000:READ cdsize%,cdrelocs%,cdpeek%,cdnumber%,cdstring%,cdcommit%
18006 DIM cdimage% cdsize%-1,cdreloc%(cdrelocs%),cdpacket% 4
18008 FOR ci%=0 TO cdsize%-1 STEP 40:READ cs$
18010 FOR cj%=1 TO LEN(cs$) STEP 2:cdimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
18012 IF cdrelocs%>0 THEN FOR ci%=0 TO cdrelocs%-1:READ cdreloc%(ci%):NEXT
18014 ENDPROC
18016 DEF PROCcapturenumber(cv)
18018 LOCAL ci%,cp%:cp%=^cv:FOR ci%=0 TO 4:cdpacket%?ci%=cp%?ci%:NEXT
18020 ENDPROC
18022 DEF PROCcapturepacked(cv,ce%)
18024 LOCAL ci%,cq:FOR ci%=0 TO 3:cq=INT(cv/256):cdpacket%?ci%=cv-cq*256:cv=cq:NEXT:cdpacket%?4=ce%
18026 ENDPROC
18028 DEF PROCusedata
18030 cdataused%=TRUE:cnumeric%=TRUE:ENDPROC
18032 DEF PROCdatastatement
18034 IF NOT cfirst% PROCbad("DATA must lead a physical line")
18036 cpos%=LEN(cline$)+1:ENDPROC
18038 DEF PROCrestoredata
18040 LOCAL ct$:PROCusedata:PROCspace:ct$="$databegin"
18042 IF NOT FNstmtend ct$="$data#"+STR$(FNnumber(65279))
18044 PROCaddr("21",ct$):PROCaddr("22","$datactx"):ENDPROC
18046 DEF PROCreadstatement
18048 LOCAL cn$,ci%,ct%,ca%,cs%,cmore%
18050 PROCusedata
18052 REPEAT
18054 cndepth%=0:csdepth%=0:PROCvalue(0):PROCaddr("DD21","$datactx"):PROCaddr("FD21","$v0"):PROCaddr("CD","$datapeek"):PROCaddr("DA","$dataerror")
18056 cn$=FNname:IF FNreserved(cn$) PROCbad("Unsupported READ target "+cn$)
18058 ci%=FNvariable(cn$):ct%=cvtype%(ci%) AND 255:ca%=(cvtype%(ci%)>255)
18060 IF ca% THEN PROCarrayaddress(ci%,TRUE) ELSE PROCbytes("3E01"):PROCaddr("32","$bind"+STR$(ci%))
18062 IF ct%=129 THEN PROCreadstring(ci%,ca%) ELSE PROCreadnumber(ci%,ca%,ct%)
18064 PROCaddr("DD21","$datactx"):PROCaddr("FD2A","$v0"):PROCaddr("CD","$datacommit"):cndepth%=0:csdepth%=0
18066 PROCspace:cmore%=(FNpeek=","):IF cmore% cpos%=cpos%+1
18068 UNTIL NOT cmore%
18070 ENDPROC
18072 DEF PROCreadnumber(ci%,ca%,ct%)
18074 LOCAL cs%:cdnumeric%=TRUE:PROCnumslot:cs%=cndepth%-1
18076 PROCaddr("DD21","$v"+STR$(cs%)):PROCaddr("FD2A","$v0"):PROCaddr("CD","$datanumber"):PROCaddr("DA","$dataerror")
18078 IF ct%<>5 THEN PROCnumindices(cs%,cs%):PROCnumcall(38)
18080 IF NOT ca% THEN PROCvarcopy("$v"+STR$(cs%),"$var"+STR$(ci%),ct%):ENDPROC
18082 PROCaddr("21","$v"+STR$(cs%)):PROCaddr("ED5B","$v1"):PROCbyte(&01):PROCbyte(ct%):PROCbytes("0000EDB0"):ENDPROC
18084 DEF PROCreadstring(ci%,ca%)
18086 PROCstrslot:PROCaddr("DD21","$s0"):PROCaddr("FD2A","$v0"):PROCaddr("CD","$datastring")
18088 IF ca% THEN PROCaddr("DD2A","$v1") ELSE PROCaddr("DD21","$var"+STR$(ci%))
18090 PROCaddr("FD21","$s0"):PROCaddr("21","$sheapctx"):PROCaddr("CD","$strstore"):PROCaddr("DA","$strerror"):ENDPROC
18092 DEF PROCdataruntime
18094 LOCAL cb%,ci%,cp%,cv%
18096 cb%=cpc%:FOR ci%=0 TO cdsize%-1:PROCbyte(cdimage%?ci%):NEXT
18098 IF cdrelocs%>0 THEN FOR ci%=0 TO cdrelocs%-1:cp%=cb%+cdreloc%(ci%):cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
18100 PROCctlexport("$datapeek",cb%+cdpeek%):PROCctlexport("$datanumber",cb%+cdnumber%):PROCctlexport("$datastring",cb%+cdstring%):PROCctlexport("$datacommit",cb%+cdcommit%)
18102 PROClabel("$datactx"):PROCaddr("","$databegin"):PROCaddr("","$dataend")
18104 PROClabel("$dataerror"):PROCbytes("FE06"):PROCaddr("CA","$datatypemismatch"):PROCbytes("FE10"):PROCaddr("CA","$datasyntax"):PROCbytes("FE2A"):PROCaddr("CA","$dataempty"):PROCaddr("C3","$numerror")
18106 PROClabel("$datatypemismatch"):PROCtext("Type mismatch"):PROCnewline:PROCaddr("C3","$error")
18108 PROClabel("$datasyntax"):PROCtext("Syntax error"):PROCnewline:PROCaddr("C3","$error")
18110 PROClabel("$dataempty"):PROCtext("Out of DATA"):PROCnewline:PROCaddr("C3","$error")
18112 ENDPROC
18114 DEF PROCdatatable
18116 LOCAL ch%,cn%,ci%,cp%,clnum%,cpos%,cline$,ccr%
18118 ch%=OPENIN(csource$):IF ch%=0 PROCbad("Cannot reopen DATA source")
18120 clnum%=0:ccr%=FALSE:PROClabel("$databegin")
18122 WHILE NOT EOF#ch%
18124 clnum%=clnum%+1:cpos%=1:PROCreadline(ch%):PROCspace:cn%=-1
18126 IF FNdigit(FNpeek) cn%=FNnumber(65279)
18128 PROCspace:IF FNword("DATA") PROCdataline(cn%)
18130 ENDWHILE
18132 CLOSE#ch%:PROClabel("$dataend")
18134 ci%=FNsymbol("$start"):cp%=csaddr%(ci%):csaddr%(ci%)=&40000+cpc%
18136 PROCaddr("21","$databegin"):PROCaddr("22","$datactx"):PROCbyte(&C3):PROCbyte(cp% MOD 256):PROCbyte((cp% DIV 256) MOD 256):PROCbyte(cp% DIV 65536)
18138 ENDPROC
18140 DEF PROCdataline(cn%)
18142 LOCAL cmore%:IF cn%>=0 PROClabel("$data#"+STR$(cn%))
18144 cpos%=cpos%+4
18146 REPEAT
18148 PROCdatafield:cmore%=(FNpeek=","):IF cmore% cpos%=cpos%+1
18150 UNTIL NOT cmore%
18152 ENDPROC
18154 DEF PROCdatafield
18156 LOCAL cs$,cp%,ci%,ce%,cq%
18158 PROCspace:cq%=(FNpeek=CHR$(34))
18160 IF cq% THEN cs$=FNstring:PROCspace:IF FNpeek<>"" AND FNpeek<>"," PROCbad("Trailing text after quoted DATA is unqualified")
18162 IF NOT cq% THEN cp%=cpos%:WHILE FNpeek<>"" AND FNpeek<>",":cpos%=cpos%+1:ENDWHILE:cs$=MID$(cline$,cp%,cpos%-cp%)
18164 ce%=6:FOR ci%=0 TO 4:cdpacket%?ci%=0:NEXT
18166 IF NOT cq% ce%=FNdataencode(cs$)
18168 IF ce%=-1 AND cdnumeric% PROCbad("Numeric READ requires literal DATA fields")
18170 IF ce%=-1 ce%=16
18171 IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCdatabytecheck(ASC(MID$(cs$,ci%,1))):NEXT
18172 PROCbyte(LEN(cs$)):PROCbyte(ce%):FOR ci%=0 TO 4:PROCbyte(cdpacket%?ci%):NEXT:PROCbyte(0)
18174 IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT
18176 ENDPROC
18178 DEF FNdataencode(cs$)
18180 LOCAL cline$,cpos%,csign%,cv,ci%,ce%,cp%:cline$=cs$:cpos%=1:csign%=0:cnumerr%=0
18182 PROCspace:IF FNpeek="" THEN =16
18184 IF FNpeek="+" OR FNpeek="-" THEN csign%=(FNpeek="-"):cpos%=cpos%+1:PROCspace
18186 IF NOT FNdigit(FNpeek) AND FNpeek<>"&" AND FNpeek<>"." THEN =-1
18188 cdcapture%=TRUE:PROCconstant:cdcapture%=FALSE:PROCspace:IF FNpeek<>"" THEN =-1
18190 IF csign% AND cnumerr%=0 THEN cv=|cdpacket%:cv=-cv:cp%=^cv:FOR ci%=0 TO 4:cdpacket%?ci%=cp%?ci%:NEXT
18192 =cnumerr%
18194 DEF PROCdatabytecheck(cb%)
18196 IF cb%<32 PROCbad("Control bytes in DATA are unsupported")
18198 ENDPROC
