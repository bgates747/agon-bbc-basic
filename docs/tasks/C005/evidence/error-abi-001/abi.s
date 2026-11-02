; Native source-error checkpoint, lost-local ownership and retained-handler probe.
    .assume adl=1
    .text
    .global entry
    .extern err_init,err_install,err_raise,err_inline,err_line,err_report
    .extern err_code,err_current,err_lastline,err_message,err_state
    .extern err_ctlpush_slot,err_strload_slot,err_strstore_slot,err_exit_slot
    .extern err_cfg_ctltop,err_cfg_acttop,err_cfg_frames,err_cfg_base
    .extern err_cfg_limit,err_cfg_rootsp,err_cfg_depth,err_cfg_heap
    .extern ctl_init,ctl_push,ctl_check,ctl_pop,ctl_top,ctl_frames
    .extern act_init,act_begin,act_save,act_install,act_leave,act_top
    .extern act_pushslot,act_checkslot,act_popslot,act_numslot
    .extern rt_strload,rt_strstore
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
    .macro stage n
    ld a,\n
    ld (stage_value),a
    .endm
    .macro patch field,value
    ld hl,\value
    ld (\field),hl
    .endm
    .macro bind_local binding,kind
    ld ix,\binding
    ld a,\kind
    call act_save
    good
    call act_install
    good
    .endm
    .macro store descriptor,text
    ld ix,\descriptor
    ld iy,\text
    ld hl,heapctx
    call rt_strstore
    good
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
    patch act_pushslot,ctl_push
    patch act_checkslot,ctl_check
    patch act_popslot,ctl_pop
    patch err_ctlpush_slot,ctl_push
    patch err_strload_slot,rt_strload
    patch err_strstore_slot,rt_strstore
    patch err_exit_slot,fatal_exit
    patch err_cfg_ctltop,ctl_top
    patch err_cfg_acttop,act_top
    patch err_cfg_frames,ctl_frames
    patch err_cfg_base,arena
    patch err_cfg_limit,arena_end
    patch err_cfg_rootsp,saved_sp
    patch err_cfg_depth,depth
    patch err_cfg_heap,heapctx
    call ctl_init
    ld hl,arena
    ld de,arena_end
    call act_init
    ld ix,0x123456
    ld iy,0xabcdef
    call err_init
    push ix
    pop hl
    same 0x123456
    push iy
    pop hl
    same 0xabcdef
    stage 1
    ld hl,wrong_handler
    ld a,1
    call err_install
    good
    ld hl,(ctl_top)
    same ctl_frames+128
    ld hl,(act_top)
    same arena+56
    call ctl_init
    ld hl,arena
    ld de,arena_end
    call act_init
    call err_init
    ld a,3
    ld hl,0
    ld de,0
    ld b,0
    call ctl_push
    good
    ld hl,wrong_handler
    ld a,1
    call err_install
    good
    ld hl,(ctl_top)
    same ctl_frames+160
    ld hl,(act_top)
    same arena+56
    call ctl_init
    ld hl,arena
    ld de,arena_end
    call act_init
    call err_init
    ld hl,global_handler
    xor a
    call err_install
    good
    call lost_locals
    jp failed
lost_locals:
    call act_begin
    good
    bind_local number,4
    ld hl,99
    ld (number+1),hl
    ld a,0
    ld (number+4),a
    bind_local string,129
    store string+1,lost_text
    bind_local string,129
    store string+1,maximum_text
    bind_local empty_string,129
    call err_line
    .byte 0x78,0x56,0x34,0x12
    ld iy,message
    ld a,100
    jp err_raise
global_handler:
    ld a,(stage_value)
    cp 1
    jp nz,failed
    ld hl,(number+1)
    same 99
    ld hl,(ctl_top)
    same ctl_frames
    ld hl,(act_top)
    same arena
    ld a,(err_message)
    cp 4
    jp nz,failed
    call err_report
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    ld hl,(err_lastline)
    same 0x345678
    ld a,(err_lastline+3)
    cp 0x12
    jp nz,failed
    call check_lost
    call overwrite
    call check_lost
    ld a,(handler_count)
    or a
    jr nz,empty_already_checked
    ld a,(empty_string+1)
    or a
    jp nz,failed
    ld a,(empty_string+2)
    or a
    jp nz,failed
    ld hl,(empty_string+3)
    same 0
    store empty_string+1,after_text
empty_already_checked:
    ld a,(handler_count)
    inc a
    ld (handler_count),a
    cp 1
    jr nz,global_second
    ld a,(err_code)
    cp 100
    jp nz,failed
    ld iy,message
    ld a,101
    jp err_raise
global_second:
    cp 2
    jp nz,failed
    ld a,(err_code)
    cp 101
    jp nz,failed
    ld hl,0
    xor a
    call err_install
    good
    stage 2
    ld a,5
    ld (depth),a
    call local_proc
    ld hl,(number+1)
    same 99
    ld hl,(other+1)
    same 77
    ld hl,(err_state+1)
    same 0
    ld hl,(ctl_top)
    same ctl_frames
    ld hl,(act_top)
    same arena
    call check_after
    call overwrite
    call check_after
    stage 3
    ld hl,wrong_handler
    xor a
    call err_install
    good
    call err_line
    .byte 255,254,0,0
    ld a,0
    call err_inline
    .byte 10
    .ascii "fatal-zero"
    jp failed
local_proc:
    call act_begin
    good
    bind_local number,4
    ld hl,7
    ld (number+1),hl
    ld a,0
    ld (number+4),a
    ld hl,local_handler
    ld a,1
    call err_install
    good
    bind_local other,4
    ld hl,77
    ld (other+1),hl
    xor a
    ld (other+4),a
    bind_local string,129
    store string+1,after_text
    ld a,9
    ld (depth),a
    call throw_nested
    jp failed
throw_nested:
    ld iy,message
    ld a,111
    jp err_raise
local_handler:
    ld a,(err_code)
    cp 111
    jp nz,failed
    ld a,(depth)
    cp 5
    jp nz,failed
    ld hl,(number+1)
    same 7
    ld hl,(other+1)
    same 77
    call check_after
    call overwrite
    call check_after
    call act_leave
    good
    ret
overwrite:
    call act_begin
    good
    bind_local temporary,129
    store temporary+1,maximum_text
    call act_leave
    good
    ret
check_lost:
    ld a,(string+1)
    cp 255
    jp nz,failed
    ld hl,(string+3)
    ld b,255
check_lost_loop:
    ld a,(hl)
    cp 'q'
    jp nz,failed
    inc hl
    djnz check_lost_loop
    ret
check_after:
    ld a,(string+1)
    cp 5
    jp nz,failed
    ld hl,(string+3)
    ld a,(hl)
    cp 'a'
    jp nz,failed
    inc hl
    inc hl
    inc hl
    inc hl
    ld a,(hl)
    cp 'r'
    jp nz,failed
    ret
wrong_handler:
    jp failed
fatal_exit:
    ld a,(stage_value)
    cp 3
    jp nz,failed
    ld a,(err_code)
    or a
    jp nz,failed
    ld a,(err_message)
    cp 10
    jp nz,failed
    ld hl,(ctl_top)
    same ctl_frames
    ld hl,(act_top)
    same arena
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
handler_count: .byte 0
depth: .byte 0
number: .byte 1
    .4byte 7
other: .byte 1
    .4byte 3
string: .byte 1,5,5
    .d24 outer_text
empty_string: .byte 1,5,5
    .d24 outer_text
temporary: .byte 1,0,0
    .d24 0
outer_text: .ascii "outer"
lost_text: .byte 4
    .ascii "lost"
after_text: .byte 5
    .ascii "after"
maximum_text: .byte 255
    .fill 255,1,113
message: .byte 9
    .ascii "boom"
    .byte 0
    .ascii "tail"
heapctx: .d24 heap,heap_end
heap: .space 4096,0
heap_end:
arena: .space 32768,0
arena_end:
