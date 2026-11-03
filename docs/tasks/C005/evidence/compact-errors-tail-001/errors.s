; C005 standalone source-error state and recovery experiment.
; ONERR/ERROR/RESLOC audit: retain handler, discard lost LOCAL records, preserve
; their CURRENT values. Repository zlib license; no interpreter entry/global.
    .assume adl=1
    .text
    .global err_init,err_install,err_raise,err_inline,err_report,err_line
    .global err_trap
    .global err_code,err_current,err_lastline,err_message,err_state
    .global err_ctlpush_slot,err_strload_slot,err_strstore_slot,err_exit_slot
    .global err_cfg_ctltop,err_cfg_acttop,err_cfg_frames,err_cfg_base
    .global err_cfg_limit,err_cfg_rootsp,err_cfg_depth,err_cfg_heap

; Entry reset preserves MOS argument registers before the main header saves them.
err_init:
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    ld hl,err_state
    ld de,err_state+1
    ld bc,23
    ld (hl),0
    ldir
    ld a,1
    ld (err_state+0),a
    ld (err_state+6),a
    ld (err_state+12),a
    ld (err_state+18),a
    xor a
    ld (err_code),a
    ld (err_message),a
    ld hl,0
    ld (err_current),hl
    ld (err_current+1),hl
    ld (err_lastline),hl
    ld (err_lastline+1),hl
    ld hl,initial_notice
    ld de,err_message
    ld bc,34
    ldir
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret

; Native inline4-byte line marker. IX/IY/SP preserved; arithmetic regs volatile.
err_line:
    pop hl
    ld de,err_current
    ld bc,4
    ldir
    push hl
    ret

; HL=native handler (zero OFF), A=0 global/1 LOCAL. LOCAL saves four opaque5-byte
; state values in compatible14-byte LOCAL records, even under a loop/root marker.
; Success A0/Z/NC, failure A0/Z/C (fatal No room); IX/IY/SP preserved.
err_install:
    ld (err_new_target),hl
    ld (err_new_mode),a
    ld hl,3
    add hl,sp
    ld (err_new_sp),hl
    push ix
    push iy
    or a
    jr z,install_state
    ld ix,err_state
    call save_one
    jr c,install_done
    ld ix,err_state+6
    call save_one
    jr c,install_done
    ld ix,err_state+12
    call save_one
    jr c,install_done
    ld ix,err_state+18
    call save_one
    jr c,install_done
install_state:
    ld hl,(err_new_target)
    ld (err_state+1),hl
    ld a,(err_new_mode)
    ld (err_state+4),a
    or a
    jr z,install_global
    ld hl,(err_new_sp)
    ld (err_state+7),hl
    ld hl,(err_cfg_ctltop)
    ld hl,(hl)
    ld (err_state+13),hl
    ld hl,(err_cfg_acttop)
    ld hl,(hl)
    ld (err_state+19),hl
    ld hl,(err_cfg_depth)
    ld a,(hl)
    ld (err_state+5),a
    jr install_success
install_global:
    xor a
    ld (err_state+5),a
    ld hl,0
    ld (err_state+7),hl
install_success:
    xor a
install_done:
    pop iy
    pop ix
    ret
save_one:
    ld hl,(err_cfg_acttop)
    ld hl,(hl)
    push hl
    ld de,14
    add hl,de
    ld (err_candidate),hl
    ld de,(err_cfg_limit)
    or a
    sbc hl,de
    pop iy
    jr c,save_space
    jr z,save_space
    xor a
    scf
    ret
save_space:
    push ix
    pop hl
    ld (iy+0),hl
    inc hl
    ld (iy+3),hl
    ld (iy+6),5
    push iy
    pop de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    ld bc,5
    ldir
    push iy
    pop hl
    ld a,6
    call ctlpush_bridge
    ret c
    ld hl,(err_cfg_acttop)
    ld de,(err_candidate)
    ld (hl),de
    xor a
    ret

; A=error byte,IY=read-only string256. Does not return: keep trap enabled and
; transfer to its saved CPU/control/arena checkpoint. Error0 bypasses the trap.
err_inline:
    pop iy                      ; Native return points at length+message bytes.
err_raise:
    ld (err_code),a
    ld hl,err_current
    ld de,err_lastline
    ld bc,4
    ldir
    ld bc,0
    ld b,(iy+0)
    push iy
    pop hl
    inc hl
    ld de,err_message+1
    ld a,b
    or a
    jr z,message_done
message_loop:
    ld a,(hl)
    or a
    jr z,message_done
    ld (de),a
    inc hl
    inc de
    inc c
    djnz message_loop
message_done:
    ld a,c
    ld (err_message),a
    ld hl,0
    ld (err_resume),hl
    ld a,(err_code)
    or a
    jr z,dispatch_root
    ld hl,(err_state+1)
    ld de,0
    or a
    sbc hl,de
    jr z,dispatch_root
    ld (err_resume),hl
    ld a,(err_state+4)
    or a
    jr z,dispatch_root
    ld hl,(err_state+7)
    ld (err_target_sp),hl
    ld hl,(err_state+13)
    ld (err_target_ctl),hl
    ld hl,(err_state+19)
    ld (err_target_act),hl
    ld a,(err_state+5)
    ld (err_target_depth),a
    jr dispatch_discard
dispatch_root:
    ld hl,(err_cfg_rootsp)
    ld hl,(hl)
    ld (err_target_sp),hl
    ld hl,(err_cfg_frames)
    ld (err_target_ctl),hl
    ld hl,(err_cfg_base)
    ld (err_target_act),hl
    xor a
    ld (err_target_depth),a
dispatch_discard:
    ld hl,(err_resume)
    ld de,0
    or a
    sbc hl,de
    jp z,dispatch_resume         ; Fatal exit has no surviving bindings to rescue.
    ld hl,(err_cfg_ctltop)
    ld hl,(hl)
    ld (err_walk),hl
walk_next:
    ld hl,(err_walk)
    ld de,(err_target_ctl)
    or a
    sbc hl,de
    jr z,dispatch_resume
    ld hl,(err_walk)
    ld de,32
    or a
    sbc hl,de
    ld (err_walk),hl
    ld a,(hl)
    cp 6
    jr nz,walk_next
    inc hl
    inc hl
    ld hl,(hl)
    push hl
    pop ix
    ld a,(ix+6)
    cp 129
    jr nz,walk_next
    call rescue_string
    jp c,rescue_no_room
    jr walk_next
dispatch_resume:
    ld hl,(err_cfg_ctltop)
    ld de,(err_target_ctl)
    ld (hl),de
    ld hl,(err_cfg_acttop)
    ld de,(err_target_act)
    ld (hl),de
    ld hl,(err_cfg_depth)
    ld a,(err_target_depth)
    ld (hl),a
    ld sp,(err_target_sp)
    ld hl,(err_resume)
    ld de,0
    or a
    sbc hl,de
    jp z,fatal_report
    jp (hl)

; IX=discarded LOCAL record. Only rescue CURRENT descriptor contents if its
; storage is being reclaimed. A repeated record sees the newly global pointer
; and skips it. Empty strings receive a zero-capacity descriptor for future stores.
rescue_string:
    ld hl,(ix+3)
    ld (err_binding),hl
    inc hl
    inc hl
    ld hl,(hl)
    ld de,(err_target_act)
    or a
    sbc hl,de
    jr c,rescue_skip
    ld hl,(err_binding)
    inc hl
    inc hl
    ld hl,(hl)
    push hl
    ld hl,(err_cfg_acttop)
    ld de,(hl)
    pop hl
    or a
    sbc hl,de
    jr nc,rescue_skip
    ld iy,(err_binding)
    ld ix,err_string
    call strload_bridge
    ld hl,0
    ld (err_descriptor),hl
    ld (err_descriptor+2),hl
    ld ix,err_descriptor
    ld iy,err_string
    ld hl,(err_cfg_heap)
    call strstore_bridge
    ret c
    ld hl,err_descriptor
    ld de,(err_binding)
    ld bc,5
    ldir
rescue_skip:
    xor a
    ret
rescue_no_room:
    xor a
    ld (err_code),a
    ld hl,no_room_message
    ld de,err_message
    ld bc,8
    ldir
    ld hl,(err_cfg_rootsp)
    ld hl,(hl)
    ld sp,hl
fatal_report:
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    call err_report
    call line_report
    ld a,13
    rst.lis 0x10
    ld a,10
    rst.lis 0x10
    jp exit_bridge

; REPORT has no implicit newline; err_raise already stopped copying at NUL.
; IX/IY/SP preserved, other registers volatile.
err_report:
    push ix
    push iy
    ld hl,err_message
    ld b,(hl)
    inc hl
    ld a,b
    or a
    jr z,report_done
report_loop:
    ld a,(hl)
    push bc
    push hl
    call report_out
    pop hl
    pop bc
    inc hl
    djnz report_loop
report_done:
    pop iy
    pop ix
    ret
; Altered MAIN.Z80 TEXT/OUT adaptation. Keyword data retains the original
; (C) COPYRIGHT R.T.RUSSELL 1981-2025 notice in report_keywords.inc.
; LF is raw output (TEXTLF), not the TINT token. Other mapped token/control
; bytes expand exactly through the private copied table. COUNT/WIDTH parser
; state is not linked; those source facilities remain outside this admission.
report_out:
    cp 10
    jp z,report_putchar
    cp 160
    jp pe,report_putchar
    push bc
    push hl
    ld hl,err_keywords
    ld bc,err_keyword_length
    cpir
    call nz,report_putchar
    ld b,160
    cp report_wrap_last+129
    jp pe,report_token
    inc b
report_token:
    ld a,(hl)
    inc hl
    cp b
    push af
    call pe,report_putchar
    pop af
    jp pe,report_token
    pop hl
    pop bc
    ret
report_putchar:
    push bc
    push hl
    rst.lis 0x10
    pop hl
    pop bc
    ret
 ; Conventional ERL is0..65279; unnumbered source uses0. Match SAYLN's
; low16 zero check and exact unsigned decimal line display. This formatter is
; metadata-only; BBC numeric values still use the unchanged numeric package.
line_report:
    ld hl,(err_lastline)
    ld a,h
    or l
    ret z
    ld hl,line_prefix
    ld b,9
    call report_bytes
    ld hl,(err_lastline)
    ld de,line_digits+5
    ld c,0
line_digit:
    xor a
    ld b,16
line_divide:
    add.s hl,hl
    rla
    cp 10
    jr c,line_divide_next
    sub 10
    inc l
line_divide_next:
    djnz line_divide
    add a,48
    dec de
    ld (de),a
    inc c
    ld a,h
    or l
    jr nz,line_digit
    push de
    pop hl
    ld b,c
report_bytes:
    ld a,(hl)
    push bc
    push hl
    rst.lis 0x10
    pop hl
    pop bc
    inc hl
    djnz report_bytes
    ret
ctlpush_bridge: .byte 0xc3
err_ctlpush_slot: .d24 0
strload_bridge: .byte 0xc3
err_strload_slot: .d24 0
strstore_bridge: .byte 0xc3
err_strstore_slot: .d24 0
exit_bridge: .byte 0xc3
err_exit_slot: .d24 0
err_cfg_ctltop: .d24 0
err_cfg_acttop: .d24 0
err_cfg_frames: .d24 0
err_cfg_base: .d24 0
err_cfg_limit: .d24 0
err_cfg_rootsp: .d24 0
err_cfg_depth: .d24 0
err_cfg_heap: .d24 0
; Each flag+opaque5 payload is compatible with an ordinary numeric LOCAL record.
err_state: .byte 1
    .space 5,0
    .byte 1
    .space 5,0
    .byte 1
    .space 5,0
    .byte 1
    .space 5,0
err_code: .byte 0
err_current: .space 4,0
err_lastline: .space 4,0
err_message: .space 256,0
err_new_target: .d24 0
err_new_sp: .d24 0
err_new_mode: .byte 0
err_candidate: .d24 0
err_resume: .d24 0
err_target_sp: .d24 0
err_target_ctl: .d24 0
err_target_act: .d24 0
err_target_depth: .byte 0
err_walk: .d24 0
err_binding: .d24 0
err_descriptor: .space 5,0
err_string: .space 256,0
no_room_message: .byte 7
    .ascii "No room"
line_prefix: .ascii " at line "
line_digits: .space 5,0
    .byte 0xa5 ; One-past digit cursor remains an in-template relocation.
initial_notice: .byte 33
    .ascii "(C) Copyright R.T.Russell 2025"
    .byte 13,10,10
    .include "report_keywords.inc"

; XEQ polls Escape after selecting an ON ERROR body. OSLINE's Escape path
; leaves a held key visible, so entering that handler can raise Escape again
; with the handler's CURLIN. Poll documented MOS sysvars instead of linking
; interpreter FLAGS/KEYASCII/KEYDOWN or assuming a fixed resulting ERL.
; IX/IY/SP preserved on ordinary return; other registers volatile.
err_trap:
    push ix
    push iy
    ld a,8
    rst.lil 0x08
    ld a,(ix+0x18)
    cp 1
    jr nz,trap_done
    ld a,(ix+5)
    cp 27
    jr nz,trap_done
    pop iy
    pop ix
    ld iy,escape_message
    ld a,17
    jp err_raise
trap_done:
    pop iy
    pop ix
    ret
escape_message: .byte 6
    .ascii "Escape"
