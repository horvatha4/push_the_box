;*********************************
;************* CRANE *************
;*********************************

; The "Big Evil´s hand"
; Its like an automat, make a workflow over and over again.
; Take a box, bring its position, carry down,
; pull up the rope and drive left out from the hall.
; crane y = 0 allways
; Start at the upper right corner

; Status enums
CRANE_ST_STAND			.equ 0
CRANE_ST_ENTER			.equ 1
CRANE_ST_LEFT_CARRY		.equ 2 
CRANE_ST_DOWN_CARRY		.equ 3 
CRANE_ST_UP_EMPTY		.equ 4 
CRANE_ST_LEFT_EMPTY		.equ 5
CRANE_ST_EXIT			.equ 6
CRANE_ST_WAIT_EMPTY		.equ 7
CRANE_ST_COLLISION		.equ 8; Error

; Relative address enums
CRANE_RA_X				.equ 0;b2_crane_visual_coord ;CRANE_RA_Y = 0 always!
CRANE_RA_ROPE			.equ 1;rope´s end
CRANE_RA_STATUS			.equ 2;b_crane_status
CRANE_RA_TARGET_X		.equ 3;b_crane_target_visual_coord
CRANE_RA_ANIM_LEFT		.equ 4
CRANE_RA_BOX_ADDR		.equ 5; carried box´s address
CRANE_RA_BOX_ADDR2		.equ 6;
CRANE_RA_SERIAL			.equ 7; crane serial

CRANE_STEP				.equ	1; CRANE_RA_ANIM_LEFT must multiply of this!
CRANE_ROPE_MIN			.equ	8; minimum rope length
CRANE_START_POS			.equ	96; start x position... outside

#define m_CraneAnimGo_ix_0		ld (ix+CRANE_RA_ANIM_LEFT), 8; define a macro for easy way

CraneCaseVecTbl:
.dw     L_CRANEU_CASE_STAND
.dw		L_CRANEU_CASE_ENTER
.dw     L_CRANEU_CASE_LEFTCARRY
.dw     L_CRANEU_CASE_DOWNCARRY
.dw     L_CRANEU_CASE_UPEMPTY
.dw		L_CRANEU_CASE_LEFTEMPTY
.dw		L_CRANEU_CASE_EXIT
.dw		L_CRANEU_CASE_WAIT_EMPTY
.dw     L_CRANEU_CASE_COLLISION
v_CraneInit_aix_0:;TESZT:OK
		ld		(ix+CRANE_RA_X),			CRANE_START_POS; b2_crane_visual_coord.x = newx
		ld		(ix+CRANE_RA_ROPE),			CRANE_ROPE_MIN
		ld		(ix+CRANE_RA_STATUS),		CRANE_ST_WAIT_EMPTY
		ld		(ix+CRANE_RA_TARGET_X),		CRANE_START_POS; visual
		ld		(ix+CRANE_RA_ANIM_LEFT),	0;
		ld		(ix+CRANE_RA_BOX_ADDR),		0
		ld		(ix+CRANE_RA_BOX_ADDR2),	0
		ld		(ix+CRANE_RA_SERIAL),		a
	ret

v_CraneRender_ix_z:;TESZT:OK
		ld		d, (ix+CRANE_RA_X)
		ld		e, 0
		ld		c, (ix+CRANE_RA_ROPE)
		ld		ix, spritekrane8x56
		jp		v_SpriteDrawOR8xC_cdeix_z

; bc = logic koords
v_CraneUpdate_bcix_abcdehl:;TESZT:OK
		ld		a, (ix+CRANE_RA_STATUS); getstatus
		ld		h, 0
		ld		l, a
		add		hl, hl
		ld		de, CraneCaseVecTbl
		add		hl, de

		ld		a, (hl)
		inc		hl
		ld		h, (hl)
		ld		l, a
		ld		a, (ix+CRANE_RA_ANIM_LEFT)
		cp		0
		jp 		(hl)
		
L_CRANEU_CASE_STAND:
		ret
		
L_CRANEU_CASE_ENTER:
		jp		nz, l_craneu_case_enter_anim
		jp		v_CraneLeftCarry_ix_a

l_craneu_case_enter_anim:
		call	v_CraneAnimLeft_ix_a
		jp		v_CraneSetBoxVisCoords_ix_dehl

L_CRANEU_CASE_LEFTCARRY:; a = anim left, bc = logic koords
		jp		nz, l_craneu_case_left_c_anim
		ld		a, (ix+CRANE_RA_X)
		cp		(ix+CRANE_RA_TARGET_X)
		jp		nz, l_craneu_case_left_toward;target koord == act koord?
		jp		v_CraneDownCarry_ix_a

l_craneu_case_left_toward:
; remark_1: was a hard thing to find an optimal and playable gameing
; not too mutch, not too slow, not too fast etc.
		; push	bc
		; ld		c, 0
		; call	a_MapMgrGetLeft_bc_abcdhl; crane bridge left free?
		; pop		bc
		; cp		0
		; ret		nz; no, waiting
		
; check_box_next_left
		call	a_MapMgrGetLeft_bc_abcdhl
		cp		0
		jp		z, l_craneu_case_left_c_free; equal what hitting, box or the worker
		jp		v_CraneCollision_ix_a

l_craneu_case_left_c_free:
		m_CraneAnimGo_ix_0
l_craneu_case_left_c_anim:
		call	v_CraneAnimLeft_ix_a
		jp		v_CraneSetBoxVisCoords_ix_dehl

L_CRANEU_CASE_DOWNCARRY:; a = anim left, bc = logic koords
		jp		nz, l_craneu_case_anim_down
; check_crane_next_down
		call	a_MapMgrGetUnder_bc_abcdhl
		cp		0
		jp		z, l_craneu_case_down_free
		cp		3; worker
		jp		nz, l_craneu_case_can_drop
		jp		v_CraneCollision_ix_a

l_craneu_case_can_drop:
		jp		v_CraneDropTheBox_ix_abcdhl

l_craneu_case_down_free:
		m_CraneAnimGo_ix_0
l_craneu_case_anim_down:
		call	v_CraneAnimDown_ix_a
		jp		v_CraneSetBoxVisCoords_ix_dehl

L_CRANEU_CASE_UPEMPTY:; a = anim left, bc = logic koords
		jp		nz, l_craneu_case_anim_up
		ld		a, (ix+CRANE_RA_ROPE)
		cp		CRANE_ROPE_MIN
		jp		nz, l_craneu_case_up_toward
		jp		v_CraneLeftEmpty_ix_a

l_craneu_case_up_toward:
		m_CraneAnimGo_ix_0
l_craneu_case_anim_up:
		jp		v_CraneAnimUp_ix_a
		
L_CRANEU_CASE_LEFTEMPTY:; a = anim left, bc = logic koords
		jp		nz, l_craneu_case_anim_e_left
;remark_2: see remark_1
		; ld		c, 0
		; call	a_MapMgrGetLeft_bc_abcdhl; crane bridge left free?
		; cp		$ff; wall?
		; jp		z, v_CraneExit_ix_a
		; cp		0; free?
		; ret		nz; no, wait for another crane
		ld		a, (ix+CRANE_RA_X)
		cp		0
		jp		nz, l_craneu_case_left_e_free
		jp		v_CraneExit_ix_a; krane running out

L_CRANEU_CASE_EXIT:; a = anim left, bc = logic koords
		jp		nz, l_craneu_case_anim_e_left
		ld		a, (ix+CRANE_RA_X)
		cp		-8
		jp		nz, l_craneu_case_left_e_free
		jp		v_CraneWaitEmpty_ix_a; krane running out -> change to empty status

l_craneu_case_left_e_free:;left_empty and exit common end routines
		m_CraneAnimGo_ix_0
l_craneu_case_anim_e_left:
		jp		v_CraneAnimLeft_ix_a

L_CRANEU_CASE_WAIT_EMPTY:; a = anim left, bc = logic koords
	ret
L_CRANEU_CASE_COLLISION:; a = anim left, bc = logic koords
	ret
; ***** CRANE UPDATE END *****
; ****************************

v_CraneStartCarry_aix_0:;TESZT:OK
		ld		(ix+CRANE_RA_TARGET_X), a; b_crane_target_coord = target_c
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_ENTER
		m_CraneAnimGo_ix_0
	ret
v_CraneLeftCarry_ix_a:;TESZT:OK
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_LEFT_CARRY
	ret
v_CraneStand_ix_a:;TESZT:OK
		ld		(ix+CRANE_RA_X), CRANE_START_POS
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_STAND
	ret
v_CraneDownCarry_ix_a:;TESZT:OK
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_DOWN_CARRY
	ret
v_CraneDropTheBox_ix_abcdhl:;TESZT:OK
		ld		l, (ix+CRANE_RA_BOX_ADDR)
		ld		h, (ix+CRANE_RA_BOX_ADDR2)
		push	ix
		push	hl
		pop		ix
		call	a_BoxStand_ix_abcdhl
		pop		ix
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_UP_EMPTY
	ret
v_CraneLeftEmpty_ix_a:;TESZT:OK
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_LEFT_EMPTY
	ret
v_CraneExit_ix_a:;TESZT:OK
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_EXIT
	ret
v_CraneWaitEmpty_ix_a:;TESZT:OK
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_WAIT_EMPTY
	ret
v_CraneCollision_ix_a:;TESZT:OK
		ld		(ix+CRANE_RA_STATUS), CRANE_ST_COLLISION
	ret
; v_CraneAnimGo_ix_0:
		; ld		(ix+CRANE_RA_ANIM_LEFT), 8; MAKRO
	; ret

v_CraneAnimLeft_ix_a:;TESZT:OK
		dec		(ix+CRANE_RA_X)
		jp		l_crane_anim_common_end

v_CraneAnimDown_ix_a:;TESZT:OK
		inc		(ix+CRANE_RA_ROPE)
		jp		l_crane_anim_common_end

v_CraneAnimUp_ix_a:;TESZT:OK
		dec		(ix+CRANE_RA_ROPE)
		;jp		l_crane_anim_common_end

l_crane_anim_common_end:
		dec		(ix+CRANE_RA_ANIM_LEFT)
	ret

bc_CraneGetVisXY_ix_bc:;TESZT:OK
		ld		b, (ix+CRANE_RA_X)
		ld		c, (ix+CRANE_RA_ROPE)
	ret
	
v_CraneSetBoxVisCoords_ix_dehl:;TESZT:OK
		ld		d, (ix+CRANE_RA_X)
		ld		e, (ix+CRANE_RA_ROPE)
		ld		l, (ix+CRANE_RA_BOX_ADDR)
		ld		h, (ix+CRANE_RA_BOX_ADDR2)
		push	ix
		push	hl
		pop		ix
		call	v_BoxSetCoords_deix_0
		pop		ix
	ret

v_CraneAddBox_ixhl_0:;TESZT:OK
		ld		(ix+CRANE_RA_BOX_ADDR), l
		ld		(ix+CRANE_RA_BOX_ADDR2), h
	ret

v_CraneUpdateMap_ix_abcdhl:;TESZT:OK
		ld		a, (ix+CRANE_RA_SERIAL)
		ld		b, (ix+CRANE_RA_X)
		ld		c, 0; always 0 row
		call	bc_MapMgrVisualToLogic_bc_bc
		call	v_MapMgrSetAndCheckAt_abc_abcdhl
		
		ld		a, 7
		ld		b, (ix+CRANE_RA_X)
		add		a, b
		ld		b, a
		ld		c, 7; (ix+CRANE_RA_ROPE)
		ld		a, (ix+CRANE_RA_SERIAL)
		call	bc_MapMgrVisualToLogic_bc_bc
		jp		v_MapMgrSetAndCheckAt_abc_abcdhl
		
a_CraneGetStatus_ix_0:;TESZT:OK
		ld		a, (ix+CRANE_RA_STATUS)
	ret
	
;************************************************	
;*************** CRANEMANAGER *******************
;************************************************
; Manage the Kranes and keep they running

CRANEM_MAX_CRANES		.equ 8; change here the num of Cranes if you want
; I find 8 is optimal. 10 is too mutch, 6 or 7 is boring
CRANEM_C_HEAP_BASE		.equ $F200; for all Crane datas. 256 / 8 = 32 = maximum handable cranes

; helper blocks
a_cranemgr_crane_count:
.db 00
a_cranemgr_entering_crane:
.db 00

v_CraneMgrInit_0_bdeix:;TESZT:OK
		ld		b, CRANEM_MAX_CRANES
		ld		de, 8
		ld		ix, CRANEM_C_HEAP_BASE
l_cranem_init_loop:
		ld		a, b
		add		a, MAPM_TOKEN_CRANEBASE; m+n,m+n-1,...,m+1
		call	v_CraneInit_aix_0
		add		ix, de
		djnz	l_cranem_init_loop
	ret
	
ix_CraneMgrGetCrane_c_bcix:;TESZT:OK
		sla		c
		sla		c
		sla		c
		ld		b, 0
		ld		ix, CRANEM_C_HEAP_BASE
		add		ix, bc
	ret

; FE = foreach
v_CraneMgrFERender_0z:;TESZT:OK
		ld		c, 0
l_cranem_rend_loop:
		push	bc; save c
		call	ix_CraneMgrGetCrane_c_bcix
		call	v_CraneRender_ix_z
		pop		bc;reload c
		inc		c
		ld		a, c
		cp		CRANEM_MAX_CRANES
		jp		nz, l_cranem_rend_loop
	ret

; ret in A $00 on OK, $ff on fail
; FE = foreach
a_CraneMgrFEUpdate_0z:;TESZT:OK
		ld		hl, a_cranemgr_crane_count
		ld		(hl), 0
l_cranemfe_u_crane_fe_loop:
		; call	v_RandomRandomise_0_hl

		ld		hl, a_cranemgr_crane_count
		ld		c, (hl)
		
		call	ix_CraneMgrGetCrane_c_bcix
		
		call	bc_CraneGetVisXY_ix_bc
		call	bc_MapMgrVisualToLogic_bc_bc
		call	v_CraneUpdate_bcix_abcdehl; update
		call	a_CraneGetStatus_ix_0
		cp		CRANE_ST_COLLISION; check collision
		jp		z, l_cranemfe_u_error

; if crane is empty, give him a box then switch to stand status
	push	af; save current status
		cp		CRANE_ST_WAIT_EMPTY; this crane empty
		jp		nz, l_cranemfe_u_crane_notempty
		
;add a box to crane
		push	ix; save crane address
		call	aix_BoxMgrNewBox_0z; ret $ff on fail
		cp		$ff
		jp		z, l_cranemfe_u_box_error
		call	v_BoxOnCrane_ix_0; set box´s status to carry crane
		push	ix; switch box address to hl
		pop		hl
		pop		ix;restore crane address
		call	v_CraneAddBox_ixhl_0
		call	v_CraneStand_ix_a
		call	v_CraneSetBoxVisCoords_ix_dehl
		jp		l_cranemfe_u_crane_busy

l_cranemfe_u_crane_notempty:
; this crane starting if its in stand status and 
; the entering place is free ( upper right position )
		cp		CRANE_ST_STAND
		jp		nz, l_cranemfe_u_crane_busy
				
		ld		hl, a_cranemgr_entering_crane; enter free?
		ld		a, (hl)
		cp		0
		jp		nz, l_cranemfe_u_crane_busy

		ld		a, (ix+CRANE_RA_SERIAL); occupie that!
		ld		(hl), a
;set box's destination
		call	a_RandomGetDest_0_adehl
		inc		a
; logic_target_coord = RandomGetANummer(10)+1
		sla		a
		sla		a
		sla		a
		call	v_CraneStartCarry_aix_0
		jp		l_cranemfe_u_crane_busy
l_cranemfe_u_box_error:
		pop		ix; pop crane address
		call	v_CraneCollision_ix_a
		pop		de; delete old a
		jp		l_cranemfe_u_error
		
l_cranemfe_u_crane_busy:
	pop		af; restore status
		
		ld		a, (ix+CRANE_RA_SERIAL)
		ld		hl, a_cranemgr_entering_crane; the entering crane?
		cp		(hl)
		jp		nz, l_cranemfe_u_crane_not_leftcarry
		
		ld		a, (ix+CRANE_RA_X)
		cp		80
		jp		nc, l_cranemfe_u_crane_not_leftcarry
		ld		(hl), 0; make enter free
		
l_cranemfe_u_crane_not_leftcarry
		ld		hl, a_cranemgr_crane_count
		inc		(hl)
		ld		a, (hl)
		cp		CRANEM_MAX_CRANES
		jp		nz, l_cranemfe_u_crane_fe_loop
		
		xor		a
	ret; OK
l_cranemfe_u_error:
		ld		a, $ff
	ret; Error

; FE = foreach
v_CraneMgrFEUpdateMap_0z:;TESZT:OK
		ld		hl, a_cranemgr_crane_count
		ld		(hl), 0
l_cranemfe_u_map_fe_loop:
		ld		hl, a_cranemgr_crane_count
		ld		c, (hl)
		call	ix_CraneMgrGetCrane_c_bcix
		
		call	v_CraneUpdateMap_ix_abcdhl
		
		ld		hl, a_cranemgr_crane_count
		inc		(hl)
		ld		a, (hl)
		cp		CRANEM_MAX_CRANES
		jp		nz, l_cranemfe_u_map_fe_loop
	ret

