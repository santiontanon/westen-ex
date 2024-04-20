;-----------------------------------------------
; input:
; - iy: pointer to object structure
update_objects_skeleton_boss:
	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	ld a,(iy+OBJECT_STRUCT_STATE)
	or a
	jr z,update_objects_skeleton_boss_state_sleep
	dec a
	jr z,update_objects_skeleton_boss_state_awake
update_objects_skeleton_boss_done:
	jp update_objects_loop_skip


update_objects_skeleton_boss_state_sleep:
	xor a
	ld (miniboss_hit),a  ; even if player hits boss before activating, it does not count
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr nz,update_objects_skeleton_boss_done
	; awake!
	ld (iy+OBJECT_STRUCT_STATE),1
	ld (iy+OBJECT_STRUCT_STATE_TIMER),0
	ld a,2
	call update_objects_skeleton_boss_change_frame
	ld bc, TEXT_MINI_BOSS_MSG1
	call queue_hud_message
	ld a,32  ; initial hitpoints
; 	ld a,4  ; initial hitpoints
	ld (miniboss_hitpoints),a
	call play_music_ingame_miniboss
	jr update_objects_skeleton_boss_done


update_objects_skeleton_boss_state_awake:
	ld a,(miniboss_hit)
	or a
	jr z,update_objects_skeleton_boss_state_awake_no_hit
	inc a
	ld (miniboss_hit),a
	dec a
	dec a
	jp z,update_objects_skeleton_boss_state_hit_boss
	cp 2
	jr nz,update_objects_skeleton_boss_state_awake_no_hit
	xor a
	ld (miniboss_hit),a
	call update_objects_skeleton_boss_redraw
	jr update_objects_skeleton_boss_done
update_objects_skeleton_boss_state_awake_no_hit:
	ld a,(iy+OBJECT_STRUCT_FRAME)
	and #01  ; if the foot was lifted from the ground, continue walking
	jr nz,update_objects_skeleton_boss_state_awake_continue
	call update_objects_skeleton_orient_toward_player
	call update_objects_skeleton_boss_change_frame
	jr nz,update_objects_skeleton_boss_done
update_objects_skeleton_boss_state_awake_continue:
	; skeleton was already facing the correct direction, have a chance to move:
	ld a,(miniboss_hitpoints)
	add a,5
	ld c,a
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	cp c  ; skeleton moves every "5 + hitpoints" frames
	jr c,update_objects_skeleton_boss_done
	; advance!
	ld (iy+OBJECT_STRUCT_STATE_TIMER),0

	ld a,(iy+OBJECT_STRUCT_FRAME)
	bit 0,a  ; only change position in the even frames
	jr nz,update_objects_skeleton_boss_state_movement_done_no_collision_check
	sra a
	jr z,update_objects_skeleton_boss_state_move_ne
	dec a
	jr z,update_objects_skeleton_boss_state_move_se
	dec a
	jr z,update_objects_skeleton_boss_state_move_sw
update_objects_skeleton_boss_state_move_nw:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,-8
	ld de,#00f8
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	jr update_objects_skeleton_boss_state_movement_done
update_objects_skeleton_boss_state_move_sw:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	cp 8*15  ; skeleton cannot go beyond this coordinate
	jr nc,update_objects_skeleton_boss_state_movement_done
	add a,8
	ld de,#0800
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	jr update_objects_skeleton_boss_state_movement_done
update_objects_skeleton_boss_state_move_se:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,8
	ld de,#0008
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	jr update_objects_skeleton_boss_state_movement_done
update_objects_skeleton_boss_state_move_ne:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,-8
	ld de,#f800
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
; 	jr update_objects_skeleton_boss_state_movement_done

update_objects_skeleton_boss_state_movement_done:
	; check if we have to hurt the player:
	push de
		ld de,0
		ld c,e  ; as e == 0 here
		ld ix,player_iso_x - OBJECT_STRUCT_PIXEL_ISO_X
		call check_8x8_collision_object
	pop de
	jr nz,update_objects_skeleton_boss_state_movement_done_no_collision_check
	; collision with player!
	push de
		call player_hit
	pop de
	push iy
		ld c,0
		call check_player_collision
	pop iy
	jr z,update_objects_skeleton_boss_state_movement_done_no_collision_check
	; try to push the player (push by "bc"):
	ld a,(player_iso_x)
	add a,e
	ld (player_iso_x),a
	ld a,(player_iso_y)
	add a,d
	ld (player_iso_y),a

update_objects_skeleton_boss_state_movement_done_no_collision_check:
	call update_enemy_screen_coordinates
	dec (iy+OBJECT_STRUCT_SCREEN_TILE_X)
	dec (iy+OBJECT_STRUCT_SCREEN_TILE_X)  ; correct the coordinates, since the function assumes
										  ; it's a 2x2 enemy
	; redraw:
	ld a,(iy+OBJECT_STRUCT_FRAME)
	xor #01
; 	call update_objects_skeleton_boss_redraw
	call update_objects_skeleton_boss_change_frame
	jp update_objects_skeleton_boss_done


;-----------------------------------------------
; input:
; - iy: ptr to mini boss object
; output:
; - a: desired frame (works for both skeleton and franky minibosses)
update_objects_skeleton_orient_toward_player:
	ld a,(player_iso_x)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ld c,a
	ld e,a
	jp p,update_objects_skeleton_orient_toward_player_dx_positive
	neg
	ld e,a
update_objects_skeleton_orient_toward_player_dx_positive:
	ld a,(player_iso_y)
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld b,a
	ld d,a
	jp p,update_objects_skeleton_orient_toward_player_dy_positive
	neg
	ld d,a
update_objects_skeleton_orient_toward_player_dy_positive:
	; c,b here contain the difference in x and y from enemy to player
	cp e
	jr c,update_objects_skeleton_orient_toward_player_x

update_objects_skeleton_orient_toward_player_y:
	ld a,b
	or a
	jp p,update_objects_skeleton_orient_toward_player_y_positive
update_objects_skeleton_orient_toward_player_y_negative:
	xor a
	jr update_objects_skeleton_orient_toward_player_done
update_objects_skeleton_orient_toward_player_y_positive:
	ld a,4
	jr update_objects_skeleton_orient_toward_player_done

update_objects_skeleton_orient_toward_player_x:
	ld a,c
	or a
	jp p,update_objects_skeleton_orient_toward_player_x_positive
update_objects_skeleton_orient_toward_player_x_negative:
	ld a,6
	jr update_objects_skeleton_orient_toward_player_done
update_objects_skeleton_orient_toward_player_x_positive:
	ld a,2
	; jr update_objects_skeleton_orient_toward_player_done

update_objects_skeleton_orient_toward_player_done:
	ret


;-----------------------------------------------
; input:
; - a: frame
; - iy: object pointer
; output:
; - z: frame not changed
; - nz: frame changed and screen redrawn
update_objects_skeleton_boss_change_frame:
	cp (iy+OBJECT_STRUCT_FRAME)
	ret z  ; skeleton already has the correct frame
	ld (iy+OBJECT_STRUCT_FRAME),a

	; change animation frame:
; 	ld l, (iy + OBJECT_STRUCT_PTR)
; 	ld h, (iy + OBJECT_STRUCT_PTR + 1)
; 	push hl

; 	ld bc, 4*5*8*3
; 	add hl,bc  ; hl now points to the name tables
; 	push hl
; 		ld bc,4*5 * 8  ; skip the 8 name tables
; 		add hl,bc
; 		ex de,hl  ; de has a pointer to the tileset
; 	pop hl
	ld ix,enemy_data_buffer
	ld bc,5*5
	or a
	jr z,update_objects_skeleton_boss_change_frame_name_table_loop_done
update_objects_skeleton_boss_change_frame_name_table_loop:
	add ix,bc
	dec a
	jr nz,update_objects_skeleton_boss_change_frame_name_table_loop
update_objects_skeleton_boss_change_frame_name_table_loop_done:
; 	ex de,hl  ; hl: tileset, de: name table
; 	push hl
; 	pop ix  ; hl: tileset, ix: name table
; 	pop de

	ld e, (iy + OBJECT_STRUCT_PTR)
	ld d, (iy + OBJECT_STRUCT_PTR + 1)
	ld hl,enemy_data_buffer + 5*5*8
	; at this point:
	; - de: points to the frame data
	; - ix: points at the name table to use
	; - hl: points to the tileset
	ld b,5*5
update_objects_skeleton_boss_change_frame_copy_tile_loop:
	push bc
		ld a,(ix)
		push hl
			; hl += a * 8*3
			push hl
				ld b,0
				ld c,a
				ld h,b  ; as b == 0 here
				ld l,a
				add hl,hl  ; a*2
				add hl,bc  ; a*3
			pop bc
			add hl,hl  ; a*2*3
			add hl,hl  ; a*4*3
			add hl,hl  ; a*8*3
			add hl,bc
			ld bc,8*3
			ldir
		pop hl
		inc ix
	pop bc
	djnz update_objects_skeleton_boss_change_frame_copy_tile_loop

update_objects_skeleton_boss_redraw:
	ld d,COLOR_RED
update_objects_skeleton_boss_redraw_sprite_color_set:
	; redraw room square:
	push de
	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		dec e
		dec d
		ld bc,#0707
		call render_room_rectangle_safe
	pop iy
	pop de

	; draw sprites:
	ld hl, buffer1024
	push hl
		ld a,(iy+OBJECT_STRUCT_FRAME)
		add a,a
		add a,12
		add a,a
		add a,a
		ld e,a
		ld b,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		ld c,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		inc b
		sla b
		bit 0,c
		jr nz,update_objects_skeleton_boss_redraw_sprite_no_y_correction
		inc b
update_objects_skeleton_boss_redraw_sprite_no_y_correction:
		sla b
		sla b
		dec b
		ld (hl),b
		inc hl		
		ld a,(iy+OBJECT_STRUCT_FRAME)
		cp 4
		jr nc,update_objects_skeleton_boss_redraw_sprite_x_set
		inc c
update_objects_skeleton_boss_redraw_sprite_x_set:
		inc c
		sla c
		sla c
		sla c
		ld (hl),c
		inc hl
		ld (hl),e
		inc hl
		ld (hl),d  ; d has the color
		inc hl
		ld a,b
		add a,16
		ld (hl),a
		inc hl
		ld (hl),c
		inc hl
		ld a,e
		add a,4
		ld (hl),a
		inc hl
		ld (hl),d  ; d has the color
	pop hl
	ld de,SPRATR2+7*4
	ld bc,8
	call fast_LDIRVM

	or 1  ; mark that we changed the frame
	ret


;-----------------------------------------------
update_objects_skeleton_boss_state_hit_boss:
	ld hl,SFX_enemy_hit
	call play_SFX_with_high_priority
	ld hl,miniboss_hitpoints
	dec (hl)
	ld a,(hl)
	or a
	jr z, update_objects_skeleton_boss_killed
	ld d,COLOR_DARK_YELLOW
	call update_objects_skeleton_boss_redraw_sprite_color_set
	jp update_objects_loop_skip	


;-----------------------------------------------
update_objects_skeleton_boss_killed:
	ld b,8
	ld hl,SFX_enemy_death
	call play_SFX_with_high_priority
update_objects_skeleton_boss_killed_loop:
	push bc
		ld d,COLOR_DARK_YELLOW
		call update_objects_skeleton_boss_redraw_sprite_color_set
		ld b,4
		call wait_b_halts
		ld d,COLOR_DARK_RED
		call update_objects_skeleton_boss_redraw_sprite_color_set
		ld b,4
		call wait_b_halts
	pop bc
	djnz update_objects_skeleton_boss_killed_loop

	ld a,1
	ld (state_skeleton_miniboss),a

	; clear the sprites:
	xor a
	ld bc,8
	ld hl,SPRATR2+7*4
	call fast_FILVRM

	ld (iy),0
	; delete boss:
	; store boss screen coordinates:
	ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)

	; replace with key:
	ld (iy),OBJECT_TYPE_SKELETON_KEY
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W),6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H),6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H),4
	ld (iy+OBJECT_STRUCT_SCREEN_TILE_W),2
	ld (iy+OBJECT_STRUCT_SCREEN_TILE_H),2
	ld (iy+OBJECT_STRUCT_TILE_X_OFFSET),1
	ld (iy+OBJECT_STRUCT_TILE_Y_OFFSET),1
	push de
		push iy
			ld hl,object_skeleton_key_zx0
			ld de,buffer1024
			SETMEGAROMPAGE_A000 OBJECTS_PAGE3
			call dzx0_standard
		pop iy
		ld hl,buffer1024+9
		ld e,(iy+OBJECT_STRUCT_PTR)
		ld d,(iy+OBJECT_STRUCT_PTR+1)
		ld bc,4*8*3
		ldir
		call update_enemy_screen_coordinates
	pop de
	push iy
		dec e
		dec d
		ld bc,#0707
		call render_room_rectangle_safe
	pop iy
	jp update_objects_loop_skip

