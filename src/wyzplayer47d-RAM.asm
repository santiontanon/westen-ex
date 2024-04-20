; MSX PSG proPLAYER V 0.47c - WYZ 19.03.2016
; (WYZTracker 2.0 o superior)
; 
; Original code can be found here: https://github.com/AugustoRuiz/WYZTracker
; Edited by santiago ontañón (Feb 14th, 2022) to adapt to the 0.47d version
; Edited by santiago ontañón (Nov 26th, 2021)

;-----------------------------------------------
; RAM
;-----------------------------------------------

wyz_hybrid: ds virtual 1
    ; Tempo hibrido
    ; bit 7 = hybrid on/off
    ; bit 6 = alternador

wyz_interr: ds virtual 1        
    ; interruptores 1=on 0=off
    ; bit 0: carga cancion on/off
    ; bit 1: player on/off
    ; bit 2: efectos on/off
    ; bit 3: sfx on/off
    ; bit 4: loop

; Musica: el orden de las variables es fijo
wyz_tempo: ds virtual 1              ; db tempo
wyz_ttempo: ds virtual 1             ; db contador tempo

wyz_puntero_a: ds virtual 2          ; dw puntero del canal a
wyz_puntero_b: ds virtual 2          ; dw puntero del canal b
wyz_puntero_c: ds virtual 2          ; dw puntero del canal c

wyz_canal_a: ds virtual 2            ; dw direcion de inicio de la musica a
wyz_canal_b: ds virtual 2            ; dw direcion de inicio de la musica b
wyz_canal_c: ds virtual 2            ; dw direcion de inicio de la musica c

wyz_puntero_p_a: ds virtual 2        ; dw puntero pauta canal a
wyz_puntero_p_b: ds virtual 2        ; dw puntero pauta canal b
wyz_puntero_p_c: ds virtual 2        ; dw puntero pauta canal c

wyz_puntero_p_a0: ds virtual 2       ; dw ini puntero pauta canal a
wyz_puntero_p_b0: ds virtual 2       ; dw ini puntero pauta canal b
wyz_puntero_p_c0: ds virtual 2       ; dw ini puntero pauta canal c

wyz_puntero_p_deca: ds virtual 2     ; dw puntero de inicio del decoder canal a
wyz_puntero_p_decb: ds virtual 2     ; dw puntero de inicio del decoder canal b
wyz_puntero_p_decc: ds virtual 2     ; dw puntero de inicio del decoder canal c

wyz_puntero_deca: ds virtual 2       ; dw puntero decoder canal a
wyz_puntero_decb: ds virtual 2       ; dw puntero decoder canal b
wyz_puntero_decc: ds virtual 2       ; dw puntero decoder canal c

wyz_reg_nota_a:    ds virtual 1      ; db registro de la nota en el canal a
wyz_vol_inst_a:    ds virtual 1      ; db volumen relativo del instrumento del canal a
wyz_reg_nota_b:    ds virtual 1      ; db registro de la nota en el canal b
wyz_vol_inst_b:    ds virtual 1      ; db volumen relativo del instrumento del canal b
wyz_reg_nota_c:    ds virtual 1      ; db registro de la nota en el canal c
wyz_vol_inst_c:    ds virtual 1      ; db volumen relativo del instrumento del canal c

wyz_puntero_l_deca: ds virtual 2     ; dw puntero de inicio del loop del decoder canal a
wyz_puntero_l_decb: ds virtual 2     ; dw puntero de inicio del loop del decoder canal b
wyz_puntero_l_decc: ds virtual 2     ; dw puntero de inicio del loop del decoder canal c

; Canal de efectos de ritmo - enmascara otro canal
wyz_puntero_p:      ds virtual 2     ; dw puntero del canal efectos
wyz_canal_p:        ds virtual 2     ; dw direcion de inicio de los efectos
wyz_puntero_p_decp: ds virtual 2     ; dw puntero de inicio del decoder canal p
wyz_puntero_decp:   ds virtual 2     ; dw puntero decoder canal p
wyz_puntero_l_decp: ds virtual 2     ; dw puntero de inicio del loop del decoder canal p

wyz_sfx_l:   ds virtual 2            ; dw direccion buffer efectos de ritmo registro bajo
wyz_sfx_h:   ds virtual 2            ; dw direccion buffer efectos de ritmo registro alto
wyz_sfx_v:   ds virtual 2            ; dw direccion buffer efectos de ritmo registro volumen
wyz_sfx_mix: ds virtual 2            ; dw direccion buffer efectos de ritmo registro mixer

; Efectos de sonido
wyz_n_sonido:       ds virtual 1     ; db numero de sonido
wyz_puntero_sonido: ds virtual 2     ; dw puntero del sonido que se reproduce

; db buffers de registros del psg
wyz_psg_reg:     ds virtual 16
wyz_psg_reg_sec: ds virtual 16
wyz_envolvente:  ds virtual 1        
	; db forma de la envolvente
    ; bit 0:   frecuencia canal on/off
    ; bit 1-2: ratio
    ; bit 3-3: forma
wyz_envolvente_back: ds virtual 1    ; db backup de la forma de la envolente

; Memoria para buffer de sonido
; Recomendable 16 o mas bytes por canal.
wyz_buffer_canal_a:    ds virtual 16
wyz_buffer_canal_b:    ds virtual 16
wyz_buffer_canal_c:    ds virtual 16
wyz_buffer_canal_p:    ds virtual 16
