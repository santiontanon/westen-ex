;-----------------------------------------------
state_game_page_changed:
    ; init the stack:
    ld sp,#f380

    xor a
    ld (hud_message_timer),a

	call disable_VDP_output
		call set_bitmap_mode
		call clearAllTheSprites
		call init_object_screen_coordinates
		call render_full_room
		call clean_inventory_of_room_objects
		call draw_hud
		call draw_player
		call enter_room_music_change
		call enter_room_events
		call update_keyboard_buffers  ; update keyboard here, to prevent spurious clicks done while loading the new room
	call enable_VDP_output

	xor a
	ld (interrupt_cycle),a

state_game_loop:
	ld c,2
	call wait_for_interrupt
	call update_keyboard_buffers
	call update_player
	call update_ui_control
	call draw_player
	call update_objects
;     out (#2c),a  
	call update_object_drawing_order_n_times
;     out (#2d),a  
	call update_hud_messages
	call update_vampire

	ld hl,game_cycle
	inc (hl)

IF CHEATS_ON = 1
	call handle_cheats
ENDIF

	ld hl,gun_cooldown
	ld a,(hl)
	or a
	jr z,state_game_loop
	dec (hl)
	jr state_game_loop


;-----------------------------------------------
wait_for_interrupt:
	ld hl,interrupt_cycle
	ld a,(hl)
	cp c
	jr c,wait_for_interrupt
	ld (hl),0
	ret


;-----------------------------------------------
update_vampire:
	ld a,(current_room_vampire_state)
	dec a
	ret nz
	
	; We are in a room with a vampire that is awake and has not seen us yet!
	ld a,(state_current_room)
	cp 35
	jr z,update_vampire_vampire1
	cp 45
	jr z,update_vampire_vampire2
update_vampire_vampire3:
	; safe positions for Vampire 3 (Lucy):
	ld a,(player_iso_y)
	cp 10*8
	ret c  ; player is safe
	ld bc,5 + 13*256  ; bat spawn position
	ld e,56
	jr update_vampire_seen

	ret
update_vampire_vampire1:
	; safe position is behind the wall in Vampire 1 (John):
	ld a,(player_iso_y)
	cp 76
	ret c  ; player is safe
	ld bc,5 + 13*256  ; bat spawn position
	ld e,48
	jr update_vampire_seen

update_vampire_vampire2:
	; safe positions for Vampire 2 (Jonathan):
	ld a,(player_iso_y)
	cp 12*8
	ret nc  ; player is safe
	ld a,(player_iso_x)
	cp 8*8
	ret nc  ; player is safe
	ld bc,8 + 2*256  ; bat spawn position
	ld e,32
; 	jr update_vampire_seen

update_vampire_seen:
	ld a,2
	ld (current_room_vampire_state),a

	; spawn a bat!
	push bc
	push de
		call find_new_object_ptr
	pop de
	pop bc

	ld (ix),OBJECT_TYPE_BAT
	ld (ix+OBJECT_STRUCT_STATE),0
	ld (ix+OBJECT_STRUCT_STATE_TIMER),0
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),c
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),b
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),e
	call load_room_init_enemy_spawn_entry_point
	ld hl,SFX_explosion
	jp play_SFX_with_high_priority


;-----------------------------------------------
; input:
; - hl: map ptr
; - e: room #
; - d: door #
teleport_player_to_room:
	ld a,e  ; room
	push de
		call load_room
	pop bc
	push bc
		ld a,b  ; door
		call teleport_player_to_door
	pop bc

	; special case for some room transitions:
; 	ld a,c  ; room
; 	dec a
; 	ret nz
	ld a,(state_current_room)
	cp 1
	jr z,teleport_player_to_room_westen_entrance
	cp 64
	jr z,teleport_player_to_room_intro
	cp 69
	jr z,teleport_player_to_room_exit_player_house
	cp 71
	jr z,teleport_player_to_room_exit_bookstore
	cp 40
	jr z,teleport_player_to_room_exit_subbasement
	ret
teleport_player_to_room_westen_entrance:
	ld a,b  ; door
	dec a
	ret nz
	ld a,4
	ld (player_iso_z),a
	ret
teleport_player_to_room_intro:
	ld a,b  ; door
	dec a
	ret nz
	ld a,16
	ld (player_iso_y),a
	ret
teleport_player_to_room_exit_player_house:
	ld a,b  ; door
	or a
	ret nz
	ld a,40
	ld (player_iso_x),a
	ld a,5
	ld (player_iso_z),a
	ret
teleport_player_to_room_exit_bookstore:
	ld a,b  ; door
	cp 3
	ret nz
	ld a,42
	ld (player_iso_x),a
	ret
teleport_player_to_room_exit_subbasement:
	ld a,b  ; door
	cp 2
	ret nz
	ld a,28
	ld (player_iso_x),a
	ld a,64
	ld (player_iso_y),a
	ld a,8
	ld (player_iso_z),a
	ld a,3
	ld (player_direction),a
	ret	

;-----------------------------------------------
; - a: door #
teleport_player_to_door:
	ld ix,doors
	or a
	jr z,teleport_player_to_door_ptr_set
	ld de,DOOR_STRUCT_SIZE
	ld b,a
teleport_player_to_door_loop:
	add ix,de
	djnz teleport_player_to_door_loop
teleport_player_to_door_ptr_set:

	; reset player state and position:
	ld hl,player_state
	xor a
	ld (hl),a  ; player_state
	inc hl
	ld (hl),a  ; player_state_timer
	inc hl

	ld a,(ix)
	and #c0
	jr z,teleport_player_to_door_nw
	cp #40
	jr z,teleport_player_to_door_ne
	cp #c0
	jr z,teleport_player_to_door_sw
teleport_player_to_door_se:
	ld a,(room_width)
	add a,a
	add a,a
	add a,a
	ld (hl),a  ; player_iso_x
	inc hl
	ld a,(ix+DOOR_STRUCT_POSITION)
	add a,a
	add a,a
	add a,a
	add a,4
	ld (hl),a  ; player_iso_y
	inc hl
	ld a,(ix+DOOR_STRUCT_HEIGHT)
	add a,a
	add a,a
	add a,a
	ld (hl),a  ; player_iso_z
	ld hl,player_direction
	ld (hl),7
	ret

teleport_player_to_door_sw:
	ld a,(ix+DOOR_STRUCT_POSITION)
	add a,a
	add a,a
	add a,a
	add a,20
	ld (hl),a  ; player_iso_x
	; if it's an empty (wider) door, put the player in the center:
	ld a,(ix+DOOR_STRUCT_TYPE)
	cp 64*3+1
	jr nz,teleport_player_to_door_sw_not_empty
	ld a,(hl)
	add a,8
	ld (hl),a
teleport_player_to_door_sw_not_empty:	
	inc hl
	ld a,(room_height)
	add a,a
	add a,a
	add a,a
	ld (hl),a  ; player_iso_y
	inc hl
	ld a,(ix+DOOR_STRUCT_HEIGHT)
	add a,a
	add a,a
	add a,a
	ld (hl),a  ; player_iso_z
	ld hl,player_direction
	ld (hl),1
	ret

teleport_player_to_door_ne:
	ld a,(ix+DOOR_STRUCT_POSITION)
	add a,a
	add a,a
	add a,a
	add a,20
	ld (hl),a  ; player_iso_x

	; if it's an empty (wider) door, put the player in the center:
	ld a,(ix+DOOR_STRUCT_TYPE)
	cp 64+1
	jr nz,teleport_player_to_door_ne_not_empty
	ld a,(hl)
	add a,8
	ld (hl),a
teleport_player_to_door_ne_not_empty:

	inc hl
	ld (hl),12  ; player_iso_y
	inc hl
	ld a,(ix+DOOR_STRUCT_HEIGHT)
	add a,a
	add a,a
	add a,a
	ld (hl),a  ; player_iso_z
	ld hl,player_direction
	ld (hl),5
	ret

teleport_player_to_door_nw:
	ld (hl),12  ; player_iso_x
	inc hl
	ld a,(ix+DOOR_STRUCT_POSITION)
	add a,a
	add a,a
	add a,a
	add a,4
	ld (hl),a  ; player_iso_y
	inc hl
	ld a,(ix+DOOR_STRUCT_HEIGHT)
	add a,a
	add a,a
	add a,a
	ld (hl),a  ; player_iso_z
	ld hl,player_direction
	ld (hl),3
	ret


;-----------------------------------------------
enter_room_events:
	ld a,(state_current_room)
	and #f0
	cp #10
	call z,enter_room_events_map2

	ld a,(state_current_room)
	and #f0
	cp #20
	call z,enter_room_events_map3

	ld a,(state_current_room)
	and #f0
	cp #30
	call z,enter_room_events_map4

	ld a,(state_current_room)
	and #f0
	cp #50
	call z,enter_room_events_map6

	ld a,(state_current_room)
	cp #14 ; enter in the writing room
	jp z,enter_room_events_writting

; 	ld a,(state_current_room)
	cp #18 ; enter in the writing room
	jp z,enter_room_events_ritual

; 	ld a,(state_current_room)
	cp 44 ; enter in the feeding room
	jp z,enter_room_events_feeding

; 	ld a,(state_current_room)
	cp 61 ; enter in the lab
	jp z,enter_room_events_lab

; 	ld a,(state_current_room)
	cp 10 ; small room after the stairs to the 2nd floor
	jp z,enter_room_check_family_cutscene_preliminary

; 	ld a,(state_current_room)
	cp 2 ; lobby
	jp z,enter_room_check_family_cutscene

; 	ld a,(state_current_room)
	cp 40 ; chapel
	jp z,enter_room_check_lucy_cutscene	

; 	ld a,(state_current_room)
	cp 35 ; vampire1
	jp z,enter_room_vampire1

; 	ld a,(state_current_room)
	cp 45 ; vampire2
	jp z,enter_room_vampire2

	; Lucy is not in her coffin in the EX version:
; 	ld a,(state_current_room)
; 	cp 42 ; vampire3
; 	call z,enter_room_vampire3

; 	ld a,(state_current_room)
	cp 87 ; vlad resurrection ritual room
	jp z,enter_room_vlad_resurrection

; 	ld a,(state_current_room)
	cp 93
	jp z,enter_room_secret_boss

; 	ld a,(state_current_room)
	cp 95 ; passage right before ending
	jp z,enter_room_passage2

	ret


enter_room_events_map2:
	ld c,TIME_REACH_WEST_WING
	call update_state_time_day_if_needed
	ret nc
	; add message if needed:
	ld bc, TEXT_MSG_ABANDONED1
	call queue_hud_message
	ld bc, TEXT_MSG_ABANDONED2
	jp queue_hud_message		


enter_room_events_map3:
	ld c,TIME_REACH_BASEMENT
	jp update_state_time_day_if_needed

enter_room_events_map4:
	ld c,TIME_REACH_SECOND_FLOOR
	jp update_state_time_day_if_needed


enter_room_events_map6:
	ld hl,state_reached_subbasement
	ld a,(hl)
	or a
	ret nz
	ld (hl),1
	; add message if needed:
	ld bc, TEXT_ENTER_SUBBASEMENT1
	call queue_hud_message
	ld bc, TEXT_ENTER_SUBBASEMENT2
	jp queue_hud_message		

enter_room_events_writting:
	ld a,(state_writing_room_msg)
	or a
	ret nz
	inc a
	ld (state_writing_room_msg),a
	ld bc, TEXT_MSG_BOOKS1
	call queue_hud_message
	ld bc, TEXT_MSG_BOOKS2
	call queue_hud_message
	ld bc, TEXT_MSG_BOOKS3
	jp queue_hud_message


enter_room_events_ritual:
	ld a,(state_ritual_room_state)
	or a
	ret nz
	inc a
	ld (state_ritual_room_state),a
	ld bc, TEXT_MSG_PENTAGRAM1
	call queue_hud_message
	ld bc, TEXT_MSG_PENTAGRAM2
	jp queue_hud_message


enter_room_events_feeding:
	ld c,TIME_REACH_FEEDING_ROOM
	call update_state_time_day_if_needed
	ret nc
	; add message if needed:
	ld bc, TEXT_MSG_FEEDING1
	call queue_hud_message
	ld bc, TEXT_MSG_FEEDING2
	call queue_hud_message
	ld bc, TEXT_MSG_FEEDING3
	jp queue_hud_message	

enter_room_events_lab:
	ld c,TIME_REACH_LAB
	call update_state_time_day_if_needed
	ret nc
	; add message if needed:
	ld bc, TEXT_MSG_LAB
	jp queue_hud_message


enter_room_check_family_cutscene_preliminary:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	ret p
	ld a,(state_lab_notes_taken)
	cp 2
	ret m

	; trigger family cutscene preliminary!
	ld bc, TEXT_MSG_FAMILY_CUTSCENE1
	jp queue_hud_message


enter_room_check_family_cutscene:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	ret p
	ld a,(state_lab_notes_taken)
	cp 2
	ret m

	; start cutscene:
	call family_cutscene

	ld bc, TEXT_MSG_FAMILY_CUTSCENE9
	call queue_hud_message
	ld bc, TEXT_MSG_FAMILY_CUTSCENE10
	call queue_hud_message
	ld bc, TEXT_MSG_FAMILY_CUTSCENE11
	jp queue_hud_message


enter_room_check_lucy_cutscene:
	ld a,(state_game_time_day)
	cp TIME_SUBBASEMENT_OPEN
	call nc,open_chapel_altar_no_sfx

	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	ret nz

	; start cutscene:
	call lucy_cutscene

	ld bc, TEXT_AFTER_LUCY_CUTSCENE1
	call queue_hud_message
	ld bc, TEXT_AFTER_LUCY_CUTSCENE2
	call queue_hud_message
	ld bc, TEXT_AFTER_LUCY_CUTSCENE3
	jp queue_hud_message


enter_room_vampire1:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	ret m
	ld a,(state_vampire1_state)
	cp 2
	ret z
	ld bc, TEXT_ENTER_VAMPIRE_ROOM1
	call queue_hud_message
	ld bc, TEXT_ENTER_VAMPIRE_ROOM2
	jp queue_hud_message


enter_room_vampire2:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	ret m
	ld a,(state_vampire2_state)
	cp 2
	ret z
	ld bc, TEXT_ENTER_VAMPIRE_ROOM1
	call queue_hud_message
	ld bc, TEXT_ENTER_VAMPIRE_ROOM2
	jp queue_hud_message


; enter_room_vampire3:
; 	ld a,(state_game_time_day)
; 	cp TIME_VAMPIRES_ARRIVE
; 	ret m
; 	ld a,(state_vampire3_state)
; 	cp 2
; 	ret z
; 	ld bc, TEXT_ENTER_VAMPIRE3_ROOM1
; 	jp queue_hud_message


enter_room_vlad_resurrection:
	ld a,(player_iso_x)
	cp 80
	; start cutscene:
	jp nc,vlad_ritual_cutscene  ; entering from the south-east
	; We entered from behind, this means game is complete if we have a stake rubbed in garlic!
	ld a,INVENTORY_RUBBED_STAKE
	call inventory_find_slot
	jr z,enter_room_vlad_resurrection_ending
	
	; we don't have a stake:
	; teleport back to the previous room:
	ld a,95
	ld (state_current_room),a
	ld hl,map6_zx0
	ld de,1*256+15
	call teleport_player_to_room
	; messages:
	ld bc, TEXT_FINAL_PASSAGE3
	call queue_hud_message
	jp state_game

enter_room_vlad_resurrection_ending:
	call enable_VDP_output
	jp state_ending


enter_room_passage2:
	ld bc, TEXT_FINAL_PASSAGE1
	call queue_hud_message
	ld bc, TEXT_FINAL_PASSAGE2
	jp queue_hud_message


enter_room_secret_boss:
	ld a,(state_franky_boss)
	or a
	ret nz
	ld bc, TEXT_FRANKY1
	call queue_hud_message
	ld bc, TEXT_FRANKY2
	jp queue_hud_message


;-----------------------------------------------
; check for music change:
enter_room_music_change:
	ld a,(state_current_room)
	or a  ; yard
	jp z,play_music_ingame_house_yard
	cp 1  ; yard
	jp z,play_music_ingame_house_yard
	cp 2  ; lobby
	jp z,play_music_ingame_house1
	cp 8  ; kitchen
	jp z,play_music_ingame_house1
	cp 9  ; cellar
	jp z,play_music_ingame_cellar
	cp 10  ; upstairs (before passing the door)
	jp z,play_music_ingame_house1
	cp 11  ; yard (with grave)
	jp z,play_music_ingame_house_yard
	cp 16  ; just before ritual room
	jp z,play_music_ingame_house2
	cp 23  ; just before ritual room
	jp z,play_music_ingame_house2
	cp 24  ; re-ritual
	jp z,play_music_ingame_cellar
	cp 32  ; access to catacombs from ritual
	jp z,play_music_ingame_cellar15
	cp 40  ; chapel
	jp z,play_music_ingame_cellar15
	cp 46  ; access to catacombs from lobby
	jp z,play_music_ingame_cellar15

	cp 48  ; second floor
	jp z,play_music_ingame_house3

	cp 34  ; exit vampire1
	jp z,play_music_ingame_cellar15
	cp 44  ; exit vampire2
	jp z,play_music_ingame_cellar15
	cp 41  ; exit vampire3
	jp z,play_music_ingame_cellar15

	cp 35  ; vampire1
	ld hl,state_vampire1_state
	jp z,play_music_ingame_vampire
	cp 45  ; vampire2
	ld hl,state_vampire2_state
	jp z,play_music_ingame_vampire
	cp 42  ; vampire3
	ld hl,state_vampire3_state
	jp z,play_music_ingame_vampire

	cp 69  ; london streets
	jp z,play_music_london_streets
	cp 64  ; london
	jp z,play_music_ingame_london

	cp 80  ; subbasement
	jp z,play_music_ingame_subbasement
	cp 81  ; subbasement
	jp z,play_music_ingame_subbasement
IF CHEATS_ON == 1
	cp 82  ; subbasement
	jp z,play_music_ingame_subbasement
ENDIF
	cp 89  ; subbasement2
	jp z,play_music_ingame_subbasement2
	cp 91  ; subbasement2
	jp z,play_music_ingame_subbasement2
	cp 92  ; mini-boss
	jr z,play_music_ingame_miniboss_check
	cp 93  ; secret mini-boss
	jr z,play_music_ingame_secret_miniboss_check
	cp 94  ; subbasement2
	jp z,play_music_ingame_subbasement2
	ret

play_music_ingame_miniboss_check:
	ld a,(state_skeleton_miniboss)
	or a
; 	jp z,play_music_ingame_miniboss
	jp z,StopMusic
	jp play_music_ingame_subbasement2

play_music_ingame_secret_miniboss_check:
	ld a,(state_franky_boss)
	or a
	jp z,play_music_ingame_secret_miniboss
	jp play_music_ingame_subbasement2
