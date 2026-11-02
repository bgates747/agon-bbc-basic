; Direct slice-write bounds/ownership ABI probe.
    .assume adl=1
    .text
    .global entry
    .extern rt_strwrite
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
    ld de,(saved_sp) ; ADL24 OK: three-byte saved stack address.
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro write descriptor,rhs,range
    ld ix,\descriptor
    ld iy,\rhs
    ld hl,\range
    ld bc,0xabcdef
    call rt_strwrite
    jp c,failed
    jp nz,failed
    check 0
    preserved \descriptor,\rhs
    .endm
    .macro six expected
    ld hl,buffer
    ld de,\expected
    ld b,6
    call compare
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
    ld (saved_sp),sp ; ADL24 OK: three-byte saved stack address.
    call reset
    write descriptor,short_rhs,0xabff00
    six left_expected
    call reset
    write descriptor,short_rhs,0xabffff
    six right_expected
    call reset
    write descriptor,short_rhs,0xabfe01
    six mid_expected
    call reset
    write descriptor,short_rhs,0xabfeff
    six initial
    call reset
    write descriptor,short_rhs,0xab00ff
    six right_two_expected
    call reset
    write descriptor,long_rhs,0xabff01
    six marker_expected
    call reset
    write descriptor,long_rhs,0xabfe01
    six clamped_expected
    call reset
    write descriptor,long_rhs,0xab0001
    six initial
    write descriptor,empty_rhs,0xabfe00
    six initial
    write empty_descriptor,short_rhs,0xabffff
    write empty_descriptor,long_rhs,0xabfe00
    write maximum_descriptor,short_rhs,0xabfffe
    ld hl,maximum_data
    ld b,255
check_max_unchanged:
    ld a,(hl)
    check 'x'
    inc hl
    djnz check_max_unchanged
    write maximum_descriptor,short_rhs,0xabfefe
    ld hl,maximum_data
    ld b,254
check_max_prefix:
    ld a,(hl)
    check 'x'
    inc hl
    djnz check_max_prefix
    ld a,(hl)
    check 'X'
    ld hl,descriptor
    ld de,descriptors_expected
    ld b,15
    call compare
    ld hl,short_rhs
    ld de,rhs_expected
    ld b,14
    call compare
    ld a,(guard_before)
    check 0xa5
    ld a,(guard_after)
    check 0x5a
    ld a,(maximum_before)
    check 0xa5
    ld a,(maximum_after)
    check 0x5a
    ld hl,0
    jr finish
failed:
    ld hl,1
finish:
    ld sp,(saved_sp) ; ADL24 OK: three-byte saved stack address.
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
reset:
    ld hl,initial
    ld de,buffer
    ld bc,6
    ldir
    ret
compare:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    djnz compare
    ret
saved_sp: .space 3
descriptor: .byte 6,6
    .d24 buffer
empty_descriptor: .byte 0,0
    .d24 0
maximum_descriptor: .byte 255,255
    .d24 maximum_data
descriptors_expected: .byte 6,6
    .d24 buffer
    .byte 0,0
    .d24 0
    .byte 255,255
    .d24 maximum_data
short_rhs: .byte 3
    .ascii "XYZ"
    .byte 0xa5
long_rhs: .byte 6
    .ascii "UVWXYZ"
empty_rhs: .byte 0,0x5a
rhs_expected: .byte 3
    .ascii "XYZ"
    .byte 0xa5,6
    .ascii "UVWXYZ"
    .byte 0,0x5a
initial: .ascii "abcdef"
left_expected: .ascii "XYZdef"
right_expected: .ascii "abcdeX"
mid_expected: .ascii "aXYZef"
right_two_expected: .ascii "abcdXY"
marker_expected: .ascii "aUVWXf"
clamped_expected: .ascii "aUVWXY"
guard_before: .byte 0xa5
buffer: .space 6
guard_after: .byte 0x5a
    .balign 256
    .space 254
maximum_before: .byte 0xa5
maximum_data: .fill 255,1,120
maximum_after: .byte 0x5a
