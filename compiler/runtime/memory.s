; C005 standalone allocation/array adapter. DIM/GETV3 semantics follow
; include/bbc-ez80/EXEC.Z80 and MAIN.Z80. mul24 is an explicitly altered
; adaptation of EXEC.Z80 MUL24 using private scratch instead of R0.
; Copyright (c) 2024 Richard T. Russell; repository license.txt applies.
; No interpreter globals, parser entries, or alternative numeric format.
    .assume adl=1
    .text
    .global mem_alloc,array_dim,array_addr,dim_step,array_prefix

; IX={u24 free,u24 limit}, HL=count. Zero count is valid.
; Success DE=old free, HL=new free, A0/Z/NC. Failure A11/NZ/C, no writes.
; IX/IY/SP preserved, AF/BC/DE/HL volatile. Entire allocation is zeroed.
mem_alloc:
    push hl
    ld de,(ix+0)               ; ADL24: explicit context pointer.
    add hl,de
    jr c,alloc_overflow
    push hl
    ld bc,(ix+3)               ; ADL24: exclusive limit.
    or a
    sbc hl,bc
    jr c,alloc_valid
    jr z,alloc_valid
    pop hl
alloc_overflow:
    pop hl
    ld a,11
    or a
    scf
    ret
alloc_valid:
    pop hl
    ld (ix+0),hl               ; Commit after all range validation.
    pop bc
    push de
    push hl
    ld hl,0
    or a
    sbc hl,bc                  ; Test all24 count bits, not just BC's low16.
    jr z,alloc_zero_done
    ex de,hl
    ld (hl),0
    push hl
    pop de
    inc de
    dec bc
    push hl
    ld hl,0
    or a
    sbc hl,bc
    pop hl
    jr z,alloc_zero_done
    ldir
alloc_zero_done:
    pop hl
    pop de
    xor a
    ret

; IX=5-byte positive running product; IY=5-byte SFIX bound.
; Validate before the next BASIC dimension expression can run.
dim_step:
    ld a,(iy+3)
    or a
    jr nz,step_bad
    ld hl,(iy+0)
    inc hl
    ld de,0
    or a
    sbc hl,de
    jr z,step_space
    push hl
    pop bc
    ld hl,(ix+0)
    call mul24
    jr c,step_space
    ld (ix+0),hl
    xor a
    ret
step_bad:
    ld a,10
    or a
    scf
    ret
step_space:
    ld a,11
    or a
    scf
    ret

; IX=pointer cell, IY=SFIX bounds (5bytes each), HL=allocation context.
; A=dimension count1..16, B=element width1/4/5. See ARRAYS.md.
array_dim:
    push ix
    push iy
    ld (work_cell),ix
    ld (work_context),hl
    ld (work_count),a
    ld (work_remaining),a
    ld a,b
    ld (work_width),a
    ld hl,(ix+0)
    ld de,0
    or a
    sbc hl,de
    jp nz,dim_bad
    ld a,(work_count)
    or a
    jp z,dim_bad
    cp 17
    jp nc,dim_bad
    ld (work_descriptor),a
    ld ix,work_descriptor+1
    ld hl,1
    ld (work_product),hl
dim_next:
    ld a,(iy+3)                ; SFIX high integer byte must be zero.
    or a
    jp nz,dim_bad
    ld hl,(iy+0)               ; ADL24: low24 bits of four-byte integer.
    inc hl
    ld de,0
    or a
    sbc hl,de
    jp z,dim_space
    ld (ix+0),hl               ; Inclusive count, exactly three bytes.
    push hl
    pop bc
    ld hl,(work_product)
    call mul24
    jp c,dim_space
    ld (work_product),hl
    ld de,5
    add iy,de
    inc ix
    inc ix
    inc ix
    ld a,(work_remaining)
    dec a
    ld (work_remaining),a
    jr nz,dim_next
    ld bc,0
    ld a,(work_width)
    ld c,a
    call mul24
    jp c,dim_space
    push hl
    ld hl,0x300
    ld a,(work_count)
    ld l,a
    mlt hl
    inc hl                     ; Descriptor bytes = 1 +3*dimensions.
    ld (work_descriptor_size),hl
    pop de
    add hl,de
    jp c,dim_space
    ld ix,(work_context)
    call mem_alloc
    jp c,array_fail
    ld hl,(work_cell)
    ld (hl),de                 ; ADL24: array pointer cell.
    ld hl,work_descriptor
    ld bc,(work_descriptor_size)
    ldir                       ; Descriptor count is always at least four.
    jp array_ok
dim_bad:
    ld a,10
    jr array_fail
dim_space:
    ld a,11
array_fail:
    pop iy
    pop ix
    or a
    scf
    ret
array_ok:
    pop iy
    pop ix
    xor a
    ret

; IX=pointer cell, IY=SFIX subscripts, A=count, B=element width.
; Success HL=element address; failure A14/15/5/27 and carry.
array_addr:
    push ix
    push iy
    push af
    ld a,1
    ld (work_full),a
    pop af
    jr address_start
array_prefix:
    push ix
    push iy
    push af
    xor a
    ld (work_full),a
    pop af
address_start:
    ld (work_count),a
    ld (work_remaining),a
    ld a,b
    ld (work_width),a
    ld hl,(ix+0)
    ld de,2                    ; Null and LOCAL's special pointer1 are invalid.
    or a
    sbc hl,de
    jp c,address_missing
    add hl,de
    ld a,(hl)
    or a
    jp z,address_missing
    ld a,(work_full)
    or a
    jr z,address_partial_count
    ld a,(work_count)
    cp (hl)
    jp c,address_comma
    jp nz,address_bracket
    or a
    jp z,address_missing
    jr address_count_ok
address_partial_count:
    ld a,(work_count)
    cp (hl)
    jp z,address_count_ok
    jp nc,address_bracket
    or a
    jp z,array_ok
address_count_ok:
    inc hl
    push hl
    pop ix
    ld hl,0
    ld (work_product),hl
address_next:
    ld a,(iy+3)
    or a
    jp nz,address_bounds
    ld hl,(iy+0)
    ld (work_index),hl
    ld bc,(ix+0)
    or a
    sbc hl,bc
    jp nc,address_bounds
    ld hl,(work_product)
    call mul24
    jp c,address_bounds
    ld de,(work_index)
    add hl,de
    jp c,address_bounds
    ld (work_product),hl
    ld de,5
    add iy,de
    inc ix
    inc ix
    inc ix
    ld a,(work_remaining)
    dec a
    ld (work_remaining),a
    jr nz,address_next
    ld a,(work_full)
    or a
    jp z,array_ok
    ld bc,0
    ld a,(work_width)
    ld c,a
    call mul24
    jp c,address_bounds
    push ix
    pop de
    add hl,de
    jp c,address_bounds
    jp array_ok
address_missing:
    ld a,14
    jp array_fail
address_bounds:
    ld a,15
    jp array_fail
address_comma:
    ld a,5
    jp array_fail
address_bracket:
    ld a,27
    jp array_fail

; Altered EXEC.Z80 MUL24: private scratch, no interpreter R0.
; HL*multipler BC -> HL, carry on overflow. AF/BC/DE volatile.
mul24:
    ld (work_multiplier),bc
    ld de,0
    ex de,hl
multiply_next:
    ld a,(work_multiplier)
    bit 0,a
    jr z,multiply_noadd
    add hl,de
    ret c
multiply_noadd:
    ld a,(work_multiplier+2)
    srl a
    ld (work_multiplier+2),a
    ld a,(work_multiplier+1)
    rr a
    ld (work_multiplier+1),a
    ld a,(work_multiplier)
    rr a
    ld (work_multiplier),a
    ld c,a
    ld a,(work_multiplier+1)
    or c
    ld c,a
    ld a,(work_multiplier+2)
    or c
    ret z
    ex de,hl
    add hl,hl
    ex de,hl
    ret c
    jr multiply_next

work_cell: .d24 0
work_context: .d24 0
work_product: .d24 0
work_index: .d24 0
work_descriptor_size: .d24 0
work_multiplier: .d24 0
work_count: .byte 0
work_remaining: .byte 0
work_width: .byte 0
work_full: .byte 0
work_descriptor: .space 49,0
