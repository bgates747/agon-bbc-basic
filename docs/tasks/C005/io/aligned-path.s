; Isolate the MOS path from BBC pointer state for the retained255-byte stall.
    .assume adl=1
    .text
    .global entry

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
    ld hl,filename
    ld c,1
    ld a,10
    rst.lil 8
    ld c,a
    ld a,11
    rst.lil 8
    ld hl,0
    ld sp,(saved_sp)
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
saved_sp: .d24 0
value: .space 5,0
    .balign 256
filename:
    .fill 255,1,113
    .byte 13,0
