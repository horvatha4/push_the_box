;***************************************
;************** RANDOM *****************
;***************************************
; Remark #3: The Ti83+ haven´t any random number generator.
; Remark #4: I try a couple routins, but the reason why I use 
; simply two random mixed table is: if the cranes carry
; 2 or more box at the same place one after another, you lose 
; the control and shortly the game, then your mood even its only 6 cranes!
; I reach 60 to 80 and one time 130 points as a maximum.

b_random_seed:
.db 12

; 0-7 numbers in randomly order for box textures
a_box_tex_nums:
.db 1,6,0,1,7,2,3,2,0,6,5,3,7,3,7,5,1,6,5,7,4,0,7,0,4,0,4,6,3,5,4,2
.db 1,5,6,7,4,0,7,5,6,7,3,0,6,2,3,1,7,2,7,1,4,0,2,7,6,2,3,0,2,1,6,4
.db 5,2,0,2,0,4,0,4,1,6,0,4,1,5,3,1,7,1,0,3,7,6,0,6,4,1,7,1,6,4,3,2
.db 3,1,5,6,5,6,7,0,5,1,4,7,5,6,0,4,3,7,3,6,3,6,2,4,5,4,7,1,5,7,4,0
.db 7,4,7,4,0,5,4,2,1,3,4,6,5,6,5,6,5,3,7,1,5,2,1,0,2,7,3,1,5,7,3,4
.db 3,4,2,4,0,7,5,2,6,2,6,7,6,0,5,3,4,2,7,6,2,0,3,6,1,3,1,0,3,4,2,4
.db 3,1,5,6,4,3,1,2,6,2,3,1,7,2,7,5,0,1,7,2,1,5,0,5,3,1,2,3,5,2,0,2
.db 1,2,4,3,2,5,4,5,1,6,0,5,0,3,7,3,1,5,5,1,4,2,0,3,6,0,6,7,0,2,6,4

; 0-9 numbers in randomly order for box destinations
a_box_dest_nums:
.db 7,3,1,6,0,9,4,2,5,8,3,1,6,7,3,1,6,0,9,4,2,5,8,3,1,6,3,4,1,5,9,4
.db 0,9,4,7,2,5,8,3,4,1,5,8,6,2,7,5,3,6,4,8,6,2,7,5,3,6,4,0,7,2,5,8
.db 7,3,1,6,0,9,4,1,6,0,9,4,7,2,5,8,3,4,1,5,8,2,5,8,3,1,6,0,9,1,5,8
.db 7,3,1,6,0,9,4,2,5,8,3,6,2,7,5,3,6,4,4,7,2,5,8,3,4,6,2,7,5,3,6,4
.db 7,3,1,6,0,9,4,2,5,8,3,1,6,7,3,1,6,0,9,4,2,5,8,3,1,6,3,4,1,5,9,4
.db 0,9,4,7,2,5,8,3,4,1,5,8,6,2,7,5,3,6,4,8,6,2,7,5,3,6,4,0,7,2,5,8
.db 7,3,1,6,0,9,4,1,6,0,9,4,7,2,5,8,3,4,1,5,8,2,5,8,3,1,6,0,9,1,5,8
.db 7,3,1,6,0,9,4,2,5,8,3,6,2,7,5,3,6,4,4,7,2,5,8,3,4,6,2,7,5,3,6,4

b_box_tex_pointer:
.db $ff
b_box_dest_pointer:
.db $ff

v_RandomInit_0_ahl:
		ld		hl, b_box_tex_pointer
		ld		a, r
		ld		(hl), a
		ld		hl, b_box_dest_pointer
		ld		a, r
		ld		(hl), a
	ret

a_RandomGetText_0_adehl:
		ld		hl, b_box_tex_pointer
		ld		a, (hl)
		inc		(hl)
		ld		e, a
		ld		d, 0
		ld		hl, a_box_tex_nums
		add		hl, de
		ld		a, (hl)
	ret

a_RandomGetDest_0_adehl:
		ld		hl, b_box_dest_pointer
		ld		a, (hl)
		inc		(hl)
		ld		e, a
		ld		d, 0
		ld		hl, a_box_dest_nums
		add		hl, de
		ld		a, (hl)
	ret
		
; v_RandomRandomise_0_hl:
		; ld		a, r; get a random nummer
		; ld		hl, b_random_seed
		; add		a, (hl); add the old value
		; ld		(hl), a; store the new
	; ret
