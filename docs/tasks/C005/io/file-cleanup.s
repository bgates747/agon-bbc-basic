; After a generated program exits, all eight MOS handles must be available.
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
    ld b,1
next:
    push bc
    ld hl,filename
    ld c,1
    ld a,10
    rst.lil 8
    pop bc
    cp b
    jr nz,failed
    inc b
    ld a,b
    cp 9
    jr nz,next
    ld hl,0
    jr finish
failed:
    ld hl,1
finish:
    push hl
    ld c,0
    ld a,11
    rst.lil 8
    pop hl
    ld sp,(saved_sp)
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
saved_sp: .d24 0
filename: .asciz "file.dat"
