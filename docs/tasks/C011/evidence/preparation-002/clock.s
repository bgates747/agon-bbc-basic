; C011 clock pointer export. New fixture helper, repository zlib license.
; MOS executable at &40000. Does not read/change firmware or the clock.
    .assume adl=1
    .text
    .global start
    jp start
    .balign 64
    .ascii "MOS"
    .byte 0,1
start:
    push ix
    push iy
    ld a,8
    rst.lil 8
    ; ADL24 OK: pointer is exactly three bytes, after four magic bytes.
    ld (pointer),ix
    ld hl,filename
    ld c,10
    ld a,0x0a
    rst.lil 8
    or a
    jr z,failed
    ld c,a
    ld hl,record
    ld de,7
write_loop:
    ld b,(hl)
    ld a,0x0d
    rst.lil 8
    inc hl
    dec de
    ld a,d
    or e
    jr nz,write_loop
    ld a,0x0b
    rst.lil 8
    ld hl,message
    call puts
    ld hl,0
    jr done
failed:
    ld hl,failure
    call puts
    ld hl,1
done:
    pop iy
    pop ix
    ret
puts:
    ld a,(hl)
    or a
    ret z
    rst.lil 0x10
    inc hl
    jr puts
filename: .asciz "clock.dat"
message: .asciz "C011 clock.dat written; run the clock check in suite.bas.\r\n"
failure: .asciz "C011 cannot create clock.dat; check current directory/card.\r\n"
record: .ascii "C011"
pointer: .space 3
