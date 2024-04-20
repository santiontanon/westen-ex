vlad_ritual_cutscene_sprite_buffer_ptr:  equ enemy_data_buffer


;-----------------------------------------------
vlad_ritual_cutscene_page_changed:
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

	call play_music_ritual_cutscene

	; decompress family sprites:
	SETMEGAROMPAGE_A000 SPRITES_PAGE
	ld hl,lucy_cutscene_sprites_zx0
	ld de,lucy_cutscene_sprite_buffer_ptr
	push de
		call dzx0_standard
	pop hl
	ld de,SPRTBL2+7*32  ; do not overwrite the player or hud sprites
	ld bc,N_LUCY_CUTSCENE_SPRITES*32  ; there are N_LUCY_CUTSCENE_SPRITES sprites needed for the family members
	call fast_LDIRVM

	; make a copy in RAM that we can edit:
	ld hl,lucy_ritual_sprites_attributes_ROM
	ld de,vlad_ritual_cutscene_sprite_buffer_ptr + N_LUCY_CUTSCENE_SPRITES*32
	ld bc,5*4
	ldir

	ld hl,vlad_ritual_cutscene_sprite_buffer_ptr + N_LUCY_CUTSCENE_SPRITES*32
	ld de,SPRATR2
	ld bc,5*4
	call fast_LDIRVM

	call enable_VDP_output

	ld c,2
	call state_intro_pause

	; lucy talks:
    ld a,31*8
    ld bc,TEXT_VLAD_RITUAL_CUTSCENE1
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_VLAD_RITUAL_CUTSCENE2
    ld de,CHRTBL2 + (21*32 + 5)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_VLAD_RITUAL_CUTSCENE3
    ld de,CHRTBL2 + (21*32 + 7)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

	ld c,2
	call state_intro_pause

	; teleport back to the previous room:
	ld a,84
	ld (state_current_room),a
	ld hl,map6_zx0
	ld de,3*256+4
	call teleport_player_to_room
	call play_music_ingame_subbasement

	; messages:
	ld bc, TEXT_VLAD_RITUAL_MSG1
	call queue_hud_message
	ld bc, TEXT_VLAD_RITUAL_MSG2
	call queue_hud_message
	ld bc, TEXT_VLAD_RITUAL_MSG3
	call queue_hud_message

	jp state_game

