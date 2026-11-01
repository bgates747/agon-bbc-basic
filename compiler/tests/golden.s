; Independently assembled oracle for: PRINT "ok":END
; New runtime code, not extracted from the reference interpreter.
    .assume adl=1
    .text
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
    ld (savedsp),sp       ; ADL24 OK: savedsp reserves exactly three bytes.
    xor a
    ld (depth),a
    call print_inline
    .byte 2
    .ascii "ok"
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    jp end_program
    jp end_program
print_inline:
    pop hl
    ld bc,0
    ld c,(hl)
    inc hl
    push hl
    add hl,bc
    ex (sp),hl            ; ADL24 OK: exchange a full native return address.
    ld a,c
    or a
    ret z
    rst.lis 0x18
    ret
gosub:
    ld a,(depth)
    cp 255
    jp z,full
    inc a
    ld (depth),a
    jp (hl)
return:
    ld a,(depth)
    or a
    jp z,bad_return
    dec a
    ld (depth),a
    ret
bad_return:
    call print_inline
    .byte 8
    .ascii "No GOSUB"
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    jp error
full:
    call print_inline
    .byte 15
    .ascii "Too many GOSUBs"
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
error:
    ld hl,1
    jp exit
end_program:
    ld hl,0
exit:
    ld sp,(savedsp)       ; ADL24 OK: savedsp reserves exactly three bytes.
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
savedsp:
    .space 3
depth:
    .byte 0
