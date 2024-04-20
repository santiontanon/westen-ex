lucy_cutscene_sprite_buffer_ptr:  equ enemy_data_buffer


;-----------------------------------------------
lucy_cutscene_page_changed:
	; clear HUD:
	ld hl,CLRTBL2 + SCREEN_HEIGHT*32*8
	ld bc,5*256 + 32
	call clear_rectangle_bitmap_mode
	ld hl,CLRTBL2 + (SCREEN_HEIGHT - 2)*32*8
	ld bc,2*256 + 10
	call clear_rectangle_bitmap_mode
	ld hl,CLRTBL2 + (SCREEN_HEIGHT - 2)*32*8 + 20*8
	ld bc,2*256 + 12
	call clear_rectangle_bitmap_mode

	; replace player sprites by family sprites:
	call clearAllTheSprites

	call play_music_lucy_cutscene

; 	; decompress family sprites:
	SETMEGAROMPAGE_A000 SPRITES_PAGE
	ld hl,lucy_cutscene_sprites_zx0
	ld de,lucy_cutscene_sprite_buffer_ptr
	push de
		call dzx0_standard
	pop hl
	ld de,SPRTBL2+7*32  ; do not overwrite the player or hud sprites
	ld bc,N_LUCY_CUTSCENE_SPRITES*32  ; there are N_LUCY_CUTSCENE_SPRITES sprites needed for the family members
	call fast_LDIRVM

; 	; make a copy in RAM that we can edit:
	ld hl,lucy_sprites_attributes_ROM
	ld de,lucy_cutscene_sprite_buffer_ptr + N_LUCY_CUTSCENE_SPRITES*32
	ld bc,5*4
	ldir

	ld hl,lucy_cutscene_sprite_buffer_ptr + N_LUCY_CUTSCENE_SPRITES*32
	ld de,SPRATR2
	ld bc,5*4
	call fast_LDIRVM

	; make vampire door disappear:
	ld a,OBJECT_TYPE_DOOR_VAMPIRE3
	call find_room_object
	call z,remove_room_object

	call enable_VDP_output

	ld c,1
	call state_intro_pause

	; close door:
	call find_new_object_ptr
	ld (ix),OBJECT_TYPE_DOOR_VAMPIRE3
	ld de,object_door_vampire_zx0
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),12
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),2
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),0
	call load_room_init_object_ptr_set
	ld e,(ix+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(ix+OBJECT_STRUCT_SCREEN_TILE_Y)
	push de
		call update_object_drawing_order_n_times
	pop de	
	ld bc,#0502
	call render_room_rectangle_safe
	ld hl,SFX_door_open
	call play_SFX_with_high_priority

	ld c,1
	call state_intro_pause

	; lucy walks sw:
	ld ix,lucy_cutscene_sprite_buffer_ptr + N_LUCY_CUTSCENE_SPRITES*32  ; ptr to the beginning of Lucy's attributes
	ld a,44
lucy_cutscene_lucy_walk_sw_loop:
	push af
		halt
		halt
		; dec x:
		call cutscene_dec_vampire_x
		bit 0,a
		call z,cutscene_inc_vampire_y
		; walk frame:
		srl a
		srl a
		and #03
		ld hl,walk_animation_sequence
		ADD_HL_A_VIA_BC
		ld a,(hl)
		ld b,a
		add a,a  ; *2
		add a,a  ; *4
		add a,b  ; *5
		add a,a  
		add a,a  ; *5*4
		add a,28
		ld (ix+2),a
		add a,4
		ld (ix+4+2),a
		add a,4
		ld (ix+8+2),a
		add a,4
		ld (ix+12+2),a
		add a,4
		ld (ix+16+2),a
		; copy lucy's attributes:
		push ix
		pop hl
		ld de,SPRATR2
		ld bc,5*4
		call fast_LDIRVM
	pop af
	dec a
	jr nz,lucy_cutscene_lucy_walk_sw_loop

	; lucy walks nw (climbing stairs until the altar):
	ld a,74
	call lucy_cutscene_lucy_walk_nw_loop

	ld c,1
	call state_intro_pause

	; lucy talks:
    ld a,31*8
    ld bc,TEXT_LUCY_CUTSCENE1
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_LUCY_CUTSCENE2
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_LUCY_CUTSCENE3
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_LUCY_CUTSCENE4
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_LUCY_CUTSCENE5
    ld de,CHRTBL2 + (21*32 + 8)*8 
    push de
	    ld iyl,COLOR_GREEN*16
		call draw_text_from_bank_multilingual

	    ld a,31*8
	    ld bc,TEXT_LUCY_CUTSCENE6
	    ld de,CHRTBL2 + (22*32 + 8)*8 
	    ld iyl,COLOR_GREEN*16
		call draw_text_from_bank_multilingual

    	ld c,10
    	call state_intro_pause
    pop hl
	ld bc,#021f
	call clear_rectangle_bitmap_mode

	; passage opens: (move altar to the right, and make stairs appear)
	call open_chapel_altar

	ld c,2
	call state_intro_pause

	; lucy advances nw:
	ld ix,lucy_cutscene_sprite_buffer_ptr + N_LUCY_CUTSCENE_SPRITES*32
	ld a,8
	call lucy_cutscene_lucy_walk_nw_loop

	; lucy disappears:
	xor a
	ld hl,SPRATR2
	ld bc,5*4
	call fast_FILVRM
	ld c,2
	call state_intro_pause

	; passage closes:
	call close_chapel_altar
	ld c,2
	call state_intro_pause

	call play_music_ingame_cellar15

	; restore the game screen and keep playing:
	call disable_VDP_output
		call clearAllTheSprites
		call draw_hud
		ld c,TIME_LUCY_ENTERS_SUBBASEMENT
		call update_state_time_day_if_needed	
		jp draw_player


;-----------------------------------------------
lucy_cutscene_lucy_walk_nw_loop:
	push af
		halt
		halt
		; dec x:
		call cutscene_dec_vampire_x
		bit 0,a
		call z,cutscene_dec_vampire_y
		; walk frame:
		srl a
		srl a
		and #03
		ld hl,walk_animation_sequence
		ADD_HL_A_VIA_BC
		ld a,(hl)
		ld b,a
		add a,a  ; *2
		add a,a  ; *4
		add a,b  ; *5
		add a,a  
		add a,a  ; *5*4
		add a,28 + 20*3
		ld (ix+2),a
		add a,4
		ld (ix+4+2),a
		add a,4
		ld (ix+8+2),a
		add a,4
		ld (ix+12+2),a
		add a,4
		ld (ix+16+2),a
		; copy lucy's attributes:
		push ix
		pop hl
		ld de,SPRATR2
		ld bc,5*4
		call fast_LDIRVM
	pop af

	cp 38
	call z,cutscene_vampire_up_step
	cp 30
	call z,cutscene_vampire_up_step

	dec a
	jr nz,lucy_cutscene_lucy_walk_nw_loop
	ret


;-----------------------------------------------
cutscene_vampire_up_step:
	call cutscene_dec_vampire_y
	call cutscene_dec_vampire_y
	call cutscene_dec_vampire_y
	jp cutscene_dec_vampire_y


;-----------------------------------------------
open_chapel_altar:
	push af
		ld hl,SFX_door_open
		call play_SFX_with_high_priority
	pop af
open_chapel_altar_no_sfx:
	; make stairs appear:
	push af
		SETMEGAROMPAGE_A000 OBJECTS_PAGE2
	pop af
	call find_new_object_ptr
	ld (ix),OBJECT_TYPE_SECRET_STAIRCASE
	ld de,object_secret_staircase_zx0
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),2
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),8
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),8
	call load_room_init_object_ptr_set

	; move altar:
	ld a,OBJECT_TYPE_ALTAR
	call find_room_object
; 	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
; 	add a,-4
; 	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),52
	push ix
	pop iy
	call update_enemy_screen_coordinates
	ld e,(ix+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(ix+OBJECT_STRUCT_SCREEN_TILE_Y)
	dec e
	dec e
	ld bc,#0506
	call render_room_rectangle_safe

	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	ret z  ; If we are still un Lucy's cutscene, do not create the collider!

	; create the collider to teleport player to subbasement:
	ld hl,n_collision_objects
	ld b,(hl)
	ld iy,collision_objects
	ld de,OBJECT_STRUCT_SIZE
open_chapel_altar_collider_loop:
	add iy,de
	djnz open_chapel_altar_collider_loop
	inc (hl)
	ld (iy),OBJECT_TYPE_COLLIDER_EVENT
	ld (iy+OBJECT_STRUCT_STATE), COLLIDER_EVENT_ENTER_SUBBASEMENT
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X), 16
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y), 64
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z), 0
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W), 12
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H), 12
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H), 80
	ret



;-----------------------------------------------
close_chapel_altar:
	; make stairs disappear:
	ld a,OBJECT_TYPE_SECRET_STAIRCASE
	call find_room_object
	call remove_room_object

	; move altar:
	ld a,OBJECT_TYPE_ALTAR
	call find_room_object
; 	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
; 	add a,12
; 	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),60
	push ix
	pop iy
	call update_enemy_screen_coordinates
	ld e,(ix+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(ix+OBJECT_STRUCT_SCREEN_TILE_Y)
	ld bc,#0506
	call render_room_rectangle_safe
	ld hl,SFX_door_open
	jp play_SFX_with_high_priority
