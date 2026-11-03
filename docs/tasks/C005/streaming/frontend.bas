19200 DEF PROCdefine(cn$,ca%)
19202 LOCAL ci%,cj%:ci%=FNsymbol(cn$)
19204 IF cphase%>1 THEN IF ci%<0 PROCbad("Layout target disappeared "+cn$)
19206 IF cphase%>1 THEN IF csaddr%(ci%)<>ca% PROCbad("Layout target moved "+cn$)
19208 IF cphase%>1 ENDPROC
19210 IF ci%>=0 PROCbad("Duplicate target "+cn$)
19212 IF csnum%=4096 PROCbad("Too many labels")
19214 IF csnum%>csinsert% THEN FOR cj%=csnum%-1 TO csinsert% STEP -1:csort%(cj%+1)=csort%(cj%):NEXT
19216 csort%(csinsert%)=csnum%:csname$(csnum%)=cn$:csaddr%(csnum%)=ca%:csnum%=csnum%+1
19218 ENDPROC
19220 DEF PROCword24(cv%)
19222 LOCAL ci%:FOR ci%=0 TO 2:PROCbyte(cv% AND 255):cv%=cv% DIV 256:NEXT
19224 ENDPROC
19226 DEF FNlineref(cn%,cm%,cw%)
19228 LOCAL ci%,cb%:ci%=cn% DIV 8+8192*cm%:cb%=2^(cn% AND 7)
19230 IF cw% clrefs%?ci%=clrefs%?ci% OR cb%
19232 =(clrefs%?ci% AND cb%)<>0
19234 DEF PROCtargetscan
19236 LOCAL cp%,cq%,cc$,cw$,cs%,cn%,cm%
19238 IF FNword("DATA") OR FNword("REM") ENDPROC
19240 IF INSTR(cline$,"GOTO")=0 AND INSTR(cline$,"GOSUB")=0 AND INSTR(cline$,"THEN")=0 AND INSTR(cline$,"ELSE")=0 AND INSTR(cline$,"RESTORE")=0 ENDPROC
19242 cp%=cpos%:cq%=FALSE
19244 WHILE cp%<=LEN(cline$)
19246 cc$=MID$(cline$,cp%,1):IF cc$=CHR$(34) cq%=NOT cq%
19248 cw$="":cm%=0
19250 IF NOT cq% AND FNkindword(cline$,cp%,"REM") cp%=LEN(cline$)+1
19252 IF NOT cq% AND FNkindword(cline$,cp%,"GOTO") cw$="GOTO"
19254 IF NOT cq% AND FNkindword(cline$,cp%,"GOSUB") cw$="GOSUB"
19256 IF NOT cq% AND FNkindword(cline$,cp%,"THEN") cw$="THEN"
19258 IF NOT cq% AND FNkindword(cline$,cp%,"ELSE") cw$="ELSE"
19260 IF NOT cq% AND FNkindword(cline$,cp%,"RESTORE") THEN cw$="RESTORE":cm%=1
19262 IF cw$<>"" THEN cs%=cpos%:cpos%=cp%+LEN(cw$):PROCspace:IF FNdigit(FNpeek) OR (cm%=1 AND FNpeek="&") cn%=FNnumber(65279):cn%=FNlineref(cn%,cm%,TRUE)
19264 IF cw$<>"" cpos%=cs%
19266 cp%=cp%+1:ENDWHILE
19268 ENDPROC
19270 DEF FNrelocindex(ck%,ci%)
19272 IF ck%=0 THEN =cnreloc%(ci%)
19274 IF ck%=1 THEN =csreloc%(ci%)
19276 IF ck%=2 THEN =ctreloc%(ci%)
19278 IF ck%=3 THEN =careloc%(ci%)
19280 IF ck%=4 THEN =cmreloc%(ci%)
19282 IF ck%=5 THEN =cireloc%(ci%)
19284 IF ck%=6 THEN =cdreloc%(ci%)
19286 =cereloc%(ci%)
19288 DEF PROCtemplate(cp%,cs%,cr%,ck%)
19290 LOCAL ci%,cj%,cb%,co%,cv%,cn$,ct%,cx%,ce%
19292 IF &40000+cpc%+cs%>&B0000 PROCbad("Executable exceeds user RAM")
19294 IF cphase%=1 THEN cpc%=cpc%+cs%:ENDPROC
19296 ci%=0:cj%=0:cb%=&40000+cpc%:ct%=0:IF ck%=7 ct%=11
19298 cx%=FNbridgeoffset(ck%,ct%):co%=-1:IF cr%>0 co%=FNrelocindex(ck%,0)
19300 WHILE ci%<cs%
19302 IF ci%=cx% THEN
19304 PROCaddr("",FNbridgename(ck%,ct%)):ci%=ci%+3:ct%=ct%+1:cx%=FNbridgeoffset(ck%,ct%)
19306 ELSE
19308 IF ci%=co% THEN
19310 cv%=cp%?ci%+256*cp%?(ci%+1)+65536*cp%?(ci%+2):PROCword24(cv%+cb%):ci%=ci%+3:cj%=cj%+1:co%=-1
19312 IF cj%<cr% co%=FNrelocindex(ck%,cj%)
19314 ELSE
19316 ce%=cs%:IF co%>=0 AND co%<ce% ce%=co%
19318 IF cx%>=0 AND cx%<ce% ce%=cx%
19320 IF ce%<=ci% PROCbad("Invalid runtime relocation order")
19322 IF cphase%=3 THEN FOR cv%=ci% TO ce%-1:BPUT#coh%,cp%?cv%:NEXT
19324 cpc%=cpc%+ce%-ci%:ci%=ce%
19326 ENDIF
19328 ENDIF
19330 ENDWHILE
19332 IF cj%<>cr% PROCbad("Invalid runtime relocation order")
19334 ENDPROC
19336 DEF FNbridgeoffset(ck%,ci%)
19338 IF ck%=2 AND ci%=0 THEN =ctnumslot%
19340 IF ck%=3 AND ci%=0 THEN =capushslot%
19342 IF ck%=3 AND ci%=1 THEN =cacheckslot%
19344 IF ck%=3 AND ci%=2 THEN =capopslot%
19346 IF ck%=3 AND ci%=3 THEN =canumslot%
19348 IF ck%=7 AND ci%<=22 THEN =ceentry%(ci%)
19350 =-1
19352 DEF FNerrorslot(ci%)
19354 LOCAL cs$,cp%,cj%,ck%:cs$="$ctlpush|$strload|$strstore|$error|$ctltop|$acttop|$ctlframes|$actbase|$actlimit|$savedsp|$depth|$sheapctx|":cp%=1
19356 FOR ck%=11 TO ci%:cj%=INSTR(cs$,"|",cp%):IF ck%<ci% cp%=cj%+1
19358 NEXT
19360 =MID$(cs$,cp%,cj%-cp%)
19362 DEF FNbridgename(ck%,ci%)
19364 IF ck%=7 THEN =FNerrorslot(ci%)
19366 IF ck%=2 OR ci%=3 THEN ="$numop"
19368 IF ci%=0 THEN ="$ctlpush"
19370 IF ci%=1 THEN ="$ctlcheck"
19372 ="$ctlpop"
