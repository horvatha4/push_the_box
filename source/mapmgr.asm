;**************************************
;************** MAPMANAGER ************
;**************************************

; Its handle a logical map for the game logic
; logic to visual coords and back helper library too
; Store/handle the object´s/actor´s serial nummer + the base nummer(MAPM_TOKEN_...BASE)

MAPM_ACTUALMAP	.equ $F300

a_mapm_ytblhelper:; helper table for multiply 12
.db 00, 12, 24, 36, 48, 60, 72, 84

; copied to MAPM_ACTUALMAP($F300) before every map update
a_mapmanager_back_map:;	12x8 byte					y
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 0
.db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 1
.db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF; 2
.db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF; 3
.db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF; 4
.db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF; 5
.db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF; 6
.db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF; 7
						   ;box,worker
; x 000,001,002,003,004,005,006,007,008,009,010,011
;8
;2426
;16318421
;+-------moving boxes , 255 -> wall
;128->
; +------standing boxes
; 64->
;  +-----cranes
;  32->
;   +----unused
;   16, 17, 18
;    +---unused
;    8->15
;     +--unused
;     4,5,6,7
;      +-worker
;      3

; 255 -> outside from map or wall
; 
MAPM_TOKEN_WORKER				.equ 3
;MAPM_TOKEN_HYDROBASE			.equ 4
;MAPM_TOKEN_WINDOWBASE			.equ 8
;MAPM_TOKEN_DECOBASE				.equ 16
MAPM_TOKEN_CRANEBASE			.equ 32
MAPM_TOKEN_BOX_STANDING_BASE	.equ 64; 2nd box with serial nummer #1 = 65, if standing
MAPM_TOKEN_BOX_MOVING_BASE		.equ 128; 129 if moving

v_MapMgrInit_0_bcdehl:;TESZT:OK
v_MapMgrReset_0z:
		ld		bc, 12*8
		ld		hl, a_mapmanager_back_map
		ld		de, MAPM_ACTUALMAP
		ldir
	ret
	
; ret in A what is it on a specific position
; $ff on wall or outside of map
; b = x logical coord
; c = y logical coord
a_MapMgrGetAndCheckAt_bc_abcdhl:;TESZT:OK
		ld		a, b
		cp		12
		jp		c, l_mapm_gch_x_ok
		ld		a, 255
	ret
l_mapm_gch_x_ok:		
		ld		a, c
		cp		8
		jp		c, l_mapm_gch_y_ok
		ld		a, 255
	ret
l_mapm_gch_y_ok:
		jp		a_MapMgrGetAt_bc_abcdhl

; set the value in A on a specific position
; or do nothing if outside of map
; b = x logical coord
; c = y logical coord
; a = the value
v_MapMgrSetAndCheckAt_abc_abcdhl:;TESZT:OK
		ld		d, a; reserve a
		ld		a, b
		cp		12
		jp		c, l_mapm_sch_x_ok
	ret
l_mapm_sch_x_ok:		
		ld		a, c
		cp		8
		jp		c, l_mapm_sch_y_ok
	ret
l_mapm_sch_y_ok:
		ld		a, d; reload a
		jp		v_MapMgrSetAt_abc_bcdhl

; Calculate Token address in ACTUAL MAP!
hl_MapMgrCalcTokenAdr_bc_bcdhl:;TESZT:OK
		ld		d, b; reserve x
		ld		b, 0
		ld		hl, a_mapm_ytblhelper
		add		hl, bc
		ld		c, (hl)
		ld		hl, MAPM_ACTUALMAP
		add		hl, bc
		ld		c, d; reload x
		add		hl, bc; hl = delta address
	ret

; BC = x,y, A = what is there
a_MapMgrGetAt_bc_abcdhl:;TESZT:OK
		call	hl_MapMgrCalcTokenAdr_bc_bcdhl
		ld		a, (hl)
	ret

; BC = x,y, A = for what
v_MapMgrSetAt_abc_bcdhl:;TESZT:OK
		call	hl_MapMgrCalcTokenAdr_bc_bcdhl
		ld		(hl), a
	ret

; BC = x,y, A = what is left, right, over, under 
a_MapMgrGetOver_bc_abcdhl:;TESZT:OK
		dec 	c
		jp		a_MapMgrGetAndCheckAt_bc_abcdhl

a_MapMgrGetUnder_bc_abcdhl:;TESZT:OK
		inc 	c
		jp		a_MapMgrGetAndCheckAt_bc_abcdhl

a_MapMgrGetLeft_bc_abcdhl:;TESZT:OK
		dec		b
		jp		a_MapMgrGetAndCheckAt_bc_abcdhl

a_MapMgrGetRight_bc_abcdhl:;TESZT:OK
		inc		b
		jp		a_MapMgrGetAndCheckAt_bc_abcdhl

bc_MapMgrLogicToVisual_bc_bc:;TESZT:OK
		sla		b; *8
		sla		b
		sla		b
		sla		c; *8
		sla		c 
		sla		c
	ret
bc_MapMgrVisualToLogic_bc_bc:;TESZT:OK
		srl		b; /8
		srl		b
		srl		b
		srl		c; /8
		srl		c
		srl		c
	ret

; helper for testing the last line, eg. it is full or not
v_MapMgrCopyLastLine_de_bcdehl:;TESZT:OK
		ld		b, 1
		ld		c, 7
		push	de
		call	hl_MapMgrCalcTokenAdr_bc_bcdhl
		pop		de
		ld		bc, 10
		ldir
	ret
	
; last line is full, delete it
v_MapMgrDelLastLine_de_abcdhl:;TESZT:OK
		ld		b, 1
		ld		c, 7
		call	hl_MapMgrCalcTokenAdr_bc_bcdhl
		xor		a
		ld		b, 10
l_mapm_del_loop:
		ld		(hl), a
		inc		hl
		djnz	l_mapm_del_loop
	ret
