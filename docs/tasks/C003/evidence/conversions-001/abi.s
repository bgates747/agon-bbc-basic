; Native bridge probe. No interpreter service or numeric host model.
    .assume adl=1
    .text
    .global entry
    .extern rt_val,rt_strnum,rt_strhex
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
    .macro success
    jp c,failed
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
    ld (saved_sp),sp ; ADL24 OK: exactly three-byte stack address.
    ld ix,result
    ld iy,empty
    ld bc,0xabcdef
    call rt_val
    success
    preserved result,empty
    ld hl,result
    ld b,5
check_zero:
    ld a,(hl)
    check 0
    inc hl
    djnz check_zero
    ld iy,maximum
    ld bc,0xdefabc
    call rt_val
    success
    preserved result,maximum
    ld a,(result)
    check 12
    ld hl,result+1
    ld b,4
check_rest_zero:
    ld a,(hl)
    check 0
    inc hl
    djnz check_rest_zero
    ld iy,nulstring
    call rt_val
    success
    preserved result,nulstring
    ld a,(result)
    check 12
    ld iy,overflow
    call rt_val
    jp nc,failed
    jp z,failed
    preserved result,overflow
    ld a,(result)
    check 12
    ld hl,result+1
    ld b,4
check_error_unchanged:
    ld a,(hl)
    check 0
    inc hl
    djnz check_error_unchanged
    ld ix,negative
    ld iy,output
    ld bc,0xcdefab
    call rt_strnum
    success
    preserved negative,output
    ld a,(output)
    check 3
    ld hl,output+1
    ld de,decimal_expected
    ld b,3
check_decimal:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    djnz check_decimal
    ld a,(output+4)
    check 0
    ld bc,0xfabcde
    call rt_strhex
    success
    preserved negative,output
    ld a,(output)
    check 8
    ld hl,output+1
    ld de,hex_expected
    ld b,8
check_hex:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    djnz check_hex
    ld ix,toobig
    ld iy,untouched
    call rt_strhex
    jp nc,failed
    jp z,failed
    preserved toobig,untouched
    ld hl,untouched
    ld b,0
check_untouched:
    ld a,(hl)
    check 0xa5
    inc hl
    djnz check_untouched
    ld ix,zero
    ld iy,output
    call rt_strhex
    success
    preserved zero,output
    ld a,(output)
    check 1
    ld a,(output+1)
    check '0'
    ld a,(guard_before)
    check 0xa5
    ld a,(guard_output)
    check 0xa5
    ld a,(guard_untouched)
    check 0xa5
    ld a,(guard_result)
    check 0xa5
    ld a,(maximum)
    check 255
    ld hl,maximum+1
    ld b,253
check_maximum:
    ld a,(hl)
    check ' '
    inc hl
    djnz check_maximum
    ld a,(hl)
    check '1'
    inc hl
    ld a,(hl)
    check '2'
    inc hl
    ld a,(hl)
    check 0xa5
    ld hl,negative
    ld de,negative_expected
    ld b,11
check_numeric_inputs:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    djnz check_numeric_inputs
    ld hl,nulstring
    ld de,nul_expected
    ld b,6
check_nul_input:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    djnz check_nul_input
    ld a,(empty)
    check 0
    ld a,(empty+1)
    check 0xa5
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
result: .fill 5,1,0xa5
guard_result: .byte 0xa5
negative: .byte 0xf4,255,255,255,0
toobig: .byte 0,0,0,0,159
    .byte 0xa5
negative_expected: .byte 0xf4,255,255,255,0,0,0,0,0,159,0xa5
zero: .space 5
empty: .byte 0,0xa5
nulstring: .byte 5,'1','2',0,'3','4'
nul_expected: .byte 5,'1','2',0,'3','4'
overflow: .byte 5
    .ascii "1E999"
decimal_expected: .ascii "-12"
hex_expected: .ascii "FFFFFFF4"
maximum: .byte 255
    .fill 253,1,32
    .ascii "12"
    .byte 0xa5
    .balign 256
    .space 254
guard_before: .byte 0xa5
output: .fill 256,1,0xa5 ; Crosses a page, length must not depend on E alone.
guard_output: .byte 0xa5
untouched: .fill 256,1,0xa5
guard_untouched: .byte 0xa5
