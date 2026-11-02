; Direct MOS bridge ABI probe. Fixture/result bytes are checked by the runner.
    .assume adl=1
    .text
    .global entry
    .extern io_open,io_get,io_eof,io_put,io_puts,io_close
    .extern io_filename,io_line_buffer
    .macro stage n
    ld a,\n
    ld (stage_value),a
    .endm
    .macro good
    jp c,failed
    jp nz,failed
    or a
    jp nz,failed
    .endm
    .macro same value
    ld de,\value
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro preserved x,y
    push ix
    pop hl
    same \x
    push iy
    pop hl
    same \y
    ld hl,0
    add hl,sp
    ld de,(saved_sp)
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro high_zero
    ld hl,(packet+1)
    same 0
    ld a,(packet+4)
    or a
    jp nz,failed
    .endm
    .macro get value
    ld ix,packet
    ld iy,0xabcdef
    ld bc,0xabcdef
    ld a,(handle)
    call io_get
    good
    ld a,(packet)
    cp \value
    jp nz,failed
    high_zero
    preserved packet,0xabcdef
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
    xor a
    call io_close
    stage 1
    ld ix,packet
    ld iy,input_name
    ld bc,0xabcdef
    ld a,1
    call io_open
    good
    ld a,(packet)
    or a
    jp z,failed
    ld (handle),a
    high_zero
    preserved packet,input_name
    stage 2
    ld a,(handle)
    call io_eof
    good
    ld hl,(packet)
    same 0
    high_zero
    preserved packet,input_name
    stage 3
    get 0
    get 127
    get 128
    get 255
    stage 4
    ld a,(handle)
    call io_eof
    good
    ld hl,(packet)
    same 0xffffff
    ld a,(packet+3)
    cp 255
    jp nz,failed
    ld a,(packet+4)
    or a
    jp nz,failed
    preserved packet,0xabcdef
    ld a,(handle)
    call io_close
    good
    stage 5
    ld a,255
    call io_eof
    good
    ld hl,(packet)
    same 0
    high_zero
    xor a
    call io_get
    good
    ld a,(packet)
    or a
    jp nz,failed
    high_zero
    stage 6
    ld iy,empty_name
    ld a,1
    call io_open
    good
    ld a,(packet)
    or a
    jp nz,failed
    high_zero
    preserved packet,empty_name
    stage 7
    ld a,0xa5
    ld (io_line_buffer),a
    ld iy,maximum_name
    ld a,1
    call io_open
    good
    ld a,(packet)
    or a
    jp nz,failed
    ld a,(io_line_buffer)
    cp 0xa5
    jp nz,failed
    ld a,(name_guard_before)
    cp 0xa5
    jp nz,failed
    ld a,(name_guard_after)
    cp 0xa5
    jp nz,failed
    ld a,(maximum_name)
    cp 255
    jp nz,failed
    ld a,(maximum_name+255)
    or a
    jp nz,failed
    high_zero
    preserved packet,maximum_name
    stage 8
    ld iy,output_name
    ld a,10
    call io_open
    good
    ld a,(packet)
    or a
    jp z,failed
    ld (handle),a
    high_zero
    preserved packet,output_name
    stage 9
    ld ix,0x123456
    ld iy,0xabcdef
    ld bc,0xabcdef
    ld b,0
    ld a,(handle)
    call io_put
    good
    preserved 0x123456,0xabcdef
    ld b,255
    ld a,(handle)
    call io_put
    good
    preserved 0x123456,0xabcdef
    stage 10
    ld iy,binary_string
    ld bc,0xabcdef
    ld c,1
    ld a,(handle)
    call io_puts
    good
    preserved 0x123456,binary_string
    ld iy,empty_name
    ld c,0
    ld a,(handle)
    call io_puts
    good
    ld c,1
    ld a,(handle)
    call io_puts
    good
    preserved 0x123456,empty_name
    stage 11
    ld iy,maximum_string
    ld c,0
    ld a,(handle)
    call io_puts
    good
    preserved 0x123456,maximum_string
    ld a,(handle)
    call io_close
    good
    preserved 0x123456,maximum_string
    stage 12
    ld a,(packet_guard_before)
    cp 0xa5
    jp nz,failed
    ld a,(packet_guard_after)
    cp 0xa5
    jp nz,failed
    ld a,(binary_string)
    cp 3
    jp nz,failed
    ld a,(binary_string+2)
    cp 128
    jp nz,failed
    ld a,(maximum_string+255)
    cp 'q'
    jp nz,failed
    ld hl,0
    jr finish
failed:
    ld hl,0
    ld a,(stage_value)
    ld l,a
finish:
    ld sp,(saved_sp)
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
saved_sp: .d24 0
stage_value: .byte 1
handle: .byte 0
input_name: .byte input_end-input_text
input_text: .ascii "io-abi-in.dat"
input_end:
output_name: .byte output_end-output_text
output_text: .ascii "io-abi-out.dat"
output_end:
empty_name: .byte 0
name_guard_before: .byte 0xa5
maximum_name: .byte 255
    .space 255,0
name_guard_after: .byte 0xa5
binary_string: .byte 3,0,128,255
maximum_string: .byte 255
    .fill 255,1,113
    .balign 256
    .space 253
packet_guard_before: .byte 0xa5
packet: .fill 5,1,0xa5
packet_guard_after: .byte 0xa5
