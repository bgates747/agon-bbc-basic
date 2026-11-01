; C002 native expression helpers, around the unchanged qualified adapter.
; This file is a standalone relocatable runtime, not a source interpreter.
    .assume adl=1
    .text
    .global rt_literal,rt_negate

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

; The vendor file ends with assembler END. It must be included last.
    .include "numeric.s"
