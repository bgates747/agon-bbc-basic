; Probe rt_format with a deliberately unaligned caller buffer and canaries.
; Input records: numeric[5], expected length[1], expected padded text[32].
; Only numeric[5] is read by native code. Expectations stay host-side.
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
    ld (saved_sp),sp       ; ADL24 OK: three-byte native stack address.
    ld hl,cases
    ld (case_ptr),hl       ; ADL24 OK: three-byte case pointer.
next_case:
    ld hl,(case_ptr)       ; ADL24 OK: three-byte case pointer.
    ld de,cases_end
    or a
    sbc hl,de
    jp z,finished
    xor a
    ld (bad_state),a
    ld hl,(case_ptr)       ; ADL24 OK: three-byte case pointer.
    ld de,value
    ld bc,5
    ldir
    ld hl,text_buffer
    ld b,32
fill_text:
    ld (hl),0xcc
    inc hl
    djnz fill_text
    ld bc,0xa51234
    ld de,0xb56789
    ld hl,0xc5abcd
    exx
    ld bc,0xd51234
    ld de,0xe56789
    ld hl,0xf5abcd
    exx
    ld ix,value
    ld iy,text_buffer
    ld (before_sp),sp      ; ADL24 OK: three-byte native stack address.
    call rt_format
    ld (status),a
    ld (text_length),hl    ; ADL24 OK: three-byte length, bounded below.
    jr c,error_flags
    jr z,flags_ok
    call mark_bad
    jr flags_ok
error_flags:
    jr nz,flags_ok
    call mark_bad
flags_ok:
    ld hl,0
    add hl,sp
    ld de,(before_sp)      ; ADL24 OK: three-byte native stack address.
    or a
    sbc hl,de
    call nz,mark_bad
    push ix
    pop hl
    ld de,value
    or a
    sbc hl,de
    call nz,mark_bad
    push iy
    pop hl
    ld de,text_buffer
    or a
    sbc hl,de
    call nz,mark_bad
    ld hl,(text_length)    ; ADL24 OK: full three-byte returned length.
    ld de,32
    or a
    sbc hl,de
    call nc,mark_bad
    ld a,(value_before)
    cp 0xa5
    call nz,mark_bad
    ld a,(value_after)
    cp 0x5a
    call nz,mark_bad
    ld a,(text_before)
    cp 0xa5
    call nz,mark_bad
    ld a,(text_after)
    cp 0x5a
    call nz,mark_bad
    ld hl,(case_ptr)       ; ADL24 OK: three-byte case pointer.
    ld de,value
    ld b,5
check_value:
    ld a,(de)
    cp (hl)
    call nz,mark_bad
    inc de
    inc hl
    djnz check_value
    ld a,'F'
    rst.lis 0x10
    ld a,':'
    rst.lis 0x10
    ld a,(status)
    call print_byte
    ld a,(text_length)
    call print_byte
    ld hl,text_buffer
    ld b,32
print_text:
    ld a,(hl)
    call print_byte
    inc hl
    djnz print_text
    ld a,(bad_state)
    call print_byte
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    ld hl,(case_ptr)       ; ADL24 OK: three-byte case pointer.
    ld de,38
    add hl,de
    ld (case_ptr),hl       ; ADL24 OK: three-byte case pointer.
    jp next_case
finished:
    ld sp,(saved_sp)       ; ADL24 OK: three-byte native stack address.
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
saved_sp:
    .space 3
before_sp:
    .space 3
case_ptr:
    .space 3
text_length:
    .space 3
status:
    .byte 0
bad_state:
    .byte 0
value_before:
    .byte 0xa5
value:
    .space 5
value_after:
    .byte 0x5a
    .balign 256
    .space 250
text_before:
    .byte 0xa5
text_buffer:
    .space 32
text_after:
    .byte 0x5a
cases:
    .incbin "format.dat"
cases_end:
