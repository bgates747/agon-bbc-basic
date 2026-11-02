; Native PROC/LOCAL helper preservation, restoration and arena-bound probe.
    .assume adl=1
    .text
    .global entry
    .extern ctl_init,ctl_push,ctl_check,ctl_pop,ctl_numslot,rt_numeric
    .extern act_init,act_begin,act_save,act_install,act_bind,act_leave
    .extern act_pushslot,act_checkslot,act_popslot,act_numslot
    .macro require
    jp c,failed
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
    ld ix,integer
    ld iy,0xabcdef
    ld a,4
    call act_save
    jp nc,failed
    cp 12
    jp nz,failed
    call act_leave
    jp nc,failed
    cp 13
    jp nz,failed
    call act_begin
    require
    ld a,4
    call act_save
    require
    ld iy,three
    xor a
    call act_bind
    require
    ld a,(integer+1)
    cp 3
    jp nz,failed
    call act_begin
    require
    ld a,4
    call act_save
    require
    call act_install
    require
    ld a,(integer+1)
    or a
    jp nz,failed
    ld a,9
    ld (integer+1),a
    call act_leave
    require
    ld a,(integer+1)
    cp 3
    jp nz,failed
    call act_leave
    require
    ld a,(integer+1)
    cp 7
    jp nz,failed
    ld ix,fresh
    call act_begin
    require
    ld a,4
    call act_save
    require
    call act_install
    ld a,9
    ld (fresh+1),a
    call act_leave
    require
    ld a,(fresh)
    cp 1
    jp nz,failed
    ld a,(fresh+1)
    or a
    jp nz,failed
    ld ix,string
    call act_begin
    require
    ld a,129
    call act_save
    require
    ld iy,full_string
    xor a
    call act_bind
    require
    ld a,(string+1)
    cp 255
    jp nz,failed
    ld a,(string+2)
    cp 255
    jp nz,failed
    ld hl,(string+3)
    ld a,(hl)
    cp 'x'
    jp nz,failed
    ld de,254
    add hl,de
    ld a,(hl)
    cp 'x'
    jp nz,failed
    call act_leave
    require
    ld a,(string+1)
    cp 3
    jp nz,failed
    ld hl,(string+3)
    ld de,old_string
    or a
    sbc hl,de
    jp nz,failed
    ld a,(old_string)
    cp 'o'
    jp nz,failed
    call ctl_init
    ld hl,arena
    ld de,arena+269
    call act_init
    call act_begin
    require
    ld a,129
    call act_save
    require
    ld a,129
    call act_save
    jp nc,failed
    or a
    jp nz,failed
    call act_leave
    require
    push ix
    pop hl
    ld de,string
    or a
    sbc hl,de
    jp nz,failed
    push iy
    pop hl
    ld de,full_string
    or a
    sbc hl,de
    jp nz,failed
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
saved_sp: .d24 0
integer: .byte 1,7,0,0,0
fresh: .byte 0,0,0,0,0
three: .byte 3,0,0,0,0
string: .byte 1,3,3
    .d24 old_string
old_string: .ascii "old"
full_string: .byte 255
    .fill 255,1,120
arena: .space 1024
arena_end:
