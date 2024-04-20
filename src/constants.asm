;-----------------------------------------------
CHEATS_ON: equ 0
    

;-----------------------------------------------
; BIOS calls:
SYNCHR: equ #0008
RDSLT:  equ #000c
CHRGTR: equ #0010
WRSLT:  equ #0014
OUTDO:  equ #0018
CALSLT: equ #001c
DCOMPR: equ #0020
ENASLT: equ #0024
GETYPR: equ #0028
CALLF:  equ #0030
KEYINT: equ #0038
INITIO: equ #003b
INIFNK: equ #003e
DISSCR: equ #0041
ENASCR: equ #0044
WRTVDP: equ #0047
RDVRM:  equ #004a
WRTVRM: equ #004d
SETRD:  equ #0050
SETWRT: equ #0053
FILVRM: equ #0056
LDIRMV: equ #0059
LDIRVM: equ #005c
CHGMOD: equ #005f
CHGCLR: equ #0062
NMI:    equ #0066
CLRSPR: equ #0069
INITXT: equ #006c
INIT32: equ #006f
INIGRP: equ #0072
INIMLT: equ #0075
SETTXT: equ #0078
SETT32: equ #007b
SETGRP: equ #007e
SETMLT: equ #0081
CALPAT: equ #0084
CALATR: equ #0087
GSPSIZ: equ #008a
GRPPRT: equ #008d
GICINI: equ #0090
WRTPSG: equ #0093
RDPSG:  equ #0096
STRTMS: equ #0099
CHSNS:  equ #009c
CHGET:  equ #009f
CHPUT:  equ #00a2
LPTOUT: equ #00a5
LPTSTT: equ #00a8
CNVCHR: equ #00ab
PINLIN: equ #00ae
INLIN:  equ #00b1
QINLIN: equ #00b4
BREAKX: equ #00b7
ISCNTC: equ #00ba
CKCNTC: equ #00bd
BEEP:   equ #00c0
CLS:    equ #00c3
POSIT:  equ #00c6
FNKSB:  equ #00c9                
ERAFNK: equ #00cc
DSPFNK: equ #00cf
TOTEXT: equ #00d2
GTSTCK: equ #00d5
GTTRIG: equ #00d8
GTPAD:  equ #00db
GTPDL:  equ #00de
TAPION: equ #00e1
TAPIN:  equ #00e4
TAPIOF: equ #00e7
TAPOON: equ #00ea
TAPOUT: equ #00ed
TAPOOF: equ #00f0
STMOTR: equ #00f3
LFTQ:   equ #00f6
PUTQ:   equ #00f9
RIGHTC: equ #00fc
LEFTC:  equ #00ff
UPC:    equ #0102
TUPC:   equ #0105
DOWNC:  equ #0108
TDOWNC: equ #010b
SCALXY: equ #010e
MAPXY:  equ #0111
FETCHC: equ #0114
STOREC: equ #0117
SETATR: equ #011a
READC:  equ #011d
SETC:   equ #0120
NSETCX: equ #0123
GTASPC: equ #0126
PNTINI: equ #0129
SCANR:  equ #012c
SCANL:  equ #012f
CHGCAP: equ #0132
CHGSND: equ #0135
RSLREG: equ #0138
WSLREG: equ #013b
RDVDP:  equ #013e
SNSMAT: equ #0141
PHYDIO: equ #0144
FORMAT: equ #0147
ISFLIO: equ #014a
OUTDLP: equ #014d
GETVCP: equ #0150
GETVC2: equ #0153
KILBUF: equ #0156
CALBAS: equ #0159
SUBROM: equ #015c
EXTROM: equ #015f
CHKSLZ: equ #0162
CHKNEW: equ #0165
EOL:    equ #0168
BIGFIL: equ #016b
NSETRD: equ #016e
NSTWRT: equ #0171
NRDVRM: equ #0174
NWRVRM: equ #0177
RDRES:  equ #017a
WRRES:  equ #017d
CHGCPU: equ #0180
GETCPU: equ #0183
PCMPLY: equ #0186
PCMREC: equ #0189


;-----------------------------------------------
; System variables
VDP.DR:	equ #0006
VDP.DW:	equ #0007
VDP_REGISTER_0: equ #f3df
VDP_REGISTER_1: equ #f3e0
CLIKSW: equ #f3db       ; keyboard sound
FORCLR: equ #f3e9
BAKCLR: equ #f3ea
BDRCLR: equ #f3eb
SCNCNT: equ #f3f6
PUTPNT: equ #f3f8
GETPNT: equ #f3fa
MODE:   equ #fafc	
KEYS:   equ #fbe5    
KEYBUF: equ #fbf0
EXPTBL: equ #fcc1
TIMI:   equ #fd9f       ; timer interrupt hook
HKEY:   equ #fd9a       ; hkey interrupt hook


;-----------------------------------------------
; Assembler opcodes:	
JP_OPCODE: 			equ  #c3
RET_OPCODE:        	equ  #c9

;-----------------------------------------------
; VRAM map in Screen 1 (only 1 table of patterns, color table has 1 byte per each 8 patterns)
CHRTBL1:  equ     #0000   ; pattern table address
NAMTBL1:  equ     #1800   ; name table address 
CLRTBL1:  equ     #2000   ; color table address             
SPRTBL1:  equ     #0800   ; sprite pattern address  
SPRATR1:  equ     #1b00   ; sprite attribute address
; VRAM map in Screen 2 (3 tables of patterns, color table has 8 bytes per pattern)
CHRTBL2:  equ     #0000   ; pattern table address
NAMTBL2:  equ     #1800   ; name table address 
CLRTBL2:  equ     #2000   ; color table address             
SPRTBL2:  equ     #3800   ; sprite pattern address  
SPRATR2:  equ     #1b00   ; sprite attribute address

; VRAM map in Screen 4 (patterns like Screen 2, but sprites specify one color per line)
CHRTBL4:  equ     #0000   ; pattern table address
NAMTBL4:  equ     #1800   ; name table address 
CLRTBL4:  equ     #2000   ; color table address             
SPRTBL4:  equ     #3800   ; sprite pattern address  
SPRATR4:  equ     #1e00   ; sprite attribute address
SPRCLR4:  equ     #1c00   ; sprite attribute address

;-----------------------------------------------
; MSX1 colors:
COLOR_TRANSPARENT:	equ 0
COLOR_BLACK:		equ 1
COLOR_GREEN:		equ 2
COLOR_LIGHT_GREEN:	equ 3
COLOR_DARK_BLUE:	equ 4
COLOR_BLUE:			equ 5
COLOR_DARK_RED:		equ 6
COLOR_LIGHT_BLUE:	equ 7
COLOR_RED:			equ 8
COLOR_LIGHT_RED:	equ 9
COLOR_DARK_YELLOW:	equ 10
COLOR_YELLOW:		equ 11
COLOR_DARK_GREEN:	equ 12
COLOR_PURPLE:		equ 13
COLOR_GREY:			equ 14
COLOR_WHITE:		equ 15


;-----------------------------------------------
; A couple of useful macros for adding 16 and 8 bit numbers

; 5 bytes
; time 24 - 28 cycles
ADD_HL_A: MACRO 
    add a,l
    ld l,a
    jr nc, $+3
    inc h
    ENDM


ADD_DE_A: MACRO 
    add a,e
    ld e,a
    jr nc, $+3
    inc d
    ENDM    


; 4 bytes
; time 25 cycles
ADD_HL_A_VIA_BC: MACRO
    ld b,0
    ld c,a
    add hl,bc
    ENDM


; ------------------------------------------------
KEY_LEFT_BYTE:				equ 0
KEY_LEFT_BIT:				equ 4

KEY_RIGHT_BYTE:				equ 0
KEY_RIGHT_BIT:				equ 7

KEY_UP_BYTE:				equ 0
KEY_UP_BIT:					equ 5

KEY_DOWN_BYTE:				equ 0
KEY_DOWN_BIT:				equ 6

KEY_BUTTON1_BYTE:			equ 0
KEY_BUTTON1_BIT:			equ 0

KEY_BUTTON2_BYTE:			equ 1*2
KEY_BUTTON2_BIT:			equ 2    ; M
KEY_BUTTON2_BIT_ALTERNATIVE:equ 3    ; N (both N/M work!)
    
; KEY_PAUSE_BYTE:				equ 2*2
; KEY_PAUSE_BIT:				equ 5


; ------------------------------------------------
SCREEN_HEIGHT:              equ 19
MAX_ROOM_OBJECTS:           equ 26
MAX_ROOM_COLLISION_OBJECTS: equ 12
TEXT_BANK_SIZE:             equ 640

MAX_ROOM_DOORS:             equ 7

MAX_COORDINATE:             equ 10*16

OBJECT_DECOMPRESSION_BUFFER_SIZE:   equ 256*15
DOOR_DECOMPRESSION_BUFFER_SIZE:     equ 128*8

OCCLUSION_MASK_HEIGHT:      equ 36

INVULNERABILITY_TIME:       equ 24
INITIAL_HEALTH:             equ 3
MAX_HEALTH:                 equ 5
GUN_COOLDOWN:               equ 24

INVENTORY_ROW_SIZE:         equ 6
INVENTORY_ROWS:             equ 4
INVENTORY_SIZE:             equ INVENTORY_ROW_SIZE * INVENTORY_ROWS
INVENTORY_SLOT_WIDTH:       equ 8*2

MAX_HUD_MESSAGES:           equ 4

HUD_MESSAGE_QUEUE_SIZE:     equ 8

N_FAMILY_CUTSCENE_SPRITES:  equ 37
N_LUCY_CUTSCENE_SPRITES:    equ 35
MAX_OBJECT_SPRITES:         equ 2

; ------------------------------------------------
PLAYER_STATE_IDLE:          equ 0
PLAYER_STATE_WALKING:       equ 1
PLAYER_STATE_JUMPING:       equ 2
PLAYER_STATE_FALLING:       equ 3
PLAYER_STATE_DEAD:          equ 4

; ------------------------------------------------
DOOR_STRUCT_SIZE:           equ 5
DOOR_STRUCT_TYPE:           equ 0
DOOR_STRUCT_POSITION:       equ 1
DOOR_STRUCT_HEIGHT:         equ 2
DOOR_STRUCT_DESTINATION_ROOM:    equ 3
DOOR_STRUCT_DESTINATION_DOOR:    equ 4

; ------------------------------------------------
OBJECT_STRUCT_SIZE:             equ 20
OBJECT_STRUCT_TYPE:             equ 0
OBJECT_STRUCT_PIXEL_ISO_X:      equ 1
OBJECT_STRUCT_PIXEL_ISO_Y:      equ 2
OBJECT_STRUCT_PIXEL_ISO_Z:      equ 3
OBJECT_STRUCT_PIXEL_ISO_W:      equ 4
OBJECT_STRUCT_PIXEL_ISO_H:      equ 5
OBJECT_STRUCT_PIXEL_ISO_Z_H:    equ 6  ; how tall is the object (when character jumps on top)
OBJECT_STRUCT_SCREEN_TILE_X:    equ 7
OBJECT_STRUCT_SCREEN_TILE_Y:    equ 8
OBJECT_STRUCT_SCREEN_PIXEL_X:   equ 9
OBJECT_STRUCT_SCREEN_PIXEL_Y:   equ 10
OBJECT_STRUCT_SCREEN_TILE_W:    equ 11
OBJECT_STRUCT_SCREEN_TILE_H:    equ 12
OBJECT_STRUCT_TILE_X_OFFSET:    equ 13  ; offset to shift the top-left-corner to draw the object
OBJECT_STRUCT_TILE_Y_OFFSET:    equ 14  ; offset to shift the top-left-corner to draw the object
OBJECT_STRUCT_PTR:              equ 15  ; 2 bytes
OBJECT_STRUCT_FRAME:            equ 17
OBJECT_STRUCT_STATE:            equ 18
OBJECT_STRUCT_STATE_TIMER:      equ 19


OBJECT_TYPE_COLLIDER:           equ 1
OBJECT_TYPE_STOOL:              equ 2
OBJECT_TYPE_CHAIR_RIGHT:        equ 3
OBJECT_TYPE_CHAIR_LEFT:         equ 4
OBJECT_TYPE_TOMBSTONE:          equ 7
OBJECT_TYPE_YELLOW_KEY:         equ 14
OBJECT_TYPE_DOOR_LEFT_RED:      equ 15
OBJECT_TYPE_DOOR_RIGHT_YELLOW:  equ 16
; OBJECT_TYPE_GUN:                equ 17
OBJECT_TYPE_GUN_KEY:            equ 17
OBJECT_TYPE_CLOCK_RIGHT:        equ 18
OBJECT_TYPE_DOOR_RIGHT_WHITE:   equ 25
OBJECT_TYPE_CHEST:              equ 31
OBJECT_TYPE_PAINTING_RIGHT:     equ 32
OBJECT_TYPE_CRATE:              equ 38
OBJECT_TYPE_WINDOW_NE:          equ 40
OBJECT_TYPE_SINK:               equ 43
OBJECT_TYPE_LETTER3:            equ 44
OBJECT_TYPE_LAMP:               equ 45
OBJECT_TYPE_OIL:                equ 46
OBJECT_TYPE_PAINTING_SAFE_RIGHT:    equ 47
OBJECT_TYPE_SAFE_RIGHT:         equ 48
OBJECT_TYPE_TOILET:             equ 50
OBJECT_TYPE_CHEST2:             equ 51
OBJECT_TYPE_BATHTUB:            equ 52
OBJECT_TYPE_GRAMOPHONE:         equ 53
OBJECT_TYPE_VIOLIN:             equ 54
OBJECT_TYPE_HEART1:             equ 55
OBJECT_TYPE_HEART2:             equ 56
OBJECT_TYPE_BOOKSTACK:          equ 57
OBJECT_TYPE_BOOK:               equ 60
OBJECT_TYPE_TALL_STOOL:         equ 62
OBJECT_TYPE_CANDLE1:            equ 63
OBJECT_TYPE_CANDLE2:            equ 64
OBJECT_TYPE_CANDLE3:            equ 65
OBJECT_TYPE_DOOR_RITUAL:        equ 68
OBJECT_TYPE_SPIKES:             equ 72
OBJECT_TYPE_TORCH:              equ 74
OBJECT_TYPE_BONES1:             equ 75
OBJECT_TYPE_BONES2:             equ 76
OBJECT_TYPE_BONES3:             equ 77
OBJECT_TYPE_COFFIN1:            equ 78
OBJECT_TYPE_COFFIN2:            equ 79
OBJECT_TYPE_DOOR_LEFT_YELLOW:   equ 80
OBJECT_TYPE_CHEST_GUN:          equ 81
OBJECT_TYPE_BOOK_WESTENRA:      equ 82
OBJECT_TYPE_DOOR_VAMPIRE1:      equ 83
OBJECT_TYPE_DOOR_VAMPIRE2:      equ 84
OBJECT_TYPE_DOOR_VAMPIRE3:      equ 85
OBJECT_TYPE_ALTAR:              equ 87
OBJECT_TYPE_DOOR_RIGHT_GREEN:   equ 89
OBJECT_TYPE_GREEN_KEY:          equ 90
OBJECT_TYPE_FIREPLACE:          equ 93
OBJECT_TYPE_HEART3:             equ 97
OBJECT_TYPE_DIARY1:             equ 98
OBJECT_TYPE_DIARY2:             equ 99
OBJECT_TYPE_DIARY3:             equ 100
OBJECT_TYPE_LAB_NOTES:          equ 103
OBJECT_TYPE_HAMMER:             equ 104
OBJECT_TYPE_CRATE_GARLIC1:      equ 105
OBJECT_TYPE_CRATE_GARLIC2:      equ 106
OBJECT_TYPE_CRATE_GARLIC3:      equ 107
OBJECT_TYPE_CRATE_STAKE1:       equ 108
OBJECT_TYPE_CRATE_STAKE2:       equ 109
OBJECT_TYPE_CRATE_STAKE3:       equ 110
OBJECT_TYPE_DOOR_RIGHT_BLUE:    equ 111
OBJECT_TYPE_GARLIC1:            equ 112
OBJECT_TYPE_GARLIC2:            equ 113
OBJECT_TYPE_GARLIC3:            equ 114
OBJECT_TYPE_STAKE1:             equ 115
OBJECT_TYPE_STAKE2:             equ 116
OBJECT_TYPE_STAKE3:             equ 117
OBJECT_TYPE_BOOKSHELVES:        equ 119
OBJECT_TYPE_BOOKSTACK_HOME:     equ 121
OBJECT_TYPE_LUGGAGE:            equ 122
OBJECT_TYPE_NEWSPAPER:          equ 123
OBJECT_TYPE_UNIVERSITY_NOTES:   equ 124
OBJECT_TYPE_DOOR_RIGHT_NO_KEY:  equ 125
OBJECT_TYPE_DOOR_LEFT_NO_KEY:   equ 127
OBJECT_TYPE_COLLIDER_EVENT:     equ 128
OBJECT_TYPE_HORSECAR:           equ 135
OBJECT_TYPE_HORSE:              equ 136
OBJECT_TYPE_BEGGAR:             equ 137
OBJECT_TYPE_BEGGAR_BAG:         equ 138
OBJECT_TYPE_BEGGAR_DEAD:        equ 139
OBJECT_TYPE_STORE_BOOKSHELF:    equ 140
OBJECT_TYPE_STORE_STACK:        equ 141
OBJECT_TYPE_BOOKSTORE_CLERK:    equ 142
OBJECT_TYPE_STORE_BOOKSHELF_BOOK:    equ 143
OBJECT_TYPE_CHOFFEUR:           equ 144
OBJECT_TYPE_LUCY_TORN_NOTE:     equ 145
OBJECT_TYPE_SECRET_STAIRCASE:   equ 146
OBJECT_TYPE_VLAD_STATUE:        equ 150
OBJECT_TYPE_CHAIR_NE:           equ 157
OBJECT_TYPE_CHAIR_SW:           equ 158
OBJECT_TYPE_DOOR_VAMPIRE4:      equ 159
OBJECT_TYPE_COIN_PILE:          equ 160
OBJECT_TYPE_PUZZLE_BOX:         equ 162
OBJECT_TYPE_VLAD_DIARY:         equ 165
OBJECT_TYPE_VLAD_CLUE_BOOK:     equ 167
OBJECT_TYPE_MIRROR_NW:          equ 168
OBJECT_TYPE_MIRROR_NE:          equ 169
OBJECT_TYPE_MIRROR_CLUE:        equ 170
OBJECT_TYPE_CHEST_REVEAL:       equ 171
OBJECT_TYPE_CHEST_REVEAL2:      equ 172
OBJECT_TYPE_CHEST_CUTLERY:      equ 173
OBJECT_TYPE_DOOR_PRISON_ENTRANCE: equ 174
OBJECT_TYPE_DOOR_PRISON_FRANKY:   equ 175
OBJECT_TYPE_DOOR_PRISON_PASSAGE:  equ 176
OBJECT_TYPE_GRID2:              equ 178
OBJECT_TYPE_CAULDRON:           equ 180
OBJECT_TYPE_SWITCH:             equ 181
OBJECT_TYPE_CHEST_SHOVEL:       equ 182
OBJECT_TYPE_ARROW_SHOOTER_X:    equ 184
OBJECT_TYPE_ARROW_SHOOTER_Y:    equ 185
OBJECT_TYPE_SKELETON_BOSS:      equ 186
OBJECT_TYPE_SKELETON_KEY:       equ 187
OBJECT_TYPE_HEART4              equ 188
OBJECT_TYPE_OPEN_GRAVE:         equ 189
OBJECT_TYPE_CLAY:               equ 190
OBJECT_TYPE_LOG_BOOK:           equ 191
OBJECT_TYPE_FRANKY:             equ 192
OBJECT_TYPE_FRANKY_NOTE:        equ 193

OBJECT_TYPE_FIRST_ENEMY:        equ 244

OBJECT_TYPE_BULLET:             equ 245
OBJECT_TYPE_BAT:                equ 248
OBJECT_TYPE_SNAKE:              equ 249
OBJECT_TYPE_ARROW:              equ 251

COLLIDER_EVENT_WRONG_WAY:       equ 1
COLLIDER_EVENT_ENTER_HOME:      equ 2
COLLIDER_EVENT_TOO_FAR:         equ 3
COLLIDER_EVENT_SCREAM:          equ 4
COLLIDER_EVENT_ENTER_BOOKSTORE: equ 5
COLLIDER_EVENT_ENTER_SUBBASEMENT: equ 6

INVENTORY_STOOL:                equ 1
INVENTORY_YELLOW_KEY:           equ 2
INVENTORY_GUN:                  equ 3
INVENTORY_WHITE_KEY:            equ 4
INVENTORY_RED_KEY_H1:           equ 5
INVENTORY_RED_KEY_H2:           equ 6
INVENTORY_RED_KEY:              equ 7
INVENTORY_LETTER3:              equ 8
INVENTORY_LAMP:                 equ 9
INVENTORY_OIL:                  equ 10
INVENTORY_HEART:                equ 11
INVENTORY_BOOK:                 equ 12
INVENTORY_CANDLE:               equ 13
INVENTORY_GUN_KEY:              equ 14
INVENTORY_GREEN_KEY:            equ 15
INVENTORY_DIARY1:               equ 16

INVENTORY_DIARY2:               equ 17
INVENTORY_DIARY3:               equ 18
INVENTORY_BACKYARD_KEY:         equ 19
INVENTORY_LAB_NOTES:            equ 20
INVENTORY_HAMMER:               equ 21
INVENTORY_GARLIC:               equ 22
INVENTORY_STAKE:                equ 23
INVENTORY_RUBBED_STAKE:         equ 24
INVENTORY_VAMPIRE1_NOTE:        equ 25
INVENTORY_VAMPIRE2_NOTE:        equ 26
INVENTORY_LUGGAGE:              equ 27
INVENTORY_NEWSPAPER:            equ 28
INVENTORY_HISTORY_OF_ROMANIA:   equ 29
INVENTORY_LUCY_TORN_NOTE:       equ 30
INVENTORY_PUZZLE_BOX:           equ 31
INVENTORY_VLAD_NOTE:            equ 32

INVENTORY_VLAD_DIARY:           equ 33
INVENTORY_REVEAL_CLUE:          equ 34
INVENTORY_PRISON_KEY:           equ 35
INVENTORY_CUTLERY:              equ 36
INVENTORY_CAULDRON:             equ 37
INVENTORY_SHOVEL:               equ 38
INVENTORY_SKELETON_KEY:         equ 39
INVENTORY_CLAY:                 equ 40
INVENTORY_QUINCEY_KEY:          equ 41
INVENTORY_FRANKY_KEY:           equ 42
INVENTORY_QUINCEY_LETTER:       equ 43
INVENTORY_CAULDRON_CUTLERY:     equ 44
INVENTORY_WET_MOLD:             equ 45
INVENTORY_MOLD:                 equ 46
INVENTORY_SILVER_BULLETS:       equ 47
INVENTORY_FRANKY_NOTE:          equ 48

; old values:             0: d1 am, 1: d1, pm, 2: d2 am, etc.
; new values:  0: d1 pm,  1: d2 am, 2: d2, pm, 3: d3 am, etc.
TIME_START:                     equ 0  ; day 1 pm <- Nov 26th
TIME_REACH_WESTEN_HOUSE:        equ 1  ; day 2 am <- Nov 27th
TIME_CODE_SEEN:                 equ 2  ; day 2 pm
TIME_REACH_WEST_WING:           equ 3  ; day 3 am <- Nov 28th
TIME_PENTAGRAM_CLUE_SEEN:       equ 4  ; day 3 pm 
TIME_REACH_BASEMENT:            equ 5  ; day 4 am <- Nov 29th
TIME_REACH_FEEDING_ROOM:        equ 6  ; day 4 pm
TIME_REACH_SECOND_FLOOR:        equ 7  ; day 5 am <- Nov 30th
TIME_REACH_LAB:                 equ 8  ; day 5 pm 
TIME_VAMPIRES_ARRIVE:           equ 9  ; day 6 am <- Dec 1st
TIME_LUCY_ENTERS_SUBBASEMENT:   equ 10 ; day 6 pm
TIME_SUBBASEMENT_OPEN:          equ 11 ; day 7 am <- Dec 2nd


OBJECTS_PAGE1: equ 4
OBJECTS_PAGE2: equ 5
OBJECTS_PAGE3: equ 6
FONT_PAGE: equ 6
SPRITES_PAGE: equ 7
OTHER_DATA_PAGE: equ 8
MAPS_PAGE: equ 8
MUSIC_PAGE1: equ 9
SFX_PAGE: equ 10
TEXT_PAGE_EN: equ 13
GRAPHIC_DATA_PAGE: equ 14
TEXT_PAGE_ES: equ 15
TEXT_MULTILINGUAL_TABLE_PAGE: equ 6
