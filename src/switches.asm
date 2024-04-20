;-----------------------------------------------
; input:
; - ix: ptr to the switch object struct
get_switch_mask:
	ld a,(state_current_room)
	cp 90
	jr z,get_switch_mask_1
	ld a,(state_current_room)
	cp 91
	jr z,get_switch_mask_2
	; cp 92
	; room 92:

get_switch_mask_4:
	ld c, 0x04  ; switch mask: it's in mini boss and opens prison entrance
	ret
get_switch_mask_2:
	ld c, 0x02  ; switch mask: it's in prison2 and opens prison2
	ret
get_switch_mask_1:
	ld c, 0x01  ; switch mask: it's in prison1, and opens prison1
	ret


;-----------------------------------------------
; input:
; - ix: ptr to the switch object struct
switch_flip_gfx_state:
	ld l, (ix + OBJECT_STRUCT_PTR)
	ld h, (ix + OBJECT_STRUCT_PTR + 1)
	; - copy current frame to buffer1024
	; - copy reserve frame over old frame
	; - copy from buffer 1024 to reserve frame
	; - redraw
	ld de,buffer1024
	ld bc, 32*3
	push hl
		ldir
	pop hl
	ld d,h
	ld e,l
	ld bc, 4*8*3
	add hl,bc
	push hl
		ldir
	pop de
	ld hl,buffer1024
	ld bc,32*3
	ldir
	push ix
		ld e,(ix + OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(ix + OBJECT_STRUCT_SCREEN_TILE_Y)
		ld bc,#0202
		call render_room_rectangle
	pop ix
	ret


;-----------------------------------------------
; input:
; - e: y coordinate of the grids to remove
switch_remove_room_grids:
	ld a,(n_objects)
	ld ix,objects
	ld b,a
switch_remove_room_grids_loop:
	push bc
		ld a,(ix)
		cp OBJECT_TYPE_GRID2
		jr nz,switch_remove_room_grids_skip
		ld a,(ix + OBJECT_STRUCT_PIXEL_ISO_Y)
		cp e
		jr nz,switch_remove_room_grids_skip
		; remove object:
		push de
			call remove_room_grid
		pop de
		; restore stack, and try again just in case there's another:
	pop bc
	jr switch_remove_room_grids

switch_remove_room_grids_skip:
		ld bc,OBJECT_STRUCT_SIZE
		add ix,bc
	pop bc
	djnz switch_remove_room_grids_loop
	xor a  ; to reset "z", indicating we need to redraw the room
	ret


	; Note: this is a duplicate of some code that is in page 2, but we replicate
	; it here for convenience.
remove_room_grid:
	ld (ix),0  ; clear the object
	; shift objects to the left:
	ld hl,objects+MAX_ROOM_OBJECTS*OBJECT_STRUCT_SIZE
	push ix
	pop bc
	or a
	sbc hl,bc
	ld b,h
	ld c,l  ; bc has the amount of bytes to copy
	push ix
	pop hl
	ld de,OBJECT_STRUCT_SIZE
	push hl
		add hl,de
	pop de
	ldir
	ld hl,n_objects
	dec (hl)
	ret


;-----------------------------------------------
; input:
; - e, d: x, y position of the grid
switch_effect_add_grid_if_not_present:
	ld a,(n_objects)
	ld ix,objects
	ld b,a
switch_effect_add_grid_if_not_present_loop:
	push bc
		ld a,(ix + OBJECT_STRUCT_PIXEL_ISO_Y)
		cp d
		jr nz,switch_effect_add_grid_if_not_present_skip
		ld a,(ix + OBJECT_STRUCT_PIXEL_ISO_X)
		cp e
		jr nz,switch_effect_add_grid_if_not_present_skip
	pop bc
	or 1  ; mark nz, for not redrawing
	ret
switch_effect_add_grid_if_not_present_skip:
		ld bc,OBJECT_STRUCT_SIZE
		add ix,bc
	pop bc
	djnz switch_effect_add_grid_if_not_present_loop
	; add new grid object:
	push de
		ld hl,n_objects
		ld b,(hl)
		inc (hl)  ; we increase the number of objects in the room by one
		ld de,OBJECT_STRUCT_SIZE
		ld ix,objects
switch_effect_add_grid_if_not_present_find_ptr_loop:
		add ix,de
		djnz switch_effect_add_grid_if_not_present_find_ptr_loop
	pop de
	ld (ix),OBJECT_TYPE_GRID2
	srl e
	srl e
	srl e
	srl d
	srl d
	srl d
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),e
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),d
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),0
	ld de,object_grid2_zx0
	SETMEGAROMPAGE_A000 OBJECTS_PAGE2
	call load_room_init_object_ptr_set
	xor a  ; indicate that we need to redraw
	ret


;-----------------------------------------------
switch_effect_on_room_page3:
	ld a,(state_current_room)
	cp 89  ; prison entrance
	jr z,switch_effect_on_room_prison_entrance
	cp 90  ; prison1
	jr z,switch_effect_on_room_prison1
	cp 91  ; prison2
	jr z,switch_effect_on_room_prison2
	ret

switch_effect_on_room_prison_entrance:  ; switch #04
	ld a,(state_switches)
	bit 2,a
	jr z,switch_effect_on_room_prison_entrance_add_grid
	; open grids:
	ld e,9*8
	jp switch_remove_room_grids
switch_effect_on_room_prison_entrance_add_grid:
	; grid2 14 9 0
	; grid2 16 9 0
	ld de, 14*8 + 9*8*256
	call switch_effect_add_grid_if_not_present
	ld de, 16*8 + 9*8*256
	jp switch_effect_add_grid_if_not_present


switch_effect_on_room_prison1:  ; switches #01
	ld a,(state_switches)
	bit 0,a
	jr z,switch_effect_on_room_prison1_add_grid1
	; open grids:
	ld e,7*8
	jp switch_remove_room_grids

switch_effect_on_room_prison1_add_grid1:
	; grid2 2 7 0
	; grid2 4 7 0
	ld de, 2*8 + 7*8*256
	call switch_effect_add_grid_if_not_present
	ld de, 4*8 + 7*8*256
	jp switch_effect_add_grid_if_not_present


switch_effect_on_room_prison2:  ; switch #02
	ld a,(state_switches)
	bit 1,a
	jr z,switch_effect_on_room_prison2_add_grid
	; open grids:
	ld e,12*8
	jp switch_remove_room_grids
switch_effect_on_room_prison2_add_grid:
	; grid2 2 12 0
	; grid2 4 12 0
	ld de, 2*8 + 12*8*256
	call switch_effect_add_grid_if_not_present
	ld de, 4*8 + 12*8*256
	jp switch_effect_add_grid_if_not_present
