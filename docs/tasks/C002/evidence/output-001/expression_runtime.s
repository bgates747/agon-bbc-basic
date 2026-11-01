; C002 native expression helpers, around the unchanged qualified adapter.
; This file is a standalone relocatable runtime, not a source interpreter.
    .assume adl=1
    .text
    .global rt_literal,rt_negate,rt_format,rt_printnum

; IX = destination five-byte value. Return address points to inline payload.
; Consume the payload and return after it. No wide accesses to numeric fields.
rt_literal:
    pop hl
    push ix
    pop de
    ld bc,5
    ldir
    push hl
    ret

; BBC unary minus preserves integer type, including wrapping INT_MIN.
; Floating minus changes only the sign bit, matching EVAL.Z80 MINUS0.
; IX preserved. AF/B/HL/DE volatile; IY untouched.
rt_negate:
    ld a,(ix+4)
    or a
    jr z,neg_integer
    ld a,(ix+3)
    xor 0x80
    ld (ix+3),a
    ret
neg_integer:
    push ix
    pop hl
    ld b,4
    scf
neg_byte:
    ld a,(hl)
    cpl
    adc a,0
    ld (hl),a
    inc hl
    djnz neg_byte
    ret

; IX = read-only packed numeric value. IY = nonoverlapping 32-byte buffer.
; Success: A=0/Z/NC, HL=length, buffer[length]=NUL. Error: A=code/NZ/C.
; IX/IY/SP preserved, other registers volatile. G9 control is private/constant.
; FPP STR needs IX=format and DE=text, unlike the packed binary-value ABI.
rt_format:
    push ix
    push iy
    ld bc,0
    ld hl,0
    ld l,(ix+2)
    ld h,(ix+3)
    ld c,(ix+4)
    exx
    ld hl,0
    ld l,(ix+0)
    ld h,(ix+1)
    exx
    push iy
    pop de
    ld ix,num_format
    ld a,37
    call FPP
    jr c,format_error
    xor a
    ld (de),a
    ex de,hl
    push iy
    pop de
    or a
    sbc hl,de
    pop iy
    pop ix
    xor a
    ret
format_error:
    pop iy
    pop ix
    or a
    scf
    ret

; IX = value, A = minimum field width (compiler supplies 0 or 10).
; IX/IY/SP preserved. Success A=0/Z/NC, error A=code/NZ/C.
; Private display scratch is reused between synchronous PRINT calls.
rt_printnum:
    push ix
    push iy
    push af
    ld iy,num_text
    call rt_format
    jr c,printnum_error
    pop af
    sub l
    jr c,printnum_chars
    ld b,a
    or a
    jr z,printnum_chars
printnum_spaces:
    ld a,32
    push bc
    rst.lis 0x10
    pop bc
    djnz printnum_spaces
printnum_chars:
    ld hl,num_text
printnum_loop:
    ld a,(hl)
    or a
    jr z,printnum_done
    push hl
    rst.lis 0x10
    pop hl
    inc hl
    jr printnum_loop
printnum_done:
    pop iy
    pop ix
    xor a
    ret
printnum_error:
    ld d,a
    pop af
    ld a,d
    pop iy
    pop ix
    or a
    scf
    ret
num_format:
    .byte 10,9,0,0
num_text:
    .space 32

; The vendor file ends with assembler END. It must be included last.
    .include "numeric.s"
