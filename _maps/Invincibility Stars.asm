; ---------------------------------------------------------------------------
; Sprite mappings - invincibility stars
; ---------------------------------------------------------------------------
Map_InvStars_internal: mappingsTable
	mappingsTableEntry.w	.stars0
	mappingsTableEntry.w	.stars1
	mappingsTableEntry.w	.stars2
	mappingsTableEntry.w	.stars3
	mappingsTableEntry.w	.stars4
	mappingsTableEntry.w	.stars5
	mappingsTableEntry.w	.stars6
	mappingsTableEntry.w	.stars7
	mappingsTableEntry.w	.stars8

.stars0:	spriteHeader
.stars0_End

.stars1:	spriteHeader
 spritePiece -4, -8, 1, 2, 0, 0, 0, 0, 0
.stars1_End

.stars2:	spriteHeader
 spritePiece -4, -8, 1, 2, 2, 0, 0, 0, 0
.stars2_End

.stars3:	spriteHeader
 spritePiece -4, -8, 1, 2, 4, 0, 0, 0, 0
.stars3_End

.stars4:	spriteHeader
 spritePiece -4, -8, 1, 2, 6, 0, 0, 0, 0
.stars4_End

.stars5:	spriteHeader
 spritePiece -4, -8, 1, 2, 8, 0, 0, 0, 0
.stars5_End

.stars6:	spriteHeader
 spritePiece -8, -8, 2, 2, $A, 0, 0, 0, 0
.stars6_End

.stars7:	spriteHeader
 spritePiece -8, -8, 2, 2, $E, 0, 0, 0, 0
.stars7_End

.stars8:	spriteHeader
 spritePiece -$10, -$10, 4, 4, $12, 0, 0, 0, 0
.stars8_End

	even