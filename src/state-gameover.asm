;-----------------------------------------------
state_game_over_page_changed:
    ; init the stack:
    ld sp,#f380

    call play_music_game_over

    call disable_VDP_output
        call clearAllTheSprites
        call set_bitmap_mode

        ld a,8*8
        ld bc,TEXT_GAME_OVER
        ld de,CHRTBL2 + (10*32 + 13)*8 
        ld iyl,COLOR_WHITE*16
        call draw_text_from_bank_multilingual
    call enable_VDP_output

    ; wait for button:
    ld c,10
    call state_intro_pause
    call clearScreenLeftToRight_bitmap
;     jp Execute_back_to_intro
    jp state_intro