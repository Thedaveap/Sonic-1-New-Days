; ---------------------------------------------------------------------------
; Palette index
; ---------------------------------------------------------------------------

makePalEntry:	macro paletteLabel,paletteRAMaddress,{INTLABEL}
__LABEL__:	label	(*-Pal_Index)/8
		dc.l paletteLabel
		dc.w paletteRAMaddress,(paletteLabel_end-paletteLabel)/4-1
		endm
; ---------------------------------------------------------------------------

Pal_Index:

; Id			Palette label,		RAM location
; NOTE: Palette size is calculated dynamically using an end marker made by bincludeEndMarker
palid_SegaBG:		makePalEntry	Pal_SegaBG, 		v_palette_line_1
palid_Title:		makePalEntry	Pal_Title,		v_palette_line_1
palid_LevelSel:		makePalEntry	Pal_LevelSel,		v_palette_line_1
palid_Sonic:		makePalEntry	Pal_Sonic,		v_palette_line_1

	Pal_Levels:
palid_GHZ:		makePalEntry	Pal_GHZ, 		v_palette_line_2
palid_LZ:		makePalEntry	Pal_LZ, 		v_palette_line_2
palid_MZ:		makePalEntry	Pal_MZ, 		v_palette_line_2
palid_SLZ:		makePalEntry	Pal_SLZ,		v_palette_line_2
palid_SYZ:		makePalEntry	Pal_SYZ,		v_palette_line_2
palid_SBZ1:		makePalEntry	Pal_SBZ1, 		v_palette_line_2
	zonewarning Pal_Levels,8

palid_Special:		makePalEntry	Pal_Special, 		v_palette_line_1
palid_LZWater:		makePalEntry	Pal_LZWater, 		v_palette_line_1
palid_SBZ3:		makePalEntry	Pal_SBZ3, 		v_palette_line_2
palid_SBZ3Water:	makePalEntry	Pal_SBZ3Water, 		v_palette_line_1
palid_SBZ2:		makePalEntry	Pal_SBZ2, 		v_palette_line_2
palid_LZSonWater:	makePalEntry	Pal_LZSonWater,		v_palette_line_1
palid_SBZ3SonWat:	makePalEntry	Pal_SBZ3SonWat,		v_palette_line_1
palid_SSResult:		makePalEntry	Pal_SSResult, 		v_palette_line_1
palid_Continue:		makePalEntry	Pal_Continue, 		v_palette_line_1
palid_Ending:		makePalEntry	Pal_Ending, 		v_palette_line_1
palid_Menu:		makePalEntry	Pal_Menu,		v_palette_line_1
palid_GHZ2:		makePalEntry	Pal_GHZ2, 		v_palette_line_2
palid_GHZ3:		makePalEntry	Pal_GHZ3, 		v_palette_line_2
palid_MZ2:		makePalEntry	Pal_MZ2, 		v_palette_line_2
palid_MZ3:		makePalEntry	Pal_MZ3, 		v_palette_line_2
palid_SYZ2:		makePalEntry	Pal_SYZ2, 		v_palette_line_2
palid_SYZ3:		makePalEntry	Pal_SYZ3, 		v_palette_line_2
palid_SLZ2:		makePalEntry	Pal_SLZ2, 		v_palette_line_2
palid_SLZ3:		makePalEntry	Pal_SLZ3, 		v_palette_line_2
palid_LZ2:		makePalEntry	Pal_LZ2, 		v_palette_line_2
palid_LZ3:		makePalEntry	Pal_LZ3, 		v_palette_line_2
	even


; ===========================================================================
; ---------------------------------------------------------------------------
; Palette data bincludes
; ---------------------------------------------------------------------------

Pal_SegaBG:		bincludeEndMarker	"palette/Sega Background.bin"
Pal_Title:		bincludeEndMarker	"palette/Title Screen.bin"
Pal_LevelSel:		bincludeEndMarker	"palette/Level Select.bin"
Pal_Sonic:		bincludeEndMarker	"palette/Sonic.bin"
Pal_GHZ:		bincludeEndMarker	"palette/Green Hill Zone.bin"
Pal_LZ:			bincludeEndMarker	"palette/Labyrinth Zone.bin"
Pal_LZWater:		bincludeEndMarker	"palette/Labyrinth Zone Underwater.bin"
Pal_MZ:			bincludeEndMarker	"palette/Marble Zone.bin"
Pal_SLZ:		bincludeEndMarker	"palette/Star Light Zone.bin"
Pal_SYZ:		bincludeEndMarker	"palette/Spring Yard Zone.bin"
Pal_SBZ1:		bincludeEndMarker	"palette/SBZ Act 1.bin"
Pal_SBZ2:		bincludeEndMarker	"palette/SBZ Act 2.bin"
Pal_Special:		bincludeEndMarker	"palette/Special Stage.bin"
Pal_SBZ3:		bincludeEndMarker	"palette/SBZ Act 3.bin"
Pal_SBZ3Water:		bincludeEndMarker	"palette/SBZ Act 3 Underwater.bin"
Pal_LZSonWater:		bincludeEndMarker	"palette/Sonic - LZ Underwater.bin"
Pal_SBZ3SonWat:		bincludeEndMarker	"palette/Sonic - SBZ3 Underwater.bin"
Pal_SSResult:		bincludeEndMarker	"palette/Special Stage Results.bin"
Pal_Continue:		bincludeEndMarker	"palette/Special Stage Continue Bonus.bin"
Pal_Ending:		bincludeEndMarker	"palette/Ending.bin"
Pal_Menu:		bincludeEndMarker	"palette/Menu.bin"
Pal_LevelSelectIcons:	bincludeEndMarker	"palette/Level Select Icons.bin"
Pal_GHZ2:		bincludeEndMarker	"palette/ghz2.bin"
Pal_GHZ3:		bincludeEndMarker	"palette/ghz3.bin"
Pal_MZ2:			bincludeEndMarker	"palette/Marble Zone Act 2.bin"
Pal_MZ3:			bincludeEndMarker	"palette/Marble Zone Act 3.bin"
Pal_SYZ2:		bincludeEndMarker	"palette/Spring Yard Zone Act 2.bin"
Pal_SYZ3:		bincludeEndMarker	"palette/Spring Yard Zone Act 3.bin"
Pal_SLZ2:		bincludeEndMarker	"palette/Star Light Zone Act 2.bin"
Pal_SLZ3:		bincludeEndMarker	"palette/Star Light Zone Act 3.bin"
Pal_LZ2:			bincludeEndMarker	"palette/Labyrinth Zone Act 2.bin"
Pal_LZ3:			bincludeEndMarker	"palette/Labyrinth Zone Act 3.bin"
