; C005 logical-value copy bounds and index/stack preservation.
    .assume adl=1
    .text
    .global entry
    .extern rt_strcopy
    .macro preserved
    push ix
    pop hl
    ld de,0x123456
    or a
    sbc hl,de
    jp nz,failed
    push iy
    pop hl
    ld de,0xabcdef
    or a
    sbc hl,de
    jp nz,failed
    ld hl,0
    add hl,sp
    ld de,(saved_sp)
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro copy source
    ld ix,0x123456
    ld iy,0xabcdef
    ld hl,\source
    ld de,destination
    ld bc,0xabcdef
    call rt_strcopy
    jp c,failed
    jp nz,failed
    or a
    jp nz,failed
    preserved
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
    ld (saved_sp),sp
    copy empty
    ld a,(destination)
    or a
    jp nz,failed
    ld a,(destination+1)
    cp 0xa5
    jp nz,failed
    copy short_value
    ld a,(destination)
    cp 3
    jp nz,failed
    ld a,(destination+1)
    or a
    jp nz,failed
    ld a,(destination+2)
    cp 128
    jp nz,failed
    ld a,(destination+3)
    cp 255
    jp nz,failed
    ld a,(destination+4)
    cp 0xa5
    jp nz,failed
    copy maximum
    ld hl,destination
    ld de,maximum
    ld bc,256
compare:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc de
    inc hl
    dec bc
    ld a,b
    or c
    jr nz,compare
    ld a,(guard_before)
    cp 0xa5
    jp nz,failed
    ld a,(guard_after)
    cp 0xa5
    jp nz,failed
    ld hl,destination
    ld de,destination
    ld bc,0xabcdef
    call rt_strcopy
    jp c,failed
    preserved
    ld a,(destination)
    cp 255
    jp nz,failed
    ld a,(destination+255)
    cp 'q'
    jp nz,failed
    ld hl,0
    jr finish
failed:
    ld hl,1
finish:
    ld sp,(saved_sp)
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
saved_sp: .d24 0
empty: .byte 0
short_value: .byte 3,0,128,255
maximum: .byte 255
    .fill 255,1,113
    .balign 256
    .space 249
 guard_before: .byte 0xa5
 destination: .fill 256,1,0xa5
 guard_after: .byte 0xa5
