; DATA helper ABI and cursor atomicity probe. Repository license applies.
    .assume adl=1
    .text
    .global entry
    .extern data_peek,data_number,data_string,data_commit
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
    stage 1
    ld ix,context
    ld iy,packet
    ld bc,0xabcdef
    call data_peek
    good
    preserved context,packet
    ld hl,(packet)
    same first
    ld hl,(packet+2)
    ld de,first
    ld a,(packet+2)
    cp 4
    jp nz,failed
    ld a,(packet+3)
    or a
    jp nz,failed
    ld a,(packet+4)
    or a
    jp nz,failed
    ld hl,(context)
    same first
    stage 2
    ld ix,value
    ld iy,first
    ld bc,0xabcdef
    call data_number
    good
    preserved value,first
    ld hl,(value)
    same 0x332211
    ld a,(value+3)
    cp 0x44
    jp nz,failed
    ld a,(value+4)
    cp 128
    jp nz,failed
    stage 3
    ld ix,string
    call data_string
    good
    preserved string,first
    ld a,(string)
    cp 3
    jp nz,failed
    ld a,(string+1)
    or a
    jp nz,failed
    ld a,(string+2)
    cp 128
    jp nz,failed
    ld a,(string+3)
    cp 255
    jp nz,failed
    stage 4
    ld ix,context
    ld hl,records_end
    ld (context),hl
    call data_commit
    good
    preserved context,first
    ld hl,(context)
    same second
    stage 5
    ld ix,value
    ld iy,second
    call data_number
    jp nc,failed
    cp 6
    jp nz,failed
    preserved value,second
    ld hl,(value)
    same 0x332211
    ld ix,string
    call data_string
    good
    preserved string,second
    ld a,(string)
    or a
    jp nz,failed
    ld a,(string+2)
    cp 128
    jp nz,failed
    stage 6
    ld iy,maximum
    ld bc,0xabcdef
    call data_string
    good
    preserved string,maximum
    ld a,(string)
    cp 255
    jp nz,failed
    ld hl,string+1
    ld b,255
check_maximum:
    ld a,(hl)
    cp 0xa5
    jp nz,failed
    inc hl
    djnz check_maximum
    ld ix,context
    call data_commit
    good
    preserved context,maximum
    ld hl,(context)
    same records_end
    stage 7
    ld iy,packet
    call data_peek
    jp nc,failed
    cp 42
    jp nz,failed
    preserved context,packet
    ld hl,(packet)
    same first
    ld hl,records_end+65536
    ld (context),hl
    call data_peek
    jp nc,failed
    cp 42
    jp nz,failed
    preserved context,packet
    ld a,(guard_before)
    cp 0x5a
    jp nz,failed
    ld a,(guard_after)
    cp 0x5a
    jp nz,failed
    ld a,(value_before)
    cp 0x5a
    jp nz,failed
    ld a,(value_after)
    cp 0x5a
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
context: .d24 first,records_end
packet: .fill 5,1,0xa5
value_before: .byte 0x5a
value: .fill 5,1,0xa5
value_after: .byte 0x5a
    .balign 256
    .space 251
first: .byte 3,0,0x11,0x22,0x33,0x44,128,0,0,128,255
second: .byte 0,6,0,0,0,0,0,0
maximum: .byte 255,20,0,0,0,0,0,0
    .fill 255,1,0xa5
records_end:
guard_before: .byte 0x5a
string: .fill 256,1,0x5a
guard_after: .byte 0x5a
