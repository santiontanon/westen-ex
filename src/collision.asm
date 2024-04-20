;-----------------------------------------------
; Checks collision between player and game objects
; input:
; - ix: object to collide with
; - e: offset in iso x
; - d: offset in iso y
; - c: offset in iso z
; return:
; - z: collision (ix contains the collided object)
; - nz: no collision
check_player_collision:
	ld iy,player_iso_x - OBJECT_STRUCT_PIXEL_ISO_X  ; ptr to the player data, mimicking an object struct
	ld a,(n_objects)
; 	or a
; 	jp z,check_player_collision_no_collision1
	ld b,a
	ld ix,objects
check_player_collision_loop1:
	ld a,(ix)
	or a
	jr z,check_player_collision_loop_skip1
	call check_8x8_collision_object
	jr z,collision_player_hit
check_player_collision_loop_skip1:
	ex de,hl
		ld de,OBJECT_STRUCT_SIZE
		add ix,de
	ex de,hl
	djnz check_player_collision_loop1
check_player_collision_no_collision1:

	ld a,(n_collision_objects)
	ld b,a
	ld ix,collision_objects
check_player_collision_loop2:
	call check_8x8_collision_object
	jp z,collision_player_collider
check_player_collision_loop_skip2:
	ex de,hl
		ld de,OBJECT_STRUCT_SIZE
		add ix,de
	ex de,hl
	djnz check_player_collision_loop2
	
check_player_collision_no_collision:
	or 1  ; no collision
	ret


collision_player_hit:
	ld a,(ix)
	cp OBJECT_TYPE_FIRST_ENEMY
	jr c,collision_player_hit_no_enemy
	cp OBJECT_TYPE_BULLET
	jr z,check_player_collision_no_collision

collision_player_hit_enemy:
	call player_hit
	jr check_player_collision_collision

collision_player_hit_no_enemy:
	; push mechanics:
	cp OBJECT_TYPE_STOOL
	jr z,collision_player_hit_push
	cp OBJECT_TYPE_CHAIR_RIGHT
	jr z,collision_player_hit_push
	cp OBJECT_TYPE_CHAIR_LEFT
	jr z,collision_player_hit_push
	cp OBJECT_TYPE_CHAIR_NE
	jr z,collision_player_hit_push
	cp OBJECT_TYPE_CHAIR_SW
	jr z,collision_player_hit_push
	cp OBJECT_TYPE_TALL_STOOL
	jr z,collision_player_hit_push
	; take damage from spikes:
	cp OBJECT_TYPE_SPIKES
	jr z,collision_player_hit_enemy
	cp OBJECT_TYPE_SKELETON_BOSS
	jr z,collision_player_hit_enemy
	cp OBJECT_TYPE_FRANKY
	jr z,collision_player_hit_enemy
check_player_collision_collision:
	xor a
	ret

collision_player_hit_push:
	ld a,c  ; if we are just jumping or falling, no pushing ("c" contains the movement offset of the player)
	or a
	jr nz,check_player_collision_collision

	ld a,(ix+OBJECT_STRUCT_STATE_TIMER)
	add a,2
	ld (ix+OBJECT_STRUCT_STATE_TIMER),a
	cp 8
	jr c,check_player_collision_collision
	; push!
	ld (ix+OBJECT_STRUCT_STATE_TIMER),0

	; check if stool would collide:
	push ix
	pop iy
	sla e
	sla e
	sla e
	sla d
	sla d
	sla d

	call check_enemy_collision
	jr z,check_player_collision_collision

	; change coordinates:
	ld a,e
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,d
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y),a
	; redraw object:	
	call update_enemy_screen_coordinates
	ld e,(iy+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(iy+OBJECT_STRUCT_SCREEN_TILE_Y)
	dec e
	dec d
	ld c,#04
	ld b,(iy+OBJECT_STRUCT_SCREEN_TILE_H)
	inc b
	inc b
	inc b
	push de
	push bc
		call update_object_drawing_order_n_times
	pop bc
	pop de

	ld hl,SFX_push_objects
	call play_SFX_with_high_priority

	jp render_room_rectangle_safe


collision_player_collider:
	ld a,(ix)
	; walking into an event box:
	cp OBJECT_TYPE_COLLIDER_EVENT
	jr nz,check_player_collision_collision

	ld a,(ix+OBJECT_STRUCT_STATE)
	dec a  ; COLLIDER_EVENT_WRONG_WAY
	jr z,collision_player_collider_event_wrong_way
	dec a  ; COLLIDER_EVENT_ENTER_HOME
	jr z,collision_player_collider_event_enter_home
	dec a  ; COLLIDER_EVENT_TOO_FAR
	jr z,collision_player_collider_event_too_far
	dec a  ; COLLIDER_EVENT_SCREAM
	jr z,collision_player_collider_event_scream
	dec a  ; COLLIDER_EVENT_ENTER_BOOKSTORE
	jr z,collision_player_collider_event_enter_bookstore
	dec a  ; COLLIDER_EVENT_ENTER_SUBBASEMENT
	jr z,collision_player_collider_event_enter_subbasement
	jr check_player_collision_collision

collision_player_collider_event_wrong_way:
	ld bc, TEXT_WRONG_WAY
	call queue_hud_message
	ld (ix+OBJECT_STRUCT_STATE),0
	jp check_player_collision_collision

collision_player_collider_event_enter_home:
	ld a,64
	ld (state_current_room),a
	ld hl,map5_zx0
	ld de,1*256+0
	call teleport_player_to_room
	jp state_game

collision_player_collider_event_too_far:
	ld bc, TEXT_TOO_FAR
	call queue_hud_message
	ld (ix+OBJECT_STRUCT_STATE),0
	jp check_player_collision_collision

collision_player_collider_event_scream:
	ld hl,state_beggar
	ld a,(hl)
	cp 2
	jp nz,check_player_collision_no_collision
	ld (hl),3
	ld hl, SFX_beggar_scream
	call play_SFX_with_high_priority
	ld bc, TEXT_EVENT_SCREAM1
	call queue_hud_message
	ld bc, TEXT_EVENT_SCREAM2
	call queue_hud_message
	ld bc, TEXT_EVENT_SCREAM3
	call queue_hud_message
	jp check_player_collision_no_collision

collision_player_collider_event_enter_bookstore:
	ld a,72
	ld (state_current_room),a
	ld hl,map5_zx0
	ld de,0*256+8
	call teleport_player_to_room
	jp state_game

collision_player_collider_event_enter_subbasement:
	ld a,80
	ld (state_current_room),a
	ld hl,map6_zx0
	ld de,0
	call teleport_player_to_room
	jp state_game


;-----------------------------------------------
; Checks collision between an enemy and game objects/player
; input:
; - iy: enemy
; - e: offset in iso x
; - d: offset in iso y
; - c: offset in iso z
; return:
; - z: collision (ix contains the collided object)
; - nz: no collision
check_enemy_collision:
	ld a,(n_objects)
; 	or a
; 	jp z,check_enemy_collision_no_collision1
	ld b,a
	ld ix,objects
check_enemy_collision_loop1:
	ld a,(ix)
	or a
	jr z,check_enemy_collision_loop_skip1
	ld a,iyl
	cp ixl
	jr nz,check_enemy_collision_loop1_not_same_object
	ld a,iyh
	cp ixh
	jr z,check_enemy_collision_loop_skip1  ; prevent self-collisions
check_enemy_collision_loop1_not_same_object:
	call check_8x8_collision_object
	ret z
check_enemy_collision_loop_skip1:
	ex de,hl
		ld de,OBJECT_STRUCT_SIZE
		add ix,de
	ex de,hl
	djnz check_enemy_collision_loop1
check_enemy_collision_no_collision1:

	ld a,(n_collision_objects)
	ld b,a
	ld ix,collision_objects
check_enemy_collision_loop2:
	call check_8x8_collision_object
	ret z
check_enemy_collision_loop_skip2:
	ex de,hl
		ld de,OBJECT_STRUCT_SIZE
		add ix,de
	ex de,hl
	djnz check_enemy_collision_loop2

	ld a,(iy)
	cp OBJECT_TYPE_BULLET
	jr z,check_enemy_collision_no_collision
	ld ix,player_iso_x - OBJECT_STRUCT_PIXEL_ISO_X
	call check_8x8_collision_object
	jp z, collision_player_hit_enemy

check_enemy_collision_no_collision:
	or 1  ; no collision
	ret


;-----------------------------------------------
; Checks for collision between two objects, in iy and ix
; - e,d,c contain x,y,z offsets to be applied to the object in iy
check_8x8_collision_object:
	; check for collision with the object pointed to by ix:
	; if player_x >= object_x + object_width  -->  no collision
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_W)
	dec a
	sub e
	ld l,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	cp l
	jr c,check_player_collision_object_no_collision

	; if player_x + 8 < object_x  -->  no collision
	ld a,l
; 	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_W)
; 	dec a
	add a,7  ; object in iy is always 8x8 pixels
	add a,e
	cp (ix+OBJECT_STRUCT_PIXEL_ISO_X)
	jr c,check_player_collision_object_no_collision

	; if player_y >= object_y + object_height  -->  no collision
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_H)
	dec a
	sub d
	ld l,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	cp l
	jr c,check_player_collision_object_no_collision

	; if player_y + 8 < object_y  -->  no collision
	ld a,l
; 	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_H)
; 	dec a
	add a,7  ; object in iy is always 8x8 pixels
	add a,d
	cp (ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	jr c,check_player_collision_object_no_collision

	; if player_z >= object_z + object_z_height  -->  no collision
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Z)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_Z_H)
	dec a
	sub c
	ld l,(iy+OBJECT_STRUCT_PIXEL_ISO_Z)
	cp l
	jr c,check_player_collision_object_no_collision

	; if player_z + 16 < object_z  -->  no collision
	ld a,l
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_Z_H)
	dec a
	add a,c
	cp (ix+OBJECT_STRUCT_PIXEL_ISO_Z)
	jr c,check_player_collision_object_no_collision

	; collision!
	xor a
	ret

	; no collision!
check_player_collision_object_no_collision:
	or 1
	ret
