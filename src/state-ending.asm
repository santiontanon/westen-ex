;-----------------------------------------------
state_ending_page_changed:
    ; init the stack:
    ld sp,#f380

    ld a,(isComputer50HzOr60Hz)
    or a
    ld a,5
    jr nz,state_ending_page_changed_continue
    ld a,4
state_ending_page_changed_continue:
    ld (ending_music_sync_pause),a

    call play_music_ending_1a

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

	; display Lucy sprite:
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
	ld de,SPRATR2+6*4
	ld bc,5*4
	call fast_LDIRVM


	; lucy talks:
    ld a,31*8
    ld bc,TEXT_VLAD_RITUAL_CUTSCENE1
    ld de,CHRTBL2 + (21*32 + 8)*8 
    ld iyl,COLOR_GREEN*16
    call ending_cutscene_text

    ld a,31*8
    ld bc,TEXT_VLAD_RITUAL_CUTSCENE2
    ld de,CHRTBL2 + (21*32 + 5)*8 
    ld iyl,COLOR_GREEN*16
    call ending_cutscene_text

    ld a,31*8
    ld bc,TEXT_VLAD_RITUAL_CUTSCENE3
    ld de,CHRTBL2 + (21*32 + 7)*8 
    ld iyl,COLOR_GREEN*16
    call ending_cutscene_text

	ld c,2
	call state_intro_pause

	; flash to white and show vignette 1:
	call disable_VDP_output_with_white_bg
		call clearAllTheSprites
		call set_bitmap_mode
		ld hl,ending_vignette1_zx0
		ld de, CHRTBL2
		ld ix, SPRTBL2
		ld iy, SPRATR2
		call ending_show_vignette

		; Text 
	    ld a,16*8
	    ld bc,TEXT_ENDING_VIGNETTE1_1
	    ld de,CHRTBL2 + (14*32 + 0)*8 
	    ld iyl,COLOR_GREEN*16
	    call draw_text_from_bank_multilingual

	    ld a,16*8
	    ld bc,TEXT_ENDING_VIGNETTE1_2
	    ld de,CHRTBL2 + (16*32 + 0)*8 
	    ld iyl,COLOR_GREEN*16
	    call draw_text_from_bank_multilingual

		call play_music_ending_1b
	call enable_VDP_output_with_black_bg

	ld a,(ending_music_sync_pause)
	ld c,a
	call state_intro_pause


	; flash to white and show vignette 2:
	call disable_VDP_output_with_white_bg
		; clear text:
		ld hl,CLRTBL2 + (14*32 + 0)*8 
		ld bc,#0310
		xor a
		call clear_rectangle_bitmap_mode

		ld hl,ending_vignette2_zx0
		ld de, CHRTBL2 + 11*8 + 32*8 * 7
		ld ix, SPRTBL2 + 32*9
		ld iy, SPRATR2 + 4*9
		call ending_show_vignette

		; Text 
	    ld a,16*8
	    ld bc,TEXT_ENDING_VIGNETTE2_1
	    ld de,CHRTBL2 + (19*32 + 10)*8 
	    ld iyl,COLOR_WHITE*16
	    call draw_text_from_bank_multilingual

	    ld a,16*8
	    ld bc,TEXT_ENDING_VIGNETTE2_2
	    ld de,CHRTBL2 + (21*32 + 10)*8 
	    ld iyl,COLOR_WHITE*16
	    call draw_text_from_bank_multilingual

		halt
	call enable_VDP_output_with_black_bg

	ld a,(ending_music_sync_pause)
	ld c,a
	call state_intro_pause


	; flash to white and show vignette 3:
	call disable_VDP_output_with_white_bg
		; clear text:
		ld hl,CLRTBL2 + (19*32 + 10)*8
		ld bc,#0310
		xor a
		call clear_rectangle_bitmap_mode

		ld hl,ending_vignette3_zx0
		ld de, CHRTBL2 + 22*8 + 32*8 * 14
		ld ix, SPRTBL2 + 32*20
		ld iy, SPRATR2 + 4*20
		call ending_show_vignette

		; Text 
	    ld a,16*8
	    ld bc,TEXT_ENDING_VIGNETTE3_1
	    ld de,CHRTBL2 + (10*32 + 23)*8 
	    ld iyl,COLOR_WHITE*16
	    call draw_text_from_bank_multilingual

	    ld a,16*8
	    ld bc,TEXT_ENDING_VIGNETTE3_2
	    ld de,CHRTBL2 + (12*32 + 23)*8 
	    ld iyl,COLOR_WHITE*16
	    call draw_text_from_bank_multilingual
		halt
	call enable_VDP_output_with_black_bg

	ld c,5
	call state_intro_pause	


	call disable_VDP_output
	    call clearAllTheSprites
	    call set_bitmap_mode    

	    SETMEGAROMPAGE_A000 OTHER_DATA_PAGE
		ld hl,ending_scroll_zx0
		ld de,enemy_data_buffer+1024
		call dzx0_standard

		; Draw scroll:
		ld ix,enemy_data_buffer+1024
		ld iy,13
		ld de,CHRTBL2+(1*32+0)*8
		ld bc,#030d
		ld hl,enemy_data_buffer+1024+13*3
		ld (draw_hud_chunk_tile_ptr),hl
		call draw_hud_chunk	

		call play_music_ending_2
	call enable_VDP_output

	; init variables:
	xor a
	ld (game_cycle),a
	ld hl,ending_trigger_map
	ld de,ending_trigger_map+1
	ld (hl),a
	ld bc,4
	ldir

state_ending_loop:
	ld c,1
	call wait_for_interrupt_page3

	call update_keyboard_buffers
	ld hl,game_cycle
	inc (hl)

	ld a,(ending_trigger_map)
	or a
	jr z,state_ending_load_map1
	cp 2
	jr z,state_ending_load_map2
	cp 4
	jr z,state_ending_load_map3
	cp 6
	jr z,state_ending_load_map4
state_ending_loop_continue1:
	ld hl,ending_roll_step
	ld a,(game_cycle)
	rra
	jr c,state_ending_loop_continue1a
	inc (hl)
state_ending_loop_continue1a:
	ld a,(hl)
	cp 228
	jr z,state_ending_loop_next_map
	cp 3
	jr c,state_ending_loop_continue2
	cp 22
	jr c,state_ending_unroll_scroll_step
	cp 223
	jr nc,state_ending_loop_continue2
	cp 203
	jp nc,state_ending_roll_scroll_step
state_ending_loop_continue2:
	; text:
	ld hl,ending_text_page_line_state
	ld a,(hl)
	inc (hl)
	or a
	jp z,state_ending_next_line
	cp 20*4
	jp c,state_ending_fade_in_line
	ld (hl),0 ; reset state, and next line
	ld hl,ending_text_page_line
	inc (hl)
state_ending_loop_continue3:
	jr state_ending_loop


;-----------------------------------------------
state_ending_load_map1:
	ld hl,ending_map1_zx0
state_ending_load_map1_entry_point:
	SETMEGAROMPAGE_A000 OTHER_DATA_PAGE
	ld de,enemy_data_buffer+1024+256 ; leave space for the scroll
	call dzx0_standard
state_ending_load_map1_entry_point2:
	ld hl,ending_trigger_map
	inc (hl)
	jr state_ending_loop_continue1

state_ending_load_map2:
	ld hl,ending_map2_zx0
	jr state_ending_load_map1_entry_point

state_ending_load_map3:
	ld hl,ending_map3_zx0
	jr state_ending_load_map1_entry_point

state_ending_load_map4:
	ld hl,ending_map4_zx0
	jr state_ending_load_map1_entry_point

state_ending_loop_next_map:
	ld hl,ending_roll_step
	ld (hl),0
	dec hl  ; ending_trigger_map
	inc (hl)
	ld a,(hl)
	cp 8
	jr nz,state_ending_loop_continue2
	ld (hl),0
	jr state_ending_loop_continue2

;-----------------------------------------------
; input:
; - a: next position of the scroll bottom
state_ending_unroll_scroll_step:
	; render the bottom of the scroll at CHRTBL2 + a*32*8
	push af
		ld h,a
		ld l,0  ; hl = a*32*8
		ld bc,CHRTBL2
		add hl,bc
		ex de,hl
		push de
			ld ix,enemy_data_buffer+1024+13
			ld iy,13
			ld bc,#020d
			ld hl,enemy_data_buffer+1024+13*3
			ld (draw_hud_chunk_tile_ptr),hl
			call draw_hud_chunk	
		pop hl

		ld a,(ending_trigger_map)
		dec a  ; map 1
		jp z,state_ending_unroll_scroll_step_map1
		dec a
		dec a  ; map 2
		jr z,state_ending_unroll_scroll_step_map2
		dec a
		dec a  ; map 3
		jr z,state_ending_unroll_scroll_step_map3
state_ending_unroll_scroll_step_map4:
	pop af
	cp a,7
	jp c,state_ending_loop_continue2
	cp a,17
	jp nc,state_ending_loop_continue2
	sub a,7
	; render a map row:
	; - from enemy_data_buffer+1024+256 + 12*(a-6)
	; - to: CHRTBL2 + a*32*8 + 8
	ld bc,8
	add hl,bc
	ex de,hl
	ld ix,enemy_data_buffer+1024+256
	ld bc,12
	or a
	jr z,state_ending_unroll_scroll_step_map4_loop_done
state_ending_unroll_scroll_step_map4_loop:
	add ix,bc
	dec a
	jr nz,state_ending_unroll_scroll_step_map4_loop
state_ending_unroll_scroll_step_map4_loop_done:
	ld iy,12
	ld hl,enemy_data_buffer+1024+256+12*10
	ld bc,#010c
	ld (draw_hud_chunk_tile_ptr),hl
	call draw_hud_chunk	
	jp state_ending_loop_continue2

state_ending_unroll_scroll_step_map3:
	pop af
	cp a,6
	jp c,state_ending_loop_continue2
	cp a,17
	jp nc,state_ending_loop_continue2
	sub a,6
	; render a map row:
	; - from enemy_data_buffer+1024+256 + 12*(a-6)
	; - to: CHRTBL2 + a*32*8 + 16
	ld bc,16
	add hl,bc
	ex de,hl
	ld ix,enemy_data_buffer+1024+256
	ld bc,11
	or a
	jr z,state_ending_unroll_scroll_step_map3_loop_done
state_ending_unroll_scroll_step_map3_loop:
	add ix,bc
	dec a
	jr nz,state_ending_unroll_scroll_step_map3_loop
state_ending_unroll_scroll_step_map3_loop_done:
	ld iy,11
	ld hl,enemy_data_buffer+1024+256+11*11
	ld bc,#010b
	ld (draw_hud_chunk_tile_ptr),hl
	call draw_hud_chunk	
	jp state_ending_loop_continue2

state_ending_unroll_scroll_step_map2:
	pop af
	cp a,8
	jp c,state_ending_loop_continue2
	cp a,17
	jp nc,state_ending_loop_continue2
	sub a,8
	; render a map row:
	; - from enemy_data_buffer+1024+256 + 12*(a-6)
	; - to: CHRTBL2 + a*32*8 + 24
	ld bc,24
	add hl,bc
	ex de,hl
	ld ix,enemy_data_buffer+1024+256
	ld bc,8
	or a
	jr z,state_ending_unroll_scroll_step_map2_loop_done
state_ending_unroll_scroll_step_map2_loop:
	add ix,bc
	dec a
	jr nz,state_ending_unroll_scroll_step_map2_loop
state_ending_unroll_scroll_step_map2_loop_done:
	ld iy,8
	ld hl,enemy_data_buffer+1024+256+8*9
	ld bc,#0108
	ld (draw_hud_chunk_tile_ptr),hl
	call draw_hud_chunk	
	jp state_ending_loop_continue2


state_ending_unroll_scroll_step_map1:
	pop af

	cp a,6
	jp c,state_ending_loop_continue2
	cp a,18
	jp nc,state_ending_loop_continue2
	sub a,6
	; render a map row:
	; - from enemy_data_buffer+1024+256 + 12*(a-6)
	; - to: CHRTBL2 + a*32*8 + 8
	ld bc,8
	add hl,bc
	ex de,hl
	ld ix,enemy_data_buffer+1024+256
	ld bc,12
	or a
	jr z,state_ending_unroll_scroll_step_map1_loop_done
state_ending_unroll_scroll_step_map1_loop:
	add ix,bc
	dec a
	jr nz,state_ending_unroll_scroll_step_map1_loop
state_ending_unroll_scroll_step_map1_loop_done:
	ld iy,12
	ld hl,enemy_data_buffer+1024+256+12*12
	ld bc,#010c
	ld (draw_hud_chunk_tile_ptr),hl
	call draw_hud_chunk	
	jp state_ending_loop_continue2


;-----------------------------------------------
; input:
; - a: next position of the scroll bottom
state_ending_roll_scroll_step:
	; a = 225 - a
	ld c,a
	ld a,225
	sub c

	; render the bottom of the scroll at CHRTBL2 + a*32*8
	ld h,a
	ld l,0  ; hl = a*32*8
	ld bc,CHRTBL2
	add hl,bc
	ex de,hl
	push de
		ld ix,enemy_data_buffer+1024+13*2
		ld iy,13
		ld bc,#010d
		ld hl,enemy_data_buffer+1024+13*3
		ld (draw_hud_chunk_tile_ptr),hl
		call draw_hud_chunk	
	pop hl
	inc h  ; next row
	ld bc,13*8
	xor a
	call fast_FILVRM
	jp state_ending_loop_continue2


;-----------------------------------------------
state_ending_next_line:
	ld hl,ending_text_page
	ld a,(hl)
	or a
	jr z,state_ending_next_line_part1
	dec a
	jr z,state_ending_next_line_wait_part1
	dec a
	jr z,state_ending_next_line_part2
	dec a
	jr z,state_ending_next_line_wait_part2
	dec a
	jr z,state_ending_part3
	jp state_ending_loop_continue3

state_ending_next_line_wait_part2:
state_ending_next_line_wait_part1:
	ld a,(ending_text_page_line)
	cp 8
	jp nz,state_ending_loop_continue3
	inc (hl)  ; ending_text_page
	inc hl
	ld (hl),0
	; clear the text (both patterns and attributes):
	ld hl,CHRTBL2 + (32+15)*8
	ld bc,20*256+17
	xor a
	push bc
		call clear_rectangle_bitmap_mode
		ld hl,CLRTBL2 + (32+15)*8
	pop bc
	xor a
	call clear_rectangle_bitmap_mode
	jp state_ending_loop_continue3

state_ending_next_line_part1:
	ld hl,ending_text_page_line
	ld a,(hl)
	cp 18
	jr nz,state_ending_next_line_part1_not_done
state_ending_next_line_next_page:
	xor a
	ld (hl),a
	dec hl
	inc (hl)  ; next page
	dec hl
	ld (hl),a
	jp state_ending_loop_continue3
state_ending_next_line_part1_not_done:
	ld hl,ending1_lines
state_ending_next_line_part2_entry_point:
	ld e,a
	add a,a
	ADD_HL_A_VIA_BC
	ld a,e

	ld de,CHRTBL2 + (2*32 + 15)*8
    add a,d  ; move lines down
    ld d,a

    ld c,(hl)
    inc hl
    ld b,(hl)
    bit 7,b
    jp nz,state_ending_loop_continue3
;     ld iyl,COLOR_WHITE*16
	ld iyl,0  ; draw them in black at first
    ld a,17*8
    call draw_text_from_bank_multilingual
    jp state_ending_loop_continue3


state_ending_next_line_part2:
	inc hl  ; ending_text_page_line
	ld a,(hl)
	cp 18
	jr nz,state_ending_next_line_part2_not_done
	jr state_ending_next_line_next_page
state_ending_next_line_part2_not_done:
	ld hl,ending2_lines
	jr state_ending_next_line_part2_entry_point


state_ending_part3:

	call disable_VDP_output
	    call set_bitmap_mode    

		SETMEGAROMPAGE_A000 OTHER_DATA_PAGE
		ld hl,ending_the_end_zx0
		ld de,enemy_data_buffer+1024
		call dzx0_standard

		ld ix,enemy_data_buffer+1024
		ld iy,7
		ld de,CHRTBL2+(8*32+12)*8
		ld bc,#0207
		ld hl,enemy_data_buffer+1024+7*2
		ld (draw_hud_chunk_tile_ptr),hl
		call draw_hud_chunk			
	call enable_VDP_output

	ld c,1
	call state_intro_pause

	; display ending statistics:
    ld bc,TEXT_VAMPIRES_KILLED
    ld de,CHRTBL2 + (14*32 + 12)*8 
    ld a,(current_language_page)
    cp TEXT_PAGE_ES
    jr nz,state_ending_no_es_correction
    ld de,CHRTBL2 + (14*32 + 10)*8 
state_ending_no_es_correction:
    ld iyl,COLOR_GREY*16
    ld a,16*8
    call draw_text_from_bank_multilingual
    ld a,16*8
    ld bc,TEXT_SECONDARY_PROGRESS
    ld de,CHRTBL2 + (16*32 + 5)*8 
    ld iyl,COLOR_GREY*16
    call draw_text_from_bank_multilingual

    ld c,1  ; at least lucy is dead:
    ld a,(state_vampire1_state)
    cp 2
    jr nz,state_ending_stats_vampire1
    inc c
state_ending_stats_vampire1:
    ld a,(state_vampire2_state)
    cp 2
    jr nz,state_ending_stats_vampire2
    inc c
state_ending_stats_vampire2:
	; "c" now has the number of vampires killed
	ld a,c
	ld de,CHRTBL2 + (14*32 + 22)*8 
	ld hl,ending_stats_template1
	ld iy,COLOR_GREY*16 + #8000
	call state_ending_draw_number

	; book in store, open vlad room, reveal Quincey chest, unearth quincey, find Frankenstein, kill Frankenstein
	ld c,0  ; secondary mission progress:
	ld a,(state_choffeur_store)
	cp 3
    jr nz,state_ending_stats_secondary1
    inc c
state_ending_stats_secondary1:
	ld a,(state_reveal_clue_taken)
	cp 1
    jr nz,state_ending_stats_secondary2
    inc c
state_ending_stats_secondary2:
	ld a,(state_ritual_room_state)
	cp 3
    jr nz,state_ending_stats_secondary3
    inc c
state_ending_stats_secondary3:
	ld a,(state_quincey_grave)
	or a
    jr z,state_ending_stats_secondary4
    inc c
state_ending_stats_secondary4:
	ld a,(state_franky_key_taken)
	cp 2
    jr nz,state_ending_stats_secondary5
    inc c
state_ending_stats_secondary5:
	ld a,(state_franky_boss)
	or a
    jr z,state_ending_stats_secondary6
    inc c
state_ending_stats_secondary6:

	ld a,c
	ld de,CHRTBL2 + (16*32 + 22)*8 
	ld hl,ending_stats_template2
	ld iy,COLOR_GREY*16 + #8000
	call state_ending_draw_number

	call wait_for_space
	; 2 second blank screen (skippable)
	call clearScreen
	call StopMusic
	ld c,2
	call state_intro_pause
; 	jp Execute_back_to_intro
	jp state_intro


state_ending_fade_in_line:
	ld e,a
	ld a,(ending_text_page)
	or a
	jr z,state_ending_fade_in_line_continue
	cp 2
	jr z,state_ending_fade_in_line_continue
	jp state_ending_loop_continue3
state_ending_fade_in_line_continue:
	ld a,(ending_text_page_line)
	ld hl,CLRTBL2 + (2*32 + 15)*8
    add a,h  ; move lines down
    ld h,a
    ld a,e
    and #fc
    ld b,0
    ld c,a
    add hl,bc
    add hl,bc  ; ptr to the character we want to color

    ld a,COLOR_DARK_RED*16
    ld bc,8
    push bc
	    push hl
	    	call fast_FILVRM_only_right_half
		pop hl
		ld bc,-8
		add hl,bc
	    ld a,COLOR_DARK_YELLOW*16
	pop bc
	push bc
	    push hl
		    call fast_FILVRM_only_right_half
		pop hl
		ld bc,-8
		add hl,bc
	    ld a,COLOR_YELLOW*16
	pop bc
	push bc
	    push hl
		    call fast_FILVRM_only_right_half
		pop hl
		ld bc,-8
		add hl,bc
	    ld a,COLOR_WHITE*16
	pop bc
	call fast_FILVRM_only_right_half
	jp state_ending_loop_continue3	


fast_FILVRM_only_right_half:
	ld e,a
	ld a,l
	cp 15*8
	ld a,e
	ret c
	jp fast_FILVRM


;-----------------------------------------------
ending1_lines:
    dw TEXT_ENDING_LINE1
    dw #ffff
    dw TEXT_ENDING_LINE2
    dw TEXT_ENDING_LINE3
    dw TEXT_ENDING_LINE4
    dw TEXT_ENDING_LINE5
    dw #ffff
    dw TEXT_ENDING_LINE6
    dw TEXT_ENDING_LINE7
    dw TEXT_ENDING_LINE8
    dw TEXT_ENDING_LINE9
    dw TEXT_ENDING_LINE10
    dw TEXT_ENDING_LINE11
    dw #ffff
    dw TEXT_ENDING_LINE12
    dw TEXT_ENDING_LINE13
    dw #ffff
    dw TEXT_ENDING_LINE14


ending2_lines:
    dw TEXT_ENDING2_LINE1
    dw TEXT_ENDING2_LINE2
    dw #ffff
    dw TEXT_ENDING2_LINE3
    dw TEXT_ENDING2_LINE4
    dw #ffff
    dw TEXT_ENDING2_LINE5
    dw TEXT_ENDING2_LINE6
    dw TEXT_ENDING2_LINE7
    dw TEXT_ENDING2_LINE8
    dw TEXT_ENDING2_LINE9
    dw TEXT_ENDING2_LINE10
    dw TEXT_ENDING2_LINE11
    dw TEXT_ENDING2_LINE12
    dw TEXT_ENDING2_LINE13
    dw #ffff
    dw TEXT_ENDING2_LINE14
    dw TEXT_ENDING2_LINE15


;-----------------------------------------------
wait_for_interrupt_page3:
	ld hl,interrupt_cycle
	ld a,(hl)
	cp c
	jr c,wait_for_interrupt_page3
	ld (hl),0
	ret


;-----------------------------------------------
; - draws a text message, waits 4 seconds, and clears it
ending_cutscene_text:
	push de
  		call draw_text_from_bank_multilingual
    	ld c,6
    	call state_intro_pause_page3
    pop hl
	ld bc,#011f
	jp clear_rectangle_bitmap_mode


;-----------------------------------------------
; waits for "c" seconds, or for pressing space
; input:
; - c: # seconds to wait
; return:
; - z: exit by timeout
; - nz: exit by pressing space/button1
state_intro_pause_page3:
state_intro_pause_page3_loop1:
	ld b,50
state_intro_pause_page3_loop2:
	halt
	push bc
    	call update_keyboard_buffers
    pop bc
    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
    bit KEY_BUTTON1_BIT,a
    ret nz
    djnz state_intro_pause_page3_loop2
    dec c
    jr nz,state_intro_pause_page3_loop1
    ret


;-----------------------------------------------
; - hl: pointer to the vignette data
; - de: pointer to draw in the screen
; - ix: SPRTBL2 ptr
; - iy: SPRATR2 ptr
ending_show_vignette:
	; decompress the data:
	push iy
		push ix
			push de
				SETMEGAROMPAGE_A000 OBJECTS_PAGE3
				ld de,enemy_data_buffer
				call dzx0_standard
			pop de

			; draw tiles:
			ld ix,enemy_data_buffer + 2
			ld iy,10
			ld bc,#0a0a
			ld hl,enemy_data_buffer + 10*10 + 2
			ld (draw_hud_chunk_tile_ptr),hl
			; - (draw_hud_chunk_tile_ptr) ptr where the tile data starts
			call draw_hud_chunk

			; draw sprites:
			ld bc,(enemy_data_buffer)
			ld hl,enemy_data_buffer + 2
			add hl,bc
			ld c,(hl)
			inc hl
			ld b,(hl)
			inc hl
		pop de
		push hl
		push bc
			call fast_LDIRVM
		pop bc
		pop hl
		add hl,bc
		ld c,(hl)
		inc hl
		ld b,(hl)
		inc hl
	pop de
	jp fast_LDIRVM


;-----------------------------------------------
; - a: number to draw
; - de: CHRTBL2 ptr to draw to
; - hl: template to use (ending_stats_template1 / ending_stats_template2)
; - iy: color / pixel to start
state_ending_draw_number:
	push de
		push hl
			ld hl,ending_numbers
			ADD_HL_A
			ld a,(hl)

			ld hl,buffer1024+900
			ld (hl),5  ; length of the string = 5
			inc hl
			ld (hl),a
			inc hl
			ex de,hl
		pop hl
		ldi
		ldi
		ldi
		ldi

		push af
		    ld hl,text_draw_buffer
		    ld bc,24
		    call clear_memory
		pop af
	pop de
	ld hl,buffer1024+900
	ld bc,24
	jp draw_sentence


; numbers from 0 to 6 used for the end statistics
ending_numbers:
	db 21, 23, 25, 27, 29, 32, 34

; " / 3"
ending_stats_template1:
	db 0,3,0,27

; " / 6"
ending_stats_template2:
	db 0,3,0,34
