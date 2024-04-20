;-----------------------------------------------
state_tutorial_page_changed:
	call StopMusic
	call clearScreenLeftToRight_bitmap
	call display_tutorial1
	call display_tutorial2
	call display_tutorial3
	call display_tutorial4
	jp state_title


;-----------------------------------------------
draw_text_from_bank_white:
    ld iyl,COLOR_WHITE
    jp draw_text_from_bank_multilingual


;-----------------------------------------------
display_tutorial1:
	call disable_VDP_output
		; draw letter:
	    ld a,COLOR_WHITE + COLOR_WHITE*16
	    ld hl,CLRTBL2 + (4*32 + 6)*8
	    ld bc,#0d14
	    call clear_rectangle_bitmap_mode_color	

	    SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
	    ld hl,tutorial_zx0
	    ld de,buffer1024
	    call dzx0_standard

		; Draw tutorial gfx:
		ld ix,buffer1024
		ld iy,20
		ld de,CHRTBL2+(9*32+11)*8
		ld bc,#050a
		ld hl,buffer1024+20*12
		ld (draw_hud_chunk_tile_ptr),hl
		call draw_hud_chunk

		; Draw tutorial text:
	    ld a,18*8
	    ld bc,TEXT_TUTORIAL1_LINE1
	    ld de,CHRTBL2 + (5*32 + 8)*8 
	    call draw_text_from_bank_white

	    ld a,18*8
	    ld bc,TEXT_TUTORIAL1_LINE2
	    ld de,CHRTBL2 + (7*32 + 8)*8 
	    call draw_text_from_bank_white

	    ld a,18*8
	    ld bc,TEXT_TUTORIAL1_LINE3
	    ld de,CHRTBL2 + (15*32 + 8)*8 
	    call draw_text_from_bank_white

display_tutorial_entrypoint:
	call enable_VDP_output

	; wait for button:
	call wait_for_space
	jp clearScreenLeftToRight_bitmap


;-----------------------------------------------
display_tutorial2:
	call disable_VDP_output
		; draw letter:
	    ld a,COLOR_WHITE + COLOR_WHITE*16
	    ld hl,CLRTBL2 + (2*32 + 6)*8
	    ld bc,#0e14
	    call clear_rectangle_bitmap_mode_color	

	    SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
	    ld hl,tutorial_zx0
	    ld de,buffer1024
	    call dzx0_standard

		; Draw tutorial gfx:
		ld ix,buffer1024+10
		ld iy,20
		ld de,CHRTBL2+(10*32+11)*8
		ld bc,#050a
		ld hl,buffer1024+20*12
		ld (draw_hud_chunk_tile_ptr),hl
		call draw_hud_chunk

		; Draw tutorial text:
	    ld a,18*8
	    ld bc,TEXT_TUTORIAL2_LINE1
	    ld de,CHRTBL2 + (3*32 + 7)*8 
	    call draw_text_from_bank_white

	    ld a,18*8
	    ld bc,TEXT_TUTORIAL2_LINE2
	    ld de,CHRTBL2 + (5*32 + 7)*8 
	    call draw_text_from_bank_white

	    ld a,18*8
	    ld bc,TEXT_TUTORIAL2_LINE3
	    ld de,CHRTBL2 + (7*32 + 7)*8 
	    call draw_text_from_bank_white

	    ld a,18*8
	    ld bc,TEXT_TUTORIAL2_LINE4
	    ld de,CHRTBL2 + (9*32 + 7)*8 
	    call draw_text_from_bank_white

	    jr display_tutorial_entrypoint


;-----------------------------------------------
display_tutorial3:
	call disable_VDP_output

		; draw letter:
	    ld a,COLOR_WHITE + COLOR_WHITE*16
	    ld hl,CLRTBL2 + (1*32 + 5)*8
	    ld bc,#1316
	    call clear_rectangle_bitmap_mode_color	

	    SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
	    ld hl,tutorial_zx0
	    ld de,buffer1024
	    call dzx0_standard

		; Draw tutorial gfx:
		ld ix,buffer1024+5*20+10
		ld iy,20
		ld de,CHRTBL2+(12*32+9)*8
		ld bc,#070a
		ld hl,buffer1024+20*12
		ld (draw_hud_chunk_tile_ptr),hl
		call draw_hud_chunk

		; Draw tutorial text:
	    ld a,20*8
	    ld bc,TEXT_TUTORIAL4_LINE1
	    ld de,CHRTBL2 + (2*32 + 6)*8 
	    call draw_text_from_bank_white

	    ld a,20*8
	    ld bc,TEXT_TUTORIAL4_LINE2
	    ld de,CHRTBL2 + (4*32 + 6)*8 
	    call draw_text_from_bank_white

	    ld a,20*8
	    ld bc,TEXT_TUTORIAL4_LINE3
	    ld de,CHRTBL2 + (6*32 + 6)*8 
	    call draw_text_from_bank_white

	    ld a,20*8
	    ld bc,TEXT_TUTORIAL4_LINE4
	    ld de,CHRTBL2 + (8*32 + 6)*8 
	    call draw_text_from_bank_white

	    ld a,20*8
	    ld bc,TEXT_TUTORIAL4_LINE5
	    ld de,CHRTBL2 + (10*32 + 6)*8 
	    call draw_text_from_bank_white

	    ld a,20*8
	    ld bc,TEXT_TUTORIAL4_LINE6
	    ld de,CHRTBL2 + (12*32 + 6)*8 
	    call draw_text_from_bank_white

		jp display_tutorial_entrypoint


;-----------------------------------------------
display_tutorial4:
	call disable_VDP_output
		; draw letter:
	    ld a,COLOR_WHITE + COLOR_WHITE*16
	    ld hl,CLRTBL2 + (3*32 + 6)*8
	    ld bc,#0d14
	    call clear_rectangle_bitmap_mode_color	

	    SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
	    ld hl,tutorial_zx0
	    ld de,buffer1024
	    call dzx0_standard

		; Draw tutorial gfx:
		ld ix,buffer1024+5*20
		ld iy,20
		ld de,CHRTBL2+(8*32+11)*8
		ld bc,#070a
		ld hl,buffer1024+20*12
		ld (draw_hud_chunk_tile_ptr),hl
		call draw_hud_chunk

		; Draw tutorial text:
	    ld a,17*8
	    ld bc,TEXT_TUTORIAL3_LINE1
	    ld de,CHRTBL2 + (4*32 + 8)*8 
	    call draw_text_from_bank_white

	    ld a,17*8
	    ld bc,TEXT_TUTORIAL3_LINE2
	    ld de,CHRTBL2 + (6*32 + 8)*8 
	    call draw_text_from_bank_white

	    jp display_tutorial_entrypoint
