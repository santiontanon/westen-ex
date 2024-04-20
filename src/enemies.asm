;-----------------------------------------------
init_object_screen_coordinates:
	ld a,(n_objects)
	or a
	ret z
	ld iy,objects
	ld b,a
init_object_screen_coordinates_loop:
	push bc
		ld a,(iy)
		cp OBJECT_TYPE_FIRST_ENEMY
		jr c,init_object_screen_coordinates_loop_skip
		call update_enemy_screen_coordinates
init_object_screen_coordinates_loop_skip:
		ld bc,OBJECT_STRUCT_SIZE
		add iy,bc
	pop bc
	djnz init_object_screen_coordinates_loop
	ret	


update_enemy_screen_coordinates:
	; screen_x = room_x + (x*2 - y*2)/16 - 1
	ld a,(room_x)
	add a,a
	add a,a
	add a,a
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	sub 8
	ld (iy+OBJECT_STRUCT_SCREEN_PIXEL_X),a
	rrca
	rrca
	rrca
	and #1f
	ld (iy+OBJECT_STRUCT_SCREEN_TILE_X),a

	ld a,(iy)
	cp OBJECT_TYPE_STOOL
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_CHAIR_RIGHT
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_CHAIR_LEFT
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_CHAIR_NE
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_CHAIR_SW
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_BULLET
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_TALL_STOOL
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_ALTAR
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_SKELETON_BOSS
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_SKELETON_KEY
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_FRANKY
	jr z,update_enemy_screen_coordinates_skip_ptr_update
	cp OBJECT_TYPE_FRANKY_NOTE
	jr z,update_enemy_screen_coordinates_skip_ptr_update

	ld a,(iy+OBJECT_STRUCT_SCREEN_PIXEL_X)
	and #06
	ld d,a
	ld a,(iy+OBJECT_STRUCT_FRAME)
	; += (a * 4 + d/2) * 16 * 3 * 2  ->  += (8*a + d) * 16 * 3
	add a,a
	add a,a
	add a,a
	add a,d
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld b,h
	ld c,l	
	ld hl,enemy_data_buffer
	add hl,bc
	add hl,bc
	add hl,bc  ; hl = pointer of the sprite to draw
	ld (iy+OBJECT_STRUCT_PTR),l
	ld (iy+OBJECT_STRUCT_PTR+1),h
update_enemy_screen_coordinates_skip_ptr_update:

	; screen_y = room_y + (x + y)/16 - z/8 - 1
	ld a,(room_y)
	add a,a
	add a,a
	add a,a
	ld c,a
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jr nc,update_enemy_screen_coordinates_ncy
	srl a
	or #80
	jr update_enemy_screen_coordinates_continuey
update_enemy_screen_coordinates_ncy:
	srl a
update_enemy_screen_coordinates_continuey:
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Z)
	add c
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H)
	ld (iy+OBJECT_STRUCT_SCREEN_PIXEL_Y),a
	rrca
	rrca
	rrca
	and #1f
	cp SCREEN_HEIGHT
	jr c,update_enemy_screen_coordinates_no_y_overflow
	add a,-32
update_enemy_screen_coordinates_no_y_overflow:
	ld (iy+OBJECT_STRUCT_SCREEN_TILE_Y),a
	ret


;-----------------------------------------------
update_enemies_rat:
	bit 7,(iy+OBJECT_STRUCT_STATE)
	jp nz,update_enemies_hit

	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	and #03
	jp nz,update_objects_loop_skip
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	rrca
	rrca
	rrca
	and #01
	add a,(iy+OBJECT_STRUCT_STATE)
	add a,(iy+OBJECT_STRUCT_STATE)
	ld (iy+OBJECT_STRUCT_FRAME),a

	ld a,(iy+OBJECT_STRUCT_STATE)
	or a
	jr z,update_enemies_rat_ne
	dec a
	jr z,update_enemies_rat_se
	dec a
	jr z,update_enemies_rat_sw
update_enemies_rat_nw:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	or a
	jr z,update_enemies_rat_ne_collision
	ld de,#00fe
	ld c,d
	call check_enemy_collision
	jr z,update_enemies_rat_nw_collision
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jp update_enemies_redraw
update_enemies_rat_nw_collision:
	ld (iy+OBJECT_STRUCT_STATE),1
	jp update_enemies_redraw


update_enemies_rat_ne:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	or a
	jr z,update_enemies_rat_ne_collision
	ld de,#fe00
	ld c,e
	call check_enemy_collision
	jr z,update_enemies_rat_ne_collision
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	jp update_enemies_redraw


update_enemies_rat_ne_collision:
	ld (iy+OBJECT_STRUCT_STATE),2
	jp update_enemies_redraw


update_enemies_rat_sw:
	ld de,#0200
	ld c,e
	call check_enemy_collision
	jr z,update_enemies_rat_sw_collision
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	jp update_enemies_redraw
update_enemies_rat_sw_collision:
	ld (iy+OBJECT_STRUCT_STATE),0
	jp update_enemies_redraw


update_enemies_rat_se:
	ld de,#0002
	ld c,d
	call check_enemy_collision
	jr z,update_enemies_rat_se_collision
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jp update_enemies_redraw
update_enemies_rat_se_collision:
	ld (iy+OBJECT_STRUCT_STATE),3
	jp update_enemies_redraw



;-----------------------------------------------
update_enemies_spider:
	bit 7,(iy+OBJECT_STRUCT_STATE)
	jp nz,update_enemies_hit

	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	and #01
	jp nz,update_objects_loop_skip

	ld a,(iy+OBJECT_STRUCT_STATE)
	or a
	jr z,update_enemies_spider_waiting
	dec a
	jr z,update_enemies_spider_attack
update_enemies_spider_rest:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jp nz,update_objects_loop_skip
	ld (iy+OBJECT_STRUCT_STATE),0
	jp update_objects_loop_skip


update_enemies_spider_waiting:
	; Check the player position:
	ld a,(player_iso_x)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	cp 48
	jp p,update_objects_loop_skip
	cp -48
	jp m,update_objects_loop_skip
	ld a,(player_iso_y)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	cp 48
	jp p,update_objects_loop_skip
	cp -48
	jp m,update_objects_loop_skip

	; player near! attack!
	ld (iy+OBJECT_STRUCT_STATE),1
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	; keep the lowest bit, which determines whether the spider is updated in odd or even frames:
	and #01
	ld (iy+OBJECT_STRUCT_STATE_TIMER),a
	jp update_objects_loop_skip


update_enemies_spider_attack:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	cp 40
	jr nz,update_enemies_spider_attack_not_done
	ld (iy+OBJECT_STRUCT_STATE),2
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	; keep the lowest bit, which determines whether the spider is updated in odd or even frames:
	and #01
	ld (iy+OBJECT_STRUCT_STATE_TIMER),a
	jp update_enemies_redraw

update_enemies_spider_attack_not_done:
	ld a,(player_iso_x)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jr z,update_enemies_spider_attack_x_done
	jp p,update_enemies_spider_attack_x_positive
update_enemies_spider_attack_x_negative:
	call update_enemy_dec_x
	ld c,6
	jr update_enemies_spider_attack_x_movement_continue
; 	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
; 	srl a
; 	and #01
; 	add a,c
; 	ld (iy+OBJECT_STRUCT_FRAME),a
; 	jr update_enemies_spider_attack_x_done

update_enemies_spider_attack_x_positive:
	call update_enemy_inc_x
	ld c,2
update_enemies_spider_attack_x_movement_continue:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	srl a
	and #01
	add a,c
	ld (iy+OBJECT_STRUCT_FRAME),a

update_enemies_spider_attack_x_done:
	ld a,(player_iso_y)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	jr z,update_enemies_spider_attack_y_done
	jp p,update_enemies_spider_attack_y_positive
update_enemies_spider_attack_y_negative:
	call update_enemy_dec_y
	ld c,0
	jr update_enemies_spider_attack_y_movement_continue
; 	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
; 	srl a
; 	and #01
; 	ld (iy+OBJECT_STRUCT_FRAME),a
; 	jr update_enemies_spider_attack_y_done

update_enemies_spider_attack_y_positive:
	call update_enemy_inc_y
	ld c,4
update_enemies_spider_attack_y_movement_continue:	
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	srl a
	and #01
	add a,c
	ld (iy+OBJECT_STRUCT_FRAME),a
update_enemies_spider_attack_y_done:
	jp update_enemies_redraw


;-----------------------------------------------
update_enemies_slime:
	bit 7,(iy+OBJECT_STRUCT_STATE)
	jp nz,update_enemies_hit

	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	and #03
	jp nz,update_objects_loop_skip

	; follow player:
	ld a,(player_iso_x)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jr z,update_enemies_slime_attack_x_done
	jp p,update_enemies_slime_attack_x_positive
update_enemies_slime_attack_x_negative:
	call update_enemy_dec_x
	jr update_enemies_slime_attack_x_done
update_enemies_slime_attack_x_positive:
	call update_enemy_inc_x
update_enemies_slime_attack_x_done:

	ld a,(player_iso_y)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	jr z,update_enemies_slime_attack_y_done
	jp p,update_enemies_slime_attack_y_positive
update_enemies_slime_attack_y_negative:
	call update_enemy_dec_y
	jr update_enemies_slime_attack_y_done
update_enemies_slime_attack_y_positive:
	call update_enemy_inc_y
update_enemies_slime_attack_y_done:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	srl a
	srl a
	and #01
	ld (iy+OBJECT_STRUCT_FRAME),a
	jp update_enemies_redraw


;-----------------------------------------------
update_enemies_bat:
	; bats cannot be killed:
; 	bit 7,(iy+OBJECT_STRUCT_STATE)
; 	jp nz,update_enemies_hit

	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	and #01
	jp nz,update_objects_loop_skip

	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Z)
	cp 12
	jp z,update_enemies_spider_attack_not_done

	ld de,#0000
	ld c,1
	call check_enemy_collision
	jp z,update_enemies_spider_attack_not_done
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_Z)
	jp update_enemies_spider_attack_not_done


;-----------------------------------------------
; state: 0, waiting
; state: 1, dashing
update_enemies_snake:
	bit 7,(iy+OBJECT_STRUCT_STATE)
	jp nz,update_enemies_hit

	ld a,(iy+OBJECT_STRUCT_STATE)
	or a
	jr z,update_enemies_snake_wait
update_enemies_snake_dash:
	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	ld c,2  ; movement speed
	cp 20
	jr z,update_enemies_snake_end_dash
	cp 16
	jr c,update_enemies_snake_dash_fast
	ld c,1
update_enemies_snake_dash_fast:
	ld a,(game_cycle)
	and #01
	ld b,a
	ld a,(iy+OBJECT_STRUCT_FRAME)
	xor b
	ld (iy+OBJECT_STRUCT_FRAME),a
	srl a
	call z,update_enemy_dec_y_c_times
	dec a
	call z,update_enemy_inc_x_c_times
	dec a
	call z,update_enemy_inc_y_c_times
	dec a
	call z,update_enemy_dec_x_c_times
	jp update_enemies_redraw

update_enemies_snake_end_dash:
	ld (iy+OBJECT_STRUCT_STATE),0
	ld (iy+OBJECT_STRUCT_STATE_TIMER),0
	ld hl,snake_already_attacking
	ld (hl),0
	jp update_enemies_redraw

update_enemies_snake_wait:
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	cp 16
	jr z,update_enemies_snake_wait_continue
	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	jp update_objects_loop_skip
update_enemies_snake_wait_continue:
	ld a,(player_iso_x)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ld c,a
	ld e,a
	jp p,update_enemies_snake_wait_dx_positive
	neg
	ld e,a
update_enemies_snake_wait_dx_positive:
	ld a,(player_iso_y)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld b,a
	ld d,a
	jp p,update_enemies_snake_wait_dy_positive
	neg
	ld d,a
update_enemies_snake_wait_dy_positive:
	; c,b here contain the difference in x and y from enemy to player
	cp e
	jr c,update_enemies_snake_wait_x_orient

update_enemies_snake_wait_y_orient:
	; check whether to dash:
	ld a,e
	cp 8
	call c,update_enemies_snake_start_dash
	ld a,b
	or a
	jp p,update_enemies_snake_wait_y_orient_positive
update_enemies_snake_wait_y_orient_negative:
	xor a
	jr update_enemies_snake_wait_orient_done
update_enemies_snake_wait_y_orient_positive:
	ld a,4
	jr update_enemies_snake_wait_orient_done

update_enemies_snake_wait_x_orient:
	; check whether to dash:
	ld a,d
	cp 8
	call c,update_enemies_snake_start_dash
	ld a,c
	or a
	jp p,update_enemies_snake_wait_x_orient_positive
update_enemies_snake_wait_x_orient_negative:
	ld a,6
	jr update_enemies_snake_wait_orient_done
update_enemies_snake_wait_x_orient_positive:
	ld a,2
	; jr update_enemies_snake_wait_orient_done

update_enemies_snake_wait_orient_done:
	cp (iy+OBJECT_STRUCT_FRAME)
	jp z,update_objects_loop_skip
	ld (iy+OBJECT_STRUCT_FRAME),a
	jp update_enemies_redraw

update_enemies_snake_start_dash:
	ld hl,snake_already_attacking
	ld a,(hl)
	or a
	ret nz  ; if there is a snake already dashing, do not dash
	ld (hl),1
	ld (iy+OBJECT_STRUCT_STATE),1
	ld (iy+OBJECT_STRUCT_STATE_TIMER),0
	ret


update_enemy_dec_y_c_times:
	push af
		xor a
		sub c
		ld d,a
		ld e,0
		ld c,e
		push de
			call check_enemy_collision
		pop de
		jr z,update_enemy_dec_y_c_times_collision
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
		add a,d
		ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
update_enemy_dec_y_c_times_collision:
	pop af
	ret

update_enemy_dec_x_c_times:
	push af
		xor a
		sub c
		ld d,0
		ld e,a
		ld c,d
		push de
			call check_enemy_collision
		pop de
		jr z,update_enemy_dec_x_c_times_collision
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
		add a,e
		ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
update_enemy_dec_x_c_times_collision:
	pop af
	ret


update_enemy_inc_y_c_times:
	push af
		ld d,c
		ld e,0
		ld c,e
		push de
			call check_enemy_collision
		pop de
		jr z,update_enemy_inc_y_c_times_collision
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
		add a,d
		ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
update_enemy_inc_y_c_times_collision:
	pop af
	ret

update_enemy_inc_x_c_times:
	push af
		ld d,0
		ld e,c
		ld c,d
		push de
			call check_enemy_collision
		pop de
		jr z,update_enemy_inc_x_c_times_collision
		ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
		add a,e
		ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
update_enemy_inc_x_c_times_collision:
	pop af
	ret


;-----------------------------------------------
update_enemies_arrow:
	dec (iy+OBJECT_STRUCT_STATE_TIMER)
	ld c,2
	ld a,(iy+OBJECT_STRUCT_FRAME)
	srl a
	dec a
	jr z,update_enemies_arrow_x
update_enemies_arrow_y:
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	cp 18*8
	jr z,update_enemies_hit
	ld de,0
	ld c,0
	call check_enemy_collision
	jr z,update_enemies_hit
	bit 0,(iy+OBJECT_STRUCT_STATE_TIMER)
	jp z,update_enemies_redraw  ; redraw x arrows in odd frames
	jp update_objects_loop_skip

update_enemies_arrow_x:
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	cp 18*8
	jr z,update_enemies_hit
	ld de,0
	ld c,0
	call check_enemy_collision
	jr z,update_enemies_hit
	bit 0,(iy+OBJECT_STRUCT_STATE_TIMER)
	jp nz,update_enemies_redraw  ; redraw y arrows in odd frames
	jp update_objects_loop_skip


;-----------------------------------------------
update_enemies_redraw:
	call update_enemy_screen_coordinates

	; redraw:
;     out (#2c),a  
	; Timing: (measured in room 34)
    ; min: 57952, max: 110812
	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		dec e
		dec d
		ld bc,#0404
		call render_room_rectangle_safe
	pop iy
; 	out (#2d),a
	jp update_objects_loop_skip


;-----------------------------------------------
update_enemies_hit:
	; delete the enemy:
	push iy
	pop ix
	push iy
		call remove_room_object
	pop iy
	ld de,-OBJECT_STRUCT_SIZE  ; since we are deleting the object, decrement iy, so the update loop can continue
	add iy,de
	jp update_objects_loop_skip


;-----------------------------------------------
update_enemy_dec_x:
	ld de,#00ff
	ld c,d
	call check_enemy_collision
	ret z
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ret

update_enemy_inc_x:
	ld de,#0001
	ld c,d
	call check_enemy_collision
	ret z
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ret

update_enemy_dec_y:
	ld de,#ff00
	ld c,e
	call check_enemy_collision
	ret z
	dec (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ret

update_enemy_inc_y:
	ld de,#0100
	ld c,e
	call check_enemy_collision
	ret z
	inc (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ret
