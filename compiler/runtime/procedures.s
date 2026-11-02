; C004 standalone PROC/LOCAL runtime. The EXEC.Z80 audit defines semantics;
; no interpreter parser, global state or entry address is linked.
    .assume adl=1
    .text
    .global act_init,act_begin,act_save,act_install,act_bind,act_leave
    .global act_fn_begin,act_fn_leave
    .global act_pushslot,act_checkslot,act_popslot,act_numslot,act_top
; HL=arena base, DE=exclusive limit. Caller preserves MOS DE at entry.
act_init:
    ld (act_top),hl             ; ADL24 OK: arena pointer
    ld (act_limit),de           ; ADL24 OK: exclusive arena limit
    ret
act_begin:
    ld hl,(act_top)
    ld a,5
    jp act_push
; IX=binding flag immediately followed by physical value; A=type1/4/5/129.
; Save first, leaving current value visible until actual arguments finish.
; Success HL=private save record; IX/IY/SP preserved.
act_save:
    push ix
    push iy
    push af
    ld a,6
    call act_check
    jr nc,act_save_context
    ld a,5
    call act_check
    jr nc,act_save_context
    ld a,7
    call act_check
    jp c,act_save_badcontext
act_save_context:
    pop af
    ld c,a
    ld b,a
    cp 129
    jr nz,act_save_width
    ld b,5
act_save_width:
    ld a,(ix+0)
    or a
    jr nz,act_save_exists
    ld (ix+0),1
    push ix
    pop hl
    inc hl
    xor a
act_save_create:
    ld (hl),a
    inc hl
    djnz act_save_create
act_save_exists:
    ld a,c
    push af
    ld de,14
    cp 129
    jr nz,act_save_size
    ld de,269
act_save_size:
    ld hl,(act_top)
    add hl,de
    ld de,(act_limit)
    or a
    sbc hl,de
    jr c,act_save_space
    jr z,act_save_space
    pop af
    xor a
    scf
    jp act_save_done
act_save_space:
    ld hl,(act_top)
    pop af
    ld de,14
    cp 129
    jr nz,act_save_next
    ld de,269
act_save_next:
    add hl,de
    ld (act_candidate),hl       ; ADL24 OK: checked candidate pointer
    ld iy,(act_top)
    push ix
    pop hl
    ld (iy+0),hl                ; ADL24 OK: saved flag pointer bytes0..2
    inc hl
    ld (iy+3),hl                ; ADL24 OK: saved value pointer bytes3..5
    ld (iy+6),a
    ld bc,0
    ld c,a
    cp 129
    jr nz,act_save_copy
    ld c,5
act_save_copy:
    push iy
    pop de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    ldir
    ld hl,(act_top)
    ld a,6
    call act_push
    jr c,act_save_done
    ld hl,(act_candidate)
    ld (act_top),hl
    push iy
    pop hl
    xor a
act_save_done:
    pop iy
    pop ix
    ret
act_save_badcontext:
    pop af
    ld a,12
    scf
    jr act_save_done
; HL=save record. Install zero numeric / fresh empty owned string.
act_install:
    push ix
    push iy
    push hl
    pop ix
    ld iy,(ix+3)
    ld a,(ix+6)
    cp 129
    jr z,act_install_string
    ld b,a
    push iy
    pop hl
    xor a
act_install_zero:
    ld (hl),a
    inc hl
    djnz act_install_zero
    jr act_install_done
act_install_string:
    ld (iy+0),0
    ld (iy+1),255
    push ix
    pop hl
    ld de,14
    add hl,de
    ld (iy+2),hl                ; ADL24 OK: descriptor pointer bytes2..4
act_install_done:
    pop iy
    pop ix
    xor a
    ret
; A=ordinal from most recent formal record; IY=actual five-byte numeric or
; length-prefixed string. Bind in reverse order after every actual is evaluated.
act_bind:
    push ix
    push iy
    push af
    ld a,6
    call act_check
    pop bc
    jp c,act_bind_bad
    push hl
    ld hl,0
    ld l,b
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ex de,hl
    pop hl
    or a
    sbc hl,de
    inc hl
    inc hl
    ld hl,(hl)                 ; ADL24 OK: save-record pointer in control record
    push hl
    pop ix
    call act_install
    ld a,(ix+6)
    cp 129
    jr z,act_bind_string
    cp 5
    jr z,act_bind_numeric
    push ix
    push iy
    pop ix
    ld a,38
    call act_numeric
    pop ix
    jr c,act_bind_done
act_bind_numeric:
    ld bc,0
    ld c,(ix+6)
    ld de,(ix+3)
    push iy
    pop hl
    ldir
    xor a
    jr act_bind_done
act_bind_string:
    ld a,(iy+0)
    ld de,(ix+3)
    ld (de),a
    or a
    jr z,act_bind_done
    ld bc,0
    ld c,a
    push ix
    pop hl
    ld de,14
    add hl,de
    ex de,hl
    push iy
    pop hl
    inc hl
    ldir
    xor a
act_bind_done:
    pop iy
    pop ix
    ret
act_bind_bad:
    ld a,12
    scf
    jr act_bind_done
; Restore LOCAL records, then require the distinct PROC marker.
act_leave:
    ld a,5
    jr act_leave_start
act_fn_leave:
    ld a,7
act_leave_start:
    ld (act_leave_kind),a
    push ix
    push iy
act_leave_loop:
    ld a,6
    call act_check
    jr c,act_leave_marker
    inc hl
    inc hl
    ld hl,(hl)                 ; ADL24 OK: save record pointer
    push hl
    pop ix
    ld (act_top),hl             ; LIFO reclamation; ordinary heap unaffected
    ld de,(ix+3)
    ld bc,0
    ld c,(ix+6)
    ld a,c
    cp 129
    jr nz,act_leave_copy
    ld c,5
act_leave_copy:
    push ix
    pop hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ldir
    call act_pop
    jr act_leave_loop
act_leave_marker:
    ld a,(act_leave_kind)
    call act_check
    jr c,act_leave_bad
    push hl
    pop ix
    ld a,(act_leave_kind)
    cp 7
    jr nz,act_leave_checkpoint
    ld hl,(ix+2)               ; ADL24 OK: arena checkpoint/prefix source
    ld de,(ix+5)               ; ADL24 OK: caller numeric pool
    ld a,(ix+8)
    or a
    jr z,act_leave_strings
    ld bc,0
    ld b,a
    ld c,5
    mlt bc
    ldir
act_leave_strings:
    ld de,(ix+9)               ; ADL24 OK: caller string pool
    ld a,(ix+12)
    or a
    jr z,act_leave_checkpoint
    ld bc,0
    ld b,a                     ; full24 count = string_count *256
    ldir
act_leave_checkpoint:
    ld hl,(ix+2)
    ld (act_top),hl
    call act_pop
    jr act_leave_done
act_leave_bad:
    ld a,(act_leave_kind)
    cp 7
    ld a,7
    jr z,act_leave_failure
    ld a,13
act_leave_failure:
    scf
act_leave_done:
    pop iy
    pop ix
    ret
 ; B=numeric prefix count, C=string prefix count, IX/IY=pool starts.
; Save caller prefixes in a separate bounded FN activation before actuals.
act_fn_begin:
    push ix
    push iy
    ld (act_fn_num),ix          ; ADL24 OK: synchronous leaf scratch pointer
    ld (act_fn_str),iy
    ld a,b
    ld (act_fn_n),a
    ld a,c
    ld (act_fn_s),a
    ld hl,(act_top)
    ld (act_fn_checkpoint),hl
    ld de,0
    ld d,c                     ; full24 count = string_count *256
    ld a,(act_fn_n)
    ld bc,0
    ld b,a
    ld c,5
    mlt bc
    add hl,bc
    add hl,de
    ld (act_candidate),hl
    ld de,(act_limit)
    or a
    sbc hl,de
    jr c,act_fn_space
    jr z,act_fn_space
    xor a
    scf
    jp act_fn_done
act_fn_space:
    ld hl,(act_fn_checkpoint)
    ld a,7
    call act_push
    jp c,act_fn_done
    ld a,7
    call act_check
    jp c,act_fn_done
    push hl
    pop ix
    ld de,(act_fn_num)
    ld (ix+5),de               ; ADL24 OK: caller numeric pool bytes5..7
    ld a,(act_fn_n)
    ld (ix+8),a
    ld de,(act_fn_str)
    ld (ix+9),de               ; ADL24 OK: caller string pool bytes9..11
    ld a,(act_fn_s)
    ld (ix+12),a
    ld de,(act_fn_checkpoint)
    ld hl,(act_fn_num)
    ld a,(act_fn_n)
    or a
    jr z,act_fn_strings
    ld bc,0
    ld b,a
    ld c,5
    mlt bc
    ldir
act_fn_strings:
    ld hl,(act_fn_str)
    ld a,(act_fn_s)
    or a
    jr z,act_fn_finish
    ld bc,0
    ld b,a
    ldir
act_fn_finish:
    ld hl,(act_candidate)
    ld (act_top),hl
    xor a
act_fn_done:
    pop iy
    pop ix
    ret
act_push:
    .byte 0xc3
act_pushslot: .d24 0
act_check:
    .byte 0xc3
act_checkslot: .d24 0
act_pop:
    .byte 0xc3
act_popslot: .d24 0
act_numeric:
    .byte 0xc3
act_numslot: .d24 0
act_top: .d24 0
act_limit: .d24 0
act_candidate: .d24 0
act_leave_kind: .byte 0
act_fn_num: .d24 0
act_fn_str: .d24 0
act_fn_checkpoint: .d24 0
act_fn_n: .byte 0
act_fn_s: .byte 0
