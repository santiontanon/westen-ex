; MSX PSG proPLAYER V 0.47c - WYZ 19.03.2016
; (WYZTracker 2.0 o superior)
; 
; Original code can be found here: https://github.com/AugustoRuiz/WYZTracker
; Edited by santiago ontañón (Feb 14th, 2021)
; - Adapted the 47c adaptation to the 47d version
; Edited by santiago ontañón (nov 26th, 2021)
; - This version is 500 - 3000 t-states faster per cycle than the original, but 1000 bytes larger.
; - wyzplayer47c-small.asm is about 500 - 1000 t-states faster per cycle than the original, and only a few bytes larger.


ADJUST_PSG_VOLUMES: equ 0  ; Set to 0 for not adjusting the PSG volumes.

IF ADJUST_PSG_VOLUMES = 1
wyz_volume_correction_table:
  db   0, 2, 4, 6, 7, 8, 9, 10, 11, 12, 13, 13, 14, 14, 15, 15
ENDIF

;-----------------------------------------------
; Code to initialize the player, and load songs.
;-----------------------------------------------

;-----------------------------------------------
wyz_player_init:
  ld hl,wyz_buffer_canal_a  ; Reservar memoria para buffer de sonido.
  ld bc,16
  ld (wyz_canal_a),hl  ; Recomendable 16 o mas bytes por canal.
;   ld hl,wyz_buffer_canal_b
  add hl,bc
  ld (wyz_canal_b),hl
;   ld hl,wyz_buffer_canal_c
  add hl,bc
  ld (wyz_canal_c),hl
;   ld hl,wyz_buffer_canal_p
  add hl,bc
  ld (wyz_canal_p),hl
  call wyz_player_off
;   ; setup the interrupt handler:
;   di
;     ld hl,wyz_interrupt_handler
;     ld (HKEY + 1),hl
;     ld a,JP_OPCODE
;     ld (HKEY),a
;   ei
;   ret


;-----------------------------------------------
wyz_player_off:
  xor a
  ld (wyz_interr),a
wyz_clear_psg_buffer:
  ld hl,wyz_psg_reg
  ld de,wyz_psg_reg+1
  ld bc,14
  ld (hl),a
  ldir
  ld a,10111000b  ; Por si acaso
  ld (wyz_psg_reg+7),a
  ld hl,wyz_psg_reg
  ld de,wyz_psg_reg_sec
  ld c,14
  ldir
  jp wyz_rout


;-----------------------------------------------
; Loads a song.
; - de: ptr to the song
wyz_carga_cancion:
  di
    ld hl,wyz_interr ; carga cancion
    set 1,(hl)  ; reproduce cancion
    call wyz_decode_song
  ei
  ret


;-----------------------------------------------
; decodificar:
; - de: ptr to the song
; - wyz_interr 0 on song: carga cancion si/no
wyz_decode_song:
  ex de,hl  ; the original player receives the pointer in hl, so, we use "ex" to reuse the code below
  ld a,(hl)
  and 01111111b
  ld (wyz_tempo),a
  dec a
  ld (wyz_ttempo),a
  ld a,(hl)
  and 10000000b
  ld (wyz_hybrid),a

  ; header byte 1
  ; (-|-|-|-|  3-1 | 0  )
  ; (-|-|-|-|fx chn|loop)
  inc hl  ; loop 1=on/0=off?
  ld a,(hl)
  bit 0,a
  jr z,wyz_nptjp0
  push hl
    ld hl,wyz_interr
    set 4,(hl)
  pop hl

  ; seleccion del canal de efectos de ritmo
wyz_nptjp0:  
  and 00000110b
  rra
  push hl
    ld hl,wyz_tabla_datos_canal_sfx
    wyz_ext_word_macro
    ex de,hl
    ld de,wyz_sfx_l
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
  pop hl
  inc hl  ; 2 bytes reservados
  inc hl
  inc hl

  ; busca y guarda inicio de los canales en el modulo mus
  ; añade offset del loop
  push hl  ; ix inicio offsets loop por canal
  pop ix

  ld de,#0008  ; Hasta inicio del canal a
  add hl,de

  ld (wyz_puntero_p_deca),hl  ; guarda puntero inicio canal
  ld e,(ix + 0)
  ld d,(ix + 1)
  add hl,de
  ld (wyz_puntero_l_deca),hl  ; guarda puntero inicio loop

  call wyz_bgicmodbc1
  ld (wyz_puntero_p_decb),hl
  ld e,(ix + 2)
  ld d,(ix + 3)
  add hl,de
  ld (wyz_puntero_l_decb),hl

  call wyz_bgicmodbc1
  ld (wyz_puntero_p_decc),hl
  ld e,(ix + 4)
  ld d,(ix + 5)
  add hl,de
  ld (wyz_puntero_l_decc),hl

  call wyz_bgicmodbc1
  ld (wyz_puntero_p_decp),hl
  ld e,(ix + 6)
  ld d,(ix + 7)
  add hl,de
  ld (wyz_puntero_l_decp),hl

  ; Lee datos de las notas
  ; (|)(|||||) longitud\nota
wyz_init_decoder:
  ld de,(wyz_canal_a)
  ld (wyz_puntero_a),de
  ld hl,(wyz_puntero_p_deca)
  call wyz_decode_canal  ; canal a
  ld (wyz_puntero_deca),hl

  ld de,(wyz_canal_b)
  ld (wyz_puntero_b),de
  ld hl,(wyz_puntero_p_decb)
  call wyz_decode_canal  ; canal b
  ld (wyz_puntero_decb),hl

  ld de,(wyz_canal_c)
  ld (wyz_puntero_c),de
  ld hl,(wyz_puntero_p_decc)
  call wyz_decode_canal  ; canal c
  ld (wyz_puntero_decc),hl

  ld de,(wyz_canal_p)
  ld (wyz_puntero_p),de
  ld hl,(wyz_puntero_p_decp)
  call wyz_decode_canal  ; canal p
  ld (wyz_puntero_decp),hl
  ret

; Busca inicio del canal
wyz_bgicmodbc1:
  ld e,#3f  ; Codigo instrumento 0
wyz_bgicmodbc2:
  xor a  ; Busca el byte 0
  ld b,#ff  ; El modulo debe tener una longitud menor de #ff00 ... o_o!
  cpir

  dec hl
  dec hl
  ld a,e  ; Es el instrumento 0??
  cp (hl)
  inc hl
  inc hl
  jr z,wyz_bgicmodbc2

  dec hl
  dec hl
  dec hl
  ld a,e  ; Es volumen 0??
  cp (hl)
  inc hl
  inc hl
  inc hl
  jr z,wyz_bgicmodbc2
  ret


;-----------------------------------------------
; Code to actually play music via the interrupt handler.
;-----------------------------------------------

;-----------------------------------------------
wyz_interrupt_handler:  
;   out (#2c),a
  call wyz_rout
  ld hl,wyz_psg_reg
  ld de,wyz_psg_reg_sec
rept 14
  ldi
endr
  ld hl,wyz_interr
  bit 2,(hl)  ; esta activado el efecto?
  call nz,wyz_reproduce_sonido
IF ADJUST_PSG_VOLUMES = 1
  call wyz_play

  ; Adjust PSG volumes:
  ld d, 0
  ld a, (wyz_psg_reg + 8)
  ld e, a
  ld hl,wyz_volume_correction_table
  push hl
    add hl, de
    ld a, (hl)
    ld (wyz_psg_reg + 8), a
  pop hl
  ld a, (wyz_psg_reg + 9)
  ld e, a
  ld hl,wyz_volume_correction_table
  push hl
    add hl, de
    ld a, (hl)
    ld (wyz_psg_reg + 9), a
  pop hl
  ld a, (wyz_psg_reg + 10)
  ld e, a
  ld hl,wyz_volume_correction_table
  add hl, de
  ld a, (hl)
  ld (wyz_psg_reg + 10),a
  ret
ELSE
  jp wyz_play
ENDIF
;   out (#2d),a    
;   ret


;-----------------------------------------------
; Reproduce efectos de sonido
wyz_reproduce_sonido:
  ld hl,(wyz_puntero_sonido)
  ld a,(hl)
  cp #ff
  jr z,wyz_fin_sonido
  ld de,(wyz_sfx_l)
  ld (de),a
  inc hl
  ld a,(hl)
  rrca
  rrca
  rrca
  rrca
  and 00001111b
  ld de,(wyz_sfx_h)
  ld (de),a
  ld a,(hl)
  and 00001111b
  ld de,(wyz_sfx_v)
  ld (de),a
  inc hl
  ld a,(hl)
  ld b,a
;   bit 7,a  ; 09.08.13 bit mas siginificativo activa envolventes
;   jr z,wyz_no_envolventes_sonido
  rla
  jr nc,wyz_no_envolventes_sonido
  ld a,#12
  ld (de),a
  inc hl
  ld a,(hl)
  ld (wyz_psg_reg_sec+11),a
  inc hl
  ld a,(hl)
  ld (wyz_psg_reg_sec+12),a
  inc hl
  ld a,(hl)
  cp 1
  jr z,wyz_no_envolventes_sonido  ; No escribe la envolvente si su valor es 1
  ld (wyz_psg_reg_sec+13),a

wyz_no_envolventes_sonido:
  ld a,b
  and #7f
  jr z,wyz_no_ruido
  ld (wyz_psg_reg_sec+6),a
  ld a,(wyz_sfx_mix)
  jp wyz_si_ruido
wyz_no_ruido:
  xor a
  ld (wyz_psg_reg_sec+6),a
  ld a,10111000b
wyz_si_ruido:
  ld (wyz_psg_reg_sec+7),a
  inc hl
  ld (wyz_puntero_sonido),hl
  ret
wyz_fin_sonido: 
  ld hl,wyz_interr
  res 2,(hl)
  ld a,(wyz_envolvente_back)  ; no restaura la envolvente si es 0
  and a
  jr z,wyz_fin_noplayer
  ld (wyz_psg_reg_sec+13),a  ; 08.13 restaura la envolvente tras el sfx
wyz_fin_noplayer: 
  ld a,10111000b
  ld (wyz_psg_reg_sec+7),a
  ret


;-----------------------------------------------
; Vuelca buffer de sonido al psg
wyz_rout:
  ld a,(wyz_psg_reg+13)
  and a   ; es cero?
  jr z,wyz_no_backup_envolvente
  ld (wyz_envolvente_back),a  ; 08.13 / guarda la envolvente en el backup

wyz_no_backup_envolvente:
  ld bc,#00a0
  ld hl,wyz_psg_reg_sec
rept 13
  out (c),b
  ld a,(hl)
  out (#a1),a
  inc hl
  inc b
endr
  out (c),b
  ld a,(hl)
  and a
  ret z
  inc c
  out (c),a
  xor a
  ld (wyz_psg_reg_sec+13),a
  ld (wyz_psg_reg+13),a
  ret
  

;-----------------------------------------------
; Decodifica notas de un canal
; - de: direccion destino
; nota=0 fin canal
; nota=1 silencio
; nota=2 puntillo
; nota=3 comando i
; Note: the entry point is below to save a "jr"
wyz_no_puntillo:
  cp 00111111b  ; Es comando?
  jr nz,wyz_no_modifica
  bit 0,b  ; comado=instrumento?
  jr z,wyz_no_instrumento
  ld a,11000001b  ; Codigo de instrumento
  ld (de),a
  inc hl
  inc de
  ldi  ; numero de instrumento
  ldi  ; volumen relativo del instrumento
;  jp wyz_decode_canal

wyz_decode_canal:
  ld a,(hl)
  and a  ; Fin del canal?
  jr z,wyz_fin_dec_canal
  call wyz_getlen

  cp 00000001b ; Es silencio?
  jr nz,wyz_no_silencio
  or #40  ; set 6,a
  jp wyz_no_modifica

wyz_no_silencio:
  cp 00111110b  ; Es puntillo?
  jr nz,wyz_no_puntillo
  rrc b
  xor a
  jp wyz_no_modifica

wyz_no_instrumento:
  bit 2,b
  jr z,wyz_no_envolvente
  ld a,11000100b  ; Codigo envolvente
  ld (de),a
  inc de
  inc hl
  ldi
  jp wyz_decode_canal

wyz_no_envolvente:
  bit 1,b
  jr z,wyz_no_modifica
  ld a,11000010b  ; Codigo efecto
  ld (de),a
  inc hl
  inc de
  ld a,(hl)
  call wyz_getlen

wyz_no_modifica:
  ld (de),a
  inc de
  xor a
  djnz wyz_no_modifica
  or #81
  ld (de),a
  inc de
  inc hl
  ret

wyz_fin_dec_canal:
  or #80  ; set 7,a
  ld (de),a
  inc de
  ret


;-----------------------------------------------
wyz_getlen:
  push af
    and 11000000b
    rlca
    rlca
    inc a
    ld b,a
    ld a,10000000b
wyz_dcbc0:
    rlca
    djnz wyz_dcbc0
    ld b,a
  pop af
  and 00111111b
  ret


;-----------------------------------------------
wyz_play:  
  ld hl,wyz_interr  ; play bit 1 on?
  bit 1,(hl)
  ret z

  ld hl,wyz_hybrid
  bit 7,(hl)
  jr z,wyz_tempo_entero
  bit 6,(hl)
  jr z,wyz_tempo_entero

wyz_tempo_semi: 
  ld hl,wyz_ttempo  ; Contador tempo
  inc (hl)
  ld a,(wyz_tempo)
  dec a
  cp (hl)
  jr nz,wyz_pautas
  ld (hl),0
  ld hl,wyz_hybrid
  res 6,(hl)
  jr wyz_interpreta
    
wyz_tempo_entero:
  ld hl,wyz_ttempo  ; Contador tempo
  inc (hl)
  ld a,(wyz_tempo)
  cp (hl)
  jr nz,wyz_pautas
  ld (hl),0
  ld hl,wyz_hybrid
  set 6,(hl)

wyz_interpreta:
  ld bc,wyz_psg_reg+8
  call wyz_localiza_nota_a
  ld bc,wyz_psg_reg+9
  call wyz_localiza_nota_b
  ld bc,wyz_psg_reg+10
  call wyz_localiza_nota_c
  call wyz_localiza_efecto

  ; pautas
wyz_pautas: 
  ld hl,wyz_psg_reg+8
  bit 4,(hl)  ; Si la envolvente esta activada no actua pauta
  call z,wyz_pauta_a
  ld hl,wyz_psg_reg+9
  bit 4,(hl)  ; Si la envolvente esta activada no actua pauta
  call z,wyz_pauta_b
  ld hl,wyz_psg_reg+10
  bit 4,(hl)  ; Si la envolvente esta activada no actua pauta
  ret nz
  jp wyz_pauta_c


;-----------------------------------------------
wyz_localiza_nota_a:
  WYZ_LOCALIZA_NOTA_MACRO wyz_psg_reg, wyz_puntero_a
wyz_localiza_nota_b:
  WYZ_LOCALIZA_NOTA_MACRO wyz_psg_reg+2, wyz_puntero_b
wyz_localiza_nota_c:
  WYZ_LOCALIZA_NOTA_MACRO wyz_psg_reg+4, wyz_puntero_c


;-----------------------------------------------
; wyz_localiza_nota: localiza nota canal a/b/c
WYZ_LOCALIZA_NOTA_MACRO: macro iy_value, ix_value
wyz_localiza_nota:
  ld hl,(ix_value)
  ld a,(hl)
  or #3f  ; Comando?
  inc a
  jr nz,wyz_lnjp0

wyz_comandos:
  ld a,(hl)
  ; bit(0): instrumento
  rra
  jr nc,wyz_com_efecto

  inc hl
  ld a,(hl)  ; numero de pauta
  inc hl
  ld e,(hl)

  push hl  ; tempo
    ld hl,wyz_tempo
    bit 5,e
    jr z,wyz_no_dec_tempo
    dec (hl)
wyz_no_dec_tempo:
    bit 6,e
    jr z,wyz_no_inc_tempo
    inc (hl)
wyz_no_inc_tempo:
    res 5,e  ; Siempre resetea los bits de tempo
    res 6,e

    ld hl,ix_value + wyz_vol_inst_a - wyz_puntero_a
    ld (hl),e  ; Registro del volumen relativo
  pop hl
  inc hl
  ld (ix_value),hl
  ld hl,TABLA_PAUTAS
  wyz_ext_word_macro
  ld (ix_value + wyz_puntero_p_a0 - wyz_puntero_a),de
  ld (ix_value + wyz_puntero_p_a - wyz_puntero_a),de
  ld l,c
  ld h,b
  res 4,(hl)  ; Apaga efecto envolvente
  xor a
  ld (wyz_psg_reg_sec+13),a
  ld (wyz_psg_reg+13),a
  jp wyz_localiza_nota

wyz_com_efecto:
  bit 1,a  ; Efecto de sonido
  jr z,wyz_com_envolvente

  inc hl
  ld a,(hl)
  inc hl
  ld (ix_value),hl
  jp wyz_inicia_sonido

wyz_com_envolvente:
  bit 2,a
  ret z  ; Ignora - error

  inc hl
  ld a,(hl)  ; Carga codigo de envolvente
  ld (wyz_envolvente),a
  inc hl
  ld (ix_value),hl
  ld l,c
  ld h,b
  ld (hl),00010000b  ; Enciende efecto envolvente
  jp wyz_localiza_nota

wyz_lnjp0:
  ld a,(hl)
  inc hl
  bit 7,a
  jr z,wyz_no_fin_canal_a
  rra
  jr nc,wyz_fin_canal_a

wyz_fin_nota_a:
  ld de,(ix_value + wyz_canal_a - wyz_puntero_a)  ; Puntero buffer al inicio
  ld (ix_value),de
  ld hl,(ix_value + wyz_puntero_deca - wyz_puntero_a)  ; Carga puntero decoder
  push bc
    call wyz_decode_canal
  pop bc
  ld (ix_value + wyz_puntero_deca - wyz_puntero_a),hl  ; Guarda puntero decoder
  jp wyz_localiza_nota

wyz_fin_canal_a: 
  ld a,(wyz_interr)  ;loop?
  bit 4,a
  jr nz,wyz_fca_cont
  pop af  ; Removes the return address from the stack
  jp wyz_player_off

wyz_fca_cont:
  ld hl,(ix_value + wyz_puntero_l_deca - wyz_puntero_a)  ; Carga puntero inicial decoder
  ld (ix_value + wyz_puntero_deca - wyz_puntero_a),hl
  jp wyz_fin_nota_a

wyz_no_fin_canal_a:
  ld (ix_value),hl  ; (puntero_a/b/c) = hl. Guarda puntero
  and a  ; No reproduce nota si nota = 0
  ret z
  bit 6,a  ; Silencio?
  jr z,wyz_no_silencio_a
  ld a,(bc)
  and 00010000b
  jr nz,wyz_silencio_envolvente

  xor a
  ld (bc),a  ; Reset volumen del correspodiente chip
  ld (iy_value + 0),a
  ld (iy_value + 1),a
  ret

wyz_silencio_envolvente:
  ld a,#ff
  ld (wyz_psg_reg+11),a
  ld (wyz_psg_reg+12),a
  xor a
  ld (wyz_psg_reg+13),a
  ld (iy_value + 0),a
  ld (iy_value + 1),a
  ret

wyz_no_silencio_a:
  ld (ix_value + wyz_reg_nota_a - wyz_puntero_a),a  ; Registro de la nota del canal

  ; Reproduce una nota
  ; - a: codigo de la nota
  ; - iy: registros de frecuencia
  ld l,c
  ld h,b
  bit 4,(hl)
  ld b,a
  jr nz,wyz_evolventes
  ld a,b
  ld hl,DATOS_NOTAS  ; Busca frecuencia
  wyz_ext_word_macro
  ld (iy_value + 0),de

  ld hl,(ix_value + wyz_puntero_p_a0 - wyz_puntero_a)  ; hl=(puntero_p_a0) resetea pauta
  ld (ix_value + wyz_puntero_p_a - wyz_puntero_a),hl  ; (puntero_p_a)=hl
  ret


;-----------------------------------------------
; - a: codigo de la envolvente
; - iy: registro de frecuencia
wyz_evolventes:
  ld hl,DATOS_NOTAS
  rlca
  ld d,0
  ld e,a
  add hl,de
  ld e,(hl)
  inc hl
  ld d,(hl)
  push de
  ld a,(wyz_envolvente)  ; Frecuencia del canal on/off
  rra
  jr nc,wyz_frecuencia_off
  ld (iy_value),de
  jp wyz_cont_env

wyz_frecuencia_off: 
  ld d,0 
  ld (iy_value),de
  ; Calculo del ratio (octava arriba)
wyz_cont_env:
  pop de
  push af
  push bc
  and 00000011b
  ld b,a

  rr d
  rr e
wyz_crtbc0:  ; 1/4 - 1/8 - 1/16
  rr d
  rr e
  djnz wyz_crtbc0
  ld a,e
  ld (wyz_psg_reg+11),a
  ld a,d
  and 00000011b
  ld (wyz_psg_reg+12),a
  pop bc
  pop af  ; Seleccion forma de envolvente

  rra
  and 00000110b  ; #08,#0a,#0c,#0e
  add 8
  ld (wyz_psg_reg+13),a
  ld (wyz_envolvente_back),a
  
  ld hl,(ix_value + wyz_puntero_p_a0 - wyz_puntero_a)  ; hl=(puntero_p_a0) resetea pauta
  ld (ix_value + wyz_puntero_p_a - wyz_puntero_a),hl  ; (puntero_p_a)=hl
  ret
endm


;-----------------------------------------------
; wyz_localiza_efecto: (entry point is in the middle of the function, to save a jp)
wyz_lejp0:
  inc hl
  bit 7,a
  jr z,wyz_no_fin_canal_p
  rra
  jr nc,wyz_fin_canal_p
wyz_fin_nota_p:
  ld de,(wyz_canal_p)
  ld (wyz_puntero_p),de
  ld hl,(wyz_puntero_decp)  ; Carga puntero decoder
  push bc
    call wyz_decode_canal  ; Decodifica canal
  pop bc
  ld (wyz_puntero_decp),hl  ; Guarda puntero decoder
  ; jp wyz_localiza_efecto

wyz_localiza_efecto:
  ld hl,(wyz_puntero_p)
  ld a,(hl)
  cp 11000010b
  jr nz,wyz_lejp0
  inc hl
  ld a,(hl)
  inc hl
  ld (wyz_puntero_p),hl

; - a: numero de sonido a iniciar
wyz_inicia_sonido: 
  ld hl,TABLA_SONIDOS
  wyz_ext_word_macro
  ld (wyz_puntero_sonido),de
  ld hl,wyz_interr
  set 2,(hl)
  ret

wyz_fin_canal_p:
  ld hl,(wyz_puntero_l_decp)  ; Carga puntero inicial decoder
  ld (wyz_puntero_decp),hl
  jp wyz_fin_nota_p

wyz_no_fin_canal_p:
  ld (wyz_puntero_p),hl
  ret


;-----------------------------------------------
wyz_pauta_a:
  WYZ_PAUTA_MACRO wyz_psg_reg+0,wyz_puntero_p_a
wyz_pauta_b:
  WYZ_PAUTA_MACRO wyz_psg_reg+2,wyz_puntero_p_b
wyz_pauta_c:
  WYZ_PAUTA_MACRO wyz_psg_reg+4,wyz_puntero_p_c


;-----------------------------------------------
; Pauta de los 3 canales
; - hl: registro de volumen
; - ix_value: puntero de la pauta
; - iy_value: registros de frecuencia
; formato pauta
;     7  6     5     4  3-0       3-0
; byte 1 (loop|oct-1|oct+1|ornmt|vol) - byte 2 ( | | | |pitch/nota)
WYZ_PAUTA_MACRO: macro iy_value, ix_value
wyz_pauta:
  ld a,(iy_value + 1)
  ld b,a
  ld a,(iy_value)
  or b
  ret z

  push hl
wyz_pcajp4:
  ld hl,(ix_value)
  ld a,(hl)

  bit 7,a  ; Loop / el resto de bits no afectan
  jr z,wyz_pcajp0
  and 00011111b  ; Máximo loop pauta (0,32)x2!!!-> para ornamentos
  rlca  ; x2
  ld d,0
  ld e,a
  sbc hl,de
  ld a,(hl)

wyz_pcajp0:
  bit 6,a  ; Octava -1
  jr z,wyz_pcajp1
  ld de,(iy_value)
  rrc d
  rr e
  ld (iy_value),de
  jp wyz_pcajp2

wyz_pcajp1:
  bit 5,a  ; Octava +1
  jr z,wyz_pcajp2
  ld de,(iy_value)
  rlc e
  rl d
  ld (iy_value),de

wyz_pcajp2:
  ld a,(hl)
  bit 4,a
  jr nz,wyz_pcajp6  ; Ornamentos seleccionados

  inc hl  ; Funcion pitch de frecuencia
  push hl
  ld e,a
  ld a,(hl)  ; Pitch de frecuencia
  ld l,a
  and a
  ld a,e
  jr z,wyz_ornmjp1

  ld a,(iy_value + 0)  ; Si la frecuencia es 0 no hay pitch
  ld h,a
  ld a,(iy_value + 1)
  add a,h
  and a
  ld a,e
  jr z,wyz_ornmjp1

  bit 7,l
  jr z,wyz_ornneg
  ld h,#ff
  jp wyz_pcajp3
wyz_ornneg:
  ld h,0

wyz_pcajp3:
  ld de,(iy_value)
  adc hl,de
  ld (iy_value),hl
  jp wyz_ornmjp1

wyz_pcajp6:
  inc hl  ; Funcion ornamentos
  push hl
    push af
      ld a,(ix_value + wyz_reg_nota_a - wyz_puntero_p_a)  ; Recupera registro de nota en el canal
      ld e,(hl)
      adc e  ; +- nota
      ld hl,DATOS_NOTAS  ; Busca frecuencia
      wyz_ext_word_macro
      ld (iy_value),de
    pop af

wyz_ornmjp1:
  pop hl
  inc hl
  ld (ix_value),hl
wyz_pcajp5:
  pop hl
  and 15
  ld c,a
  ld a,(ix_value + wyz_vol_inst_a - wyz_puntero_p_a)  ; Volumen relativo
  bit 4,a
  jr z, wyz_pcajp9
  or #f0
wyz_pcajp9:
  add a,c
  jp p,wyz_pcajp7
  ld a,1
wyz_pcajp7:
  cp 15
  jp m,wyz_pcajp8
  ld a,15
wyz_pcajp8:
  ld (hl),a
  ret
endm


;-----------------------------------------------
; Extrae un "dw" de una tabla
; - hl: direccion tabla
; - a: posicion
wyz_ext_word_macro: macro
  ld d,0
  rlca
  ld e,a
  add hl,de
  ld e,(hl)
  inc hl
  ld d,(hl)
endm


;-----------------------------------------------
; Tabla de datos del selector del canal de efectos de ritmo
wyz_tabla_datos_canal_sfx:
  dw wyz_select_canal_a, wyz_select_canal_b, wyz_select_canal_c


;-----------------------------------------------
; byte 0-1: sfx_l
; byte 2-3: sfx_h
; byte 4-5: sfx_v
; byte 6: sfx_mix
wyz_select_canal_a:
  dw wyz_psg_reg_sec+0, wyz_psg_reg_sec+1, wyz_psg_reg_sec+8
  db 10110001b

wyz_select_canal_b:
  dw wyz_psg_reg_sec+2, wyz_psg_reg_sec+3, wyz_psg_reg_sec+9
  db 10101010b

wyz_select_canal_c:
  dw wyz_psg_reg_sec+4, wyz_psg_reg_sec+5, wyz_psg_reg_sec+10
  db 10011100b
