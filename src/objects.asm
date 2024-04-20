;-----------------------------------------------
update_objects:
	ld a,(n_objects)
	; unnecessary check, as all rooms have at least one object
; 	or a
; 	ret z
	ld iy,objects
	ld b,a
update_objects_loop:
	push bc
		ld a,(iy)
		cp OBJECT_TYPE_STOOL
		jr z,update_pushable_furniture
		cp OBJECT_TYPE_CHAIR_RIGHT
		jr z,update_pushable_furniture
		cp OBJECT_TYPE_CHAIR_LEFT
		jr z,update_pushable_furniture
		cp OBJECT_TYPE_CHAIR_NE
		jr z,update_pushable_furniture
		cp OBJECT_TYPE_CHAIR_SW
		jr z,update_pushable_furniture
		cp OBJECT_TYPE_CLOCK_RIGHT
		jp z,update_clock_right
		cp OBJECT_TYPE_TORCH
		jp z,update_torch
		cp OBJECT_TYPE_FIREPLACE
		jp z,update_fireplace
		cp OBJECT_TYPE_COFFIN2
		jp z,update_coffin2
		cp OBJECT_TYPE_HORSE
		jp z,update_objects_horse
		cp OBJECT_TYPE_ARROW_SHOOTER_X
		jp z,update_objects_arrow_shooter_x
		cp OBJECT_TYPE_ARROW_SHOOTER_Y
		jp z,update_objects_arrow_shooter_y
		cp OBJECT_TYPE_SKELETON_BOSS
		jp z,update_objects_skeleton_boss
		cp OBJECT_TYPE_FRANKY
		jp z,update_objects_franky_boss
		cp OBJECT_TYPE_FIRST_ENEMY
		jr c,update_objects_loop_skip
		sub OBJECT_TYPE_FIRST_ENEMY
		jp z,update_enemies_rat
		dec a
		jp z,update_gun_bullet
		dec a
		jp z,update_enemies_spider
		dec a
		jp z,update_enemies_slime
		dec a
		jp z,update_enemies_bat
		dec a
		jp z,update_enemies_snake  ; snake at full health
		dec a
		jp z,update_enemies_snake  ; snake with 1 hit point
		dec a
		jp z,update_enemies_arrow
update_objects_loop_skip:
		ld bc,OBJECT_STRUCT_SIZE
		add iy,bc
	pop bc
	djnz update_objects_loop
	ret


;-----------------------------------------------
update_pushable_furniture:
	; push state:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	and #0f
	jr z,update_pushable_furniture_continue
	dec a
	ld (iy+OBJECT_STRUCT_STATE_TIMER),a
update_pushable_furniture_continue:
	; check if it needs to fall:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Z)
	or a
	jr z,update_objects_loop_skip
	ld de,0
	ld c,-1
	call check_enemy_collision
	jr z,update_objects_loop_skip
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_Z)

	call update_enemy_screen_coordinates

	; redraw:
	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		dec d
		ld bc,#0404
		call render_room_rectangle_safe
	pop iy
	jr update_objects_loop_skip


;-----------------------------------------------
update_clock_right:
	inc (iy + OBJECT_STRUCT_STATE_TIMER)
	ld a, (iy + OBJECT_STRUCT_STATE_TIMER)
	and #1f
	jr nz, update_objects_loop_skip

; 	ld hl, SFX_short_hi_hat
; 	call play_SFX_with_high_priority

	; change animation frame:
	ld l, (iy + OBJECT_STRUCT_PTR)
	ld h, (iy + OBJECT_STRUCT_PTR + 1)

	; - copy current frame to buffer1024
	; - copy reserve frame over old frame
	; - copy from buffer 1024 to reserve frame
	; - redraw
	ld bc, (7*8 + 4)*3
	add hl, bc
	ld de,buffer1024
	ld c,7*3
	push hl
		ldir
	pop hl
	ld d,h
	ld e,l
; 	ld bc, (7*8 + 4)*3
	ld c, (7*8 + 4)*3  ; as b == 0 here already
	add hl,bc
	ld c,7*3
	push hl
		ldir
	pop de
	ld hl,buffer1024
; 	ld bc,7*3
	ld c,7*3  ; as b == 0 here already
	ldir

	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		inc e
		inc d
		inc d
		ld bc,#0201
		call render_room_rectangle
	pop iy

	jp update_objects_loop_skip


;-----------------------------------------------
update_torch:
	inc (iy + OBJECT_STRUCT_STATE_TIMER)
	ld a, (iy + OBJECT_STRUCT_STATE_TIMER)
	and #07
	jp nz, update_objects_loop_skip

	; change animation frame:
	ld l, (iy + OBJECT_STRUCT_PTR)
	ld h, (iy + OBJECT_STRUCT_PTR + 1)

	; Since there are 3 frames, we will be rotating the 3 frames:
	; - copy current frame to buffer1024
	; - copy reserve frame 1 over old frame
	; - copy reserve frame 2 over reserve frame 1
	; - copy from buffer1024 to reserve frame 2
	; - redraw
	; object_ptr  ->  buffer1024:
	ld de,buffer1024
	ld bc,6*3
	push hl
		ldir
	pop hl

	; object_ptr+16*3  ->  object_ptr:
	ld d,h
	ld e,l
; 	ld bc, 16*3
	ld c, 16*3  ; as b == 0 here already
	add hl,bc
	ld c,6*3
	push hl
		ldir
	pop hl

	; object_ptr+(16+6)*3  ->  object_ptr+(16*3):
	ld d,h
	ld e,l
; 	ld bc, 6*3
	ld c, 6*3  ; as b == 0 here already
	add hl,bc
; 	ld c,6*3
	push hl
		ldir
	pop de

	; buffer1024  ->  object_ptr+(16+6)*3:

	ld hl,buffer1024
; 	ld bc,6*3
	ld c,6*3  ; as b == 0 here already
	ldir

	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		ld bc,#0201
		call render_room_rectangle
	pop iy
	jp update_objects_loop_skip


update_fireplace:
	inc (iy + OBJECT_STRUCT_STATE_TIMER)
	ld a, (iy + OBJECT_STRUCT_STATE_TIMER)
	and #07
	jp nz, update_objects_loop_skip

	; change animation frame:
	ld l, (iy + OBJECT_STRUCT_PTR)
	ld h, (iy + OBJECT_STRUCT_PTR + 1)
	ld bc, (12*8+2)*3
	add hl, bc

	; Since there are 3 frames, we will be rotating the 3 frames:
	; - copy current frame to buffer1024
	; - copy reserve frame 1 over old frame
	; - copy reserve frame 2 over reserve frame 1
	; - copy from buffer1024 to reserve frame 2
	; - redraw
	; object_ptr+(12*8+2)*3  ->  buffer1024:
	ld de,buffer1024
	ld bc,8*3
	push hl
		ldir
	pop hl

	; object_ptr+(20*8)*3  ->  object_ptr+(12*8+2)*3:
	ld d,h
	ld e,l
; 	ld bc, 20*8*3 - (12*8+2)*3
	ld c, 20*8*3 - (12*8+2)*3  ; as b == 0 here already
	add hl,bc
	ld c,8*3
	push hl
		ldir
	pop hl

	; object_ptr+(20*8+8)*3  ->  object_ptr+(20*8*3):
	ld d,h
	ld e,l
; 	ld bc, 8*3
	ld c, 8*3  ; as b == 0
	add hl,bc
	push hl
		ldir
	pop de

	; buffer1024  ->  object_ptr+(20*8+8)*3:
	ld hl,buffer1024
; 	ld bc,8*3
	ld c, 8*3  ; as b == 0
	ldir

	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		inc e
		inc e
		inc d
		inc d
		ld bc,#0201
		call render_room_rectangle
	pop iy
	jp update_objects_loop_skip	


update_objects_horse:
	inc (iy + OBJECT_STRUCT_STATE_TIMER)
	ld a, (iy + OBJECT_STRUCT_STATE_TIMER)
	and #3f
	jp nz, update_objects_loop_skip

	; change animation frame:
	ld l, (iy + OBJECT_STRUCT_PTR)
	ld h, (iy + OBJECT_STRUCT_PTR + 1)

	; - copy current frame to buffer1024
	; - copy reserve frame over old frame
	; - copy from buffer 1024 to reserve frame
	; - redraw
	ld bc, (2*7*8)*3
	add hl, bc
	ld d, h
	ld e, l
	ld bc, (3*7*8)*3
	add hl,bc
	ex de,hl  ; hl = current horse head, de = next horse head
	ld b,3
update_objects_horse_loop:
	push bc
		push hl
			push de
				push de
					ld de,buffer1024
					ld bc,24*3
					push hl
						ldir  ; hl: current, de: buffer
					pop de
				pop hl 
				ld bc,24*3
				push hl
					ldir  ; hl: next, de: current
				pop de	
				ld hl,buffer1024
				ld bc,24*3
				ldir  ; de: next, hl: buffer
			pop hl
			ld bc,3*8*3
			add hl,bc
			ex de,hl
		pop hl
		ld bc,7*8*3
		add hl,bc
	pop bc
	djnz update_objects_horse_loop

	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		inc e
		inc e
		ld bc,#0303
		call render_room_rectangle
	pop iy
	jp update_objects_loop_skip	


;-----------------------------------------------
update_coffin2:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	jp m,update_objects_loop_skip  ; vampires are not yet active

	ld a,(state_current_room)
	cp 35
	jr z,update_coffin2_vampire1
	cp 45
	jr z,update_coffin2_vampire2
update_coffin2_vampire3:
; 	ld a,(state_vampire3_state)
; 	cp 2
; 	jp z,update_objects_loop_skip  ; vampire already dead
; 	jr update_coffin2_continue
	jp update_objects_loop_skip  ; Lucy is not on her coffin

update_coffin2_vampire1:
	ld a,(state_vampire1_state)
	cp 2
	jp z,update_objects_loop_skip  ; vampire already dead
	jr update_coffin2_continue

update_coffin2_vampire2:
	ld a,(state_vampire2_state)
	cp 2
	jp z,update_objects_loop_skip  ; vampire already dead

update_coffin2_continue:
	inc (iy + OBJECT_STRUCT_STATE_TIMER)
	ld a, (iy + OBJECT_STRUCT_STATE_TIMER)
	cp 144
	jp nz, update_objects_loop_skip
	ld (iy + OBJECT_STRUCT_STATE_TIMER), 0

	; vampire switch state:
	ld a,(current_room_vampire_state)
	cp 2
	jp z,update_objects_loop_skip  ; vampire has seen player, do not go back to sleep again!
	xor #01
	ld (current_room_vampire_state),a

	; change animation frame:
	ld l, (iy + OBJECT_STRUCT_PTR)
	ld h, (iy + OBJECT_STRUCT_PTR + 1)

	; - copy current frame to buffer1024
	; - copy reserve frame over old frame
	; - copy from buffer 1024 to reserve frame
	; - redraw
	; column 1:
	ld a,(state_current_room)
	cp 42  ; lucy
	jr z,update_coffin2_lucy
	push hl
		ld bc, 4*3
		add hl, bc
		ld de,buffer1024
		ld c,16*3
		push hl
			ldir
		pop hl
		ld d,h
		ld e,l
		ld bc, (28 + 32*2)*3
		add hl,bc
		ld bc,16*3
		push hl
			ldir
		pop de
		ld hl,buffer1024
		ld bc,16*3
		ldir
	pop hl

	; column 2:
	ld bc, (32+4)*3
	add hl, bc
	ld de,buffer1024
	ld c,16*3
	push hl
		ldir
	pop hl
	ld d,h
	ld e,l
	ld bc, (28 + 32*1 + 16)*3
	add hl,bc
	ld bc,16*3
	push hl
		ldir
	pop de
	ld hl,buffer1024
	ld bc,16*3
	ldir

update_coffin2_continue2:
	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		ld bc,#0303
		call render_room_rectangle
	pop iy
	jp update_objects_loop_skip	

update_coffin2_lucy:
	push hl
		ld bc, 4*3
		add hl, bc
		ld de,buffer1024
		ld c,16*3
		push hl
			ldir
		pop hl
		ld d,h
		ld e,l
		ld bc, (28 + 32*2 + 16*2)*3
		add hl,bc
		ld bc,16*3
		push hl
			ldir
		pop de
		ld hl,buffer1024
		ld bc,16*3
		ldir
	pop hl

	; column 2:
	ld bc, (32+4)*3
	add hl, bc
	ld de,buffer1024
	ld c,16*3
	push hl
		ldir
	pop hl
	ld d,h
	ld e,l
	ld bc, (28 + 32 + 16*3)*3
	add hl,bc
	ld bc,16*3
	push hl
		ldir
	pop de
	ld hl,buffer1024
	ld bc,16*3
	ldir	
	jr update_coffin2_continue2


;-----------------------------------------------
update_gun_bullet:
	; move the bullet until collision:
	ld a,(iy+OBJECT_STRUCT_STATE)
	or a
	jr z,update_gun_bullet_n
	dec a
	jr z,update_gun_bullet_ne
	dec a
	jr z,update_gun_bullet_e
	dec a
	jr z,update_gun_bullet_se
	dec a
	jr z,update_gun_bullet_s
	dec a
	jr z,update_gun_bullet_sw
	dec a
	jr z,update_gun_bullet_w
update_gun_bullet_nw:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,-6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	jr update_gun_bullet_continue

update_gun_bullet_n:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,-4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,-4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	jr update_gun_bullet_continue

update_gun_bullet_ne:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,-6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	jr update_gun_bullet_continue

update_gun_bullet_e:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,-4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	jr update_gun_bullet_continue

update_gun_bullet_se:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	jr update_gun_bullet_continue

update_gun_bullet_s:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	jr update_gun_bullet_continue

update_gun_bullet_sw:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	jr update_gun_bullet_continue

update_gun_bullet_w:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,-4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,4
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a

update_gun_bullet_continue:
	; check if the bullet left the room:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	cp 8
	jr c,update_objects_destroy_object
	ld hl,room_width_pixels
	add a,8
	cp (hl)
	jr nc,update_objects_destroy_object
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	cp 8
	jr c,update_objects_destroy_object
	ld hl,room_height_pixels
	add a,8
	cp (hl)
	jr nc,update_objects_destroy_object


	ld de,0
	ld c,e
	call check_enemy_collision
	jp nz,update_enemies_redraw

	ld a,(ix)
	cp OBJECT_TYPE_SKELETON_BOSS
	jr z,update_gun_bullet_boss_hit
	cp OBJECT_TYPE_FRANKY
	jr z,update_gun_bullet_boss_hit
	cp OBJECT_TYPE_FIRST_ENEMY
	jr c,update_objects_destroy_object

	; we just hit an enemy!
	ld a,(ix+OBJECT_STRUCT_TYPE)
	cp OBJECT_TYPE_SNAKE
	jr nz,update_gun_bullet_enemy_kill
	inc (ix+OBJECT_STRUCT_TYPE)
	ld hl,SFX_enemy_hit
	call play_SFX_with_high_priority
	jr update_objects_destroy_object

update_gun_bullet_boss_hit:
	ld a,1
	ld (miniboss_hit),a
	jr update_objects_destroy_object

update_gun_bullet_enemy_kill:
	ld a,(ix+OBJECT_STRUCT_STATE)
	or #80  ; we mark it as hit!
	ld (ix+OBJECT_STRUCT_STATE),a
	ld (ix+OBJECT_STRUCT_STATE_TIMER),0

	ld hl,SFX_enemy_death
	call play_SFX_with_high_priority

update_objects_destroy_object:
	; collision:
	push iy
	pop ix
	push iy
		call remove_room_object
	pop iy
	ld de,-OBJECT_STRUCT_SIZE  ; since we are deleting the object, decrement iy, so the update loop can continue
	add iy,de
	jp update_objects_loop_skip


;-----------------------------------------------
update_objects_arrow_shooter_x:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	or a
	jr nz,update_objects_arrow_shooter_wait
update_objects_arrow_shooter_x_spawn_arrow:
	ld a,(player_iso_y)
	add a,12
	cp (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	jp c,update_objects_loop_skip
	add a,-24
	cp (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	jp nc,update_objects_loop_skip

	ld (iy+OBJECT_STRUCT_STATE_TIMER),128

	ld hl,SFX_arrow
	call play_SFX_with_high_priority

	ld a,(n_objects)
	cp MAX_ROOM_OBJECTS
	jp z,update_objects_loop_skip
	push iy
		call find_new_object_ptr
		ld (ix),OBJECT_TYPE_ARROW
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
		add a,8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_W),8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_H),8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z_H),8
		ld (ix+OBJECT_STRUCT_SCREEN_TILE_W),3
		ld (ix+OBJECT_STRUCT_SCREEN_TILE_H),2
		ld (ix+OBJECT_STRUCT_FRAME),2  ; move in the x axis
		ld (ix+OBJECT_STRUCT_PTR),enemy_data_buffer%256
		ld (ix+OBJECT_STRUCT_PTR+1),enemy_data_buffer/256
		ld (ix+OBJECT_STRUCT_STATE_TIMER),0
		push ix
		pop iy
		call update_enemy_screen_coordinates
	pop iy
	jp update_objects_loop_skip

update_objects_arrow_shooter_wait:
	dec (iy+OBJECT_STRUCT_STATE_TIMER)
	jp update_objects_loop_skip	



;-----------------------------------------------
update_objects_arrow_shooter_y:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	or a
	jr nz,update_objects_arrow_shooter_wait
update_objects_arrow_shooter_y_spawn_arrow:
	ld a,(player_iso_x)
	add a,12
	cp (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jp c,update_objects_loop_skip
	add a,-24
	cp (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jp nc,update_objects_loop_skip

	ld (iy+OBJECT_STRUCT_STATE_TIMER),128

	ld hl,SFX_arrow
	call play_SFX_with_high_priority

	ld a,(n_objects)
	cp MAX_ROOM_OBJECTS
	jp z,update_objects_loop_skip
	push iy
		call find_new_object_ptr
		ld (ix),OBJECT_TYPE_ARROW
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
		add a,8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_W),8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_H),8
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z_H),8
		ld (ix+OBJECT_STRUCT_SCREEN_TILE_W),3
		ld (ix+OBJECT_STRUCT_SCREEN_TILE_H),2
		ld (ix+OBJECT_STRUCT_FRAME),4  ; move in the x axis
		ld (ix+OBJECT_STRUCT_PTR),enemy_data_buffer%256
		ld (ix+OBJECT_STRUCT_PTR+1),enemy_data_buffer/256
		ld (ix+OBJECT_STRUCT_STATE_TIMER),0
		push ix
		pop iy
		call update_enemy_screen_coordinates
	pop iy
	jp update_objects_loop_skip


;-----------------------------------------------
; Calls "update_object_drawing_order" a few times,
; Useful to minimize flicker when objects are pushed, or dropped
update_object_drawing_order_n_times:
; 	ld a,(n_objects)
; 	or a
; 	ret z
; 	dec a
; 	ret z	
	ld b,16
update_object_drawing_order_n_times_loop:
	push bc
		; forward pass:
		call update_object_drawing_order
	pop bc
	ld a,(update_object_drawing_order_any_change)
	or a
	ret z  ; if nothing was updated, just return
	push bc
		; backward pass: (ix and iy already have the right values)
		ld de,-OBJECT_STRUCT_SIZE
		add ix,de
		add iy,de
		call update_object_drawing_order_entry_point
	pop bc
	ld a,(update_object_drawing_order_any_change)
	or a
	ret z  ; if nothing was updated, just return
	djnz update_object_drawing_order_n_times_loop
	ret


;-----------------------------------------------
; return:
; - update_object_drawing_order_any_change: 0 if no change, 1 if change
update_object_drawing_order:
	ld ix,objects
	ld iy,objects + OBJECT_STRUCT_SIZE
	ld de,OBJECT_STRUCT_SIZE
update_object_drawing_order_entry_point:
	ld hl,update_object_drawing_order_any_change
	ld (hl),0
	ld a,(n_objects)
	or a
	ret z
	dec a
	ret z
	ld b,a
update_object_drawing_order_loop:
	; compare to see if we need to flip ix and iy:
	; currently, ix is drawn before iy

	; sort first by X, otherwise by Y, and otherwise by top Z:
	; X:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ld c,a
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_W)
	ld l,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	dec a
	cp l  ; if IY.(X+W) <= IX.X -> flip
	jr c,update_object_drawing_order_flip
; 	jr z,update_object_drawing_order_flip

	ld a,l
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_W)
	dec a
	cp c
	jr c,update_object_drawing_order_skip
; 	jr z,update_object_drawing_order_skip

	; Y:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld c,a
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_H)
	ld l,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)  ; if IY.(Y+H) <= IX.Y -> flip
	dec a
	cp l
	jr c,update_object_drawing_order_flip
; 	jr z,update_object_drawing_order_flip

	ld a,l
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_H)
	dec a
	cp c
	jr c,update_object_drawing_order_skip
; 	jr z,update_object_drawing_order_skip

	; Z:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Z)
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_Z_H)
	dec a
	cp (ix+OBJECT_STRUCT_PIXEL_ISO_Z)  ; if IY.(Z+Z_H) <= IX.Z -> flip
	jp m,update_object_drawing_order_flip
; 	jr z,update_object_drawing_order_flip


update_object_drawing_order_skip:
	add ix,de
	add iy,de
	djnz update_object_drawing_order_loop
	ret


update_object_drawing_order_flip:
	exx  ; to save de and bc
		; ix -> buffer
		push ix
		pop hl
		push iy
		pop de
		ld b,OBJECT_STRUCT_SIZE
update_object_drawing_order_flip_loop:
 		ld c,(hl)
 		ld a,(de)
 		ld (hl),a
 		ld a,c
 		ld (de),a
 		inc hl
 		inc de
 		djnz update_object_drawing_order_flip_loop

; 		push ix
; 		pop hl
; 		ld de,buffer1024
; 		ld bc,OBJECT_STRUCT_SIZE
; 		ldir
; 		; iy -> ix
; 		push iy
; 		pop hl
; 		push ix
; 		pop de
; 		ld bc,OBJECT_STRUCT_SIZE
; 		ldir
; 		; buffer -> iy:
; 		ld hl,buffer1024
; 		push iy
; 		pop de
; 		ld bc,OBJECT_STRUCT_SIZE
; 		ldir
	exx
	ld hl,update_object_drawing_order_any_change
	inc (hl)  ; hl already has 'update_object_drawing_order_any_change'
	jr update_object_drawing_order_skip

	; We do not redraw, as the only objects that this can affect are pushable objects/enemies,
	; which already redraw on their own:
; 	; redraw the object that was moved to closer (iy):
; 	ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
; 	ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
; 	ld c,(iy+OBJECT_STRUCT_SCREEN_TILE_W)
; 	ld b,(iy+OBJECT_STRUCT_SCREEN_TILE_H)

; 	; make sure we don't draw outside of the room space in the y axis:
; 	ld a,d
; 	cp SCREEN_HEIGHT
; 	ret p
; 	jp render_room_rectangle


;-----------------------------------------------
; input:
; - ix: object to delete
remove_room_object:
	ld (ix),0  ; clear the object

	ld e,(ix+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(ix+OBJECT_STRUCT_SCREEN_TILE_Y)
	ld c,(ix+OBJECT_STRUCT_SCREEN_TILE_W)
	ld b,(ix+OBJECT_STRUCT_SCREEN_TILE_H)
	inc b
	push ix
		call render_room_rectangle_safe
	pop ix

remove_room_object_no_redraw:
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
find_new_object_ptr:
	ld hl,n_objects
	ld b,(hl)
	inc (hl)  ; we increase the number of objects in the room by one
	ld de,OBJECT_STRUCT_SIZE
	ld ix,objects
find_new_object_ptr_loop:
	add ix,de
	djnz find_new_object_ptr_loop
	ret


;-----------------------------------------------
; input: 
; - a: object ID to find
; returns:
; - z: found (and pointer in ix)
; - nz: not found
find_closeby_room_object:
	ld de,OBJECT_STRUCT_SIZE
	ld ix,objects
	push hl
		ld hl,n_objects
		ld b,(hl)
	pop hl
find_closeby_room_object_loop:
	cp (ix)
	jr z,find_closeby_room_object_loop_found
find_closeby_room_object_loop_next:
	add ix,de
	djnz find_closeby_room_object_loop
	or 1  ; nz: not found
	ret
find_closeby_room_object_loop_found:
	call check_if_object_close_by
	jr nz,find_closeby_room_object_loop_next
	ret  ; z: found


;-----------------------------------------------
; input: 
; - a: object ID to find
; returns:
; - z: found (and pointer in ix)
; - nz: not found
find_room_object:
	ld de,OBJECT_STRUCT_SIZE
	ld ix,objects
	push hl
		ld hl,n_objects
		ld b,(hl)
	pop hl
find_room_object_loop:
	cp (ix)
	ret z
find_room_object_loop_next:
	add ix,de
	djnz find_room_object_loop
	or 1  ; nz: not found
	ret
