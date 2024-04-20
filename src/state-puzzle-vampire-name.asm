;-----------------------------------------------
state_password_lock_internal:

	ld bc, TEXT_USE_VAMPIRE_DOOR
	call queue_hud_message

	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
	ld hl,password_lock_zx0
	ld de,buffer1024
	call dzx0_standard

    xor a
    ld hl,CLRTBL2 + (7*32 + 11)*8
    ld bc,#050a
    call clear_rectangle_bitmap_mode_color

	ld ix,buffer1024
	ld iy,8
	ld de,CHRTBL2+(8*32+12)*8
	ld bc,#0308
	ld hl,buffer1024+8*3
	ld (draw_hud_chunk_tile_ptr),hl
	call draw_hud_chunk

	ld bc,13*8-1 + 56*256
	call setup_puzzle_pointer_sprite

	inc hl
	ld bc,6-1
	call clear_memory

	; password starts at: puzzle_current_letters
	call state_password_draw_current_password	
	
state_password_lock_loop:
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
	ld hl,state_password_lock_loop
	push hl  ; setting the return address for a potential "ret" from the movement functions
	    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
	    bit KEY_BUTTON1_BIT,a
	    jr nz,state_password_lock_loop_exit
	    bit KEY_LEFT_BIT,a
	    jr nz,state_password_lock_left
	    bit KEY_RIGHT_BIT,a
	    jr nz,state_password_lock_right
	    bit KEY_UP_BIT,a
	    jr nz,state_password_lock_up
	    bit KEY_DOWN_BIT,a
	    jr nz,state_password_lock_down
	ret  ; this just restores the stack and jumps back to "state_password_lock_loop"

state_password_lock_loop_exit:
	pop af  ; restore the stack

	; remove pointer sprite
	ld a,200
	ld hl,SPRATR2+7*4
	call WRTVRM

	; re-render the room:
	ld de,11 + 7*256
	ld bc,10+5*256
	jp render_room_rectangle


state_password_lock_left:
	ld hl,puzzle_pointer_position
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority


state_password_lock_right:
	ld hl,puzzle_pointer_position
	ld a,(hl)
	cp 5
	ret z 
	inc (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority


state_password_lock_up:
	ld a,(puzzle_pointer_position)  ; current position
	ld hl,puzzle_current_letters
	ADD_HL_A
	ld a,(hl)
	or a
	jr z,state_password_lock_up_reset
	dec a
	jr state_password_lock_up_continue
state_password_lock_up_reset:
	ld a,26
state_password_lock_up_continue
	ld (hl),a
	call state_password_draw_current_password
	ld hl,SFX_ui_change_letter
	jp play_SFX_with_high_priority


state_password_lock_down:
	ld a,(puzzle_pointer_position)  ; current position
	ld hl,puzzle_current_letters
	ADD_HL_A
	ld a,(hl)
	cp 26
	jr z,state_password_lock_down_reset
	inc a
	jr state_password_lock_down_continue
state_password_lock_down_reset:
	xor a
state_password_lock_down_continue
	ld (hl),a
	call state_password_draw_current_password
	ld hl,SFX_ui_change_letter
	jp play_SFX_with_high_priority


	; password starts at puzzle_current_letters
	; we use a temporary string buffer in puzzle_tmp_string_buffer
state_password_draw_current_password:
	ld de,CHRTBL2+(9*32+13)*8
state_password_draw_current_password_entrypoint:
	ld b,6
	ld hl,puzzle_current_letters
	ld a,(current_language_page)
	SETMEGAROMPAGE_A000_A
state_password_draw_current_password_loop:
	push hl
	push bc
		push de
			call state_password_draw_current_password_character
		pop hl
		ld bc,8
		add hl,bc
		ex de,hl
	pop bc
	pop hl
	inc hl
	djnz state_password_draw_current_password_loop
	ret


state_password_draw_current_password_character:
	push de
		ld a,(hl)
		ld hl,combination_lock_letters
		ADD_HL_A
		ld a,(hl)

		push af
		    ld hl,text_draw_buffer
		    ld bc,8
		    ld a,#01
		    call clear_memory_a	
		pop af

		ld hl,puzzle_tmp_string_buffer
		ld (hl),1  ; length of the string = 1
		inc hl
		ld (hl),a
		dec hl
	pop de
	ld iy,COLOR_DARK_RED + #4000
	ld bc,8
	jp draw_sentence


;-----------------------------------------------
; c,b: x,y coordinates
setup_puzzle_pointer_sprite:
	; set up pointer sprite:
	push bc
		SETMEGAROMPAGE_A000 SPRITES_PAGE
		ld hl,keyword_lock_pointer_sprite
		ld de,SPRTBL2+7*32
		ld bc,32
		call fast_LDIRVM
	pop bc

	ld hl,puzzle_pointer_sprite_attributes
	ld (hl),b  ; y
	inc hl
	ld (hl),c  ; x
	inc hl
	ld (hl),7*4
	inc hl
	ld (hl),COLOR_WHITE
	inc hl
	ld (hl),0  ; current position
	ret


;-----------------------------------------------
puzzle_pointer_sprite_blink:
	ld a,(interrupt_cycle)
	bit 3,a
	ld a,COLOR_WHITE
	jr z,puzzle_pointer_sprite_blink_blink
	xor a
puzzle_pointer_sprite_blink_blink:
	ld hl,puzzle_pointer_sprite_attributes+3
	ld (hl),a  ; color
	ret


combination_lock_letters:
    db 43, 45, 47, 49, 51, 53, 55, 57, 59, 61, 63, 66, 68, 71, 74, 76, 78, 81, 83, 85, 88, 90, 93, 96, 99, 102, 0
