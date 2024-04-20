;-----------------------------------------------
state_puzzle_box_internal:
	SETMEGAROMPAGE_A000 OTHER_DATA_PAGE
	ld hl,puzzle_box_zx0
	ld de,buffer1024
	call dzx0_standard

    xor a
    ld hl,CLRTBL2 + (4*32 + 11)*8
    ld bc,#0a0a
    call clear_rectangle_bitmap_mode_color

    call hide_player

	ld ix,buffer1024
	ld iy,8
	ld de,CHRTBL2+(5*32+12)*8
	ld bc,#0808
	ld hl,buffer1024+8*8
	ld (draw_hud_chunk_tile_ptr),hl
	call draw_hud_chunk

	; Draw clue text:
    ld a,6*8
    ld bc,TEXT_PUZZLE_BOX1
    ld de,CHRTBL2 + (6*32 + 13)*8 
    ld iyl,COLOR_DARK_RED
    call draw_text_from_bank_multilingual
    ld a,6*8
    ld bc,TEXT_PUZZLE_BOX2
    ld de,CHRTBL2 + (7*32 + 13)*8 
    ld iyl,COLOR_DARK_RED
    call draw_text_from_bank_multilingual
    ld a,6*8
    ld bc,TEXT_PUZZLE_BOX3
    ld de,CHRTBL2 + (8*32 + 13)*8 
    ld iyl,COLOR_DARK_RED
    call draw_text_from_bank_multilingual


	ld bc,13*8-1 + (9*8+4)*256
	call setup_puzzle_pointer_sprite

	inc hl
	ld bc,6-1
	call clear_memory

	call state_puzzle_box_draw_current_password	
	
state_puzzle_box_loop:
	halt
	call puzzle_pointer_sprite_blink
	inc hl
	ld a,(hl)
	add a,a
	add a,a
	add a,a
	add a,13*8-1
	ld hl,puzzle_pointer_sprite_attributes+1
	ld (hl),a  ; x
	dec hl
	ld de,SPRATR2+7*4
	ld bc,4
	call fast_LDIRVM

	call update_hud_messages
	call update_keyboard_buffers
	ld hl,state_puzzle_box_loop
	push hl  ; setting the return address for a potential "ret" from the movement functions
	    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
	    bit KEY_BUTTON1_BIT,a
	    jr nz,state_puzzle_box_loop_exit
	    bit KEY_LEFT_BIT,a
	    jr nz,state_puzzle_box_left
	    bit KEY_RIGHT_BIT,a
	    jr nz,state_puzzle_box_right
	    bit KEY_UP_BIT,a
	    jr nz,state_puzzle_box_up
	    bit KEY_DOWN_BIT,a
	    jr nz,state_puzzle_box_down
	ret  ; this just restores the stack and jumps back to "state_puzzle_box_loop"

state_puzzle_box_loop_exit:
	pop af  ; restore the stack

	; remove pointer sprite
	ld a,200
	ld hl,SPRATR2+7*4
	call WRTVRM

	; re-render the room:
	ld de,11 + 4*256
	ld bc,10+10*256
	jp render_room_rectangle


state_puzzle_box_left:
	ld hl,puzzle_pointer_position
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority


state_puzzle_box_right:
	ld hl,puzzle_pointer_position
	ld a,(hl)
	cp 5
	ret z 
	inc (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority


state_puzzle_box_up:
	ld a,(puzzle_pointer_position)
	ld hl,puzzle_current_letters
	ADD_HL_A
	ld a,(hl)
	or a
	jr z,state_puzzle_box_up_reset
	dec a
	jr state_puzzle_box_up_continue
state_puzzle_box_up_reset:
	ld a,26
state_puzzle_box_up_continue
	ld (hl),a
	call state_puzzle_box_draw_current_password
	ld hl,SFX_ui_change_letter
	jp play_SFX_with_high_priority


state_puzzle_box_down:
	ld a,(puzzle_pointer_position)  ; current position
	ld hl,puzzle_current_letters
	ADD_HL_A
	ld a,(hl)
	cp 26
	jr z,state_puzzle_box_down_reset
	inc a
	jr state_puzzle_box_down_continue
state_puzzle_box_down_reset:
	xor a
state_puzzle_box_down_continue
	ld (hl),a
	call state_puzzle_box_draw_current_password
	ld hl,SFX_ui_change_letter
	jp play_SFX_with_high_priority



state_puzzle_box_draw_current_password:
	ld de,CHRTBL2+(11*32+13)*8
	jp state_password_draw_current_password_entrypoint
