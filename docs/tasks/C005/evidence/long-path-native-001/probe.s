; Isolate the MOS path from BBC pointer state for the retained255-byte stall.
    .assume adl=1
    .text
    .global entry
    .extern io_open,io_close
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
    ld ix,value
    ld iy,filename
    ld a,1
    call io_open
    ld a,(value)
    call io_close
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
filename: .byte 255
    .fill 255,1,113
