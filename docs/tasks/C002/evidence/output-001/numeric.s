; C002 experimental numeric adapter. New wrapper around the unchanged package.
; See ABI.md and vendor/PROVENANCE.md. No interpreter is linked.
    .assume adl=1
    .text
    .global rt_numeric

; A = selector (0..15 binary, 16..31 unary, 35 PI, 38 fix, 39 float).
; IX = writable five-byte lhs/result; IY = five-byte rhs (may equal IX).
; Success: A=0, Z=1, carry=0. Failure: A=error, Z=0, carry=1;
; lhs is unchanged. IX, IY and SP are preserved. Other registers are volatile.
rt_numeric:
    cp 32
    jr c,num_accept
    cp 35
    jr z,num_accept
    cp 38
    jr z,num_accept
    cp 39
    jr z,num_accept
    ld a,1
    or a
    scf
    ret
num_accept:
    push ix
    push iy
    push af
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
    pop ix
    call DLOAD5
    pop af
    call FPP
    jr c,num_error
    pop iy
    pop ix
    call STORE5
    xor a
    ret
num_error:
    pop iy
    pop ix
    or a
    scf
    ret

; Adapted from baseline EVAL.Z80 / EXEC.Z80 (same license as vendor/LICENSE).
; Read/write only the stated five bytes. Zero upper register bytes on loads.
    .global DLOAD5,STORE5,TEST
DLOAD5:
    ld b,(ix+4)
    exx
    ld de,0
    ld e,(ix+0)
    ld d,(ix+1)
    exx
    ld de,0
    ld e,(ix+2)
    ld d,(ix+3)
    ret
STORE5:
    ld (ix+4),c
    exx
    ld (ix+0),l
    ld (ix+1),h
    exx
    ld (ix+2),l
    ld (ix+3),h
    ret
TEST:
    ld a,h
    or l
    exx
    or h
    or l
    exx
    ret

; Additional, undeclared package dependencies found by standalone linking.
; Internal sparse stack value: low word + padding at 0..2, high word +
; padding at 3..5, exponent at 6. All seven accesses below are byte-exact.
    .global DLOAD5_SPL,STORE5_SPL
DLOAD5_SPL:
    ld b,(ix+6)
    exx
    ld de,0
    ld e,(ix+0)
    ld d,(ix+1)
    exx
    ld de,0
    ld e,(ix+3)
    ld d,(ix+4)
    ret
STORE5_SPL:
    ld (ix+6),c
    exx
    ld (ix+0),l
    ld (ix+1),h
    xor a
    ld (ix+2),a
    exx
    ld (ix+3),l
    ld (ix+4),h
    ld (ix+5),a
    ret

; Minimal assembly compatibility macros required by the pinned package.
    .macro EXTRN symbol
    .extern \symbol
    .endm
    .macro PTR symbol
    .d24 \symbol
    .endm
    .macro UEXT reg
    or a
    sbc \reg,\reg
    .endm
    .macro UEXTA reg
    xor a
    sbc \reg,\reg
    .endm
    .include "vendor/MATH.Z80"
