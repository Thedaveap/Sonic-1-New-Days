; ---------------------------------------------------------------------------
; Object 04 - Super Sonic's star
; ---------------------------------------------------------------------------

SuperSonicStar:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SuperSonicStar_Index(pc,d0.w),d1
		jmp	SuperSonicStar_Index(pc,d1.w)
; ===========================================================================
SuperSonicStar_Index:
		dc.w	SuperSonicStar_Init-SuperSonicStar_Index
		dc.w	SuperSonicStar_Main-SuperSonicStar_Index
; ===========================================================================
sstar_active:	equ objoff_30
; ===========================================================================

SuperSonicStar_Init:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_SuperSonicStar,obMap(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.w	#make_art_tile(ArtTile_SuperSonicStar,0,0),obGfx(a0)
		move.l	#Art_SuperSonicStar,d1			; set source adress
		move.w	#ArtTile_SuperSonicStar*tile_size,d2	; set destination
		move.w	#Art_SuperSonicStarend-Art_SuperSonicStar,d3	; set length (in bytes)
		jsr	(QueueDMATransfer).l			; load art

SuperSonicStar_Main:	; Routine 2
		tst.b	(v_supersonic).w	; is Sonic Super?
		beq.w	.delete			; if not, delete

		tst.b	sstar_active(a0)	; is the star currently animating?
		beq.s	.chkdisplay		; if not, check trigger conditions

		subq.b	#1,obTimeFrame(a0)	; count down frame timer
		bpl.s	.display		; still on this frame, display
		move.b	#1,obTimeFrame(a0)	; reset timer
		addq.b	#1,obFrame(a0)		; advance to next frame
		cmpi.b	#6,obFrame(a0)		; past the last frame?
		blo.s	.display
		move.b	#0,obFrame(a0)		; reset frame
		move.b	#0,sstar_active(a0)	; stop animating
		rts
; ===========================================================================

.chkdisplay:
		tst.b	(f_playerctrl).w	; are Sonic's controls locked?
		bne.s	.hide
		move.w	(v_player+obInertia).w,d0
		bpl.s	.positive
		neg.w	d0
.positive:
		cmpi.w	#$800,d0		; is Sonic moving fast enough?
		blo.s	.hide
		move.b	#0,obFrame(a0)		; reset to first frame
		move.b	#1,sstar_active(a0)	; start animating
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)

.display:
		bra.w	DisplaySprite

.hide:
		rts
; ===========================================================================

.delete:
		bra.w	DeleteObject
; End of function SuperSonicStar