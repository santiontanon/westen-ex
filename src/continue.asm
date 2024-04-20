;-----------------------------------------------
; returns:
; - z: start from scratch
; - nz: continue
ask_whether_to_continue_or_not_page_changed:
	; Check if we need to load a game:
    ld a,(RAM_game_saved)
    or a
    ret z

    ld a,18*8
    ld bc,TEXT_CONTINUE1
    ld de,CHRTBL2 + (18*32 + 8)*8 
    ld iyl,COLOR_WHITE*16
    call draw_text_from_bank_multilingual
    ld bc,0
    xor a
    ld (continue_yes_no),a
state_gamestart_continue_yes_no_loop:
	halt

    push bc
        ld a,c
        and #07
        jr nz,state_gamestart_continue_yes_no_loop_continue
        bit 4,c
        jr nz,state_gamestart_continue_yes_no_loop_white
state_gamestart_continue_yes_no_loop_black:
        ld a,(continue_yes_no)
        or a
        jr z,state_gamestart_continue_yes_no_loop_no
state_gamestart_continue_yes_no_loop_yes:
        ld a,16*8
        ld bc,TEXT_CONTINUE2
        ld de,CHRTBL2 + (20*32 + 15)*8 
        ld iyl,COLOR_BLACK*16
        call draw_text_from_bank_multilingual
        jr state_gamestart_continue_yes_no_loop_continue

state_gamestart_continue_yes_no_loop_no:
        ld a,16*8
        ld bc,TEXT_CONTINUE3
        ld de,CHRTBL2 + (20*32 + 15)*8 
        ld iyl,COLOR_BLACK*16
        call draw_text_from_bank_multilingual
        jr state_gamestart_continue_yes_no_loop_continue

state_gamestart_continue_yes_no_loop_white:
        ld a,COLOR_WHITE*16
        ld hl,CLRTBL2 + (20*32 + 15)*8 
        ld bc,#0102
        call clear_rectangle_bitmap_mode_color
state_gamestart_continue_yes_no_loop_continue:

        call update_keyboard_buffers
        ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
        bit KEY_BUTTON1_BIT,a
    pop bc
	jr nz,state_gamestart_continue_yes_no_loop_end
    dec bc

    ld a,(keyboard_line_clicks+KEY_LEFT_BYTE)
    bit KEY_LEFT_BIT,a
    jp nz,state_gamestart_continue_yes_no_loop_change
    bit KEY_RIGHT_BIT,a
    jp nz,state_gamestart_continue_yes_no_loop_change

    jr state_gamestart_continue_yes_no_loop

state_gamestart_continue_yes_no_loop_end:
    ; start from scratch:
    ld a,(continue_yes_no)
    or a
    ret


state_gamestart_continue_yes_no_loop_change:
    ld a,(continue_yes_no)
    xor 1
    ld (continue_yes_no),a
    jr state_gamestart_continue_yes_no_loop
