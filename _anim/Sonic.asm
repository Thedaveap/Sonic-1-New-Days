; ---------------------------------------------------------------------------
; Sonic frame IDs
; ---------------------------------------------------------------------------

; Sonic frame IDs
fr_Null:	equ 0
fr_Stand:	equ 1
fr_Wait1:	equ 2
fr_Wait2:	equ 3
fr_Wait3:	equ 4
fr_LookUp:	equ 5
fr_Walk11:	equ 6
fr_Walk12:	equ 7
fr_Walk13:	equ 8
fr_Walk14:	equ 9
fr_Walk15:	equ $A
fr_Walk16:	equ $B
fr_Walk17:	equ $C	; <-- new
fr_Walk18:	equ $D	; <-- new
fr_Walk21:	equ $E
fr_Walk22:	equ $F
fr_Walk23:	equ $10
fr_Walk24:	equ $11
fr_Walk25:	equ $12
fr_Walk26:	equ $13
fr_Walk27:	equ $14	; <-- new
fr_Walk28:	equ $15	; <-- new
fr_Walk31:	equ $16
fr_Walk32:	equ $17
fr_Walk33:	equ $18
fr_Walk34:	equ $19
fr_Walk35:	equ $1A
fr_Walk36:	equ $1B
fr_Walk37:	equ $1C	; <-- new
fr_Walk38:	equ $1D	; <-- new
fr_Walk41:	equ $1E
fr_Walk42:	equ $1F
fr_Walk43:	equ $20
fr_Walk44:	equ $21
fr_Walk45:	equ $22
fr_Walk46:	equ $23
fr_Walk47:	equ $24	; <-- new
fr_Walk48:	equ $25	; <-- new
fr_Run11:	equ $26	; every frame ID from here on out has been increased by 8 
fr_Run12:	equ $27
fr_Run13:	equ $28
fr_Run14:	equ $29
fr_Run21:	equ $2A
fr_Run22:	equ $2B
fr_Run23:	equ $2C
fr_Run24:	equ $2D
fr_Run31:	equ $2E
fr_Run32:	equ $2F
fr_Run33:	equ $30
fr_Run34:	equ $31
fr_Run41:	equ $32
fr_Run42:	equ $33
fr_Run43:	equ $34
fr_Run44:	equ $35
fr_Roll1:	equ $96
fr_Roll2:	equ $37
fr_Roll3:	equ $38
fr_Roll4:	equ $39
fr_Roll5:	equ $3A
fr_Warp1:	equ $3B
fr_Warp2:	equ $3C
fr_Warp3:	equ $3D
fr_Warp4:	equ $3E
fr_Stop1:	equ $3F
fr_Stop2:	equ $40
fr_Duck:	equ $41
fr_Balance1:	equ $42
fr_Balance2:	equ $43
fr_Float1:	equ $44
fr_Float2:	equ $45
fr_Float3:	equ $46
fr_Float4:	equ $47
fr_Spring:	equ $48
fr_Hang1:	equ $49
fr_Hang2:	equ $4A
fr_Leap1:	equ $4B
fr_Leap2:	equ $4C
fr_Push1:	equ $4D
fr_Push2:	equ $4E
fr_Push3:	equ $4F
fr_Push4:	equ $50
fr_Surf:	equ $51
fr_BubStand:	equ $52
fr_Burnt:	equ $53
fr_Drown:	equ $54
fr_Death:	equ $55
fr_Shrink1:	equ $56
fr_Shrink2:	equ $57
fr_Shrink3:	equ $58
fr_Shrink4:	equ $59
fr_Shrink5:	equ $5A
fr_Float5:	equ $5B
fr_Float6:	equ $5C
fr_Injury:	equ $5D
fr_GetAir:	equ $5E
fr_Slide:	equ $5F ; formerly mamed fr_WaterSlide (was too long...)

; Super Sonic frame IDs
fr_Transform1:		equ fr_Slide+1
fr_Transform2:		equ fr_Transform1+1
fr_Transform3:		equ fr_Transform2+1
fr_Transform4:		equ fr_Transform3+1
fr_Transform5:		equ fr_Transform4+1
fr_SuperStand1:		equ fr_Transform5+1
fr_SuperStand2:		equ fr_SuperStand1+1
fr_SuperStand3:		equ fr_SuperStand2+1
fr_SuperWalk11:		equ fr_SuperStand3+1
fr_SuperWalk12:		equ fr_SuperWalk11+1
fr_SuperWalk13:		equ fr_SuperWalk12+1
fr_SuperWalk14:		equ fr_SuperWalk13+1
fr_SuperWalk15:		equ fr_SuperWalk14+1
fr_SuperWalk16:		equ fr_SuperWalk15+1
fr_SuperRun11:		equ fr_SuperWalk11+(4*6)
fr_SuperRun12:		equ fr_SuperRun11+1
fr_SuperPush1:		equ fr_SuperRun11+(4*2)
fr_SuperPush2:		equ fr_SuperPush1+1
fr_SuperPush3:		equ fr_SuperPush2+1
fr_SuperPush4:		equ fr_SuperPush3+1
fr_SuperDuck:		equ fr_SuperPush4+1
fr_SuperBalance1:	equ fr_SuperDuck+1
fr_SuperBalance2:	equ fr_SuperBalance1+1
fr_SuperBalance3:	equ fr_SuperBalance2+1
fr_SuperBalance4:	equ fr_SuperBalance3+1
fr_SuperBalance5:	equ fr_SuperBalance4+1
fr_SuperBalance6:	equ fr_SuperBalance5+1

; Misc. Sprites
fr_SpinDash1:	equ fr_SuperBalance6+1
fr_SpinDash2:	equ fr_SpinDash1+1
fr_SpinDash3:	equ fr_SpinDash2+1
fr_SpinDash4:	equ fr_SpinDash3+1
fr_SpinDash5:	equ fr_SpinDash4+1
fr_SpinDash6:	equ fr_SpinDash5+1
fr_Victory1:	equ fr_SpinDash6+1
fr_Victory2:	equ fr_Victory1+1
fr_Figure8_11:	equ fr_Victory2+1
fr_Figure8_12:	equ fr_Figure8_11+1
fr_Figure8_13:	equ fr_Figure8_12+1
fr_Figure8_14:	equ fr_Figure8_13+1
fr_Figure8_21:	equ fr_Figure8_14+1
fr_Figure8_22:	equ fr_Figure8_21+1
fr_Figure8_23:	equ fr_Figure8_22+1
fr_Figure8_24:	equ fr_Figure8_23+1
fr_Figure8_31:	equ fr_Figure8_24+1
fr_Figure8_32:	equ fr_Figure8_31+1
fr_Figure8_33:	equ fr_Figure8_32+1
fr_Figure8_34:	equ fr_Figure8_33+1
fr_Figure8_41:	equ fr_Figure8_34+1
fr_Figure8_42:	equ fr_Figure8_41+1
fr_Figure8_43:	equ fr_Figure8_42+1
fr_Figure8_44:	equ fr_Figure8_43+1
fr_Fall1:       equ	fr_Figure8_44+3
fr_Fall2:       equ fr_Fall1+1
fr_Blink:       equ fr_Fall2+1
fr_Dropdash1:	equ	fr_Blink+1
fr_Dropdash2:	equ	fr_Dropdash1+1
fr_Dropdash3:	equ	fr_Dropdash2+1
fr_Dropdash4:	equ	fr_Dropdash3+1
fr_Dropdash5:	equ	fr_Dropdash4+1
fr_Dropdash6:	equ	fr_Dropdash5+1
fr_Dropdash7:	equ	fr_Dropdash6+1
fr_Dropdash8:	equ	fr_Dropdash7+1
fr_DuckTransition:	equ	fr_Dropdash8+1
fr_LookUpTransition:	equ	fr_DuckTransition+1

; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------

; Macro to map an ID to a label while defining the offset table entries
sonani:		macro anim,{INTLABEL}
__LABEL__:	label	(*-Ani_Sonic)/2
		dc.w	anim-Ani_Sonic
		endm
; ---------------------------------------------------------------------------

Ani_Sonic:

id_Walk:	sonani	SonAni_Walk	; $00
id_Run:		sonani	SonAni_Run	; $01
id_Roll:	sonani	SonAni_Roll	; $02
id_Roll2:	sonani	SonAni_Roll2	; $03
id_Push:	sonani	SonAni_Push	; $04
id_Wait:	sonani	SonAni_Wait	; $05
id_BalanceBack:	sonani	SonAni_BalanceBack	; $06
id_BalanceForward:	sonani	SonAni_BalanceForward	; $06
id_LookUp:	sonani	SonAni_LookUp	; $07
id_Duck:	sonani	SonAni_Duck	; $08
id_Warp1:	sonani	SonAni_Warp1	; $09
id_Warp2:	sonani	SonAni_Warp2	; $0A
id_Warp3:	sonani	SonAni_Warp3	; $0B
id_Warp4:	sonani	SonAni_Warp4	; $0C
id_Stop:	sonani	SonAni_Stop	; $0D
id_Float1:	sonani	SonAni_Float1	; $0E
id_Float2:	sonani	SonAni_Float2	; $0F
id_Spring:	sonani	SonAni_Spring	; $10
id_Hang:	sonani	SonAni_Hang	; $11
id_Leap1:	sonani	SonAni_Leap1	; $12
id_Leap2:	sonani	SonAni_Leap2	; $13
id_Surf:	sonani	SonAni_Surf	; $14
id_GetAir:	sonani	SonAni_GetAir	; $15
id_Burnt:	sonani	SonAni_Burnt	; $16
id_Drown:	sonani	SonAni_Drown	; $17
id_Death:	sonani	SonAni_Death	; $18
id_Shrink:	sonani	SonAni_Shrink	; $19
id_Hurt:	sonani	SonAni_Hurt	; $1A
id_Slide:	sonani	SonAni_Slide	; $1B
id_Null:	sonani	SonAni_Null	; $1C
id_Float3:	sonani	SonAni_Float3	; $1D
id_Float4:	sonani	SonAni_Float4	; $1E
id_SpinDash:	sonani	SonAni_SpinDash	; $1F
id_Victory:	sonani	SonAni_Victory	; $20
id_Figure8:	sonani	SonAni_Figure8	; $21
id_Fall:        sonani  SonAni_Fall	; $22

; ---------------------------------------------------------------------------
; --- Special animations (walk/run/roll/push) ---
; Sonic handles animations with a start value of $80 or greater separately.
; All special animations need to have EXACTLY 8 frames (plus one afEnd),
; animations that are too short have extra afEnd to pad to the same length.
; This is because the special animation handler switches between these
; animations without resetting the animation positon.

SonAni_Walk:	dc.b $FF
		dc.b 7, 8, 9, $A, $B, $C, 1, 2, 3, 4, 5, 6
		dc.b afEnd
		even

SonAni_Run:	dc.b $FF
		dc.b $10+$21,  $10+$22,  $10+$23,  $10+$24,  afEnd,     afEnd,  afEnd,     afEnd,  afEnd,     afEnd,  afEnd,     afEnd
		dc.b afEnd 
		even

SonAni_Roll:	dc.b $FE
		dc.b $97,  $F1,  $98,  $F2,  $99,  $F3,  $9A,  $F4,  $96,  afEnd,  afEnd,  afEnd,  afEnd,     afEnd,  afEnd,     afEnd
		dc.b afEnd
		even

SonAni_Roll2:	dc.b $FE
		dc.b $97,  $F1,  $98,  $F2,  $96,  $99,  $F3,  $9A,  $F4,  $96,  afEnd,  afEnd,  afEnd,     afEnd,  afEnd,     afEnd
		dc.b afEnd
		even

SonAni_Push:	dc.b $FD
		dc.b $B6,  $B7,  $B8,  $B9,  afEnd,     afEnd,  afEnd,  afEnd,  afEnd,     afEnd,  afEnd,     afEnd
		dc.b afEnd
		even

SonAni_Figure8:	dc.b $FF
		dc.b $DA, $DB, $DC, $DD, afEnd, afEnd, afEnd, afEnd,  afEnd,     afEnd,  afEnd,     afEnd
		dc.b afEnd
		even

; ---------------------------------------------------------------------------
; --- Normal animations ---
; First byte denotes number of frames between each animation.
; Overview of animation flags (examples):
; 	dc.b afEnd  		; return to beginning of animation
; 	dc.b afBack, 5		; go back specified number of frames
; 	dc.b afChange, id_Surf	; switch to a different animation

SonAni_Wait:	dc.b 5
		dc.b  $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
		dc.b  $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
		dc.b  $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
		dc.b  $BA, $BA, $BA, $BB, $BC, $BC, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD
		dc.b  $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD
		dc.b  $BE, $BE, $BD, $BD, $BE, $BE, $AD, $AD, $AD, $AD, $AD, $AD, $AE, $AE, $AE, $AE
		dc.b  $AE, $AE, $AF, $D9, $D9, $D9, $D9, $D9, $D9, $AF, $AF, $FE, $35
		even

SonAni_BalanceBack:	dc.b 7
		dc.b $A4, $A5, $A6, $FF
		dc.b afEnd
		even

SonAni_BalanceForward:	dc.b 5
		dc.b $A1, $A2, $A3, $FF
		dc.b afEnd
		even

SonAni_LookUp:	dc.b 5
		dc.b $C3, $C4
		dc.b afBack, 1
		even

SonAni_Duck:	dc.b 5
		dc.b $9B, $9C
		dc.b afBack, 1
		even

SonAni_Warp1:	dc.b 63
		dc.b fr_Warp1
		dc.b afEnd
		even

SonAni_Warp2:	dc.b 63
		dc.b fr_Warp2
		dc.b afEnd
		even

SonAni_Warp3:	dc.b 63
		dc.b fr_Warp3
		dc.b afEnd
		even

SonAni_Warp4:	dc.b 63
		dc.b fr_Warp4
		dc.b afEnd
		even

SonAni_Stop:	dc.b 3
		dc.b $9D, $9E, $9F, $A0, $FD,   0
		dc.b afEnd
		even

SonAni_Float1:	dc.b 7
		dc.b $C8, $FF
		dc.b afEnd
		even

SonAni_Float2:	dc.b 7
		dc.b $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF, $FF
		dc.b afEnd
		even

SonAni_Spring:	dc.b 3
                dc.b $EC, $ED, $EE, $EF, $F0
		dc.b $EC, $ED, $EE, $EF, $F0
		dc.b $EC, $ED, $EE, $EF, $F0
		dc.b afChange, id_Walk
		even

SonAni_Hang:	dc.b 1
		dc.b $AA, $AB, $FF
		dc.b afEnd
		even

SonAni_Leap1:	dc.b 15
		dc.b fr_Leap1, fr_Leap1
		dc.b fr_Leap1 ; looped
		dc.b afBack, 1
		even

SonAni_Leap2:	dc.b 15
		dc.b fr_Leap1
		dc.b fr_Leap2 ; looped
		dc.b afBack, 1
		even

SonAni_Surf:	dc.b 63
		dc.b fr_Surf
		dc.b afEnd
		even

SonAni_GetAir:	dc.b $B
		dc.b $AC, $AC,   3,   4, $FD,   0
		dc.b afChange, id_Walk
		even

SonAni_Burnt:	dc.b 32
		dc.b $A8
		dc.b afEnd
		even

SonAni_Drown:	dc.b 47
		dc.b $A9
		dc.b afEnd
		even

SonAni_Death:	dc.b 25
		dc.b $A7,	$A9
		dc.b afBack, 1
		even

SonAni_Shrink:	dc.b 3
		dc.b fr_Shrink1, fr_Shrink2, fr_Shrink3, fr_Shrink4, fr_Shrink5
		dc.b fr_Null ; looped
		dc.b afBack, 1
		even

SonAni_Hurt:	dc.b $40
		dc.b $8D, $FF
		dc.b afEnd
		even

SonAni_Slide:	dc.b 7
		dc.b $8C, $8D, $FF
		dc.b afEnd
		even

SonAni_Null:	dc.b 119
		dc.b fr_Null
		dc.b afChange, id_Walk
		even

SonAni_Float3:	dc.b 3
		dc.b $C8, $CA, $CC, $CD, $CE, $FE,   4
		dc.b afEnd
		even

SonAni_Float4:	dc.b 3
		dc.b $C8
		dc.b afChange, id_Walk
		even

SonAni_SpinDash:
		dc.b 0
		dc.b $86, $87, $86, $88, $86, $89, $86, $8A, $86, $8B
		dc.b afEnd
		even

SonAni_Victory:	dc.b 7
		dc.b $B0, $B2, $B2, $B2, $B2, $B2, $B2, $B1, $B2, $B3, $B2, $FE,   4
		dc.b afEnd
		even

SonAni_Fall:    dc.b 3
		dc.b $EA, $EB
		dc.b afEnd
		even
