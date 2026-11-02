; Direct native guards and calling-convention probe; no interpreter engine.
    .assume adl=1
    .text
    .global entry
    .extern rt_strinstr,rt_strrepeat
    .macro check value
    cp \value
    jp nz,failed
    .endm
    .macro preserved left,right
    push ix
    pop hl
    ld de,\left
    or a
    sbc hl,de
    jp nz,failed
    push iy
    pop hl
    ld de,\right
    or a
    sbc hl,de
    jp nz,failed
    ld hl,0
    add hl,sp
    ld de,(saved_sp) ; ADL24 OK: exactly three-byte stack address.
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro search left,right,start,result
    ld ix,\left
    ld iy,\right
    ld bc,0xabcdef
    ld a,\start
    call rt_strinstr
    check \result
    preserved \left,\right
    .endm
    jp entry
    .org 0x40
    .ascii "MOS"
    .byte 0,1
entry:
    push af
    push bc
    push de
    push ix
    push iy
    ld (saved_sp),sp ; ADL24 OK: exactly three-byte stack address.
    search full,last,1,255
    search full,last,255,255
    search full,lasttwo,0,254
    search full,lasttwo,255,0
    search full,full,1,1
    search full,full,2,0
    search full,empty,1,0
    search empty,last,0,0
    search overlaps,overlapneedle,1,3
    search high,highneedle,1,2
    search high,highneedle,3,5
    ; Check all search inputs, including maximum-length alias and guards.
    ld hl,full
    ld de,full_expected
    ld bc,257
check_full:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    dec bc
    ld a,b
    or c
    jr nz,check_full
    ld hl,inputs
    ld de,inputs_expected
    ld b,inputs_end-inputs
check_inputs:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    djnz check_inputs
    ld ix,repeat_buffer
    ld iy,last
    ld bc,0xfedcba
    ld a,86
    call rt_strrepeat
    jp nc,failed
    jp z,failed
    check 19
    preserved repeat_buffer,last
    ld a,(repeat_buffer)
    check 3
    ld a,(repeat_buffer+1)
    check 0
    ld a,(repeat_buffer+2)
    check 128
    ld a,(repeat_buffer+3)
    check 255
    ld hl,repeat_buffer+4
    ld b,252
check_overflow_unchanged:
    ld a,(hl)
    check 0xa5
    inc hl
    djnz check_overflow_unchanged
    ld bc,0xabc123
    ld a,85
    call rt_strrepeat
    jp c,failed
    jp nz,failed
    preserved repeat_buffer,last
    ld a,(repeat_buffer)
    check 255
    ld hl,repeat_buffer+1
    ld b,85
check_repetition:
    ld a,(hl)
    check 0
    inc hl
    ld a,(hl)
    check 128
    inc hl
    ld a,(hl)
    check 255
    inc hl
    djnz check_repetition
    ld a,1
    call rt_strrepeat
    jp c,failed
    preserved repeat_buffer,last
    ld a,(repeat_buffer)
    check 255
    ld a,2
    call rt_strrepeat
    jp nc,failed
    check 19
    preserved repeat_buffer,last
    ld a,(repeat_buffer)
    check 255
    xor a
    call rt_strrepeat
    jp c,failed
    preserved repeat_buffer,last
    ld a,(repeat_buffer)
    check 0
    ld bc,0xfedcba
    ld a,255
    call rt_strrepeat
    jp c,failed
    preserved repeat_buffer,last
    ld a,(repeat_buffer)
    check 0
    ld a,(guard_before)
    check 0xa5
    ld a,(guard_after)
    check 0x5a
    ; Empty and zero-count paths must not invoke LDIR with a zero count.
    ; Data from the prior maximum repetition remains intact after these calls.
    ld hl,repeat_buffer+1
    ld b,85
check_zero_preserves_data:
    ld a,(hl)
    check 0
    inc hl
    ld a,(hl)
    check 128
    inc hl
    ld a,(hl)
    check 255
    inc hl
    djnz check_zero_preserves_data
    ld hl,0
    jr finish
failed:
    ld hl,1
finish:
    ld sp,(saved_sp) ; ADL24 OK: exactly three-byte stack address.
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
saved_sp: .space 3
full: .byte 255
    .fill 254,1,120
    .byte 'z',0xa5
full_expected: .byte 255
    .fill 254,1,120
    .byte 'z',0xa5
inputs:
last: .byte 1,'z'
lasttwo: .byte 2,'x','z'
empty: .byte 0,0xa5
overlaps: .byte 6
    .ascii "aaaaab"
overlapneedle: .byte 4
    .ascii "aaab"
high: .byte 6,0,128,255,0,128,255
highneedle: .byte 2,128,255
inputs_end:
inputs_expected:
    .byte 1,'z',2,'x','z',0,0xa5,6
    .ascii "aaaaab"
    .byte 4
    .ascii "aaab"
    .byte 6,0,128,255,0,128,255,2,128,255
    .balign 256
    .space 254
guard_before: .byte 0xa5
repeat_buffer: .byte 3,0,128,255
    .fill 252,1,0xa5
guard_after: .byte 0x5a
