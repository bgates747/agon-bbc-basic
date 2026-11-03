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
    ld hl,prompt
    call text
    ld hl,buffer
    ld bc,256
    ld de,1
    ld a,9
    rst.lil 0x08
    ld (state),a
    ld a,8
    rst.lil 0x08
    ld a,(ix+5)
    ld (state+1),a
    ld a,(ix+0x18)
    ld (state+2),a
    ld hl,label
    call text
    ld a,(state)
    call hex
    ld a,':'
    rst.lis 0x10
    ld a,(state+1)
    call hex
    ld a,':'
    rst.lis 0x10
    ld a,(state+2)
    call hex
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0
    ret
text:
    ld a,(hl)
    inc hl
    or a
    ret z
    push hl
    rst.lis 0x10
    pop hl
    jr text
hex:
    push af
    rrca
    rrca
    rrca
    rrca
    call nibble
    pop af
nibble:
    and 15
    add a,48
    cp 58
    jr c,digit
    add a,7
digit:
    rst.lis 0x10
    ret
prompt: .asciz "ERROR_KEY_STATE:"
label: .asciz "KEY_STATE:"
state: .space 3,0
buffer: .space 256,0
