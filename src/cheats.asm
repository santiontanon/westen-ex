;-----------------------------------------------
handle_cheats:
	; Read number keys:
    xor a
    call SNSMAT

	; Check if any number key was pressed:
	bit 0,a  ; 0
	jp z,handle_cheats_cheat10  ; secondary mission

	bit 1,a  ; 1
	jr z,handle_cheats_cheat1

	bit 2,a  ; 2
	jp z,handle_cheats_cheat2

	bit 3,a  ; 3
	jp z,handle_cheats_cheat3  ; about to open the safe

	bit 4,a  ; 4
	jp z,handle_cheats_cheat4  ; about the solve the candle puzzle

	bit 5,a  ; 5
	jp z,handle_cheats_cheat5  ; just before cutscene 1

	bit 6,a  ; 6
	jp z,handle_cheats_cheat6  ; in front of a vampire door

	bit 7,a  ; 7
	jp z,handle_cheats_cheat7  ; just before chapel puzzle

    ld a,1
    call SNSMAT

	bit 0,a  ; 8
	jp z,handle_cheats_cheat8  ; vlad statue

	bit 1,a  ; 9
	jp z,handle_cheats_cheat9  ; prison
	ret


;-----------------------------------------------
handle_cheats_cheat1: ; game start
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_WHITE_KEY
	inc hl
	ld (hl),INVENTORY_RED_KEY_H1
	ld hl,state_game_time_day
	ld (hl),TIME_START
	ld hl,map5_zx0
	ld de,0 + 0*256  ; e: room, d: door
	ld a,64
	ld (state_current_room),a
	call teleport_player_to_room	
	ld hl,player_iso_x
	ld (hl),5*8
	inc hl
	ld (hl),6*8
	ld hl,player_direction
	ld (hl),4
	call clearAllTheSprites
    call clearScreenLeftToRight_bitmap	
	jp state_game


;-----------------------------------------------
handle_cheats_cheat2: ; garden
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_WHITE_KEY
	inc hl
	ld (hl),INVENTORY_RED_KEY_H1
	inc hl
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	ld hl,state_newspaper_taken
	ld (hl),1
	ld hl,state_choffeur_store
	ld (hl),3
	ld hl,state_game_time_day
	ld (hl),TIME_REACH_WESTEN_HOUSE
	ld hl,map1_zx0
	ld de,0 + 0*256  ; e: room, d: door
	ld a,0
handle_cheats_entry_point:
	ld (state_current_room),a
	call teleport_player_to_room
	call clearAllTheSprites
    call clearScreenLeftToRight_bitmap	
	jp state_game


;-----------------------------------------------
handle_cheats_cheat3: ; about to open the safe
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_RED_KEY_H1
	inc hl
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_CANDLE
	inc hl
	ld (hl),INVENTORY_LETTER3
	ld hl,state_choffeur_store
	ld (hl),3
	ld hl,state_candle1_position
	ld (hl),#ff
	ld hl,state_letter3_taken
	ld (hl),4
	ld hl,state_game_time_day
	ld (hl),TIME_CODE_SEEN
	ld hl,map1_zx0
	ld de,2 + 0*256  ; e: room, d: door
	ld a,2
	jp handle_cheats_entry_point


;-----------------------------------------------
handle_cheats_cheat4: ; about to solve the candle puzzle
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_CANDLE
	inc hl
	ld (hl),INVENTORY_CANDLE
	inc hl
	ld (hl),INVENTORY_BOOK
	ld hl,state_choffeur_store
	ld (hl),3
	ld hl,state_candle1_position
	ld (hl),#ff
	ld hl,state_candle2_position
	ld (hl),#ff
	ld hl,state_letter3_taken
	ld (hl),5
	ld hl,state_book_taken
	ld (hl),1
	ld hl,state_red_key_taken
	ld (hl),2
	ld hl,state_game_time_day
	ld (hl),TIME_PENTAGRAM_CLUE_SEEN
	ld hl,map2_zx0
	ld de,8 + 0*256  ; e: room, d: door
	ld a,24
	jp handle_cheats_entry_point


;-----------------------------------------------
handle_cheats_cheat5: ; just before cutscene 1
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_HAMMER
	inc hl
	ld (hl),INVENTORY_GUN
	inc hl
	ld (hl),INVENTORY_LAB_NOTES
	call cheats_set_game_state_cheat5
	ld hl,state_game_time_day
	ld (hl),TIME_REACH_LAB
	ld hl,map1_zx0
	ld de,10 + 1*256  ; e: room, d: door
	ld a,10
	jp handle_cheats_entry_point


;-----------------------------------------------
handle_cheats_cheat6: ; just before vampire door 1
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_HAMMER
	inc hl
	ld (hl),INVENTORY_GUN
	inc hl
	ld (hl),INVENTORY_LAB_NOTES
	inc hl
	ld (hl),INVENTORY_STAKE
	inc hl
	ld (hl),INVENTORY_GARLIC
	call cheats_set_game_state_cheat6
	ld hl,state_game_time_day
	ld (hl),TIME_VAMPIRES_ARRIVE
	ld hl,map3_zx0
	ld de,2 + 6*256  ; e: room, d: door
	ld a,34
	jp handle_cheats_entry_point


;-----------------------------------------------
handle_cheats_cheat7: ; about to solve chapel puzzle
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_HAMMER
	inc hl
	ld (hl),INVENTORY_GUN
	inc hl
	ld (hl),INVENTORY_LAB_NOTES
	inc hl
	ld (hl),INVENTORY_STAKE
	inc hl
	ld (hl),INVENTORY_GARLIC
	inc hl
	ld (hl),INVENTORY_LUCY_TORN_NOTE
	call cheats_set_game_state_cheat7
	ld hl,state_game_time_day
; 	ld (hl),TIME_LUCY_ENTERS_SUBBASEMENT
	ld (hl),TIME_VAMPIRES_ARRIVE
	ld hl,map3_zx0
	ld de,8 + 0*256  ; e: room, d: door
	ld a,40
	jp handle_cheats_entry_point


;-----------------------------------------------
handle_cheats_cheat8: ; vlad statue
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_HAMMER
	inc hl
	ld (hl),INVENTORY_GUN
	inc hl
	ld (hl),INVENTORY_LAB_NOTES
	inc hl
	ld (hl),INVENTORY_STAKE
	inc hl
	ld (hl),INVENTORY_GARLIC
	call cheats_set_game_state_cheat8
	ld hl,state_game_time_day
	ld (hl),TIME_SUBBASEMENT_OPEN
	ld hl,map6_zx0
	ld de,2 + 0*256  ; e: room, d: door
	ld a,82
	; Vlad room:
; 	ld de,8 + 0*256  ; e: room, d: door
; 	ld a,88
	jp handle_cheats_entry_point


handle_cheats_cheat9:  ; prison
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_HAMMER
	inc hl
	ld (hl),INVENTORY_GUN
	inc hl
	ld (hl),INVENTORY_LAB_NOTES
	inc hl
	ld (hl),INVENTORY_STAKE
	inc hl
	ld (hl),INVENTORY_GARLIC
	inc hl
	ld (hl),INVENTORY_VLAD_DIARY
	inc hl
	ld (hl),INVENTORY_REVEAL_CLUE
	inc hl
	ld (hl),INVENTORY_CUTLERY
	call cheats_set_game_state_cheat9
	ld hl,state_game_time_day
	ld (hl),TIME_SUBBASEMENT_OPEN
	ld hl,map6_zx0
	ld de,15 + 1*256  ; e: room, d: door  ; right before ending
	ld a,95
; 	ld de,11 + 1*256  ; e: room, d: door  ; right before skeleton boss
; 	ld a,91
	jp handle_cheats_entry_point



handle_cheats_cheat10:  ; (secondary mission)
	call StopMusic
	call init_game_variables
	ld hl,state_white_key_taken
	ld (hl),1
	ld hl,inventory
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	inc hl
	ld (hl),INVENTORY_HAMMER
	inc hl
	ld (hl),INVENTORY_GUN
	inc hl
	ld (hl),INVENTORY_LAB_NOTES
	inc hl
	ld (hl),INVENTORY_STAKE
	inc hl
	ld (hl),INVENTORY_GARLIC
	inc hl
	ld (hl),INVENTORY_VLAD_DIARY
; 	inc hl
; 	ld (hl),INVENTORY_REVEAL_CLUE
; 	inc hl
; 	ld (hl),INVENTORY_CUTLERY
	inc hl
	ld (hl),INVENTORY_SHOVEL
; 	inc hl
; 	ld (hl),INVENTORY_CANDLE
; 	inc hl
; 	ld (hl),INVENTORY_CANDLE
; 	inc hl
; 	ld (hl),INVENTORY_QUINCEY_KEY
; 	inc hl
; 	ld (hl),INVENTORY_CLAY
; 	inc hl
; 	ld (hl),INVENTORY_CAULDRON
; 	inc hl
; 	ld (hl),INVENTORY_WET_MOLD
	inc hl
	ld (hl),INVENTORY_FRANKY_KEY
	inc hl
	ld (hl),INVENTORY_SILVER_BULLETS
	inc hl
	ld (hl),INVENTORY_QUINCEY_LETTER
	call cheats_set_game_state_cheat10
	ld hl,state_game_time_day
	ld (hl),TIME_SUBBASEMENT_OPEN
; 	ld hl,map1_zx0
; 	ld de,11 + 0*256  ; e: room, d: door 
; 	ld a,11
; 	ld hl,map2_zx0
; 	ld de,8 + 0*256  ; e: room, d: door 
	ld a,24
	ld hl,map1_zx0
	ld de,10 + 0*256  ; e: room, d: door 
; 	ld a,92
; 	ld hl,map6_zx0
; 	ld de,12 + 0*256  ; e: room, d: door 
	jp handle_cheats_entry_point


cheats_set_game_state_cheat10:
	ld hl,state_cauldron_taken
	ld (hl),1
	ld hl,state_shovel_taken
	ld (hl),1	
	ld hl,state_backyard_key_taken	
	ld (hl),2
; 	ld hl,state_skeleton_miniboss
; 	ld (hl),1	
	ld hl,state_skeleton_key_taken
; 	ld (hl),2
; 	ld hl,state_clay_taken
	ld (hl),1	
	ld hl,state_franky_key_taken
	ld (hl),1	
	ld hl,state_quincey_note_read
	ld (hl),1

cheats_set_game_state_cheat9:
	ld hl,state_vampire4_state
	ld (hl),1
	ld hl,state_puzzle_box_taken
	ld (hl),3
	ld hl,state_vlad_statue_examined
	ld (hl),1
	ld hl,state_vlad_diary_taken
	ld (hl),1
	ld hl,state_reveal_clue_taken
	ld (hl),1
	ld hl,state_cutlery_taken
	ld (hl),1
	ld hl,state_prison_door_entrance
	ld (hl),1
	ld hl,state_switches  ; all switches open	
	ld (hl),0x07

cheats_set_game_state_cheat8:
	ld hl,state_vampire3_state
	ld (hl),1
cheats_set_game_state_cheat7:
	ld hl,state_crate_garlic2
	ld (hl),2
	ld hl,state_crate_stake2
	ld (hl),2
	ld hl,state_crate_garlic3
	ld (hl),2
	ld hl,state_crate_stake3
	ld (hl),2
	ld hl,state_vampire1_state
	ld (hl),2
	ld hl,state_vampire2_state
	ld (hl),2
	ld hl,state_torn_note_taken
	ld (hl),1

cheats_set_game_state_cheat6:
cheats_set_game_state_cheat5:
	ld hl,state_choffeur_store
	ld (hl),3
	ld hl,state_candle1_position
	ld (hl),#ff
	ld hl,state_candle2_position
	ld (hl),#ff
	ld hl,state_candle3_position
	ld (hl),#ff
	ld hl,state_letter3_taken
	ld (hl),5
	ld hl,state_book_taken
	ld (hl),1
	ld hl,state_red_key_taken
	ld (hl),2
	ld hl,state_hammer_taken
	ld (hl),1
	ld hl,state_gun_taken
	ld (hl),2
	ld hl,state_ritual_room_state
	ld (hl),2
	ld hl,state_lab_notes_taken
	ld (hl),2
	ld hl,state_green_key_taken
	ld (hl),2
	ld hl,state_yellow_key_taken
	ld (hl),2
	ld hl,state_crate_garlic1
	ld (hl),2
	ld hl,state_crate_stake1
	ld (hl),2
	ret
