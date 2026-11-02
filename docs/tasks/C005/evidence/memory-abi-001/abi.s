; C005 allocator/array helper probe; independent from the BBC compiler.
    .assume adl=1
    .text
    .global entry
    .extern mem_alloc,array_dim,array_addr,dim_step,array_prefix
    .macro stage number
    ld a,\number
    ld (current_stage),a
    .endm
    .macro equal value
    ld de,\value
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro preserved x,y
    push ix
    pop hl
    equal \x
    push iy
    pop hl
    equal \y
    ld hl,0
    add hl,sp
    ld de,(saved_sp)
    or a
    sbc hl,de
    jp nz,failed
    .endm
    .macro success
    jp c,failed
    jp nz,failed
    or a
    jp nz,failed
    .endm
    .macro expect_error number
    jp nc,failed
    cp \number
    jp nz,failed
    .endm
    .macro reset_array
    ld hl,0
    ld (cell),hl
    ld hl,buffer
    ld (context),hl
    ld hl,buffer+50
    ld (context+3),hl
    ld hl,buffer
    ld de,buffer+1
    ld bc,49
    ld (hl),0xa5
    ldir
    .endm
    .macro dimension width,count,bounds
    ld ix,cell
    ld iy,\bounds
    ld hl,context
    ld bc,0xabcdef
    ld b,\width
    ld a,\count
    call array_dim
    .endm
    .macro address width,count,indices
    ld ix,cell
    ld iy,\indices
    ld bc,0xabcdef
    ld b,\width
    ld a,\count
    call array_addr
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
    ld iy,0xabcdef
    ld hl,0
    ld bc,0xabcdef
    call mem_alloc
    success
    push hl
    push de
    pop hl
    equal buffer
    pop hl
    equal buffer
    ld hl,(context)
    equal buffer
    ld a,(buffer)
    cp 0xa5
    jp nz,failed
    preserved context,0xabcdef
    stage 2
    ld hl,65537
    ld bc,0xabcdef
    call mem_alloc
    success
    push hl
    push de
    pop hl
    equal buffer
    pop hl
    equal buffer+65537
    ld hl,(context)
    equal buffer+65537
    ld hl,buffer
    ld bc,65537
check_zero:
    ld a,(hl)
    or a
    jp nz,failed
    inc hl
    dec bc
    push hl
    ld hl,0
    or a
    sbc hl,bc
    pop hl
    jr nz,check_zero
    ld a,(before_buffer)
    cp 0xa5
    jp nz,failed
    ld a,(after_buffer)
    cp 0xa5
    jp nz,failed
    preserved context,0xabcdef
    stage 3
    ld hl,1
    call mem_alloc
    expect_error 11
    ld hl,(context)
    equal buffer+65537
    preserved context,0xabcdef
    stage 4
    ld ix,overflow_context
    ld hl,32
    call mem_alloc
    expect_error 11
    ld hl,(overflow_context)
    equal 0xfffff0
    preserved overflow_context,0xabcdef
    stage 5
    reset_array
    dimension 5,2,bounds
    success
    ld hl,(cell)
    equal buffer
    ld hl,(context)
    equal buffer+37
    ld a,(buffer)
    cp 2
    jp nz,failed
    ld hl,(buffer+1)
    equal 2
    ld hl,(buffer+4)
    equal 3
    ld a,(buffer+7)
    or a
    jp nz,failed
    ld a,(buffer+36)
    or a
    jp nz,failed
    ld a,(buffer+37)
    cp 0xa5
    jp nz,failed
    preserved cell,bounds
    stage 6
    address 5,2,indices
    success
    equal buffer+32
    preserved cell,indices
    stage 7
    address 5,2,high_indices
    expect_error 15
    preserved cell,high_indices
    stage 8
    address 5,2,negative_indices
    expect_error 15
    address 5,2,wide_indices
    expect_error 15
    preserved cell,wide_indices
    stage 9
    address 5,1,indices
    expect_error 5
    address 5,3,indices
    expect_error 27
    preserved cell,indices
    stage 10
    dimension 5,2,bounds
    expect_error 10
    ld hl,(context)
    equal buffer+37
    ld hl,(cell)
    equal buffer
    preserved cell,bounds
    stage 11
    reset_array
    address 1,2,indices
    expect_error 14
    ld hl,1
    ld (cell),hl
    address 1,2,indices
    expect_error 14
    preserved cell,indices
    stage 12
    reset_array
    dimension 1,2,negative_indices
    expect_error 10
    ld hl,(context)
    equal buffer
    ld hl,(cell)
    equal 0
    preserved cell,negative_indices
    stage 13
    dimension 1,2,overflow_bounds
    expect_error 11
    dimension 1,2,product_bounds
    expect_error 11
    dimension 5,2,bounds_too_large
    expect_error 11
    ld hl,(context)
    equal buffer
    ld hl,(cell)
    equal 0
    preserved cell,bounds_too_large
    stage 14
    reset_array
    dimension 4,2,bounds
    success
    address 4,2,indices
    success
    equal buffer+27
    preserved cell,indices
    stage 15
    reset_array
    dimension 1,2,bounds
    success
    address 1,2,indices
    success
    equal buffer+12
    preserved cell,indices
    stage 16
    reset_array
    dimension 1,16,zero_indices
    success
    ld hl,(context)
    equal buffer+50
    address 1,16,zero_indices
    success
    equal buffer+49
    preserved cell,zero_indices
    stage 17
    reset_array
    dimension 1,0,zero_indices
    expect_error 10
    dimension 1,17,zero_indices
    expect_error 10
    ld hl,(cell)
    equal 0
    preserved cell,zero_indices
    stage 18
    reset_array
    dimension 5,2,bounds
    success
    ld ix,cell
    ld iy,0
    ld bc,0xabcdef
    xor a
    call array_prefix
    success
    preserved cell,0
    ld ix,cell
    ld iy,high_indices
    ld a,1
    call array_prefix
    success
    preserved cell,high_indices
    ld a,2
    call array_prefix
    expect_error 15
    preserved cell,high_indices
    ld iy,negative_indices
    ld a,1
    call array_prefix
    expect_error 15
    preserved cell,negative_indices
    ld iy,0
    ld a,3
    call array_prefix
    expect_error 27
    preserved cell,0
    stage 19
    ld ix,running_product
    ld iy,bounds
    ld bc,0xabcdef
    call dim_step
    success
    ld hl,(running_product)
    equal 2
    preserved running_product,bounds
    ld iy,bounds+5
    call dim_step
    success
    ld hl,(running_product)
    equal 6
    preserved running_product,bounds+5
    ld iy,negative_indices
    call dim_step
    expect_error 10
    ld hl,(running_product)
    equal 6
    preserved running_product,negative_indices
    ld iy,product_bounds
    call dim_step
    expect_error 11
    ld hl,(running_product)
    equal 6
    preserved running_product,product_bounds
    ld iy,overflow_bounds
    call dim_step
    expect_error 11
    ld iy,wide_indices
    call dim_step
    expect_error 10
    ld hl,(running_product)
    equal 6
    ld a,(running_product+3)
    or a
    jp nz,failed
    ld a,(running_product+4)
    or a
    jp nz,failed
    preserved running_product,wide_indices
    ld hl,0
    jr finish
failed:
    ld hl,0
    ld a,(current_stage)
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
current_stage: .byte 1
context: .d24 buffer,buffer+65537
overflow_context: .d24 0xfffff0,0xffffff
cell: .d24 0
running_product: .byte 1,0,0,0,0
bounds: .byte 1,0,0,0,0,2,0,0,0,0
indices: .byte 1,0,0,0,0,2,0,0,0,0
high_indices: .byte 1,0,0,0,0,3,0,0,0,0
negative_indices: .byte 255,255,255,255,0,0,0,0,0,0
wide_indices: .byte 0,0,0,1,0,0,0,0,0,0
overflow_bounds: .byte 255,255,255,0,0,0,0,0,0,0
product_bounds: .byte 254,255,255,0,0,1,0,0,0,0
bounds_too_large: .byte 10,0,0,0,0,10,0,0,0,0
zero_indices: .space 80,0
    .balign 256
    .space 249
before_buffer: .byte 0xa5
buffer: .fill 65537,1,0xa5
after_buffer: .byte 0xa5
