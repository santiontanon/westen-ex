;-----------------------------------------------
; input:
; - hl: map
; - a: room # within the map
load_room:
	push af
		; decompress the map:
		SETMEGAROMPAGE_A000 MAPS_PAGE
		ld de,buffer1024
		call dzx0_standard
	pop af
	ld hl,buffer1024
	or a
	jr z,load_room_found
load_room_loop:
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	add hl,bc
	dec a
	jr nz,load_room_loop
load_room_found:
	inc hl  ; skip the room size
	inc hl
	ld de,room_x
	ldi
	ldi
	ldi
	ldi
	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
	SETMEGAROMPAGE_8000 3
	ld a,(hl)  ; floor type
	inc hl
	push hl
		call load_room_floor
	pop hl

	ld a,(hl)  ; wall type
	inc hl
	push hl
		call load_room_wall
		SETMEGAROMPAGE_8000 2

		; clear the object/door buffers:
		ld hl,object_decompression_buffer
		ld (hl),0
		ld de,object_decompression_buffer+1
		ld bc,OBJECT_DECOMPRESSION_BUFFER_SIZE+DOOR_DECOMPRESSION_BUFFER_SIZE-1
		ldir
	pop hl

	ld a,(hl)
	ld (n_doors),a
	inc hl
	or a
	jr z, load_room_door_loop_done
	ld de,doors
	ld b,a
load_room_door_loop:
	push bc
		push de
			ld bc,DOOR_STRUCT_SIZE
			ldir
		pop ix
		push de
		push hl
			SETMEGAROMPAGE_8000 3
			call load_room_door
			SETMEGAROMPAGE_8000 2
		pop hl
		pop de
	pop bc
	djnz load_room_door_loop
load_room_door_loop_done:

	; shoft the room_y upward to make walls have width:
	push hl
		ld hl,room_y
		dec (hl)
		dec (hl)
		inc hl
		inc (hl)
		inc (hl)
		inc hl
		inc (hl)
		inc (hl)
	pop hl

	; load objects:
	xor a
	ld (miniboss_hitpoints),a  ; clear the hitpoints to indicate we are not fighting
							   ; a miniboss by default.
	ld (room_enemy_type),a
	ld (object_decompression_buffer),a
	ld a,(hl)
	ld (n_objects),a
	inc hl
	or a
	jr z, load_room_object_loop_done  ; no objects
	ld b,a
	ld ix,objects
load_room_object_loop:
	push bc
		push ix
		pop de
		ld bc,4
		ldir
		ld a,(ix)
		cp OBJECT_TYPE_FIRST_ENEMY
		push af
			call c,load_room_init_object
		pop af
		call nc,load_room_init_enemy
		ld de,OBJECT_STRUCT_SIZE
		add ix,de
load_room_object_loop_skip:
	pop bc
	djnz load_room_object_loop
load_room_object_loop_done:

	; clear vampire state:
	xor a
	ld (current_room_vampire_state),a

	; assuming we only have one type of enemy per room, decompress the enemy type:
	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
	ld a,(room_enemy_type)
	dec a
	jp z,decompress_enemy_rat
	add a,-2
	jp z,decompress_enemy_spider
	dec a
	jp z,decompress_enemy_slime
	dec a
	jp z,decompress_enemy_bat
	dec a
	jp z,decompress_enemy_snake
	add a,-2
	jp z,decompress_enemy_arrow
	dec a
	jp z,decompress_enemy_skeleton_boss
	dec a
	jp z,decompress_enemy_franky_boss

load_room_enemy_loop_done:
	; Fill in derived variables:
	ld a,(room_width)
	inc a
	add a,a
	add a,a
	add a,a
	ld (room_width_pixels),a
	ld a,(room_height)
	inc a
	add a,a
	add a,a
	add a,a
	ld (room_height_pixels),a
	call sync_switch_state_with_global_state
	call switch_effect_on_room
	SETMEGAROMPAGE_8000 2
	call spawn_global_items
	SETMEGAROMPAGE_8000 3
	call create_wall_colliders
	SETMEGAROMPAGE_8000 2
	ret


load_room_wall:
	or a
	ret z
	dec a
	jp z,setup_wall_bookshelves
	dec a
	jp z,setup_wall_bluebricks
	dec a
	jp z,setup_wall_entrance
	dec a
	jp z,setup_wall_victorian
	dec a
	jp z,setup_wall_victorian_tiles
	dec a
	jp z,setup_wall_victorian_blue
	dec a
	jp z,setup_wall_bricks_bookshelves
	dec a
	jp z,setup_wall_ossuary_ne
	dec a
	jp z,setup_wall_ossuary_nw
	dec a
	jp z,setup_wall_white_stone
	dec a
	jp z,setup_wall_white_stone_nw
	ret


;-----------------------------------------------
; Populates the object ptr, and the screen coordinates of the object. 
; input:
; - ix: object ptr
load_room_init_object:
	SETMEGAROMPAGE_A000 OBJECTS_PAGE1
	ld a,(ix)
	push hl
		ld hl,object_data_ptrs - 4 ; first object ID is 2
		ld b,0
		ld c,a
		add hl,bc
		add hl,bc
		ld e,(hl)
		inc hl
		ld d,(hl)

		cp 93  ; first object to be in page 5
		jr c,load_room_init_object_page1
		push af
			SETMEGAROMPAGE_A000 OBJECTS_PAGE2
		pop af
		cp 183  ; first object to be in page 6
		jr c,load_room_init_object_page2
		push af
			SETMEGAROMPAGE_A000 OBJECTS_PAGE3
		pop af
load_room_init_object_page1:
load_room_init_object_page2:
	pop hl
	cp OBJECT_TYPE_YELLOW_KEY
	jp z,load_room_init_object_yellow_key
	cp OBJECT_TYPE_DOOR_LEFT_RED
	jp z,load_room_init_object_door_left_red
	cp OBJECT_TYPE_DOOR_RIGHT_YELLOW
	jp z,load_room_init_object_door_right_yellow
; 	cp OBJECT_TYPE_GUN
; 	jp z,load_room_init_object_gun
	cp OBJECT_TYPE_GUN_KEY
	jp z,load_room_init_object_gun_key
	cp OBJECT_TYPE_DOOR_RIGHT_WHITE
	jp z,load_room_init_object_door_right_white
	cp OBJECT_TYPE_LETTER3
	jp z,load_room_init_object_letter3
	cp OBJECT_TYPE_LAMP
	jp z,load_room_init_object_lamp
	cp OBJECT_TYPE_OIL
	jp z,load_room_init_object_oil
	cp OBJECT_TYPE_PAINTING_SAFE_RIGHT
	jp z,load_room_init_painting_safe_right
	cp OBJECT_TYPE_HEART1
	jp z,load_room_init_object_heart1
	cp OBJECT_TYPE_HEART2
	jp z,load_room_init_object_heart2
	cp OBJECT_TYPE_HEART3
	jp z,load_room_init_object_heart3
	cp OBJECT_TYPE_HEART4
	jp z,load_room_init_object_heart4
	cp OBJECT_TYPE_BOOK
	jp z,load_room_init_object_book
	cp OBJECT_TYPE_DOOR_RITUAL
	jp z,load_room_init_object_ritual_door
	cp OBJECT_TYPE_DOOR_LEFT_YELLOW
	jp z,load_room_init_object_door_left_yellow
	cp OBJECT_TYPE_GREEN_KEY
	jp z,load_room_init_object_green_key
	cp OBJECT_TYPE_DOOR_RIGHT_GREEN
	jp z,load_room_init_object_door_right_green
	cp OBJECT_TYPE_DIARY1
	jp z,load_room_init_object_diary1
	cp OBJECT_TYPE_DIARY2
	jp z,load_room_init_object_diary2
	cp OBJECT_TYPE_DIARY3
	jp z,load_room_init_object_diary3
	cp OBJECT_TYPE_LAB_NOTES
	jp z,load_room_init_object_lab_notes
	cp OBJECT_TYPE_HAMMER
	jp z,load_room_init_object_hammer
	cp OBJECT_TYPE_DOOR_RIGHT_BLUE
	jp z,load_room_init_object_door_right_blue
	cp OBJECT_TYPE_CRATE_GARLIC1
	jp z,load_room_init_object_crate_garlic1
	cp OBJECT_TYPE_CRATE_GARLIC2
	jp z,load_room_init_object_crate_garlic2
	cp OBJECT_TYPE_CRATE_GARLIC3
	jp z,load_room_init_object_crate_garlic3
	cp OBJECT_TYPE_CRATE_STAKE1
	jp z,load_room_init_object_crate_stake1
	cp OBJECT_TYPE_CRATE_STAKE2
	jp z,load_room_init_object_crate_stake2
	cp OBJECT_TYPE_CRATE_STAKE3
	jp z,load_room_init_object_crate_stake3
	cp OBJECT_TYPE_DOOR_VAMPIRE1
	jp z,load_room_init_object_door_vampire1
	cp OBJECT_TYPE_DOOR_VAMPIRE2
	jp z,load_room_init_object_door_vampire2
	cp OBJECT_TYPE_DOOR_VAMPIRE3
	jp z,load_room_init_object_door_vampire3
	cp OBJECT_TYPE_DOOR_VAMPIRE4
	jp z,load_room_init_object_door_vampire4
	cp OBJECT_TYPE_COFFIN1
	jp z,load_room_init_object_coffin1
	cp OBJECT_TYPE_COFFIN2
	jp z,load_room_init_object_coffin2
	cp OBJECT_TYPE_LUGGAGE
	jp z,load_room_init_object_luggage
	cp OBJECT_TYPE_NEWSPAPER
	jp z,load_room_init_object_newspaper
	cp OBJECT_TYPE_BEGGAR
	jp z,load_room_init_object_beggar
	cp OBJECT_TYPE_CHOFFEUR
	jp z,load_room_init_object_choffeur
	cp OBJECT_TYPE_LUCY_TORN_NOTE
	jp z,load_room_init_object_torn_note
	cp OBJECT_TYPE_MIRROR_NW
	jp z,load_room_init_object_mirror_nw
	cp OBJECT_TYPE_MIRROR_NE
	jp z,load_room_init_object_mirror_ne
	cp OBJECT_TYPE_CHEST_REVEAL
	jp z,load_room_init_object_chest_reveal
	cp OBJECT_TYPE_CHEST_REVEAL2
	jp z,load_room_init_object_chest_reveal
	cp OBJECT_TYPE_DOOR_PRISON_ENTRANCE
	jp z,load_room_init_object_door_prison_entrance
	cp OBJECT_TYPE_CAULDRON
	jp z,load_room_init_object_cauldron
	cp OBJECT_TYPE_ARROW_SHOOTER_X
	jp z,load_room_init_arrow_shooter
	cp OBJECT_TYPE_ARROW_SHOOTER_Y
	jp z,load_room_init_arrow_shooter
	cp OBJECT_TYPE_SKELETON_BOSS
	jp z,load_room_init_skeleton_boss
	cp OBJECT_TYPE_DOOR_PRISON_PASSAGE
	jp z,load_room_init_object_door_prison_passage 
	cp OBJECT_TYPE_DOOR_PRISON_FRANKY
	jp z,load_room_init_object_door_prison_franky
	cp OBJECT_TYPE_OPEN_GRAVE
	jp z,load_room_init_object_open_grave
	cp OBJECT_TYPE_CLAY
	jp z,load_room_init_object_clay
	cp OBJECT_TYPE_FRANKY
	jp z,load_room_init_franky
	cp OBJECT_TYPE_PUZZLE_BOX
	jp z,load_room_init_puzzle_box
	cp OBJECT_TYPE_VLAD_DIARY
	jp z,load_room_init_vlad_diary

load_room_init_object_ptr_set:
	; see if we have the object already recompressed:
	push hl
		ld hl,object_decompression_buffer
load_room_init_object_find_decompressed_loop:
		ld a,(hl)
		or a
		jr z,load_room_init_object_not_found
		cp (ix)
		jr z,load_room_init_object_found
		inc hl
		ld c,(hl)
		inc hl
		ld b,(hl)
		inc hl
		add hl,bc
		jr load_room_init_object_find_decompressed_loop

load_room_init_object_found:
		ex de,hl
		inc de
		jr load_room_init_object_decompressed

load_room_init_object_not_found:
		ex de,hl
		ld a,(ix)
		ld (de),a
		inc de
		push de
		push ix
			call dzx0_standard
		pop ix
		pop de
load_room_init_object_decompressed:
		inc de
		inc de  ; skip object size in bytes
	pop hl

load_room_init_object_ptr_set_decompressed:
	ld a,(de)  ; object width
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_W),a	
	inc de
	ld a,(de)  ; object height
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_H),a	

	inc de
	ld a,(de)  ; object width
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_W),a
	inc de
	ld a,(de)  ; object height
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_H),a

	inc de
	ld a,(de)  ; object z height
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z_H),a	
	inc de
	ld a,(de)  ; object x offset
	ld (ix+OBJECT_STRUCT_TILE_X_OFFSET),a	
	inc de
	ld a,(de)  ; object y offset
	ld (ix+OBJECT_STRUCT_TILE_Y_OFFSET),a	
	inc de

	; screen_x = room_x + x - y
	; screen_y = room_y + x/2 + y/2
	ld a,(room_x)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)  ; note: at this point, coordinates are still in "tiles", we have not yet converted them to pixels
	sub (ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	sub (ix+OBJECT_STRUCT_TILE_X_OFFSET)
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_X),a
	add a,a
	add a,a
	add a,a
	ld (ix+OBJECT_STRUCT_SCREEN_PIXEL_X),a	

	; convert the coordinates to pixels (multiply first by 4, and by 2 more below):
	sla (ix+OBJECT_STRUCT_PIXEL_ISO_X)
	sla (ix+OBJECT_STRUCT_PIXEL_ISO_X)
	sla (ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	sla (ix+OBJECT_STRUCT_PIXEL_ISO_Y)
 
	ld a,(room_y)
	add a,a
	add a,a
	add a,a
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld b,a
	ld a,(ix+OBJECT_STRUCT_TILE_Y_OFFSET)
	add a,a
	add a,a
	add a,a
	ld c,a
	ld a,b
	sub c
	sub (ix+OBJECT_STRUCT_PIXEL_ISO_Z)
	ld (ix+OBJECT_STRUCT_SCREEN_PIXEL_Y),a
	rrca
	rrca
	rrca
	and #1f
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_Y),a

	sla (ix+OBJECT_STRUCT_PIXEL_ISO_X)
	sla (ix+OBJECT_STRUCT_PIXEL_ISO_Y)

	ld (ix+OBJECT_STRUCT_STATE_TIMER),0

	; we store the pointer to the object, skipping the w, h data
	ld (ix+OBJECT_STRUCT_PTR),e
	ld (ix+OBJECT_STRUCT_PTR+1),d	
	ret

load_room_init_object_yellow_key:
	ld a,(state_yellow_key_taken)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_door_right_yellow:
	ld a,(state_yellow_key_taken)
load_room_init_object_door_right_yellow_state_set:
	cp 2
	jp z, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_door_left_yellow:
	ld a,(state_yellow_key_taken)
	jr load_room_init_object_door_right_yellow_state_set

load_room_init_object_door_left_red:
	ld a,(state_red_key_taken)
	jr load_room_init_object_door_right_yellow_state_set

load_room_init_object_door_right_white:
	ld a,(state_white_key_taken)
	jr load_room_init_object_door_right_yellow_state_set

load_room_init_object_door_right_green:
	ld a,(state_green_key_taken)
	jr load_room_init_object_door_right_yellow_state_set

load_room_init_object_door_right_blue:
	ld a,(state_backyard_key_taken)
	jr load_room_init_object_door_right_yellow_state_set

load_room_init_object_door_prison_passage:
	ld a,(state_skeleton_key_taken)
	jr load_room_init_object_door_right_yellow_state_set

load_room_init_object_door_prison_franky:
	ld a,(state_franky_key_taken)
	jr load_room_init_object_door_right_yellow_state_set

load_room_init_object_door_vampire1:
	ld a,(state_vampire1_state)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_door_vampire2:
	ld a,(state_vampire2_state)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_door_vampire3:
	ld a,(state_vampire3_state)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_door_vampire4:
	ld a,(state_vampire4_state)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_door_prison_entrance:
	ld a,(state_prison_door_entrance)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

; load_room_init_object_gun:
; 	ld a,(state_gun_taken)
; load_room_init_object_takeable:
; 	or a
; 	jr nz, load_room_init_object_already_taken
; 	jp load_room_init_object_ptr_set

load_room_init_object_gun_key:
	ld a,(state_gun_taken)
load_room_init_object_takeable:
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_green_key:
	ld a,(state_green_key_taken)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_letter3:
	ld a,(state_letter3_taken)
	jr load_room_init_object_takeable

load_room_init_object_lamp:
	ld a,(state_lamp_taken)
	jr load_room_init_object_takeable

load_room_init_object_oil:
	ld a,(state_oil_taken)
	jr load_room_init_object_takeable

load_room_init_object_heart1:
	ld a,(state_heart1_taken)
	jr load_room_init_object_takeable

load_room_init_object_heart2:
	ld a,(state_heart2_taken)
	jr load_room_init_object_takeable

load_room_init_object_heart3:
	ld a,(state_heart3_taken)
	jr load_room_init_object_takeable

load_room_init_object_heart4:
	ld a,(state_heart4_taken)
	jr load_room_init_object_takeable

load_room_init_object_book:
	ld a,(state_book_taken)
	jr load_room_init_object_takeable

load_room_init_painting_safe_right:
	ld a,(state_painting_safe)
	or a
	jp z,load_room_init_object_ptr_set
	; replace the painting by a safe:
	ld (ix),OBJECT_TYPE_SAFE_RIGHT
	ld de,object_safe_right_zx0
	jp load_room_init_object_ptr_set

load_room_init_object_ritual_door:
	ld a,(state_ritual_room_state)
	cp 2
	jp p, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_diary1:
	ld a,(state_diary1_taken)
	jr load_room_init_object_takeable

load_room_init_object_diary2:
	ld a,(state_diary2_taken)
	jr load_room_init_object_takeable

load_room_init_object_diary3:
	ld a,(state_diary3_taken)
	jr load_room_init_object_takeable

load_room_init_object_lab_notes:
	ld a,(state_lab_notes_taken)
	jr load_room_init_object_takeable

load_room_init_object_hammer:
	ld a,(state_hammer_taken)
	jr load_room_init_object_takeable


load_room_init_object_crate_garlic1:
	ld a,(state_crate_garlic1)
	or a
	jp z,load_room_init_object_ptr_set
	dec a
	jr nz,load_room_init_object_already_taken
	ld (ix),OBJECT_TYPE_GARLIC1
	ld de,object_garlic_zx0
	jp load_room_init_object_ptr_set

load_room_init_object_crate_garlic2:
	ld a,(state_crate_garlic2)
	or a
	jp z,load_room_init_object_ptr_set
	dec a
	jr nz,load_room_init_object_already_taken
	ld (ix),OBJECT_TYPE_GARLIC2
	ld de,object_garlic_zx0
	jp load_room_init_object_ptr_set

load_room_init_object_crate_garlic3:
	ld a,(state_crate_garlic3)
	or a
	jp z,load_room_init_object_ptr_set
	dec a
	jr nz,load_room_init_object_already_taken
	ld (ix),OBJECT_TYPE_GARLIC3
	ld de,object_garlic_zx0
	jp load_room_init_object_ptr_set

load_room_init_object_crate_stake1:
	ld a,(state_crate_stake1)
	or a
	jp z,load_room_init_object_ptr_set
	dec a
	jr nz,load_room_init_object_already_taken
	ld (ix),OBJECT_TYPE_STAKE1
	ld de,object_stake_zx0
	jp load_room_init_object_ptr_set

load_room_init_object_crate_stake2:
	ld a,(state_crate_stake2)
	or a
	jp z,load_room_init_object_ptr_set
	dec a
	jr nz,load_room_init_object_already_taken
	ld (ix),OBJECT_TYPE_STAKE2
	ld de,object_stake_zx0
	jp load_room_init_object_ptr_set

load_room_init_object_crate_stake3:
	ld a,(state_crate_stake3)
	or a
	jp z,load_room_init_object_ptr_set
	dec a
	jr nz,load_room_init_object_already_taken
	ld (ix),OBJECT_TYPE_STAKE3
	ld de,object_stake_zx0
	jp load_room_init_object_ptr_set

load_room_init_object_luggage:
	ld a,(state_luggage_taken)
	jp load_room_init_object_takeable

load_room_init_object_newspaper:
	ld a,(state_newspaper_taken)
	jp load_room_init_object_takeable

load_room_init_object_already_taken:
load_room_init_object_already_broken:
	push hl
		ld hl,n_objects
		dec (hl)
	pop hl
	pop af ; restore the stack
	pop af
	jp load_room_object_loop_skip

load_room_init_object_beggar:
	ld a,(state_beggar)
	cp 3  ; beggar dead
	jp nz,load_room_init_object_ptr_set
	ld de,object_beggar_dead_zx0
	jp load_room_init_object_ptr_set


load_room_init_object_coffin1:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	jp m,load_room_init_object_ptr_set
	ld a,(state_current_room)
	cp 35  ; vampire 1
	jr z,load_room_init_object_coffin1_vampire1
	cp 45  ; vampire 2
	jr z,load_room_init_object_coffin1_vampire2
	; vampire 3 (Lucy, her coffin is always empty in the EX version)
; 	ld a,(state_vampire3_state)
; 	cp 2  ; vampire dead
; 	jp z, load_room_init_object_ptr_set
	jp load_room_init_object_ptr_set
load_room_init_object_coffin1_vampire:
	SETMEGAROMPAGE_A000 OBJECTS_PAGE2
	ld de,coffin_vampire_1_zx0
	jp load_room_init_object_ptr_set
load_room_init_object_coffin1_vampire1:
	ld a,(state_vampire1_state)
	cp 2  ; vampire dead
	jp z, load_room_init_object_ptr_set
	jr load_room_init_object_coffin1_vampire
load_room_init_object_coffin1_vampire2:
	ld a,(state_vampire2_state)
	cp 2  ; vampire dead
	jp z, load_room_init_object_ptr_set
	jr load_room_init_object_coffin1_vampire


load_room_init_object_coffin2:
	ld a,5
	ld (room_enemy_type),a
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	jp m,load_room_init_object_ptr_set
	ld a,(state_current_room)
	cp 35  ; vampire 1
	jr z,load_room_init_object_coffin2_vampire1
	cp 45  ; vampire 2
	jr z,load_room_init_object_coffin2_vampire2
	; vampire 3 (Lucy, her coffin is always empty in the EX version)
; 	ld a,(state_vampire3_state)
; 	cp 2  ; vampire dead
; 	jp z, load_room_init_object_ptr_set
	jp load_room_init_object_ptr_set
load_room_init_object_coffin2_vampire:
	SETMEGAROMPAGE_A000 OBJECTS_PAGE2
	ld de,coffin_vampire_2_zx0
	jp load_room_init_object_ptr_set
load_room_init_object_coffin2_vampire1:
	ld a,(state_vampire1_state)
	cp 2  ; vampire dead
	jp z, load_room_init_object_ptr_set
	jr load_room_init_object_coffin2_vampire
load_room_init_object_coffin2_vampire2:
	ld a,(state_vampire2_state)
	cp 2  ; vampire dead
	jp z, load_room_init_object_ptr_set
	jr load_room_init_object_coffin2_vampire

load_room_init_object_choffeur:
	ld a,(state_choffeur_store)
	or a
	jp z, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_torn_note:
	ld a,(state_torn_note_taken)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_cauldron:
	ld a,(state_cauldron_taken)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_object_mirror_nw:
	push hl
		ld hl,state_mirrors_broken
		ld a,(state_current_room)
		cp 18
		jr z,load_room_init_object_mirror_nw_room18
		cp 51
		jr z,load_room_init_object_mirror_nw_room51
		cp 55
		jr z,load_room_init_object_mirror_nw_room55
		cp 57
		jr z,load_room_init_object_mirror_nw_room57
load_room_init_object_mirror_nw_room59:
		bit 5,(hl)
		jr load_room_init_object_mirror_nw_entry_point
load_room_init_object_mirror_nw_room18:
		bit 1,(hl)
		jr load_room_init_object_mirror_nw_entry_point
load_room_init_object_mirror_nw_room51:
		bit 2,(hl)
		jr load_room_init_object_mirror_nw_entry_point
load_room_init_object_mirror_nw_room55:
		bit 3,(hl)
		jr load_room_init_object_mirror_nw_entry_point
load_room_init_object_mirror_nw_room57:
		bit 4,(hl)
		jr load_room_init_object_mirror_nw_entry_point

load_room_init_object_mirror_ne:
	ld a,(state_mirrors_broken)
	bit 0,a
	push hl  ; just to compensate from the push hl in the "nw" mirror
load_room_init_object_mirror_nw_entry_point:
	pop hl
	jp nz,load_room_init_object_already_broken
	jp load_room_init_object_ptr_set


load_room_init_object_chest_reveal:
	ld a,(state_ritual_room_state)
	cp 3
	jp nz,load_room_init_object_already_taken
	jp load_room_init_object_ptr_set


load_room_init_arrow_shooter:
	ld a,OBJECT_TYPE_ARROW - (OBJECT_TYPE_FIRST_ENEMY-1)
	ld (room_enemy_type),a
	jp load_room_init_object_ptr_set


load_room_init_skeleton_boss:
	ld (ix+OBJECT_STRUCT_STATE),0
	ld (ix+OBJECT_STRUCT_STATE_TIMER),0
	ld (ix+OBJECT_STRUCT_FRAME),#ff  ; force redraw
	ld a,(state_skeleton_miniboss)
	or a
	jr z,load_room_init_skeleton_boss_init  ; not killed
	ld a,(state_skeleton_key_taken)
	or a
	jr z,load_room_init_skeleton_boss_key
	jp load_room_init_object_already_taken
load_room_init_skeleton_boss_key:
	; spawn key instead:
	ld (ix),OBJECT_TYPE_SKELETON_KEY
	ld de,object_skeleton_key_zx0
	jp load_room_init_object_ptr_set

load_room_init_skeleton_boss_init:
	ld a,9
	ld (room_enemy_type),a
	jp load_room_init_object_ptr_set


load_room_init_franky:
	ld (ix+OBJECT_STRUCT_STATE),0
	ld (ix+OBJECT_STRUCT_STATE_TIMER),0
	ld (ix+OBJECT_STRUCT_FRAME),#ff  ; force redraw
	ld a,(state_franky_boss)
	or a
	jr z,load_room_init_franky_init  ; not killed
	dec a
	jr z,load_room_init_franky_note
	jp load_room_init_object_already_taken
load_room_init_franky_note:
	; spawn note instead:
	ld (ix),OBJECT_TYPE_FRANKY_NOTE
	ld de,object_franky_note_zx0
	jp load_room_init_object_ptr_set

load_room_init_franky_init:
	xor a
	ld (miniboss_hit),a
	ld a,10
	ld (room_enemy_type),a
	ld a,16  ; franky hitpoints
	ld (miniboss_hitpoints),a
	jp load_room_init_object_ptr_set


load_room_init_object_open_grave:
	ld a,(state_quincey_grave)
	or a
	jp z, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set


load_room_init_object_clay:
	ld a,(state_quincey_grave)
	or a
	jp z, load_room_init_object_already_taken
	ld a,(state_clay_taken)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_puzzle_box:
	ld a,(state_puzzle_box_taken)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set

load_room_init_vlad_diary:
	ld a,(state_vlad_diary_taken)
	or a
	jp nz, load_room_init_object_already_taken
	jp load_room_init_object_ptr_set


;-----------------------------------------------
; input:
; - ix: object ptr
load_room_init_enemy:
	; store the enemy type:
	ld a,(ix)
	sub OBJECT_TYPE_FIRST_ENEMY-1
	ld (room_enemy_type),a

	; load the additional enemy data:
	ld a,(hl)
	inc hl
	ld (ix+OBJECT_STRUCT_STATE),a
	ld a,(hl)
	inc hl
	ld (ix+OBJECT_STRUCT_STATE_TIMER),a  ; state timer

load_room_init_enemy_spawn_entry_point:
	; screen_x = room_x + x*2 - y*2 - 1
	; screen_y = room_y + x + y - z - 1
	ld a,(room_x)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)  ; note: at this point, coordinates are still in "tiles", we have not yet converted them to pixels
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	sub (ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	sub (ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	dec a
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_X),a
	ld a,(room_y)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld b,a
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Z)
	rrca
	rrca
	rrca
	and #1f
	neg
	add a,b
	dec a
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_Y),a

	ld (ix+OBJECT_STRUCT_PIXEL_ISO_W),8
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_H),8
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z_H),8
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_W),3
	ld (ix+OBJECT_STRUCT_SCREEN_TILE_H),2
	ld (ix+OBJECT_STRUCT_FRAME),0

	ld (ix+OBJECT_STRUCT_PTR),enemy_data_buffer%256
	ld (ix+OBJECT_STRUCT_PTR+1),enemy_data_buffer/256

	// Convert coordinates from tiles to pixels:
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,a
	add a,a
	add a,a
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,a
	add a,a
	add a,a
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	ret


;-----------------------------------------------
decompress_enemy_skeleton_boss:
	; Load mini-boss data:
	push hl
		; sprites:
		SETMEGAROMPAGE_A000 SPRITES_PAGE
		ld hl,skeleton_boss_sprites_zx0
		ld de,enemy_data_buffer
		call dzx0_standard
		ld hl,enemy_data_buffer
		ld de,SPRTBL2+(7+5)*32
		ld bc,16*32  ; 16 sprites
		call fast_LDIRVM
		; frames:
		SETMEGAROMPAGE_A000 OBJECTS_PAGE3
		ld hl,skeleton_boss_frames_zx0	
		ld de,enemy_data_buffer
		call dzx0_standard
	pop hl
	jp load_room_enemy_loop_done


;-----------------------------------------------
decompress_enemy_franky_boss:
	; Load mini-boss data:
	push hl
		; sprites:
		SETMEGAROMPAGE_A000 OBJECTS_PAGE3
		ld hl,franky_boss_sprites_zx0
		ld de,enemy_data_buffer
		call dzx0_standard
		ld hl,enemy_data_buffer
		ld de,SPRTBL2+(7+5)*32
		ld bc,24*32  ; 24 sprites
		call fast_LDIRVM
		; frames:
		ld hl,franky_boss_frames_zx0	
		ld de,enemy_data_buffer
		call dzx0_standard
	pop hl
	jp load_room_enemy_loop_done


;-----------------------------------------------
decompress_enemy_rat:
	push hl
		ld hl,enemy_rat_zx0
		jr create_enemy_frames

decompress_enemy_spider:
	push hl
		ld hl,enemy_spider_zx0
		jr create_enemy_frames

decompress_enemy_slime:
	push hl
		ld hl,enemy_slime_zx0
		jr create_enemy_frames

decompress_enemy_bat:
	push hl
		ld hl,enemy_bat_zx0
		jr create_enemy_frames

decompress_enemy_snake:
	push hl
		ld hl,snake_already_attacking  ; initialize snake global state
		ld (hl),0
		ld hl,enemy_snake_zx0
		jr create_enemy_frames

decompress_enemy_arrow:
	push hl
		ld hl,enemy_arrow_zx0
; 		jr create_enemy_frames


;-----------------------------------------------
create_enemy_frames:
		ld de,buffer1024
		call dzx0_standard

		; north east (frame 1):
		ld hl,buffer1024+96*2
		ld de,enemy_data_buffer
		call create_enemy_frames_flip
		ld hl,enemy_data_buffer
		ld de,enemy_data_buffer+96
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites
		; north east (frame 2):
		ld hl,buffer1024+96*3
		ld de,enemy_data_buffer+96*4
		call create_enemy_frames_flip
		ld hl,enemy_data_buffer+96*4
		ld de,enemy_data_buffer+96*5
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites

		; south east (frame 1):
		ld hl,buffer1024
		ld de,enemy_data_buffer+96*8
		ld bc,96
		ldir
		ld hl,enemy_data_buffer+96*8
		ld de,enemy_data_buffer+96*9
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites
		; south east (frame 2):
		ld hl,buffer1024+96
		ld de,enemy_data_buffer+96*12
		ld bc,96
		ldir
		ld hl,enemy_data_buffer+96*12
		ld de,enemy_data_buffer+96*13
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites

		; south west (frame 1):
		ld hl,buffer1024
		ld de,enemy_data_buffer+96*16
		call create_enemy_frames_flip
		ld hl,enemy_data_buffer+96*16
		ld de,enemy_data_buffer+96*17
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites
		; south west (frame 2):
		ld hl,buffer1024+96
		ld de,enemy_data_buffer+96*20
		call create_enemy_frames_flip
		ld hl,enemy_data_buffer+96*20
		ld de,enemy_data_buffer+96*21
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites

		; north west (frame 1):
		ld hl,buffer1024+96*2
		ld de,enemy_data_buffer+96*24
		ld bc,96
		ldir
		ld hl,enemy_data_buffer+96*24
		ld de,enemy_data_buffer+96*25
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites
		; north west (frame 2):
		ld hl,buffer1024+96*3
		ld de,enemy_data_buffer+96*28
		ld bc,96
		ldir
		ld hl,enemy_data_buffer+96*28
		ld de,enemy_data_buffer+96*29
		call create_enemy_frames_shift ; this creates the +2, +4 and +6 sprites
	pop hl
	jp load_room_enemy_loop_done


create_enemy_frames_flip_c_into_a:
	push bc
		ld b,8
		xor a
create_enemy_frames_flip_c_into_a_loop:
		rr c
		rla
		djnz create_enemy_frames_flip_c_into_a_loop
	pop bc
	ret


; hl: source
; de: target
create_enemy_frames_flip:
	push hl
		; column 1 is column 2 flipped:
		ld bc,32
		add hl,bc
		ld b,c  ; b = 32
create_enemy_frames_flip_column1_loop:
		ld c,(hl)
		call create_enemy_frames_flip_c_into_a
		ld (de),a
		inc hl
		inc de
		djnz create_enemy_frames_flip_column1_loop
	pop hl

	; column 2 is column 1 flipped:
	ld b,32
create_enemy_frames_flip_column2_loop:
	ld c,(hl)
	call create_enemy_frames_flip_c_into_a
	ld (de),a
	inc hl
	inc de
	djnz create_enemy_frames_flip_column2_loop

	; column 3 is empty:
	ld b,16
	ex de,hl
create_enemy_frames_flip_column3_loop:
	ld (hl),#ff
	inc hl
	ld (hl),0
	inc hl
	djnz create_enemy_frames_flip_column3_loop
	ret


create_enemy_frames_shift:
	; Call the function 3 times to create the 3 shifted versions:
	call create_enemy_frames_shift_internal
	call create_enemy_frames_shift_internal
create_enemy_frames_shift_internal:
	ld b,16
create_enemy_frames_shift_internal_loop:
	push bc
		; mask:
		push hl
		push de
			push de
				ld de,32
				ld a,(hl)
				add hl,de
				ld b,(hl)
				add hl,de
				ld c,(hl)
				srl a
				rr b
				rr c
				or #80
				srl a
				rr b
				rr c
				or #80
			pop hl
			ld (hl),a
			add hl,de
			ld (hl),b
			add hl,de
			ld (hl),c
		pop de
		pop hl
		inc de
		inc hl
		; pattern:
		push hl
		push de
			push de
				ld de,32
				ld a,(hl)
				add hl,de
				ld b,(hl)
				add hl,de
				ld c,(hl)
				srl a
				rr b
				rr c
				srl a
				rr b
				rr c
			pop hl
			ld (hl),a
			add hl,de
			ld (hl),b
			add hl,de
			ld (hl),c
		pop de
		pop hl
		inc de
		inc hl
	pop bc
	djnz create_enemy_frames_shift_internal_loop
 	ld bc,64
 	add hl,bc
 	ex de,hl
 		add hl,bc
 	ex de,hl
	ret


;-----------------------------------------------
spawn_global_items:
	SETMEGAROMPAGE_A000 OBJECTS_PAGE1
	ld hl,state_candle1_position
	ld a,(state_current_room)
	cp (hl)
	call z,spawn_global_items_candle1
	ld hl,state_candle2_position
	ld a,(state_current_room)
	cp (hl)
	call z,spawn_global_items_candle2
	ld hl,state_candle3_position
	ld a,(state_current_room)
	cp (hl)
	call z,spawn_global_items_candle3
	ret


spawn_global_items_candle1:
	push hl
		call find_new_object_ptr
		ld (ix),OBJECT_TYPE_CANDLE1
spawn_global_items_candle_entry_point:
		ld de,object_candle_zx0
	pop hl
	inc hl
	ld a,(hl)
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
	inc hl
	ld a,(hl)
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	inc hl
	ld a,(hl)
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),a
	jp load_room_init_object_ptr_set


spawn_global_items_candle2:
	push hl
		call find_new_object_ptr
		ld (ix),OBJECT_TYPE_CANDLE2
		jr spawn_global_items_candle_entry_point


spawn_global_items_candle3:
	push hl
		call find_new_object_ptr
		ld (ix),OBJECT_TYPE_CANDLE3
		jr spawn_global_items_candle_entry_point
