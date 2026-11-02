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

; Slices/comparison adapt EVAL.Z80 LEFT1/RIGHT1/MIDS/SCP0, baseline
; 2998edd4ceb6030d6840cb4e3d587e75d94dc44c, Richard T. Russell 1981-2025.
; Altered standalone interfaces; repository license.txt applies. No ACCS,
; page alignment, expression parser, alternate-register or error-state imports.
    .global rt_strleft,rt_strright,rt_strmid,rt_strcompare

; IX=length-prefixed buffer, A=already-SFIX-converted low-byte count.
; Keep first min(count,length) bytes. IX/IY/SP preserved, others volatile.
rt_strleft:
    cp (ix+0)
    ret nc
    ld (ix+0),a
    ret

; IX=buffer, A=count low byte. Keep final min(count,length) bytes.
rt_strright:
    ld c,a
    ld a,(ix+0)
    cp c
    ret c
    ret z
    sub c
    ld b,c
    jr str_slice_move

; IX=buffer, A=one-based start low byte. Zero preserves the full string.
; Start beyond length gives empty. IX/IY/SP preserved, others volatile.
rt_strmid:
    or a
    ret z
    dec a
    ld c,a
    ld a,(ix+0)
    sub c
    jr c,str_slice_empty
    jr z,str_slice_empty
    ld b,a
    ld a,c
str_slice_move:
    ld (ix+0),b
    push ix
    pop hl
    inc hl
    push hl
    pop de
    ld bc,0          ; Clear all count/offset bits, including poisoned BCU.
    ld c,a
    add hl,bc
    ld c,(ix+0)
    ld a,c
    or a
    ret z            ; LDIR with zero would copy 2^24 bytes.
    ldir
    ret
str_slice_empty:
    xor a
    ld (ix+0),a
    ret

; IX=lhs buffer, IY=rhs buffer. Unsigned byte lexicographic ordering.
; A=255 less, 0 equal, 1 greater. Input bytes unchanged, including length.
; IX/IY/SP preserved; flags and BC/DE/HL volatile. No wide memory access.
rt_strcompare:
    ld b,(ix+0)
    ld c,(iy+0)
    push ix
    pop hl
    inc hl
    push iy
    pop de
    inc de
str_compare_loop:
    ld a,b
    or a
    jr z,str_compare_left_end
    ld a,c
    or a
    jr z,str_compare_greater
    ld a,(de)
    cp (hl)
    jr c,str_compare_greater
    jr nz,str_compare_less
    inc hl
    inc de
    dec b
    dec c
    jr str_compare_loop
str_compare_left_end:
    ld a,c
    or a
    ret z
str_compare_less:
    ld a,255
    ret
str_compare_greater:
    ld a,1
    ret

; Search/repetition adapt baseline EVAL.Z80 INSTR/SEARCH/STRING/STRIN1.
; Richard T. Russell 1981-2025; altered standalone ABI, same license.txt.
    .global rt_strinstr,rt_strrepeat

; IX=read-only main buffer, IY=read-only needle buffer, A=start low byte.
; A=result 0..255 (0=not found); IX/IY/SP preserved, other registers/flags
; volatile. Start 0 and 1 both search from the beginning. Empty needle returns
; 0: reference SEARCH's remaining<=254 test always rejects its B=0 case.
rt_strinstr:
    push af
    ld a,(ix+0)
    or a
    jr z,str_search_empty
    ld a,(iy+0)
    or a
    jr z,str_search_empty
    ld bc,0
    ld c,(ix+0)
    ld b,(iy+0)
    push ix
    pop hl
    inc hl
    push iy
    pop de
    inc de
    pop af
    or a
    jr z,str_search_offset
    dec a
str_search_offset:
    push hl
    call str_search
    pop de
    jr nz,str_search_missing
    or a
    sbc hl,de
    ld a,l
    ret
str_search_empty:
    pop af
str_search_missing:
    xor a
    ret

; Adapted SEARCH byte algorithm. HL=main data, C=length, DE=needle data,
; B=nonzero length, A=zero-based offset. Z=found at HL-1, NZ=not found.
str_search:
    push bc
    ld bc,0
    ld c,a
    add hl,bc
    pop bc
    sub c
    jr nc,str_search_not_found
    neg
    ld c,a
str_search_next:
    ld a,(de)
    push bc
    push af
    ld a,c
    ld bc,0
    ld c,a
    pop af
    cpir
    ld a,c
    pop bc
    jr nz,str_search_not_found
    ld c,a
    dec b
    cp b
    inc b
    jr c,str_search_not_found
    push bc
    push de
    push hl
    dec b
    jr z,str_search_matched
str_search_compare:
    inc de
    ld a,(de)
    cp (hl)
    jr nz,str_search_matched
    inc hl
    djnz str_search_compare
str_search_matched:
    pop hl
    pop de
    pop bc
    jr nz,str_search_next
    xor a
    ret
str_search_not_found:
    or 0xff
    ret

; IX=private 256-byte expression buffer, A=repeat count low byte.
; Success A=0/Z/NC. Overflow A=19/NZ/C, buffer unchanged. IX/IY/SP preserved.
; Precheck length*count instead of partially filling ACCS then overflowing.
; On success LDIR repeats the original pattern through its newly copied prefix.
rt_strrepeat:
    or a
    jr z,str_repeat_clear
    ld bc,0
    ld b,a
    ld c,(ix+0)
    ld a,c
    or a
    ret z
    mlt bc
    ld a,b
    or a
    jp nz,str_too_long
    ld a,c
    ld b,(ix+0)
    ld (ix+0),a
    sub b
    jr z,str_repeat_done
    ld c,b
    ld b,0
    push ix
    pop hl
    inc hl
    push hl
    pop de
    add hl,bc
    ex de,hl
    ld c,a
    ldir
str_repeat_done:
    xor a
    ret
str_repeat_clear:
    ld (ix+0),a
    ret

; Altered EXEC.Z80 SUBSL0..9, same Richard T. Russell/repository license.
; IX=existing five-byte descriptor, IY=read-only RHS length-prefixed buffer.
; L=first/H=last byte marker (upper HL ignored). No resize/allocation.
; IX/IY/SP preserved; success A=0/Z/NC; other registers volatile.
    .global rt_strwrite
rt_strwrite:
    ld bc,0
    ld b,h
    ld c,l
    push bc
    pop hl            ; Explicitly clear upper offset bits.
    ld bc,0
    ld c,(iy+0)
    ld b,(ix+0)
    ld de,(ix+2)      ; ADL24 OK: descriptor's exact three-byte pointer.
    ld a,l
    inc a
    jr nz,str_write_normal
    inc h
    inc h
    ld a,c
    cp h
    jr nc,str_write_right
    ld h,a
str_write_right:
    ld a,b
    sub h
    jr nc,str_write_right_start
    xor a
str_write_right_start:
    ld l,a
    jr str_write_clamp
str_write_normal:
    ld a,h
    inc a
    jr nz,str_write_bounds
    ld a,b
    sub 2
    jr c,str_write_done
    ld h,a
str_write_bounds:
    ld a,l
    cp b
    jr nc,str_write_done
    ld a,h
    cp b
    jr c,str_write_size
str_write_clamp:
    ld a,b
    dec a
    ld h,a
str_write_size:
    ld a,h
    sub l
    jr c,str_write_done
    inc a
    cp c
    jr c,str_write_copy
    ld a,c
str_write_copy:
    ld bc,0
    ld h,b
    ld c,a
    or a
    jr z,str_write_done
    ex de,hl
    add hl,de
    ex de,hl
    push iy
    pop hl
    inc hl
    ldir
str_write_done:
    xor a
    ret
