; ---------------------------------------------------------------------------
; Animation script - Super Sonic
; ---------------------------------------------------------------------------
Ani_SuperSonic:
		dc.w SupSonAni_Walk-Ani_SuperSonic
		dc.w SupSonAni_Run-Ani_SuperSonic
		dc.w SonAni_Roll-Ani_SuperSonic
		dc.w SonAni_Roll2-Ani_SuperSonic
		dc.w SupSonAni_Push-Ani_SuperSonic
		dc.w SupSonAni_Stand-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SonAni_LookUp-Ani_SuperSonic
		dc.w SupSonAni_Duck-Ani_SuperSonic
		dc.w SonAni_Warp1-Ani_SuperSonic
		dc.w SonAni_Warp2-Ani_SuperSonic
		dc.w SonAni_Warp3-Ani_SuperSonic
		dc.w SonAni_Warp4-Ani_SuperSonic
		dc.w SonAni_Stop-Ani_SuperSonic
		dc.w SonAni_Float1-Ani_SuperSonic
		dc.w SonAni_Float2-Ani_SuperSonic
		dc.w SonAni_Spring-Ani_SuperSonic
		dc.w SonAni_Hang-Ani_SuperSonic
		dc.w SonAni_Leap1-Ani_SuperSonic
		dc.w SonAni_Leap2-Ani_SuperSonic
		dc.w SonAni_Surf-Ani_SuperSonic
		dc.w SonAni_GetAir-Ani_SuperSonic
		dc.w SonAni_Burnt-Ani_SuperSonic
		dc.w SonAni_Drown-Ani_SuperSonic
		dc.w SonAni_Death-Ani_SuperSonic
		dc.w SonAni_Shrink-Ani_SuperSonic
		dc.w SonAni_Hurt-Ani_SuperSonic
		dc.w SonAni_Slide-Ani_SuperSonic
		dc.w SonAni_Null-Ani_SuperSonic
		dc.w SonAni_Float3-Ani_SuperSonic
		dc.w SonAni_Float4-Ani_SuperSonic
		dc.w SonAni_SpinDash-Ani_SuperSonic
		dc.w SonAni_Figure8-Ani_SuperSonic
		dc.w SonAni_Victory-Ani_SuperSonic
		dc.w SonAni_Transform-Ani_SuperSonic
		dc.w SonAni_Fall-Ani_SuperSonic
		dc.w SonAni_SpringJump-Ani_SuperSonic
		dc.w SonAni_DropDash-Ani_SuperSonic

SupSonAni_Walk:		dc.b $FF, fr_SuperWalk13, fr_SuperWalk14, fr_SuperWalk15, fr_SuperWalk16, fr_SuperWalk11, fr_SuperWalk12, afEnd
		even
SupSonAni_Run:		dc.b $FF, fr_SuperRun11,  fr_SuperRun12, afEnd, afEnd, afEnd, afEnd, afEnd
		even
SupSonAni_Push:		dc.b $FD, fr_SuperPush1, fr_SuperPush2, fr_SuperPush3, fr_SuperPush4, afEnd, afEnd, afEnd
		even
SupSonAni_Stand:	dc.b   7, fr_SuperStand1, fr_SuperStand2, fr_SuperStand3, fr_SuperStand2, afEnd
		even
SupSonAni_Balance:	dc.b   9, fr_SuperBalance1, fr_SuperBalance2, fr_SuperBalance3, fr_SuperBalance2, fr_SuperBalance4, fr_SuperBalance5, fr_SuperBalance6, fr_SuperBalance5, afEnd
		even
SupSonAni_Duck:		dc.b   5, fr_SuperDuck, afEnd
		even