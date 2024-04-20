;-----------------------------------------------
draw_hud:
	ld hl,draw_hud_page3
	jp call_from_page_3_and_back_to_previous


;-----------------------------------------------
draw_hud_vit_time:
	ld hl,draw_hud_vit_time_page3
	jp call_from_page_3_and_back_to_previous


;-----------------------------------------------
; input:
; - c: desired time_day
; output:
; - nc: already updated
; - c: updated
update_state_time_day_if_needed:
	ld hl,update_state_time_day_if_needed_page3
	jp call_from_page_3_and_back_to_previous
; update_state_time_day_if_needed_page3:
; 	ld a,(state_game_time_day)
; 	cp c
; 	ret nc
; 	ld a,c
; 	ld (state_game_time_day),a

; 	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
;     ld hl,hud_zx0
;     ld de,buffer1024
;     call dzx0_standard
; 	ld hl,draw_hud_time_day_page3
; 	call call_from_page_3_and_back_to_previous
;  	scf
;  	ret


;-----------------------------------------------
hud_update_health:
	ld hl, CLRTBL2 + 32*8 * 17 + 3*8
	ld a,(player_health)
	or a
	jr z,hud_update_health_zero_health1
	ld b,a
hud_update_health_loop1:
	push bc
		push hl
			ld a,COLOR_DARK_RED*16
			ld bc,8
			call fast_FILVRM
		pop hl
		ld bc,32*8
		add hl,bc
		push hl
			ld a,COLOR_DARK_RED*16
			ld bc,8
			call fast_FILVRM
		pop hl
		ld bc,-31*8
		add hl,bc
	pop bc
	djnz hud_update_health_loop1
hud_update_health_zero_health1:

	ld a,(player_max_health)
	push hl
		ld hl,player_health
		sub (hl)
	pop hl
	ret z
	ld b,a
hud_update_health_loop2:
	push bc
		push hl
			ld a,COLOR_DARK_BLUE*16
			ld bc,8
			call fast_FILVRM
		pop hl
		ld bc,32*8
		add hl,bc
		push hl
			ld a,COLOR_DARK_BLUE*16
			ld bc,8
			call fast_FILVRM
		pop hl
		ld bc,-31*8
		add hl,bc
	pop bc
	djnz hud_update_health_loop2
	ret


;-----------------------------------------------
update_hud_messages_appear:
	ld hl,hud_message_timer
	dec (hl)

	; hl = CLRTBL2 + (23*32 + 32 - (hud_message_timer))*8
	ld a,32
	sub (hl)
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc, 23*32*8 + CLRTBL2
	add hl,bc
	; draw red cursor:
	ld a,(hud_message_timer)
	or a
	jr z,update_hud_messages_appear_no_red
	ld a,COLOR_BLACK*16 + COLOR_RED
	ld bc,8
	push hl
		call fast_FILVRM
	pop hl

update_hud_messages_appear_no_red:
	; turn it to yellow:
	ld a,(hud_message_timer)
	cp 19
	ret z
	ld bc,-8
	add hl,bc
	ld a,COLOR_BLACK*16 + COLOR_DARK_YELLOW
	ld bc,8
	jp fast_FILVRM


;-----------------------------------------------
check_event_when_hud_messages_done:
	ld hl,call_james_when_hud_messages_done
	ld a,(hl)
	or a
	ret z
	ld (hl),0
	ld hl,SFX_jaaaames
	call play_SFX_with_high_priority
	ld bc, TEXT_USE_CLERK5
	jp queue_hud_message
	

;-----------------------------------------------
update_hud_messages:
	ld a,(hud_message_timer)
	or a
	jr nz,update_hud_messages_appear

	ld hl,hud_message_queue_size
	ld a,(hl)
	or a
	jr z,check_event_when_hud_messages_done

	dec (hl)
	ld hl,hud_message_queue
	ld c,(hl)
	inc hl
	ld b,(hl)
	push bc
		inc hl
		ld de,hud_message_queue
		ld bc,(HUD_MESSAGE_QUEUE_SIZE - 1) * 2
		ldir
	pop bc
	; jp hud_add_message


;-----------------------------------------------
; input:
; - bc: text bank and text idx
hud_add_message:
	ld hl,hud_message_timer
	ld (hl),20
	push bc
		ld hl,hud_messages+2
		ld de,hud_messages
		ld bc,(MAX_HUD_MESSAGES-1)*2
		ldir
	pop bc
	inc c
	ld (hud_messages+(MAX_HUD_MESSAGES-1)*2),bc
	ld hl,hud_draw_messages_page3
	jp call_from_page_3_and_back_to_previous


;-----------------------------------------------
hud_update_inventory:
	ld hl,hud_update_inventory_page3
	jp call_from_page_3_and_back_to_previous


;-----------------------------------------------
clean_inventory_of_room_objects:
	ld hl,inventory
	ld bc,INVENTORY_SIZE*256
clean_inventory_of_room_objects_loop:
	ld a,(hl)
	dec a  ; cp INVENTORY_STOOL
	jr nz,clean_inventory_of_room_objects_loop_continue
	ld (hl),0
	ld c,1
clean_inventory_of_room_objects_loop_continue:
	inc hl
	djnz clean_inventory_of_room_objects_loop
	ld a,c
	or a
	ret z
	; add message about leaving stools behind:
	ld bc,TEXT_DROP_STOOLS
; 	jp queue_hud_message


;-----------------------------------------------
; input:
; - bc: text bank and text idx
queue_hud_message:
	ld a,(hud_message_queue_size)
	cp HUD_MESSAGE_QUEUE_SIZE
	ret z

	ld hl,hud_message_queue
	ld d,0
	ld e,a
	add hl,de
	add hl,de
	ld (hl),c
	inc hl
	ld (hl),b
	ld hl,hud_message_queue_size
	inc (hl)
	ret


;-----------------------------------------------
wait_for_space_updating_messages:
	halt
	call update_hud_messages
	call update_keyboard_buffers
	ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
	bit KEY_BUTTON1_BIT,a
	jr z,wait_for_space_updating_messages
	ret


;-----------------------------------------------
wait_for_space:
	halt
	call update_keyboard_buffers
	ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
	bit KEY_BUTTON1_BIT,a
	jr z,wait_for_space
	ret


;-----------------------------------------------
; input:
; - hl: letter lines
; - de: video ptr to draw to
; - iyl: attribute
; - a: width of the text in bytes
; - b: # of lines
render_letter_text_multilingual:
render_letter_text_loop:
    push bc
    	push af
	    	SETMEGAROMPAGE_A000 OTHER_DATA_PAGE
	    pop af
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        push hl
            push de
            push af
                bit 7,b
                call z,draw_text_from_bank_multilingual
            pop af
            pop hl
            ld bc,32*8
            add hl,bc
            ex de,hl
        pop hl
    pop bc
    djnz render_letter_text_loop
    ret


;-----------------------------------------------
; waits for "c" seconds, or for pressing space
; input:
; - c: # seconds to wait
; return:
; - z: exit by timeout
; - nz: exit by pressing space/button1
state_intro_pause:
state_intro_pause_loop1:
	ld b,50
state_intro_pause_loop2:
	halt
	push bc
    	call update_keyboard_buffers
    pop bc
    ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
    bit KEY_BUTTON1_BIT,a
    ret nz
    djnz state_intro_pause_loop2
    dec c
    jr nz,state_intro_pause_loop1
    ret


