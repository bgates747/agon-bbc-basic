; C005 explicit DATA record helpers. Repository zlib license applies.
; READ/FETCHS/READ2 in EXEC.Z80 guide ordering; no interpreter state/parser.
; Record: len8,error8,numeric5,reserved8,raw[len]. Context: cursor24,end24.
    .assume adl=1
    .text
    .global data_peek,data_number,data_string,data_commit

; IX=context, IY=numeric5 capture. Check exhaustion BEFORE resolving destination.
; Success captures record pointer and clears packet's upper byte/exponent.
; IX/IY/SP preserved; AF/BC/DE/HL volatile. Error42/C leaves capture untouched.
data_peek:
    ld hl,(ix+0)
    ld de,(ix+3)
    push hl
    or a
    sbc hl,de
    pop hl
    jr nc,data_exhausted
    ld (iy+0),hl
    xor a
    ld (iy+3),a
    ld (iy+4),a
    ret
data_exhausted:
    ld a,42
    or a
    scf
    ret

; IX=numeric5 destination,IY=captured record. No cursor advance here.
; Return deferred field error/C without changing destination, or A0/Z/NC.
data_number:
    ld a,(iy+1)
    or a
    jr nz,data_bad_number
    push ix
    push iy
    push iy
    pop hl
    inc hl
    inc hl
    push ix
    pop de
    ld bc,5
    ldir
    pop iy
    pop ix
    xor a
    ret
data_bad_number:
    scf
    ret

; IX=string256 destination,IY=captured record. Copy exact raw bytes, length<=255.
; Do not inspect numeric error metadata. Empty input leaves logical tail alone.
data_string:
    push ix
    push iy
    ld bc,0
    ld c,(iy+0)
    ld (ix+0),c
    ld a,c
    or a
    jr z,data_string_done
    push iy
    pop hl
    ld de,8
    add hl,de
    push ix
    pop de
    inc de
    ldir
data_string_done:
    pop iy
    pop ix
    xor a
    ret

; IX=context,IY=captured record, not necessarily the current cursor.
; Called only AFTER conversion/storage succeeds. Nested READ/RESTORE cannot
; replace the outer record's committed next address.
data_commit:
    push iy
    pop hl
    ld de,0
    ld e,(iy+0)
    add hl,de
    ld de,8
    add hl,de
    ld (ix+0),hl
    xor a
    ret
