; English / Spanish text (this is not compressed as it needs to be
; rendered before language has been selected and all language
; variables are populated):

en_language_selection_str:
	db 7, 51, 130, 117, 126, 121, 140, 119
es_language_selection_str:
	db 7, 51, 140, 134, 105, 169, 132, 126

state_language_selection_page_set:
    call clearAllTheSprites
    call clearScreenLeftToRight_bitmap
    call set_bitmap_mode

	xor a
	ld (language_selection_pos),a
state_language_selection_loop:
	halt

    call clear_text_rendering_buffer
	ld hl,en_language_selection_str
    ld de,CHRTBL2 + (10*32 + 13)*8
    ld bc,6*8
    ld a,(language_selection_pos)
    or a
    jr nz,state_language_selection_loop_en_white
    ld a,(interrupt_cycle)
    bit 3,a
    jr z,state_language_selection_loop_en_black
state_language_selection_loop_en_white:
    ld iy,COLOR_WHITE*16 + 128*256
    jr state_language_selection_loop_en_color_set
state_language_selection_loop_en_black:
	ld iy,COLOR_BLACK*16 + 128*256
state_language_selection_loop_en_color_set:
	call draw_sentence

state_language_selection_loop_es:
    call clear_text_rendering_buffer
	ld hl,es_language_selection_str
    ld de,CHRTBL2 + (12*32 + 13)*8 
    ld iy,COLOR_WHITE*16 + 128*256
    ld bc,6*8
    ld a,(language_selection_pos)
    or a
    jr z,state_language_selection_loop_es_white
    ld a,(interrupt_cycle)
    bit 3,a
    jr z,state_language_selection_loop_es_black
state_language_selection_loop_es_white:
    ld iy,COLOR_WHITE*16 + 128*256
    jr state_language_selection_loop_es_color_set
state_language_selection_loop_es_black:
	ld iy,COLOR_BLACK*16 + 128*256
state_language_selection_loop_es_color_set:
	call draw_sentence

    ; keyboard control:
    call update_keyboard_buffers
    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
    bit KEY_BUTTON1_BIT,a
    jr nz,state_language_selection_loop_done

    ld a,(keyboard_line_clicks+KEY_UP_BYTE)
    bit KEY_UP_BIT,a
    jp nz,state_language_selection_loop_done_change
    bit KEY_DOWN_BIT,a
    jp nz,state_language_selection_loop_done_change
	jr state_language_selection_loop
state_language_selection_loop_done_change:
    ld a,(language_selection_pos)
    xor 1
    ld (language_selection_pos),a
    jr state_language_selection_loop

state_language_selection_loop_done:
    ld a,(language_selection_pos)
    or a
    jr nz,state_language_selection_es

state_language_selection_en:
    ld a,TEXT_PAGE_EN
    ld de,en_text_table
    ld hl,textBankPointers_en
    jr state_language_selection_continue
state_language_selection_es:
    ld a,TEXT_PAGE_ES
    ld de,es_text_table
    ld hl,textBankPointers_es
state_language_selection_continue:
    ld (current_language_page),a
    ld (current_language_table),de
    ld (current_language_bank_ptr),hl
    jp state_intro
    