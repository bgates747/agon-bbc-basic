; C002 MOS executable: exercise each packed case through rt_numeric.
; Input record: selector, alias, lhs[5], rhs[5], expected status, expected[5].
; The native probe reads only the selector/alias/operands, never expectations.
; Output: R: followed by status[1], result[5], structural-failure flag[1] in hex.
    .assume adl=1
    .text
    .global _start
_start:
    jp start
    .space 60
    .ascii "MOS"
    .byte 0,1
start:
    push af
    push bc
    push de
    push ix
    push iy
    ld (saved_sp),sp       ; ADL24 OK: saved_sp is a three-byte stack address.
    ld hl,cases
    ld (case_ptr),hl       ; ADL24 OK: case_ptr is a three-byte address.
case_loop:
    ld hl,(case_ptr)       ; ADL24 OK: case_ptr is a three-byte address.
    ld de,cases_end
    or a
    sbc hl,de
    jp z,finished
    xor a
    ld (bad_state),a
    ld hl,(case_ptr)       ; ADL24 OK: case_ptr is a three-byte address.
    ld a,(hl)
    ld (selector),a
    inc hl
    ld a,(hl)
    ld (alias),a
    inc hl
    ld de,left
    ld bc,5
    ldir
    ld de,right
    ld bc,5
    ldir
    ; Deliberately dirty the upper bytes of both register sets.
    ld bc,0xa51234
    ld de,0xb56789
    ld hl,0xc5abcd
    exx
    ld bc,0xd51234
    ld de,0xe56789
    ld hl,0xf5abcd
    exx
    ld ix,left
    ld iy,right
    ld a,(alias)
    or a
    jr z,not_alias
    ld iy,left
not_alias:
    ld (before_sp),sp      ; ADL24 OK: before_sp is a three-byte stack address.
    ld a,(selector)
    call rt_numeric
    ld (status),a
    jr c,error_flags
    jr z,flags_done
    call mark_bad
    jr flags_done
error_flags:
    jr nz,flags_done
    call mark_bad
flags_done:
    ld hl,0
    add hl,sp
    ld de,(before_sp)      ; ADL24 OK: before_sp is a three-byte stack address.
    or a
    sbc hl,de
    call nz,mark_bad
    push ix
    pop hl
    ld de,left
    or a
    sbc hl,de
    call nz,mark_bad
    push iy
    pop hl
    ld de,right
    ld a,(alias)
    or a
    jr z,check_iy
    ld de,left
check_iy:
    or a
    sbc hl,de
    call nz,mark_bad
    ld a,(left_before)
    cp 0xa5
    call nz,mark_bad
    ld a,(left_after)
    cp 0x5a
    call nz,mark_bad
    ld a,(right_before)
    cp 0xa5
    call nz,mark_bad
    ld a,(right_after)
    cp 0x5a
    call nz,mark_bad
    ld hl,(case_ptr)       ; ADL24 OK: case_ptr is a three-byte address.
    ld de,7
    add hl,de
    ex de,hl
    ld hl,right
    ld b,5
check_rhs:
    ld a,(de)
    cp (hl)
    call nz,mark_bad
    inc hl
    inc de
    djnz check_rhs
    ld a,'R'
    rst.lis 0x10
    ld a,':'
    rst.lis 0x10
    ld a,(status)
    call print_byte
    ld hl,left
    ld b,5
print_result:
    ld a,(hl)
    call print_byte
    inc hl
    djnz print_result
    ld a,(bad_state)
    call print_byte
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    ld hl,(case_ptr)       ; ADL24 OK: case_ptr is a three-byte address.
    ld de,18
    add hl,de
    ld (case_ptr),hl       ; ADL24 OK: case_ptr is a three-byte address.
    jp case_loop
finished:
    ld hl,done_text
    ld bc,0
    xor a
    rst.lis 0x18
    ld sp,(saved_sp)       ; ADL24 OK: saved_sp is a three-byte stack address.
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0
    ret
mark_bad:
    ld a,1
    ld (bad_state),a
    ret
print_byte:
    push af
    rrca
    rrca
    rrca
    rrca
    and 15
    call print_nibble
    pop af
    and 15
print_nibble:
    push hl
    push de
    push bc
    ld hl,hex_chars
    ld de,0
    ld e,a
    add hl,de
    ld a,(hl)
    rst.lis 0x10
    pop bc
    pop de
    pop hl
    ret
hex_chars:
    .ascii "0123456789ABCDEF"
done_text:
    .asciz "NUMERIC_DONE\r\n"
saved_sp:
    .space 3
before_sp:
    .space 3
case_ptr:
    .space 3
selector:
    .byte 0
alias:
    .byte 0
status:
    .byte 0
bad_state:
    .byte 0
left_before:
    .byte 0xa5
left:
    .space 5
left_after:
    .byte 0x5a
right_before:
    .byte 0xa5
right:
    .space 5
right_after:
    .byte 0x5a
cases:
    .incbin "cases.dat"
cases_end:
