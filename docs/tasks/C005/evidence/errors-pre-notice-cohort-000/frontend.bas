19000 DEF PROCloaderrors
19002 LOCAL ci%,cj%,cs$
19004 DIM ceentry%(22):RESTORE 63000:READ cesize%,cerelocs%:FOR ci%=0 TO 22:READ ceentry%(ci%):NEXT
19006 DIM ceimage% cesize%-1,cereloc%(cerelocs%-1)
19008 FOR ci%=0 TO cesize%-1 STEP 40:READ cs$
19010 FOR cj%=1 TO LEN(cs$) STEP 2:ceimage%?(ci%+(cj%-1) DIV 2)=FNhexbyte(MID$(cs$,cj%,2)):NEXT:NEXT
19012 IF cerelocs%>0 THEN FOR ci%=0 TO cerelocs%-1:READ cereloc%(ci%):NEXT
19014 ENDPROC
19016 DEF PROCuseerrors
19018 PROCuseacts:PROCusememory:cstrings%=TRUE:IF csslots%=0 csslots%=1
19020 ENDPROC
19022 DEF PROCerrorscan
19024 LOCAL cp%,cq%,cc$
19026 IF FNword("DATA") OR FNword("REM") ENDPROC
19028 cp%=cpos%:cq%=FALSE
19030 WHILE cp%<=LEN(cline$)
19032 cc$=MID$(cline$,cp%,1):IF cc$=CHR$(34) cq%=NOT cq%
19034 IF NOT cq% THEN IF FNkindword(cline$,cp%,"REM") cp%=LEN(cline$)+1
19036 IF NOT cq% THEN IF FNkindword(cline$,cp%,"ERROR") OR FNkindword(cline$,cp%,"ERR") OR FNkindword(cline$,cp%,"ERL") OR FNkindword(cline$,cp%,"REPORT") cerrors%=TRUE
19038 cp%=cp%+1:ENDWHILE
19040 ENDPROC
19042 DEF PROCerrmark
19044 LOCAL ci%,cp%:IF NOT cerrors% ENDPROC
19045 IF FNword("REM") OR FNword("DATA") ENDPROC
19046 PROCaddr("CD","$errline"):cp%=cbasicline%
19048 FOR ci%=0 TO 3:PROCbyte(cp% AND 255):cp%=cp% DIV 256:NEXT
19050 ENDPROC
19052 DEF PROCerrorinstall
19054 LOCAL cm%,ct$:PROCexpectword("ERROR"):PROCspace:cm%=0
19056 IF FNword("LOCAL") THEN cm%=1:cpos%=cpos%+5:PROCspace
19058 IF FNword("OFF") THEN cpos%=cpos%+3:PROCbytes("210000003E"):PROCbyte(cm%):PROCaddr("CD","$errinstall"):PROCaddr("DA","$acterror"):ENDPROC
19060 IF cinum%<>0 PROCbad("ON ERROR handler installation inside inline IF is unsupported")
19062 IF chskip$<>"" PROCbad("Only one ON ERROR handler body per physical line is supported")
19064 ct$=FNflow:chskip$=FNflow
19066 PROCaddr("21",ct$):PROCbyte(&3E):PROCbyte(cm%):PROCaddr("CD","$errinstall"):PROCaddr("DA","$acterror")
19068 PROCaddr("C3",chskip$):PROClabel(ct$):ccont%=TRUE
19070 ENDPROC
19072 DEF PROCerrorstatement
19074 cndepth%=0:csdepth%=0:PROCexpr(1):PROCneednumber:PROCnumindices(0,0):PROCnumcall(38):PROCexpect(","):PROCstrexpr
19076 IF csunsafe%(csdepth%-1) PROCbad("Direct FN error-message carriers are unqualified")
19078 PROCaddr("3A","$v0"):PROCaddr("FD21","$s0"):PROCaddr("C3","$errraise"):cndepth%=0:csdepth%=0
19080 ENDPROC
19082 DEF PROCerritem(cw$)
19084 LOCAL ct%,cs$:ct%=1:cs$="$errcode":IF cw$="ERL" ct%=4:cs$="$errlastline"
19086 PROCvalue(0):PROCvarcopy(cs$,"$v"+STR$(cndepth%-1),ct%):ENDPROC
19088 DEF PROCerrorconstant(cn%,cs$)
19090 LOCAL ci%
19092 IF NOT cerrors% THEN PROCtext(cs$):PROCnewline:PROCaddr("C3","$error"):ENDPROC
19094 IF cn%>=0 THEN PROCbyte(&3E):PROCbyte(cn%)
19095 PROCaddr("CD","$errinline"):PROCbyte(LEN(cs$))
19096 IF cs$<>"" THEN FOR ci%=1 TO LEN(cs$):PROCbyte(ASC(MID$(cs$,ci%,1))):NEXT
19098 ENDPROC
19100 DEF PROCerrorruntime
19102 LOCAL cb%,ci%,cp%,cv%,cs%,cs$,cj%
19104 cb%=cpc%:FOR ci%=0 TO cesize%-1:PROCbyte(ceimage%?ci%):NEXT
19106 FOR ci%=0 TO cerelocs%-1:cp%=cb%+cereloc%(ci%):cv%=ccode%?cp%+256*ccode%?(cp%+1)+65536*ccode%?(cp%+2):PROCpatch(cp%,cv%+&40000+cb%):NEXT
19108 cs$="errinit|errinstall|errraise|errinline|errreport|errline|errcode|errcurrent|errlastline|errmsg|errstate|":cp%=1
19110 FOR ci%=0 TO 10:cj%=INSTR(cs$,"|",cp%):PROCctlexport("$"+MID$(cs$,cp%,cj%-cp%),cb%+ceentry%(ci%)):cp%=cj%+1:NEXT
19112 cs$="$ctlpush|$strload|$strstore|$error|$ctltop|$acttop|$ctlframes|$actbase|$actlimit|$savedsp|$depth|$sheapctx|":cp%=1:cs%=cpc%
19114 FOR ci%=11 TO 22:cj%=INSTR(cs$,"|",cp%):cpc%=cb%+ceentry%(ci%):PROCaddr("",MID$(cs$,cp%,cj%-cp%)):cp%=cj%+1:NEXT:cpc%=cs%
19116 ENDPROC
