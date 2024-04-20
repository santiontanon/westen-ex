;-----------------------------------------------
state_title_page_changed:
	call play_music_game_title

	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
    ld hl,title_zx0
    ld de,buffer1024
    call dzx0_standard

    call clearAllTheSprites
    call set_bitmap_mode

	ld ix, buffer1024  ; start of the name table of the title
	ld de, CHRTBL2 + 32*8 * 4
	ld b,32
state_title_loop_x:
	halt
	push bc
		ld b,8
; 		ld b,9
		push ix
			push de
state_title_loop_y:
			push bc
				ld a,(ix)
				ld bc,32
				add ix,bc

				; hl = (buffer1024+32*8) + a*16
				ld h,b  ; b == 0 here
				ld l,a
				add hl,hl
				add hl,hl
				add hl,hl
				add hl,hl
				ld bc,buffer1024+32*8
; 				ld bc,buffer1024+32*9
				add hl,bc

				push de
					call draw_tile_bitmap_mode
				pop hl
				ld bc,32*8
				add hl,bc
				ex de,hl
			pop bc
			djnz state_title_loop_y
			pop hl
			ld bc,8
			add hl,bc
			ex de,hl
		pop ix
		inc ix
	pop bc
	djnz state_title_loop_x


    ld a,16*8
    ld bc,TEXT_CREDITS1
    ld de,CHRTBL2 + (21*32 + 11)*8 
    ld iyl,COLOR_WHITE*16
    call draw_text_from_bank_multilingual

    ld a,18*8
    ld bc,TEXT_CREDITS2
    ld de,CHRTBL2 + (22*32 + 7)*8 
    ld iyl,COLOR_WHITE*16
    call draw_text_from_bank_multilingual

    ld a,23*8
    ld bc,TEXT_CREDITS3
    ld de,CHRTBL2 + (23*32 + 5)*8 
    ld iyl,COLOR_WHITE*16
    call draw_text_from_bank_multilingual


    ld a,16*8
    ld bc,TEXT_CONTROLS
    ld de,CHRTBL2 + (15*32 + 10)*8 
    ld iyl,COLOR_WHITE*16
    call draw_text_from_bank_multilingual

    ld bc,#03ff
state_title_loop:
	halt
	push bc
		ld a,c
		and #07
		jr nz,state_title_loop_continue
		ld a,c
		bit 4,a
		jr nz,state_title_loop_white
state_title_loop_black:
		rla
		jr nc,state_title_loop_black_space
state_title_loop_black_controls:
	    ld a,16*8
	    ld bc,TEXT_CONTROLS
	    ld de,CHRTBL2 + (15*32 + 10)*8 
	    ld iyl,COLOR_BLACK*16
	    call draw_text_from_bank_multilingual
	    jr state_title_loop_continue

state_title_loop_black_space:
	    ld a,16*8
	    ld bc,TEXT_START
	    ld de,CHRTBL2 + (15*32 + 10)*8 
	    ld iyl,COLOR_BLACK*16
	    call draw_text_from_bank_multilingual
	    jr state_title_loop_continue

state_title_loop_white:
		ld a,COLOR_WHITE*16
		ld hl,CLRTBL2 + (15*32 + 10)*8 
		ld bc,#0110
		call clear_rectangle_bitmap_mode_color
state_title_loop_continue:

		call update_keyboard_buffers
	    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
	    bit KEY_BUTTON1_BIT,a
	pop bc
    jp nz,state_gamestart

    ld a,(keyboard_line_clicks+KEY_BUTTON2_BYTE)
    bit KEY_BUTTON2_BIT,a
    jp nz,state_tutorial
    bit KEY_BUTTON2_BIT_ALTERNATIVE,a
    jp nz,state_tutorial

    dec bc
    ld a,b
    or c
    jp z,state_intro  ; time out!
	jr state_title_loop


