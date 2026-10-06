; --------------------------------------------------------------------------------
; Sprite mappings - output from ClownMapEd - MapMacros format
; --------------------------------------------------------------------------------

.offsets:	mappingsTable
	mappingsTableEntry.w	.frame0
	mappingsTableEntry.w	.frame1
	mappingsTableEntry.w	.frame2
	mappingsTableEntry.w	.frame3
	mappingsTableEntry.w	.frame4
	mappingsTableEntry.w	.frame5
	mappingsTableEntry.w	.frame6
	mappingsTableEntry.w	.frame7
	mappingsTableEntry.w	.frame8
	mappingsTableEntry.w	.frame9
	mappingsTableEntry.w	.frame10
	mappingsTableEntry.w	.frame11
	mappingsTableEntry.w	.frame12

.frame0:	spriteHeader
	spritePiece -16, -24, 4, 1, 0, 0, 0, 0, 0
.frame0_End

.frame1:	spriteHeader
	spritePiece -24, -24, 3, 2, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 2, 0, 1, 0, 0, 0
.frame1_End

.frame2:	spriteHeader
	spritePiece -24, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 3, 0, 1, 0, 0, 0
.frame2_End

.frame3:	spriteHeader
	spritePiece -24, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 3, 0, 1, 0, 0, 0
.frame3_End

.frame4:	spriteHeader
	spritePiece -24, -16, 3, 4, 0, 0, 0, 0, 0
	spritePiece 0, -16, 3, 4, 0, 1, 0, 0, 0
.frame4_End

.frame5:	spriteHeader
	spritePiece -24, 0, 3, 3, 0, 0, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 1, 1, 0, 0
.frame5_End

.frame6:	spriteHeader
	spritePiece -24, 0, 3, 3, 0, 0, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 1, 1, 0, 0
.frame6_End

.frame7:	spriteHeader
	spritePiece -24, 8, 3, 2, 0, 0, 1, 0, 0
	spritePiece 0, 8, 3, 2, 0, 1, 1, 0, 0
.frame7_End

.frame8:	spriteHeader
	spritePiece -16, 16, 2, 1, 0, 0, 1, 0, 0
	spritePiece 0, 16, 2, 1, 0, 1, 1, 0, 0
.frame8_End

.frame9:	spriteHeader
	spritePiece -24, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 3, 9, 0, 0, 0, 0
	spritePiece -24, 0, 3, 3, 0, 0, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 1, 1, 0, 0
.frame9_End

.frame10:	spriteHeader
	spritePiece -24, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 3, 9, 0, 0, 0, 0
	spritePiece -24, 0, 3, 3, 0, 0, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 1, 1, 0, 0
.frame10_End

.frame11:	spriteHeader
	spritePiece -28, -20, 4, 2, 0, 0, 0, 0, 0
	spritePiece 4, -20, 3, 2, 8, 0, 0, 0, 0
	spritePiece -28, -4, 4, 3, 14, 0, 0, 0, 0
	spritePiece 4, -4, 3, 3, 14, 1, 0, 0, 0
.frame11_End

.frame12:	spriteHeader
	spritePiece -36, -16, 4, 4, 0, 0, 0, 0, 0
	spritePiece -4, -16, 1, 4, 16, 0, 0, 0, 0
	spritePiece 4, -16, 4, 4, 20, 0, 0, 0, 0
.frame12_End

	even
