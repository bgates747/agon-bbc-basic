; C004 typed native control records. New standalone implementation guided by
; EXEC.Z80 loop/marker semantics; no interpreter state or entry ABI is linked.
    .assume adl=1
    .text
    .global ctl_init,ctl_push,ctl_check,ctl_pop,ctl_until,ctl_again
    .global ctl_for,ctl_next,ctl_numslot,ctl_top,ctl_frames,ctl_frames_end
ctl_init:
    ld hl,ctl_frames
    ld (ctl_top),hl             ; ADL24 OK: next-free record pointer
    ret
; A=type, HL=body/test, DE=variable, B=width. IX/IY preserved.
ctl_push:
    push ix
    push hl
    push bc
    push de
    push af
    ld ix,(ctl_top)             ; ADL24 OK: record pointer
    ld hl,ctl_frames_end
    push ix
    pop bc
    or a
    sbc hl,bc
    jr z,ctl_full
    pop af
    pop de
    pop bc
    pop hl
    ld (ix+0),a
    ld (ix+2),hl                ; ADL24 OK: record body pointer bytes2..4
    ld (ix+5),de                ; ADL24 OK: variable pointer bytes5..7
    ld (ix+8),b
    ld bc,32
    add ix,bc
    ld (ctl_top),ix             ; ADL24 OK: record pointer
    pop ix
    xor a
    ret
ctl_full:
    pop af
    pop de
    pop bc
    pop hl
    pop ix
    xor a                      ; error0 -> No room in compiler bridge
    scf
    ret
; A=expected type. Success HL=top record, A=0/NC. Does not pop.
ctl_check:
    ld c,a
    ld hl,(ctl_top)             ; ADL24 OK: record pointer
    ld de,ctl_frames
    or a
    sbc hl,de
    jr z,ctl_missing
    ld hl,(ctl_top)
    ld de,32
    or a
    sbc hl,de
    ld a,(hl)
    cp c
    jr nz,ctl_missing
    xor a
    ret
ctl_missing:
    ld a,c
    cp 1
    ld a,43
    jr z,ctl_fail
    ld a,c
    cp 2
    ld a,46
    jr z,ctl_fail
    ld a,c
    cp 3
    ld a,32
    jr z,ctl_fail
    ld a,38
ctl_fail:
    or a
    scf
    ret
; Caller has checked top. IX/IY preserved, DE volatile.
ctl_pop:
    ld hl,(ctl_top)
    ld de,32
    or a
    sbc hl,de
    ld (ctl_top),hl
    xor a
    ret
; A=already converted condition OR of four bytes.
ctl_until:
    push af
    ld a,1
    call ctl_check
    pop bc
    ret c
    ld a,b
    or a
    jp nz,ctl_pop
    inc hl
    inc hl
    ld hl,(hl)                 ; ADL24 OK: body pointer bytes2..4
    pop de                     ; discard only ctl_until continuation
    jp (hl)
ctl_again:
    ld a,2
    call ctl_check
    ret c
    inc hl
    inc hl
    ld hl,(hl)                 ; ADL24 OK: condition pointer bytes2..4
    pop de
    jp (hl)
; IX=limit, IY=step, HL=body, DE=variable, B=physical width.
ctl_for:
    ld a,3
    call ctl_push
    ret c
    push ix
    push iy
    push ix
    pop de
    ld ix,(ctl_top)
    ld bc,-32
    add ix,bc
    push ix
    pop hl
    ld bc,9
    add hl,bc
    ex de,hl
    ld bc,5
    ldir
    push iy
    pop hl
    ld bc,5                    ; DE already points to step at offset14
    ldir
    ld a,(iy+3)
    and 128
    ld (ix+19),a
    pop iy
    pop ix
    xor a
    ret
; DE=requested variable pointer, or0 for current FOR.
ctl_next:
    push ix
    push iy
    push de
    ld a,3
    call ctl_check
    pop de
    jp c,ctl_next_done
ctl_next_select:
    push hl
    pop iy
    ld hl,0
    or a
    sbc hl,de
    jr z,ctl_next_match
    ld hl,(iy+5)               ; ADL24 OK: variable pointer
    or a
    sbc hl,de
    jr z,ctl_next_match
    push de
    call ctl_pop
    ld a,3
    call ctl_check
    pop de
    jr nc,ctl_next_select
    ld a,33
    scf
    jp ctl_next_done
ctl_next_match:
    ld hl,0
    ld (ctl_value),hl           ; ADL24 OK: numeric bytes0..2
    ld (ctl_value+2),hl         ; ADL24 OK: numeric bytes2..4, bounded overlap
    ld hl,(iy+5)
    ld de,ctl_value
    ld bc,0
    ld c,(iy+8)
    ldir
    ld ix,ctl_value
    push iy
    push iy
    pop hl
    ld de,14
    add hl,de
    push hl
    pop iy
    ld a,11
    call ctl_numeric
    pop iy
    jr c,ctl_next_done
    ld a,(iy+8)
    cp 5
    jr z,ctl_next_store
    push iy
    push ix
    pop iy
    ld a,38
    call ctl_numeric
    pop iy
    jr c,ctl_next_done
ctl_next_store:
    ld hl,ctl_value
    ld de,(iy+5)
    ld bc,0
    ld c,(iy+8)
    ldir
    ld a,(iy+19)
    or a
    ld a,12                    ; nonnegative: terminate updated > limit
    jr z,ctl_next_compare
    ld a,8                     ; negative: terminate updated < limit
ctl_next_compare:
    push iy
    push af
    push iy
    pop hl
    ld de,9
    add hl,de
    push hl
    pop iy
    pop af
    call ctl_numeric
    pop iy
    jr c,ctl_next_done
    ld a,(ctl_value)
    or a
    jr z,ctl_next_repeat
    call ctl_pop
ctl_next_done:
    pop iy
    pop ix
    ret
ctl_next_repeat:
    ld hl,(iy+2)
    pop iy
    pop ix
    pop de
    jp (hl)
ctl_numeric:
    .byte 0xc3
ctl_numslot:
    .d24 0                     ; compiler patches to qualified numeric adapter
ctl_value:
    .space 5
ctl_top:
    .d24 0
ctl_frames:
    .space 8192
ctl_frames_end:
