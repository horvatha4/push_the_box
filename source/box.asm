;******************************
;************* BOX ************
;******************************

; Passiv object. A Crane take into the Hall. Infuenced by the gravity. Can fallen.
; It will destroyed if fallen from 2 or more unit box.
; The Worker can push left or right.

; Status enums
BOX_STATUS_STAND				.equ 0
BOX_STATUS_ON_CRANE				.equ 1
BOX_STATUS_WORKER_PUSH			.equ 2
BOX_STATUS_FALL					.equ 3
BOX_STATUS_CRASH				.equ 4
BOX_STATUS_CRASHED				.equ 5

; Relativ address enums
BOX_RA_X						.equ 0; box_logical_or_visual_coord_xy:
BOX_RA_Y						.equ 1
BOX_RA_STATUS					.equ 2; byte - witch animation play now
BOX_RA_ANIM_LEFT				.equ 3; byte - how mutch left
BOX_RA_FALLCOUNT				.equ 4; fall counter
BOX_RA_TEXTURE					.equ 5
BOX_RA_SERIAL					.equ 6

; Constants
BOX_CRASH_ANIM_LENGTH			.equ 5
BOX_FALL_ANIM_LENGTH			.equ 8

BoxCaseVecTbl:
.dw		L_BOXU_CASE_STAND
.dw		L_BOXU_CASE_ON_CRANE
.dw		L_BOXU_CASE_WORKER_PUSH
.dw		L_BOXU_CASE_FALL
.dw		L_BOXU_CASE_CRASH
;.dw		L_BOXU_CASE_CRASHED

; ix = base address
; b = newtexture
; c = box serial number
v_BoxInit_bcix_0:;TESZT:OK
		ld		(ix+BOX_RA_STATUS), BOX_STATUS_STAND; b_box_status = box_stand
		ld		(ix+BOX_RA_TEXTURE),		b	; b_box_texture = newtexture
		ld		(ix+BOX_RA_ANIM_LEFT),		0	; b_box_current_anim_left = 0
		ld		(ix+BOX_RA_FALLCOUNT),		0	; b_box_fallcount = 0
		ld		(ix+BOX_RA_X),				0	; b2_box_coord_xy.x
		ld		(ix+BOX_RA_Y),				0	; b2_box_coord_xy.y
		ld		(ix+BOX_RA_SERIAL),			c	; serial number
	ret

; status ret in a
a_BoxUpdate_ix_abcdehl:;TESZT:OK
		ld		a, (ix+BOX_RA_STATUS)
		ld		h, 0
		ld		l, a
		add		hl, hl
		ld		de, BoxCaseVecTbl
		add		hl, de
		
		ld		a, (hl)
		inc		hl
		ld		h, (hl)
		ld		l, a
		
		jp		(hl)
		
L_BOXU_CASE_STAND:
		ld		b, (ix+BOX_RA_X)
		ld		c, (ix+BOX_RA_Y)
		push	bc
		call	a_MapMgrGetUnder_bc_abcdhl
		pop		bc
		cp		0
		jp		z, a_BoxStartFalling_ix_abcdhl
		jp		a_BoxGetStatus_ix_a
		
L_BOXU_CASE_ON_CRANE:
		jp		a_BoxGetStatus_ix_a
		
L_BOXU_CASE_WORKER_PUSH:
		jp		a_BoxGetStatus_ix_a
		
L_BOXU_CASE_FALL:
		ld		a, (ix+BOX_RA_ANIM_LEFT)
		cp		0
		jp		z, l_boxu_fall_check
		dec		(ix+BOX_RA_ANIM_LEFT)
		dec		(ix+BOX_RA_ANIM_LEFT)
		inc		(ix+BOX_RA_Y)
		inc		(ix+BOX_RA_Y)
		jp		a_BoxGetStatus_ix_a
l_boxu_fall_check:
		ld		b, (ix+BOX_RA_X)
		ld		c, (ix+BOX_RA_Y)
		call	bc_MapMgrVisualToLogic_bc_bc
		push	bc
		call	a_MapMgrGetUnder_bc_abcdhl
		pop		bc
		cp		0
		jp		nz, l_boxu_fall_end
		ld		(ix+BOX_RA_ANIM_LEFT), 8
		inc		(ix+BOX_RA_FALLCOUNT); b_box_fallcount++		
		jp		a_BoxGetStatus_ix_a
l_boxu_fall_end:
		jp		a_BoxStand_ix_abcdhl
		
L_BOXU_CASE_CRASH:
		inc		(ix+BOX_RA_ANIM_LEFT)
		ld		a, (ix+BOX_RA_ANIM_LEFT)
		cp		BOX_CRASH_ANIM_LENGTH
		jp		c, l_boxu_keep_crash
		ld		(ix+BOX_RA_STATUS), BOX_STATUS_CRASHED
l_boxu_keep_crash:
		jp		a_BoxGetStatus_ix_a
	
; L_BOXU_CASE_CRASHED:
		; jp		a_BoxGetStatus_ix_a

; *****************************************
; ************ BOX RENDER *****************
; *****************************************
; if stand or crashing draw as tile, otherwise sprite
v_BoxRender_ix_z:;TESZT:OK
		ld		a, (ix+BOX_RA_STATUS)
		cp		BOX_STATUS_CRASH
		jp		nz, l_box_r_nocrash

		ld		c, (ix+BOX_RA_ANIM_LEFT)
		sla		c
		sla		c
		sla		c; *8
		ld		b, 0
		ld		d, (ix+BOX_RA_X)
		ld		e, (ix+BOX_RA_Y)
		ld		ix, box_crash_frames
		add		ix, bc
		jp		v_TileCopy8x8_deix_abdehlix

l_box_r_nocrash:
		cp		BOX_STATUS_STAND
		jp		nz, l_box_r_nostand
		
		ld		c, (ix+BOX_RA_TEXTURE)
		sla		c
		sla		c
		sla		c; *8
		ld		b, 0
		ld		d, (ix+BOX_RA_X)
		ld		e, (ix+BOX_RA_Y)
		ld		ix, box_textures
		add		ix, bc
		jp		v_TileCopy8x8_deix_abdehlix

; all other case: BOX_STATUS_FALL, BOX_STATUS_ON_CRANE
; BOX_STATUS_WORKER_PUSH
l_box_r_nostand:
		ld		c, (ix+BOX_RA_TEXTURE)
		sla		c
		sla		c
		sla		c; *8
		ld		b, 0

		ld		d, (ix+BOX_RA_X)
		ld		e, (ix+BOX_RA_Y)
		ld		ix, box_textures
		add		ix, bc
		ld		c, 8
		jp		v_SpriteDrawOR8xC_cdeix_z

;Commond end in Update
a_BoxGetStatus_ix_a:;TESZT:OK
		ld		a, (ix+BOX_RA_STATUS)
	ret

;Set Coords for Render
v_BoxSetCoords_deix_0:;TESZT:OK
		ld		(ix+BOX_RA_X),	d
		ld		(ix+BOX_RA_Y),	e
	ret

;Mark that box is on Crane
v_BoxOnCrane_ix_0:;TESZT:OK
		ld		(ix+BOX_RA_STATUS), BOX_STATUS_ON_CRANE
		; crane make update visual coords at every update
	ret
	
a_BoxStand_ix_abcdhl:;TESZT:OK
		ld		b, (ix+BOX_RA_X)
		ld		c, (ix+BOX_RA_Y)
		call	bc_MapMgrVisualToLogic_bc_bc
		ld		(ix+BOX_RA_X),	b	
		ld		(ix+BOX_RA_Y),	c
		
		ld		a, (ix+BOX_RA_FALLCOUNT)
		cp		2; box max fall unit
		jp		c, l_boxst_fall_ok
		;start crash
		ld		(ix+BOX_RA_STATUS), BOX_STATUS_CRASH
		ld		(ix+BOX_RA_ANIM_LEFT), 0
		jp		a_BoxGetStatus_ix_a
		
l_boxst_fall_ok:
		ld		(ix+BOX_RA_STATUS), BOX_STATUS_STAND
		jp		a_BoxGetStatus_ix_a
		
v_BoxStartPushed_ix_abcdhl:;TESZT:OK
		ld		(ix+BOX_RA_STATUS), BOX_STATUS_WORKER_PUSH
		ld		b, (ix+BOX_RA_X)
		ld		c, (ix+BOX_RA_Y)
		call	bc_MapMgrLogicToVisual_bc_bc
		ld		(ix+BOX_RA_X), b
		ld		(ix+BOX_RA_Y), c
	ret

; fall one unit 
a_BoxStartFalling_ix_abcdhl:;TESZT:OK
		; BoxStatusChanged(box_fall)
		ld		(ix+BOX_RA_STATUS), BOX_STATUS_FALL
		ld		(ix+BOX_RA_FALLCOUNT), 0		
		; prepare fall anim, logic coords to visual
		call	bc_MapMgrLogicToVisual_bc_bc
		ld		(ix+BOX_RA_X), b
		ld		(ix+BOX_RA_Y), c
		ld		(ix+BOX_RA_ANIM_LEFT), BOX_FALL_ANIM_LENGTH	
		jp		a_BoxGetStatus_ix_a

v_BoxUpdateMap_ix_abcdhl:;TESZT:OK
		ld		b, (ix+BOX_RA_X)
		ld		c, (ix+BOX_RA_Y)
		ld		a, (ix+BOX_RA_STATUS)
		cp		BOX_STATUS_STAND
		jp		nz, l_box_um_boxnostand
		
		ld		a, (ix+BOX_RA_SERIAL)
		add		a, MAPM_TOKEN_BOX_STANDING_BASE
		jp		v_MapMgrSetAndCheckAt_abc_abcdhl
		
l_box_um_boxnostand:
		ld		a, (ix+BOX_RA_SERIAL)
		add		a, MAPM_TOKEN_BOX_MOVING_BASE
		call	bc_MapMgrVisualToLogic_bc_bc
		call	v_MapMgrSetAndCheckAt_abc_abcdhl
		
		ld		a, 7
		add		a, (ix+BOX_RA_X)
		ld		b, a
		ld		a, 7
		add		a, (ix+BOX_RA_Y)
		ld		c, a
		ld		a, (ix+BOX_RA_SERIAL)
		add		a, MAPM_TOKEN_BOX_MOVING_BASE
		call	bc_MapMgrVisualToLogic_bc_bc
		jp		v_MapMgrSetAndCheckAt_abc_abcdhl


;***************************************************
;**************** BoxManager ***********************
;***************************************************
; Handle all boxes dynamically.
; Use a "Box allocation table", what just mark the valid boxes
; and a heap for the box datas

BOXM_MAX_BOXES		.equ 64; byte - max capacity
BOXM_MAX_TEXTURE	.equ 8; num of textures
BOXM_BOXHEAP_BASE	.equ $F000;$F000-F200, 512 = 64x8 byte, egy box 7 byte
BOXM_BAT			.equ $EF00; BOX ALLOCATION TABLE address

v_BoxMgrInit_0_abde:;TESZT:OK 16.01.2022
		ld		b, BOXM_MAX_BOXES; clear BAT
		xor		a
		ld		de, BOXM_BAT
l_boxm_init_loop:
		ld		(de), a
		inc		de
		djnz	l_boxm_init_loop
	ret

; ret in A the first free slot nummer in BAT, $ff if not found
; alloc the slot too.
a_BoxMgrGetFreeSetBAT_0_abhl:;TESZT:OK 14.01.2022
		ld		b, 0
		ld		hl, BOXM_BAT
l_boxm_gfs_loop:
		xor		a
		cp		(hl)
		jp		z, l_boxm_gfs_found
		inc		hl
		inc		b
		ld		a, b
		cp		BOXM_MAX_BOXES
		jp		nz, l_boxm_gfs_loop
		ld		a, $ff; not found
		ret
l_boxm_gfs_found:
		ld		(hl), $ff; alloc in BAT
		ld		a, b
	ret

; Make a new box at the first free place
; ret serialnum_of_box in A or $ff on fail
aix_BoxMgrNewBox_0z:;TESZT:OK
		call	a_BoxMgrGetFreeSetBAT_0_abhl
		cp		$ff
		ret		z;, l_boxm_newb_fail
		ld		c, a; reserve boxnum
		ld		e, a; calc block address
		ld		d, 0
		sla		e; 1 block = 8 byte, so e *= 8; + box_heap_base
		sla		e
		sla		e
		rl		d
		ld		ix, BOXM_BOXHEAP_BASE
		add		ix, de
		
		; ld		a, BOXM_MAX_TEXTURE; choose a texture
		; call	hl_RandomGetANummer_a_abdehl
		call	a_RandomGetText_0_adehl
		ld		b, a
		
		call	v_BoxInit_bcix_0
		ld		a, c; reload boxnum
;l_boxm_newb_fail:
	ret
	
; Delete a BOX in BAT, A = boxnum
; write $00 in BAT
v_BoxMgrDeleteBox_a_dehl:;TESZT:OK
		ld		h, 0
		ld		l, a; reserve boxnum
		ld		de, BOXM_BAT
		add		hl, de
		ld		(hl), 0
	ret

; return in IX the box´s address
ix_BoxMgrGetBox_a_bcix:;TESZT:OK
		ld		c, a
		ld		b, 0
		sla		c
		sla		c
		sla		c
		rl		b
		ld		ix, BOXM_BOXHEAP_BASE
		add		ix, bc
	ret
	
; call all valid box's BoxUpdate
; FE = foreach
v_BoxMgrFEUpdate_0z:;TESZT:OK
		ld		c, 0
		ld		hl, BOXM_BAT
l_boxm_fe_u_loop:;loop all
		xor		a
		cp		(hl)
		jp		z, l_boxm_fe_u_empty
		push	bc; save c
		ld		b, 0
		sla		c
		sla		c
		sla		c
		rl		b
		ld		ix, BOXM_BOXHEAP_BASE
		add		ix, bc
		push	hl; save BAT pointer
		call	a_BoxUpdate_ix_abcdehl
		cp		BOX_STATUS_CRASHED; crashed
		jp		nz, l_boxm_fe_u_notcrashed
		
		ld		a, (ix+BOX_RA_SERIAL)
		call	v_BoxMgrDeleteBox_a_dehl;
		call	v_GameDecreaseScore_0z;minus point
l_boxm_fe_u_notcrashed:
		pop		hl; reload BAT pointer
		pop		bc; reload c
l_boxm_fe_u_empty:
		inc		hl
		inc		c
		ld		a, c
		cp		BOXM_MAX_BOXES
		jp		nz, l_boxm_fe_u_loop
	ret
	
; call all valid box's BoxRender
v_BoxMgrFERender_0z:;TESZT:OK
		ld		c, 0
		ld		hl, BOXM_BAT
l_boxm_fe_r_loop:;loop all
		xor		a
		cp		(hl)
		jp		z, l_boxm_fe_r_empty
		push	bc; save c
		ld		b, 0
		sla		c
		sla		c
		sla		c
		rl		b
		ld		ix, BOXM_BOXHEAP_BASE
		add		ix, bc
		push	hl; save pointer
		call	v_BoxRender_ix_z
		pop		hl; reload pointer
		pop		bc; reload c
l_boxm_fe_r_empty:
		inc		hl
		inc		c
		ld		a, c
		cp		BOXM_MAX_BOXES
		jp		nz, l_boxm_fe_r_loop
	ret

; call all valid box's BoxUpdateMap
v_BoxMgrFEUpdateMap_0z:;TESZT:OK
		ld		c, 0
		ld		hl, BOXM_BAT
l_boxm_fe_um_loop:;loop all
		xor		a
		cp		(hl)
		jp		z, l_boxm_fe_um_empty
		push	bc; save c
		ld		b, 0
		sla		c
		sla		c
		sla		c
		rl		b
		ld		ix, BOXM_BOXHEAP_BASE
		add		ix, bc
		push	hl; save pointer
		call	v_BoxUpdateMap_ix_abcdhl
		pop		hl; reload pointer
		pop		bc; reload c
l_boxm_fe_um_empty:
		inc		hl
		inc		c
		ld		a, c
		cp		BOXM_MAX_BOXES
		jp		nz, l_boxm_fe_um_loop
	ret
