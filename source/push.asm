; MEMORY ALLOCATION
; FE66h-9D95h = 60D1h (24785) = 24KByte
; c000h-9d95h = 8811d
; BOXM_BOXHEAP_BASE		.equ $F000
; CRANEM_C_HEAP_BASE	.equ $F200
; MAPM_ACTUALMAP		.equ $F300
; BOXM_BAT				.equ $EF00

; x horizontal positive right
; y vertical positive down

; word = 16 bit => lo, hi
; player_want_packed_3_bit = 1 byte = 0. bit left, 1. bit right, 2. bit jump
; l_ = label to jump
; L_ = label to jump
; m_ = makro
; bn_ = n byte
; t_ = text
; fpn_ = floatingpoint nummer

; Funcion naming conventions
; .._FunctionName_parameters_destroys:
; .. = v_ = void
; .. = a_, b_, bc_, hl_, ix_, aix_ ... etc = function return one or more values in those registers
; 0 = no need parameter or destroy nothing
; z = destroy all
; FE in name = foreach

; $00 = false
; $FF = true

; Z	If the zero flag is set.				NZ	If the zero flag is reset.
; C	If the carry flag is set.				NC	If the carry flag is reset.
; PE If the parity/overflow flag is set.	PO	If the parity/overflow flag is reset.
; M	If the sign flag is set.				P	If the sign flag is reset.
; COMPARISON	UNSIGNED			SIGNED
; A == num		Z flag is set		Z flag is set
; A != num		Z flag is reset		Z flag is reset
; A < num		C flag is set		S and P/V are different
; A >= num		C flag is reset		S and P/V are the same

; "call" and "ret" instruction lines changed to "jp"

.nolist
#include	"ti83plus.inc"
.list
.org	$9D93
.db t2ByteTok, tAsmCmp
;***** PROGRAM START *****
		call	v_GameInit
		call	v_GameRun
		jp		v_GameDone
	;ret

; back screen render only from the 6th line
; hl = start address
v_CpyBackScn_6_ToPlotSS_hl_bcdehl:;TESZT:OK
		ld		de, plotsscreen+(6*12)	  ;start at x row of display
		ld		bc, 58*12				  ;58 rows of data
		ldir
	ret

; Wait for any one key then return
v_GetAnyKey_0z:
l_get_any_key_loop:
		ld		a, $bf
		out		(1), a
		in		a, (1)
		cp		$ff
	ret		nz
		ld		a, $df
		out		(1), a
		in		a, (1)
		cp		$ff
	ret		nz
		ld		a, $ef
		out		(1), a
		in		a, (1)
		cp		$ff
	ret		nz
		ld		a, $f7
		out		(1), a
		in		a, (1)
		cp		$ff
	ret		nz
		ld		a, $fb
		out		(1), a
		in		a, (1)
		cp		$ff
	ret		nz
		ld		a, $fd
		out		(1), a
		in		a, (1)
		cp		$ff
	ret		nz
		ld		a, $fe
		out		(1), a
		in		a, (1)
		cp		$ff
	ret		nz
		jp		l_get_any_key_loop
		
;***************************************
;*************** GAME ******************
;***************************************
b_gameEnd:; flag, gameEnd
.db $00
b_gameUpdatePoints:; flag, update points
.db $00
fpn_game_total_score:
.db $00,$80,$00,$00,$00,$00,$00,$00,$00;from OP1
fpn_game_zero_score:
.db $00,$80,$00,$00,$00,$00,$00,$00,$00; for init
fpn_game_plus_score:;  +10
.db $00,$81,$10,$00,$00,$00,$00,$00,$00;to OP3
fpn_game_minus_score:; -1
.db $80,$80,$10,$00,$00,$00,$00,$00,$00;to OP4

; Add fpn_game_plus_score to fpn_game_total_score
v_GameIncreaseScore_0z:;TESZT:OK
		b_call	(_OP3ToOP2)
		b_call	(_FPAdd)
		ld		a, 1
		ld		(b_gameUpdatePoints), a
	ret

; Add fpn_game_minus_score to fpn_game_total_score
v_GameDecreaseScore_0z:;TESZT:OK
		b_call	(_OP4ToOP2)
		b_call	(_FPAdd)
		ld		a, 1
		ld		(b_gameUpdatePoints), a
	ret

; load the score from OP1 to fpn_game_total_score
v_GameGetTotalScore_0_bcdehl:;TESZT:OK
		ld		bc, 9
		ld		hl, OP1
		ld		de, fpn_game_total_score
		ldir
 	ret

; Render a textblock
; b = num of lines in block
; hl = text start address
; ix = text coords start address
; after hl = next byte after the closing zero
v_GameRenderTextblock_bhlix_aix:;TESZT:OK
l_game_textblock_loop:
; one times will run even b == 0
		ld		a, (ix)
		ld		(pencol), a
		inc		ix
		ld		a, (ix)
		ld		(penrow), a
		inc		ix
		b_call	(_vputs)
		djnz	l_game_textblock_loop
	ret

; Show "Game Paused Press a key" block
v_GameShowPause_0_bdeix:;TESZT:??
		ld		hl, game_paused
		ld		de, plotsscreen+(3*8*12)+2
		ld		b, 16
l_game_showpause_loop:
		push	bc
		ld		bc, 8
		ldir
		inc		de
		inc		de
		inc		de
		inc		de
		pop		bc
		djnz	l_game_showpause_loop
		
		b_call	(_GrBufCpy)
	ret

; Show the Help Page
v_GameShowHelp_0z:;TESZT:OK
		b_call	(_ClrLCDFull)
		ld		hl, t_help
		ld		ix, help_text_coords
		ld		b, 7
		call	v_GameRenderTextblock_bhlix_aix
		push	hl
		push	ix
		call	v_GetAnyKey_0z
		b_call	(_ClrLCDFull); destroy ALL
		pop		ix
		pop		hl
		ld		b, 5
		call	v_GameRenderTextblock_bhlix_aix
		push	hl
		push	ix
		call	v_GetAnyKey_0z
		b_call	(_ClrLCDFull); destroy ALL
		pop		ix
		pop		hl
		ld		b, 5
		call	v_GameRenderTextblock_bhlix_aix
		jp		v_GetAnyKey_0z
	;ret
t_help:
.db "Direct the Worker and", 0
.db "fill up the last row", 0
.db "with boxes in the Hall!", 0
.db "The Worker can walk,", 0
.db "jump up, jump over and", 0
.db "push one box.", 0
.db "The Gravity is influencing!", 0

.db "Use the left- right- buttons", 0
.db "to move and 2nd to jump.", 0
.db "CLEAR to exit", 0
.db "Y= to PAUSE",0
.db "(APW dont run!)",0

.db "Watch out for Cranes and", 0
.db "don't let the boxes", 0
.db "or the Worker fall ", 0
.db "too high (max 2 unit)", 0
.db "Good Luck!", 0
help_text_coords:
.db 10,05,15,12,10,19,15,26,05,33,25,40,05,47
.db 05,05,10,12,25,19,28,26,22,33
.db 10,12,20,19,20,26,18,33,30,40

; Show the GameOver Page with Scores
v_GameShowGameOver_0z:;TESZT:OK
		b_call	(_ClrLCDFull); destroy ALL
		ld		hl, t_game_over
		ld		ix, game_over_text_coords
		ld		b, 2
		call	v_GameRenderTextblock_bhlix_aix
		
		ld		a, (ix)
		ld		(pencol), a
		inc		ix
		ld		a, (ix)
		ld		(penrow), a

		ld		a, 6; 6 character
		b_call	(_DispOP1A); ROM call
		jp		v_GetAnyKey_0z
	;ret
t_game_over:
.db "Game Over!",0
.db "Your score is:",0
game_over_text_coords:
.db 30,05,25,12,35,19

v_GameDrawScoreToken_0z:;TESZT:OK
		ld		a, (b_gameUpdatePoints); need score update?
		cp		0
		jp		z, l_game_drawscore_no_update
		call	v_GameGetTotalScore_0_bcdehl
		
		ld		ix, sign_space
		ld		(ix), 36; space if positive
		
		ld		hl, fpn_game_total_score
		ld		a, (hl)
		cp		$80
		jp		nz, l_game_drawscore_non_neg; negatív?
		inc		(ix); draw minus sign
l_game_drawscore_non_neg:
		inc		hl
		ld		a, (hl)
		sub		$80
		jp		m, l_game_drawscore_small; < 1 ?
		cp		6
		jp		nc, l_game_drawscore_big; > 99999
		
		inc		a
		ld		(tmp_space), a;at witch position start the nummer	
; convert fpn mantissa to byte and tile address
		inc		hl; to mantissa
		ld		de, score_space
		ld		b, 3; 3 byte, 6 digit
l_game_drawscore_conv_loop:
		xor		a
		rld
		sla		a
		sla		a
		sla		a; a *= 8
		ld		(de), a
		inc		de
		xor		a
		rld
		sla		a
		sla		a
		sla		a; a *= 8
		ld		(de),a
		inc		de
		inc		hl
		djnz	l_game_drawscore_conv_loop
		xor		a
		ld		(b_gameUpdatePoints), a; update finish, clear the flag
l_game_drawscore_no_update:
;draw score
		ld		hl, score_space
		ld		b, 6; digit
		ld		d, 6; x logic coord
		ld		e, 0; y logic coord
l_game_drawscore_loop:
		ld		a, (tmp_space)
		ld		ix, number_tiles
		push	bc
		cp		b
		jp		c, l_game_drawscore_leadnull

		ld		c, (hl)
		ld		b, 0
		add		ix, bc
		inc		hl
l_game_drawscore_leadnull:
		push	de
		push	hl
		call	v_TileCopy8x8_deix_abdehlix
		pop		hl
		pop		de
		pop		bc
		inc		d
		djnz	l_game_drawscore_loop
;draw msg, 6 character
		ld		hl, msg_space
		ld		a, 6
		ld		d, 0
		ld		e, 0
l_game_drawscore_msg_loop:
		ld		b, 0
		ld		c, (hl)
		sla		c
		sla		c
		sla		c
		rl		b
		ld		ix, number_tiles
		add		ix, bc
		push	af
		push	de
		push	hl
		call	v_TileCopy8x8_deix_abdehlix
		pop		hl
		pop		de
		pop		af
		inc		hl
		inc		d
		dec		a
		cp		0
		jp		nz, l_game_drawscore_msg_loop
l_game_drawscore_small:
l_game_drawscore_big:
	ret
tmp_space:
.db $00
msg_space:
.db 28,12,24,27,14; "score" ;-)
sign_space:
.db 00
score_space:
.db $00,$00,$00,$00,$00,$00,0
game_counter:; 3x8 bit game cycle counter
.db $00, $00, $00

b_player_want:; packed 1 byte 3 bit
		; 0.bit - left
		; 1.bit - right
		; 2.bit - up
.db 00

PL_WILL_NOTHING		.equ 0
PL_WILL_LEFT		.equ 1
PL_WILL_RIGHT		.equ 2
PL_WILL_LR			.equ 3
PL_WILL_UP			.equ 4
PL_WILL_UP_LEFT		.equ 5
PL_WILL_UP_RIGHT	.equ 6
PL_WILL_ALL			.equ 7

v_GameInit:;TESZT:OK
		b_call	(_RunIndicOff);Deactivates the Run Indicator.
		xor		a
		ld		(b_gameEnd), a;b_gameEnd = false
		inc		a
		ld		(b_gameUpdatePoints), a; b_gameUpdatePoints = true
		ld		hl, fpn_game_plus_score
		b_call	(_Mov9ToOP1)
		b_call	(_OP1ToOP3)
		ld		hl, fpn_game_minus_score
		b_call	(_Mov9ToOP2)
		b_call	(_OP2ToOP4)
		ld		hl, fpn_game_zero_score
		b_call	(_Mov9ToOP1)

		xor		a		
		ld		(b_player_want), a
		call	v_MapMgrInit_0_bcdehl
		call	v_BoxMgrInit_0_abde
		call	v_CraneMgrInit_0_bdeix
		
		call	v_RandomInit_0_ahl
		
		ld		b, 6
		ld		c, 5
		call	bc_MapMgrLogicToVisual_bc_bc
		call	v_WorkerInit_bc_abcix
				
		call	aix_BoxMgrNewBox_0z; to add a box
		ld		d, 7*8
		ld		e, 5*8
		call	v_BoxSetCoords_deix_0
		jp		a_BoxStand_ix_abcdhl
	; ret

v_GameRun:;TESZT:OK
		ld		hl, start_page; render start page and menu
		ld		de, plotsscreen
		ld		bc, 64*12				  ;64 rows of data
		ldir
		b_call	(_GrBufCpy)
l_game_r_key_loop:; wait for 2ND or MODE key
		ld		a, BFh	 ; key group
		out		(1), a
		in		a, (1)
		cp		BFh
		jp		z, l_game_r_help; MODE key - Help
		ld		a, BFh	 ; key group
		out		(1), a
		in		a, (1)
		cp		DFh
		jp		z, l_game_r_start; 2ND key - Start Game
		jp		l_game_r_key_loop
l_game_r_help:
		call	v_GameShowHelp_0z; render help pages
l_game_r_start:; lets start the game
l_game_r_while_loop:
				; ProcessInput()
					; ReadKeys()
; player_want_packed_3_bit = 1 byte = 0. bit left, 1. bit right, 2. bit jump
		ld		b, 0
		ld		c, b
		ld		d, b
		ld		a, $FD
		out		(1), a
		in		a, (1)
		cp		$BF
		jp		z, l_game_r_exit; GameExit(); CLEAR FD, BF
		
		ld		a, $BF
		out		(1), a
		in		a, (1)
		cp		$EF
		jp		nz, l_game_r_no_pause; GamePause(); Y= BF, EF
		call	v_GameShowPause_0_bdeix
		call	v_GetAnyKey_0z

l_game_r_no_pause:
		cp		$DF
		jp		nz, l_game_r_no_jump
		ld		d, 4; 2ND key - jump
l_game_r_no_jump:
		ld		a, $FE
		out		(1), a
		in		a, (1)
		cp		$FD			
		jp		nz, l_game_r_no_left;left FE, FD
		ld		b, 1; LEFT
l_game_r_no_left:
		cp		$FB		
		jp		nz, l_game_r_no_right;right FE; FB
		ld		c, 2; RIGHT
l_game_r_no_right:
		xor		a
		or		b
		or		c
		or		d
		ld		(b_player_want), a; SetPlayerWill(player_will_packed_3_bit)
; end ReadKeys
; end ProcessInput
		ld		hl, game_counter
		ld		a, 1
		add		a, (hl)
		ld		(hl), a
		inc		hl
		ld		a, 0
		adc		a, (hl)
		ld		(hl), a
		inc		hl
		ld		a, 0
		adc		a, (hl)
		ld		(hl), a
; Update()
		ld		a, (game_counter+1)
		cp		3; SLOW DOWN THE GAME
		jp		nz, l_game_cycle_end
;		jp		nc, l_game_update
		
		; call	v_RandomRandomise_0_hl
		call	a_WorkerUpdate_0z; workerUpdate()
		cp		WORKER_STATUS_DIED; workerIsDied()
		jp		nz, l_game_worker_ok
		ld		hl, b_gameEnd
		set		1, (hl)
		
l_game_worker_ok:		
		xor		a; reset the counter
		ld		(game_counter), a
		ld		(game_counter+1), a
		ld		(game_counter+2), a

; l_game_update:
		call	v_GameCheckLastLine_0z; check last line
		call	v_BoxMgrFEUpdate_0z; boxes_Update(), foreach Boxes
		call	a_CraneMgrFEUpdate_0z; crans_Update(), foreach Crane; ret $ff on fail
		cp		$ff
		jp		nz, l_game_crane_ok
		ld		hl, b_gameEnd
		set		2, (hl)
l_game_crane_ok:
;// Update game logic
		; call	v_RandomRandomise_0_hl
		call	v_MapMgrReset_0z
		call	v_WorkerUpdateMap_0_abcdhl
		call	v_CraneMgrFEUpdateMap_0z
		call	v_BoxMgrFEUpdateMap_0z
; Render()
	; render the whole scene to back_buffer
		ld		hl, back_scene
		call	v_CpyBackScn_6_ToPlotSS_hl_bcdehl; render the whole back scene (-6 line) to back_buffer
		call	v_GameDrawScoreToken_0z
		call	v_CraneMgrFERender_0z; foreach cranes
		call	v_BoxMgrFERender_0z; foreach boxes
		call	v_WorkerRender_0z; workerRender()
		b_call	(_GrBufCpy); copy back_buffer to GrpBuff
		
l_game_cycle_end:
		ld		a, (b_gameEnd); while (gameEnd!=true)
		cp		$0
		jp		z, l_game_r_while_loop
		call	v_GameShowGameOver_0z;game over
l_game_r_exit:
	ret

v_GameDone:;TESZT:OK
		b_call	(_RunIndicOn);	Activates the Run Indicator.
	ret

v_GameCheckLastLine_0z:;TESZT:OK
	; last line is full ?
		ld		de, a_maplastline_copy
		call	v_MapMgrCopyLastLine_de_bcdehl
		;search zeros
		ld		hl, a_maplastline_copy
		ld		a, 0
		ld		bc, 10
		cpir
		jp		z, l_game_lline_not_full
		;search the worker
		ld		hl, a_maplastline_copy
		ld		a, 3
		ld		bc, 10
		cpir
		jp		z, l_game_lline_not_full
		;search moving boxes
		ld		hl, a_maplastline_copy
		ld		b, 10
		ld		a, MAPM_TOKEN_BOX_MOVING_BASE-1
l_game_movingbox_loop:
		cp		(hl)
		jp		c, l_game_lline_not_full
		inc		hl
		djnz	l_game_movingbox_loop
	; yes
		;sub MAPM_TOKEN_BOX_STANDING_BASE => boxes to delete
		ld		hl, a_maplastline_copy
		ld		b, 10
l_game_lline_deletebox_loop:
		ld		a, (hl)
		sub		MAPM_TOKEN_BOX_STANDING_BASE
		push	hl
		call	v_BoxMgrDeleteBox_a_dehl; those boxes to delete
		pop		hl
		inc		hl
		djnz	l_game_lline_deletebox_loop
		call	v_MapMgrDelLastLine_de_abcdhl; delete last line in map
		call	v_GameIncreaseScore_0z; Increase score
l_game_lline_not_full:
	ret

a_maplastline_copy:
.block 10

.nolist
#include	"tile.asm"
#include	"sprite.asm"
#include	"random.asm"
#include	"worker.asm"
#include	"box.asm"
#include	"crane.asm"
#include	"mapmgr.asm"
#include	"dataheap.asm"
.list
.end
.end
