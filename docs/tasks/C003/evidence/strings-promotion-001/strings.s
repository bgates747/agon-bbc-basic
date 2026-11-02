; C003 string core. New standalone glue adapted from the descriptor/storage
; conventions in baseline EXEC.Z80/EVAL.Z80. Same repository zlib license.
; No interpreter globals, parser entry points or fixed interpreter addresses.
    .assume adl=1
    .text
    .global rt_strliteral,rt_strload,rt_strcat,rt_strstore,rt_strprint

; IX=256-byte buffer; inline return payload is length byte then characters.
; IX/IY/SP preserved; AF/BC/DE/HL volatile. Consumes at least the length byte.
rt_strliteral:
    pop hl
    push ix
    pop de
    ld bc,0
    ld c,(hl)
    inc bc
    ldir
    push hl
    ret

; IX=buffer, IY=read-only 5-byte descriptor. Empty avoids its null pointer.
; Descriptor = u8 length, u8 capacity, u24 pointer. IX/IY/SP preserved.
rt_strload:
    ld a,(iy+0)
    ld (ix+0),a
    or a
    ret z
    ld bc,0
    ld c,a
    ld hl,(iy+2)       ; ADL24 OK: descriptor's exact three-byte pointer.
    push ix
    pop de
    inc de
    ldir
    ret

; IX=lhs buffer, IY=rhs buffer; append with alias-safe original lengths.
; Success A=0/Z/NC. Overflow A=19/NZ/C, lhs unchanged. IX/IY/SP preserved.
rt_strcat:
    ld a,(ix+0)
    ld b,a
    ld c,(iy+0)
    add a,c
    jr c,str_too_long
    ld (ix+0),a
    ld a,c
    or a
    ret z
    push ix
    pop hl
    inc hl
    ld de,0
    ld e,b
    add hl,de
    ex de,hl
    push iy
    pop hl
    inc hl
    ld bc,0
    ld c,a
    ldir
    xor a
    ret
str_too_long:
    ld a,19
    or a
    scf
    ret

; IX=destination descriptor, IY=completed expression buffer.
; HL=context: u24 FREE at +0, u24 exclusive limit at +3.
; Private ownership, capacity reuse and tail extension follow STORES; non-tail
; growth rounds to 2^k-1 after an existing allocation. No GC or globals.
; Success A=0/Z/NC; no room A=0/Z/C, descriptor/context unchanged.
; IX/IY/SP preserved. All other registers volatile.
rt_strstore:
    push ix
    push iy
    push hl
    ld a,(ix+1)
    cp (iy+0)
    jr nc,str_store_copy
    push iy
    push hl
    pop iy
    ld de,(iy+0)       ; ADL24 OK: context FREE pointer.
    ld hl,(iy+3)       ; ADL24 OK: context exclusive-limit pointer.
    pop iy
    push hl
    push de
    ld hl,(ix+2)       ; ADL24 OK: descriptor data pointer.
    ld bc,0
    ld c,(ix+1)
    add hl,bc
    or a
    sbc hl,de
    jr z,str_store_tail
    ld c,(iy+0)
    ld a,(ix+1)
    or a
    jr z,str_store_grow
    ld c,1
str_store_round:
    ld a,c
    cp (iy+0)
    jr nc,str_store_grow
    sla c
    inc c
    jr str_store_round
str_store_tail:
    ld de,(ix+2)       ; ADL24 OK: reuse tail's three-byte data pointer.
    ld c,(iy+0)
str_store_grow:
    ld a,c
    pop hl            ; discard old FREE copy
    pop hl            ; exclusive limit
    push de           ; chosen destination
    push hl           ; limit
    ex de,hl
    ld bc,0
    ld c,a
    add hl,bc         ; candidate new FREE
    or a
    sbc hl,de
    jr c,str_store_room
    jr z,str_store_room
    pop hl
    pop hl
    pop hl
    pop iy
    pop ix
    xor a
    scf
    ret
str_store_room:
    add hl,de         ; restore new FREE
    pop de            ; discard saved limit
    pop de            ; chosen destination
    pop bc            ; context address
    push bc
    push iy
    push bc
    pop iy
    ld (iy+0),hl      ; ADL24 OK: update context's exact FREE pointer.
    pop iy
    ld (ix+1),a
    ld (ix+2),de      ; ADL24 OK: descriptor's exact three-byte pointer.
str_store_copy:
    ld a,(iy+0)
    ld (ix+0),a
    or a
    jr z,str_store_done
    ld bc,0
    ld c,a
    ld de,(ix+2)      ; ADL24 OK: descriptor's exact three-byte pointer.
    push iy
    pop hl
    inc hl
    ldir
str_store_done:
    pop hl
    pop iy
    pop ix
    xor a
    ret

; IX=length-prefixed buffer; write exact bytes, including zero bytes.
; IX/IY/SP preserved. No NUL-terminated MOS string convention is used.
rt_strprint:
    ld b,(ix+0)
    ld a,b
    or a
    ret z
    push ix
    push iy
    push ix
    pop hl
    inc hl
str_print_loop:
    ld a,(hl)
    push bc
    push hl
    rst.lis 0x10
    pop hl
    pop bc
    inc hl
    djnz str_print_loop
    pop iy
    pop ix
    xor a
    ret
