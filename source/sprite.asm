;****************************************
;***************** SPRITE ***************
;****************************************
; What is a Sprite?
; The Sprite is a 8 x any pixel graphics object.
; Can appear at any display´s position. Clipped Horizontaly.
; In Ti83p there is a 96x64 pixel graphics area. These are the VISUAL COORDINATES

v_SpriteDrawOR8xC_cdeix_z:;TESZT:OK
; Check and call the right sprite function. Only call this from extern!
; The Sprite datas OR-ed into the plotSScreen
; NORM: de = x,y; 0 <= x <= 88; 0 <= y <= 56; upper left corner
; LH: de = x,y; 88 < x < 95; 0 <= y <= 56; upper left corner
; RH: de = x,y; -8 < x < 0; 0 <= y <= 56; upper left corner
; C = sprite high
		ld		a, e; y
		cp		57
		jp		nc, l_sprite_drawor_end
		ld		a, d; x
		cp		0
		jp		m, l_sprite_drawor_minus
		cp		89
		jp		c, v_SpriteOR8xC_cdeix_z
		cp		96
		jp		c, v_SpriteOR8xC_LH_cdeix_z
	ret
l_sprite_drawor_minus:
		cp		-7
		jp		p, v_SpriteOR8xC_RH_cdeix_z
l_sprite_drawor_end:		
	ret

; Calculate Sprite address from VISUAL coords
; de = x,y; 0 <= x <= 88; 0 <= y <= 56; upper left corner
hl_SpriteCalcAdr_de_bcdehl:;TESZT:OK
		ld		hl, plotSScreen
		ld		c, d
		sra		c
		sra		c
		sra		c
		ld		b, 0
		add		hl, bc; .. = x_base_address
		ld		d, 0
		sla		e ; 2
		sla		e ; 4
		add		hl, de; add 4xe
		sla		e ; 8xe
		rl		d ; de = y_base_address
		add		hl, de; hl now = full_base_address = plotSScreen + x_base_address + y_base_address
	ret

; draw a 8xC sprite
; ix = sprite start address
; de = x,y; 0 <= x <= 88; 0 <= y <= 56; upper left corner
; c = pixel high
v_SpriteOR8xC_cdeix_z:;TESZT:OK
		ld		a, d; ide is kell ez a sor, mert ha d > volt mint 88 akkor a-ban marad a nagyobb d
		and		7; a = shift right (and make carry reset)
		push	bc
		call	hl_SpriteCalcAdr_de_bcdehl
		pop		bc
		ld		b, a; copy a
l_sprite_or_ing_loop:	
		ld		d, (ix)
		ld		e, 0
		ld		a, b; reserve shift right
		cp		0
		jp		z, l_sprite_noshift		
l_sprite_shift_loop:
		rr		d
		rr		e
		djnz	l_sprite_shift_loop
l_sprite_noshift:
		ld		b, a; reload shift right
		ld		a, d
		or		(hl)
		ld		(hl), a
		ld		a, e
		inc		hl
		or		(hl)
		ld		(hl), a
		;dec hl
		ld		d, 0
		ld		e, 11; 12
		add		hl, de; Carry reset here
		inc		ix
		dec		c
		jp		nz, l_sprite_or_ing_loop
	ret

; draw a 8xC sprite, Left Half
; ix = sprite start address
; de = x,y; 88 < x < 95; 0 <= y <= 56; upper left corner
; c = pixel high
v_SpriteOR8xC_LH_cdeix_z:;TESZT:OK
		ld		a, d; ide is kell ez a sor, mert ha d > volt mint 88 akkor a-ban marad a nagyobb d
		and		7; a = shift right (and make carry reset)
		push	bc
		call	hl_SpriteCalcAdr_de_bcdehl
		pop		bc
		ld		b, a; copy a
l_sprite_or_inglh_loop:	
		ld		d, (ix)
		ld		e, 0
		ld		a, b; reserve shift right
		cp		0
		jp		z, l_spritelh_noshift
l_sprite_shiftlh_loop:
		rr		d
		rr		e
		djnz	l_sprite_shiftlh_loop
l_spritelh_noshift:
		ld		b, a; reload shift right
		ld		a, d
		or		(hl)
		ld		(hl), a
		inc		hl
		; ld		a, e
		; or		(hl)
		; ld		(hl), a
		;dec hl
		ld		d, 0
		ld		e, 11; 12
		add		hl, de; Carry reset here
		inc		ix
		dec		c
		jp		nz, l_sprite_or_inglh_loop
	ret
	
; draw a 8x8 sprite, Right Half
; ix = sprite start address
; de = x,y; -8 < x < 0; 0 <= y <= 56; upper left corner
; c = sprite high
v_SpriteOR8xC_RH_cdeix_z:;TESZT:OK
		ld		a, 8
		add		a, d		
		and		7; a = shift right (and make carry reset)
		ld		d, 0
		push	bc
		call	hl_SpriteCalcAdr_de_bcdehl
		pop		bc
		dec		hl
		ld		b, a; copy a
l_sprite_or_ingrh_loop:	
		ld		d, (ix)
		ld		e, 0
		ld		a, b; reserve shift right
		cp		0
		jp		z, l_spriterh_noshift
l_sprite_shiftrh_loop:
		rr		d
		rr		e
		djnz	l_sprite_shiftrh_loop
l_spriterh_noshift:
		ld		b, a; reload shift right
		; ld		a, d
		; or		(hl)
		; ld		(hl), a
		inc		hl
		ld		a, e
		or		(hl)
		ld		(hl), a
		;dec hl
		ld		d, 0
		ld		e, 11; 12
		add		hl, de; Carry reset here
		inc		ix
		dec		c
		jp		nz, l_sprite_or_ingrh_loop
	ret
