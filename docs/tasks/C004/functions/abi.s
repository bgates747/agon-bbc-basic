; FN prefix/caller restoration including poisoned upper BC and zero pointers.
    .assume adl=1
    .text
    .global entry
    .extern ctl_init,ctl_push,ctl_check,ctl_pop,ctl_numslot,rt_numeric
    .extern act_init,act_begin,act_save,act_install,act_leave
    .extern act_fn_begin,act_fn_leave,act_pushslot,act_checkslot,act_popslot,act_numslot
    .macro require
    jp c,failed
    .endm
    .macro preserved left,right
    push ix
    pop hl
    ld de,\left
    or a
    sbc hl,de
    jp nz,failed
    push iy
    pop hl
    ld de,\right
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
    ld hl,rt_numeric
    ld (ctl_numslot),hl
    ld (act_numslot),hl
    ld hl,ctl_push
    ld (act_pushslot),hl
    ld hl,ctl_check
    ld (act_checkslot),hl
    ld hl,ctl_pop
    ld (act_popslot),hl
    call ctl_init
    ld hl,arena
    ld de,arena_end
    call act_init
    ld ix,numbers
    ld iy,strings
    ld bc,0xab0202
    call act_fn_begin
    require
    preserved numbers,strings
    call zero_pools
    call act_fn_leave
    require
    preserved numbers,strings
    call check_pools
    ld ix,numbers
    ld iy,strings
    ld bc,0xcd0202
    call act_fn_begin
    require
    ld a,9
    ld (numbers),a
    ld a,1
    ld (strings),a
    ld a,'Q'
    ld (strings+1),a
    ld bc,0xef0101
    call act_fn_begin
    require
    call zero_pools
    call act_fn_leave
    require
    ld a,(numbers)
    cp 9
    jp nz,failed
    ld a,(strings)
    cp 1
    jp nz,failed
    ld a,(strings+1)
    cp 'Q'
    jp nz,failed
    ld a,(numbers+5)
    or a
    jp nz,failed
    call act_fn_leave
    require
    call check_pools
    ld ix,numbers
    ld iy,strings
    ld bc,0xab0202
    call act_fn_begin
    require
    ld ix,binding
    ld a,4
    call act_save
    require
    call act_install
    ld a,42
    ld (binding+1),a
    call zero_pools
    call act_fn_leave
    require
    ld a,(binding+1)
    cp 7
    jp nz,failed
    call check_pools
    call act_begin
    require
    call act_fn_leave
    jp nc,failed
    cp 7
    jp nz,failed
    call act_leave
    require
    ld ix,0
    ld iy,0
    ld bc,0xab0000
    call act_fn_begin
    require
    call act_leave
    jp nc,failed
    cp 13
    jp nz,failed
    call act_fn_leave
    require
    ld hl,arena
    ld de,arena+522
    call act_init
    ld ix,numbers
    ld iy,strings
    ld bc,0xab0202
    call act_fn_begin
    require
    ld ix,0
    ld iy,0
    ld bc,0xcd0000
    call act_fn_begin
    require
    call act_fn_leave
    require
    ld ix,numbers
    ld iy,0
    ld bc,0xef0100
    call act_fn_begin
    jp nc,failed
    or a
    jp nz,failed
    call act_fn_leave
    require
    call check_pools
    ld hl,0
    add hl,sp
    ld de,(saved_sp)
    or a
    sbc hl,de
    jp nz,failed
    ld hl,0
    jr finish
failed:
    ld hl,1
finish:
    ld sp,(saved_sp)
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret
zero_pools:
    ld hl,numbers
    ld de,numbers+1
    ld (hl),0
    ld bc,9
    ldir
    ld hl,strings
    ld de,strings+1
    ld (hl),0
    ld bc,511
    ldir
    ret
check_pools:
    ld hl,numbers
    ld de,expected_numbers
    ld bc,10
    call compare
    ld hl,strings
    ld de,expected_strings
    ld bc,512
    jp compare
compare:
    ld a,(de)
    cp (hl)
    jp nz,failed
    inc hl
    inc de
    dec bc
    ld a,b
    or c
    jr nz,compare
    ret
saved_sp: .d24 0
binding: .byte 1,7,0,0,0
numbers: .byte 1,2,3,4,5,6,7,8,9,10
strings: .fill 512,1,113
expected_numbers: .byte 1,2,3,4,5,6,7,8,9,10
expected_strings: .fill 512,1,113
arena: .space 4096
arena_end:
