; C005 compact native CALL adapters. Fixed inline operands, never a source /
; bytecode dispatch loop. Arithmetic and conversion call the unchanged NUM ABI.
; ABI.md owns fields, register/stack/error contracts and relocation bridges.
    .assume adl=1
    .text
    .global cp_literal,cp_numeric,cp_read1,cp_read4,cp_read5
    .global cp_store1,cp_store4,cp_store5,cp_arrayprefix,cp_arrayaddr
    .global cp_actsave,cp_actbind,cp_actbegin
    .global cp_num_base,cp_str_base,cp_slot_numeric,cp_slot_numerror
    .global cp_slot_literal,cp_slot_novar,cp_slot_prefix,cp_slot_addr
    .global cp_slot_memerror,cp_slot_save,cp_slot_bind,cp_slot_begin,cp_slot_acterror

; A=slot0..31; HL=base+5*A. BC/IX/IY preserved. Zero all24 address bits.
num_ptr:
    ld hl,0
    ld l,a
    ld h,5
    mlt hl
    ld de,(cp_num_base)        ; ADL24 OK: private three-byte pointer cell
    add hl,de
    ret
str_ptr:
    ld hl,0
    ld h,a
    ld de,(cp_str_base)        ; ADL24 OK: private three-byte pointer cell
    add hl,de
    ret

; CALL; slot:u8; packet:5. Existing literal entry consumes the packet.
cp_literal:
    pop hl
    ld a,(hl)
    inc hl
    push hl
    call num_ptr
    push hl
    pop ix
    jp literal_target

; CALL; lhs:u8; rhs:u8; operation:u8. Return with IX/IY at the same pools
; as the original explicit register setup. NUM failure tail-transfers unchanged.
cp_numeric:
    pop hl
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld a,(hl)
    inc hl
    push hl
    push af
    ld a,b
    call num_ptr
    push hl
    pop ix
    ld a,c
    call num_ptr
    push hl
    pop iy
    pop af
    call numeric_target
    jp c,numerror_target
    ret

; CALL; binding:u24; destination_slot:u8. Preserve caller IX/IY, as the
; old binding-copy sequence did. A missing binding changes no pool bytes.
cp_read1:
    ld bc,1
    jr read_value
cp_read4:
    ld bc,4
    jr read_value
cp_read5:
    ld bc,5
read_value:
    pop hl
    ld de,(hl)                ; ADL24 OK: inline three-byte binding pointer
    inc hl
    inc hl
    inc hl
    ld a,(hl)
    inc hl
    push hl
    push ix
    push iy
    push de
    pop ix
    call num_ptr
    push hl
    pop iy
    ld a,(ix+0)
    or a
    jr z,read_missing
    push ix
    pop hl
    inc hl
    push iy
    pop de
    ld a,5
    sub c
    ldir
    or a
    jr z,read_done
    ld b,a
    xor a
read_pad:
    ld (de),a
    inc de
    djnz read_pad
read_done:
    pop iy
    pop ix
    ret
read_missing:
    pop iy
    pop ix
    jp novar_target

; CALL; destination:u24. Integer/byte stores use the original SFIX entry38
; on v0 before copying. Keep the destination and exact width across NUM.
cp_store1:
    ld bc,1
    jr store_integer
cp_store4:
    ld bc,4
store_integer:
    pop hl
    ld de,(hl)                ; ADL24 OK: inline three-byte payload pointer
    inc hl
    inc hl
    inc hl
    push hl
    push bc
    push de
    ld ix,(cp_num_base)        ; ADL24 OK: private three-byte v0 pointer
    push ix
    pop iy
    ld a,38
    call numeric_target
    pop de
    pop bc
    jp c,numerror_target
    ld hl,(cp_num_base)        ; ADL24 OK: private three-byte v0 pointer
    ldir
    ret
cp_store5:
    pop hl
    ld de,(hl)                ; ADL24 OK: inline three-byte payload pointer
    inc hl
    inc hl
    inc hl
    push hl
    ld hl,(cp_num_base)        ; ADL24 OK: private three-byte v0 pointer
    ld bc,5
    ldir
    ret

; CALL; binding:u24; subscript_slot:u8; width:u8; count:u8. Prefix and full
; addressing retain the existing memory helper's independent early checks.
    .macro array_call target
    pop hl
    ld ix,(hl)                ; ADL24 OK: inline three-byte binding pointer
    inc hl
    inc hl
    inc hl
    ld a,(hl)
    inc hl
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    push hl
    call num_ptr
    push hl
    pop iy
    ld a,c
    call \target
    jp c,memerror_target
    ret
    .endm
cp_arrayprefix:
    array_call prefix_target
cp_arrayaddr:
    array_call addr_target

; CALL; binding:u24; type:u8. Save still precedes argument evaluation.
cp_actsave:
    pop hl
    ld ix,(hl)                ; ADL24 OK: inline three-byte binding pointer
    inc hl
    inc hl
    inc hl
    ld a,(hl)
    inc hl
    push hl
    call save_target
    jp c,acterror_target
    ret

; CALL; record_offset:u8; kind:u8; temporary_slot:u8. kind0=numeric,1=string.
cp_actbind:
    pop hl
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld a,(hl)
    inc hl
    push hl
    bit 0,c
    jr nz,bind_string
    call num_ptr
    jr bind_ready
bind_string:
    call str_ptr
bind_ready:
    push hl
    pop iy
    ld a,b
    call bind_target
    jp c,acterror_target
    ret
cp_actbegin:
    call begin_target
    jp c,acterror_target
    ret

; Pointer cells and JP operands are external bridge fields, not internal PIC
; operands. Optional unused facilities receive zero; emitted calls require them.
cp_num_base: .d24 0
cp_str_base: .d24 0
numeric_target: .byte 0xc3
cp_slot_numeric: .d24 0
numerror_target: .byte 0xc3
cp_slot_numerror: .d24 0
literal_target: .byte 0xc3
cp_slot_literal: .d24 0
novar_target: .byte 0xc3
cp_slot_novar: .d24 0
prefix_target: .byte 0xc3
cp_slot_prefix: .d24 0
addr_target: .byte 0xc3
cp_slot_addr: .d24 0
memerror_target: .byte 0xc3
cp_slot_memerror: .d24 0
save_target: .byte 0xc3
cp_slot_save: .d24 0
bind_target: .byte 0xc3
cp_slot_bind: .d24 0
begin_target: .byte 0xc3
cp_slot_begin: .d24 0
acterror_target: .byte 0xc3
cp_slot_acterror: .d24 0
