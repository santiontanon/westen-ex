;-----------------------------------------------
draw_hud_page3:
	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
    ld hl,hud_zx0
    ld de,buffer1024
    call dzx0_standard

	; draw base hud background:
	ld ix, buffer1024 + 32*2  ; start of the name table of the hud
	ld de, CHRTBL2 + 32*8 * 19
	ld bc,32+5*256
	call draw_hud_chunk_from_hud
	call draw_hud_vit_time_already_decompressed
	call hud_draw_messages_page3
	jp hud_update_inventory


;-----------------------------------------------
draw_hud_vit_time_page3:
	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
    ld hl,hud_zx0
    ld de,buffer1024
    call dzx0_standard
draw_hud_vit_time_already_decompressed:
	; draw current time/day:
; 	; day:
; 	ld ix, buffer1024  ; start of the name table of the hud
; 	ld de, CHRTBL2 + 32*8 * 17 + 25*8
; 	ld bc,2+2*256
; 	call draw_hud_chunk_from_hud

; 	; comma:
; 	ld ix, buffer1024 + 2  ; start of the name table of the hud
; 	ld de, CHRTBL2 + 32*8 * 17 + 29*8
; 	ld bc,1+2*256
; 	call draw_hud_chunk_from_hud
	call draw_hud_time_day_page3

	; draw vitality base tiles:
	; draw vitality:
	ld ix, buffer1024 + 17 ; start of the name table of the hud
	ld de, CHRTBL2 + 32*8 * 17 + 0*8
	ld bc,2+2*256
	call draw_hud_chunk_from_hud

	ld b, MAX_HEALTH
	ld ix, buffer1024 + 19 ; start of the name table of the hud
	ld de, CHRTBL2 + 32*8 * 17 + 3*8
draw_hud_health_loop:
	push ix
	push bc
		push de
			ld bc,1+2*256
			call draw_hud_chunk_from_hud
		pop hl
		ld bc,8
		add hl,bc
		ex de,hl
	pop bc
	pop ix
	djnz draw_hud_health_loop

	; hide all the health tiles:
	xor a
	ld hl,CLRTBL2 + 32*8 * 17 + 3*8
	ld bc,MAX_HEALTH*8
	call fast_FILVRM

	xor a
	ld hl,CLRTBL2 + 32*8 * 18 + 3*8
	ld bc,MAX_HEALTH*8
	call fast_FILVRM

	jp hud_update_health


;-----------------------------------------------
draw_hud_time_day_page3:
	; units:  ((state_game_time_day)+1)/2 + buffer1024 + 10
	ld a,(state_game_time_day)
	push af
		inc a
		srl a
		ld b,0
		ld c,a
		ld hl,buffer1024 + 10
		add hl,bc
		push hl
		pop ix
		ld de, CHRTBL2 + 32*8 * 17 + 28*8
		ld bc,1+2*256
		call draw_hud_chunk_from_hud

	; tenths: (state_game_time_day) < 7 -> "2", 7,8 -> 3, else -> nothing
	pop af
	cp 7
	jp m,draw_hud_time_day_20s
	cp 9
	jp p,draw_hud_time_day_00s
draw_hud_time_day_30s:
	ld ix, buffer1024 + 8
	jr draw_hud_time_day_tens_set
draw_hud_time_day_20s:
	ld ix, buffer1024 + 7
draw_hud_time_day_tens_set:
	ld de, CHRTBL2 + 32*8 * 17 + 27*8
	ld bc,1+2*256
	call draw_hud_chunk_from_hud

draw_hud_time_day_00s:

	; Nov or Dec:
	ld a,(state_game_time_day)
	cp TIME_VAMPIRES_ARRIVE
draw_hud_nov:
	ld ix, buffer1024 + 20
	jr c,draw_hud_nov_dec_set
draw_hud_dec:
	ld ix, buffer1024 + 23
draw_hud_nov_dec_set:
	ld de, CHRTBL2 + 32*8 * 17 + 24*8
	ld bc,3+2*256
	call draw_hud_chunk_from_hud

	; am/pm:
	ld a,(state_game_time_day)
	and #01
	jr z,draw_hud_pm
draw_hud_am:
	ld ix, buffer1024 + 5  ; start of the name table of the hud
	jr draw_hud_am_pm_set
draw_hud_pm:
	ld ix, buffer1024 + 3  ; start of the name table of the hud
draw_hud_am_pm_set:
	ld de, CHRTBL2 + 32*8 * 17 + 30*8
	ld bc,2+2*256
; 	jp draw_hud_chunk_from_hud


;-----------------------------------------------
; input:
; - ix: name table
; - iy: name table width
; - de: ptr to draw to 
; - c: width
; - b: height
; - (draw_hud_chunk_tile_ptr) ptr where the tile data starts
draw_hud_chunk_from_hud:
	ld iy,32
	ld hl,buffer1024+32*7
	ld (draw_hud_chunk_tile_ptr),hl
draw_hud_chunk:
draw_hud_loop_y:
	push bc
		ld b,c
		push ix
			push de
draw_hud_loop_x:
			push bc
				ld a,(ix)
				inc ix

				; hl = (buffer1024+32*7) + a*16
				add a,a
				ld h,0
				ld l,a
				add hl,hl
				add hl,hl
				add hl,hl
				ld bc,(draw_hud_chunk_tile_ptr)
				add hl,bc

				push de
					call draw_tile_bitmap_mode
				pop hl
				ld bc,8
				add hl,bc
				ex de,hl
			pop bc
			djnz draw_hud_loop_x
			pop hl
			ld bc,32*8
			add hl,bc
			ex de,hl
		pop ix
		push iy
		pop bc
		add ix,bc
	pop bc
	djnz draw_hud_loop_y
	ret


;-----------------------------------------------
hud_update_inventory_page3:
	ld a,#ff
	ld (last_decompressed_inventory_bank),a

	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE

	; draw inventory:
	ld a,(inventory_first_displayed_item)
	ld hl,inventory
	ADD_HL_A
	ld b,INVENTORY_ROW_SIZE * 2  ; Only draw two rows
	ld de,CHRTBL2 + (19*32)*8
hud_update_inventory_loop:
	push bc
		ld a,(hl)
		inc hl
		push hl
			or a
			jp z,hud_update_inventory_empty
			dec a

			; decompress the correct bank:
			ld c,a
			rrca
			rrca
			rrca
			rrca
			and #0f
			ld hl,last_decompressed_inventory_bank
			cp (hl)
			jr z,hud_update_inventory_loop_bank_decompressed
			; decompress the bank:
			push de
			push bc
				ld (hl),a
				add a,a
				ld hl,inventory_tiles_ptrs
				ADD_HL_A
				ld e,(hl)
				inc hl
				ld d,(hl)
				ex de,hl
				ld de,buffer1024
				call dzx0_standard
			pop bc
			pop de
hud_update_inventory_loop_bank_decompressed:
			ld a,c
			and #0f  ; there are only 16 inventory gfx per bank
			ld h,0
			ld l,a
			add hl,hl
			add hl,hl
			add hl,hl
			add hl,hl
			add hl,hl
			add hl,hl
			ld bc,buffer1024
			add hl,bc
			call hud_update_inventory_draw_item
hud_update_inventory_drawn:
		pop hl

		; next position to draw:
		ex de,hl
			ld bc,INVENTORY_SLOT_WIDTH
			add hl,bc
		ex de,hl
	pop bc
	ld a,b
	cp INVENTORY_ROW_SIZE + 1
	jr nz,hud_update_inventory_loop_continue
	; next inventory line:
	push bc
		ex de,hl
			ld bc,(20 + 64)*8
			add hl,bc
		ex de,hl
	pop bc
hud_update_inventory_loop_continue:
	djnz hud_update_inventory_loop

hud_update_inventory_only_sprite:
	; pointer position:
	; x: (inventory_selected)*24
	ld a,(inventory_selected)
	ld hl,inventory_first_displayed_item
	sub (hl)
	add a,a
	add a,a
	add a,a  ; *8
; 	ld b,a
	add a,a  ; *16
; 	add a,b  ; *24
	ld (inventory_pointer_sprite_attributes+1),a

	; y: 19*8-1 or 22*8-1
	ld a,(inventory_selected)
	sub (hl)
	cp INVENTORY_ROW_SIZE
	jr nc,hud_update_inventory_row2
	ld a,19*8-1
	jr hud_update_inventory_continue
hud_update_inventory_row2:
	ld hl,inventory_pointer_sprite_attributes + 1
	ld a,(hl)
	add a, -INVENTORY_SLOT_WIDTH * (INVENTORY_ROW_SIZE)
	ld (hl),a 
	ld a,22*8-1
hud_update_inventory_continue:
	ld (inventory_pointer_sprite_attributes),a

	ld hl,inventory_pointer_sprite_attributes
	ld de,SPRATR2+6*4
	ld bc,4
	jp fast_LDIRVM	


hud_update_inventory_empty:
	push hl
	push de
		ex de,hl
		push hl
			ld bc,16
			xor a
			call fast_FILVRM
		pop hl
		ld bc,32*8
		add hl,bc
		ld bc,16
		xor a
		call fast_FILVRM
	pop de
	pop hl
	jr hud_update_inventory_drawn


hud_update_inventory_draw_item:
	push hl
	push de
		push hl
			push de
				call draw_tile_bitmap_mode
			pop hl
			ld bc,8
			add hl,bc
			ex de,hl
		pop hl
		ld c,16
		add hl,bc

		push hl
			push de
				call draw_tile_bitmap_mode
			pop hl
			ld bc,31*8
			add hl,bc
			ex de,hl
		pop hl
		ld c,16
		add hl,bc

		push hl
			push de
				call draw_tile_bitmap_mode
			pop hl
			ld bc,8
			add hl,bc
			ex de,hl
		pop hl
		ld c,16
		add hl,bc

		call draw_tile_bitmap_mode
	pop de
	pop hl
	ret


;-----------------------------------------------
hud_draw_messages_page3:
	ld hl,hud_messages
	ld b,MAX_HUD_MESSAGES
	ld de,CHRTBL2+(20*32+13)*8
hud_draw_messages_loop:
	push bc
		ld a,(hl)
		or a
		jr z,hud_draw_messages_empty
		ld c,a
		dec c
		inc hl
		push hl
		push de
			ld a,b
			dec a
			jr z,hud_draw_messages_loop_last
hud_draw_messages_loop_not_last:
			ld iyl, COLOR_BLACK*16 + COLOR_DARK_YELLOW + #8000
			jr hud_draw_messages_loop_color_set
hud_draw_messages_loop_last:
			ld a,(hud_message_timer)
			or a
			jr z,hud_draw_messages_loop_not_last
			ld iyl, COLOR_DARK_YELLOW*16 + COLOR_DARK_YELLOW + #8000
hud_draw_messages_loop_color_set:
			ld a,19*8
			ld b,(hl)
			call draw_text_from_bank_multilingual
		pop de
		pop hl
hud_draw_messages_loop_continue:		
		inc hl
		ex de,hl
			ld bc,32*8
			add hl,bc
		ex de,hl		
	pop bc
	djnz hud_draw_messages_loop
	ret

hud_draw_messages_empty:
	push hl
	push de
		push de
			call clear_text_rendering_buffer
		pop de
		ld a, COLOR_BLACK*16 + COLOR_DARK_YELLOW + #8000
		ld bc,18*8
		call render_text_draw_buffer
	pop de
	pop hl
	inc hl
	jr hud_draw_messages_loop_continue


;-----------------------------------------------
; input:
; - c: desired time_day
; output:
; - nc: already updated
; - c: updated
update_state_time_day_if_needed_page3:
	ld a,(state_game_time_day)
	cp c
	ret nc
	ld a,c
	ld (state_game_time_day),a

	SETMEGAROMPAGE_A000 GRAPHIC_DATA_PAGE
    ld hl,hud_zx0
    ld de,buffer1024
    call dzx0_standard
	call draw_hud_time_day_page3
 	scf
 	ret