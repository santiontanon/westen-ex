;-----------------------------------------------
create_wall_colliders:
	xor a
	ld (n_collision_objects),a
	ld iy,collision_objects

	ld a,(state_current_room)
	cp 69
	jp z,create_wall_colliders_street1
	cp 70
	jp z,create_wall_colliders_street2
	cp 71
	jp z,create_wall_colliders_street3

	; NW doors:
	xor a
	ld (door_collider_generation_position_x),a
	ld (door_collider_generation_position_y),a
	ld (door_collider_generation_door_type),a
	call create_wall_colliders_x

	; SE doors:
	ld a,(room_width)
	add a,a
	add a,a
	add a,a
	ld (door_collider_generation_position_x),a
	xor a
	ld (door_collider_generation_position_y),a
	ld a,#80
	ld (door_collider_generation_door_type),a
	call create_wall_colliders_x

	; NE doors:
	xor a
	ld (door_collider_generation_position_x),a
	ld (door_collider_generation_position_y),a
	ld a,#40
	ld (door_collider_generation_door_type),a
	call create_wall_colliders_y

	; SW doors:
	xor a
	ld (door_collider_generation_position_x),a
	ld a,(room_height)
	add a,a
	add a,a
	add a,a
	ld (door_collider_generation_position_y),a
	ld a,#c0
	ld (door_collider_generation_door_type),a
	call create_wall_colliders_y

	ld a,(state_current_room)
	or a
	jp z,create_extra_wall_colliders_house_entrance
	cp 72
	jp z,create_wall_colliders_bookstore	
	ret


create_wall_colliders_x:
	xor a
	ld (door_collider_generation_collided_door_type),a
	ld hl,n_collision_objects
	inc (hl)
	ld (iy), OBJECT_TYPE_COLLIDER
	ld a,(door_collider_generation_position_x)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X), a
	ld a,(door_collider_generation_position_y)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y), a
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z), 0
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W), 16
	ld a,MAX_COORDINATE
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H), a
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H), 80

	ld a,(n_doors)
	or a
	jr z,create_wall_colliders_x_done
	ld ix,doors
	ld b,a
create_wall_colliders_x_loop:
	ld a,(ix)
	and #c0
	ld hl,door_collider_generation_door_type
	cp (hl)
	jr nz,create_wall_colliders_x_loop_skip
	; check if we need to shorten the collider:
	ld a,(ix+DOOR_STRUCT_POSITION)
	add a,a
	add a,a
	add a,a
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	jr c,create_wall_colliders_x_loop_skip

	cp (iy+OBJECT_STRUCT_PIXEL_ISO_H)
	jr nc,create_wall_colliders_x_loop_skip
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H), a
	ld a,(ix)
	ld (door_collider_generation_collided_door_type),a

create_wall_colliders_x_loop_skip:
	ld de,DOOR_STRUCT_SIZE
	add ix,de
	djnz create_wall_colliders_x_loop
create_wall_colliders_x_done:

	ld a,(door_collider_generation_collided_door_type)
	and #3f
	dec a
	jr z,create_wall_colliders_x_done_wide_door
	ld a,16 ; door width
	jr create_wall_colliders_x_done_door_width_set
create_wall_colliders_x_done_wide_door:
	ld a,32 ; door width
create_wall_colliders_x_done_door_width_set:
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_Y)
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_H)
	ld (door_collider_generation_position_y),a

	ld de,OBJECT_STRUCT_SIZE
	add iy,de

	cp 20*8
	jp c,create_wall_colliders_x
	ret


create_wall_colliders_y:
	xor a
	ld (door_collider_generation_collided_door_type),a
	ld hl,n_collision_objects
	inc (hl)
	ld (iy), OBJECT_TYPE_COLLIDER
	ld a,(door_collider_generation_position_x)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X), a
	ld a,(door_collider_generation_position_y)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y), a
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z), 0
	ld a,MAX_COORDINATE
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W), a
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H), 16
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H), 80

	ld a,(n_doors)
	or a
	jr z,create_wall_colliders_y_done
	ld ix,doors
	ld b,a
create_wall_colliders_y_loop:
	ld a,(ix)
	and #c0
	ld hl,door_collider_generation_door_type
	cp (hl)
	jr nz,create_wall_colliders_y_loop_skip
	; check if we need to shorten the collider:
	ld a,(ix+DOOR_STRUCT_POSITION)
	add a,a
	add a,a
	add a,a
	add 16
	sub (iy+OBJECT_STRUCT_PIXEL_ISO_X)
	jr c,create_wall_colliders_y_loop_skip

	cp (iy+OBJECT_STRUCT_PIXEL_ISO_W)
	jr nc,create_wall_colliders_y_loop_skip
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W), a
	ld a,(ix)
	ld (door_collider_generation_collided_door_type),a

create_wall_colliders_y_loop_skip:
	ld de,DOOR_STRUCT_SIZE
	add ix,de
	djnz create_wall_colliders_y_loop
create_wall_colliders_y_done:

	ld a,(door_collider_generation_collided_door_type)
	and #3f
	dec a
	jr z,create_wall_colliders_y_done_wide_door
	ld a,16 ; door width
	jr create_wall_colliders_y_done_door_width_set
create_wall_colliders_y_done_wide_door:
	ld a,32 ; door width
create_wall_colliders_y_done_door_width_set:
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_X)
	add a,(iy+OBJECT_STRUCT_PIXEL_ISO_W)
	ld (door_collider_generation_position_x),a

	ld de,OBJECT_STRUCT_SIZE
	add iy,de

	cp 20*8
	jp c,create_wall_colliders_y
	ret


;-----------------------------------------------
create_wall_colliders_street1:
	ld hl,n_collision_objects
	ld b,8
	ld (hl),b
	ld hl,street1_colliders
	call create_wall_colliders_street
	; collider events:
	ld (iy-OBJECT_STRUCT_SIZE*3), OBJECT_TYPE_COLLIDER_EVENT
	ld (iy-OBJECT_STRUCT_SIZE*3+OBJECT_STRUCT_STATE), COLLIDER_EVENT_WRONG_WAY
	ld (iy-OBJECT_STRUCT_SIZE*2), OBJECT_TYPE_COLLIDER_EVENT
	ld (iy-OBJECT_STRUCT_SIZE*2+OBJECT_STRUCT_STATE), COLLIDER_EVENT_ENTER_HOME
	ld (iy-OBJECT_STRUCT_SIZE), OBJECT_TYPE_COLLIDER_EVENT
	ld (iy-OBJECT_STRUCT_SIZE+OBJECT_STRUCT_STATE), COLLIDER_EVENT_SCREAM
	ret

create_wall_colliders_street2:
	ld hl,n_collision_objects
	ld b,3
	ld (hl),b
	ld hl,street2_colliders
	jp create_wall_colliders_street

create_wall_colliders_street3:
	ld hl,n_collision_objects
	ld b,5
	ld (hl),b
	ld hl,street3_colliders
	call create_wall_colliders_street
	; collider events:
	ld (iy-OBJECT_STRUCT_SIZE), OBJECT_TYPE_COLLIDER_EVENT
	ld (iy-OBJECT_STRUCT_SIZE+OBJECT_STRUCT_STATE), COLLIDER_EVENT_TOO_FAR
	ld (iy-OBJECT_STRUCT_SIZE*2), OBJECT_TYPE_COLLIDER_EVENT
	ld (iy-OBJECT_STRUCT_SIZE*2+OBJECT_STRUCT_STATE), COLLIDER_EVENT_ENTER_BOOKSTORE
	ret


create_wall_colliders_street:
	SETMEGAROMPAGE_A000 OTHER_DATA_PAGE
	ld de,OBJECT_STRUCT_SIZE
create_wall_colliders_street_loop:
	ld (iy), OBJECT_TYPE_COLLIDER
	ld a,(hl)
	inc hl
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X), a
	ld a,(hl)
	inc hl
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y), a
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z), 0
	ld a,(hl)
	inc hl
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W), a
	ld a,(hl)
	inc hl
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H), a
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H), 80
	add iy,de
	djnz create_wall_colliders_street_loop
	ret


create_extra_wall_colliders_house_entrance:
	ld hl,n_collision_objects
	inc (hl)
	ld (iy),OBJECT_TYPE_COLLIDER_EVENT
	ld (iy+OBJECT_STRUCT_STATE), COLLIDER_EVENT_WRONG_WAY
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X), 48
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y), 110
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z), 0
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W), 32
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H), 2
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H), 80
	ret


create_wall_colliders_bookstore:
	; clock clerk area: 4 10 0
	ld hl,n_collision_objects
	inc (hl)
	ld (iy),OBJECT_TYPE_COLLIDER
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_X), 16
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Y), 80
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z), 0
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_W), 16
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_H), 80
	ld (iy+OBJECT_STRUCT_PIXEL_ISO_Z_H), 80
	ret
