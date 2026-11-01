; ===========================================================================
; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

shistar_prev:	equ objoff_32		; previous frame, used to check if graphics need updating

ShieldItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Shi_Index(pc,d0.w),d1
		jmp	Shi_Index(pc,d1.w)
; ===========================================================================
Shi_Index:	dc.w Shi_Main-Shi_Index
		dc.w Shi_Shield-Shi_Index
; ===========================================================================

Shi_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to Shi_Shield
		move.l	#Map_Shield,obMap(a0)			; set shield mappings
		move.b	#sprite_cam_field,obRender(a0)		; set playfield-positioning mode
		move.b	#1,obPriority(a0)			; set sprite priority (above Sonic)
		move.b	#32/2,obActWid(a0)			; set sprite display width
		st.b	shistar_prev(a0)			; make sure initial frame art loads
		move.w	#ArtTile_Shield,obGfx(a0)		; shield-specific art tile
; ===========================================================================

Shi_Shield:	; Routine 2
		tst.b	(v_invinc).w				; has Sonic gained invincibility after already having a shield?
		bne.s	.hide					; if yes, hide shield sprite
		tst.b	(v_shield).w				; has Sonic lost the shield?
		beq.s	.delete					; if yes, delete it

		move.w	(v_player+obX).w,obX(a0)		; keep copying Sonic's X-position
		move.w	(v_player+obY).w,obY(a0)		; keep copying Sonic's Y-position
		move.b	(v_player+obStatus).w,obStatus(a0)	; keep Sonic's status flags for rendering
		lea	(Ani_Shield).l,a1			; load shield animation script
		jsr	(AnimateSprite).l			; keep animating shield
		move.b	obFrame(a0),d0				; load current frame to d0
		cmp.b	shistar_prev(a0),d0			; has it changed?
		beq.s	.display				; if so, branch
		move.b	d0,shistar_prev(a0)			; mark frame's art as loaded
		lea	ShieldStarDynPLC(pc),a2			; load shield/stars DPLCs to a2
		move.l	#Art_Shield,d6				; load uncompressed graphics pointer to d6
		move.w	#ArtTile_Shield*tile_size,d4		; load art tile x $20 to d4 to get VRAM offset
		jsr	(LoadDynPLC).l				; load DPLCs
.display:
		jmp	(DisplaySprite).l			; display shield sprite

	.hide:
		rts						; hide shield sprite but don't delete it

	.delete:
		jmp	(DeleteObject).l			; delete shield object

ShieldStarDynPLC:	include "_maps/Shield - Dynamic Gfx Script.asm"
