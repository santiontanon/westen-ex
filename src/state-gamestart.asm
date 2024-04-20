;-----------------------------------------------
state_gamestart_page_changed:
	call play_music_game_start

	ld b,50
	call wait_b_halts

	; load object sprites:
	SETMEGAROMPAGE_A000 SPRITES_PAGE
	ld hl,object_sprites_zx0
	ld de,buffer1024
	push de
		call dzx0_standard
	pop hl
	ld de,SPRTBL2+7*32
	ld bc,5*32  ; 5 sprites for regular objects
	call fast_LDIRVM

	; copy inventory sprite pattern
; 	SETMEGAROMPAGE_A000 SPRITES_PAGE
	ld hl,inventory_pointer_sprite
	ld de,SPRTBL2+6*32
	ld bc,32
	call fast_LDIRVM

	call init_game_variables

    call clearScreenLeftToRight_bitmap

    ; wait for intro song to end:
state_gamestart_wait_for_song_loop:
    ld a,(wyz_interr)
    or a
    jr nz,state_gamestart_wait_for_song_loop

    call ask_whether_to_continue_or_not
    jr z,state_gamestart_no_load_game

    ; Load saved game:
	ld hl,RAM_save
	ld de,game_state_start
	ld bc,game_state_end - game_state_start
	ldir

	ld a,(state_current_room)
	push af
		ld e,a
		call get_map_ptr_from_room_number
		ld a,e
		and #0f
		ld e,a
		ld d,0
	pop af
	ld (state_current_room),a
	call teleport_player_to_room	
    jp state_game


state_gamestart_no_load_game:
	ld hl,state_white_key_taken
	ld (hl),1

	; initial objects:
	ld hl,inventory
	ld (hl),INVENTORY_WHITE_KEY
	inc hl
	ld (hl),INVENTORY_RED_KEY_H1

	; Regular game start (original version):
; 	ld hl,map1_zx0
; 	ld de,0 + 0*256  ; e: room, d: door
; 	xor a
; 	ld (state_current_room),a
; 	call teleport_player_to_room	
; 	ld hl,player_iso_x
; 	ld (hl),8*8
; 	inc hl
; 	ld (hl),12*8
; 	ld hl,player_direction
; 	ld (hl),1

	ld bc, TEXT_GAME_START_MESSSAGE1
	call queue_hud_message
	ld bc, TEXT_GAME_START_MESSSAGE2
	call queue_hud_message
	ld bc, TEXT_GAME_START_MESSSAGE3
	call queue_hud_message

	; Regular game start (EX version):
	ld hl,map5_zx0
	ld de,0 + 0*256  ; e: room, d: door
	ld a,64
	ld (state_current_room),a
	call teleport_player_to_room	
	ld hl,player_iso_x
	ld (hl),5*8
	inc hl
	ld (hl),6*8
	ld hl,player_direction
	ld (hl),4

	jp state_game


;-----------------------------------------------
init_game_variables:
	SETMEGAROMPAGE_A000 SPRITES_PAGE
	ld hl,player_sprite_attributes_ROM
	ld de,player_sprite_attributes
	ld bc,4*6+4
	ldir

	; clear variables before game start:
	ld hl,ram_to_clear_at_game_start
	ld (hl),0
	ld de,ram_to_clear_at_game_start+1
	ld bc,(ram_to_clear_at_game_start_end - ram_to_clear_at_game_start) - 1
	ldir

	xor a
	ld (player_invulnerability),a
	ld a,INITIAL_HEALTH
	ld (player_health),a
	ld (player_max_health),a

	ld hl,candle_initial_positions
	ld de,state_candle1_position
	ld bc,12
	ldir

	; set player dimensions:
	ld hl,player_iso_w
	ld (hl),8
	inc hl
	ld (hl),8
	inc hl
	ld (hl),16	
	ret


candle_initial_positions:
    db 8, 2, 2, 32
    db 22, 4, 2, 0
    db 24, 8, 4, 0