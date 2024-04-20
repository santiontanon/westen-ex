;-----------------------------------------------
; Code that goes to another state, properly changing megaROM pages:


; page 2 states:
state_intro:
	SETMEGAROMPAGE_8000 2
	jp state_intro_page_changed

state_gamestart:
	SETMEGAROMPAGE_8000 2
	jp state_gamestart_page_changed

ask_whether_to_continue_or_not:
    SETMEGAROMPAGE_8000 3
    call ask_whether_to_continue_or_not_page_changed
    SETMEGAROMPAGE_8000 2
    ret

state_language_selection:
	SETMEGAROMPAGE_8000 3
    jp state_language_selection_page_set

state_game:
	SETMEGAROMPAGE_8000 2
	jp state_game_page_changed

family_cutscene:
	SETMEGAROMPAGE_8000 2
	jp family_cutscene_page_changed

lucy_cutscene:
	SETMEGAROMPAGE_8000 2
	jp lucy_cutscene_page_changed

state_travel_cutscene:
	SETMEGAROMPAGE_8000 3
	jp state_travel_cutscene_page_changed


; page 3 states:
vlad_ritual_cutscene:
	SETMEGAROMPAGE_8000 2
	jp vlad_ritual_cutscene_page_changed

state_travel_cutscene_end:
	SETMEGAROMPAGE_8000 2
    ; Appear in Westen house:
	xor a
	ld (state_current_room),a
	ld hl,map1_zx0
	ld de,0*256+0
	call teleport_player_to_room
	ld hl,player_iso_x
	ld (hl),8*8
	inc hl
	ld (hl),12*8
	ld hl,player_direction
	ld (hl),1	

	call disable_VDP_output
	call hud_update_inventory
	ld c,TIME_REACH_WESTEN_HOUSE
	call update_state_time_day_if_needed
	jp state_game


state_title:
	SETMEGAROMPAGE_8000 3
	jp state_title_page_changed

state_tutorial:
	SETMEGAROMPAGE_8000 3
	jp state_tutorial_page_changed

state_ending:
	SETMEGAROMPAGE_8000 3
	jp state_ending_page_changed

state_game_over:
	SETMEGAROMPAGE_8000 3
	jp state_game_over_page_changed

state_password_lock:
	SETMEGAROMPAGE_8000 3
	push ix
		call inter_music_pause
		call play_music_riddle_solving
		call state_password_lock_internal
		call inter_music_pause
; 		call play_music_ingame_cellar15  ; We do not play the song yet, as maybe the puzzle was solved and we need to play the puzzle solved tune!
	pop ix
	SETMEGAROMPAGE_8000 2
	ret

state_puzzle_chapel:
	SETMEGAROMPAGE_8000 3
	push ix
		call inter_music_pause
		call play_music_riddle_solving
		call state_puzzle_chapel_internal
		call inter_music_pause
		call play_music_ingame_cellar15
	pop ix
	SETMEGAROMPAGE_8000 2
	ret

state_puzzle_box:
	SETMEGAROMPAGE_8000 3
	push ix
		call inter_music_pause
		call play_music_riddle_solving
		call state_puzzle_box_internal
		call inter_music_pause
	pop ix
	SETMEGAROMPAGE_8000 2
	ret


open_chapel_altar_from_page3:
	SETMEGAROMPAGE_8000 2
	jp open_chapel_altar


