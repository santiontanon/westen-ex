;-----------------------------------------------
state_intro_page_changed:
	call init_game_variables
    call clearAllTheSprites
    call clearScreenLeftToRight_bitmap
    call set_bitmap_mode

    call play_music_intro    

    SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
    ld hl,braingames_zx0
    ld de,buffer1024
    call dzx0_standard

    ld hl,buffer1024
    ld de,CHRTBL2 + (10*32 + 12)*8 
    ld b,2
state_intro_bg_loop1:
    push bc
        ld b,8
state_intro_bg_loop2:
        push bc
            push hl
                push de
                call draw_tile_bitmap_mode
                pop hl
                ld bc,8
                add hl,bc
                ex de,hl
            pop hl
            add hl,bc
            add hl,bc
        pop bc
        djnz state_intro_bg_loop2
        ex de,hl
            ld bc,24*8
            add hl,bc
        ex de,hl
    pop bc
    djnz state_intro_bg_loop1

    ld c,2
    call state_intro_pause_title_if_space
    ld a,8*8
    ld bc,TEXT_PRESENTS 
    ld de,CHRTBL2 + (13*32 + 13)*8 
    ld iy,COLOR_WHITE*16 + 8*256
    call draw_text_from_bank_multilingual_iyh_set
    ld c,3
    call state_intro_pause_title_if_space
    call clearScreenLeftToRight_bitmap

    ld c,1
    call state_intro_pause_title_if_space

	; message 1:
    ld a,8*8
    ld bc,TEXT_INTRO_MSG1
    ld de,CHRTBL2 + (20*32 + 12)*8 
    ld iyl,COLOR_WHITE*16
    call draw_text_from_bank_multilingual
    ld c,2
    call state_intro_pause_title_if_space

    ; draw room:
	ld hl,map5_zx0
	ld de,0
	call teleport_player_to_room
	call init_object_screen_coordinates
	call render_full_room

    ld c,4
    call state_intro_pause_title_if_space

	ld hl,CLRTBL2 + (20*32 + 12)*8 
	ld bc,#0108
	call clear_rectangle_bitmap_mode

    ld c,1
    call state_intro_pause_title_if_space

    ; door rings
    ld hl,SFX_doorbell
    call play_SFX_with_high_priority
    ld a,8*8
    ld bc,TEXT_INTRO_MSG2
    ld de,CHRTBL2 + (5*32 + 23)*8 
    ld iyl,COLOR_YELLOW*16
    call intro_draw_text

    ; comming!
    ld a,8*8
    ld bc,TEXT_INTRO_MSG3
    ld de,CHRTBL2 + (17*32 + 13)*8 
    ld iyl,COLOR_WHITE*16
    call intro_draw_text

    ; player walks to the door
    call draw_player
    ld hl,cutscene1_keystrokes
    call state_intro_cutscene

    ; door opens
	ld de,OBJECT_STRUCT_SIZE
	ld ix,objects
	ld a,OBJECT_TYPE_DOOR_RIGHT_NO_KEY
state_intro_find_door_loop:
	cp (ix)
	jr z,state_intro_find_door_loop_found
	add ix,de
	jr state_intro_find_door_loop
state_intro_find_door_loop_found:
	call remove_room_object
	ld hl,SFX_door_open
	call play_SFX_with_high_priority

    ld c,2
    call state_intro_pause_title_if_space

    ; talk to mail man
    ld a,16*8
    ld bc,TEXT_INTRO_MSG4
    ld de,CHRTBL2 + (1*32 + 16)*8 
    ld iyl,COLOR_LIGHT_BLUE*16
    call intro_draw_text

    ld a,12*8
    ld bc,TEXT_INTRO_MSG5
    ld de,CHRTBL2 + (17*32 + 12)*8 
    ld iyl,COLOR_WHITE*16
    call intro_draw_text

    ; walk back to room center
    ld hl,cutscene2_keystrokes
    call state_intro_cutscene

    ; wonder who the letter is from
    ld a,16*8
    ld bc,TEXT_INTRO_MSG6
    ld de,CHRTBL2 + (17*32 + 12)*8 
    ld iyl,COLOR_WHITE*16
    call intro_draw_text

    ld c,1
    call state_intro_pause_title_if_space

    ; letter 1
    call clearAllTheSprites
    ld a,COLOR_WHITE + COLOR_WHITE*16
    ld hl,CLRTBL2 + (8*32 + 1)*8
    ld bc,#0a1e
    call clear_rectangle_bitmap_mode_color
    ld hl,letter1_lines
    ld a,28*8
    ld de,CHRTBL2+9*32*8+2*8
    ld iyl,COLOR_WHITE
    ld b,8
    call render_letter_text_multilingual

    ld c,18
    call state_intro_pause_title_if_space
    ld hl,CLRTBL2 + (8*32 + 1)*8
    ld bc,#0a1e
    call clear_rectangle_bitmap_mode
    call draw_player
    call render_full_room
    ld c,1
    call state_intro_pause_title_if_space

    ; letter 2
    call clearAllTheSprites
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (8*32 + 3)*8
    ld bc,#0e1a
    call clear_rectangle_bitmap_mode_color
    ld hl,letter2_lines
    ld a,24*8
    ld de,CHRTBL2+9*32*8+4*8
    ld iyl,COLOR_YELLOW
    ld b,12
    call render_letter_text_multilingual

    ld c,20
    call state_intro_pause_title_if_space
    ld hl,CLRTBL2 + (8*32 + 3)*8
    ld bc,#0e1a
    call clear_rectangle_bitmap_mode
    call draw_player
    call render_full_room
    ld c,1
    call state_intro_pause_title_if_space

    ; final text lines
    ld a,12*8
    ld bc,TEXT_INTRO_MSG7
    ld de,CHRTBL2 + (17*32 + 12)*8 
    ld iyl,COLOR_WHITE*16
    call intro_draw_text

    ld a,14*8
    ld bc,TEXT_INTRO_MSG8
    ld de,CHRTBL2 + (17*32 + 11)*8 
    ld iyl,COLOR_WHITE*16
    call intro_draw_text

    ld a,14*8
    ld bc,TEXT_INTRO_MSG9
    ld de,CHRTBL2 + (17*32 + 11)*8 
    ld iyl,COLOR_WHITE*16
    call intro_draw_text

    ld c,2
    call state_intro_pause_title_if_space
    call clearScreenLeftToRight_bitmap
    jp state_title


;-----------------------------------------------
; controls the player based on pre-recorded keystrokes:
; input:
; - hl: keystrokes ptr
state_intro_cutscene:
    ld bc,(key_to_direction_mapping_ptr)
    push bc
        ; set the default direction mapping for the predefined cutscene keystrokes:
        ld bc,key_to_direction_mapping
        ld (key_to_direction_mapping_ptr),bc
    	push hl
    		ld a,#ff
    		ld hl,keyboard_line_state
    		ld de,keyboard_line_state+1
    		ld (hl),a
    		ld bc,5
    		ldir
    		; clicks:
    		xor a
    		ld (keyboard_line_clicks),a
    		ld (keyboard_line_clicks+2),a
    	pop hl
state_intro_cutscene_loop1:
    	ld a,(hl)
    	or a
        jr z,state_intro_cutscene_done
    	inc hl
    	ld b,(hl)
    	inc hl
    	ld (keyboard_line_state),a
state_intro_cutscene_loop2:
    	push bc
    	push hl
            ld c,2
            call wait_for_interrupt

    		call update_player
    		call draw_player
    	pop hl
    	pop bc
    	djnz state_intro_cutscene_loop2
    	jr state_intro_cutscene_loop1
state_intro_cutscene_done:
    pop bc
    ; restore the player selected direction mapping
    ld (key_to_direction_mapping_ptr),bc
    ret


;-----------------------------------------------
; - draws a text message, waits 4 seconds, and clears it
intro_draw_text:
	push de
  		call draw_text_from_bank_multilingual
    	ld c,3
    	call state_intro_pause_title_if_space
    pop hl
	ld bc,#0110
	jp clear_rectangle_bitmap_mode


;-----------------------------------------------
letter1_lines:
    dw TEXT_LETTER1_LINE1
    dw #ffff
    dw TEXT_LETTER1_LINE2
    dw TEXT_LETTER1_LINE3
    dw TEXT_LETTER1_LINE4
    dw TEXT_LETTER1_LINE5
    dw TEXT_LETTER1_LINE6
    dw TEXT_LETTER1_LINE7

letter2_lines:
    dw TEXT_LETTER3_LINE1
    dw #ffff
    dw TEXT_LETTER2_LINE2
    dw TEXT_LETTER2_LINE3
    dw TEXT_LETTER2_LINE4
    dw TEXT_LETTER2_LINE5
    dw TEXT_LETTER2_LINE6
    dw TEXT_LETTER2_LINE7
    dw TEXT_LETTER2_LINE8
    dw TEXT_LETTER2_LINE9
    dw #ffff
    dw TEXT_LETTER3_LINE7


;-----------------------------------------------
cutscene1_keystrokes:
    db #3f, 32
    db #5f, 34+8
    db 0

cutscene2_keystrokes:
    db #af, 16
    db #bf, 4
    db #ff, 4
    db 0


;-----------------------------------------------
state_intro_pause_title_if_space:
    call state_intro_pause
    ret z
    call clearAllTheSprites
    call clearScreenLeftToRight_bitmap
    jp state_title

