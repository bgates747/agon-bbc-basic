; C005 standalone MOS file/line helpers, adapted from the API conventions in
; src/agon_os.s. Repository zlib license applies. No interpreter state/parser.
    .assume adl=1
    .text
    .global io_open,io_get,io_eof,io_put,io_puts,io_close,io_input
    .global io_filename,io_line_buffer ; Workspace symbols for independent ABI inspection.

; IX=numeric5 destination, IY=string256, A=FatFS mode1/3/10.
io_open:
    push ix
    push iy
    push af
    push iy
    pop hl
    ld bc,0
    ld c,(hl)
    inc hl
    ld de,io_filename
    ld a,c
    or a
    jr z,open_empty
    ldir
open_empty:
    ld a,13
    ld (de),a
    pop af
    ld c,a
    ld hl,io_filename
    ld a,0x0a
    rst.lil 0x08
    call value_byte
    pop iy
    pop ix
    xor a
    ret

; IX=numeric5 destination, A=handle. Carry from MOS is not a BASIC error.
io_get:
    push ix
    push iy
    ld c,a
    ld a,0x0c
    rst.lil 0x08
    call value_byte
    pop iy
    pop ix
    xor a
    ret
io_eof:
    push ix
    push iy
    ld c,a
    ld a,0x0e
    rst.lil 0x08
    cp 1
    ld a,0
    jr nz,eof_false
    dec a
eof_false:
    ld (ix+0),a
    ld (ix+1),a
    ld (ix+2),a
    ld (ix+3),a
    xor a
    ld (ix+4),a
    pop iy
    pop ix
    ret
value_byte:
    ld (ix+0),a
    xor a
    ld (ix+1),a
    ld (ix+2),a
    ld (ix+3),a
    ld (ix+4),a
    ret

; A=handle,B=byte. The MOS API preserves the remaining argument registers.
io_put:
    push ix
    push iy
    ld c,a
    ld a,0x0d
    rst.lil 0x08
    pop iy
    pop ix
    xor a
    ret
io_close:
    push ix
    push iy
    ld c,a
    ld a,0x0b
    rst.lil 0x08
    pop iy
    pop ix
    xor a
    ret

; A=handle,IY=string256,C=append-LF0/1. Exact binary length; no null LDIR.
io_puts:
    push ix
    push iy
    push bc
    ld e,a
    ld d,(iy+0)
    ld c,e
    push iy
    pop hl
    inc hl
    ld a,d
    or a
    jr z,puts_tail
puts_next:
    ld b,(hl)
    inc hl
    ld a,0x0d
    rst.lil 0x08
    dec d
    jr nz,puts_next
puts_tail:
    pop bc
    ld a,c
    or a
    jr z,puts_done
    ld c,e
    ld b,10
    ld a,0x0d
    rst.lil 0x08
puts_done:
    pop iy
    pop ix
    xor a
    ret

; IX=expression string256. MOS supplies a NUL-terminated line, maximum255.
; CRLF precedes Escape A17/NZ/C as in OSLINE. Caller commits only on success.
io_input:
    push ix
    push iy
    ld hl,io_line_buffer
    ld bc,256
    ld de,1
    ld a,9
    rst.lil 0x08
    push af
    ld hl,io_line_buffer
    ld bc,0
input_length:
    ld a,(hl)
    or a
    jr z,input_copy
    inc hl
    inc c
    ld a,c
    cp 255
    jr nz,input_length
input_copy:
    ld (ix+0),c
    ld a,c
    or a
    jr z,input_newline
    ld hl,io_line_buffer
    push ix
    pop de
    inc de
    ldir
input_newline:
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    pop af
    cp 27
    pop iy
    pop ix
    jr z,input_escape
    xor a
    ret
input_escape:
    ld a,17
    or a
    scf
    ret
io_filename: .space 256,0
io_line_buffer: .space 256,0
