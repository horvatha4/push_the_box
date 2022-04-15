;****************************************
;************* TILE *********************
;****************************************
; What is a Tile?
; The Tile is a 8 x 8 pixel graphics object.
; Can appear only at every 8th horizonal and vertical display´s position.
; So in Ti83p there is a 12x8 unit graphics area. These are the LOGICAL COORDINATES

; Common routin to calc tile upper left corner's address from LOGIC koords
; DE = x,y; 0 <= x < 12; 0 <= y < 8; upper left corner
; return the address in HL
hl_TileCalcAdr_de_adehl:;TESZT:OK
		ld		hl, plotSScreen
		ld		a, e; reserve e
		ld		e, d; for add hl, de
		ld		d, 0 ; de = x_base_address
		add		hl, de 
		ld		e, a ; reload e;cmax=7; e x 12x8 = cx96 = %0110.0000
		sla		e ; 2
		sla		e ; 4
		sla		e ; 8
		sla		e ; 16
		sla		e ; 32
		add		hl, de
		sla		e ; 64
		rl		d  ; de = y_base_address
		add		hl, de; hl now = full_base_address = plotSScreen + x_base_address + y_base_address
	ret

; Copy a 8x8 tile
; ix = tile start address
; de = x,y; 0 <= x < 12; 0 <= y < 8; upper left corner
v_TileCopy8x8_deix_abdehlix:;TESZT:OK
		call	hl_TileCalcAdr_de_adehl
		ld		b, 8; 8 pixel high
		ld		d, 0
		ld		e, 12
l_tile_copy_loop:
		ld		a, (ix)
		ld		(hl), a
		add		hl, de
		inc		ix
		djnz	l_tile_copy_loop
	ret

; ****************** UNUSED ROUTINES ***********************
; fill with $FF a 8x8 tile
; de = x,y; 0 <= x < 12; 0 <= y < 8; upper left corner
; v_TileBlack8x8_de_abdehl:;TESZT:OK
		; call	hl_TileCalcAdr_de_adehl
		; ld		b, 8; 8 pixel high
		; ld		d, 0
		; ld		e, 12
		; ld		a,$ff
; l_tile_black_loop:
		; ld		(hl), a
		; add		hl, de
		; djnz	l_tile_black_loop
	; ret

; fill with $00 a 8x8 tile
; de = x,y; 0 <= x < 12; 0 <= y < 8; upper left corner
; v_TileErase8x8_de_abdehl:;TESZT:OK
		; call	hl_TileCalcAdr_de_adehl
		; ld		b, 8; 8 pixel high
		; ld		d, 0
		; ld		e, 12
		; xor		a
; l_tile_erase_loop:
		; ld		(hl), a
		; add		hl, de
		; djnz	l_tile_erase_loop
	; ret

; draw a gate $55 in a 8x8 tile
; de = x,y; 0 <= x < 12; 0 <= y < 8; upper left corner
; c = gate's high
; v_TileGate8x8_cde_abdehl:;TESZT:OK
		; call	hl_TileCalcAdr_de_adehl
		; ld		b, 8; 8 pixel high
		; ld		d, 0
		; ld		e, 12
; l_tile_gate_loop:
		; ld		a, b
		; cp		c
		; jp		z, l_tile_gate_gate
		; jp		c, l_tile_gate_gate
		; ld		(hl), $00
		; add		hl, de
		; djnz	l_tile_gate_loop
	; ret
; l_tile_gate_gate:
		; ld		(hl), $55
		; add		hl, de
		; djnz	l_tile_gate_loop
	; ret
