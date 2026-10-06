; ===========================================================================
; ---------------------------------------------------------------------------
; Object 02 - Fire FireShield
; ---------------------------------------------------------------------------

FireShistar_prev:	equ objoff_32		; previous frame, used to check if graphics need updating

FireShield:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	FireShi_Index(pc,d0.w),d1
		jmp	FireShi_Index(pc,d1.w)
; ===========================================================================
FireShi_Index:	dc.w FireShi_Main-FireShi_Index
		dc.w FireShi_FireShield-FireShi_Index

; ===========================================================================

FireShi_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to FireShi_FireFireShield
		move.l	#Map_FireShield,obMap(a0)			; set FireFireShield mappings
		move.b	#sprite_cam_field,obRender(a0)		; set playfield-positioning mode
		move.b	#1,obPriority(a0)			; set sprite priority (above Sonic)
		move.b	#32/2,obActWid(a0)			; set sprite display width
		st.b	FireShistar_prev(a0)			; make sure initial frame art loads

; ===========================================================================

FireShi_FireShield:	; Routine 2
		tst.b	(v_invinc).w				; has Sonic gained invincibility after already having a FireFireShield?
		bne.s	.hide					; if yes, hide FireFireShield sprite
		btst	#Status_FireShield,(v_shieldtype).w				; has Sonic lost the Fire Shield?
		beq.s	.delete					; if yes, delete it

		move.w	(v_player+obX).w,obX(a0)		; keep copying Sonic's X-position
		move.w	(v_player+obY).w,obY(a0)		; keep copying Sonic's Y-position
		move.b	(v_player+obStatus).w,obStatus(a0)	; keep Sonic's status flags for rendering
		lea	(Ani_FireShield).l,a1			; load FireFireShield animation script
		jsr	(AnimateSprite).l			; keep animating FireFireShield
		move.b	obFrame(a0),d0				; load current frame to d0
		cmp.b	FireShistar_prev(a0),d0			; has it changed?
		beq.s	.display				; if so, branch
		move.b	d0,FireShistar_prev(a0)			; mark frame's art as loaded
		lea	FireShieldDynPLC(pc),a2			; load FireFireShield/stars DPLCs to a2
		move.l	#Art_FireShield,d6				; load uncompressed graphics pointer to d6
		move.w	#ArtTile_Shield*tile_size,d4		; load art tile x $20 to d4 to get VRAM offset
		jsr	(LoadDynPLC).l				; load DPLCs
.display:
		jmp	(DisplaySprite).l			; display FireFireShield sprite

	.hide:
		rts						; hide FireFireShield sprite but don't delete it

	.delete:
		jmp	(DeleteObject).l			; delete FireFireShield object
; ===========================================================================

FireShi_Start_Delete:
		jmp	(DeleteObject).l			; delete invincibility stars object

FireShieldDynPLC:	include "_maps/Fire Shield - Dynamic Gfx Script.asm"
