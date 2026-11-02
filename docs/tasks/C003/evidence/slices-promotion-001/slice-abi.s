; Independent native probe for private-buffer slices and ordering.
    .assume adl=1
    .text
    .global entry
    .extern rt_strleft,rt_strright,rt_strmid,rt_strcompare
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
    ld de,(saved_sp) ; ADL24 OK: saved stack address is exactly three bytes.
    or a
    sbc hl,de
    jp nz,failed
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
    ld (saved_sp),sp ; ADL24 OK: saved stack address is exactly three bytes.
    ld ix,full
    ld iy,same
    ld bc,0xabcdef
    call rt_strcompare
    check 0
    preserved full,same
    ld a,(full)
    check 255
    ld hl,full+1
    ld de,same+1
    ld bc,255
check_equal_operands:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    dec bc
    ld a,b
    or c
    jr nz,check_equal_operands
    ld ix,empty
    ld iy,same
    call rt_strcompare
    check 255
    preserved empty,same
    ld ix,same
    ld iy,empty
    call rt_strcompare
    check 1
    preserved same,empty
    ld ix,low
    ld iy,high
    call rt_strcompare
    check 255
    preserved low,high
    ld ix,high
    ld iy,low
    call rt_strcompare
    check 1
    preserved high,low
    ld ix,shorter
    ld iy,longer
    call rt_strcompare
    check 255
    preserved shorter,longer
    ld ix,longer
    ld iy,shorter
    call rt_strcompare
    check 1
    preserved longer,shorter
    ld ix,buffer
    ld iy,same
    ld bc,0xcdef01
    ld a,2
    call rt_strright
    preserved buffer,same
    ld a,(buffer)
    check 2
    ld a,(buffer+1)
    check 'd'
    ld a,(buffer+2)
    check 'e'
    ld bc,0xdef012
    ld a,1
    call rt_strleft
    preserved buffer,same
    ld a,(buffer)
    check 1
    ld a,(buffer+1)
    check 'd'
    xor a
    call rt_strmid
    preserved buffer,same
    ld a,(buffer)
    check 1
    ld bc,0xfedcba
    ld a,2
    call rt_strmid
    preserved buffer,same
    ld a,(buffer)
    check 0
    ld a,255
    call rt_strright
    preserved buffer,same
    ld a,(buffer)
    check 0
    ld ix,full
    ld bc,0xbacdef
    ld a,255
    call rt_strmid
    preserved full,same
    ld a,(full)
    check 1
    ld a,(full+1)
    check 'z'
    xor a
    call rt_strright
    preserved full,same
    ld a,(full)
    check 0
    ld a,(guard_buffer)
    check 0xa5
    ld a,(guard_full)
    check 0xa5
    ld a,(guard_same)
    check 0x5a
    ld a,(same)
    check 255
    ; Entire comparison RHS is read-only, including all 255 characters.
    ld hl,same+1
    ld b,254
check_same:
    ld a,(hl)
    check 'x'
    inc hl
    djnz check_same
    ld a,(hl)
    check 'z'
    ld a,(empty)
    check 0
    ld a,(low)
    check 2
    ld a,(low+1)
    check 0
    ld a,(low+2)
    check 128
    ld a,(high+2)
    check 255
    ld hl,0
    jr finish
failed:
    ld hl,1
finish:
    ld sp,(saved_sp) ; ADL24 OK: saved stack address is exactly three bytes.
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
saved_sp: .space 3
buffer: .byte 5
    .ascii "abcde"
    .space 250
guard_buffer: .byte 0xa5
full: .byte 255
    .fill 254,1,120
    .byte 'z'
guard_full: .byte 0xa5
same: .byte 255
    .fill 254,1,120
    .byte 'z'
guard_same: .byte 0x5a
empty: .byte 0,0xa5
low: .byte 2,0,128
high: .byte 2,0,255
shorter: .byte 1,'a'
longer: .byte 2,'a','b'
