;-----------------------------------------------
	db 0  ; just a marker showing there is a blank space to the left of the line
chapel_puzzle_message:
	; Vlad al III lea Tepes
	db  90,126,105,111,  0,  105,126,  0,   59, 59, 59,  0,  126,113,105,  0,   85,113,134,113,140
chapel_puzzle_message_end:
	db 0  ; to marek the space at the very end
chapel_puzzle_message_offsets:  ; how many pixels to offset each letter to make it centered
	db #20,#08,#20,#20,  0,  #20,#08,  0,  #10,#10,#10,  0,  #08,#20,#20,  0,  #20,#20,#20,#20,#20
chapel_puzzle_target_state:
	db 0,0,0,0, 0, 1,1, 0, 0,1,0, 0, 0,0,0, 0, 0,1,0,0,0

CHAPEL_PUZZLE_MESSAGE_LEN: equ chapel_puzzle_message_end - chapel_puzzle_message


state_puzzle_chapel_internal:	
; 	ld bc, TEXT_USE_CHAPEL_ALTAR_BANK + 256*TEXT_USE_CHAPEL_ALTAR_IDX
; 	call queue_hud_message

	SETMEGAROMPAGE_A000 OTHER_DATA_PAGE
	ld hl,puzzle_altar_zx0
	ld de,buffer1024
	call dzx0_standard

    xor a
    ld hl,CLRTBL2 + (2*32 + 4)*8
    ld bc,#0b19
    call clear_rectangle_bitmap_mode_color

	call hide_player

	ld ix,buffer1024
	ld iy,23
	ld de,CHRTBL2+(3*32+5)*8
	ld bc,#0917
	ld hl,buffer1024+23*9
	ld (draw_hud_chunk_tile_ptr),hl
	call draw_hud_chunk

	ld bc,6*8 + 38*256
	call setup_puzzle_pointer_sprite

	inc hl
	ld bc,CHAPEL_PUZZLE_MESSAGE_LEN-1
	call clear_memory	

	; draw the current state of the puzzle:
	call state_puzzle_chapel_draw_letters

state_puzzle_chapel_loop:
	halt
	call puzzle_pointer_sprite_blink
	inc hl
	ld a,(hl)
	add a,a
	add a,a
	add a,a
	add a,6*8
	ld hl,puzzle_pointer_sprite_attributes+1
	ld (hl),a  ; x
	dec hl
	ld de,SPRATR2+7*4
	ld bc,4
	call fast_LDIRVM

	call update_hud_messages
	call update_keyboard_buffers
    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
    bit KEY_BUTTON1_BIT,a
	ld hl,state_puzzle_chapel_loop
	push hl  ; setting the return address for a potential "ret" from the movement functions
	    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
	    bit KEY_BUTTON1_BIT,a
	    jr nz,state_puzzle_chapel_loop_exit
	    bit KEY_LEFT_BIT,a
	    jp nz,state_password_lock_left
	    bit KEY_RIGHT_BIT,a
	    jr nz,state_puzzle_chapel_right
	    bit KEY_UP_BIT,a
	    jr nz,state_puzzle_chapel_up_down
	    bit KEY_DOWN_BIT,a
	    jr nz,state_puzzle_chapel_up_down
	ret  ; this just restores the stack and jumps back to "state_puzzle_chapel_loop"

state_puzzle_chapel_loop_exit:
	pop af  ; restore the stack

	; re-render the room:
	; clear the pointer:
	xor a
	ld hl,SPRATR2+7*4
	ld bc,4
	call fast_FILVRM
	
	ld de,0
	ld bc,16+13*256
	call render_room_rectangle
	ld de,16
	ld bc,16+13*256
	jp render_room_rectangle



state_puzzle_chapel_right:
	ld hl,puzzle_pointer_position
	ld a,(hl)
	cp CHAPEL_PUZZLE_MESSAGE_LEN-1
	ret z 
	inc (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority


state_puzzle_chapel_up_down:
	; change the state of a letter:
	ld a,(puzzle_pointer_position)  ; Current position of the pointer
	ld hl,chapel_puzzle_message
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	or a
	ret z  ; we are in a space
	ld hl,SFX_ui_change_letter
	call play_SFX_with_high_priority

	ld hl,puzzle_current_letters  ; state of the letters
	add hl,bc
	ld a,(hl)
	xor #01  ; flip the state
	ld (hl),a
	ld hl,chapel_puzzle_message
	add hl,bc
	ex de,hl
	ld hl,CHRTBL2+(5*32+6)*8
	REPT 8
		add hl,bc  ; does not modify z flag, so, we still have the z from the state flip
	ENDR
	jr nz,state_puzzle_chapel_press_letter
state_puzzle_chapel_release_letter:
	; hl: VDP pointer to modify
	; de: pointer to the letter
	inc de
	call state_puzzle_chapel_space_or_pressed
	call z,state_puzzle_chapel_press_letter_before_space
 	call state_puzzle_chapel_release_letter_vdp_ram
	push hl
		; move things up 2 pixels:
		ld hl,text_draw_buffer+8
		ld de,text_draw_buffer+6
		ld bc,11
		ldir
		ld hl,text_draw_buffer+17
		ld (hl),#80
	pop de
	call state_puzzle_chapel_release_letter_ram_vdp
	jp state_puzzle_chapel_check_puzzle_solved


state_puzzle_chapel_press_letter:
	; hl: VDP pointer to modify
	; de: pointer to the letter
	push de
		inc de
		call state_puzzle_chapel_space_or_pressed
		call z,state_puzzle_chapel_press_letter_before_space
	 	call state_puzzle_chapel_release_letter_vdp_ram
	pop de
	push hl
		push de
			; move things down 2 pixels:
			ld hl,text_draw_buffer+16
			ld de,text_draw_buffer+18
			ld bc,13
			lddr
		pop de

		dec de
		call state_puzzle_chapel_space_or_pressed
		jr z,state_puzzle_chapel_press_letter_after_a_space
		ld hl,text_draw_buffer+6
		ld (hl),#80
		inc hl
		ld (hl),#80
state_puzzle_chapel_press_letter_after_a_space:
	pop de
	call state_puzzle_chapel_release_letter_ram_vdp
; 	jp state_puzzle_chapel_check_puzzle_solved

state_puzzle_chapel_check_puzzle_solved:
	; Check if the puzzle is solved:
	ld hl,puzzle_current_letters
	ld de,chapel_puzzle_target_state
	ld bc,CHAPEL_PUZZLE_MESSAGE_LEN
state_puzzle_chapel_check_puzzle_solved_loop:
	ld a,(de)
	inc de
	cpi
	ret nz
	ld a,c
	or a
	jr nz,state_puzzle_chapel_check_puzzle_solved_loop

	; puzzle solved!!!
	call puzzle_solved_sound

	ld c,TIME_SUBBASEMENT_OPEN
	call update_state_time_day_if_needed

	; Lose the torn note:
	ld a,INVENTORY_LUCY_TORN_NOTE
	call inventory_find_slot
	jr nz,state_puzzle_chapel_check_puzzle_solved_no_torn_note
	ld (hl),0  ; lose the item from inventory
	call hud_update_inventory
state_puzzle_chapel_check_puzzle_solved_no_torn_note:

	call render_full_room
	pop af  ; restore the stack
	jp open_chapel_altar_from_page3


state_puzzle_chapel_space_or_pressed:
	ld a,(de)
	or a
	ret z
	; check if the previous button is pressed already:
	push hl
		ld bc,puzzle_current_letters - chapel_puzzle_message
		ex de,hl
		add hl,bc
		ld a,(hl)
	pop hl
	xor 1
	ret


state_puzzle_chapel_press_letter_before_space:
	; move down the tile to the right as well
	push hl
		ld bc,14
		add hl,bc
		ld de,text_draw_buffer
		ld bc,2
		push de
		push hl
		push bc
			call LDIRMV
		pop bc
		pop de
		pop hl
		ld a,(hl)
		xor #80
		ld (hl),a
		inc hl
		ld a,(hl)
		xor #80
		ld (hl),a
		dec hl
		call fast_LDIRVM
	pop hl
	ret

state_puzzle_chapel_release_letter_vdp_ram:
	; VDP -> RAM:
	push hl
		ld de,text_draw_buffer
		ld bc,8
		push bc
			push hl
				call LDIRMV
			pop hl
			ld bc,32*8
			add hl,bc
		pop bc
		ld de,text_draw_buffer+8
		push bc
			push hl
				call LDIRMV
			pop hl
			ld bc,32*8
			add hl,bc
		pop bc
		ld de,text_draw_buffer+16
		call LDIRMV
	pop hl
	ret


state_puzzle_chapel_release_letter_ram_vdp:
	; RAM -> VDP:
	ld hl,text_draw_buffer
	ld bc,8
	push bc
		push de
			call fast_LDIRVM
		pop hl
		ld bc,32*8
		add hl,bc
		ex de,hl
	pop bc
	ld hl,text_draw_buffer+8
	push bc
		push de
			call fast_LDIRVM
		pop hl
		ld bc,32*8
		add hl,bc
		ex de,hl
	pop bc
	ld hl,text_draw_buffer+16
	jp fast_LDIRVM


;-----------------------------------------------
state_puzzle_chapel_draw_letters:
	ld a,(current_language_page)
	SETMEGAROMPAGE_A000_A

	ld ix,chapel_puzzle_message
	ld iy,chapel_puzzle_message_offsets
	ld de,CHRTBL2+(6*32+6)*8
	ld b,CHAPEL_PUZZLE_MESSAGE_LEN
state_puzzle_chapel_draw_letters_loop:
	push bc
		push de
		    ld hl,text_draw_buffer
		    ld bc,8
		    ld a,#80
		    call clear_memory_a	
		pop de
		push iy
		push ix
			ld hl,text_buffer
			ld (hl),1  ; length
			inc hl
			ld a,(ix)
			ld (hl),a
			dec hl
			or a  ; for the call nz below
			ld a,(iy)
			ld iyl,COLOR_DARK_BLUE
			ld iyh,a
			ld bc,8
			push bc
			push de
				call nz,draw_sentence	; only draw if letter is != 0
			pop hl
			pop bc
			add hl,bc
			ex de,hl
		pop ix
		pop iy
		inc ix
		inc iy
	pop bc
	djnz state_puzzle_chapel_draw_letters_loop
	ret

