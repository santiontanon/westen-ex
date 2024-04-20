;-----------------------------------------------
; Loads the interrupt hook for playing music:
setup_custom_interrupt:
    ld  a,JP_OPCODE    ;NEW HOOK SET
    di
        ld  (TIMI),a
        ld  hl,interrupt_callback
        ld  (TIMI+1),hl
    ei
    ret


; ------------------------------------------------
; My interrupt handler:
interrupt_callback:
    push af
    push bc
    push hl
        ld hl,interrupt_cycle
        inc (hl)
        ; ld hl,interrupt_tempo_state
        inc hl
        ld a,(hl)
        inc hl
        add a,(hl)
        dec hl
        ld (hl),a
        cp 128
        jr c,interrupt_callback_skip
        and #7f
        ld (hl),a
        push de
            ; play SFX:
            ld a,(SFX_player_active)
            or a
            call nz,play_ayfx        
            ; set music megarom pages:
            ld a,(current_music_page)
            ld (#a000),a
            call wyz_interrupt_handler        
            ; restore the previous megarom page:
            ld a,(current_megarom_page_in_a000)
            ld (#a000),a
        pop de
interrupt_callback_skip:
    pop hl
    pop bc
    pop af
    ei
    ret
