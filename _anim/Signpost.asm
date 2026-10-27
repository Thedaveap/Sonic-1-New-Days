; ---------------------------------------------------------------------------
; Animation script - signpost
; ---------------------------------------------------------------------------
Ani_Sign:	dc.w .eggman-Ani_Sign
		dc.w .spin1-Ani_Sign
		dc.w .spin2-Ani_Sign
		dc.w .sonic-Ani_Sign
.eggman:	dc.b $F, 0, afEnd
		even
.spin1:		dc.b 1,	0, 1, 2, 3, afEnd
.spin2:		dc.b 1,	4, 1, 2, 3, afEnd
.sonic:		dc.b $2, 4, 4, 4, 4, 4, 5, 6, 7, 8, 7, 6, 5, 4, afBack, 1
		even