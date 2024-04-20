;-----------------------------------------------
update_ui_control:
	ld a,(keyboard_line_state+KEY_BUTTON2_BYTE)
	bit KEY_BUTTON2_BIT,a
	jr z,update_ui_control_button2_pressed
	bit KEY_BUTTON2_BIT_ALTERNATIVE,a
	jr z,update_ui_control_button2_pressed

update_ui_control_restore_ui_sprite:
	ld hl,inventory_pointer_sprite_attributes+3
	ld a,(hl)
	or a
	ret nz
	ld a,COLOR_WHITE
	ld (hl),a
	ld hl,SPRATR2+6*4+3
	jp WRTVRM

update_ui_control_button2_pressed:
	; flash hud sprite:
	ld hl,inventory_pointer_sprite_attributes+3
	ld a,(game_cycle)
	bit 2,a
	jr z,update_ui_control_sprite_white
update_ui_control_sprite_black:
	xor a
	ld (hl),a
	jr update_ui_control_sprite_set
update_ui_control_sprite_white:
	ld a,COLOR_WHITE
	ld (hl),a
update_ui_control_sprite_set:
	ld hl,SPRATR2+6*4+3
	call WRTVRM


	ld a,(keyboard_line_clicks+KEY_LEFT_BYTE)
	bit KEY_RIGHT_BIT,a
	jr nz,update_ui_input_right
	bit KEY_LEFT_BIT,a
	jr nz,update_ui_input_left
	bit KEY_UP_BIT,a
	jr nz,update_ui_input_up
	bit KEY_DOWN_BIT,a
	jr nz,update_ui_input_down
	bit KEY_BUTTON1_BIT,a
	jr nz,update_ui_input_button
	ret


;-----------------------------------------------
update_ui_input_left:
	ld a,(inventory_selected)
	dec a
	jr update_ui_input_right_entrypoint

update_ui_input_right:
ui_next_inventory_slot:
	ld a,(inventory_selected)
	inc a
update_ui_input_right_entrypoint:
update_ui_input_up_entrypoint:
update_ui_input_down_entrypoint:
	cp INVENTORY_SIZE
	jr c, update_ui_input_no_overflow
	cp INVENTORY_SIZE*2
	jr nc, update_ui_input_negative
	add a,-INVENTORY_SIZE
	jr update_ui_input_down_entrypoint
update_ui_input_negative:
	add a,INVENTORY_SIZE
	jr update_ui_input_down_entrypoint
update_ui_input_no_overflow:
	ld (inventory_selected),a
	; Change the selected row:
update_ui_input_update_current_row:
	ld a,(inventory_selected)
	ld hl,inventory_first_displayed_item
	sub (hl)  ; a = (inventory_selected) - (inventory_first_displayed_item)
	; if a < INVENTORY_ROW_SIZE*2 -> we are good!
	; if a < INVENTORY_ROW_SIZE*3 -> (inventory_first_displayed_item) += INVENTORY_ROW_SIZE
	; else: (inventory_first_displayed_item) -= INVENTORY_ROW_SIZE
	cp INVENTORY_ROW_SIZE*2
	jr c,update_ui_input_continue
	cp INVENTORY_ROW_SIZE*3
	jr c,update_ui_input_ensure_next_row

update_ui_input_ensure_previous_row:
	ld a,(hl)
	add a,-INVENTORY_ROW_SIZE
	jp p,update_ui_input_ensure_previous_row_continue
	ld a,INVENTORY_ROW_SIZE*(INVENTORY_ROWS-2)
update_ui_input_ensure_previous_row_continue:
	ld (hl),a
	jr update_ui_input_update_current_row

; 	cp INVENTORY_ROW_SIZE
; 	jp c,update_ui_input_ensure_first_row
; 	cp INVENTORY_ROW_SIZE*(INVENTORY_ROWS-1)
; 	jp nc,update_ui_input_ensure_second_row

update_ui_input_continue:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp hud_update_inventory


update_ui_input_ensure_next_row:
	ld a,(hl)
	add a,INVENTORY_ROW_SIZE
	ld (hl),a
	jr update_ui_input_update_current_row

update_ui_input_up:
	ld a, (inventory_selected)
	add a, -INVENTORY_ROW_SIZE
	jr update_ui_input_up_entrypoint

update_ui_input_down:
	ld a, (inventory_selected)
	add a, INVENTORY_ROW_SIZE
	jr update_ui_input_down_entrypoint

; update_ui_input_ensure_first_row:
; 	ld hl,inventory_first_displayed_item
; 	ld a,(hl)
; 	or a
; 	jr z, update_ui_input_continue
; 	ld (hl), 0
; 	jr update_ui_input_continue


; update_ui_input_ensure_second_row:
; 	ld hl,inventory_first_displayed_item
; 	ld a,(hl)
; 	or a
; 	jr nz, update_ui_input_continue
; 	ld (hl), INVENTORY_ROW_SIZE*(INVENTORY_ROWS-2)
; 	jr update_ui_input_continue



update_ui_input_button:
	ld hl,inventory
	ld b,0
	ld a,(inventory_selected)
	ld c,a
	add hl,bc
	ld a,(hl)
	; If we are fighting a boss, only allow using gun and hearts (to prevent reading
	; letters during bosses, etc., which mess up the sprites):
	push af
		ld a,(miniboss_hitpoints)
		or a
		jr z,update_ui_input_button_no_miniboss
	pop af
	cp INVENTORY_GUN
	jr z,update_ui_input_button_no_miniboss_continue
	cp INVENTORY_HEART
	jr z,update_ui_input_button_no_miniboss_continue
	; do not let the player use any other object
	ret
update_ui_input_button_no_miniboss:
	pop af
update_ui_input_button_no_miniboss_continue:

	ld ix,inventory_effect_functions  ; we use ix, to preserve hl
	ld c,a
	add ix,bc
	add ix,bc
	ld e,(ix)
	ld d,(ix+1)
	ld ixl,e
	ld ixh,d
	jp ix


;-----------------------------------------------
; input:
; - a: desired item
; output:
; - z: found (slot in hl)
; - nz: not found
inventory_find_slot:
	ld hl,inventory
	ld b,INVENTORY_SIZE
inventory_find_slot_loop:
	cp (hl)
	ret z
	inc hl
	djnz inventory_find_slot_loop
	inc b  ; nz
	ret


;-----------------------------------------------
inventory_fn_jump:
	ld hl,SFX_jump
	call play_SFX_with_high_priority
	ld hl,player_state
	ld (hl),PLAYER_STATE_JUMPING
	inc hl
	ld (hl),0  ; player_state_timer
	jp update_player_no_use_or_jump


;-----------------------------------------------
inventory_fn_use:
	; if the hud message queue does not have at least 4 empty rows, ignore the use
	; command:
	ld a,(hud_message_queue_size)
	cp HUD_MESSAGE_QUEUE_SIZE-4
	ret p

	; Check if there is an item to pickup:
	ld de,0
	ld c,-1
	call check_player_collision
	jp nz,inventory_fn_use_nothing_to_pickup

	; Check if we have a free inventory slot:
	xor a
	call inventory_find_slot
	ret nz

	; try to take the object pointed to by "ix":
	ld a,(ix)
	cp OBJECT_TYPE_STOOL
	jp z,inventory_fn_use_pickup_stool
	cp OBJECT_TYPE_YELLOW_KEY
	jp z,inventory_fn_use_pickup_yellow_key
; 	cp OBJECT_TYPE_GUN
; 	jp z,inventory_fn_use_pickup_gun
	cp OBJECT_TYPE_GUN_KEY
	jp z,inventory_fn_use_pickup_gun_key
	cp OBJECT_TYPE_LETTER3
	jp z,inventory_fn_use_pickup_letter3
	cp OBJECT_TYPE_LAMP
	jp z,inventory_fn_use_pickup_lamp
	cp OBJECT_TYPE_OIL
	jp z,inventory_fn_use_pickup_oil
	cp OBJECT_TYPE_HEART1
	jp z,inventory_fn_use_pickup_heart1
	cp OBJECT_TYPE_HEART2
	jp z,inventory_fn_use_pickup_heart2
	cp OBJECT_TYPE_HEART3
	jp z,inventory_fn_use_pickup_heart3
	cp OBJECT_TYPE_HEART4
	jp z,inventory_fn_use_pickup_heart4
	cp OBJECT_TYPE_BOOK
	jp z,inventory_fn_use_pickup_book
	cp OBJECT_TYPE_CANDLE1
	jp z,inventory_fn_use_pickup_candle1
	cp OBJECT_TYPE_CANDLE2
	jp z,inventory_fn_use_pickup_candle2
	cp OBJECT_TYPE_CANDLE3
	jp z,inventory_fn_use_pickup_candle3
	cp OBJECT_TYPE_GREEN_KEY
	jp z,inventory_fn_use_pickup_green_key
	cp OBJECT_TYPE_DIARY1
	jp z,inventory_fn_use_pickup_diary1
	cp OBJECT_TYPE_DIARY2
	jp z,inventory_fn_use_pickup_diary2
	cp OBJECT_TYPE_DIARY3
	jp z,inventory_fn_use_pickup_diary3
	cp OBJECT_TYPE_LAB_NOTES
	jp z,inventory_fn_use_pickup_lab_notes
	cp OBJECT_TYPE_HAMMER
	jp z,inventory_fn_use_pickup_hammer
	cp OBJECT_TYPE_GARLIC1
	jp z,inventory_fn_use_pickup_garlic1
	cp OBJECT_TYPE_GARLIC2
	jp z,inventory_fn_use_pickup_garlic2
	cp OBJECT_TYPE_GARLIC3
	jp z,inventory_fn_use_pickup_garlic3
	cp OBJECT_TYPE_STAKE1
	jp z,inventory_fn_use_pickup_stake1
	cp OBJECT_TYPE_STAKE2
	jp z,inventory_fn_use_pickup_stake2
	cp OBJECT_TYPE_STAKE3
	jp z,inventory_fn_use_pickup_stake3
	cp OBJECT_TYPE_LUGGAGE
	jp z,inventory_fn_use_pickup_luggage
	cp OBJECT_TYPE_NEWSPAPER
	jp z,inventory_fn_use_pickup_newspaper
	cp OBJECT_TYPE_LUCY_TORN_NOTE
	jp z,inventory_fn_use_pickup_torn_note
	cp OBJECT_TYPE_PUZZLE_BOX
	jp z,inventory_fn_use_pickup_puzzle_box
	cp OBJECT_TYPE_VLAD_DIARY
	jp z,inventory_fn_use_pickup_vlad_diary
	cp OBJECT_TYPE_CAULDRON
	jp z,inventory_fn_use_pickup_cauldron
	cp OBJECT_TYPE_SKELETON_KEY
	jp z,inventory_fn_use_pickup_skeleton_key
	cp OBJECT_TYPE_CLAY
	jp z,inventory_fn_use_pickup_clay
	cp OBJECT_TYPE_FRANKY_NOTE
	jp z,inventory_fn_use_pickup_franky_note

inventory_fn_use_nothing_to_pickup:
	; check if there is any item to use nearby:
	ld de,OBJECT_STRUCT_SIZE
	ld ix,objects
	ld a,(n_objects)
	ld b,a
inventory_fn_use_loop:
	; see if the object is nearby:
	call check_if_object_close_by
	jp nz,inventory_fn_use_loop_next
	ld a,(ix)
	cp OBJECT_TYPE_TOMBSTONE
	jp z,inventory_fn_use_tombstone
	cp OBJECT_TYPE_DOOR_LEFT_RED
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_DOOR_LEFT_YELLOW
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_DOOR_RIGHT_YELLOW
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_DOOR_RIGHT_WHITE
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_PAINTING_RIGHT
	jp z,inventory_fn_use_painting
	cp OBJECT_TYPE_PAINTING_SAFE_RIGHT
	jp z,inventory_fn_use_painting_safe
	cp OBJECT_TYPE_SAFE_RIGHT
	jp z,inventory_fn_use_safe
	cp OBJECT_TYPE_CHEST
	jp z,inventory_fn_use_chest
	cp OBJECT_TYPE_CHEST2
	jp z,inventory_fn_use_chest
	cp OBJECT_TYPE_SINK
	jp z,inventory_fn_use_sink
	cp OBJECT_TYPE_WINDOW_NE
	jp z,inventory_fn_use_window
	cp OBJECT_TYPE_BOOKSTACK
	jp z,inventory_fn_use_bookstack
	cp OBJECT_TYPE_BOOKSTACK_HOME
	jp z,inventory_fn_use_bookstack_home
	cp OBJECT_TYPE_TOILET
	jp z,inventory_fn_use_toilet
	cp OBJECT_TYPE_BATHTUB
	jp z,inventory_fn_use_bathtub
	cp OBJECT_TYPE_GRAMOPHONE
	jp z,inventory_fn_use_gramophone
	cp OBJECT_TYPE_VIOLIN
	jp z,inventory_fn_use_violin
	cp OBJECT_TYPE_COFFIN1
	jp z,inventory_fn_use_coffin
	cp OBJECT_TYPE_COFFIN2
	jp z,inventory_fn_use_coffin
	cp OBJECT_TYPE_BONES1
	jp z,inventory_fn_use_bones
	cp OBJECT_TYPE_BONES2
	jp z,inventory_fn_use_bones
	cp OBJECT_TYPE_BONES3
	jp z,inventory_fn_use_bones
	cp OBJECT_TYPE_CHEST_GUN
	jp z,inventory_fn_use_chest_gun
	cp OBJECT_TYPE_BOOK_WESTENRA
	jp z,inventory_fn_use_book_westenra	
	cp OBJECT_TYPE_DOOR_VAMPIRE1
	jp z,inventory_fn_use_door_vampire1
	cp OBJECT_TYPE_DOOR_VAMPIRE2
	jp z,inventory_fn_use_door_vampire2
	cp OBJECT_TYPE_DOOR_VAMPIRE3
	jp z,inventory_fn_use_door_vampire3
	cp OBJECT_TYPE_DOOR_RIGHT_GREEN
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_DOOR_RIGHT_BLUE
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_CRATE_GARLIC1
	jp z,inventory_fn_use_breakable_crate
	cp OBJECT_TYPE_CRATE_GARLIC2
	jp z,inventory_fn_use_breakable_crate
	cp OBJECT_TYPE_CRATE_GARLIC3
	jp z,inventory_fn_use_breakable_crate
	cp OBJECT_TYPE_CRATE_STAKE1
	jp z,inventory_fn_use_breakable_crate
	cp OBJECT_TYPE_CRATE_STAKE2
	jp z,inventory_fn_use_breakable_crate
	cp OBJECT_TYPE_CRATE_STAKE3
	jp z,inventory_fn_use_breakable_crate
	cp OBJECT_TYPE_BOOKSHELVES
	jp z,inventory_fn_use_bookshelves
	cp OBJECT_TYPE_UNIVERSITY_NOTES
	jp z,inventory_fn_use_university_notes
	cp OBJECT_TYPE_DOOR_RIGHT_NO_KEY
	jp z,inventory_fn_use_door_no_key
	cp OBJECT_TYPE_DOOR_LEFT_NO_KEY
	jp z,inventory_fn_use_door_no_key
	cp OBJECT_TYPE_BEGGAR
	jp z,inventory_fn_use_beggar
	cp OBJECT_TYPE_BEGGAR_BAG
	jp z,inventory_fn_use_beggar_bag
	cp OBJECT_TYPE_BEGGAR_DEAD
	jp z,inventory_fn_use_beggar_dead
	cp OBJECT_TYPE_HORSE
	jp z,inventory_fn_use_horse
	cp OBJECT_TYPE_HORSECAR
	jp z,inventory_fn_use_horse_car
	cp OBJECT_TYPE_BOOKSTORE_CLERK
	jp z,inventory_fn_use_bookstore_clerk
	cp OBJECT_TYPE_STORE_BOOKSHELF
	jp z,inventory_fn_use_store_bookshelf
	cp OBJECT_TYPE_STORE_STACK
	jp z,inventory_fn_use_store_bookshelf
	cp OBJECT_TYPE_STORE_BOOKSHELF_BOOK
	jp z,inventory_fn_use_store_bookshelf_book
	cp OBJECT_TYPE_CHOFFEUR
	jp z,inventory_fn_use_choffeur
	cp OBJECT_TYPE_ALTAR
	jp z,inventory_fn_use_chapel_altar
	cp OBJECT_TYPE_VLAD_STATUE
	jp z,inventory_fn_use_vlad_statue
	cp OBJECT_TYPE_DOOR_VAMPIRE4
	jp z,inventory_fn_use_door_vampire4
	cp OBJECT_TYPE_COIN_PILE
	jp z,inventory_fn_use_coin_pile
	cp OBJECT_TYPE_VLAD_CLUE_BOOK
	jp z,inventory_fn_use_vlad_clue_book
	cp OBJECT_TYPE_MIRROR_NW
	jp z,inventory_fn_use_mirror
	cp OBJECT_TYPE_MIRROR_NE
	jp z,inventory_fn_use_mirror
	cp OBJECT_TYPE_MIRROR_CLUE
	jp z,inventory_fn_use_mirror_clue
	cp OBJECT_TYPE_CHEST_REVEAL
	jp z,inventory_fn_use_chest_reveal
	cp OBJECT_TYPE_CHEST_REVEAL2
	jp z,inventory_fn_use_chest_reveal2
	cp OBJECT_TYPE_CHEST_CUTLERY
	jp z,inventory_fn_use_chest_cutlery
	cp OBJECT_TYPE_DOOR_PRISON_ENTRANCE
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_DOOR_PRISON_FRANKY
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_DOOR_PRISON_PASSAGE
	jp z,inventory_fn_use_door
	cp OBJECT_TYPE_SWITCH
	jp z,inventory_fn_use_switch
	cp OBJECT_TYPE_CHEST_SHOVEL
	jp z,inventory_fn_use_chest_shovel
	cp OBJECT_TYPE_OPEN_GRAVE
	jp z,inventory_fn_use_open_grave
	cp OBJECT_TYPE_CLAY
	jp z,inventory_fn_use_clay
	cp OBJECT_TYPE_LOG_BOOK
	jp z,inventory_fn_use_log_book

inventory_fn_use_loop_next:	
	add ix,de
	dec b
	jp nz,inventory_fn_use_loop
inventory_fn_use_nothing_to_use:
	ld bc, TEXT_USE_ERROR
	jp queue_hud_message

inventory_fn_use_tombstone:
	ld bc, TEXT_USE_TOMBSTONE
	jp queue_hud_message	

inventory_fn_use_door:
	ld bc, TEXT_USE_DOOR
	jp queue_hud_message	

inventory_fn_use_door_no_key:
	ld a,(state_current_room)
	cp 64
	jr nz,inventory_fn_use_door_no_key_continue
	ld a,(state_luggage_taken)
	or a
	jr nz,inventory_fn_use_door_no_key_continue
	ld bc, TEXT_NEED_LUGGAGE
	jp queue_hud_message
inventory_fn_use_door_no_key_continue:
	call remove_room_object
	jp play_SFX_door_open

inventory_fn_use_bookstack:
	ld bc, TEXT_USE_BOOK_STACK
	jp queue_hud_message	

inventory_fn_use_bookstack_home:
	ld bc, TEXT_USE_BOOK_STACK_HOME
	jp queue_hud_message	

inventory_fn_use_toilet:
	ld bc, TEXT_USE_TOILET
	jp queue_hud_message	

inventory_fn_use_bathtub:
	ld bc, TEXT_USE_BATHTUB
	jp queue_hud_message	

inventory_fn_use_gramophone:
	ld bc, TEXT_USE_GRAMOPHONE
	jp queue_hud_message	

inventory_fn_use_violin:
	ld bc, TEXT_USE_VIOLIN
	jp queue_hud_message	

inventory_fn_use_painting:
	ld bc, TEXT_USE_PAINTING
	jp queue_hud_message

inventory_fn_use_chest:
	ld bc, TEXT_USE_CHEST
	jp queue_hud_message

inventory_fn_use_sink:
	ld bc, TEXT_USE_SINK
	jp queue_hud_message

inventory_fn_use_window:
	ld bc, TEXT_USE_WINDOW
	jp queue_hud_message

inventory_fn_use_coffin:
	ld bc, TEXT_USE_COFFIN
	jp queue_hud_message

inventory_fn_use_bones:
	ld bc, TEXT_USE_BONES
	jp queue_hud_message

inventory_fn_use_chest_gun:
	ld a,(state_gun_taken)
	cp 2
	jr z,inventory_fn_use_chest_gun_taken
	ld bc, TEXT_USE_CHEST_GUN1
	jp queue_hud_message
inventory_fn_use_chest_gun_taken:
	ld bc, TEXT_USE_CHEST_GUN2
	jp queue_hud_message


inventory_fn_use_painting_safe:
	ld bc, TEXT_USE_PAINTING_SAFE
	call queue_hud_message

	; replace the painting with a safe:
	ld a,1
	ld (state_painting_safe),a

	; 1) get the pointer to the painting data:
	; 2) decompress the safe data over it
	; 3) reinitialize the object
	; 4) redraw
	ld l,(ix+OBJECT_STRUCT_PTR)
	ld h,(ix+OBJECT_STRUCT_PTR+1)
	ld bc,-9
	add hl,bc
	ex de,hl
	ld hl,object_safe_right_zx0
	push ix
		SETMEGAROMPAGE_A000 OBJECTS_PAGE1
		call dzx0_standard
	pop ix
	ld (ix),OBJECT_TYPE_SAFE_RIGHT
	ld e,(ix+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(ix+OBJECT_STRUCT_SCREEN_TILE_Y)
	ld bc,#0403
	jp render_room_rectangle

inventory_fn_use_safe:
	ld a,(state_letter3_taken)
	cp 5  ; already taken the key
	jr z,inventory_fn_use_safe_already_open
	cp 4  ; check if we know the code
	jr z,inventory_fn_use_safe_open
	ld bc, TEXT_USE_SAFE
	jp queue_hud_message

inventory_fn_use_safe_already_open:
	ld bc, TEXT_USE_SAFE_OPEN2
	jp queue_hud_message

inventory_fn_use_safe_open:
	; gain second half of the key:
	ld a,INVENTORY_LETTER3
	call inventory_find_slot
	ret nz
	ld (hl),INVENTORY_RED_KEY_H2
	ld a,5
	ld (state_letter3_taken),a
	ld bc, TEXT_USE_SAFE_OPEN1
	call queue_hud_message
	ld hl,SFX_open_safe
	call play_SFX_with_high_priority
	jp hud_update_inventory


inventory_fn_use_book_westenra:
	ld bc, TEXT_USE_BOOK_WESTENRA1
	call queue_hud_message
	ld bc, TEXT_USE_BOOK_WESTENRA2
	call queue_hud_message
	ld bc, TEXT_USE_BOOK_WESTENRA3
	jp queue_hud_message

inventory_fn_use_pickup_stool:
	ld a,INVENTORY_STOOL
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_yellow_key:
	ld a,1
	ld (state_yellow_key_taken),a 
	ld a,INVENTORY_YELLOW_KEY
	jp inventory_fn_use_pickup_continue

; inventory_fn_use_pickup_gun:
; 	ld a,1
; 	ld (state_gun_taken),a 
; 	ld a,INVENTORY_GUN
; 	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_gun_key:
	ld a,1
	ld (state_gun_taken),a 
	ld a,INVENTORY_GUN_KEY
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_letter3:
	push hl
	push ix
		ld bc, TEXT_LETTER3
		call queue_hud_message
	pop ix
	pop hl
	ld a,1
	ld (state_letter3_taken),a 
	ld a,INVENTORY_LETTER3
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_lamp:
	ld a,1
	ld (state_lamp_taken),a 
	ld a,INVENTORY_LAMP
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_oil:
	ld a,1
	ld (state_oil_taken),a 
	ld a,INVENTORY_OIL
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_heart1:
	ld de,state_heart1_taken
inventory_fn_use_pickup_heart1_continue:
	ld a,1
	ld (de),a
	ld a,INVENTORY_HEART
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_heart2:
	ld de,state_heart2_taken
	jr inventory_fn_use_pickup_heart1_continue

inventory_fn_use_pickup_heart3:
	ld de,state_heart3_taken
	jr inventory_fn_use_pickup_heart1_continue

inventory_fn_use_pickup_heart4:
	ld de,state_heart4_taken
	jr inventory_fn_use_pickup_heart1_continue

inventory_fn_use_pickup_book:
	ld a,1
	ld (state_book_taken),a 
	ld a,INVENTORY_BOOK
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_candle1:
	ld de,state_candle1_position
inventory_fn_use_pickup_candle1_continue:
	ld a,#ff
	ld (de),a 
	ld a,INVENTORY_CANDLE
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_candle2:
	ld de,state_candle2_position
	jr inventory_fn_use_pickup_candle1_continue

inventory_fn_use_pickup_candle3:
	ld de,state_candle3_position
	jr inventory_fn_use_pickup_candle1_continue

inventory_fn_use_pickup_green_key:
	ld a,1
	ld (state_green_key_taken),a 
	ld a,INVENTORY_GREEN_KEY
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_diary1:
	ld a,1
	ld (state_diary1_taken),a 
	ld a,INVENTORY_DIARY1
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_diary2:
	ld a,1
	ld (state_diary2_taken),a 
	ld a,INVENTORY_DIARY2
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_diary3:
	ld a,1
	ld (state_diary3_taken),a 
	ld a,INVENTORY_DIARY3
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_lab_notes:
	ld a,1
	ld (state_lab_notes_taken),a 
	ld (hl),INVENTORY_LAB_NOTES
	call remove_room_object
	call play_SFX_ui_select
	call hud_update_inventory	
	jp inventory_fn_lab_notes

inventory_fn_use_pickup_hammer:
	ld a,1
	ld (state_hammer_taken),a 
	ld a,INVENTORY_HAMMER
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_garlic1:
	ld de,state_crate_garlic1
inventory_fn_use_pickup_garlic1_continue
	ld a,2
	ld (de),a 
	ld a,INVENTORY_GARLIC
	jp inventory_fn_use_pickup_continue

inventory_fn_use_pickup_garlic2:
	ld de,state_crate_garlic2
	jr inventory_fn_use_pickup_garlic1_continue

inventory_fn_use_pickup_garlic3:
	ld de,state_crate_garlic3
	jr inventory_fn_use_pickup_garlic1_continue

inventory_fn_use_pickup_stake1:
	ld de,state_crate_stake1
inventory_fn_use_pickup_stake1_continue:
	ld a,2
	ld (de),a 
	ld a,INVENTORY_STAKE
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_stake2:
	ld de,state_crate_stake2
	jr inventory_fn_use_pickup_stake1_continue

inventory_fn_use_pickup_stake3:
	ld de,state_crate_stake3
	jr inventory_fn_use_pickup_stake1_continue

inventory_fn_use_pickup_luggage:
	ld a,1
	ld (state_luggage_taken),a 
	ld a,INVENTORY_LUGGAGE
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_newspaper:
	ld a,1
	ld (state_newspaper_taken),a 
	ld a,INVENTORY_NEWSPAPER
 	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_torn_note:
	push hl
	push ix
		ld bc, TEXT_LUCY_TORN_NOTE1
		call queue_hud_message
		ld bc, TEXT_LUCY_TORN_NOTE2
		call queue_hud_message
	pop ix
	pop hl
	ld a,1
	ld (state_torn_note_taken),a 
	ld a,INVENTORY_LUCY_TORN_NOTE
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_puzzle_box:
	ld a,1
	ld (state_puzzle_box_taken),a 
	ld a,INVENTORY_PUZZLE_BOX
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_vlad_diary:
	push hl
	push ix
		ld bc, TEXT_VLAD_DIARY_MSG1
		call queue_hud_message
		ld bc, TEXT_VLAD_DIARY_MSG2
		call queue_hud_message
	pop ix
	pop hl
	ld a,1
	ld (state_vlad_diary_taken),a 
	ld a,INVENTORY_VLAD_DIARY
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_cauldron:
	ld a,1
	ld (state_cauldron_taken),a 
	ld a,INVENTORY_CAULDRON
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_skeleton_key:
	ld a,1
	ld (state_skeleton_key_taken),a 
	ld a,INVENTORY_SKELETON_KEY
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_clay:
	ld a,1
	ld (state_clay_taken),a 
	ld a,INVENTORY_CLAY
	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_franky_note:
	ld a,2
	ld (state_franky_boss),a 
	ld a,INVENTORY_FRANKY_NOTE
; 	jr inventory_fn_use_pickup_continue

inventory_fn_use_pickup_continue:
	ld (hl),a
	call remove_room_object
	call play_SFX_ui_select
; inventory_fn_use_back_to_jump:
; 	xor a
; 	ld (inventory_selected),a
	jp hud_update_inventory	

inventory_fn_use_breakable_crate:
	ld bc, TEXT_USE_BREAKABLE_CRATE
	jp queue_hud_message


inventory_fn_use_door_vampire1:
	call state_password_lock
	; check if it has the right password:
	ld iy,state_vampire1_state
	ld de,password_vampire1_en
	ld a,(current_language_page)
	cp TEXT_PAGE_EN
	jr z,inventory_fn_use_door_vampire1_en
	ld de,password_vampire1_es
inventory_fn_use_door_vampire1_en:
	ld c,INVENTORY_DIARY1
inventory_fn_use_door_vampire2_entry_point:
inventory_fn_use_door_vampire3_entry_point:
inventory_fn_use_door_vampire4_entry_point:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	; if player has not yet seen the cut scene, do not let the doors open
	jr c,inventory_fn_use_door_vampire1_door_return_to_game

	call match_passwords
	jr nz,inventory_fn_use_door_vampire1_door_return_to_game
	; passwords match!
	ld a,1
	ld (iy),a
	push bc
		push ix
			call puzzle_solved_sound
		pop ix
		call remove_room_object
	pop bc

	; remove the corresponding diary:
	ld a,c
	cp INVENTORY_VAMPIRE1_NOTE
	jr z,inventory_fn_use_door_vampire3_lose_items
	call inventory_find_slot
	jr nz,inventory_fn_use_door_vampire1_no_diary
	ld (hl),0
	call hud_update_inventory
	ld bc, TEXT_OPEN_VAMPIRE1_DOOR
	call queue_hud_message
	ld bc, TEXT_OPEN_VAMPIRE1_DOOR2
	call queue_hud_message
inventory_fn_use_door_vampire1_no_diary:
inventory_fn_use_door_vampire1_no_note2:	
	call play_SFX_door_open

inventory_fn_use_door_vampire1_door_return_to_game:
	ld a,(state_current_room)
	cp 84
	jp z,play_music_ingame_subbasement
	jp play_music_ingame_cellar15


inventory_fn_use_door_vampire2:
	call state_password_lock
	ld iy,state_vampire2_state
	ld de,password_vampire2
	ld c,INVENTORY_DIARY2
	jr inventory_fn_use_door_vampire2_entry_point

inventory_fn_use_door_vampire3:
	call state_password_lock
	ld iy,state_vampire3_state
	ld de,password_vampire3
	ld c,INVENTORY_VAMPIRE1_NOTE
	jr inventory_fn_use_door_vampire3_entry_point

inventory_fn_use_door_vampire4:
	call state_password_lock
	ld iy,state_vampire4_state
	ld de,password_vampire4
	ld c,INVENTORY_VLAD_NOTE
	jr inventory_fn_use_door_vampire4_entry_point

inventory_fn_use_door_vampire3_lose_items:
	ld a,INVENTORY_VAMPIRE1_NOTE
	call inventory_find_slot
	jr nz,inventory_fn_use_door_vampire1_no_note1
	ld (hl),0
	call hud_update_inventory
inventory_fn_use_door_vampire1_no_note1:
	ld a,INVENTORY_VAMPIRE2_NOTE
	call inventory_find_slot
	jr nz,inventory_fn_use_door_vampire1_no_note2
	ld (hl),0
	call hud_update_inventory
	jr inventory_fn_use_door_vampire1_no_note2


inventory_fn_use_bookshelves:
	ld bc, TEXT_USE_BOOKSHELVES
	jp queue_hud_message

inventory_fn_use_university_notes:
	ld bc, TEXT_USE_UNIVERSITY_NOTES
	jp queue_hud_message

inventory_fn_use_beggar:
	ld hl,state_beggar
	ld a,(hl)
	or a
	jr z,inventory_fn_use_beggar_init
	dec a
	jr z,inventory_fn_use_beggar_2nd_interaction
	dec a
	jr nz,inventory_fn_use_beggar_dead
inventory_fn_use_beggar_3rd_interaction:	
	ld bc, TEXT_USE_BEGGAR5
	jp queue_hud_message
inventory_fn_use_beggar_2nd_interaction:
	ld (hl),2
	ld bc, TEXT_USE_BEGGAR2
	call queue_hud_message
	ld bc, TEXT_USE_BEGGAR3
	call queue_hud_message
	ld bc, TEXT_USE_BEGGAR4
	jp queue_hud_message
inventory_fn_use_beggar_init:
	ld (hl),1
	ld bc, TEXT_HELLO
	call queue_hud_message
	ld bc, TEXT_USE_BEGGAR1
	jp queue_hud_message


inventory_fn_use_beggar_bag:
	ld bc, TEXT_USE_BEGGAR_BAG
	jp queue_hud_message

inventory_fn_use_beggar_dead:
	ld bc, TEXT_USE_BEGGAR_DEAD1
	call queue_hud_message
	ld bc, TEXT_USE_BEGGAR_DEAD2
	call queue_hud_message
	ld bc, TEXT_USE_BEGGAR_DEAD3
	call queue_hud_message
	ld bc, TEXT_USE_BEGGAR_DEAD4
	jp queue_hud_message

inventory_fn_use_horse:
	ld bc, TEXT_USE_HORSE
	jp queue_hud_message

inventory_fn_use_horse_car:
	ld bc, TEXT_USE_HORSECAR1
	call queue_hud_message
	ld a,(state_choffeur_store)
	or a
	ret nz
	ld bc, TEXT_USE_HORSECAR2
	jp queue_hud_message

inventory_fn_use_bookstore_clerk:
	ld hl,state_choffeur_store
	ld a,(hl)
	or a
	jr z,inventory_fn_use_bookstore_clerk_first
	cp 2
	jr z,inventory_fn_use_bookstore_clerk_book
	ld bc, TEXT_USE_CLERK6
	jp queue_hud_message
inventory_fn_use_bookstore_clerk_first:
	ld (hl),1  ; choffeur wakes up
	ld bc, TEXT_USE_CLERK2
	call queue_hud_message
	ld bc, TEXT_USE_CLERK3
	call queue_hud_message
	ld bc, TEXT_USE_CLERK4
	ld a,1
	ld (call_james_when_hud_messages_done),a
	jp queue_hud_message
inventory_fn_use_bookstore_clerk_book:
	ld (hl),3  ; book purchased
	; gain item:
	xor a
	call inventory_find_slot  ; No way there is no slot free here, so no need
							  ; to check if inventory is full.
	ld (hl),INVENTORY_HISTORY_OF_ROMANIA
	call hud_update_inventory
	ld bc, TEXT_USE_CLERK7
	call queue_hud_message
	ld bc, TEXT_USE_CLERK8
	jp queue_hud_message


inventory_fn_use_store_bookshelf:
	ld bc, TEXT_USE_STORE_BOOKSHELF1
	jp queue_hud_message


inventory_fn_use_store_bookshelf_book:
	ld hl,state_choffeur_store
	ld a,(hl)
	cp 3
	jr z,inventory_fn_use_store_bookshelf
	dec a
	jr z,inventory_fn_use_store_bookshelf_book_ready
	ld bc, TEXT_USE_STORE_BOOKSHELF4
	jp queue_hud_message
inventory_fn_use_store_bookshelf_book_ready:
	ld (hl),2  ; book seen
	ld bc, TEXT_USE_STORE_BOOKSHELF2
	call queue_hud_message
	ld bc, TEXT_USE_STORE_BOOKSHELF3
	jp queue_hud_message


inventory_fn_use_choffeur:
	ld bc, TEXT_USE_CHOFFEUR1
	call queue_hud_message
	ld bc, TEXT_USE_CHOFFEUR2
	call queue_hud_message

inventory_fn_use_choffeur_loop:
	ld c,2
	call wait_for_interrupt
	call update_keyboard_buffers
	call update_hud_messages
	ld a,(hud_message_timer)
	or a
	jr nz,inventory_fn_use_choffeur_loop
	ld a,(hud_message_queue_size)
	or a
	jr nz,inventory_fn_use_choffeur_loop
	ld c,4
	call state_intro_pause
	jp state_travel_cutscene


inventory_fn_use_chapel_altar:
	ld a,(state_game_time_day)
	cp TIME_LUCY_ENTERS_SUBBASEMENT
	ret c  ; if lucy hasn't gone down, no puzzle
	ld a,(state_game_time_day)
	cp TIME_SUBBASEMENT_OPEN
	ret nc  ; if puzzle is already solved, we are done
	jp state_puzzle_chapel


inventory_fn_use_vlad_statue:
	ld hl,state_vlad_statue_examined
	ld (hl),1
	ld bc, TEXT_VLAD_STATUE1
	call queue_hud_message
	ld bc, TEXT_VLAD_STATUE2
	jp queue_hud_message


inventory_fn_use_coin_pile:
	ld bc, TEXT_GOLD_PILE1
	call queue_hud_message
	ld bc, TEXT_GOLD_PILE2
	call queue_hud_message
	ld bc, TEXT_GOLD_PILE3
	jp queue_hud_message


inventory_fn_use_vlad_clue_book:
	ld hl,state_reveal_clue_taken
	ld a,(hl)
	or a
	jp nz,inventory_fn_use_bookstack
	ld (hl),1
	; gain item:
	; xor a  ; not needed, as a == 0 here already
	call inventory_find_slot
	jr nz,inventory_fn_use_vlad_clue_book_inventory_full
	ld (hl),INVENTORY_REVEAL_CLUE
	call hud_update_inventory
inventory_fn_use_vlad_clue_book_inventory_full:	
	ld bc, TEXT_REVEAL_CLUE1
	call queue_hud_message
	ld bc, TEXT_REVEAL_CLUE2
	jp queue_hud_message


inventory_fn_use_mirror:
	ld bc, TEXT_USE_MIRROR
	jp queue_hud_message


inventory_fn_use_mirror_clue:
	ld bc, TEXT_MIRROR_CLUE1
	call queue_hud_message
	ld bc, TEXT_MIRROR_CLUE2
	call queue_hud_message
	ld bc, TEXT_MIRROR_CLUE3
	jp queue_hud_message


inventory_fn_use_chest_reveal:
	ld bc, TEXT_USE_CHEST_GUN1
	jp queue_hud_message


inventory_fn_use_chest_reveal2:
	ld a,(state_quincey_grave)
	cp 2
	jp z,inventory_fn_use_safe_already_open
	ld bc, TEXT_USE_CHEST_GUN1
	jp queue_hud_message


inventory_fn_use_chest_cutlery:
	ld bc, TEXT_CHEST_CUTLERY1
	call queue_hud_message
	ld a,(state_cutlery_taken)
	or a
	jr z,inventory_fn_use_chest_cutlery_not_taken
	ld bc, TEXT_CHEST_CUTLERY3
	jp queue_hud_message
inventory_fn_use_chest_cutlery_not_taken:
	ld hl,state_cutlery_taken
	ld (hl),1
	; gain cutlery:
	xor a
	call inventory_find_slot
	ret nz
	ld (hl),INVENTORY_CUTLERY
	call hud_update_inventory
	ld bc, TEXT_CHEST_CUTLERY2
	jp queue_hud_message


inventory_fn_use_chest_shovel:
	ld a,(state_shovel_taken)
	or a
	jr z,inventory_fn_use_chest_shovel_not_taken
	ld bc, TEXT_TAKE_SHOVEL2
	jp queue_hud_message
inventory_fn_use_chest_shovel_not_taken:
	ld hl,state_shovel_taken
	ld (hl),1
	; gain shovel:
	xor a
	call inventory_find_slot
	ret nz
	ld (hl),INVENTORY_SHOVEL
	call hud_update_inventory
	ld bc, TEXT_TAKE_SHOVEL
	jp queue_hud_message


inventory_fn_use_switch:
	SETMEGAROMPAGE_8000 3
	; we distinguish them by the switch "y" coordinate:
	call get_switch_mask  ; this gives us the switch mask in "c"
	ld hl,state_switches
	ld a,(hl)
	xor c
	ld (hl),a

	call switch_flip_gfx_state
	ld hl,SFX_lever
	call play_SFX_with_high_priority
	call switch_effect_on_room
	ret nz  ; if no change, just return
	call update_object_drawing_order_n_times
render_full_room_after_switch:
	ld de,0
	ld bc,16+(SCREEN_HEIGHT-2)*256  ; -2 so that we don't overwrite vitality and time
	call render_room_rectangle
	ld de,16
	ld bc,16+(SCREEN_HEIGHT-2)*256
	jp render_room_rectangle


switch_effect_on_room:
	SETMEGAROMPAGE_8000 3
	call switch_effect_on_room_page3
	SETMEGAROMPAGE_8000 2
	ret


sync_switch_state_with_global_state:
	SETMEGAROMPAGE_8000 3
	ld a,(n_objects)
	ld ix,objects
	ld b,a
sync_switch_state_with_global_state_loop:
	push bc
		ld a,(ix)
		cp OBJECT_TYPE_SWITCH
		jr nz,sync_switch_state_with_global_state_skip
		call get_switch_mask
		ld a,(state_switches)
		and c
		jr z,sync_switch_state_with_global_state_skip
		call switch_flip_gfx_state
sync_switch_state_with_global_state_skip:
		ld bc,OBJECT_STRUCT_SIZE
		add ix,bc
	pop bc
	djnz sync_switch_state_with_global_state_loop
	ret


inventory_fn_use_open_grave:
	ld hl,state_quincey_grave
	ld a,(hl)
	cp 3
	jp nz,inventory_fn_use_nothing_to_use
	; pick up key:
	ld (hl),1
	xor a
	call inventory_find_slot
	ret nz
	ld (hl),INVENTORY_QUINCEY_KEY
	call hud_update_inventory
	ld bc, TEXT_QUINCEY_KEY
	jp queue_hud_message


inventory_fn_use_clay:
	ld bc, TEXT_CLAY_INTERACT1
	call queue_hud_message
	ld bc, TEXT_CLAY_INTERACT2
	jp queue_hud_message


inventory_fn_use_log_book:
	ld a,1
	ld (RAM_game_saved),a
	ld hl,game_state_start
	ld de,RAM_save
	ld bc,game_state_end - game_state_start
	ldir
	ld bc, TEXT_LOG_BOOK1
	call queue_hud_message
	ld bc, TEXT_LOG_BOOK2
	jp queue_hud_message


;-----------------------------------------------
; input:
; - ix:	ptr to the object struct to use (with object type ID already set)
; - de: ptr to the compressed object data
inventory_spawn_object:
	ld a,(player_iso_x)
	add a,4
	rrca
	rrca
	rrca
	and #1f
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(player_iso_y)
	add a,4
	rrca
	rrca
	rrca
	and #1f
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	ld a,(player_iso_z)
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),a
	jp load_room_init_object_ptr_set


;-----------------------------------------------
redraw_area_after_dropped_item:
	ld e,(ix+OBJECT_STRUCT_SCREEN_TILE_X)
	ld d,(ix+OBJECT_STRUCT_SCREEN_TILE_Y)
	push de
		call update_object_drawing_order_n_times
	pop de	
	ld bc,#0302
	jp render_room_rectangle_safe


;-----------------------------------------------
inventory_fn_stool:
	ld a,(n_objects)
	cp MAX_ROOM_OBJECTS
; 	jr z,inventory_fn_drop_room_full
	ret z

	ld (hl),0  ; lose the stool from inventory

	; spawn a new stool:
	call find_new_object_ptr

	ld (ix),OBJECT_TYPE_STOOL
	ld de,object_stool_zx0
	call inventory_spawn_object

inventory_fn_candle_entrypoint:	
	; redraw area:
	call redraw_area_after_dropped_item

	ld hl,player_iso_z
	ld a,(hl)
	add 8
	ld (hl),a

	call play_SFX_door_open
	jp hud_update_inventory
; 	jr inventory_fn_use_back_to_jump


; inventory_fn_drop_room_full:
	; this should never happen!
; 	ld hl,SFX_ui_wrong
; 	jp play_SFX_with_high_priority
; 	ret


;-----------------------------------------------
; input:
; - ix: object
; output:
; - z: close by
; - nz: fat
check_if_object_close_by:
; 	ld b,20
; 	ld c,-16
	ld a,(player_iso_x)
	sub (ix+OBJECT_STRUCT_PIXEL_ISO_X)
	cp 20
	jp p,check_if_object_close_by_far
	cp -16
	jp m,check_if_object_close_by_far
	ld a,(player_iso_y)
	sub (ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	cp 20
	jp p,check_if_object_close_by_far
	cp -16
	jp m,check_if_object_close_by_far
	xor a
	ret
check_if_object_close_by_far:
	or 1
	ret


;-----------------------------------------------
inventory_fn_white_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_RIGHT_WHITE
	ld iy,state_white_key_taken
	jr inventory_fn_white_key_entry_point

inventory_fn_green_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_RIGHT_GREEN
	ld iy,state_green_key_taken
	jr inventory_fn_green_key_entry_point

inventory_fn_red_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_LEFT_RED
	ld iy,state_red_key_taken
	jr inventory_fn_red_key_entry_point

inventory_fn_yellow_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_LEFT_YELLOW
	ld iy,state_yellow_key_taken

inventory_fn_backyard_key_entry_point:
inventory_fn_green_key_entry_point:
inventory_fn_white_key_entry_point:
inventory_fn_red_key_entry_point:
	call check_if_object_type_nearby
	jr z,inventory_fn_yellow_key_found
inventory_fn_yellow_key_no_door:
	ld bc, TEXT_ITEM_KEY
	jp queue_hud_message
inventory_fn_yellow_key_found:
	; mark it in the global state:
	ld (iy),2

	; remove key from inventory:
	ld (hl),0

	; remove door (ix):
	call remove_room_object
	call play_SFX_door_open
	jp hud_update_inventory
; 	jp inventory_fn_use_back_to_jump



inventory_fn_gun_key:
	; check if the corresponding chest is in the room:
	ld a,OBJECT_TYPE_CHEST_GUN
	call check_if_object_type_nearby
	jr z,inventory_fn_gun_key_chest_found
inventory_fn_yellow_key_no_chest:
	ld bc, TEXT_ITEM_KEY_GUN
	jp queue_hud_message
inventory_fn_gun_key_chest_found:
	; mark it in the global state:
	ld a,2
	ld (state_gun_taken),a

	; switch gun key by gun:
	ld (hl),INVENTORY_GUN

	call play_SFX_door_open

	; message:
	ld bc, TEXT_TAKE_GUN1
	call queue_hud_message
	ld bc, TEXT_TAKE_GUN2
	call queue_hud_message
	jp hud_update_inventory



inventory_fn_gun:
	ld a,(gun_cooldown)
	or a
	ret nz
	ld a,GUN_COOLDOWN
	ld (gun_cooldown),a

	ld a,(n_objects)
	cp MAX_ROOM_OBJECTS
	ret z

	ld hl,SFX_explosion
	call play_SFX_with_high_priority

	; spawn the bullet:
	call find_new_object_ptr
	ld (ix),OBJECT_TYPE_BULLET
	ld a,(player_iso_x)
; 	add a,4
	srl a
	sra a
	sra a
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(player_iso_y)
; 	add a,4
	srl a
	sra a
	sra a
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	ld a,(player_iso_z)
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),a
	ld de, bullet_bin
	ld a,(player_direction)
	ld (ix+OBJECT_STRUCT_STATE),a
	jp load_room_init_object_ptr_set_decompressed


inventory_fn_red_key_half:
	ld a,INVENTORY_RED_KEY_H2
	call inventory_find_slot
	jr nz,inventory_fn_red_key_half_missing_one
	ld (hl),0
	ld a,INVENTORY_RED_KEY_H1
	call inventory_find_slot
	ld (hl),INVENTORY_RED_KEY
	ld bc, TEXT_MERGE_RED_KEY
	call queue_hud_message
	ld hl,SFX_assemble_key
	call play_SFX_with_high_priority
	jp hud_update_inventory

inventory_fn_red_key_half_missing_one:
	ld bc, TEXT_ITEM_HALF_KEY
	jp queue_hud_message



inventory_fn_letter3:
	; hide player:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 4)*8
    ld bc,#0a18
    call clear_rectangle_bitmap_mode_color

	; draw text:
	ld hl,letter3_lines
	ld a,22*8
	ld de,CHRTBL2+5*32*8+5*8
	ld iyl,COLOR_YELLOW
	ld b,8
	call render_letter_text_multilingual

	ld a,(state_letter3_taken)
	cp 4
	jr z,inventory_fn_letter3_secret_already_revealed
	cp 3
	jr nz,inventory_fn_letter3_no_secret
	; mark the code as seen!
	ld a,4
	ld (state_letter3_taken),a
	ld c,TIME_CODE_SEEN
	call update_state_time_day_if_needed
inventory_fn_letter3_secret_already_revealed:
	ld a,12*8
	ld de,CHRTBL2+5*32*8+12*8
	ld iyl,COLOR_YELLOW+COLOR_DARK_RED*16
	ld bc,TEXT_LETTER3_LINE1_SECRET
	call draw_text_from_bank_multilingual

inventory_fn_letter3_no_secret:

	; wait for button:
	call wait_for_space_updating_messages

	; mark letter as read:
	ld hl,state_letter3_taken
	ld a,(hl)
	cp 2
	jr nc,inventory_fn_letter3_read
	ld (hl),2
inventory_fn_letter3_read:

	; redraw room again:
	ld de,4 + 4*256
	ld bc,12+10*256
	call render_room_rectangle

	ld de,16 + 4*256
	ld bc,12+10*256
	jp render_room_rectangle


inventory_fn_lamp:
	ld a,(state_lamp_taken)
	dec a
	jr z,inventory_fn_lamp_off
	; lamp on, check if we have the letter and have read it:
	ld a,(state_letter3_taken)
	cp 2 ; letter read
	jr nz,inventory_fn_lamp_letter_not_read
	push hl
		ld a,INVENTORY_LAMP
		call inventory_find_slot
		jr z,inventory_fn_lamp_with_letter_read
	pop hl
inventory_fn_lamp_letter_not_read:
	ld bc, TEXT_ITEM_LAMP_ON
	jp queue_hud_message
inventory_fn_lamp_with_letter_read:
		ld a,3
		ld (state_letter3_taken),a
	pop hl
	ld (hl),0
	call hud_update_inventory
	ld bc, TEXT_USE_LAMP1
	call queue_hud_message
	ld bc, TEXT_USE_LAMP2
	jp queue_hud_message
; 	jp inventory_fn_use_back_to_jump
inventory_fn_lamp_off:
	ld bc, TEXT_ITEM_LAMP
	jp queue_hud_message


inventory_fn_oil:
	push hl
		ld a,INVENTORY_LAMP
		call inventory_find_slot
		jr z,inventory_fn_oil_with_lamp
	pop hl
	ld bc, TEXT_ITEM_OIL
	jp queue_hud_message

inventory_fn_oil_with_lamp:
		ld a,2
		ld (state_lamp_taken),a
	pop hl
	ld (hl),0
	call hud_update_inventory
	ld bc, TEXT_ITEM_OIL_USED
	jp queue_hud_message
; 	jp inventory_fn_use_back_to_jump


inventory_fn_heart:
	ex de,hl
	ld hl,player_health
	ld a,(hl)
	cp 5
	ret z
	ld hl,player_max_health
	xor a
	ld (de),a
	ld a,(hl)
	cp 5
	jr z,inventory_fn_heart_max
	inc (hl)
	ld a,(hl)
inventory_fn_heart_max:
	ld (player_health),a
	ld hl,SFX_use_heart
	call play_SFX_with_high_priority
	call hud_update_health
	jp hud_update_inventory
; 	jp inventory_fn_use_back_to_jump


inventory_fn_book:
	ld bc, TEXT_USE_BOOK
	call queue_hud_message

	ld hl,pentagram_clue_zx0
inventory_fn_reveal_clue_entrypoint:
	SETMEGAROMPAGE_A000 SPRITES_PAGE
	ld de,buffer1024
	call dzx0_standard
	call hide_player

	ld ix,buffer1024
	ld iy,5
	ld de,CHRTBL2+(6*32+13)*8
	ld bc,#0605
	ld hl,buffer1024+5*6
	ld (draw_hud_chunk_tile_ptr),hl
	SETMEGAROMPAGE_8000 3
	call draw_hud_chunk
	SETMEGAROMPAGE_8000 2

	; wait for button:
	call wait_for_space_updating_messages

	ld de,#060d
	ld bc,#0605
	call render_room_rectangle

	ld c,TIME_PENTAGRAM_CLUE_SEEN
	jp update_state_time_day_if_needed


inventory_fn_candle:
	ld a,(player_iso_z)
	or a
	jr nz,inventory_fn_candle_no_drop
	ld a,(state_game_time_day)
	cp TIME_PENTAGRAM_CLUE_SEEN
	jr c,inventory_fn_candle_no_drop  ; if player has not seen the clue yet, do not let them place the candles
	ld a,(state_current_room)
	cp #18
	jr z,inventory_fn_candle_ritual_room

inventory_fn_candle_no_drop:
	ld bc, TEXT_USE_CANDLE
	jp queue_hud_message

inventory_fn_candle_ritual_room:
	; No need to check if the room is full
	ld (hl),0  ; lose the item from inventory
	call hud_update_inventory

	; spawn a new candle:
	call find_new_object_ptr

	ld (ix),OBJECT_TYPE_CANDLE1
	SETMEGAROMPAGE_A000 OBJECTS_PAGE1
	ld de,object_candle_zx0
	call inventory_spawn_object

	; mark the position of the candle:
	ld hl,state_candle1_position
	ld a,(hl)
	inc a  ; cp #ff
	jr z,inventory_fn_candle_store_position
	ld (ix),OBJECT_TYPE_CANDLE2
	ld hl,state_candle2_position
	ld a,(hl)
	inc a  ; cp #ff
	jr z,inventory_fn_candle_store_position
	ld (ix),OBJECT_TYPE_CANDLE3
	ld hl,state_candle3_position

inventory_fn_candle_store_position:
	ld a,(state_current_room)
	ld (hl),a
	inc hl
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	rrca
	rrca
	rrca
	and #1f
	ld (hl),a
	inc hl
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	rrca
	rrca
	rrca
	and #1f
	ld (hl),a
	inc hl
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Z)
	ld (hl),a

	; redraw the area:
	call inventory_fn_candle_entrypoint

	; Check if all candles are in the right position:
	ld a,(state_ritual_room_state)
	cp 2
	jp p,inventory_fn_candle_store_position_reveal_pentagram_pattern

	ld hl,state_candle1_position
	call check_candle_position
	ret nz
	ld hl,state_candle2_position
	call check_candle_position
	ret nz
	ld hl,state_candle3_position
	call check_candle_position
	ret nz

	ld a,#ff
	ld (state_candle1_position),a
	ld (state_candle2_position),a
	ld (state_candle3_position),a

	; all candles are in the right position!!
	; visual effect:
	call disable_VDP_output_with_white_bg
		; play SFX:
		call play_SFX_door_open

		halt

		; open door and remove candles:
		call pentagram_remove_candles_and_door

		; remove book from inventory:
		ld a,INVENTORY_BOOK
		call inventory_find_slot
		jr nz,inventory_fn_candle_store_position_no_book
		ld (hl),0
		call hud_update_inventory
inventory_fn_candle_store_position_no_book:

		; messages:
		ld bc, TEXT_MSG_PENTAGRAM_SOLVED1
		call queue_hud_message
		ld bc, TEXT_MSG_PENTAGRAM_SOLVED2
		call queue_hud_message
		ld bc, TEXT_MSG_PENTAGRAM_SOLVED3
		call queue_hud_message

		; redraw room:
	    xor a
	    ld hl,CLRTBL2 + (0*32 + 0)*8
	    ld bc,#1320
	    call clear_rectangle_bitmap_mode_color
	    call render_full_room
	    call draw_hud_vit_time
    call enable_VDP_output_with_black_bg

	ld a,2
	ld (state_ritual_room_state),a
	ret


inventory_fn_candle_store_position_reveal_pentagram_pattern:
	ld hl,state_candle1_position
	call check_candle_position_reveal
	ret nz
	ld hl,state_candle2_position
	call check_candle_position_reveal
	ret nz

	ld a,#ff
	ld (state_candle1_position),a
	ld (state_candle2_position),a

	; all candles are in the right position!!
	; visual effect:
	call disable_VDP_output_with_white_bg
		; play SFX:
		call play_SFX_door_open
		halt

		; remove candles:
		call pentagram_remove_candles_and_door

		; make chests appear:
		; spawn chests:
		call find_new_object_ptr
		ld de,object_chest_reveal_zx0
		SETMEGAROMPAGE_A000 OBJECTS_PAGE2  ; page of garlic/stake
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),2
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),2
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),0
		ld (ix),OBJECT_TYPE_CHEST_REVEAL
		call load_room_init_object_ptr_set

		call find_new_object_ptr
		ld de,object_chest_reveal_zx0
		SETMEGAROMPAGE_A000 OBJECTS_PAGE2  ; page of garlic/stake
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),2
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),14
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),0
		ld (ix),OBJECT_TYPE_CHEST_REVEAL
		call load_room_init_object_ptr_set

		call find_new_object_ptr
		ld de,object_chest_reveal_zx0
		SETMEGAROMPAGE_A000 OBJECTS_PAGE2  ; page of garlic/stake
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),15
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),2
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),0
		ld (ix),OBJECT_TYPE_CHEST_REVEAL
		call load_room_init_object_ptr_set

		call find_new_object_ptr
		ld de,object_chest_reveal_zx0
		SETMEGAROMPAGE_A000 OBJECTS_PAGE2  ; page of garlic/stake
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),15
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),14
		ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),0
		ld (ix),OBJECT_TYPE_CHEST_REVEAL2
		call load_room_init_object_ptr_set

		; remove book from inventory:
		ld a,INVENTORY_REVEAL_CLUE
		call inventory_find_slot
		jr nz,inventory_fn_candle_store_position_reveal_pentagram_pattern_no_clue
		ld (hl),0
		call hud_update_inventory
	inventory_fn_candle_store_position_reveal_pentagram_pattern_no_clue:

		; messages:
		ld bc, TEXT_PENTAGRAM_REVEAL1
		call queue_hud_message

		; redraw room:
	    xor a
	    ld hl,CLRTBL2 + (0*32 + 0)*8
	    ld bc,#1320
	    call clear_rectangle_bitmap_mode_color
	    call render_full_room
	    call draw_hud_vit_time
	call enable_VDP_output_with_black_bg

	ld a,3
	ld (state_ritual_room_state),a
	ret


; candle_target_positions:
;     db 24, 7, 10, 0
;     db 24, 9, 9, 0
;     db 24, 9, 8, 0
check_candle_position:
	ld a,(hl)
	cp 24
	ret nz
	inc hl
	ld a,(hl)
	cp 7
	jr z,check_candle_position1
	cp 9
	ret nz
check_candle_position2_or_3:
	inc hl
	ld a,(hl)
	cp 9
	ret z
	cp 8
	ret
check_candle_position1:
	inc hl
	ld a,(hl)
	cp 10
	ret


; candle_target_positions_reveal:
;     db 24, 6, 8, 0
;     db 24, 7, 7, 0
check_candle_position_reveal:
	ld a,(hl)
	cp 24
	ret nz
	inc hl
	ld a,(hl)
	cp 6
	jr z,check_candle_reveal_position1
	cp 7
	ret nz
check_candle_reveal_position2:
	inc hl
	ld a,(hl)
	cp 7
	ret
check_candle_reveal_position1:
	inc hl
	ld a,(hl)
	cp 8
	ret


pentagram_remove_candles_and_door:
	ld ix,objects
	ld a,(n_objects)
	ld b,a
pentagram_remove_candles_and_door_loop:
	ld a,(ix)
	push bc
		cp OBJECT_TYPE_CANDLE1
		push af
			call z,remove_room_object_no_redraw
		pop af
		jr z,pentagram_remove_candles_and_door_loop_loop_skip
		cp OBJECT_TYPE_CANDLE2
		push af
			call z,remove_room_object_no_redraw
		pop af
		jr z,pentagram_remove_candles_and_door_loop_loop_skip
		cp OBJECT_TYPE_CANDLE3
		push af
			call z,remove_room_object_no_redraw
		pop af
		jr z,pentagram_remove_candles_and_door_loop_loop_skip
		cp OBJECT_TYPE_DOOR_RITUAL
		push af
			call z,remove_room_object_no_redraw
		pop af
		jr z,pentagram_remove_candles_and_door_loop_loop_skip
		ld de,OBJECT_STRUCT_SIZE
		add ix,de
pentagram_remove_candles_and_door_loop_loop_skip:
	pop bc
	djnz pentagram_remove_candles_and_door_loop
	ret


inventory_fn_diary1:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 3)*8
    ld bc,#0a1a
    call clear_rectangle_bitmap_mode_color

	; draw text:
	ld hl,diary1_lines
	ld a,24*8
	ld de,CHRTBL2+5*32*8+4*8
	ld iyl,COLOR_YELLOW
	ld b,8
	call render_letter_text_multilingual

	; wait for button:
	call wait_for_space_updating_messages

	; redraw room again:
	ld de,3 + 4*256
	ld bc,13+10*256
	call render_room_rectangle
	ld de,16 + 4*256
	ld bc,13+10*256
	jp render_room_rectangle


inventory_fn_diary2:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 3)*8
    ld bc,#0b1a
    call clear_rectangle_bitmap_mode_color

	; draw text:
	ld hl,diary2_lines
	ld a,24*8
	ld de,CHRTBL2+5*32*8+4*8
	ld iyl,COLOR_YELLOW
	ld b,9
	call render_letter_text_multilingual

	; wait for button:
	call wait_for_space_updating_messages

	; redraw room again:
	ld de,3 + 4*256
	ld bc,13+11*256
	call render_room_rectangle
	ld de,16 + 4*256
	ld bc,13+11*256
	jp render_room_rectangle


inventory_fn_diary3:
	ld (hl),INVENTORY_BACKYARD_KEY
	call hud_update_inventory

	ld a,1
	ld (state_backyard_key_taken),a

	ld bc, TEXT_USE_DIARY3_1
	call queue_hud_message
	ld bc, TEXT_USE_DIARY3_2
	call queue_hud_message
	ld bc, TEXT_USE_DIARY3_3
	jp queue_hud_message


inventory_fn_backyard_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_RIGHT_BLUE
	ld iy,state_backyard_key_taken
	jp inventory_fn_backyard_key_entry_point


inventory_fn_lab_notes:
	; hide player:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (2*32 + 3)*8
    ld bc,#0e1a
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,lab_notes_lines
	ld a,24*8
	ld de,CHRTBL2+3*32*8+4*8
	ld iyl,COLOR_YELLOW
	ld b,12
	call render_letter_text_multilingual
	; wait for button:
	call wait_for_space_updating_messages

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (2*32 + 3)*8
    ld bc,#0e1a
    call clear_rectangle_bitmap_mode_color
	; draw text:
	ld hl,lab_notes_lines2
	ld a,24*8
	ld de,CHRTBL2+3*32*8+4*8
	ld iyl,COLOR_YELLOW
	ld b,10
	call render_letter_text_multilingual
	; wait for button:
	call wait_for_space_updating_messages

	; redraw room again:
	ld de,3 + 2*256
	ld bc,13+14*256
	call render_room_rectangle
	ld de,16 + 2*256
	ld bc,13+14*256
	call render_room_rectangle

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 3)*8
    ld bc,#0b1a
    call clear_rectangle_bitmap_mode_color
	; draw text:
	ld hl,lab_notes_lines3
	ld a,24*8
	ld de,CHRTBL2+5*32*8+4*8
	ld iyl,COLOR_YELLOW
	ld b,9
	call render_letter_text_multilingual
	; wait for button:
	call wait_for_space_updating_messages

	; redraw room again:
	ld de,3 + 4*256
	ld bc,13+11*256
	call render_room_rectangle
	ld de,16 + 4*256
	ld bc,13+11*256
	call render_room_rectangle

	; mark letter as read:
	ld hl,state_lab_notes_taken
	ld a,(hl)
	cp 2
	ret z
	ld (hl),2
	ld bc, TEXT_USE_LAB_NOTES_1
	call queue_hud_message
	ld bc, TEXT_USE_LAB_NOTES_2
	call queue_hud_message
	ld bc, TEXT_USE_LAB_NOTES_3
	jp queue_hud_message


inventory_fn_hammer:
	ld de,OBJECT_STRUCT_SIZE
	ld ix,objects
	push hl
		ld hl,n_objects
		ld b,(hl)
	pop hl
inventory_fn_hammer_loop:
	ld a,(ix)
	cp OBJECT_TYPE_CRATE_GARLIC1
	jr z,inventory_fn_hammer_garlic1_crate
	cp OBJECT_TYPE_CRATE_GARLIC2
	jr z,inventory_fn_hammer_garlic2_crate
	cp OBJECT_TYPE_CRATE_GARLIC3
	jr z,inventory_fn_hammer_garlic3_crate
	cp OBJECT_TYPE_CRATE_STAKE1
	jp z,inventory_fn_hammer_stake1_crate
	cp OBJECT_TYPE_CRATE_STAKE2
	jp z,inventory_fn_hammer_stake2_crate
	cp OBJECT_TYPE_CRATE_STAKE3
	jp z,inventory_fn_hammer_stake3_crate
	cp OBJECT_TYPE_MIRROR_NW
	jp z,inventory_fn_hammer_mirror_nw
	cp OBJECT_TYPE_MIRROR_NE
	jp z,inventory_fn_hammer_mirror_ne
inventory_fn_hammer_loop_next:
	add ix,de
	djnz inventory_fn_hammer_loop
inventory_fn_hammer_no_breakable_crate:
	ld bc, TEXT_USE_HAMMER1
	jp queue_hud_message

inventory_fn_hammer_garlic1_crate:
	call check_if_object_close_by
	jr nz, inventory_fn_hammer_loop_next
	ld a,1
	ld (state_crate_garlic1),a
	ld a,OBJECT_TYPE_GARLIC1
	push af
	jr inventory_fn_hammer_garlic_crate_continue

inventory_fn_hammer_garlic2_crate:
	call check_if_object_close_by
	jr nz, inventory_fn_hammer_loop_next
	ld a,1
	ld (state_crate_garlic2),a
	ld a,OBJECT_TYPE_GARLIC2
	push af
	jr inventory_fn_hammer_garlic_crate_continue

inventory_fn_hammer_garlic3_crate:
	call check_if_object_close_by
	jr nz, inventory_fn_hammer_loop_next
	ld a,1
	ld (state_crate_garlic3),a
	ld a,OBJECT_TYPE_GARLIC3
	push af

inventory_fn_hammer_garlic_crate_continue:
	; remove crate (save its position first):
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Z)
	push af
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	push af
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	push af
	call remove_room_object

	ld hl,SFX_break_crate
	call play_SFX_with_high_priority

	; spawn garlic:
	call find_new_object_ptr

	ld de,object_garlic_zx0
inventory_fn_hammer_crate_continue:	
	SETMEGAROMPAGE_A000 OBJECTS_PAGE2  ; page of garlic/stake
	pop af
	rrca
	rrca
	rrca
	and #1f
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
	pop af
	rrca
	rrca
	rrca
	and #1f
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	pop af
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Z),a
	pop af
	ld (ix),a
	call load_room_init_object_ptr_set

	; redraw area:
	call redraw_area_after_dropped_item

	ld bc, TEXT_USE_HAMMER2
	jp queue_hud_message


inventory_fn_hammer_stake1_crate:
	call check_if_object_close_by
	jp nz, inventory_fn_hammer_loop_next
	ld a,1
	ld (state_crate_stake1),a
	ld a,OBJECT_TYPE_STAKE1
	push af
	jr inventory_fn_hammer_stake_crate_continue

inventory_fn_hammer_stake2_crate:
	call check_if_object_close_by
	jp nz, inventory_fn_hammer_loop_next
	ld a,1
	ld (state_crate_stake2),a
	ld a,OBJECT_TYPE_STAKE2
	push af
	jr inventory_fn_hammer_stake_crate_continue

inventory_fn_hammer_stake3_crate:
	call check_if_object_close_by
	jp nz, inventory_fn_hammer_loop_next
	ld a,1
	ld (state_crate_stake3),a
	ld a,OBJECT_TYPE_STAKE3
	push af

inventory_fn_hammer_stake_crate_continue:
	; remove crate (save its position first):
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Z)
	push af
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	push af
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	push af
	call remove_room_object
	ld hl,SFX_break_crate
	call play_SFX_with_high_priority

	; spawn stake:
	call find_new_object_ptr

	ld de,object_stake_zx0
	jp inventory_fn_hammer_crate_continue


inventory_fn_hammer_mirror_nw:
	call check_if_object_close_by
	jp nz, inventory_fn_hammer_loop_next
	call remove_room_object

	ld hl,SFX_break_crate
	call play_SFX_with_high_priority

	ld hl,state_mirrors_broken
	ld a,(state_current_room)
	cp 18
	jr z,inventory_fn_hammer_mirror_nw_room18
	cp 51
	jr z,inventory_fn_hammer_mirror_nw_room51
	cp 55
	jr z,inventory_fn_hammer_mirror_nw_room55
	cp 57
	jr z,inventory_fn_hammer_mirror_nw_room57
inventory_fn_hammer_mirror_nw_room59:
	set 5,(hl)
inventory_fn_hammer_mirror_nw_room57_entry_point:
	ld bc, TEXT_USE_MIRROR2
	call queue_hud_message
	ld bc, TEXT_USE_MIRROR3
	call queue_hud_message
	ld bc, TEXT_USE_MIRROR5
	jp queue_hud_message
inventory_fn_hammer_mirror_nw_room18:
	set 1,(hl)
	ld a,INVENTORY_HEART
	jr inventory_fn_hammer_mirror_nw_entry_point
inventory_fn_hammer_mirror_nw_room51:
	set 2,(hl)
	ld a,INVENTORY_CANDLE
	jr inventory_fn_hammer_mirror_nw_entry_point
inventory_fn_hammer_mirror_nw_room55:
	set 3,(hl)
	ld a,INVENTORY_CANDLE
	jr inventory_fn_hammer_mirror_nw_entry_point
inventory_fn_hammer_mirror_nw_room57:
	set 4,(hl)
	jr inventory_fn_hammer_mirror_nw_room57_entry_point


inventory_fn_hammer_mirror_ne:
	; This can only be the mirror in the vampire residence area
	call check_if_object_close_by
	jp nz, inventory_fn_hammer_loop_next
	call remove_room_object

	ld hl,SFX_break_crate
	call play_SFX_with_high_priority

	ld hl,state_mirrors_broken
	set 0,(hl)  ; mark mirror as broken

	; gain item:
	ld a,INVENTORY_PRISON_KEY
inventory_fn_hammer_mirror_nw_entry_point:
	push af
		xor a
		call inventory_find_slot  ; assume there is a free slot
	pop af
	ld (hl),a

	call hud_update_inventory
	ld bc, TEXT_USE_MIRROR2
	call queue_hud_message
	ld bc, TEXT_USE_MIRROR3
	call queue_hud_message
	ld bc, TEXT_USE_MIRROR4
	jp queue_hud_message


inventory_fn_garlic:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
	jp m,inventory_fn_garlic_do_not_rub
	push hl
		ld a,INVENTORY_STAKE
		call inventory_find_slot
		jr z,inventory_fn_garlic_with_stake
	pop hl
inventory_fn_garlic_do_not_rub:
	ld bc, TEXT_USE_GARLIC1
	jp queue_hud_message
inventory_fn_garlic_with_stake:
		ld (hl),INVENTORY_RUBBED_STAKE
	pop hl
	ld (hl),0
	call hud_update_inventory
	ld bc, TEXT_USE_GARLIC2
	jp queue_hud_message


inventory_fn_stake:
	ld bc, TEXT_USE_STAKE
	jp queue_hud_message


inventory_fn_rubbed_stake:
	ld a,(state_current_room)
	cp 35
	jr z,inventory_fn_rubbed_stake_vampire1_room
	cp 45
	jr z,inventory_fn_rubbed_stake_vampire2_room
; 	cp 42
; 	jr z,inventory_fn_rubbed_stake_vampire3_room
inventory_fn_rubbed_stake_describe:
	ld bc, TEXT_USE_RUBBED_STAKE
	jp queue_hud_message

inventory_fn_rubbed_stake_vampire1_room:
	ld a,(state_vampire1_state)
	cp 2
	jr z,inventory_fn_rubbed_stake_describe
	jr inventory_fn_rubbed_stake_vampire_room

inventory_fn_rubbed_stake_vampire2_room:
	ld a,(state_vampire2_state)
	cp 2
	jr z,inventory_fn_rubbed_stake_describe
	jr inventory_fn_rubbed_stake_vampire_room

; inventory_fn_rubbed_stake_vampire3_room:
; 	ld a,(state_vampire3_state)
; 	cp 2
; 	jr z,inventory_fn_rubbed_stake_describe

inventory_fn_rubbed_stake_vampire_room:
	ld a,(current_room_vampire_state)
	or a
	jr z,inventory_fn_rubbed_stake_vampire_room_sleeping
inventory_fn_rubbed_stake_vampire_room_awake:
	ld bc, TEXT_USE_RUBBED_STAKE_AWAKE
	jp queue_hud_message

inventory_fn_rubbed_stake_vampire_room_sleeping:
	; check if we are near a coffin2:
	ld a,OBJECT_TYPE_COFFIN2
	call find_closeby_room_object
	jr z,inventory_fn_rubbed_stake_vampire_room_sleeping_found
	ld bc, TEXT_USE_RUBBED_STAKE_TOO_FAR
	jp queue_hud_message
inventory_fn_rubbed_stake_vampire_room_sleeping_found:

	; kill the vampire!!!
	ld (hl),0  ; lose the stake
	push hl
	    ; swap with a closed coffin:
		ld (ix),#ff ; this will force decompression
		call inventory_object_position_to_tiles
		SETMEGAROMPAGE_A000 OBJECTS_PAGE1
		ld de,object_coffin2_zx0
		call load_room_init_object_ptr_set
		ld (ix),OBJECT_TYPE_COFFIN2

		ld a,OBJECT_TYPE_COFFIN1
		call find_closeby_room_object
		ld (ix),#fe ; this will force decompression
		call inventory_object_position_to_tiles
		ld de,object_coffin1_zx0
		call load_room_init_object_ptr_set
		ld (ix),OBJECT_TYPE_COFFIN1

		ld bc, TEXT_USE_RUBBED_STAKE_KILL
		call queue_hud_message

		; visual effect:
		call hide_player
	    ld a,COLOR_WHITE + COLOR_WHITE*16
	    ld hl,CLRTBL2 + (0*32 + 0)*8
	    ld bc,#1320
	    call clear_rectangle_bitmap_mode_color

		; play SFX:
		ld hl,SFX_use_stake
		call play_SFX_with_high_priority	

		halt

	    call render_full_room
		call draw_hud_vit_time
	    call draw_player
	pop hl

	; mark vampire as dead:
	ld a,(state_current_room)
; 	cp 35
; 	jr z,inventory_fn_rubbed_stake_kill_vampire1
	cp 45
	jr z,inventory_fn_rubbed_stake_kill_vampire2
; ;	cp 42
;	jr z,inventory_fn_rubbed_stake_kill_vampire3
; inventory_fn_rubbed_stake_kill_vampire3:
; 	ld a,2
; 	ld (state_vampire3_state),a	
; 	call hud_update_inventory
; 	jp state_ending

inventory_fn_rubbed_stake_kill_vampire1:
	ld a,2
	ld (state_vampire1_state),a
	ld (hl),INVENTORY_VAMPIRE1_NOTE
	ld bc, TEXT_FIND_VAMPIRE_NOTE
inventory_fn_rubbed_stake_kill_vampire2_entrypoint:
	call queue_hud_message
	jp hud_update_inventory

inventory_fn_rubbed_stake_kill_vampire2:
	ld a,2
	ld (state_vampire2_state),a
	ld (hl),INVENTORY_VAMPIRE2_NOTE
	ld bc, TEXT_FIND_VAMPIRE_NOTE
	jr inventory_fn_rubbed_stake_kill_vampire2_entrypoint
; 	call queue_hud_message
; 	jp hud_update_inventory


inventory_object_position_to_tiles:
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_X)
	rrca
	rrca
	rrca
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_X),a
	ld a,(ix+OBJECT_STRUCT_PIXEL_ISO_Y)
	rrca
	rrca
	rrca
	ld (ix+OBJECT_STRUCT_PIXEL_ISO_Y),a
	ret


inventory_fn_vampire1_note:
	; hide player:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 3)*8
    ld bc,#0b1a
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,vampire1_note_lines
	ld a,24*8
	ld de,CHRTBL2+5*32*8+4*8
	ld b,9
inventory_fn_vampire2_note_entrypoint:
inventory_fn_vlad_note_entrypoint:
inventory_fn_vlad_diary_entrypoint:
inventory_fn_franky_letter_entrypoint:
	ld iyl,COLOR_YELLOW
inventory_fn_quincey_letter_entrypoint:
	call render_letter_text_multilingual
	; wait for button:
	call wait_for_space_updating_messages

	; redraw room again:
	ld de,3 + 3*256
	ld bc,13+13*256
	call render_room_rectangle
	ld de,16 + 3*256
	ld bc,13+13*256
	jp render_room_rectangle


inventory_fn_vampire2_note:
	; hide player:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (5*32 + 4)*8
    ld bc,#0718
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,vampire2_note_lines
	ld a,22*8
	ld de,CHRTBL2+6*32*8+5*8
	ld b,5
	jr inventory_fn_vampire2_note_entrypoint
; 	ld iyl,COLOR_YELLOW
; 	call render_letter_text
; 	; wait for button:
; 	call wait_for_space_updating_messages

; 	; redraw room again:
; 	ld de,4 + 5*256
; 	ld bc,12+7*256
; 	call render_room_rectangle
; 	ld de,16 + 5*256
; 	ld bc,12+7*256
; 	jp render_room_rectangle


inventory_fn_luggage:
	ld bc, TEXT_USE_LUGGAGE
	jp queue_hud_message


inventory_fn_newspaper:
	ld bc, TEXT_USE_NEWSPAPER
	jp queue_hud_message


inventory_fn_history_of_romania:
	ld a,(state_puzzle_box_taken)
	cp 2
	jr nc,inventory_fn_history_of_romania_read
	ld bc, TEXT_USE_HISTORY_OF_ROMANIA1
	call queue_hud_message
	ld bc, TEXT_USE_HISTORY_OF_ROMANIA2
	jp queue_hud_message
inventory_fn_history_of_romania_read:
	; check if we have examined vlad's statue:
	ld a,(state_vlad_statue_examined)
	or a
	jr z,inventory_fn_history_of_romania_read_no_clue
inventory_fn_history_of_romania_read_clue:
	ld bc, TEXT_PUZZLE_BOX_MSG_D1
	call queue_hud_message
	ld bc, TEXT_PUZZLE_BOX_MSG_D2
	call queue_hud_message
	ld bc, TEXT_PUZZLE_BOX_MSG_D3
	call queue_hud_message
	ld bc, TEXT_PUZZLE_BOX_MSG_D4
	jp queue_hud_message
inventory_fn_history_of_romania_read_no_clue:
	ld bc, TEXT_PUZZLE_BOX_MSG_C1
	jp queue_hud_message


inventory_fn_lucy_torn_note:
	ld bc, TEXT_LUCY_TORN_NOTE3
	call queue_hud_message
	ld bc, TEXT_LUCY_TORN_NOTE4
	call queue_hud_message
	ld bc, TEXT_LUCY_TORN_NOTE5
	call queue_hud_message
	ld bc, TEXT_LUCY_TORN_NOTE6
	jp queue_hud_message


inventory_fn_puzzle_box:
	ld a,(current_music)
	push af
		call state_puzzle_box
		call draw_player
		; mark as attempted:
		ld a,2
		ld (state_puzzle_box_taken),a 

		; Check if we solved it:
		ld de,password_puzzlebox
		call match_passwords
		jr z,inventory_fn_puzzle_box_solved
	pop af


	; We did not solve it, check if we have the book:
	call play_music_a
	ld a,(state_choffeur_store)
	cp 3 ; "history of Romaina" book purchased
	jr z,inventory_fn_puzzle_box_not_solved_book
inventory_fn_puzzle_box_not_solved_no_book:
	ld bc, TEXT_PUZZLE_BOX_MSG_A1
	call queue_hud_message
	ld bc, TEXT_PUZZLE_BOX_MSG_A2
	jp queue_hud_message

inventory_fn_puzzle_box_not_solved_book:
	ld bc, TEXT_PUZZLE_BOX_MSG_B1
	jp queue_hud_message

inventory_fn_puzzle_box_solved:
		call puzzle_solved_sound
		ld bc, TEXT_PUZZLE_BOX_MSG_E1
		call queue_hud_message

		ld a,3
		ld (state_puzzle_box_taken),a 		

		; replace box by note:
		ld a,INVENTORY_PUZZLE_BOX
		call inventory_find_slot
		ld (hl),INVENTORY_VLAD_NOTE
		call hud_update_inventory
	pop af
	jp play_music_a


inventory_fn_vlad_note:
	; hide player:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 4)*8
    ld bc,#0918
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,vlad_note_lines
	ld a,22*8
	ld de,CHRTBL2+5*32*8+5*8
	ld b,7
	jp inventory_fn_vlad_note_entrypoint


inventory_fn_vlad_diary:
	; display some messages:
	ld bc, TEXT_VLAD_DIARY_USE1
	call queue_hud_message
	ld bc, TEXT_VLAD_DIARY_USE2
	call queue_hud_message
	call wait_for_space_updating_messages

	; hide player:
	call hide_player

	; diary page 1:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 3)*8
    ld bc,#0b1a
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,vlad_diary_lines1
	ld a,24*8
	ld de,CHRTBL2+5*32*8+4*8
	ld b,9
	call inventory_fn_vlad_diary_entrypoint

	; diary page 2:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 3)*8
    ld bc,#0b1a
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,vlad_diary_lines2
	ld a,24*8
	ld de,CHRTBL2+5*32*8+4*8
	ld b,9
	call inventory_fn_vlad_diary_entrypoint
	
	; diary page 3:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (4*32 + 3)*8
    ld bc,#0b1a
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,vlad_diary_lines3
	ld a,24*8
	ld de,CHRTBL2+5*32*8+4*8
	ld b,5
	call inventory_fn_vlad_diary_entrypoint

	; Add final message:
	ld bc, TEXT_VLAD_DIARY_USE3
	call queue_hud_message
	ld bc, TEXT_VLAD_DIARY_USE4
	call queue_hud_message
	ld bc, TEXT_VLAD_DIARY_USE5
	call queue_hud_message
	ld bc, TEXT_VLAD_DIARY_USE6
	jp queue_hud_message



inventory_fn_reveal_clue:
	ld hl,pentagram_clue2_zx0
	jp inventory_fn_reveal_clue_entrypoint


inventory_fn_prison_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_PRISON_ENTRANCE
	ld iy,state_prison_door_entrance
	jp inventory_fn_backyard_key_entry_point


inventory_fn_cutlery:
	ld a,(state_quincey_note_read)
	or a
	jr z,inventory_fn_cutlery_describe
	ld a,(state_cutlery_taken)
	or a
	jr z,inventory_fn_cutlery_describe
	ld a,(state_cauldron_taken)
	or a
	jr nz,inventory_fn_cutlery_mix
inventory_fn_cutlery_describe:
	ld bc, TEXT_USE_CUTLERY
	jp queue_hud_message

; returns "nz" if it could not do it
inventory_fn_cutlery_mix:
	ld a,INVENTORY_CUTLERY
	call inventory_find_slot
	ld (hl),0
	ld a,INVENTORY_CAULDRON
	call inventory_find_slot
	ld (hl),INVENTORY_CAULDRON_CUTLERY
	call hud_update_inventory
	jp inventory_fn_cauldron_cutlery_describe


inventory_fn_cauldron:
	ld a,(state_quincey_note_read)
	or a
	jr z,inventory_fn_cauldron_describe
	ld a,(state_cutlery_taken)
	or a
	jr z,inventory_fn_cauldron_describe
	ld a,(state_cauldron_taken)
	or a
	jr nz,inventory_fn_cutlery_mix
inventory_fn_cauldron_describe:
	ld bc, TEXT_USE_CAULDRON
	jp queue_hud_message


inventory_fn_shovel:
	ld a,(state_quincey_grave)
	or a
	jr nz,inventory_fn_shovel_no_tombstone
	; Check if we are near the tombstone:
	ld a,OBJECT_TYPE_TOMBSTONE
	call check_if_object_type_nearby
	jr z,inventory_fn_shovel_tombstone_found
inventory_fn_shovel_no_tombstone:
	ld bc, TEXT_USE_SHOVEL
	jp queue_hud_message
inventory_fn_shovel_tombstone_found:
	; dig up the grave of quincey:
	ld bc, TEXT_OPEN_GRAVE1
	call queue_hud_message
	ld bc, TEXT_OPEN_GRAVE2
	call queue_hud_message
	ld bc, TEXT_OPEN_GRAVE3
	call queue_hud_message

	; wait for messages:
inventory_fn_shovel_tombstone_found_wait_for_messages:
	halt
	call update_hud_messages
	ld a,(hud_message_timer)
	or a
	jr nz,inventory_fn_shovel_tombstone_found_wait_for_messages
	ld a,(hud_message_queue_size)
	or a
	jr nz,inventory_fn_shovel_tombstone_found_wait_for_messages

	ld b,25
	call wait_b_halts

	ld hl,state_quincey_grave
	ld (hl),3  ; grave open, but key not taken

	; lose the shovel:
	ld a,INVENTORY_SHOVEL
	call inventory_find_slot
	ld (hl),0

	; reload the room:
	ld hl,map1_zx0
	ld de,#000b
	call teleport_player_to_room

	; teleport player to the right place:
	ld hl,player_iso_x
	ld (hl),64
	inc hl  ; player_iso_y
	ld (hl),72

	ld bc, TEXT_OPEN_GRAVE4
	call queue_hud_message	

	jp state_game


inventory_fn_skeleton_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_PRISON_PASSAGE
	ld iy,state_skeleton_key_taken
	jp inventory_fn_backyard_key_entry_point


inventory_fn_clay:
	ld a,(state_quincey_note_read)
	or a
	jr z,inventory_fn_clay_describe

	ld a,OBJECT_TYPE_SINK
	call check_if_object_type_nearby
	jr z,inventory_fn_clay_sink_found
inventory_fn_clay_no_sink:
	ld bc, TEXT_CLAY_WET1
	call queue_hud_message
	ld bc, TEXT_CLAY_WET2
	jp queue_hud_message

inventory_fn_clay_sink_found:
	ld a,(state_gun_taken)
	cp 2
	jr nz,inventory_fn_clay_sink_found_no_bullets
	
	ld a,INVENTORY_CLAY
	call inventory_find_slot
	ld (hl),INVENTORY_WET_MOLD
	call hud_update_inventory

	ld bc, TEXT_CLAY_WET5
	call queue_hud_message
	ld bc, TEXT_CLAY_WET6
	call queue_hud_message
	ld bc, TEXT_CLAY_WET7
	jp queue_hud_message

inventory_fn_clay_sink_found_no_bullets:
	ld bc, TEXT_CLAY_WET3
	call queue_hud_message
	ld bc, TEXT_CLAY_WET4
	jp queue_hud_message


inventory_fn_clay_describe:
	ld bc, TEXT_CLAY
	jp queue_hud_message


inventory_fn_quincey_key:
	ld a,OBJECT_TYPE_CHEST_REVEAL2
	call check_if_object_type_nearby
	jr z,inventory_fn_shovel_chest_found
inventory_fn_shovel_no_chest:
	ld bc, TEXT_ITEM_KEY
	jp queue_hud_message
inventory_fn_shovel_chest_found:

	; mark it in the global state:
	ld a,2
	ld (state_quincey_grave),a

	; switch keys:
	ld (hl),INVENTORY_FRANKY_KEY

	; gain letter:
	xor a
	call inventory_find_slot
	ld (hl),INVENTORY_QUINCEY_LETTER

	call play_SFX_door_open

	; message:
	ld bc, TEXT_TAKE_GUN1
	call queue_hud_message
	ld bc, TEXT_QUINCEY_CHEST
	call queue_hud_message
	jp hud_update_inventory



inventory_fn_franky_key:
	; check if the corresponding door is in the room:
	ld a,OBJECT_TYPE_DOOR_PRISON_FRANKY
	ld iy,state_franky_key_taken
	jp inventory_fn_backyard_key_entry_point


inventory_fn_quincey_letter:
	; mark as read:
	ld hl,state_quincey_note_read
	ld (hl),1

	; hide player:
	call hide_player

	; draw letter:
    ld a,COLOR_WHITE + COLOR_WHITE*16
    ld hl,CLRTBL2 + (3*32 + 3)*8
    ld bc,#0d1a
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,quincey_letter_lines
	ld a,24*8
	ld de,CHRTBL2+4*32*8+4*8
	ld b,11
	ld iyl,COLOR_WHITE
	jp inventory_fn_quincey_letter_entrypoint


inventory_fn_cauldron_cutlery:
	ld a,OBJECT_TYPE_FIREPLACE
	call check_if_object_type_nearby
	jr z,inventory_fn_cauldron_cutlery_fireplace_found
inventory_fn_cauldron_cutlery_no_fireplace:
inventory_fn_cauldron_cutlery_describe:
	ld bc, TEXT_MELT_CUTLERY1
	call queue_hud_message
	ld bc, TEXT_MELT_CUTLERY2
	jp queue_hud_message
inventory_fn_cauldron_cutlery_fireplace_found:
	ld a,INVENTORY_MOLD
	call inventory_find_slot
	jr z,inventory_fn_cauldron_cutlery_make_bullets
	ld bc, TEXT_MELT_SILVER1
	call queue_hud_message
	ld bc, TEXT_MELT_SILVER2
	jp queue_hud_message

inventory_fn_cauldron_cutlery_make_bullets:
	; create the silver bullets:
	ld (hl),INVENTORY_SILVER_BULLETS
	ld a,INVENTORY_CAULDRON_CUTLERY
	call inventory_find_slot
	ld (hl),0
	call hud_update_inventory
	ld bc, TEXT_MELT_SILVER3
	call queue_hud_message
	ld bc, TEXT_MELT_SILVER4
	jp queue_hud_message


inventory_fn_wet_mold:
	ld a,OBJECT_TYPE_FIREPLACE
	call check_if_object_type_nearby
	jr z,inventory_fn_wet_mold_fireplabe_found
inventory_fn_wet_mold_no_fireplabe:
	ld bc, TEXT_WET_MOLD
	jp queue_hud_message
inventory_fn_wet_mold_fireplabe_found:
	; cook the mold:
	ld hl,state_clay_taken
	ld (hl),2
	ld a,INVENTORY_WET_MOLD
	call inventory_find_slot
	ld (hl),INVENTORY_MOLD
	call hud_update_inventory
	ld bc, TEXT_MOLD_COOK1
	call queue_hud_message
	ld bc, TEXT_MOLD_COOK2
	jp queue_hud_message


inventory_fn_mold:
	ld bc, TEXT_MOLD
	jp queue_hud_message


inventory_fn_silver_bullets:
	ld bc, TEXT_SILVER_BULLETS
	jp queue_hud_message


inventory_fn_franky_note:
	; hide player:
	call hide_player

	; draw letter:
    ld a,COLOR_YELLOW + COLOR_YELLOW*16
    ld hl,CLRTBL2 + (8*32 + 8)*8
    ld bc,#0510
    call clear_rectangle_bitmap_mode_color
	; draw text:	
	ld hl,franky_letter_lines
	ld a,12*8
	ld de,CHRTBL2+10*32*8+11*8
	ld b,1
	jp inventory_fn_franky_letter_entrypoint


;-----------------------------------------------
; input:
; - a: object type to search for
; returns:
; - z: found
; - nz: not found
check_if_object_type_nearby:
	ld de,OBJECT_STRUCT_SIZE
	ld ix,objects
	push hl
		ld hl,n_objects
		ld b,(hl)
	pop hl
inventory_fn_gun_key_loop:
	cp (ix)
	jp z,check_if_object_close_by
	add ix,de
	djnz inventory_fn_gun_key_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - de: password to match
; output:
; - z: match
; - nz: no match
match_passwords:
	ld hl,puzzle_current_letters  ; current password
	ld b,6
inventory_fn_use_door_vampire1_loop:
	ld a,(de)
	cp (hl)
	ret nz
	inc de
	inc hl
	djnz inventory_fn_use_door_vampire1_loop
	ret


;-----------------------------------------------
; helper functions to save space in the ROM:
play_SFX_door_open:
	ld hl,SFX_door_open
	jp play_SFX_with_high_priority


play_SFX_ui_select:
	ld hl,SFX_ui_select
	jp play_SFX_with_high_priority


;-----------------------------------------------
inventory_effect_functions:
    dw inventory_fn_use
    dw inventory_fn_stool
    dw inventory_fn_yellow_key
    dw inventory_fn_gun
    dw inventory_fn_white_key
    dw inventory_fn_red_key_half
    dw inventory_fn_red_key_half
    dw inventory_fn_red_key
    dw inventory_fn_letter3
    dw inventory_fn_lamp
    dw inventory_fn_oil
    dw inventory_fn_heart
    dw inventory_fn_book
    dw inventory_fn_candle
    dw inventory_fn_gun_key
    dw inventory_fn_green_key
    dw inventory_fn_diary1
    dw inventory_fn_diary2
    dw inventory_fn_diary3
    dw inventory_fn_backyard_key
    dw inventory_fn_lab_notes
    dw inventory_fn_hammer
    dw inventory_fn_garlic
    dw inventory_fn_stake
    dw inventory_fn_rubbed_stake
    dw inventory_fn_vampire1_note
    dw inventory_fn_vampire2_note
    dw inventory_fn_luggage
    dw inventory_fn_newspaper
    dw inventory_fn_history_of_romania
    dw inventory_fn_lucy_torn_note
    dw inventory_fn_puzzle_box
    dw inventory_fn_vlad_note
    dw inventory_fn_vlad_diary
    dw inventory_fn_reveal_clue
    dw inventory_fn_prison_key
    dw inventory_fn_cutlery
    dw inventory_fn_cauldron
    dw inventory_fn_shovel
    dw inventory_fn_skeleton_key
    dw inventory_fn_clay
    dw inventory_fn_quincey_key
    dw inventory_fn_franky_key
    dw inventory_fn_quincey_letter
    dw inventory_fn_cauldron_cutlery
    dw inventory_fn_wet_mold
    dw inventory_fn_mold
    dw inventory_fn_silver_bullets
    dw inventory_fn_franky_note

