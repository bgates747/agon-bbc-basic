"""Prepare BBC emitter use of independently qualified native call adapters.
Text preparation only; the BBC compiler still parses and compiles every input.
"""
from pathlib import Path
import hashlib,re
T=Path(__file__).resolve().parent;s=(T/'compiler.bas').read_text();assert hashlib.sha256(s.encode()).hexdigest()=='558c39a9656a46c5799a209c957fdfce48a9fafbb93bc08bfe5b50fe9f53a30b'
def change(a,b):
 global s
 assert s.count(a)==1,a
 s=s.replace(a,b)
def block(a,b,new):
 global s
 i=s.index(a);j=s.index(b,i);s=s[:i]+new+'\n'+s[j:]
change('1028 PROCloadstrings:PROCloadmemory:PROCloadio:PROCloaddata:PROCloaderrors','1028 PROCloadstrings:PROCloadmemory:PROCloadio:PROCloaddata:PROCloaderrors:PROCloadcompact')
change('1063 memory%=FALSE:dimparse%=0:io%=FALSE:fileio%=FALSE','1063 memory%=FALSE:dimparse%=0:io%=FALSE:fileio%=FALSE:compact%=FALSE')
change('3231 IF memory% PROCmemoryworkspace\n3232 IF acts% PROCactworkspace\n3233 ENDPROC','3231 IF compact% PROCcompactruntime\n3232 IF memory% PROCmemoryworkspace\n3233 IF acts% PROCactworkspace\n3234 ENDPROC')
# Coalesce only adjacent register-setup/NUM-call pairs. Keep the old routines
# for VDU's separate lines and FOR/DIM entries requiring explicit IX/IY setup.
s,n=re.subn(r'PROCnumindices\(([^(),]+),([^()]+)\):PROCnumcall\(([^()]+)\)',r'PROCnumoperation(\1,\2,\3)',s);assert n>=15,n
change('4180 PROCnumslot:valuekind%=0:PROCaddr("DD21","$v"+STR$(ndepth%-1))','4180 PROCnumslot:valuekind%=0:PROCusecompact:PROCaddr("CD","$cplit"):PROCbyte(ndepth%-1)')
change('4190 PROCaddr("CD","$numlit"):p%=^v','4190 p%=^v')
change('5187 PROCnumslot:PROCaddr("DD21","$v"+STR$(ndepth%-1)):PROCaddr("CD","$numlit")','5187 PROCnumslot:PROCusecompact:PROCaddr("CD","$cplit"):PROCbyte(ndepth%-1)')
block('6230 IF t%<>5','6250 ENDPROC','6230 PROCusecompact:PROCaddr("CD","$cpstore"+STR$(t%))\n6240 PROCaddr("","$var"+STR$(i%)):ndepth%=0')
block('16632 PROCaddr','16638 valuekind%', '16632 PROCusecompact:PROCnumslot:PROCaddr("CD","$cpread"+STR$(t%))\n16634 PROCaddr("","$bind"+STR$(i%)):PROCbyte(ndepth%-1)')
change('13680 PROCuseacts:PROCaddr("CD","$actbegin"):PROCaddr("DA","$acterror"):count%=parcnt&(i%)','13680 PROCuseacts:PROCusecompact:PROCaddr("CD","$cpbegin"):count%=parcnt&(i%)')
block('13840 LOCAL n$','13860 ENDPROC','13840 PROCusecompact:PROCaddr("CD","$cpbind")\n13850 PROCbyte(o%):PROCbyte(argkind&(frame%,i%)):PROCbyte(argindex&(frame%,i%))')
change('13880 PROCaddr("DD21","$bind"+STR$(i%)):PROCbyte(&3E):PROCbyte(vtype%(i%)):PROCaddr("CD","$actsave"):PROCaddr("DA","$acterror")','13880 PROCusecompact:PROCaddr("CD","$cpsave"):PROCaddr("","$bind"+STR$(i%)):PROCbyte(vtype%(i%))')
# DIM retains its old HL allocation-context contract. Only prefix/address
# calls use the new adapter, whose num_ptr scratch changes HL before entry.
change('16488 PROCaddr("DD21","$var"+STR$(i%)):PROCaddr("FD21","$v"+STR$(s%))','164881 IF r$="$arrayprefix" OR r$="$arrayaddr" THEN\n164882 PROCusecompact:IF r$="$arrayprefix" THEN PROCaddr("CD","$cpprefix") ELSE PROCaddr("CD","$cpaddr")\n164883 PROCaddr("","$var"+STR$(i%)):PROCbyte(s%):PROCbyte(FNmemwidth(i%)):PROCbyte(n%):ENDPROC\n164884 ENDIF\n164885 PROCaddr("DD21","$var"+STR$(i%)):PROCaddr("FD21","$v"+STR$(s%))')
# Renumber this tiny routine inside its existing gap, keeping all loader lines
# <=65279 and each function/procedure call named rather than numeric.
a=s.index('16486 DEF PROCarraycall');b=s.index('16494 DEF PROCarrayaddress',a);rows=s[a:b].splitlines();s=s[:a]+'\n'.join(f'{16486+i} {row.split(" ",1)[1]}' for i,row in enumerate(rows))+'\n'+s[b:]
change('19286 =ereloc%(i%)','19286 IF k%=7 THEN =ereloc%(i%)\n19287 =xreloc%(i%)')
# Names below are the already spread private identifiers.
change('19296 i%=0:j%=0:b%=&40000+pc%:t%=0:IF k%=7 t%=11','19296 i%=0:j%=0:b%=&40000+pc%:t%=0:IF k%=7 t%=11\n19297 IF k%=8 t%=13')
change('19350 =-1','19349 IF k%=8 AND i%<=25 THEN =xentry%(i%)\n19350 =-1')
change('19366 IF k%=2 OR i%=3 THEN ="$numop"','19365 IF k%=8 THEN =FNcompactbridge(i%)\n19366 IF k%=2 OR i%=3 THEN ="$numop"')
a,b=s.split('20000 DATA',1);s=a+(T/'frontend.bas').read_text()+'20000 DATA'+b
s+=(T.parent/'build/compact-runtime/runtime_data.bas').read_text()
rows=s.splitlines();nums=[int(row.split()[0]) for row in rows];assert nums==sorted(set(nums)),[(a,b) for a,b in zip(nums,nums[1:]) if a>=b]
assert max(len(row.split(' ',1)[1]) for row in rows)<=255
assert max(nums)<=65279
defs=re.findall(r'^\d+ DEF (PROC|FN)([A-Za-z_][A-Za-z0-9_]*[$%&]?)',s,re.M);assert len(defs)==len(set(defs))
out=T/'integrated.bas';assert not out.exists(),'Preserve an existing candidate';out.write_text(s)
print('Prepared',len(rows),'lines,',len(defs),'definitions, coalesced',n,'NUM pairs:',hashlib.sha256(s.encode()).hexdigest())
