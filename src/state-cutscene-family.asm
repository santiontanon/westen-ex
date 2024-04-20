family_cutscene_sprite_buffer_ptr: equ enemy_data_buffer


;-----------------------------------------------
family_cutscene_page_changed:
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

	call play_music_family_cutscene

	; decompress family sprites:
	SETMEGAROMPAGE_A000 SPRITES_PAGE
	ld hl,family_cutscene_sprites_zx0
	ld de,family_cutscene_sprite_buffer_ptr
	push de
		call dzx0_standard
	pop hl
	ld de,SPRTBL2+7*32  ; do not overwrite the player or hud sprites
	ld bc,N_FAMILY_CUTSCENE_SPRITES*32  ; there are N_FAMILY_CUTSCENE_SPRITES sprites needed for the family members
	call fast_LDIRVM

	; make a copy in RAM that we can edit:
	ld hl,family_sprites_attributes_ROM
	ld de,family_cutscene_sprite_buffer_ptr + N_FAMILY_CUTSCENE_SPRITES*32
	ld bc,(4+5+5)*4
	ldir

	ld hl,family_cutscene_sprite_buffer_ptr + N_FAMILY_CUTSCENE_SPRITES*32
	ld de,SPRATR2
	ld bc,(4+5+5)*4
	call fast_LDIRVM

	call enable_VDP_output

	ld c,1
	call state_intro_pause

	; Arthur talks:
    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE2
    ld de,CHRTBL2 + (21*32 + 4)*8 
    ld iyl,COLOR_BLUE*16
    call intro_cutscene_text

	; Lucy advances:
	ld ix,family_cutscene_sprite_buffer_ptr + N_FAMILY_CUTSCENE_SPRITES*32 + (4+5)*4  ; ptr to the beginning of Lucy's attributes
	ld a,16
family_cutscene_lucy_walk_loop:
	push af
		halt
		halt
		; inc x:
		call cutscene_inc_vampire_x
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
		add a,64
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
		ld de,SPRATR2 + (4+5)*4
		ld bc,5*4
		call fast_LDIRVM
	pop af
	dec a
	jr nz,family_cutscene_lucy_walk_loop

	; Lucy turns:
	ld (ix+2),64+15*4
	ld (ix+4+2),68+15*4
	ld (ix+8+2),72+15*4
	ld (ix+12+2),76+15*4
	ld (ix+16+2),80+15*4
	push ix
	pop hl
	ld de,SPRATR2 + (4+5)*4
	ld bc,5*4
	call fast_LDIRVM

	; Lucy talks:
    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE3
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE4
    ld de,CHRTBL2 + (21*32 + 2)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE5
    ld de,CHRTBL2 + (21*32 + 4)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE6
    ld de,CHRTBL2 + (21*32 + 1)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

	; All laugh:
    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE7A
    ld de,CHRTBL2 + (21*32 + 12)*8 
    ld iyl,COLOR_GREEN*16
	call draw_text_from_bank_multilingual
    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE7B
    ld de,CHRTBL2 + (22*32 + 16)*8 
    ld iyl,COLOR_WHITE*16
	call draw_text_from_bank_multilingual
    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE7C
    ld de,CHRTBL2 + (20*32 + 8)*8 
    ld iyl,COLOR_BLUE*16
    push de
		call draw_text_from_bank_multilingual
		ld c,4
		call state_intro_pause
	pop hl
	ld bc,#031f
	call clear_rectangle_bitmap_mode

	; Lucy talks again:
    ld a,31*8
    ld bc,TEXT_MSG_FAMILY_CUTSCENE8
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call intro_cutscene_text

	; Lucy turns into a vampire and leaves:
	ld ix,family_cutscene_sprite_buffer_ptr + N_FAMILY_CUTSCENE_SPRITES*32 + (4+5)*4  ; ptr to the beginning of Lucy's attributes
	ld a,(ix)
	add a,8
	ld (ix),a
	ld (ix+4),a
	ld (ix+4+3),COLOR_WHITE
	ld (ix+8),200
	ld (ix+12),200
	ld (ix+16),200
	push ix
	pop hl
	ld de,SPRATR2 + (4+5)*4
	push de
	push hl
		ld bc,5*4
		call fast_LDIRVM
	pop hl
	pop de
	call family_cutscene_bat_leaves

	; Arthur turns into a vampire and leaves:
	ld ix,family_cutscene_sprite_buffer_ptr + N_FAMILY_CUTSCENE_SPRITES*32  ; ptr to the beginning of Arthur's attributes
	ld a,(ix)
	add a,8
	ld (ix),a
	ld (ix+4),a
	ld (ix+4+3),COLOR_WHITE
	ld (ix+8),200
	ld (ix+12),200
	push ix
	pop hl
	ld de,SPRATR2
	push de
	push hl
		ld bc,4*4
		call fast_LDIRVM
	pop hl
	pop de
	call family_cutscene_bat_leaves

	; John turns into a vampire and leaves:
	ld ix,family_cutscene_sprite_buffer_ptr + N_FAMILY_CUTSCENE_SPRITES*32 + 4*4  ; ptr to the beginning of John's attributes
	ld a,(ix)
	add a,8
	ld (ix),a
	ld (ix+4),a
	ld (ix+4+3),COLOR_WHITE
	ld (ix+8),200
	ld (ix+12),200
	ld (ix+16),200
	push ix
	pop hl
	ld de,SPRATR2 + 4*4
	push de
	push hl
		ld bc,5*4
		call fast_LDIRVM
	pop hl
	pop de
	call family_cutscene_bat_leaves

	ld c,TIME_VAMPIRES_ARRIVE
	call update_state_time_day_if_needed	

	call play_music_ingame_house1

	; restore the game screen and keep playing:
	call disable_VDP_output
		call clearAllTheSprites
		call draw_hud
		jp draw_player


;-----------------------------------------------
family_cutscene_bat_leaves:
	; smoke:
	ld b,4
family_cutscene_bat_leaves_smoke_loop:
	push bc
		ld (ix+2),144
		ld (ix+4+2),148
		ld bc,2*4
		call fast_LDIRVM_preserving_ptrs

		ld b,8
		call wait_b_halts

		ld (ix+2),152
		ld (ix+4+2),156
		ld bc,2*4
		call fast_LDIRVM_preserving_ptrs

		ld b,8
		call wait_b_halts
	pop bc
	djnz family_cutscene_bat_leaves_smoke_loop

	; bat:
family_cutscene_bat_leaves_bat_loop:
	ld (ix+2),160
	ld (ix+4+2),164
	ld bc,2*4
	call fast_LDIRVM_preserving_ptrs

	ld b,4
	call wait_b_halts
	inc (ix+1)
	inc (ix+5)
	inc (ix+1)
	inc (ix+5)
	ld bc,2*4
	call fast_LDIRVM_preserving_ptrs

	ld b,4
	call wait_b_halts
	
	ld a,(ix)
	cp 56
	jr c,family_cutscene_bat_leaves_y_set1
	dec (ix)
	dec (ix+4)
	dec (ix)
	dec (ix+4)
family_cutscene_bat_leaves_y_set1:

	inc (ix+1)
	inc (ix+5)
	inc (ix+1)
	inc (ix+5)

	ld (ix+2),168
	ld (ix+4+2),172
	ld bc,2*4
	call fast_LDIRVM_preserving_ptrs

	ld b,4
	call wait_b_halts
	inc (ix+1)
	inc (ix+5)
	inc (ix+1)
	inc (ix+5)
	ld bc,2*4
	call fast_LDIRVM_preserving_ptrs

	ld b,4
	call wait_b_halts

	ld a,(ix)
	cp 56
	jr c,family_cutscene_bat_leaves_y_set2
	dec (ix)
	dec (ix+4)
	dec (ix)
	dec (ix+4)
family_cutscene_bat_leaves_y_set2:

	ld a,(ix+1)
	cp 212
	jr nc,family_cutscene_bat_leaves_done
	inc a
	ld (ix+1),a
	ld (ix+5),a
	ld (ix+1),a
	ld (ix+5),a
	jp family_cutscene_bat_leaves_bat_loop

family_cutscene_bat_leaves_done:
	ld (ix),200
	ld (ix+4),200
	ld bc,2*4
	jp fast_LDIRVM


;-----------------------------------------------
; - draws a text message, waits 4 seconds, and clears it
intro_cutscene_text:
	push de
  		call draw_text_from_bank_multilingual
    	ld c,6
    	call state_intro_pause
    pop hl
	ld bc,#011f
	jp clear_rectangle_bitmap_mode


;-----------------------------------------------
cutscene_inc_vampire_x:
	inc (ix+1)
	inc (ix+4+1)
	inc (ix+8+1)
	inc (ix+12+1)
	inc (ix+16+1)
	ret


;-----------------------------------------------
cutscene_dec_vampire_x:
	dec (ix+1)
	dec (ix+4+1)
	dec (ix+8+1)
	dec (ix+12+1)
	dec (ix+16+1)
	ret


;-----------------------------------------------
cutscene_inc_vampire_y:
	inc (ix)
	inc (ix+4)
	inc (ix+8)
	inc (ix+12)
	inc (ix+16)
	ret


;-----------------------------------------------
cutscene_dec_vampire_y:
	dec (ix)
	dec (ix+4)
	dec (ix+8)
	dec (ix+12)
	dec (ix+16)
	ret
	