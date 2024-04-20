;-----------------------------------------------
state_travel_cutscene_page_changed:
    ; init the stack:
    ld sp,#f380
	
    call StopMusic

    call disable_VDP_output
        call clearAllTheSprites
        call clearScreen
        call set_bitmap_name_table_bank3
        xor a
        ld hl,CLRTBL2+256*8*2
        ld bc,256*8
        call fast_FILVRM

        xor a
        ld hl,CLRTBL2
        ld bc,8
        call fast_FILVRM
        xor a
        ld hl,CLRTBL2+256*8
        ld bc,8
        call fast_FILVRM

	    ; Travel cutscene:
	    SETMEGAROMPAGE_A000 SPRITES_PAGE
	    ld hl,travel_cutscene_data_zx0
	    ld de,enemy_data_buffer
	    call dzx0_standard

		; Upload tiles to VDP
	    ld bc,(enemy_data_buffer+22*10)  ; size of the pattern data
	    ld hl,enemy_data_buffer+22*10+2
	    ld de,CHRTBL2+8
	    push hl
	    push bc
	    	call fast_LDIRVM
	    pop bc
	    pop hl
	    add hl,bc
	    ld de,CLRTBL2+8
	    push bc
		    call fast_LDIRVM
		pop bc
	    ld hl,enemy_data_buffer+22*10+2
	    ld de,CHRTBL2+8+256*8
	    push hl
	    push bc
	    	call fast_LDIRVM
	    pop bc
	    pop hl
	    add hl,bc
	    ld de,CLRTBL2+8+256*8
	    push bc
		    call fast_LDIRVM
		pop bc

		; Upload sprites to the VDP (to the last patterns: 60, 61, 62, 63)
	    ld hl,enemy_data_buffer+22*10+2
	    add hl,bc
	    add hl,bc  ; hl points to the start of the sprite data:
	    ; it's 4 sprites
	    push hl
		    ld de,SPRATR2
		    ld bc,4*4
		    call fast_LDIRVM
		pop hl
		ld de,SPRTBL2+60*32
		ld bc,16
		add hl,bc
		ld bc,32*4
		push hl
		push bc
			call fast_LDIRVM
		pop bc
		pop hl
		add hl,bc  ; hl = start of path change data

		push hl
			; Upload name table
		    ld hl,enemy_data_buffer
		    ld de,NAMTBL2+5*32+5
		    ld b,10
	state_travel_cutscene_nametable_loop:
			push bc
				push hl
					push de
						ld bc,22
						call fast_LDIRVM
					pop hl
					ld bc,32
					add hl,bc
					ex de,hl
				pop hl
				ld c,22
				add hl,bc
			pop bc
			djnz state_travel_cutscene_nametable_loop
    call enable_VDP_output

    call play_music_ingame_travel

	ld c,1
	call state_intro_pause

	; Loop that applies the changes to show the path
	pop hl
    ld b,(hl)  ; number of changes (should be 69)
    inc hl
state_travel_path_update_loop:
	push bc
		push hl
			ld a,b
			cp 69 - 11
			jp z,state_travel_path_update_loop_reach_station

state_travel_path_update_loop_continue:
			ld b,8
			call wait_b_halts
			call update_keyboard_buffers
		pop hl

		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
		ld a,(hl)
		inc hl
		ex de,hl
		push de
			call WRTVRM
		pop hl
	pop bc
	djnz state_travel_path_update_loop

	call state_travel_path_update_clear_text
	; if we have the newspaper:
	ld a,(state_newspaper_taken)
	or a
	jr z,state_travel_cutscene_no_newspaper

	ld hl,travel_cutscene_3b
	ld a,22*8
	ld de,CHRTBL2+17*32*8+5*8
	ld iyl,COLOR_WHITE*16
	ld b,7
	call render_letter_text_multilingual

	ld a,(state_choffeur_store)
	cp 3  ; "Historia of Romania" purchased
	jr nz,state_travel_cutscene_no_newspaper

	ld c,12
	call state_intro_pause

	call state_travel_path_update_clear_text
	ld hl,travel_cutscene_4b
	ld a,22*8
	ld de,CHRTBL2+17*32*8+5*8
	ld iyl,COLOR_WHITE*16
	ld b,5
	call render_letter_text_multilingual

	ld c,8
	call state_intro_pause

state_travel_cutscene_no_newspaper:

    ; wait for intro song to end:
    call update_keyboard_buffers  ; call once before to prevent previous clicks from skipping accidentally
state_travel_wait_for_song_loop:
	halt
    call update_keyboard_buffers
    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
    bit KEY_BUTTON1_BIT,a
    jr nz,state_travel_wait_for_song_loop_exit
    ld a,(wyz_interr)
    or a
    jr nz,state_travel_wait_for_song_loop
state_travel_wait_for_song_loop_exit:

	; Lose newspaper and luggage:
	ld a,INVENTORY_LUGGAGE
	call inventory_find_slot
	jr nz,state_travel_cutscene_continue1
	ld (hl),0
state_travel_cutscene_continue1:
	ld a,INVENTORY_NEWSPAPER
	call inventory_find_slot
	jr nz,state_travel_cutscene_continue2
	ld (hl),0
state_travel_cutscene_continue2:

	ld bc, TEXT_HOUSE_ARRIVAL_MESSSAGE1
	call queue_hud_message
	ld bc, TEXT_HOUSE_ARRIVAL_MESSSAGE2
	call queue_hud_message
	jp state_travel_cutscene_end


state_travel_path_update_loop_reach_station:
	; draw text:
	ld hl,travel_cutscene_1
	ld a,22*8
	ld de,CHRTBL2+17*32*8+5*8
	ld iyl,COLOR_WHITE*16
	ld b,3
	call render_letter_text_multilingual

	ld c,4
	call state_intro_pause
	call state_travel_path_update_clear_text

	ld a,(state_newspaper_taken)
	or a
	jr nz,state_travel_path_update_loop_reach_station_newspaper
state_travel_path_update_loop_reach_station_no_newspaper:
	ld hl,travel_cutscene_2a
	jr state_travel_path_update_loop_reach_station_newspaper_set
state_travel_path_update_loop_reach_station_newspaper:
	ld hl,travel_cutscene_2b
state_travel_path_update_loop_reach_station_newspaper_set:
	ld a,22*8
	ld de,CHRTBL2+17*32*8+5*8
	ld iyl,COLOR_WHITE*16
	ld b,3
	call render_letter_text_multilingual
	jp state_travel_path_update_loop_continue


state_travel_path_update_clear_text:
	xor a
	ld hl,CLRTBL2 + (17*32 + 5)*8 
	ld bc,#0716
	jp clear_rectangle_bitmap_mode_color


