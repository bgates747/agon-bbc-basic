; Native adapter probes: real unchanged NUM, observation bridges for MEM/ACT.
    .assume adl=1
    .text
    .global entry
    .extern cp_literal,cp_numeric,cp_read1,cp_read4,cp_read5
    .extern cp_store1,cp_store4,cp_store5,cp_arrayprefix,cp_arrayaddr
    .extern cp_actsave,cp_actbind,cp_actbegin
    .extern cp_num_base,cp_str_base,cp_slot_numeric,cp_slot_numerror
    .extern cp_slot_literal,cp_slot_novar,cp_slot_prefix,cp_slot_addr
    .extern cp_slot_memerror,cp_slot_save,cp_slot_bind,cp_slot_begin,cp_slot_acterror
    .extern rt_numeric,rt_literal
    .macro patch field,value
    ld hl,\value
    ld (\field),hl               ; ADL24 OK: three-byte bridge field
    .endm
    .macro stage n
    ld a,\n
    ld (stage_value),a
    .endm
    .macro same value
    ld de,\value
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro stack_ok
    ld hl,0
    add hl,sp
    ld de,(saved_sp)             ; ADL24 OK: saved three-byte stack pointer
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro byte_at address,value
    ld a,(\address)
    cp \value
    jp nz,failed
    .endm
    .macro same_packet address,expected
    ld hl,\address
    ld de,\expected
    ld bc,5
    call compare_bytes
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
    ld (saved_sp),sp             ; ADL24 OK: three-byte saved pointer
    patch cp_num_base,num_pool
    patch cp_str_base,str_pool
    patch cp_slot_numeric,rt_numeric
    patch cp_slot_numerror,error_bridge
    patch cp_slot_literal,rt_literal
    patch cp_slot_novar,missing_bridge
    patch cp_slot_prefix,prefix_stub
    patch cp_slot_addr,addr_stub
    patch cp_slot_memerror,error_bridge
    patch cp_slot_save,save_stub
    patch cp_slot_bind,bind_stub
    patch cp_slot_begin,begin_stub
    patch cp_slot_acterror,error_bridge

    stage 1
    ld iy,0xabcdef
    ld bc,0xfedcba
    call cp_literal
    .byte 31,0,0,0,0x30,0x81     ; float2.75; packet is copied, not reinterpreted
    same_packet num_pool+155,positive_fraction
    push ix
    pop hl
    same num_pool+155
    push iy
    pop hl
    same 0xabcdef
    stack_ok

    stage 2
    call cp_literal
    .byte 0,2,0,0,0,0
    call cp_literal
    .byte 31,3,0,0,0,0
    ld bc,0xfedcba
    call cp_numeric
    .byte 0,31,11               ; reference NUM selector11: ADD2+3
    same_packet num_pool,five
    push ix
    pop hl
    same num_pool
    push iy
    pop hl
    same num_pool+155
    stack_ok

    stage 3
    ld ix,0x123456
    ld iy,0xabcdef
    call cp_read1
    .d24 byte_binding
    .byte 31
    same_packet num_pool+155,byte_value
    push ix
    pop hl
    same 0x123456
    push iy
    pop hl
    same 0xabcdef
    call cp_read4
    .d24 integer_binding
    .byte 0
    same_packet num_pool,integer_value
    call cp_read5
    .d24 variant_binding
    .byte 31
    same_packet num_pool+155,positive_fraction
    stack_ok

    stage 4
    call cp_literal
    .byte 0,0xa5,0xa5,0xa5,0xa5,0
    call cp_read4
    .d24 missing_binding
    .byte 0
    jp nc,failed
    cp 26
    jp nz,failed
    same_packet num_pool,unchanged_value
    push ix
    pop hl
    same num_pool                  ; cp_literal set IX before the missing read
    push iy
    pop hl
    same 0xabcdef
    stack_ok

    stage 5
    call cp_literal
    .byte 0,0,0,0,0x30,0x81
    call cp_store4
    .d24 integer_destination
    byte_at integer_destination,2
    byte_at integer_destination+1,0
    byte_at integer_destination+2,0
    byte_at integer_destination+3,0
    byte_at integer_destination-1,0x55
    byte_at integer_destination+4,0x66
    push ix
    pop hl
    same num_pool
    push iy
    pop hl
    same num_pool
    stack_ok

    stage 6
    call cp_literal
    .byte 0,0,0,0,0xb0,0x81
    call cp_store4
    .d24 integer_destination
    ld hl,(integer_destination)   ; ADL24 OK: inspect low three of four payload bytes
    same 0xfffffe
    byte_at integer_destination+3,255
    stack_ok

    stage 7
    call cp_literal
    .byte 0,1,1,0,0,0             ; integer257 -> byte1
    call cp_store1
    .d24 byte_destination
    byte_at byte_destination,1
    byte_at byte_destination-1,0x77
    byte_at byte_destination+1,0x88
    call cp_literal
    .byte 0,255,255,255,255,0
    call cp_store1
    .d24 byte_destination
    byte_at byte_destination,255
    stack_ok

    stage 8
    call cp_literal
    .byte 0,0,0,0,0,0x9f          ; positive2^31, real SFIX overflow
    call cp_store4
    .d24 integer_destination
    jp nc,failed
    cp 20
    jp nz,failed
    ld hl,(integer_destination)   ; ADL24 OK: inspect low three payload bytes
    same 0xfffffe
    byte_at integer_destination+3,255
    byte_at integer_destination+4,0x66
    stack_ok

    stage 9
    call cp_store1
    .d24 byte_destination
    jp nc,failed
    cp 20
    jp nz,failed
    byte_at byte_destination,255
    byte_at byte_destination+1,0x88
    stack_ok

    stage 10
    call cp_literal
    .byte 0,0,0,0,0x30,0x81
    ld ix,0x123456
    ld iy,0xabcdef
    call cp_store5
    .d24 variant_destination
    same_packet variant_destination,positive_fraction
    byte_at variant_destination-1,0x99
    byte_at variant_destination+5,0xaa
    push ix
    pop hl
    same 0x123456
    push iy
    pop hl
    same 0xabcdef
    stack_ok

    stage 11
    xor a
    ld (mode),a
    ld bc,0xaabbcc
    call cp_arrayprefix
    .d24 array_cell
    .byte 31,4,1
    push ix
    pop hl
    same array_cell
    push iy
    pop hl
    same num_pool+155
    byte_at observed_a,1
    byte_at observed_b,4
    byte_at observed_tag,1
    stack_ok

    stage 12
    ld a,1
    ld (mode),a
    call cp_arrayaddr
    .d24 array_cell
    .byte 0,5,16
    jp nc,failed
    cp 15
    jp nz,failed
    byte_at observed_tag,2
    byte_at observed_a,16
    byte_at observed_b,5
    push iy
    pop hl
    same num_pool
    stack_ok

    stage 13
    xor a
    ld (mode),a
    ld iy,0xabcdef
    call cp_actsave
    .d24 variant_binding
    .byte 129
    byte_at observed_a,129
    byte_at observed_tag,3
    push ix
    pop hl
    same variant_binding
    push iy
    pop hl
    same 0xabcdef
    stack_ok

    stage 14
    call cp_actbind
    .byte 15,0,31
    byte_at observed_a,15
    byte_at observed_tag,4
    push iy
    pop hl
    same num_pool+155
    stack_ok

    stage 15
    call cp_actbind
    .byte 0,1,31
    byte_at observed_a,0
    push iy
    pop hl
    same str_pool+31*256
    stack_ok

    stage 16
    ld a,1
    ld (mode),a
    call cp_actbegin
    jp nc,failed
    or a
    jp nz,failed
    byte_at observed_tag,5
    stack_ok
    stage 17
    xor a
    ld (mode),a
    call cp_actbegin
    jp c,failed
    stack_ok
    stage 18
    call cp_literal
    .byte 0,7,0,0,0,0
    call cp_literal
    .byte 31,0,0,0,0,0
    call cp_numeric
    .byte 0,31,15               ; real division by zero, left value unchanged
    jp nc,failed
    cp 18
    jp nz,failed
    same_packet num_pool,seven
    stack_ok
    stage 19
    ld a,1
    ld (mode),a
    call cp_actsave
    .d24 integer_binding
    .byte 4
    jp nc,failed
    or a
    jp nz,failed
    stack_ok
    stage 20
    call cp_actbind
    .byte 15,1,31
    jp nc,failed
    or a
    jp nz,failed
    stack_ok
    stage 21
    patch cp_str_base,0
    patch cp_slot_prefix,0
    patch cp_slot_addr,0
    patch cp_slot_memerror,0
    patch cp_slot_save,0
    patch cp_slot_bind,0
    patch cp_slot_begin,0
    patch cp_slot_acterror,0
    call cp_numeric
    .byte 0,31,11
    same_packet num_pool,seven
    call cp_read4
    .d24 integer_binding
    .byte 0
    call cp_store4
    .d24 integer_destination
    same_packet num_pool,integer_value
    byte_at integer_destination+4,0x66
    stack_ok
    byte_at num_guard,0x35
    byte_at num_end_guard,0x53
    ld hl,success_text
    call print_text
    ld hl,0
    jr exit
failed:
    ld a,'F'
    rst.lis 0x10
    ld a,(stage_value)
    add a,64
    rst.lis 0x10
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    ld hl,1
exit:
    ld sp,(saved_sp)             ; ADL24 OK: restore three-byte SP
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
compare_bytes:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    dec bc
    push hl
    ld hl,0
    or a
    sbc hl,bc
    pop hl
    jr nz,compare_bytes
    ret
print_text:
    ld a,(hl)
    or a
    ret z
    rst.lis 0x10
    inc hl
    jr print_text
missing_bridge:
    ld a,26
error_bridge:
    ld (error_seen),a
    scf
    ret
prefix_stub:
    push af
    ld a,1
    ld (observed_tag),a
    pop af
    jr memory_stub
addr_stub:
    push af
    ld a,2
    ld (observed_tag),a
    pop af
memory_stub:
    ld (observed_a),a
    ld a,b
    ld (observed_b),a
    ld a,(mode)
    or a
    ret z
    ld a,15
    scf
    ret
save_stub:
    push af
    ld a,3
    ld (observed_tag),a
    pop af
    jr activation_stub
bind_stub:
    push af
    ld a,4
    ld (observed_tag),a
    pop af
    jr activation_stub
begin_stub:
    ld a,5
    ld (observed_tag),a
    xor a
activation_stub:
    ld (observed_a),a
    ld a,(mode)
    or a
    ret z
    xor a
    scf
    ret
saved_sp: .d24 0
stage_value: .byte 0
mode: .byte 0
error_seen: .byte 0
observed_a: .byte 0
observed_b: .byte 0
observed_tag: .byte 0
byte_binding: .byte 1,255
integer_binding: .byte 1,0x78,0x56,0x34,0x92
variant_binding: .byte 1,0,0,0,0x30,0x81
missing_binding: .byte 0,1,2,3,4
byte_value: .byte 255,0,0,0,0
integer_value: .byte 0x78,0x56,0x34,0x92,0
positive_fraction: .byte 0,0,0,0x30,0x81
unchanged_value: .byte 0xa5,0xa5,0xa5,0xa5,0
five: .byte 5,0,0,0,0
seven: .byte 7,0,0,0,0
.byte 0x55
integer_destination: .space 4,0xcc
.byte 0x66,0x77
byte_destination: .byte 0xcc
.byte 0x88,0x99
variant_destination: .space 5,0xcc
.byte 0xaa
array_cell: .d24 0
success_text: .asciz "COMPACT_ABI_OK\r\n"
    .org 0x10000
num_guard: .byte 0x35
num_pool: .space 160,0xa5
num_end_guard: .byte 0x53
str_pool: .space 8192,0x5a
