;-----------------------------------------------
; dummy file, place holder for real music player

;-----------------------------------------------
StopMusic: 
	xor a
    ld (current_music),a	
StopMusic_internal: 
	jp wyz_player_off


;-----------------------------------------------
inter_music_pause:
	; Little pause in between musics
	call StopMusic
	ld b,10
	jp wait_b_halts


;-----------------------------------------------
puzzle_solved_sound:
	call StopMusic
	ld hl,SFX_puzzle_solved
	call play_SFX_with_high_priority

	ld b,50
	call wait_b_halts

	ld de,music_riddle_solved
	ld a,MUSIC_RIDDLE_SOLVED_PAGE
    ld (current_music_page),a
	SETMEGAROMPAGE_A000_A
	call wyz_carga_cancion

	ld b,100
	jp wait_b_halts


;-----------------------------------------------
play_music_fns:
	dw StopMusic
	dw play_music_game_start
	dw play_music_intro
	dw play_music_ingame_london
	dw play_music_ingame_house1
	dw play_music_ingame_house2
	dw play_music_game_over
	dw play_music_game_title
	dw play_music_ingame_house3
	dw play_music_ingame_cellar
	dw play_music_ingame_cellar15
	dw play_music_ingame_vampire
	dw play_music_family_cutscene
	dw play_music_lucy_cutscene
	dw play_music_ingame_subbasement
	dw play_music_london_streets
	dw play_music_ingame_house_yard
	dw play_music_ingame_travel
	dw play_music_riddle_solving
	dw 0 ; puzzle_solved_sound
	dw music_ingame_subbasement2
	dw music_ingame_ritual_cutscene
	dw play_music_ending_1a
	dw play_music_ingame_secret_miniboss
	dw play_music_ingame_miniboss
	dw play_music_ending_1b
	dw play_music_ending_2

play_music_a:
	ld hl,play_music_fns
	add a,a
	ld b,0
	ld c,a
	add hl,bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jp hl


;-----------------------------------------------
play_music_intro:
	ld bc,MUSIC_INGAME_INTRO_ID + 256*MUSIC_INGAME_INTRO_PAGE
	ld de,music_intro
play_music_entry_point:
	ld a,(current_music)
	cp c
	ret z
    ld a,c
    ld (current_music),a
    ld a,b
    ld (current_music_page),a
	push de
		call StopMusic_internal
	pop de
;     jp play_music_internal

;-----------------------------------------------
; - de: Song pointer.
play_music_internal:
	ld a,(current_music_page)
	SETMEGAROMPAGE_A000_A
	jp wyz_carga_cancion


play_music_game_start:
	ld bc,MUSIC_GAME_START_ID + 256*MUSIC_GAME_START_PAGE
	ld de,music_game_start
	jr play_music_entry_point


play_music_ingame_london:
	ld bc,MUSIC_INGAME_LONDON_ID + 256*MUSIC_INGAME_LONDON_PAGE
	ld de,music_ingame_london
	jr play_music_entry_point


play_music_ingame_travel:
	ld bc,MUSIC_INGAME_TRAVEL_ID + 256*MUSIC_INGAME_TRAVEL_PAGE
	ld de,music_ingame_travel
	jr play_music_entry_point


play_music_ingame_house_yard:
	ld bc,MUSIC_INGAME_HOUSE_YARD_ID + 256*MUSIC_INGAME_HOUSE_YARD_PAGE
	ld de,music_ingame_house_yard
	jr play_music_entry_point


play_music_ingame_house1:
	ld bc,MUSIC_INGAME_HOUSE1_ID + 256*MUSIC_INGAME_HOUSE1_PAGE
	ld de,music_ingame_house1
	jr play_music_entry_point


play_music_ingame_house2:
	ld bc,MUSIC_INGAME_HOUSE2_ID + 256*MUSIC_INGAME_HOUSE2_PAGE
	ld de,music_ingame_house2
	jr play_music_entry_point


play_music_ingame_house3:
	ld bc,MUSIC_INGAME_HOUSE3_ID + 256*MUSIC_INGAME_HOUSE3_PAGE
	ld de,music_ingame_house3
	jr play_music_entry_point


play_music_ingame_cellar:
	ld bc,MUSIC_INGAME_CELLAR_ID + 256*MUSIC_INGAME_CELLAR_PAGE
	ld de,music_ingame_cellar
	jr play_music_entry_point


play_music_ingame_cellar15:
	ld bc,MUSIC_INGAME_CELLAR15_ID + 256*MUSIC_INGAME_CELLAR15_PAGE
	ld de,music_ingame_cellar15
	jr play_music_entry_point


; hl: pointer to the vampire state variable corresponding to this vampire
play_music_ingame_vampire:
	ld a,(hl)
	cp 2  ; if the vampire is dead, do not change the music!
	ret z
	ld bc,MUSIC_INGAME_VAMPIRE_ID + 256*MUSIC_INGAME_VAMPIRE_PAGE
	ld de,music_ingame_vampire
	jr play_music_entry_point


play_music_family_cutscene:
	ld bc,MUSIC_INGAME_FAMILY_CUTSCENE_ID + 256*MUSIC_INGAME_FAMILY_CUTSCENE_PAGE
	ld de,music_ingame_family_cutscene
	jr play_music_entry_point

play_music_lucy_cutscene:
	ld bc,MUSIC_INGAME_LUCY_CUTSCENE_ID + 256*MUSIC_INGAME_LUCY_CUTSCENE_PAGE
	ld de,music_ingame_lucy_cutscene
	jp play_music_entry_point

play_music_ending_1a:
	ld bc,MUSIC_ENDING_1A_ID + 256*MUSIC_ENDING_1A_PAGE
	ld de,music_ending_1a
	jp play_music_entry_point

play_music_ending_1b:
	ld bc,MUSIC_ENDING_1B_ID + 256*MUSIC_ENDING_1B_PAGE
	ld de,music_ending_1b
	jp play_music_entry_point

play_music_ending_2:
	ld bc,MUSIC_ENDING_2_ID + 256*MUSIC_ENDING_2_PAGE
	ld de,music_ending_2
	jp play_music_entry_point

play_music_game_over:
	ld bc,MUSIC_GAME_OVER_ID + 256*MUSIC_GAME_OVER_PAGE
	ld de,music_game_over
	jp play_music_entry_point

play_music_game_title:
	ld bc,MUSIC_GAME_TITLE_ID + 256*MUSIC_GAME_TITLE_PAGE
	ld de,music_game_title
	jp play_music_entry_point

play_music_london_streets:
	ld bc,MUSIC_LONDON_STREETS_ID + 256*MUSIC_LONDON_STREETS_PAGE
	ld de,music_london_streets
	jp play_music_entry_point

play_music_riddle_solving:
	ld bc,MUSIC_RIDDLE_SOLVING_ID + 256*MUSIC_RIDDLE_SOLVING_PAGE
	ld de,music_riddle_solving
	jp play_music_entry_point

play_music_ingame_subbasement:
	ld bc,MUSIC_INGAME_SUBBASEMENT_ID + 256*MUSIC_INGAME_SUBBASEMENT_PAGE
	ld de,music_ingame_subbasement
	jp play_music_entry_point

play_music_ingame_subbasement2:
	ld bc,MUSIC_INGAME_SUBBASEMENT2_ID + 256*MUSIC_INGAME_SUBBASEMENT2_PAGE
	ld de,music_ingame_subbasement2
	jp play_music_entry_point

play_music_ritual_cutscene:
	ld bc,MUSIC_RITUAL_CUTSCENE_ID + 256*MUSIC_RITUAL_CUTSCENE_PAGE
	ld de,music_ingame_ritual_cutscene
	jp play_music_entry_point

play_music_ingame_miniboss:
	ld bc,MUSIC_BOSS_B_ID + 256*MUSIC_BOSS_B_PAGE
	ld de,music_boss_b
	jp play_music_entry_point

play_music_ingame_secret_miniboss:
	ld bc,MUSIC_BOSS_A_ID + 256*MUSIC_BOSS_A_PAGE
	ld de,music_boss_a
	jp play_music_entry_point


;-----------------------------------------------
; - hl: sfx pointer.
play_SFX_with_high_priority:
	di
		ld (SFX_player_pointer),hl
		ld a,1
		ld (SFX_player_active),a
		; copy over the register state from the music player:
; 		ld a,(wyz_psg_reg+7)
; 		set 1,a  ; 0: channel A, 1: channel B, 2: channel C
; 		set 4,a  ; 3: channel A, 4: channel B, 5: channel C
; 		ld (SFX_player_registers+3),a
	ei
	ret


;-----------------------------------------------
; SFX format (taken form the ayfxedit documentation):
; Every frame encoded with a flag byte and a number of bytes, 
; which is vary depending from value change flags.
; - bit0..3  Volume
; - bit4     Disable T
; - bit5     Change Tone
; - bit6     Change Noise
; - bit7     Disable N
; When the bit5 set, two bytes with tone period will follow; when the bit6 set, 
; a single byte with noise period will follow; when both bits are set, first two 
; bytes of tone period, then single byte with noise period will follow. When none 
; of the bits are set, next flags byte will follow.
; End of the effect is marked with byte sequence #D0, #20. Player should detect it 
; before outputting it to the AY registers, by checking noise period value to be equal #20.
;-----------------------------------------------
; Plays a sound effect on PSG channel B
; hl: sfx pointer
play_ayfx:
    ld a,SFX_PAGE  ; change the page without recording it, so we can restore it later
    ld (#a000),a
	ld hl,(SFX_player_pointer)
	ld a,(wyz_psg_reg_sec+7) ; Register 7	
; 	ld a,(SFX_player_registers+3)  ; Register 7
; 	and #db ; activate tone/noise by default (channel C) 11011011
	and #ed ; activate tone/noise by default (channel B) 11101101
	ld d,a  ; d will maintain the value to be written in R7
	ld a,(hl)
	inc hl
	cp #d0
	jr z,play_ayfx_end_check
play_ayfx_continue1:
	; volume:
	push af
		and #0f
		ld (SFX_player_registers+4),a  ; SFX channel volume
	pop af
	bit 4,a
	jr z,play_ayfx_continue2
play_ayfx_disable_tone:
	set 1,d  ; 0: channel A, 1: channel B, 2: channel C
play_ayfx_continue2:
	bit 7,a
	jr z,play_ayfx_continue3
play_ayfx_disable_noise:
	set 4,d  ; 3: channel A, 4: channel B, 5: channel C
play_ayfx_continue3:
	bit 5,a
	jr z,play_ayfx_continue4
	push af
		; since there is tone period, we activate the tone in the SFX channel
; 		res 1,d  ; 0: channel A, 1: channel B, 2: channel C
		ld a,(hl)
		inc hl
		ld (SFX_player_registers+0),a  ; (channel period 1)
		ld a,(hl)
		inc hl
		ld (SFX_player_registers+1),a  ; (channel period 2)
	pop af
play_ayfx_continue4:
	bit 6,a
	jr z,play_ayfx_continue5
; 	push af
		; since there is noise frequency, we activate the noise in the SFX channel
; 		res 4,d  ; 3: channel A, 4: channel B, 5: channel C
		ld a,(hl)
		inc hl
		ld (SFX_player_registers+2),a  ; register 6 (noise tone)
; 	pop af
play_ayfx_continue5:
	; write register 7:
	ld a,d
	ld (SFX_player_registers+3),a  ; register 7 (which channels are active)
	ld (SFX_player_pointer),hl
	; overwrite wyz player registers:
	ld hl,SFX_player_registers
	; Channel A:
; 	ld de,wyz_psg_reg_sec
; 	ldi  ; R0
; 	ldi  ; R1
; 	inc de
; 	inc de
; 	inc de
; 	inc de
; 	ldi  ; R6
; 	ldi  ; R7
; 	ldi  ; R8

	; Channel B:
	ld de,wyz_psg_reg_sec+2
	ldi  ; R2
	ldi  ; R3
	inc de
	inc de
	ldi  ; R6
	ldi  ; R7
	inc de
	ldi  ; R9

	; Channel C:
; 	ld de,wyz_psg_reg_sec+4
; 	ldi  ; R4
; 	ldi  ; R5
; 	ldi  ; R6
; 	ldi  ; R7
; 	inc de
; 	inc de
; 	ldi  ; R10
	ret
	
play_ayfx_end_check:
	ld a,(hl)
	cp #20
	jr z,play_ayfx_end
	dec hl
	ld a,(hl)
	inc hl
	jr play_ayfx_continue1

play_ayfx_end:
	ld a,d
	set 1,a  ; 0: channel A, 1: channel B, 2: channel C
	set 4,a  ; 3: channel A, 4: channel B, 5: channel C
	ld (SFX_player_registers+3),a  ; register 7 (which channels are active)
	xor a
	ld (SFX_player_active),a
    ret

