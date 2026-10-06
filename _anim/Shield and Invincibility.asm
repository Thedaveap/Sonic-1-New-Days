; ---------------------------------------------------------------------------
; Animation script - shield and invincibility stars
; ---------------------------------------------------------------------------

Ani_Shield:	dc.w .shield-Ani_Shield
		dc.w .stars1-Ani_Shield
		dc.w .stars2-Ani_Shield
		dc.w .stars3-Ani_Shield
		dc.w .stars4-Ani_Shield

.shield:	dc.b 0
		dc.b 6, 1, 6, 2, 6, 3, 6, 4, 6, 5
		dc.b afEnd
		even

.stars1:	dc.b 5
		dc.b 7, 8, 9, $A
		dc.b afEnd
		even

.stars2:	dc.b 0
		dc.b 7, 7, 0, 7, 7, 0, 8, 8, 0, 8, 8, 0
		dc.b 9, 9, 0, 9, 9, 0, $A, $A, 0, $A, $A, 0
		dc.b afEnd
		even

.stars3:	dc.b 0
		dc.b 7, 7, 0, 7, 0, 0, 8, 8, 0, 8, 0, 0
		dc.b 9, 9, 0, 9, 0, 0, $A, $A, 0, $A, 0, 0
		dc.b afEnd
		even

.stars4:	dc.b 0
		dc.b 7, 0, 0, 7, 0, 0, 8, 0, 0, 8, 0, 0
		dc.b 9, 0, 0, 9, 0, 0, $A, 0, 0, $A, 0, 0
		dc.b afEnd
		even
