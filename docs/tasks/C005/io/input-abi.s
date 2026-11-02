; Exercise the real MOS line editor with harness-injected keyboard events.
    .assume adl=1
    .text
    .global entry
    .extern io_input
    .macro good
    jp c,failed
    jp nz,failed
    or a
    jp nz,failed
    .endm
    .macro preserved
    push ix
    pop hl
    ld de,packet
    or a
    sbc hl,de
    jp nz,failed
    push iy
    pop hl
    ld de,0xabcdef
    or a
    sbc hl,de
    jp nz,failed
    ld hl,0
    add hl,sp
    ld de,(saved_sp)
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro input prompt
    ld hl,\prompt
    call print
    ld ix,packet
    ld iy,0xabcdef
    ld bc,0xabcdef
    call io_input
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
    ld (saved_sp),sp
    ld a,1
    ld (stage),a
    input first_prompt
    good
    preserved
    ld hl,packet
    ld de,alpha
    ld b,6
check_alpha:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc de
    inc hl
    djnz check_alpha
    ld a,2
    ld (stage),a
    input empty_prompt
    good
    preserved
    ld a,(packet)
    or a
    jp nz,failed
    ld a,(packet+1)
    cp 'a'
    jp nz,failed
    ld a,3
    ld (stage),a
    input maximum_prompt
    good
    preserved
    ld a,(packet)
    cp 255
    jp nz,failed
    ld hl,packet+1
    ld b,255
check_maximum:
    ld a,(hl)
    cp 'q'
    jp nz,failed
    inc hl
    djnz check_maximum
    ld a,4
    ld (stage),a
    input escape_prompt
    jp nc,failed
    cp 17
    jp nz,failed
    preserved
    ld a,(guard_before)
    cp 0xa5
    jp nz,failed
    ld a,(guard_after)
    cp 0xa5
    jp nz,failed
    ld hl,0
    jr finish
failed:
    ld hl,0
    ld a,(stage)
    ld l,a
finish:
    ld sp,(saved_sp)
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
print:
    ld a,(hl)
    or a
    ret z
    inc hl
    push hl
    rst.lis 0x10
    pop hl
    jr print
saved_sp: .d24 0
stage: .byte 1
first_prompt: .asciz "INPUT_ALPHA\n"
empty_prompt: .asciz "INPUT_EMPTY\n"
maximum_prompt: .asciz "INPUT_MAXIMUM\n"
escape_prompt: .asciz "INPUT_ESCAPE\n"
alpha: .byte 5
    .ascii "alpha"
    .balign 256
    .space 249
guard_before: .byte 0xa5
packet: .fill 256,1,0xa5
guard_after: .byte 0xa5
