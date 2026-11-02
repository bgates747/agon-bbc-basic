; Direct ABI regression, independent of BBC compiler emission.
    .assume adl=1
    .text
    .global entry
    .extern rt_strliteral,rt_strload,rt_strcat,rt_strstore,rt_strprint
    .macro ptrcheck reg,target
    push \reg
    pop hl
    ld de,\target
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro spcheck
    ld hl,0
    add hl,sp
    ld de,(saved_sp)   ; ADL24 OK: saved SP occupies three bytes.
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
    ld (saved_sp),sp   ; ADL24 OK: saved SP occupies three bytes.
    ld ix,buffer_a
    ld iy,buffer_b
    ld bc,0xab0000    ; Poison the upper BC byte before a byte-count operation.
    call rt_strcat
    jp c,failed
    or a
    jp nz,failed
    ptrcheck ix,buffer_a
    ptrcheck iy,buffer_b
    spcheck
    ld a,(buffer_a)
    cp 2
    jp nz,failed
    ld a,(buffer_a+1)
    cp 'a'
    jp nz,failed
    ld a,(buffer_a+2)
    cp 'b'
    jp nz,failed
    ld a,(guard_a)
    cp 0xa5
    jp nz,failed
    ld ix,large
    ld iy,buffer_b
    ld bc,0xcd0000
    call rt_strcat
    jp nc,failed
    cp 19
    jp nz,failed
    ptrcheck ix,large
    ptrcheck iy,buffer_b
    spcheck
    ld hl,large
    ld a,(hl)
    cp 255
    jp nz,failed
    inc hl
    ld b,255
check_large:
    ld a,(hl)
    cp 'x'
    jp nz,failed
    inc hl
    djnz check_large
    ld a,(hl)
    cp 0xa5
    jp nz,failed
    ld ix,descriptor
    ld iy,buffer_a
    ld hl,context
    ld bc,0xef0000
    call rt_strstore
    jp c,failed
    or a
    jp nz,failed
    ptrcheck ix,descriptor
    ptrcheck iy,buffer_a
    spcheck
    ld a,(descriptor)
    cp 2
    jp nz,failed
    ld a,(descriptor+1)
    cp 2
    jp nz,failed
    ld hl,(descriptor+2) ; ADL24 OK: descriptor pointer is three bytes.
    ld de,heap
    or a
    sbc hl,de
    jp nz,failed
    ld hl,(context)   ; ADL24 OK: context FREE is three bytes.
    ld de,heap+2
    or a
    sbc hl,de
    jp nz,failed
    ld a,(heap)
    cp 'a'
    jp nz,failed
    ld a,(heap+1)
    cp 'b'
    jp nz,failed
    ld iy,large
    ld hl,context
    call rt_strstore
    jp nc,failed
    or a
    jp nz,failed
    ptrcheck ix,descriptor
    ptrcheck iy,large
    spcheck
    ld a,(descriptor)
    cp 2
    jp nz,failed
    ld a,(descriptor+1)
    cp 2
    jp nz,failed
    ld hl,(context)   ; ADL24 OK: context FREE is three bytes.
    ld de,heap+2
    or a
    sbc hl,de
    jp nz,failed
    ld hl,(descriptor+2) ; ADL24 OK: failure must preserve the entire pointer.
    ld de,heap
    or a
    sbc hl,de
    jp nz,failed
    ld hl,(context+3) ; ADL24 OK: failure must preserve the exclusive limit.
    ld de,heap+16
    or a
    sbc hl,de
    jp nz,failed
    ld hl,heap+2
    ld b,15
check_heap_guard:
    ld a,(hl)
    cp 0xa5
    jp nz,failed
    inc hl
    djnz check_heap_guard
    ld ix,buffer_b
    ld iy,buffer_b
    call rt_strcat
    jp c,failed
    ptrcheck ix,buffer_b
    ptrcheck iy,buffer_b
    spcheck
    ld a,(buffer_b)
    cp 2
    jp nz,failed
    ld a,(buffer_b+1)
    cp 'b'
    jp nz,failed
    ld a,(buffer_b+2)
    cp 'b'
    jp nz,failed
    ld ix,buffer_a
    ld iy,empty
    call rt_strload
    ptrcheck ix,buffer_a
    ptrcheck iy,empty
    spcheck
    ld a,(buffer_a)
    or a
    jp nz,failed
    call rt_strliteral
    .byte 0
    spcheck
    ld a,(buffer_a)
    or a
    jp nz,failed
    call rt_strliteral
    .byte 255
    .fill 255,1,120
    ptrcheck ix,buffer_a
    ptrcheck iy,empty
    spcheck
    ld a,(buffer_a)
    cp 255
    jp nz,failed
    ld a,(buffer_a+255)
    cp 'x'
    jp nz,failed
    ld a,(guard_a)
    cp 0xa5
    jp nz,failed
    ld ix,buffer_b
    call rt_strprint
    ptrcheck ix,buffer_b
    ptrcheck iy,empty
    spcheck
    ld hl,0
    jr finish
failed:
    ld hl,1
finish:
    ld sp,(saved_sp)   ; ADL24 OK: restore probe stack before returning to MOS.
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
saved_sp: .space 3
buffer_a: .byte 1,'a'
    .space 254
 guard_a: .byte 0xa5
buffer_b: .byte 1,'b'
    .space 254
large: .byte 255
    .fill 255,1,120
    .byte 0xa5
    .balign 256
    .space 254
; Descriptor crosses a page boundary, including its three-byte pointer field.
descriptor: .space 5
empty: .space 5
context: .d24 heap,heap+16
heap: .fill 17,1,0xa5
