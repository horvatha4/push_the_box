;*****************************************
;****************** WORKER ***************
;*****************************************

;A játékos álltal irányított karakter amire hat a gravitáció is.
; This Character directed by the player. He can push, jump up, jump over one box.
; Influensed by the "Gravity".

; Status enums
WORKER_STATUS_STAND						.EQU 00
WORKER_STATUS_WALK_LEFT					.EQU 01
WORKER_STATUS_WALK_RIGHT				.EQU 02
WORKER_STATUS_PUSH_LEFT					.EQU 03
WORKER_STATUS_PUSH_LEFT_FAIL			.EQU 04
WORKER_STATUS_PUSH_RIGHT				.EQU 05
WORKER_STATUS_PUSH_RIGHT_FAIL			.EQU 06
WORKER_STATUS_JUMP_UP_LEFT				.EQU 07
WORKER_STATUS_JUMP_UP_LEFT_FAIL			.EQU 08
WORKER_STATUS_JUMP_UP_RIGHT				.EQU 09
WORKER_STATUS_JUMP_UP_RIGHT_FAIL		.EQU 10
WORKER_STATUS_JUMP_OVER_LEFT			.EQU 11
WORKER_STATUS_JUMP_OVER_RIGHT			.EQU 12
WORKER_STATUS_FALL						.EQU 13
WORKER_STATUS_DIE						.EQU 14
WORKER_STATUS_JUMPUP_OVER_LEFT			.EQU 15
WORKER_STATUS_JUMPUP_OVER_LEFT_FAIL		.EQU 16
WORKER_STATUS_JUMPUP_OVER_RIGHT			.EQU 17
WORKER_STATUS_JUMPUP_OVER_RIGHT_FAIL	.EQU 18
WORKER_STATUS_DIED						.EQU 19

; Relative address enums. Relative to worker_base_datas address.
WORKER_RA_COORD_X						.equ 0
WORKER_RA_COORD_Y						.equ 1
WORKER_RA_ANIM_LENGTH					.equ 2
WORKER_RA_CURRENT_FRAME					.equ 3
WORKER_RA_FALL_COUNT					.equ 4
WORKER_RA_STATUS						.equ 5
WORKER_RA_FRAME_POINTER_LO				.equ 6
WORKER_RA_FRAME_POINTER_HI				.equ 7
WORKER_RA_COORDS_POINTER_LO				.equ 8
WORKER_RA_COORDS_POINTER_HI				.equ 9
WORKER_RA_PUSHED_BOX_SERIAL				.equ 10

WBD:; worker_base_datas
.db 00; x coord
.db 00;	y coord
.db 00; anims length
.db 00; witch frame must render
.db 00; how high falling
.db 00; witch anim play now, status
.db 00, 00; akt frame pointer lo/hi
.db	00, 00; akt coords pointer lo/hi
.db 00; pushed box serial

a3_worker_anim_datas:; anim length, start of xy coords, start of frames in dataheap
.db 01, 00, 00; worker_stand
.db 05, 01, 86; worker_walk_left
.db 05, 06, 91; worker_walk_right
.db 06, 11, 74; worker_push_left
.db 06, 17, 74; worker_push_left_fail
.db 06, 23, 80; worker_push_right
.db 06, 29, 80; worker_push_right_fail
.db 07, 35, 46; worker_jump_up_left
.db 07, 42, 53; worker_jump_up_left_fail
.db 07, 49, 67; worker_jump_up_right
.db 07, 56, 60; worker_jump_up_right_fail
.db 11, 63, 06; worker_jump_over_left
.db 11, 74, 35; worker_jump_over_right
.db 05, 85,102; worker_fall
.db 05, 90, 01; worker_die
.db 11, 95, 06; worker_jumpup_over_left
.db 09,106, 17; worker_jumpup_over_left_fail
.db 11,115, 35; worker_jumpup_over_right
.db 09,126, 26; worker_jumpup_over_right_fail


worker_anim_xy_coords:
;		0	  1		2	  3		4	  5		6	  7		8	  9	   10
.db	 0, 0; worker_stand
.db -1, 0,-3, 0,-2, 0,-2, 0,-0, 0; worker_walk_left
.db +1, 0,+3, 0,+2, 0,+2, 0,+0, 0; worker_walk_right
.db -1, 0,-2, 0,-2, 0,-1, 0,-2, 0, 0, 0; worker_push_left
.db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; worker_push_left_fail
.db +1, 0,+2, 0,+2, 0,+1, 0,+2, 0, 0, 0; worker_push_right
.db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; worker_push_right_fail
.db	 0, 0,-2,-3,-2,-4,-2,-1,-2, 0, 0, 0, 0, 0; worker_jump_up_left
.db	 0, 0,-2,-3,-1,-2, 0, 2, 0, 3, 3, 0,+0, 0; worker_jump_up_left_fail
.db	 0, 0,+2,-3,+2,-4,+2,-1,+2, 0, 0, 0, 0, 0; worker_jump_up_right
.db	 0, 0,+2,-3,+1,-2,+0, 2, 0, 3,-3, 0,-0, 0; worker_jump_up_right_fail
.db -1, 0,-2, 0,-2,-1,-2,-1,-2,-1,-2, 0,-2, 1,-2, 1,-1, 1, 0, 0, 0, 0; worker_jump_over_left
.db +1, 0,+2, 0,+2,-1,+2,-1,+2,-1,+2, 0,+2, 1,+2, 1,+1, 1, 0, 0, 0, 0; worker_jump_over_right
.db	 0, 1, 0, 2, 0, 3, 0, 2, 0, 0; worker_fall
.db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; worker_die
.db -1, 0,-2, 0,-2,-3,-2,-3,-2,-3,-2, 0,-2, 0,-2, 0,-1, 1, 0, 0, 0, 0; worker_jumpup_over_left
.db -1, 0,-2, 0,-2,-1,-2,-1,-2,-1,-2, 0, 0, 2, 3, 1,+0, 0; worker_jumpup_over_left_fail
.db +1, 0,+2, 0,+2,-3,+2,-3,+2,-3,+2, 0,+2, 0,+2, 0,+1, 1, 0, 0, 0, 0; worker_jumpup_over_right
.db +1, 0,+2, 0,+2,-1,+2,-1,+2,-1,+2, 0, 0, 2,-3, 1,-0, 0; worker_jumpup_over_right_fail

; bc = (newx,newy) visual coords
v_WorkerInit_bc_abcix:;TESZT:OK
		ld		ix, WBD
		ld		(ix+WORKER_RA_COORD_X), b
		ld		(ix+WORKER_RA_COORD_Y), c
		xor		a
		ld		(WBD+WORKER_RA_ANIM_LENGTH), a; b_worker_current_anim_left
		ld		(WBD+WORKER_RA_CURRENT_FRAME), a; b_worker_current_frame
		ld		(WBD+WORKER_RA_FALL_COUNT), a; b_worker_fallcount = 0
		ld		(WBD+WORKER_RA_STATUS), a; (worker_stand)
		ld		(WBD+WORKER_RA_PUSHED_BOX_SERIAL), a
		jp		v_WorkerSetAnim_a_z

WorkerCaseActionTbl:
.dw L_WORKERU_CASE_NOTHING 
.dw L_WORKERU_CASE_LEFT
.dw L_WORKERU_CASE_RIGHT
.dw L_WORKERU_CASE_LR
.dw L_WORKERU_CASE_UP
.dw L_WORKERU_CASE_UP_LEFT
.dw L_WORKERU_CASE_UP_RIGHT
.dw L_WORKERU_CASE_ALL

a_WorkerUpdate_0z:;TESZT:OK
		ld		a, (WBD+WORKER_RA_STATUS)
		cp		WORKER_STATUS_STAND
		jp		nz, l_workeru_nostand

		ld		ix, WBD
		ld		b, (ix+WORKER_RA_COORD_X)
		ld		c, (ix+WORKER_RA_COORD_Y)
		call	bc_MapMgrVisualToLogic_bc_bc; logic coords to bc
		push	bc
		call	a_MapMgrGetUnder_bc_abcdhl; check_worker_next_down is empty
		pop		bc
		cp		0
		jp		z, v_WorkerFall_0z; fall if nothing under
		
		push	bc
		call	a_MapMgrGetAt_bc_abcdhl
		pop		bc
		cp		MAPM_TOKEN_WORKER
		jp		nz, v_WorkerDie_0z
		
		ld		a, (b_player_want);start CASE logic
		ld		h, 0
		ld		l, a
		add		hl, hl
		ld		de, WorkerCaseActionTbl
		add		hl, de
		ld		a, (hl)
		inc		hl
		ld		h, (hl)
		ld		l, a
		jp		(hl)

L_WORKERU_CASE_NOTHING:
	ret
L_WORKERU_CASE_LEFT:
		push	bc
		call	a_MapMgrGetLeft_bc_abcdhl
		pop		bc
		cp		0; empty?
		jp		z, v_WorkerWalkLeft_0z; yes
		ld		e, a; not empty; save A
		and		MAPM_TOKEN_BOX_MOVING_BASE; moving box or wall?
		jp		nz, v_WorkerPushLeftFail_0z; yes
		
		dec		b; left from box empty?
		push	bc
		call	a_MapMgrGetLeft_bc_abcdhl
		pop		bc
		cp		0
		jp		nz, v_WorkerPushLeftFail_0z; not
		call	a_MapMgrGetOver_bc_abcdhl; over the box empty?
		cp		0
		jp		nz, v_WorkerPushLeftFail_0z
		ld		a, e; reload A
		jp		v_WorkerPushLeft_a_z

L_WORKERU_CASE_RIGHT:
		push	bc
		call	a_MapMgrGetRight_bc_abcdhl; check_worker_next_right
		pop		bc
		cp		0; empty?
		jp		z, v_WorkerWalkRight_0z; yes
		ld		e, a; save a
		and		MAPM_TOKEN_BOX_MOVING_BASE; moving box or wall?
		jp		nz, v_WorkerPushRightFail_0z; yes
		
		inc		b
		push	bc
		call	a_MapMgrGetRight_bc_abcdhl; check_box_next_right
		pop		bc
		cp		0
		jp		nz, v_WorkerPushRightFail_0z; if not empty
		call	a_MapMgrGetOver_bc_abcdhl
		cp		0
		jp		nz, v_WorkerPushRightFail_0z; right over not empty too
		ld		a, e; reload
		jp		v_WorkerPushRight_a_z
		
L_WORKERU_CASE_LR:
		jp		a_WorkerGetStatus_0_a; NOP
L_WORKERU_CASE_UP:
		jp		a_WorkerGetStatus_0_a; NOP
L_WORKERU_CASE_UP_LEFT:; left+fel
		push	bc
		call	a_MapMgrGetLeft_bc_abcdhl; left #1
		pop		bc
		cp		0
		jp		z, l_wrkru_jmp_left_over;nothing
		and		MAPM_TOKEN_BOX_STANDING_BASE
		jp		z, v_WorkerJumpUpLeftFail_0z; not box
		dec		b
		call	a_MapMgrGetOver_bc_abcdhl; box over #2
		cp		0
		jp		nz, v_WorkerJumpUpLeftFail_0z;not empty
		jp		v_WorkerJumpUpLeft_0z
l_wrkru_jmp_left_over:
		dec		b
		push	bc
		call	a_MapMgrGetLeft_bc_abcdhl; left left #2
		pop		bc
		cp		0
		jp		z, l_wrkru_maybe_jol;v_WorkerJumpOverLeft_0z
		and		MAPM_TOKEN_BOX_STANDING_BASE
		jp		z, v_WorkerJumpUpOverLeftFail_0z; not a box, fail
		
		dec		b; left left
		call	a_MapMgrGetOver_bc_abcdhl; over #3
		cp		0
		jp		nz, v_WorkerJumpUpOverLeftFail_0z
		jp		v_WorkerJumpUpOverLeft_0z
l_wrkru_maybe_jol:
		dec		b; left left
		call	a_MapMgrGetOver_bc_abcdhl; over #3
		cp		0
		jp		nz, v_WorkerJumpUpOverLeftFail_0z
		jp		v_WorkerJumpOverLeft_0z
		
L_WORKERU_CASE_UP_RIGHT:; right+up
		push	bc
		call	a_MapMgrGetRight_bc_abcdhl; check_worker_next_right
		pop		bc
		cp		0
		jp		z, l_wrkru_jmp_right_over
		and		MAPM_TOKEN_BOX_STANDING_BASE
		jp		z, v_WorkerJumpUpRightFail_0z;not box
		inc		b; check right over
		call	a_MapMgrGetOver_bc_abcdhl
		cp		0
		jp		nz, v_WorkerJumpUpRightFail_0z; not empty
		jp		v_WorkerJumpUpRight_0z
l_wrkru_jmp_right_over:
		inc		b
		push	bc
		call	a_MapMgrGetRight_bc_abcdhl; right right
		pop		bc
		cp		0
		jp		z, l_wrkru_maybe_jor
		and		MAPM_TOKEN_BOX_STANDING_BASE
		jp		z, v_WorkerJumpUpOverRightFail_0z
		
		inc		b
		call	a_MapMgrGetOver_bc_abcdhl
		cp		0
		jp		nz, v_WorkerJumpUpOverRightFail_0z
		jp		v_WorkerJumpUpOverRight_0z
l_wrkru_maybe_jor:		
		inc		b
		call	a_MapMgrGetOver_bc_abcdhl
		cp		0
		jp		nz, v_WorkerJumpUpOverRightFail_0z
		jp		v_WorkerJumpOverRight_0z
		
L_WORKERU_CASE_ALL:
		jp		a_WorkerGetStatus_0_a

l_workeru_nostand:
		ld		ix, WBD
		ld		a, (ix+WORKER_RA_ANIM_LENGTH)
		cp		(ix+WORKER_RA_CURRENT_FRAME)
		jp		nz, l_workeru_updanim; anim play end?
			
		ld		a, (ix+WORKER_RA_STATUS)
		cp		WORKER_STATUS_DIE; b_worker_status == worker_die
		jp		z, v_WorkerDied_0z
		
		; set the pushed box to stand if any
		cp		WORKER_STATUS_PUSH_LEFT; ?
		jp		nz, l_wrkru_no_push_left; no
		ld		a, (WBD+WORKER_RA_PUSHED_BOX_SERIAL)
		call	ix_BoxMgrGetBox_a_bcix
		call	a_BoxStand_ix_abcdhl
		jp		l_wrkru_no_push_at_all
		
l_wrkru_no_push_left:
		cp		WORKER_STATUS_PUSH_RIGHT; ?
		jp		nz, l_wrkru_no_push_at_all; no
		ld		a, (WBD+WORKER_RA_PUSHED_BOX_SERIAL)
		call	ix_BoxMgrGetBox_a_bcix
		call	a_BoxStand_ix_abcdhl
l_wrkru_no_push_at_all:

		ld		ix, WBD
		ld		b, (ix+WORKER_RA_COORD_X)
		ld		c, (ix+WORKER_RA_COORD_Y)
		call	bc_MapMgrVisualToLogic_bc_bc
		call	a_MapMgrGetUnder_bc_abcdhl; check_worker_next_down is empty
		cp		0
		jp		z, v_WorkerFall_0z; fall if under is empty
		
		ld		a, (ix+WORKER_RA_FALL_COUNT)
		cp		3
		jp		nc, v_WorkerDie_0z; b_worker_fallcount > 2
		
		xor		a
		ld		(ix+WORKER_RA_FALL_COUNT), a; b_worker_fallcount = 0
		jp		v_WorkerStand_0z
		
l_workeru_updanim:; WorkerUpdateAnim()
		inc		(ix+WORKER_RA_CURRENT_FRAME);inc framecounter
		ld		hl, (WBD+WORKER_RA_FRAME_POINTER_LO); step frame pointer
		ld		de, 8
		add		hl, de
		ld		(WBD+WORKER_RA_FRAME_POINTER_LO), hl
		
		ld		hl, (WBD+WORKER_RA_COORDS_POINTER_LO); step coord pointer...
		ld		a, (ix+WORKER_RA_COORD_X)
		add		a, (hl); and ... add worker_anim_coords to b2_worker_visual_coord_xy
		ld		(ix+WORKER_RA_COORD_X), a
		inc		hl
		ld		a, (ix+WORKER_RA_COORD_Y)
		add		a, (hl)
		ld		(ix+WORKER_RA_COORD_Y), a
		inc		hl
		
		ld		(WBD+WORKER_RA_COORDS_POINTER_LO), hl

		ld		a, (WBD+WORKER_RA_STATUS); cp push left or right
		cp		WORKER_STATUS_PUSH_LEFT; ?
		jp		z, l_wrkru_push_left; yes
		cp		WORKER_STATUS_PUSH_RIGHT; ?
		jp		z, l_wrkru_push_right; yes
		jp		a_WorkerGetStatus_0_a
		
l_wrkru_push_left:; update the box coords too
		ld		a, (WBD+WORKER_RA_PUSHED_BOX_SERIAL)
		call	ix_BoxMgrGetBox_a_bcix
		ld		hl, (WBD+WORKER_RA_COORD_X)
		ld		a, l
		sub		8
		ld		d, a
		ld		e, h
		call	v_BoxSetCoords_deix_0
		jp		a_WorkerGetStatus_0_a
		
l_wrkru_push_right:
		ld		a, (WBD+WORKER_RA_PUSHED_BOX_SERIAL)
		call	ix_BoxMgrGetBox_a_bcix
		ld		hl, (WBD+WORKER_RA_COORD_X)
		ld		a, l
		add		a, 8
		ld		d, a
		ld		e, h
		call	v_BoxSetCoords_deix_0
		jp		a_WorkerGetStatus_0_a
 
;******************************************************
;***************** WORKER RENDER **********************
;******************************************************
v_WorkerRender_0z:;TESZT:OK
		ld		a, (WBD+WORKER_RA_STATUS)
		cp		WORKER_STATUS_DIED
		ret		z
	; if b_worker_status != worker_died
		ld		ix, WBD
		ld		d, (ix+WORKER_RA_COORD_X)
		ld		e, (ix+WORKER_RA_COORD_Y)
		ld		c, 8
		ld		ix, (WBD+WORKER_RA_FRAME_POINTER_LO)
		jp		v_SpriteDrawOR8xC_cdeix_z; render sprite

;*******************************************************
;*************** WORKER SET ANIM ***********************
;*******************************************************
v_WorkerSetAnim_a_z:;TESZT:OK
		ld		(WBD+WORKER_RA_STATUS), a; b_worker_status = new_anim
		cp		WORKER_STATUS_DIED
	ret		z		;no anim
		cp		0
		jp		nz, l_workerr_notstand
		ld		hl, worker_anim_frames
		ld		(WBD+WORKER_RA_FRAME_POINTER_LO), hl
	ret
l_workerr_notstand:
		ld		l, a
		ld		h, 0
		sla		a
		add		a, l ;3xa->hl
		ld		l, a
		ld		de, a3_worker_anim_datas
		add		hl, de
		ld		a, (hl); hl point to anim length
		dec		a; all anim length -1
		ld		(WBD+WORKER_RA_ANIM_LENGTH), a
		xor		a
		ld		(WBD+WORKER_RA_CURRENT_FRAME), a
		inc		hl
		ld		a, (hl); hl point to coords
		inc		hl
		ld		c, (hl); hl point to frames
		add		a, a
		ld		l, a
		ld		h, 0
		ld		de, worker_anim_xy_coords
		add		hl, de
		ld		(WBD+WORKER_RA_COORDS_POINTER_LO), hl
		
		ld		b, 0
		ld		hl, worker_anim_frames
		sla		c
		sla		c
		rl		b
		sla		c
		rl		b
		add		hl, bc
		ld		(WBD+WORKER_RA_FRAME_POINTER_LO), hl
	ret

v_WorkerStand_0z:;TESZT:OK
		ld		a, WORKER_STATUS_STAND
		jp		v_WorkerSetAnim_a_z

v_WorkerWalkLeft_0z:;TESZT:OK
		ld		a, WORKER_STATUS_WALK_LEFT
		jp		v_WorkerSetAnim_a_z

v_WorkerWalkRight_0z:;TESZT:OK
		ld		a, WORKER_STATUS_WALK_RIGHT
		jp		v_WorkerSetAnim_a_z

v_WorkerPushLeft_a_z:;TESZT:OK
		ld		(WBD+WORKER_RA_PUSHED_BOX_SERIAL), a
		call	ix_BoxMgrGetBox_a_bcix
		call	v_BoxStartPushed_ix_abcdhl
		ld		a, WORKER_STATUS_PUSH_LEFT
		jp		v_WorkerSetAnim_a_z

v_WorkerPushLeftFail_0z:;TESZT:OK
		ld		a, WORKER_STATUS_PUSH_LEFT_FAIL
		jp		v_WorkerSetAnim_a_z

v_WorkerPushRight_a_z:;TESZT:OK
		ld		(WBD+WORKER_RA_PUSHED_BOX_SERIAL), a
		call	ix_BoxMgrGetBox_a_bcix
		call	v_BoxStartPushed_ix_abcdhl
		ld		a, WORKER_STATUS_PUSH_RIGHT
		jp		v_WorkerSetAnim_a_z

v_WorkerPushRightFail_0z:;TESZT:OK
		ld		a, WORKER_STATUS_PUSH_RIGHT_FAIL
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpLeft_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMP_UP_LEFT
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpLeftFail_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMP_UP_LEFT_FAIL
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpRight_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMP_UP_RIGHT
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpRightFail_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMP_UP_RIGHT_FAIL
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpOverLeft_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMP_OVER_LEFT
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpOverRight_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMP_OVER_RIGHT
		jp		v_WorkerSetAnim_a_z

v_WorkerFall_0z:;TESZT:OK
		ld		ix, WBD
		inc		(ix+WORKER_RA_FALL_COUNT); b_worker_fallcount++
		ld		a, WORKER_STATUS_FALL
		jp		v_WorkerSetAnim_a_z

v_WorkerDie_0z:;TESZT:OK
		ld		a, WORKER_STATUS_DIE
		jp		v_WorkerSetAnim_a_z

v_WorkerDied_0z:;TESZT:OK
		ld		a, WORKER_STATUS_DIED
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpOverLeft_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMPUP_OVER_LEFT
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpOverLeftFail_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMPUP_OVER_LEFT_FAIL
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpOverRight_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMPUP_OVER_RIGHT
		jp		v_WorkerSetAnim_a_z

v_WorkerJumpUpOverRightFail_0z:;TESZT:OK
		ld		a, WORKER_STATUS_JUMPUP_OVER_RIGHT_FAIL
		jp		v_WorkerSetAnim_a_z

a_WorkerGetStatus_0_a:;TESZT:OK
		ld		a, (WBD+WORKER_RA_STATUS)
	ret
	
v_WorkerUpdateMap_0_abcdhl:;TESZT:OK
		ld		ix, WBD
		;upper left corner
		ld		b, (ix+WORKER_RA_COORD_X)
		ld		c, (ix+WORKER_RA_COORD_Y)
		call	bc_MapMgrVisualToLogic_bc_bc		
		ld		a, MAPM_TOKEN_WORKER
		call	v_MapMgrSetAndCheckAt_abc_abcdhl
		;upper right corner
		ld		a, (ix+WORKER_RA_COORD_X)
		add		a, 7
		ld		b, a
		ld		c, (ix+WORKER_RA_COORD_Y)
		call	bc_MapMgrVisualToLogic_bc_bc
		ld		a, MAPM_TOKEN_WORKER
		call	v_MapMgrSetAndCheckAt_abc_abcdhl
		;lower left corner
		ld		b, (ix+WORKER_RA_COORD_X)
		ld		a, (ix+WORKER_RA_COORD_Y)
		add		a, 7
		ld		c, a
		call	bc_MapMgrVisualToLogic_bc_bc
		ld		a, MAPM_TOKEN_WORKER
		call	v_MapMgrSetAndCheckAt_abc_abcdhl
		;lower right corner
		ld		a, (ix+WORKER_RA_COORD_X)
		add		a, 7
		ld		b, a
		ld		a, (ix+WORKER_RA_COORD_Y)
		add		a, 7
		ld		c, a
		call	bc_MapMgrVisualToLogic_bc_bc
		ld		a, MAPM_TOKEN_WORKER
		jp		v_MapMgrSetAndCheckAt_abc_abcdhl
	;ret