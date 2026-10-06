; ---------------------------------------------------------------------------
; Sprite mappings - Title screen menu that replaces "PRESS START BUTTON"
; ---------------------------------------------------------------------------

Map_PSBMenu_internal:	mappingsTable
	mappingsTableEntry.w	.selection0
	mappingsTableEntry.w	.selection1
	mappingsTableEntry.w	.selection2
	mappingsTableEntry.w	.selection3

.selection0:	spriteHeader	; START GAME
	spritePiece	$0C, $00-8, 1, 1, $00, 0, 0, 1, 0

	spritePiece	$1C, $00-8, 4, 1, $01, 0, 0, 1, 0
	spritePiece	$3C, $00-8, 4, 1, $05, 0, 0, 1, 0
	spritePiece	$5C, $00-8, 4, 1, $09, 0, 0, 1, 0
	spritePiece	$7C, $00-8, 4, 1, $0D, 0, 0, 1, 0

	spritePiece	$1C, $0C-8, 4, 1, $11, 0, 0, 2, 0
	spritePiece	$3C, $0C-8, 4, 1, $15, 0, 0, 2, 0
	spritePiece	$5C, $0C-8, 4, 1, $19, 0, 0, 2, 0
	spritePiece	$7C, $0C-8, 4, 1, $1D, 0, 0, 2, 0

	spritePiece	$1C, $18-8, 4, 1, $21, 0, 0, 2, 0
	spritePiece	$3C, $18-8, 4, 1, $25, 0, 0, 2, 0
	spritePiece	$5C, $18-8, 4, 1, $29, 0, 0, 2, 0
	spritePiece	$7C, $18-8, 4, 1, $2D, 0, 0, 2, 0

	spritePiece	$1C, ($18+$0C)-8, 4, 1, $31, 0, 0, 2, 0
	spritePiece	$3C, ($18+$0C)-8, 4, 1, $35, 0, 0, 2, 0
	spritePiece	$5C, ($18+$0C)-8, 4, 1, $39, 0, 0, 2, 0
	spritePiece	$7C, ($18+$0C)-8, 4, 1, $3D, 0, 0, 2, 0
.selection0_End

.selection1:	spriteHeader	; LEVEL SELECT
	spritePiece	$0C, $0C-8, 1, 1, $00, 0, 0, 1, 0

	spritePiece	$1C, $00-8, 4, 1, $01, 0, 0, 2, 0
	spritePiece	$3C, $00-8, 4, 1, $05, 0, 0, 2, 0
	spritePiece	$5C, $00-8, 4, 1, $09, 0, 0, 2, 0
	spritePiece	$7C, $00-8, 4, 1, $0D, 0, 0, 2, 0

	spritePiece	$1C, $0C-8, 4, 1, $11, 0, 0, 1, 0
	spritePiece	$3C, $0C-8, 4, 1, $15, 0, 0, 1, 0
	spritePiece	$5C, $0C-8, 4, 1, $19, 0, 0, 1, 0
	spritePiece	$7C, $0C-8, 4, 1, $1D, 0, 0, 1, 0

	spritePiece	$1C, $18-8, 4, 1, $21, 0, 0, 2, 0
	spritePiece	$3C, $18-8, 4, 1, $25, 0, 0, 2, 0
	spritePiece	$5C, $18-8, 4, 1, $29, 0, 0, 2, 0
	spritePiece	$7C, $18-8, 4, 1, $2D, 0, 0, 2, 0

	spritePiece	$1C, ($18+$0C)-8, 4, 1, $31, 0, 0, 2, 0
	spritePiece	$3C, ($18+$0C)-8, 4, 1, $35, 0, 0, 2, 0
	spritePiece	$5C, ($18+$0C)-8, 4, 1, $39, 0, 0, 2, 0
	spritePiece	$7C, ($18+$0C)-8, 4, 1, $3D, 0, 0, 2, 0
.selection1_End

.selection2:	spriteHeader	; CREDITS
	spritePiece	$0C, $18-8, 1, 1, $00, 0, 0, 1, 0

	spritePiece	$1C, $00-8, 4, 1, $01, 0, 0, 2, 0
	spritePiece	$3C, $00-8, 4, 1, $05, 0, 0, 2, 0
	spritePiece	$5C, $00-8, 4, 1, $09, 0, 0, 2, 0
	spritePiece	$7C, $00-8, 4, 1, $0D, 0, 0, 2, 0

	spritePiece	$1C, $0C-8, 4, 1, $11, 0, 0, 2, 0
	spritePiece	$3C, $0C-8, 4, 1, $15, 0, 0, 2, 0
	spritePiece	$5C, $0C-8, 4, 1, $19, 0, 0, 2, 0
	spritePiece	$7C, $0C-8, 4, 1, $1D, 0, 0, 2, 0

	spritePiece	$1C, $18-8, 4, 1, $21, 0, 0, 1, 0
	spritePiece	$3C, $18-8, 4, 1, $25, 0, 0, 1, 0
	spritePiece	$5C, $18-8, 4, 1, $29, 0, 0, 1, 0
	spritePiece	$7C, $18-8, 4, 1, $2D, 0, 0, 1, 0

	spritePiece	$1C, ($18+$0C)-8, 4, 1, $31, 0, 0, 2, 0
	spritePiece	$3C, ($18+$0C)-8, 4, 1, $35, 0, 0, 2, 0
	spritePiece	$5C, ($18+$0C)-8, 4, 1, $39, 0, 0, 2, 0
	spritePiece	$7C, ($18+$0C)-8, 4, 1, $3D, 0, 0, 2, 0
.selection2_End

.selection3:	spriteHeader	; CREDITS
	spritePiece	$0C, ($18+$0C)-8, 1, 1, $00, 0, 0, 1, 0

	spritePiece	$1C, $00-8, 4, 1, $01, 0, 0, 2, 0
	spritePiece	$3C, $00-8, 4, 1, $05, 0, 0, 2, 0
	spritePiece	$5C, $00-8, 4, 1, $09, 0, 0, 2, 0
	spritePiece	$7C, $00-8, 4, 1, $0D, 0, 0, 2, 0

	spritePiece	$1C, $0C-8, 4, 1, $11, 0, 0, 2, 0
	spritePiece	$3C, $0C-8, 4, 1, $15, 0, 0, 2, 0
	spritePiece	$5C, $0C-8, 4, 1, $19, 0, 0, 2, 0
	spritePiece	$7C, $0C-8, 4, 1, $1D, 0, 0, 2, 0

	spritePiece	$1C, $18-8, 4, 1, $21, 0, 0, 2, 0
	spritePiece	$3C, $18-8, 4, 1, $25, 0, 0, 2, 0
	spritePiece	$5C, $18-8, 4, 1, $29, 0, 0, 2, 0
	spritePiece	$7C, $18-8, 4, 1, $2D, 0, 0, 2, 0

	spritePiece	$1C, ($18+$0C)-8, 4, 1, $31, 0, 0, 1, 0
	spritePiece	$3C, ($18+$0C)-8, 4, 1, $35, 0, 0, 1, 0
	spritePiece	$5C, ($18+$0C)-8, 4, 1, $39, 0, 0, 1, 0
	spritePiece	$7C, ($18+$0C)-8, 4, 1, $3D, 0, 0, 1, 0
.selection3_End
	even