;-----------------------------------------------
; input:
; - iy: pointer to object structure
update_objects_franky_boss:
	ld a,(miniboss_hit)
	or a
	jp nz,update_objects_franky_boss_hit

	; franky behavior, follow player:
	call update_objects_franky_orient_toward_player
	call update_objects_franky_boss_change_frame
	jp nz,update_objects_franky_boss_done
update_objects_franky_boss_state_follow_continue:
	; boss was already facing the correct direction, have a chance to move:
	inc (iy+OBJECT_STRUCT_STATE_TIMER)
	ld a,(iy+OBJECT_STRUCT_STATE_TIMER)
	cp 32  ; franky moves every "32" frames
	jp c,update_objects_franky_boss_done
	; advance!
	ld (iy+OBJECT_STRUCT_STATE_TIMER),0

	ld a,(iy+OBJECT_STRUCT_FRAME)
	sra a
	jr z,update_objects_franky_boss_state_move_ne
	dec a
	jr z,update_objects_franky_boss_state_move_se
	dec a
	jr z,update_objects_franky_boss_state_move_sw
update_objects_franky_boss_state_move_nw:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,-8
	ld de,#00f8
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	jr update_objects_franky_boss_state_movement_done
update_objects_franky_boss_state_move_sw:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	cp 8*13  ; skeleton cannot go beyond this coordinate
	jr nc,update_objects_franky_boss_state_movement_done	
	add a,8
	ld de,#0800
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	jr update_objects_franky_boss_state_movement_done
update_objects_franky_boss_state_move_se:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,8
	ld de,#0008
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	jr update_objects_franky_boss_state_movement_done
update_objects_franky_boss_state_move_ne:
	ld a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,-8
	ld de,#f800
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
; 	jr update_objects_franky_boss_state_movement_done

update_objects_franky_boss_state_movement_done:
	; check if we have to hurt the player:
	push de
		ld de,0
		ld c,0
		ld ix,player_iso_x - OBJECT_STRUCT_PIXEL_ISO_X
		call check_8x8_collision_object
	pop de
	jr nz,update_objects_franky_boss_state_movement_done_no_collision_check
	; collision with player!
	push de
		call player_hit
	pop de
	push iy
		ld c,0
		call check_player_collision
	pop iy
	jr z,update_objects_franky_boss_state_movement_done_no_collision_check
	; try to push the player (push by "bc"):
	ld a,(player_iso_x)
	add a,e
	ld (player_iso_x),a
	ld a,(player_iso_y)
	add a,d
	ld (player_iso_y),a

update_objects_franky_boss_state_movement_done_no_collision_check:
	call update_enemy_screen_coordinates

	; with x-3: -8, -8
	; with x-2: 0, -8
	; with x-2, y+1: sprites in right place, but tiles 0, -8!?
	inc (iy+OBJECT_STRUCT_SCREEN_TILE_Y)
	ld a,(iy+OBJECT_STRUCT_SCREEN_PIXEL_Y)
	add a,8
	ld (iy+OBJECT_STRUCT_SCREEN_PIXEL_Y),a
	dec (iy+OBJECT_STRUCT_SCREEN_TILE_X)
	dec (iy+OBJECT_STRUCT_SCREEN_TILE_X)  ; correct the coordinates, since the function assumes
										  ; it's a 2x2 enemy
	; redraw:
	ld a,(iy+OBJECT_STRUCT_FRAME)
	xor #01
	call update_objects_franky_boss_change_frame
update_objects_franky_boss_done:
	jp update_objects_loop_skip



;-----------------------------------------------
update_objects_franky_orient_toward_player:
	call update_objects_skeleton_orient_toward_player
	ld b,a
	ld a,(iy+OBJECT_STRUCT_FRAME)
	and #01
	or b
	ret


;-----------------------------------------------
; input:
; - a: frame
; - iy: object pointer
; output:
; - z: frame not changed
; - nz: frame changed and screen redrawn
update_objects_franky_boss_change_frame:
	cp (iy+OBJECT_STRUCT_FRAME)
	ret z  ; franky already has the correct frame
	ld (iy+OBJECT_STRUCT_FRAME),a

	; change animation frame:
	ld ix,enemy_data_buffer
	ld bc,5*6
	or a
	jr z,update_objects_franky_boss_change_frame_name_table_loop_done
update_objects_franky_boss_change_frame_name_table_loop:
	add ix,bc
	dec a
	jr nz,update_objects_franky_boss_change_frame_name_table_loop
update_objects_franky_boss_change_frame_name_table_loop_done:

	ld e, (iy + OBJECT_STRUCT_PTR)
	ld d, (iy + OBJECT_STRUCT_PTR + 1)
	ld hl,enemy_data_buffer + 5*6*8
	; at this point:
	; - de: points to the frame data
	; - ix: points at the name table to use
	; - hl: points to the tileset
	ld b,5*6
update_objects_franky_boss_change_frame_copy_tile_loop:
	push bc
		ld a,(ix)
		push hl
			; hl += a * 8*3
			push hl
				ld b,0
				ld c,a
				ld h,0
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
	djnz update_objects_franky_boss_change_frame_copy_tile_loop


update_objects_franky_boss_redraw:
	; redraw room square:
	push de
	push iy
		ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
		ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
		dec e
		dec d
		ld bc,#0807
		call render_room_rectangle_safe
	pop iy
	pop de

	; draw sprites:
	ld hl, buffer1024
	push hl
		ld a,(iy+OBJECT_STRUCT_FRAME)
		push af
			; sprite is: 4*(a*3+12)
			add a,a
			add a,(iy+OBJECT_STRUCT_FRAME)
			add a,12
			add a,a
			add a,a
			ld e,a
			ld b,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
			ld c,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
			dec b
			sla b
			bit 0,c
			jr nz,update_objects_franky_boss_redraw_sprite_no_y_correction
			inc b
update_objects_franky_boss_redraw_sprite_no_y_correction:
			inc b
			sla b
			sla b
			; sprite 1: eyes
			ld (hl),b  ; y
			inc hl		
			ld a,(iy+OBJECT_STRUCT_FRAME)
			inc c
			inc c
			sla c
			sla c
			sla c
			ld (hl),c  ; x
			inc hl
			ld (hl),e  ; sprite
			inc hl
			ld (hl),9  ; color
		pop af

		push bc
			; 0,1: ok
			; 2,3: -8
			; 4,5: ok
			; 6,7: -8
			bit 1,a
			jr z,update_objects_franky_boss_redraw_correct_x
			ld a,c
			add a,-8
			ld c,a
update_objects_franky_boss_redraw_correct_x:

			; sprite 2:
			inc hl
			ld a,b
			add a,16
			ld (hl),a  ; y
			inc hl
			ld (hl),c  ; x
			inc hl
			ld a,e
			add a,4
			ld (hl),a  ; sprite
			inc hl
			ld (hl),2  ; color
		pop bc

		; sprite 3:
		inc hl
		ld a,b
		add a,32 + 3
		ld (hl),a  ; y
		inc hl
		ld a,c
		add a,-8
		ld (hl),a  ; x
		inc hl
		ld a,e
		add a,8
		ld (hl),a  ; sprite
		inc hl
		ld (hl),2  ; color

	pop hl
	ld de,SPRATR2+7*4
	ld bc,4*3
	call fast_LDIRVM

	or 1  ; mark that we changed the frame
	ret


;-----------------------------------------------
update_objects_franky_boss_hit:
	xor a
	ld (miniboss_hit),a
	ld a,INVENTORY_SILVER_BULLETS
	call inventory_find_slot
	jr z,update_objects_franky_boss_hit_damage
update_objects_franky_boss_hit_no_damage:
	ld bc, TEXT_FRANKY3
	call queue_hud_message
	jp update_objects_loop_skip


update_objects_franky_boss_hit_damage:
	ld hl,SFX_enemy_hit
	call play_SFX_with_high_priority
	ld hl,miniboss_hitpoints
	dec (hl)
	ld a,(hl)
	or a
	jr z, update_objects_franky_boss_killed
	jp update_objects_loop_skip


;-----------------------------------------------
update_objects_franky_boss_killed:
	ld hl,SFX_enemy_death
	call play_SFX_with_high_priority
; 	ld b,8
; update_objects_franky_boss_killed_loop:
; 	push bc
; 		ld d,COLOR_DARK_YELLOW
; 		call update_objects_franky_boss_redraw_sprite_color_set
; 		ld b,4
; 		call wait_b_halts
; 		ld d,COLOR_DARK_RED
; 		call update_objects_franky_boss_redraw_sprite_color_set
; 		ld b,4
; 		call wait_b_halts
; 	pop bc
; 	djnz update_objects_franky_boss_killed_loop

	ld a,1
	ld (state_franky_boss),a

	; clear the sprites:
; 	xor a
; 	ld bc,8
; 	ld hl,SPRATR2+7*4
; 	call fast_FILVRM

	; messages:
	ld bc, TEXT_FRANKY4
	call queue_hud_message
	ld bc, TEXT_FRANKY5
	call queue_hud_message

	ld (iy),0
	; delete boss:
	; store boss screen coordinates:
	ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)

	; replace with note:
	ld (iy),OBJECT_TYPE_FRANKY_NOTE
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W),6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H),6
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H),4
	ld (iy+OBJECT_STRUCT_SCREEN_TILE_W),2
	ld (iy+OBJECT_STRUCT_SCREEN_TILE_H),2
	ld (iy+OBJECT_STRUCT_TILE_X_OFFSET),1
	ld (iy+OBJECT_STRUCT_TILE_Y_OFFSET),1
	push de
		push iy
			ld hl,object_franky_note_zx0
			ld de,buffer1024
			SETMEGAROMPAGE_A000 OBJECTS_PAGE3
			call dzx0_standard

			; remove the boss sprites:
			xor a
			ld hl,SPRATR2+7*4
			ld bc,4*3
			call fast_FILVRM
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
		ld bc,#0807
		call render_room_rectangle_safe
	pop iy
	jp update_objects_loop_skip

