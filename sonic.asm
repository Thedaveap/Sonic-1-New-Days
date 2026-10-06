;  =========================================================================
; |           Sonic the Hedgehog Disassembly for Sega Mega Drive            |
;  =========================================================================
;
; Disassembly created by Hivebrain
; thanks to drx, Stealth and Esrael L.G. Neto
; ---------------------------------------------------------------------------
; NOTE:
; Set your editor's tab width to 8 characters wide for viewing this file.

; ===========================================================================
; ASSEMBLY OPTIONS:

Revision = 1
; 	| If 0, build the original version of the game, dubbed REV00
; 	| If 1, build the later version, dubbed REV01, which includes various bugfixes and enhancements
; 	| If 2, build the hacked version from Sonic Mega Collection, dubbed REVXB,
;	|       which (sloppily) fixes the infamous "spike bug" -- not recommended

FixBugs = 1
;	| If 1, enables various bugfixes across the game and sound driver
;	|       (see also the "_Fixed Binary Files" folder, and FixMusicAndSFXDataBugs)

CheatsEnabled = 0
;	| If 1, all in-game cheats (Level Select, Debug Mode, Slow-Motion, Japanese Credits)
;	|       will be enabled by default, without requiring any title screen button inputs

AllOptimizations = 0
;	| If 1, enables all optimizations
SkipChecksumCheck = 0|AllOptimizations
;	| If 1, disables the slow bootup checksum calculation
ZeroOffsetOptimization = 0|AllOptimizations
;	| If 1, makes a handful of zero-offset instructions smaller
PaddingOptimization = 0|AllOptimizations
;	| If 1, removes about 3 KB of various superfluous padding

EnableSRAM = 0
;	| If 1, enable SRAM support
BackupSRAM = 1
;	| 0 = no saving (read-only SRAM); 1 = allow saving
AddressSRAM = 3
;	| 0 = odd+even; 2 = even only; 3 = odd only
;	| (odd only is the most common setting)

ZoneCount = 6
;	| Used for the "zonewarning" macro. Do not change, unless more zones get added.
;	| Discrete zones are: GHZ, LZ, MZ, SLZ, SYZ, and SBZ

; ===========================================================================
; AS-specific macros and assembler settings
	cpu 68000
	include "MacroSetup.asm"

; ===========================================================================
; Simplifying macros and functions
	include	"Macros.asm"

; ===========================================================================
; Equates section - Names for constants
	include	"_Constants.asm"

; ===========================================================================
; Equates section - Names for variables
	include	"_Variables.asm"

; ===========================================================================
; Expressing sprite mappings and DPLCs in a portable and human-readable form
SonicMappingsVer = 1
SonicDplcVer = 1
	include	"_maps/_MapMacros.asm"

; ===========================================================================
; start of ROM

; MD Debugger and Error Handler macros
	include	"Debugger.asm"

;__DEBUG__: equ "DEB"
; 	| Comment this in to enable extra debugging tools ("KDebug" and "assert").
; 	| If commented out, extra tools are disabled to avoid performance penalties.

StartOfRom:
	if * <> 0
		fatal "StartOfRom was $\{*} but it should be 0"
	endif

Vectors:
		dc.l v_systemstack&$FFFFFF			; Initial stack pointer value
		dc.l EntryPoint					; Start of program
		dc.l BusError					; Bus error
		dc.l AddressError				; Address error (4)
		dc.l IllegalInstr				; Illegal instruction
		dc.l ZeroDivide					; Division by zero
		dc.l ChkInstr					; CHK exception
		dc.l TrapvInstr					; TRAPV exception (8)
		dc.l PrivilegeViol				; Privilege violation
		dc.l Trace					; TRACE exception
		dc.l Line1010Emu				; Line-A emulator
		dc.l Line1111Emu				; Line-F emulator (12)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (16)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (20)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (24)
		dc.l ErrorExcept				; Spurious exception
		dc.l ErrorTrap					; IRQ level 1
		dc.l ErrorTrap					; IRQ level 2
		dc.l ErrorTrap					; IRQ level 3 (28)
		dc.l HBlank					; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap					; IRQ level 5
		dc.l VBlank					; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap					; IRQ level 7 (32)
		dc.l ErrorTrap					; TRAP #00 exception
		dc.l ErrorTrap					; TRAP #01 exception
		dc.l ErrorTrap					; TRAP #02 exception
		dc.l ErrorTrap					; TRAP #03 exception (36)
		dc.l ErrorTrap					; TRAP #04 exception
		dc.l ErrorTrap					; TRAP #05 exception
		dc.l ErrorTrap					; TRAP #06 exception
		dc.l ErrorTrap					; TRAP #07 exception (40)
		dc.l ErrorTrap					; TRAP #08 exception
		dc.l ErrorTrap					; TRAP #09 exception
		dc.l ErrorTrap					; TRAP #10 exception
		dc.l ErrorTrap					; TRAP #11 exception (44)
		dc.l ErrorTrap					; TRAP #12 exception
		dc.l ErrorTrap					; TRAP #13 exception
		dc.l ErrorTrap					; TRAP #14 exception
		dc.l ErrorTrap					; TRAP #15 exception (48)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
	if Revision<>2|FixBugs
		if (Revision=2)&(FixBugs=1)&(MOMPASS=1)
			warning "'Revision = 2' is unnecessary with 'FixBugs' enabled (use 'Revision = 1' instead)."
		endif
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
	else
		; loc_E0:
	Rev02_SpikeBugFix:
		; Relocated code from Spik_Hurt. REVXB was a nasty hex-edit.
		; See _incObj/36 Spikes.asm for more info.
		move.l	obY(a0),d3				; get Sonic's Y-position (with subpixels)
		move.w	obVelY(a0),d0				; get Sonic's Y-velocity
		ext.l	d0					; extend velocity to longword
		asl.l	#8,d0					; shift velocity to upper word (16.16 fixed point)
		jmp	(Rev02_SpikeBugFix_Return).l		; return to main spikes logic
		dc.w ErrorTrap					; Unused (reserved)
	endif
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)

		dc.b "SEGA MEGA DRIVE "				; Hardware system ID (Console name)
		dc.b "(C)SEGA 1991.APR"				; Copyright holder and release date (generally year)
	rept 2
		 ; Name (identical for domestic and overseas version)
		dc.b "SONIC THE               HEDGEHOG                "
	endr

	if Revision=0
		dc.b "GM 00001009-00"				; Serial/version number (Rev 0)
	else
		dc.b "GM 00004049-01"				; Serial/version number (Rev non-0)
	endif

Checksum:		; Checksum is hardcoded to make it easier to check for ROM correctness
	if Revision=0
		dc.w $264A
	else
		dc.w $AFC7
	endif

		dc.b "J               "				; I/O support
		dc.l StartOfRom					; Start address of ROM
RomEndLoc:	dc.l EndOfRom-1					; End address of ROM
		dc.l $FF0000					; Start address of RAM
		dc.l $FFFFFF					; End address of RAM
	if EnableSRAM=1
		dc.b "RA", $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20 ; SRAM support
		dc.l sram_start					; SRAM start
		dc.l sram_end-1					; SRAM end
	else
		dc.b "    "
		dc.b "    "
		dc.b "    "
	endif
		dc.b "                                                    " ; Notes (unused, anything can be put in this space, but it has to be 52 bytes)
		dc.b "JUE             "				; Region (Country code)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000. Unlike Sonic 2, Sonic 1 uses the 68000 for playing music, so it stops too
ErrorTrap:
		nop						; no operation
		nop						; ''
		bra.s	ErrorTrap				; loop forever
; ===========================================================================
; ---------------------------------------------------------------------------
; Entry point for the game on boot or soft-reset
; (This section from a standard Mega Drive devkit library)
; ---------------------------------------------------------------------------

EntryPoint:
		tst.l	(port_1_control_hi).l			; test port A & B control registers
		bne.s	PortA_Ok				; if either of them are already initialized, branch
		tst.w	(expansion_control_hi).l		; test port C control register
PortA_Ok:	bne.s	SkipSetup				; if any port was already initialized, skip the VDP and Z80 setup code (this is a soft-reset)

		lea	SetupValues(pc),a5			; load setup values array address
		movem.w	(a5)+,d5-d7				; d5 = VDP register start number; d6 = size of RAM/4; d7 = VDP register diff
		movem.l	(a5)+,a0-a4				; a0 = start of Z80 RAM; a1 = Z80 bus request; a2 = Z80 reset; a3 = VDP data; a4 = VDP control

		move.b	-$10FF(a1),d0				; get hardware version (from $A10001)
		andi.b	#$F,d0					; only look at Mega Drive version
		beq.s	SkipSecurity				; if the console has no TMSS, skip the security stuff
		move.l	#'SEGA',$2F00(a1)			; write "SEGA" to TMSS security register ($A14000)

SkipSecurity:
		move.w	(a4),d0					; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		moveq	#0,d0					; clear d0
		movea.l	d0,a6					; clear a6
		move.l	a6,usp					; set usp to $0

		moveq	#SetupValues_VDP_End-SetupValues_VDP-1,d1 ; write to all VDP registers
VDPInitLoop:	move.b	(a5)+,d5				; add $8000 to value
		move.w	d5,(a4)					; write value to VDP register
		add.w	d7,d5					; next register
		dbf	d1,VDPInitLoop				; loop until all registers are set up

		move.l	(a5)+,(a4)				; write DMA destination to VDP (VRAM 0000)
		move.w	d0,(a3)					; set DMA fill value to 00 (DMA starts here, clears entire VRAM)

		move.w	d7,(a1)					; stop the Z80
		move.w	d7,(a2)					; reset the Z80
WaitForZ80:	btst	d0,(a1)					; has the Z80 stopped?
		bne.s	WaitForZ80				; if not, loop until it has

		moveq	#SetupValues_Z80_End-SetupValues_Z80-1,d2 ; write all Z80 boot code
Z80InitLoop:	move.b	(a5)+,(a0)+				; write boot code to Z80 RAM
		dbf	d2,Z80InitLoop				; loop until all boot code has been written

		move.w	d0,(a2)					; set Z80 reset on
		move.w	d0,(a1)					; set Z80 stop off
		move.w	d7,(a2)					; set Z80 reset off

ClrRAMLoop:	move.l	d0,-(a6)				; clear 4 bytes of RAM
		dbf	d6,ClrRAMLoop				; repeat until the entire RAM is cleared

		move.l	(a5)+,(a4)				; set VDP display mode and increment mode

		move.l	(a5)+,(a4)				; set VDP to CRAM write
		moveq	#(v_palette_end-v_palette)/4-1,d3	; set repeat times to cover full CRAM
ClrCRAMLoop:	move.l	d0,(a3)					; clear 2 colors
		dbf	d3,ClrCRAMLoop				; repeat until the entire CRAM is clear

		move.l	(a5)+,(a4)				; set VDP to VSRAM write
		moveq	#$14-1,d4
ClrVSRAMLoop:	move.l	d0,(a3)					; clear 4 bytes of VSRAM
		dbf	d4,ClrVSRAMLoop				; repeat until the entire VSRAM is clear

		moveq	#SetupValues_PSG_End-SetupValues_PSG-1,d5 ; write to all PSG registers
PSGInitLoop:	move.b	(a5)+,$11(a3)				; write PSG volume values to PSG port ($C00011)
		dbf	d5,PSGInitLoop				; repeat for all channels

		move.w	d0,(a2)					; set Z80 reset on
		movem.l	(a6),d0-a6				; clear all registers
		disable_ints					; disable interrupts

SkipSetup:
		bra.s	GameProgram				; begin actual game
; ===========================================================================

SetupValues:	dc.w vreg_mode1					; VDP register start number
		dc.w (v_ram_end-v_ram_start_def/4)-1		; size of RAM/4 ($3FFF)
		dc.w $100					; VDP register diff

		dc.l z80_ram					; start of Z80 RAM
		dc.l z80_bus_request				; Z80 bus request
		dc.l z80_reset					; Z80 reset
		dc.l vdp_data_port				; VDP data
		dc.l vdp_control_port				; VDP control

	SetupValues_VDP:
		; Note that most of these are immediately overwritten again in VDPSetupArray
		dc.b %000100					; VDP $80 - 8-colour mode
		dc.b %00010100					; VDP $81 - Mega Drive mode, DMA enable
		dc.b ($C000>>10)				; VDP $82 - foreground nametable address
		dc.b ($F000>>10)				; VDP $83 - window nametable address
		dc.b ($E000>>13)				; VDP $84 - background nametable address
		dc.b ($D800>>9)					; VDP $85 - sprite table address
		dc.b 0						; VDP $86 - unused
		dc.b 0<<4|0					; VDP $87 - background colour
		dc.b 0						; VDP $88 - unused
		dc.b 0						; VDP $89 - unused
		dc.b 255					; VDP $8A - HBlank register
		dc.b %0000					; VDP $8B - full screen scroll
		dc.b %10000001					; VDP $8C - 40 cell display
		dc.b ($DC00>>10)				; VDP $8D - h-scroll table address
		dc.b 0						; VDP $8E - unused
		dc.b 1						; VDP $8F - VDP increment
		dc.b %000001					; VDP $90 - 64 cell h-scroll size
		dc.b 0						; VDP $91 - window h position
		dc.b 0						; VDP $92 - window v position
		dc.w $FFFF					; VDP $93/94 - DMA length
		dc.w $0000					; VDP $95/96 - DMA source
		dc.b $80					; VDP $97 - DMA fill VRAM
	SetupValues_VDP_End:
		dc.l $40000080					; DMA fill destination (VRAM 0000)

	SetupValues_Z80:
		; Z80 instructions (not the sound driver; that gets loaded later)
		save
		CPU Z80						; start assembling Z80 code
		phase 0						; pretend we're at address 0

		xor	a					; clear a to 0
		ld	bc,((z80_ram_end-z80_ram)-zStartupCodeEndLoc)-1 ; prepare to loop this many times
		ld	de,zStartupCodeEndLoc+1			; initial destination address
		ld	hl,zStartupCodeEndLoc			; initial source address
		ld	sp,hl					; set the address the stack starts at
		ld	(hl),a					; set first byte of the stack to 0
		ldir						; loop to fill the stack (entire remaining available Z80 RAM) with 0
		pop	ix					; clear ix
		pop	iy					; clear iy
		ld	i,a					; clear i
		ld	r,a					; clear r
		pop	de					; clear de
		pop	hl					; clear hl
		pop	af					; clear af
		ex	af,af'					; swap af with af'
		exx						; swap bc/de/hl with their shadow registers too
		pop	bc					; clear bc
		pop	de					; clear de
		pop	hl					; clear hl
		pop	af					; clear af
		ld	sp,hl					; clear sp
		di						; clear iff1 (for interrupt handler)
		im	1					; interrupt handling mode = 1
		ld	(hl),0E9h				; replace the first instruction with a jump to itself
		jp	(hl)	 				; jump to the first instruction (to stay there forever)
	zStartupCodeEndLoc:
		dephase						; stop pretending
		restore
		padding off					; unfortunately our flags got reset so we have to set them again...
	SetupValues_Z80_End:

		dc.w vreg_mode2|%00000100			; VDP display mode
		dc.w vreg_autoinc|2				; VDP increment
		dc.l $C0000000					; CRAM write mode
		dc.l $40000010					; VSRAM address 0

	SetupValues_PSG:
		dc.b $9F, $BF, $DF, $FF				; values for PSG channel volumes
	SetupValues_PSG_End:
; End of SetupValues


; ===========================================================================
; ---------------------------------------------------------------------------
; Proper game entry point for Sonic the Hedgehog after initialization
; ---------------------------------------------------------------------------

GameProgram:
		tst.w	(vdp_control_port).l			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		btst	#6,(expansion_control).l		; has port C been initialized?
		beq.s	CheckSumCheck				; if not, branch
		cmpi.l	#'init',(v_init).w			; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

CheckSumCheck:
	if SkipChecksumCheck=0
		movea.l	#EndOfHeader,a0				; start checking bytes after the header ($200)
		movea.l	#RomEndLoc,a1				; stop at end of ROM
		move.l	(a1),d0					; retrieve long of ROM end
		moveq	#0,d1					; clear d1
	.loop:	add.w	(a0)+,d1				; add next byte value of ROM word
		cmp.l	a0,d0					; has iterator reached end of ROM?
		bhs.s	.loop					; if not, loop until so

		movea.l	#Checksum,a1				; read the checksum
		cmp.w	(a1),d1					; compare calculated value with checksum in ROM header
		bne.w	CheckSumError				; if they don't match, a checksum error has occurred
	endif

CheckSumOk:
		lea	(v_crossresetram).w,a6			; load cross-reset RAM location
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_ram_end-v_crossresetram)/4-1,d6	; write to all of cross-reset RAM ($FE00-$FFFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		move.b	(console_version).l,d0			; get hardware information from console
		andi.b	#%11000000,d0				; filter to only overseas flag and PAL flag
		move.b	d0,(v_megadrive).w			; store region settings

		move.l	#'init',(v_init).w			; set flag so checksum won't run again

GameInit:
		lea	(v_ram_start).l,a6			; load start location of RAM
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_crossresetram-v_ram_start_def)/4-1,d6 ; write to all of RAM except cross-reset RAM ($0000-$FDFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		jsr	(InitDMAQueue).l
		bsr.w	VDPSetupGame				; initialize (proper) VDP registers
		bsr.w	DACDriverLoad				; initialize Z80 DAC driver
		bsr.w	JoypadInit				; initialize controller ports
		move.b	#id_Sega,(v_gamemode).w			; set first Game Mode to Sega Screen

	if CheatsEnabled=1
		moveq	#1,d0					; enable all cheats by default
		move.b	d0,(f_levselcheat).w			; enable level select cheat
		move.b	d0,(f_slomocheat).w			; enable slow-motion cheat
		move.b	d0,(f_debugcheat).w			; enable debug mode cheat
		move.b	d0,(f_creditscheat).w			; enable hidden Japanese credits cheat
	endif

MainGameLoop:
		move.b	(v_gamemode).w,d0			; load Game Mode
		andi.w	#$7C,d0					; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		jsr	GameModeArray(pc,d0.w)			; jump to apt location in ROM
		bra.s	MainGameLoop				; loop indefinitely

; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:

gmptr:		macro gamemode,{INTLABEL}
__LABEL__:	label	*-GameModeArray
		bra.w	gamemode
		endm

id_Sega:	gmptr	GM_Sega					; Sega Screen ($00)
id_Title:	gmptr	GM_Title				; Title Screen ($04)
id_Demo:	gmptr	GM_Level				; Demo Mode ($08)
id_Level:	gmptr	GM_Level				; Normal Level ($0C)
id_Special:	gmptr	GM_Special				; Special Stage ($10)
id_Continue:	gmptr	GM_Continue				; Continue Screen ($14)
id_Ending:	gmptr	GM_Ending				; End of game sequence ($18)
id_Credits:	gmptr	GM_Credits				; Credits ($1C)
id_LevelSelect:	gmptr	GM_LevelSelect	; Level Select ($20)
id_MySplash:	gmptr	GM_MySplash				; Splash Screen ($20)

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to attempt recovering from an exception if C is pressed.
; ---------------------------------------------------------------------------

Debugger_RecoverFromException:
		movea.l	(0).w,sp		; reset Stack Pointer (sp)
		bsr.w	VDPSetupGame		; restore Sonic 1 VDP settings
		enable_display			; make sure display is enabled
		bra.w	MainGameLoop		; return to main game loop and try resuming operation
; End of function Debugger_RecoverFromException


; ===========================================================================
; ---------------------------------------------------------------------------
; Error handler
; ---------------------------------------------------------------------------

	if SkipChecksumCheck=0
CheckSumError:
		bsr.w	VDPSetupGame				; restore all VDP registers
		move.l	#$C0000000,(vdp_control_port).l		; set VDP to CRAM write
		moveq	#(v_palette_end-v_palette)/2-1,d7	; write to entire palette
.fillred:	move.w	#cRed,(vdp_data_port).l			; fill palette with red
		dbf	d7,.fillred				; repeat until CRAM is filled
		bra.s	*					; endless loop to itself
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Uncompressed art text for debug mode, level select, and errors
; (formerly "menutext.bin")
; ---------------------------------------------------------------------------

Art_Text:	bincludeEndMarker	"artunc/Level Select & Debug Text.unc"


; ===========================================================================
; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------
id_VBlank_Lag:		equ $00					; (lag frame)
id_VBlank_Sega:		equ $02					; Sega Screen
id_VBlank_Title:	equ $04					; Title Screen, Credits
id_VBlank_Unused06:	equ $06					; (unused)
id_VBlank_Levels:	equ $08					; Levels, Demos
id_VBlank_SpecialStage:	equ $0A					; Special Stages
id_VBlank_TitleCards:	equ $0C					; Title Cards
id_VBlank_Unused0E:	equ $0E					; (unused)
id_VBlank_Paused:	equ $10					; Paused
id_VBlank_PaletteFade:	equ $12					; Palette Fade
id_VBlank_SegaPCM:	equ $14					; Sega Screen PCM
id_VBlank_Continue:	equ $16					; Continue Screen
id_VBlank_Ending:	equ $18					; Ending Sequence
; ---------------------------------------------------------------------------

; loc_B10: VBla:
VBlank:
		movem.l	d0-a6,-(sp)				; backup all registers except stack pointer (a7)

		tst.b	(v_vblank_routine).w			; was a VBlank routine set?
		beq.s	VBlank_Lag				; if not, this is a lag frame, branch

		move.w	(vdp_control_port).l,d0			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		move.l	#$40000010,(vdp_control_port).l		; set VDP to VSRAM write mode
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l	; send screen y-axis pos. to VSRAM

		; Wait here in a loop doing nothing for a while. This seems to be a pretty harsh attempt
		; to push CRAM dots outside of the visible view area, due to Sonic 1 not using all
		; the available screen space PAL offers, as they would otherwise be seen at the bottom.
		btst	#6,(v_megadrive).w			; is Mega Drive PAL?
		beq.s	.notPAL					; if not, branch
		move.w	#$700,d0				; set to waste a bunch of cycles
	.waitPAL:
		dbf	d0,.waitPAL				; loop until cycles have been wasted

.notPAL:
		move.b	(v_vblank_routine).w,d0			; copy specified VBlank routine to d0
		move.b	#id_VBlank_Lag,(v_vblank_routine).w	; reset actual routine to lag frame (which ideally should get set again in the next frame)
		move.w	#1,(f_hblank_pal).w			; set HBlank palette swap flag (only relevant for LZ)
		andi.w	#$3E,d0					; mask out irrelevant bits in VBlank routine
		move.w	VBlank_Index(pc,d0.w),d0		; load address to relevant VBlank routine
		jsr	VBlank_Index(pc,d0.w)			; jump to VBlank routine and then return here

VBlank_Music:
		jsr	(UpdateMusic).l				; run sound driver to advance music

VBlank_Exit:
		addq.l	#1,(v_vblank_count).w			; increment VBlank counter
		movem.l	(sp)+,d0-a6				; restore all backed-up registers
		rte						; return from interrupt and resume normal operation

; ===========================================================================
; VBla_Index:
VBlank_Index:	dc.w VBlank_Lag-VBlank_Index			; $00 - (lag frame)
		dc.w VBlank_Sega-VBlank_Index			; $02 - Sega Screen
		dc.w VBlank_Title-VBlank_Index			; $04 - Title Screen, Credits, Try Again
		dc.w VBlank_Unused06-VBlank_Index		; $06 - (unused)
		dc.w VBlank_Levels-VBlank_Index			; $08 - Levels, Demos
		dc.w VBlank_SpecialStage-VBlank_Index		; $0A - Special Stages
		dc.w VBlank_TitleCards-VBlank_Index		; $0C - Title Cards
		dc.w VBlank_Unused0E-VBlank_Index		; $0E - (unused)
		dc.w VBlank_Paused-VBlank_Index			; $10 - Paused
		dc.w VBlank_PaletteFade-VBlank_Index		; $12 - Palette Fade
		dc.w VBlank_SegaPCM-VBlank_Index		; $14 - Sega Screen PCM
		dc.w VBlank_Continue-VBlank_Index		; $16 - Continue Screen, SS Finish
		dc.w VBlank_Ending-VBlank_Index			; $18 - Ending Sequence
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 00 - Lag frame (VBlank occurred before call to WaitForVBlank)
; ---------------------------------------------------------------------------

; loc_B88: VBla_00:
VBlank_Lag:
		cmpi.b	#$80+id_Level,(v_gamemode).w		; is pre level sequence active?
		beq.s	.isLevel				; if not, just update sound driver and resume operation
		cmpi.b	#id_Level,(v_gamemode).w		; is game on a level?
		bne.w	VBlank_Music				; if not, just update sound driver and resume operation

.isLevel:
		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
		bne.w	VBlank_Music				; if not, just update sound driver and resume operation

		; --- A lag frame has occurred while in Labyrinth Zone ---

		move.w	(vdp_control_port).l,d0			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)

		; Same as in the opening block of the VBlank routine, this time during a lag frame.
		; This only happens if the level is LZ (note, Sonic 2/3/&K would change this so it runs in any level).
		btst	#6,(v_megadrive).w			; is Mega Drive PAL?
		beq.s	.paletteTransfer			; if not, branch
		move.w	#$700,d0				; set to waste a bunch of cycles
	.waitPAL:
		dbf	d0,.waitPAL				; loop until cycles have been wasted

.paletteTransfer:
		move.w	#1,(f_hblank_pal).w			; set HBlank flag
		stopZ80						; stop Z80 for CRAM transfers
		waitZ80						; wait until Z80 has stopped
		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:
		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.w	d0,(a5)			; write to VDP register ($8Axx)
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)
		startZ80					; restart Z80

		bra.w	VBlank_Music				; branch back to update sound driver and resume operation

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 02 - Sega Screen
; ---------------------------------------------------------------------------

; loc_C32: VBla_02:
VBlank_Sega:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		; fall-through...

; ---------------------------------------------------------------------------
; VBlank 14 - Sega Screen while the PCM sample is playing
; ---------------------------------------------------------------------------

; loc_C36: VBla_14:
VBlank_SegaPCM:
		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 04 - Title Screen, Level Select, Credits, "Try Again" screen
; ---------------------------------------------------------------------------

; loc_C44: VBla_04:
VBlank_Title:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		bsr.w	LoadTilesAsYouMove_BGOnly		; update background tiles as title screen scrolls

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 06 - Unused and unknown purpose
; ---------------------------------------------------------------------------

; loc_C5E: VBla_06:
VBlank_Unused06:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers...
		rts						; ...and nothing else

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 10 - While game is paused
; ---------------------------------------------------------------------------

; loc_C64: VBla_10:
VBlank_Paused:
		cmpi.b	#id_Special,(v_gamemode).w		; is game on special stage?
		beq.w	VBlank_SpecialStage			; if yes, branch
		; fall-through...

; ---------------------------------------------------------------------------
; VBlank 08 - Levels and Demos
; ---------------------------------------------------------------------------

; loc_C6E: VBla_08:
VBlank_Levels:
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:
		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.w	d0,(a5)			; write to VDP register ($8Axx)
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)

		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		jsr	ProcessDMAQueue(pc)
		startZ80					; restart Z80

		movem.l	(v_screenposx).w,d0-d7			; copy everything from v_screenposx to v_bg3screenposy...
		movem.l	d0-d7,(v_screenposx_dup).w		; ...to backup RAM (used in LoadTilesAsYouMove)
		movem.l	(v_fg_scroll_flags).w,d0-d1		; copy FG and BG scroll flags...
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w		; ...to backup RAM

		; The following code handles an awkward visual glitch for the LZ water surface.
		; If the surface is near the top of the screen (within 96 pixels), the VDP would not have
		; enough time to do all the transfers in VBlank_UpdateScreen before the palette needs to get
		; changed for the water. Without this special check, the water surface would violently flicker
		; whenever it's near the top of the screen. It's a rather dirty workaround, but it works.
		cmpi.b	#96,(v_hblank_line).w			; is LZ water surface within 96 pixels of the top of the screen?
		bhs.s	VBlank_UpdateScreen			; if not, do screen updates now
		move.b	#1,(f_doupdatesinhblank).w		; otherwise, we don't have enough time to do them now before HBlank hits, defer updates to then
		addq.l	#4,sp					; skip return address (i.e. postpone updating the sound driver as well)
		bra.w	VBlank_Exit				; go straight back to to the VBlank exit

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to update various screen elements during interrupts.
; Also deducts the generic timer that controls the length of a Demo.
; ---------------------------------------------------------------------------

; Demo_Time: VBla_UpdateScreen:
VBlank_UpdateScreen:
		bsr.w	LoadTilesAsYouMove			; update level tiles while screen is moving
		jsr	(AnimateLevelGfx).l			; updated animated tiles
		jsr	(HUD_Update).l				; update HUD data

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return
; End of function VBlank_UpdateScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0A - Special Stages
; ---------------------------------------------------------------------------

; loc_DA6: VBla_0A:
VBlank_SpecialStage:
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		jsr	ProcessDMAQueue(pc)
		startZ80					; restart Z80

		bsr.w	PalCycle_SS				; advance special stage palette cycle and animate bird/fish graphics

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0C - While title cards are displayed (Levels and SS Results)
; VBlank 18 - During the Ending Sequence
; ---------------------------------------------------------------------------

; loc_E72: VBla_0C: VBla_18:
VBlank_TitleCards:
VBlank_Ending:
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:
		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.w	d0,(a5)			; write to VDP register ($8Axx)
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)

		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		jsr	ProcessDMAQueue(pc)
		startZ80					; restart Z80

		movem.l	(v_screenposx).w,d0-d7			; copy everything from v_screenposx to v_bg3screenposy...
		movem.l	d0-d7,(v_screenposx_dup).w		; ...to backup RAM (used in LoadTilesAsYouMove)
		movem.l	(v_fg_scroll_flags).w,d0-d1		; copy FG and BG scroll flags...
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w		; ...to backup RAM

		bsr.w	LoadTilesAsYouMove			; update rendered
		jsr	(AnimateLevelGfx).l			; animate uncompressed level graphics (e.g. MZ lava)
		jsr	(HUD_Update).l				; update HUD numbers
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0E - Unused (possibly once used as a lag frame counter?)
; ---------------------------------------------------------------------------

; loc_F8A: VBla_0E:
VBlank_Unused0E:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		addq.b	#1,(v_vblank_0e_counter).w		; increment some counter (unused besides this one write...)
		move.b	#id_VBlank_Unused0E,(v_vblank_routine).w ; set itself to land back here again if not further altered
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 12 - During palette fades
; ---------------------------------------------------------------------------

; loc_F9A: VBla_12:
VBlank_PaletteFade:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.w	d0,(a5)			; write to VDP register ($8Axx)
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 16 - Continue Screen and Special Stage finish loop
; ---------------------------------------------------------------------------

; loc_FA6: VBla_16:
VBlank_Continue:
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		jsr	ProcessDMAQueue(pc)
		startZ80					; restart Z80

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to perform standard VRAM transfers (palette, sprites, H-scroll)
; ---------------------------------------------------------------------------

; sub_106E:
VBlank_StandardTransfers:
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:

		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		jsr	ProcessDMAQueue(pc)
		startZ80					; restart Z80
		rts						; return
; End of function VBlank_StandardTransfers
; End of VBlank (as a whole)


; ===========================================================================
; ---------------------------------------------------------------------------
; Horizontal interrupt (exclusively used for the LZ water palette effect)
; ---------------------------------------------------------------------------

; PalToCRAM: <-- old misnomer
HBlank:
		tst.w	(f_hblank_pal).w			; is palette set to change?
		beq.w	.nochg					; if not, branch
		move.w	#0,(f_hblank_pal).w			; clear palette change flag

		movem.l	d0-d2/a0-a2,-(sp)			; backup registers
		stopZ80						; request Z80 stop
		waitZ80						; wait until it stopped

		lea	(vdp_data_port).l,a1			; load VDP data port to a1
		move.w	#$8A00+223,4(a1)			; reset horizontal interrupt counter

		lea	HBlank_LZWater(pc),a2			; get water transition LUT
		move.w	#(HBlank_LZWater_End-HBlank_LZWater)/2-1,d1 ; get number of entries in list
		move.b	(v_waterline).w,d0			; get scanline that was written to
		subi.b	#200,d0					; is H-int occurring below line 200?
		bcs.s	.transferColors				; if it is, branch
		sub.b	d0,d1					; skip relevant number of entries in LUT
		bcs.s	.skipTransfer				; if everything was skipped, branch

	.transferColors:
		moveq	#0,d0					; clear d0
		move.w	(a2)+,d0				; get palette offset from LUT
		lea	(v_palette_water).w,a0			; get buffered water palette
		adda.w	d0,a0					; go to specified entry in palette buffer
		addi.w	#$C000,d0				; prepare CRAM write
		swap	d0					; move to upper word
		move.l	d0,4(a1)				; write to CRAM at appropriate address

		swap	d1					; high word of D1 is used for buffering
		move.l	(a0)+,d2				; buffer colors to registers for faster transfer
		move.w	(a0)+,d1				; ''

		move.b	#320/2,d0				; trigger transfer once H-Counter has gone offscreen to the right
	.waitH:	cmp.b	vdp_counter-vdp_data_port+1(a1),d0	; read H-Counter, has it gone offscreen?
		bhi.s	.waitH					; if not, loop until it has

		move.l	d2,(a1)					; transfer two colors
		move.w	d1,(a1)					; transfer the third color
		swap	d1					; use d1 as counter again
		dbf	d1,.transferColors			; repeat for number of colors
; ---------------------------------------------------------------------------

.skipTransfer:
		startZ80					; restart Z80
		movem.l	(sp)+,d0-d2/a0-a2			; restore registers

		tst.b	(f_doupdatesinhblank).w			; was frame update delayed by water surface being near the top of the screen?
		bne.s	.delayed_transfer			; if yes, resume transfer now

	.nochg:
		rte						; return from horizontal interrupt and resume normal operation
; ===========================================================================

; loc_119E:
.delayed_transfer:
		clr.b	(f_doupdatesinhblank).w			; clear delayed updates flag
		movem.l	d0-a6,-(sp)				; backup all registers except stack pointer (a7)
		bsr.w	VBlank_UpdateScreen			; do all the screen updates that were skipped during VBlank now
		jsr	(UpdateMusic).l				; update the sound driver
		movem.l	(sp)+,d0-a6				; restore registers
		rte						; return from horizontal interrupt and resume normal operation
; End of function HBlank

; ===========================================================================

HBlank_LZWater:
		dc.w $62	; line 4, color 1-2-3
		dc.w $68	; line 4, color 4-5-6
		dc.w $7A	; line 4, color D-E-F
		dc.w $6E	; line 4, color 7-8-9
		dc.w $74	; line 4, color A-B-C

		dc.w $42	; line 3, color 1-2-3
		dc.w $48	; line 3, color 4-5-6
		dc.w $4E	; line 3, color 7-8-9
		dc.w $54	; line 3, color A-B-C
		dc.w $5A	; line 3, color D-E-F

		dc.w $02	; line 1, color 1-2-3
		dc.w $08	; line 1, color 4-5-6
		dc.w $0E	; line 1, color 7-8-9
		dc.w $14	; line 1, color A-B-C
		dc.w $1A	; line 1, color D-E-F

		dc.w $34	; line 2, color A-B-C
		dc.w $22	; line 2, color 1-2-3
		dc.w $3A	; line 2, color D-E-F
		dc.w $2E	; line 2, color 7-8-9
		dc.w $28	; line 2, color 4-5-6
HBlank_LZWater_End:

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to initialise joypads (run once during boot)
; ---------------------------------------------------------------------------

JoypadInit:
		stopZ80						; request Z80 stop on
		waitZ80						; wait until it has stopped
		moveq	#$40,d0					; prepare initialise value
		move.b	d0,(port_1_control).l			; init port 1 (joypad 1)
		move.b	d0,(port_2_control).l			; init port 2 (joypad 2)
		move.b	d0,(expansion_control).l		; init port 3 (expansion/extra)
		startZ80					; request Z80 stop off
		rts						; return
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to read joypad input, and send it to the RAM (read every VBlank)
; ---------------------------------------------------------------------------

ReadJoypads:
		lea	(v_jpadhold1).w,a0			; address where joypad states are written
		lea	(port_1_data).l,a1			; first joypad port
		bsr.s	.read					; do the first joypad
		addq.w	#2,a1					; do the second joypad (port_2_data)

.read:
		move.b	#0,(a1)					; read A and Start input (TH poll low)
		nop						; wait a bit
		nop						; ''
		move.b	(a1),d0					; write A and Start input states to d0

		lsl.b	#2,d0					; move A and Start to topmost bits
		andi.b	#%11000000,d0				; clear all other inputs from the poll

		move.b	#$40,(a1)				; read D-Pad, B, and C input (TH poll high)
		nop						; wait a bit
		nop						; ''
		move.b	(a1),d1					; write D-Pad, B, and C input states to d1

		andi.b	#%00111111,d1				; clear all other inputs from the poll
		or.b	d1,d0					; merge but poll results into d0
		not.b	d0					; flip bits so that 0=released and 1=pressed

		move.b	(a0),d1					; get buttons pressed the previous frame
		eor.b	d0,d1					; XOR with buttons pressed this frame

		move.b	d0,(a0)+				; write HELD buttons
		and.b	d0,d1					; find buttons pressed this frame
		move.b	d1,(a0)+				; write PRESSED buttons
		rts						; return to VBlank routine
; End of function ReadJoypads


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to setup the VDP with values used for the game itself
; ---------------------------------------------------------------------------

VDPSetupGame:
		lea	(vdp_control_port).l,a0			; load VDP control port
		lea	(vdp_data_port).l,a1			; load VDP data port
		lea	(VDPSetupArray).l,a2			; load address of register values
		moveq	#(VDPSetupArray_End-VDPSetupArray)/2-1,d7 ; set repeat times
.setreg:
		move.w	(a2)+,(a0)				; save register value to VDP
		dbf	d7,.setreg				; repeat until all register values have been sent

		move.w	(VDPSetupArray+2).l,d0			; get second entry of VDPSetupArray
		move.w	d0,(v_vdp_buffer1).w			; buffer register $81 (used for enabling/disabling display)

		move.w	#vreg_hintrate|223,(v_hblank_hreg).w		; HBlank every 224th scanline

		moveq	#cBlack,d0				; set d0 to 0 (black)
		move.l	#$C0000000,(vdp_control_port).l		; set VDP to CRAM write
		move.w	#($80)/2-1,d7				; set repeat times to cover full CRAM
.clrCRAM:
		move.w	d0,(a1)					; clear colours
		dbf	d7,.clrCRAM				; repeat until the entire palette is clear (black)

		clr.l	(v_scrposy_vdp).w			; clear single vertical scroll buffer
		clr.l	(v_scrposx_vdp).w			; clear single horizontal scroll buffer
		move.l	d1,-(sp)				; store d1 data in the stack for now
		fillVRAM 0,0,$10000				; clear the entirety of VRAM
		move.l	(sp)+,d1				; reload d1 data back out of the stack
		rts						; return
; End of function VDPSetupGame

; ---------------------------------------------------------------------------
; VDP register settings to use for the game. Do note that a handful of these
; are getting rewritten for every game mode change, though the majority
; will stay at their initial settings defined in this array.
; ---------------------------------------------------------------------------
; See here for details on VDP registers:
; https://segaretro.org/Sega_Mega_Drive/VDP_registers
; ---------------------------------------------------------------------------

VDPSetupArray:
		dc.w vreg_mode1|%000100				; 8-color mode
		dc.w vreg_mode2|%00110100			; vertical interrupts, DMA, Mega Drive display
		dc.w vreg_fgvram|(vram_fg>>10)			; foreground nametable address
		dc.w vreg_winvram|(vram_win>>10)		; window nametable address
		dc.w vreg_bgvram|(vram_bg>>13)			; background nametable address
		dc.w vreg_spritevram|(vram_sprites>>9)		; sprite table address
		dc.w $8600					; (unused, only relevant for 128KB VRAM mode)
		dc.w vreg_bgcolor|0<<4|0			; background colour (palette line 0, entry 0)
		dc.w $8800					; (unused, only relevant for Master System)
		dc.w $8900					; (unused, only relevant for Master System)
		dc.w vreg_hintrate|$00				; horizontal interrupt register
		dc.w vreg_mode3|%0000				; full-screen vertical scrolling
		dc.w vreg_mode4|%10000001			; 40-cell display mode
		dc.w vreg_hscrollvram|(vram_hscroll>>10)	; background H-scroll address
		dc.w $8E00					; (unused, only relevant for 128KB VRAM mode)
		dc.w vreg_autoinc|2				; VDP auto-increment size (2)
		dc.w vreg_planesize|%000001			; 64-cell H-scroll size
		dc.w vreg_winxpos|0				; window horizontal position
		dc.w vreg_winypos|0				; window vertical position
VDPSetupArray_End:


; ===========================================================================

		include	"_inc/DMA-Queue.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Load a Dynamic Pattern Load Cues request into the DMA queue.
; ---------------------------------------------------------------------------
; Input:
;	d0.b = frame number
;	d4.w = starting target VRAM tile address
;	d6.l = pointer to uncompressed art
;	a2   = pointer to DPLC table
; ---------------------------------------------------------------------------

LoadDynPLC:
		andi.w	#$FF,d0					; mask out anything except the input frame
		add.w	d0,d0					; double ID (for word-based indexing)
		adda.w	(a2,d0.w),a2				; find current DPLC entry
		moveq	#0,d5					; clear d5
		move.b	(a2)+,d5				; get number of tasks in this DPLC entry
		subq.w	#1,d5					; subtract 1 from number of tasks (will be the loop count)
		bmi.w	.end					; if it underflowed, this is an empty entry, nothing to do
		
	.loop:
		move.b	(a2)+,d3				; get first byte of DPLC task
		move.b	d3,-(sp)				; move it to stack (bytes shift sp by 2)
		moveq	#0,d1					; clear d1
		move.w	(sp)+,d1				; move it from stack to upper byte of d1
		move.b	(a2)+,d1				; get second byte of DPLC task
		andi.w	#$F0,d3					; only look at upper nybble of first byte
		addi.w	#$10,d3					; add 1 to that nybble
		andi.w	#$FFF,d1				; mask out that nybble in the other part
		lsl.l	#5,d1					; multiply by $20 (tile_size)
		add.l	d6,d1					; add art location
		move.w	d4,d2					; set target VRAM location
		add.w	d3,d4					; advance VRAM pointer
		add.w	d3,d4					; (twice, for word-based tiles)
		bsr.w	QueueDMATransfer			; load DMA request into queue (also known as "DMA_68KtoVRAM")
		dbf	d5,.loop				; repeat for number of entries
		
	.end:
		rts						; return
; End of function LoadDynPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to clear the screen (plane mappings, sprites, and scroll data)
; ---------------------------------------------------------------------------

ClearScreen:
		fillVRAM 0, vram_fg, vram_fg+plane_size_64x32	; clear foreground namespace
		fillVRAM 0, vram_bg, vram_bg+plane_size_64x32	; clear background namespace

	if Revision=0
		move.l	#0,(v_scrposy_vdp).w			; clear single vertical scroll buffer
		move.l	#0,(v_scrposx_vdp).w			; clear single horizontal scroll buffer
	else
		; REV01 changed this from moving 0 to clears, but functionally identical
		clr.l	(v_scrposy_vdp).w			; clear single vertical scroll buffer
		clr.l	(v_scrposx_vdp).w			; clear single horizontal scroll buffer
	endif

	if FixBugs
		clearRAM v_spritetablebuffer,v_spritetablebuffer_end ; clear sprite table buffer
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded ; clear H-Scroll table buffer
	else
		; Both of these clear loops clear one more longwords than they should.
		; This will clear the first 4 bytes of v_palette_water and v_objspace, respectively.
		clearRAM v_spritetablebuffer,v_spritetablebuffer_end+4 ; clear sprite table buffer
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded+4 ; clear H-Scroll table buffer
	endif
		ResetDMAQueue
		clr.b	(v_draw_hud).w				; disable HUD drawing
		rts						; return
; End of function ClearScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load the DAC driver
; ---------------------------------------------------------------------------

; SoundDriverLoad: <-- old misnomer
DACDriverLoad:
		nop						; delay
		stopZ80						; request Z80 stop on
		deassertZ80Reset				; request Z80 reset off
		lea	(DACDriver).l,a0			; load compressed DAC driver address as source
		lea	(z80_ram).l,a1				; set Z80 RAM address as target
		bsr.w	KosDec					; decompress the DAC driver into Z80 RAM
		assertZ80Reset					; request Z80 reset on
		nop						; delay (while the Z80 resets)
		nop						; ''
		nop						; ''
		nop						; ''
		deassertZ80Reset				; request Z80 reset off
		startZ80					; request Z80 stop off
		rts						; return
; End of function DACDriverLoad

; ===========================================================================
; >>> Subroutines to queue sound commands to be executed by the sound driver during VBlank
	; includes QueueSound1, QueueSound2, QueueSound3
	; (formerly called PlaySound, PlaySound_Special, PlaySound_Unknown)
	include	"_inc/Queue Sound Routines.asm"


; ===========================================================================
; >>> Subroutine to allow pausing the game
	include	"_inc/PauseGame.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

TilemapToVRAM:
		lea	(vdp_data_port).l,a6			; load VDP data port address
		move.l	#$800000,d4				; prepare plane width size for VDP address advancing (row)

Tilemap_Line:
		move.l	d0,4(a6)				; set the VDP the VRAM write mode with address
		move.w	d1,d3					; load width of rectangle

Tilemap_Cell:
		move.w	(a1)+,(a6)				; copy tile map to VRAM plane space
		dbf	d3,Tilemap_Cell				; repeat for the entire width
		add.l	d4,d0					; advance VDP value address to the next row
		dbf	d2,Tilemap_Line				; repeat for the entire height
		rts						; return
; End of function TilemapToVRAM

; ===========================================================================
; >>> Decompression algorithms
	include	"_inc/Decompression/Enigma Decompression.asm"
	include	"_inc/Decompression/Kosinski Decompression.asm"
	include	"_inc/Decompression/KosinskiPlus.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add all entries from a PLC list to the PLC queue
; ---------------------------------------------------------------------------
; Input:
;    d0 = index of PLC list
; ---------------------------------------------------------------------------
PLC_Decompressor:	equ KosPlusDec
; ---------------------------------------------------------------------------

NewPLC:
		bsr.s	ClearPLC				; like AddPLC, but clear the PLC queue first
; ---------------------------------------------------------------------------

AddPLC:
		movem.l	a1-a2,-(sp)				; store register data
		lea	(ArtLoadCues).l,a1			; load PLC list address
		add.w	d0,d0					; double for word-based indexing
		move.w	(a1,d0.w),d0				; load correct relative add address
		lea	(a1,d0.w),a1				; add and load actual address of list
		move.w	(a1)+,d0				; load size of list
		bmi.s	.return					; if there is no list, branch

		lea	(v_plc_buffer).w,a2			; load PLC process list		
	.findspace:
		tst.l	(a2)					; is this slot taken?
		beq.s	.fillQueue				; if not, branch
		addq.w	#plc_slot_size,a2			; advance to next slot
		bra.s	.findspace				; recheck

.fillQueue:
		cmpa.l	#v_plc_buffer_only_end,a2		; is PLC queue full?
		bhs.s	.overflow				; if yes, overflow...
		move.l	(a1)+,(a2)+				; copy Nemesis art address
		move.w	(a1)+,(a2)+				; copy VRAM location to dump to
		dbf	d0,.fillQueue				; repeat for all entries

	.return:
		movem.l	(sp)+,a1-a2				; restore register data
		rts						; return
; ---------------------------------------------------------------------------

.overflow:
		; WARNING: This will just silently drop the new PLC request and move on
		; like nothing happened. Ideally, you would raise an error here or some
		; other debugging functionality to troubleshoot any queue overflows!
		;RaiseError "PLC queue overflow"		; comment this in if you have vladikcomper's Debugger
		bra.s	.return					; otherwise, just silently return...
; End of function AddPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to clear the PLC queue and all helper variables
; ---------------------------------------------------------------------------

ClearPLC:
		lea	(v_plc_buffer).w,a2			; load PLC process list
		moveq	#(v_plc_buffer_end-v_plc_buffer)/4-1,d1	; set size of list
	.loop:	clr.l	(a2)+					; clear PLC process list
		dbf	d1,.loop				; repeat until entire list is cleared
		rts						; return
; End of function ClearPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to directly load a full PLC list outside of VBlank (blocking).
; Not recommended, but Sonic 1 does use this occasionally...
; ---------------------------------------------------------------------------
; Input:
;    d0 = index of PLC list
; ---------------------------------------------------------------------------

QuickPLC:
		bsr.w	NewPLC					; write PLC ID to new queue on the fly...
; ---------------------------------------------------------------------------

.loop:
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w ; set VBlank routine (palette fade is good enough)
		bsr.w	WaitForVBlank				; execute PLC and DMA in VBlank
		tst.l	(v_plc_buffer).w			; is more work to be done?
		bne.s	.loop					; if yes, loop
		tst.b	(v_plc_Busy).w				; has last entry failed to get DMA'd in time?
		bne.s	.loop					; if yes, VBlank for one extra frame
		rts						; return
; End of function QuickPLC


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to execute PLC (decompress queued entries and queue for DMA)
; ---------------------------------------------------------------------------

ExecutePLC:
		tst.l	(v_plc_buffer).w			; does PLC queue contain any work for us?
		beq.s	.queueEmpty				; if not, branch

		movem.l	d0-a6,-(sp)				; backup all registers
		move.w	#Art_Buffer,(v_plc_BufferPtr).w		; reset decompression buffer pointer to start
		bsr.s	.executePLC				; execute the next PLC entry
		movem.l	(sp)+,d0-a6				; restore backed-up registers

	.queueEmpty:
		rts						; nothing to do
; ---------------------------------------------------------------------------

.executePLC:
		tst.b	(v_plc_Modules).w			; is multi-module decompression currently in progress?
		bne.s	.decompressAndQueueDMA			; if yes, continue decompressing next module
		; fresh entry...

; ---------------------------------------------------------------------------
; Process PLC queue (get next entry, prepare variables, get module count...)
; ---------------------------------------------------------------------------

.getNewPLCEntry:
		lea	(v_plc_buffer).w,a0			; get next entry of PLC queue
		move.l	(a0)+,d0				; get art offset
		move.w	(a0)+,(v_plc_VRAMAddr).w		; remember start VRAM address
		movea.l	d0,a0					; get art pointer

		move.w	(a0)+,d2				; get moduled header
		move.l	a0,(v_plc_ArtPtr).w			; remember start address of compressed data
		move.w	d2,d3					; copy module header
		and.w	#$F000,d2				; high nybble contains number of total modules - 1
		rol.w	#4,d2					; move to low nybble
		and.w	#$0FFF,d3				; get size of the last module
		seq.b	d3					; d3 = 0 if last module size is non-zero, -1 otherwise
		add.b	d3,d2					; reduce number of modules if the last module's size is zero

		addq.b	#1,d2					; make module count 1-based
		move.b	d2,(v_plc_Modules).w			; get number of modules to decompress
		; begin decompressing first module...

; ---------------------------------------------------------------------------
; Decompress a single module and queue it for DMA
; ---------------------------------------------------------------------------

.decompressAndQueueDMA:
		movea.w	(v_plc_BufferPtr).w,a1			; a1 = decompression buffer
		move.l	(v_plc_ArtPtr).w,a0			; a0 = compressed art pointer
        
		bsr.w	PLC_Decompressor			; decompress module to buffer using the specified decompressor

	if PLC_Decompressor=KosDec
		; Regular Kosinski-Moduled compression has a unique quirk not found in any other moduled compression:
		; "[...] all modules but the last are padded out to a size which is a multiple of $10 bytes."
		; Because of this, we need to manually adjust the compressed art pointer to account for it.
		move.l	(v_plc_ArtPtr).w,d0			; get base compressed art offset before decompression began
		sub.l	a0,d0					; subtract by actual end of pointer after compression
		and.l	#$F,d0					; default limit is a maximum of 16 KosPM padding bytes
		adda.l	d0,a0					; adjust final art pointer to account for KosPM padding
	endif
		move.l	a0,(v_plc_ArtPtr).w			; remember compressed art pointer

		movea.w	(v_plc_BufferPtr).w,a0			; a0 = source
		move.w	a1,d3					; d3 = end of buffer
		sub.w	a0,d3					; d3 = size of decompressed module
		add.w	d3,(v_plc_BufferPtr).w			; adjust decompression buffer pointer
		move.l	a0,d1					; d1 = source address
		andi.l	#$FFFFFF,d1				; mask to 24-bit address
		move.w	(v_plc_VRAMAddr).w,d2			; d2 = destination VRAM address
		add.w	d3,(v_plc_VRAMAddr).w			; adjust destination VRAM address
		lsr.w	#1,d3					; d3 = DMA transfer length (transfer size / 2)

		move.w	sr,-(sp)				; remember interrupt state
		disable_ints					; need to disable interrupts while accessing DMA queue
		jsr	(QueueDMATransfer).l			; queue decompressed art to be DMA'd
		move.w	(sp)+,sr				; restore previous interrupt state
		
		subq.b	#1,(v_plc_Modules).w			; decrement number of remaining modules
		bne.s	.return					; if this is a multi-module asset and more modules are left to do, branch
		; all modules for this entry are completed, go to next PLC entry...

; ---------------------------------------------------------------------------
; When a single PLC entry (with all modules) has been fully decompressed
; ---------------------------------------------------------------------------

.entryCompleted:
		; Shift the whole PLC queue 6 bytes to the left 
		lea	(v_plc_buffer).w,a0			; load PLC process list
		moveq	#(v_plc_buffer_only_end-v_plc_buffer-plc_slot_size)/4-1,d0 ; set size of list
	.loop:	move.l	plc_slot_size(a0),(a0)+			; shift contents of PLC buffer up 6 bytes
		dbf	d0,.loop				; repeat until done

		; Properly 'POP' last entry
		if (v_plc_buffer_only_end-v_plc_buffer-plc_slot_size)&2
			move.w	plc_slot_size(a0),(a0)		; pop trailing word of last entry
		endif
		clr.l	(v_plc_buffer_only_end-plc_slot_size+0).w ; clear art location of last entry
		clr.w	(v_plc_buffer_only_end-plc_slot_size+4).w ; clear VRAM dump location of last entry

		; Immediately execute the next PLC entry if it's small enough to fit into the buffer
		tst.l	(v_plc_buffer).w			; are more tasks in the PLC queue?
		beq.s	.return					; if not, branch
		movea.l	(v_plc_buffer).w,a0			; get art location of next entry from PLC queue
		move.w	(a0),d0					; get module header of art data
		move.w	#Art_Buffer_End,d1			; get end location of decompression buffer
		sub.w	(v_plc_BufferPtr).w,d1			; d1 = remaining space in buffer
		cmp.w	d1,d0					; is remaining space in buffer big enough for the next entry?
		bge.s	.return					; if not, branch
		movea.w	(VDP_Command_Buffer_Slot).w,a0		; get current DMA queue length
		cmpa.w	#VDP_Command_Buffer_Slot,a0		; is DMA queue already full?
		bne.w	.getNewPLCEntry				; if not, immediately execute next PLC entry

.return:
		rts						; return
; End of function ExecutePLC

; ---------------------------------------------------------------------------
; ===========================================================================


; ===========================================================================
; >>> Palette logic routines
	include	"_inc/PaletteCycle.asm"
	include	"_inc/Palette Fading.asm" ; includes "PaletteFadeIn", "PaletteFadeOut", "PaletteWhiteIn", and "PaletteWhiteOut"


; ===========================================================================
; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo
; ---------------------------------------------------------------------------

PalCycle_Sega:
		tst.b	(v_pcyc_time+1).w			; is light scanning effect done?
		bne.s	PCycSega_FadeIn				; if yes, branch

; ---------------------------------------------------------------------------
; First part of the Sega screen palette cycle (the "light scan effect")
; ---------------------------------------------------------------------------

		lea	(v_palette_line_2).w,a1			; set target start palette line (affects line 2-4 overall)
		lea	(Pal_Sega1).l,a0			; get palette cycle colors for the light scanning effect
		moveq	#(Pal_Sega1_end-Pal_Sega1)/2-1,d1	; set size of colors to write (6 in total)
		move.w	(v_pcyc_num).w,d0			; load current palcycle position (initialized to -$A)

; loc_2020:
.findScanStart:
		bpl.s	.doLightScan				; has start position been found? if yes, branch (d0 >= 0)
		addq.w	#2,a0					; get next color in Pal_Sega1
		subq.w	#1,d1					; set to load one less color
		addq.w	#2,d0					; go to next starting color for light effect
		bra.s	.findScanStart				; loop until current position has been found
; ===========================================================================

; loc_202A:
.doLightScan:
		move.w	d0,d2					; get current target position
		andi.w	#$1E,d2					; limit to one palette line ($20 bytes)
		bne.s	.notTransparent1			; is it the first (transparent) color? if not, branch
		addq.w	#2,d0					; skip over transparent color

; loc_2034:
.notTransparent1:
		cmpi.w	#v_palette_line_4-v_palette_line_1,d0	; (=$60) would we write past the last palette entry?
		bhs.s	.writeNoMore				; if yes, do not write new color
		move.w	(a0)+,(a1,d0.w)				; write current light scan color to palette buffer

; loc_203E:
.writeNoMore:
		addq.w	#2,d0					; go to next starting color for light effect
		dbf	d1,.doLightScan				; loop until all colors have been written

		; Palette dumping is done, update next offset or set to next part
		move.w	(v_pcyc_num).w,d0			; load current palcycle position
		addq.w	#2,d0					; go to next starting color
		move.w	d0,d2					; get current target position
		andi.w	#$1E,d2					; limit to one palette line ($20 bytes)
		bne.s	.notTransparent2			; is it the first (transparent) color? if not, branch
		addq.w	#2,d0					; skip over transparent color

; loc_2054:
.notTransparent2:
		cmpi.w	#v_palette_line_4-v_palette_line_1+4,d0	; (=$64) has light scan effect finished?
		blt.s	.scanNotDone				; if not, branch
		move.w	#(4<<8)+1,(v_pcyc_time).w		; set delay between fade-in increments (high byte) and "light scan done" flag (low byte)
		moveq	#-6*2,d0				; set starting offset for fade-in palette (gets set to 0 for first fade-in step)

; loc_2062:
.scanNotDone:
		move.w	d0,(v_pcyc_num).w
		moveq	#1,d0					; clear Z-flag (possibly for a return signal, but now unsued)
		rts						; return
; ===========================================================================

; ---------------------------------------------------------------------------
; Second part of the Sega screen palette cycle (the fade-in)
; ---------------------------------------------------------------------------

; loc_206A:
PCycSega_FadeIn:
		subq.b	#1,(v_pcyc_time).w			; decrement delay until next brightness increase
		bpl.s	.delayFadeIn				; does delay time remain? if yes, branch

		move.b	#4,(v_pcyc_time).w			; reset delay between fade-in increments
		move.w	(v_pcyc_num).w,d0			; get current fade-in position
		addi.w	#6*2,d0					; go to next set of colors
		cmpi.w	#(6*2)*4,d0				; have four color sets been done?
		blo.s	.doFadeIn				; if not, do next fade-in step

		moveq	#0,d0					; set Z-flag (possibly for a return signal, but now unsued)
		rts						; return
; ===========================================================================

; loc_2088:
.doFadeIn:
		move.w	d0,(v_pcyc_num).w			; remember position for next fade-in increment
		lea	(Pal_Sega2).l,a0			; get palette cycle colors for the fade-in effect
		lea	(a0,d0.w),a0				; go to relevant color data
		lea	(v_palette_line_1+$04).w,a1		; set to write past transparent and pure-white color
		move.l	(a0)+,(a1)+				; write colors 1 and 2 to buffer
		move.l	(a0)+,(a1)+				; write colors 3 and 4 to buffer
		move.w	(a0)+,(a1)				; write color 5 to buffer

		; Main palette dumping is done, fill remaining palette buffer with 6th color
		lea	(v_palette_line_2).w,a1			; start from second palette line (up to fourth one)
		moveq	#0,d0					; clear d0
		moveq	#((v_palette_line_4-v_palette_line_1)/2)-3-1,d1 ; (=$2C) write 3 lines, minus skipped transparent colors, minus 1

; loc_20A8:
.fillRest:
		move.w	d0,d2					; get current target position
		andi.w	#$1E,d2					; limit to one palette line ($20 bytes)
		bne.s	.notTransparent3			; is it the first (transparent) color? if not, branch
		addq.w	#2,d0					; skip over transparent color

; loc_20B2:
.notTransparent3:
		move.w	(a0),(a1,d0.w)				; write fill color to current palette slot (and don't advance index)
		addq.w	#2,d0					; go to next palette target
		dbf	d1,.fillRest				; loop until remaining palette has been filled completely

; loc_20BC:
.delayFadeIn:
		moveq	#1,d0					; clear Z-flag (possibly for a return signal, but now unsued)
		rts						; return
; End of function PalCycle_Sega

; ===========================================================================
; >>> Palette cycle data used for Sega screen
Pal_Sega1:	bincludeEndMarker	"palette/Sega1.bin"	; used during the light scanning effect
Pal_Sega2:	bincludeEndMarker	"palette/Sega2.bin"	; used during the fade-in (three color sets, 5+1 colors each)


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load main palettes into the fading buffer.
; These get displayed once PaletteFadeIn/PaletteWhiteIn is called.

; input:
; d0 = index number for palette
; ---------------------------------------------------------------------------

PalLoad_Fade:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		adda.w	#v_palette_fading-v_palette,a3		; load to palette fade-in buffer instead of active palette buffer (+$80)
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Fade

; ---------------------------------------------------------------------------
; Subroutine to directly load main palettes to the active palette.
; Same as PalLoad_Fade, but without adding $80.
; ---------------------------------------------------------------------------

PalLoad:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load underwater palettes into the water fading buffer.
; These get displayed once PaletteFadeIn/PaletteWhiteIn is called.
; ---------------------------------------------------------------------------

PalLoad_Fade_Water:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		suba.w	#v_palette-v_palette_water,a3		; load to (water) palette fade-in buffer instead of active palette buffer
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Fade_Water

; ---------------------------------------------------------------------------
; Subroutine to directly load underwater palettes to the active palette.
; Same as PalLoad_Fade_Water, but writing $80 before it.
; ---------------------------------------------------------------------------

PalLoad_Water:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		suba.w	#v_palette-v_palette_water_fading,a3	; load to active (water) palette buffer instead of main active palette buffer
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Water

; ===========================================================================
; >>> Palette pointers and palette binary includes
	include	"_inc/Palette Index.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; DelayProgram: <-- old misnomer
; WaitForVBla: <-- old name
WaitForVBlank:
		enable_ints					; enable interrupts so vertical interrupts can occur

		tst.l	(v_plc_buffer).w			; are any PLC jobs queued?
		beq.s	.wait					; if not, branch
		tst.b	(v_plc_Busy).w				; has PLC DMA missed the previous frame?
		bne.s	.wait					; if yes, don't advance PLC this frame
		bsr.w	ExecutePLC				; decompress the next PLC entry and queue it for DMA
		tst.b	(v_vblank_routine).w			; has VBlank interrupt occurred while PLC was running?
		bne.s	.wait					; if not, branch
		st.b	(v_plc_Busy).w				; otherwise, set flag that next frame should skip PLC (flush DMA)
		rts
.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, loop until it has

		sf.b	(v_plc_Busy).w				; clear DMA busy flag
		rts						; resume normal operation
; End of function WaitForVBlank

; ===========================================================================
; >>> Subroutines for generic calculations
	include	"_incObj/sub RandomNumber.asm"
	include	"_incObj/sub CalcSine.asm"
    if Revision=0
		; Only in REV00, and even there it was never used
	include	"_incObj/sub CalcSqrt.asm"
    endif
	include	"_incObj/sub CalcAngle.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

; SegaScreen:
GM_Sega:
		; fading out from previous game mode
		move.b	#bgm_Stop,d0				; set stop music command
		bsr.w	QueueSound2				; stop music
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_bgcolor|0<<4|0,(a6)		; set background colour (palette entry 0)
		move.w	#vreg_mode3|%0000,(a6)			; full-screen vertical scrolling
		clr.b	(f_wtr_state).w				; clear water state

		disable_ints					; disable interrupts
		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe the screen

		moveq	#plcid_Sega,d0			; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer
		lea	(Eni_SegaLogo).l,a0			; load Sega logo mappings
		move.w	#ArtTile_Sega_Tiles,d0			; set art tile for Sega screen mappings
		bsr.w	EniDec					; decompress Enigma-compressed mappings to RAM buffer
		copyTilemap v_ram_start,vram_bg+$510,24,8	; transfer decompressed patterns to VRAM (BG plane, light scanning effect)
		copyTilemap v_ram_start+24*8*2,vram_fg,40,28	; transfer decompressed patterns to VRAM (FG plane, Sega logo cutout)

	if Revision<>0
		tst.b	(v_megadrive).w				; is console Japanese?
		bmi.s	.loadpal				; if not, branch
		copyTilemap v_ram_start+$A40,vram_fg+$53A,3,2	; hide "TM" with a white rectangle
.loadpal:
	endif

		moveq	#palid_SegaBG,d0			; load Sega screen palette...
		bsr.w	PalLoad					; ...directly to active palette (not fade-in buffer)
		move.w	#-$A,(v_pcyc_num).w			; light scanning palette cycle effect start offset
		move.w	#0,(v_pcyc_time).w			; clear palette fade-in counter
		move.w	#0,(v_pal_buffer+$12).w			; clear some palcycle buffer (unused?)
		move.w	#0,(v_pal_buffer+$10).w			; clear some palcycle buffer (unused?)
		enable_display					; enable screen output
; ---------------------------------------------------------------------------

Sega_WaitPal:		; while light scanning effect is active
		move.b	#id_VBlank_Sega,(v_vblank_routine).w	; set VBlank routine to $02
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	PalCycle_Sega				; advance light scanning palette cycle effect
		bne.s	Sega_WaitPal				; loop until it's finished
; ---------------------------------------------------------------------------

		; while "SEGA" sound is playing
		move.b	#sfx_Sega,d0				; set "SEGA" sound
		bsr.w	QueueSound2				; queue it
		move.b	#id_VBlank_SegaPCM,(v_vblank_routine).w	; set VBlank routine to $14
		bsr.w	WaitForVBlank				; wait for VBlank to play the sound (CPU is frozen here until sound finished playing)
; ---------------------------------------------------------------------------

		; after sound has finished playing
		move.w	#30,(v_generictimer).w			; wait 30 frames before automatic fade-out

Sega_WaitEnd:
		move.b	#id_VBlank_Sega,(v_vblank_routine).w	; set VBlank routine to $02
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		tst.w	(v_generictimer).w			; has post-chant timer expired?
		beq.s	Sega_GotoTitle				; if yes, go to title screen
		andi.b	#btnStart,(v_jpadpress1).w		; is Start button pressed?
		beq.s	Sega_WaitEnd				; if not, loop post-chant routine
; ---------------------------------------------------------------------------

Sega_GotoTitle:		; transition to title screen
		move.b	#id_MySplash,(v_gamemode).w		; go to title screen
		rts						; return to MainGameLoop
; End of function GM_Sega


; ===========================================================================
; ---------------------------------------------------------------------------
; Title screen
; ---------------------------------------------------------------------------

; TitleScreen:
GM_Title:		; fading out from previous game mode
		move.b	#bgm_Stop,d0				; set stop music command
		bsr.w	QueueSound2				; stop music
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading "SONIC TEAM PRESENTS" (STP) patterns
		disable_ints					; disable ints while accessing the VDP
		bsr.w	DACDriverLoad				; load Z80 driver
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		move.w	#vreg_winypos|0,(a6)			; window vertical position
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (palette line 2, entry 0)
		clr.b	(f_wtr_state).w				; clear water state
		bsr.w	ClearScreen				; wipe the screen
		clearRAM v_objspace				; clear object RAM

		moveq	#plcid_TitleSonicTeam,d0	; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer
		lea	(Eni_JapNames).l,a0			; load mappings for hidden Japanese credits
	if FixBugs
		move.w	#ArtTile_Title_Japanese_Text|Tile_Pal3,d0 ; set art tile for hidden Japanese credits (cyan)
	else
		; The hidden Japanese credits cheat in Object 8A sets the text color to cyan on palette line 3,
		; but this part makes the text continue using palette line 1, rendering them black instead.
		move.w	#ArtTile_Title_Japanese_Text|Tile_Pal1,d0 ; set art tile for hidden Japanese credits (black)
	endif
		bsr.w	EniDec					; decompress Enigma-compressed mappings to RAM buffer
		copyTilemap v_ram_start,vram_fg,40,28		; transfer decompressed patterns from RAM buffer to VRAM

		clearRAM v_palette_fading			; set palette fade-in buffer to all-black
		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad_Fade				; ...into fade-in buffer
		move.b	#id_CreditsText,(v_sonicteam).w		; load "SONIC TEAM PRESENTS" object
		jsr	(ExecuteObjects).l			; execute objects to load STP object
		jsr	(BuildSprites).l			; build sprites for the STP object
		bsr.w	PaletteFadeIn				; fade-in STP screen
; ---------------------------------------------------------------------------

		; load main title screen patterns while "SONIC TEAM PRESENTS" screen is shown
		disable_ints					; display is frozen during the STP screen

		moveq	#plcid_TitleForeground,d0	; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		lea	(vdp_data_port).l,a6			; load VDP data transfer port
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6) ; set target VRAM location for level select font
		lea	(Art_Text).l,a5				; load uncompressed level select font
		move.w	#(Art_Text_end-Art_Text)/2-1,d1		; set loop count for level select
Tit_LoadText:
		move.w	(a5)+,(a6)				; write one row of the level select font to VRAM
		dbf	d1,Tit_LoadText				; loop until it's fully loaded

		move.b	#0,(v_lastlamp).w			; clear lamppost counter
		move.w	#0,(v_debuguse).w			; exit debug mode if necessary
		move.w	#0,(f_demo).w				; disable demo mode
		move.w	#0,(v_unused2).w			; unused variable
		move.w	#id_GHZ_act1,(v_zone_act).w		; set level to GHZ1 (000)
		move.w	#0,(v_pcyc_time).w			; disable palette cycling
		bsr.w	LevelSizeLoad				; load level size (will use GHZ1's sizes)
		bsr.w	DeformLayers				; initialize background deformation before fade-in (redundant here)

		move.l	#Blk16_Title,(v_rom_blocks).w		; set Blk16 pointer to use GHZ blocks

		move.l	#Blk256_Title,(v_rom_chunks).w		; set Blk256 pointer to use GHZ blocks

		bsr.w	LevelLayoutLoad				; load level layout for the background
		moveq	#60-1,d0				; frames to manually wait on STP screen
	.delay:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		dbf	d0,.delay
		bsr.w	PaletteFadeOut				; fade-out "SONIC TEAM PRESENTS" screen
; ---------------------------------------------------------------------------

		; "SONIC TEAM PRESENTS" screen has faded out, load remaining patterns and fade in
		disable_ints					; disable interrupts again after the fade-out
		bsr.w	ClearScreen				; wipe screen

		lea	(vdp_control_port).l,a5			; set VDP control port
		lea	(vdp_data_port).l,a6			; set VDP data port
		lea	(v_bgscreenposx).w,a3			; get current background X position
		lea	(v_lvllayout_bg).w,a4			; get location in level layout RAM where background is stored
		move.w	#$4000+(vram_bg-vram_fg),d2		; =$6000 (VRAM write command $4000 + nametable start address relative to vram_fg)
		bsr.w	DrawChunks				; draw initial background layer

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer (this overwrites unused chunk RAM)
		lea	(Eni_Title).l,a0			; load title screen emblem mappings
		move.w	#ArtTile_Level,d0			; =$0000 (emblem mappings are themselves set up with a +$2000 offset per tile)
		bsr.w	EniDec					; decompress Enigma-compressed emblem mappings to buffer
	if FixBugs
		; Fix title screen position
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Title_Screen_position_in_Sonic_1
		copyTilemap v_ram_start,vram_fg+$208,34,22	; transfer decompressed patterns from RAM buffer to VRAM (correctly centered)
	else
		copyTilemap v_ram_start,vram_fg+$206,34,22	; transfer decompressed patterns from RAM buffer to VRAM (off-center)
	endif

		moveq	#plcid_TitleBackground,d0	; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		moveq	#palid_Title,d0				; load title screen palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		move.b	#bgm_Title,d0				; set title screen music
		bsr.w	QueueSound2				; play title screen music
		move.b	#0,(f_debugmode).w			; disable debug mode (cheat remains active though)
		move.w	#640,(v_generictimer).w			; run title screen for 640 frames (11 seconds plus some change)

	if FixBugs
		; Fix the Press Start Button text
		; https://info.sonicretro.org/SCHG_How-to:Display_the_Press_Start_Button_text
		clearRAM v_sonicteam,v_sonicteam+object_size	; delete RAM used by "SONIC TEAM PRESENTS" object (fully)
	else
		; Bug: this only clears half of the "SONIC TEAM PRESENTS" slot.
		; This is responsible for why the "PRESS START BUTTON" text doesn't
		; show up, as the routine ID isn't reset.
		clearRAM v_sonicteam,v_sonicteam+object_size/2	; delete RAM used by "SONIC TEAM PRESENTS" object (partially)
	endif

		move.b	#id_TitleSonic,(v_titlesonic).w		; load big Sonic object
		move.b	#id_PSBTM,(v_pressstart).w		; load "PRESS START BUTTON" object
		jsr	(TitleMenu_LoadTextGraphics).l
	;	clr.b	(v_pressstart+obRoutine).w		; The 'Mega Games 10' version of Sonic 1 added this line to fix the 'PRESS START BUTTON' object not appearing

	if Revision<>0
		tst.b	(v_megadrive).w				; is console Japanese?
		bpl.s	.isjap					; if yes, don't load TM object
	endif
		move.b	#id_PSBTM,(v_titletm).w			; load title screen HUD object
		move.b	#3,(v_titletm+obFrame).w		; set it to the "TM" frame
	.isjap:

		move.b	#id_PSBTM,(v_ttlsonichide).w		; load title screen HUD object
		move.b	#2,(v_ttlsonichide+obFrame).w		; load object which hides part of Sonic's torso behind the emblem

		jsr	(ExecuteObjects).l			; load title screen objects
		bsr.w	DeformLayers				; initialize background deformation before fade-in
		jsr	(BuildSprites).l			; build sprites for the title screen objects before fade-in
		moveq	#plcid_Main,d0				; load main patterns (rings, etc.)
		bsr.w	NewPLC					; (these get loaded once for the title screen and then never again, except when exiting Special Stages)

		move.w	#0,(v_title_dcount).w			; clear D-Pad counter for title screen cheats
		move.w	#0,(v_title_ccount).w			; clear C counter for title screen cheats
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		enable_display					; enable display
		bsr.w	PaletteFadeIn				; fade-in title screen

; ---------------------------------------------------------------------------
; Title screen main loop and cheat checks
; ---------------------------------------------------------------------------

Tit_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		jsr	(ExecuteObjects).l			; execute title screen objects
		bsr.w	DeformLayers				; run background deformation
		jsr	(BuildSprites).l			; display sprites
		bsr.w	PalCycle_Title				; run title screen palette cycle

		move.w	(v_player+obX).w,d0			; get current title screen position (big Sonic object)
		addq.w	#2,d0					; move it 2px to the right
		move.w	d0,(v_player+obX).w			; write new X position
		cmpi.w	#$1C00,d0				; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_ChkRegion				; if not, branch
		; Will never happen due to the short title screen generic timer.
		; This likely was an old failsafe before Demos were introduced.
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		rts
; ===========================================================================

Tit_ChkRegion:
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	Tit_RegionJap				; if Japanese, branch
		lea	(LevSelCode_US).l,a0			; load US code
		bra.s	Tit_EnterCheat				; skip over

Tit_RegionJap:
		lea	(LevSelCode_J).l,a0			; load J code

Tit_EnterCheat:
		move.w	(v_title_dcount).w,d0			; get number of successful D-Pad cheat inputs
		adda.w	d0,a0					; add to loaded code to find current cheat input requirement
		move.b	(v_jpadpress1).w,d0			; get buttons pressed this frame
		andi.b	#btnDir,d0				; read only D-Pad buttons (UDLR)
		cmp.b	(a0),d0					; does button press match current cheat entry?
		bne.s	Tit_ResetCheat				; if not, branch and reset cheat
		addq.w	#1,(v_title_dcount).w			; increment number of successful D-Pad cheat inputs
		tst.b	d0					; has end of cheat code been reached? (0-entry in cheat)
		bne.s	Tit_CountC				; if not, branch
	if FixBugs
		; Allow additional cheats to be entered without resetting the sequence first.
		clr.w	(v_title_dcount).w			; reset D-Pad counter
	endif

Tit_ActivateCheat:
		; (On JAPANESE consoles only) Activated cheat depends on the amount of times C was pressed:
		; 0-1 level select -- 2-3 slow motion -- 4-5 debug mode -- 6-7: hidden Japanese credits & sound test 9E/9F
		; For any other regions, pressing C twice or more will ALWAYS result in slow motion and debug mode,
		; and the hidden Japanese credits cheat is unavailable under any circumstances on such consoles.
		lea	(f_levselcheat).w,a0			; get base cheat index
		move.w	(v_title_ccount).w,d1			; get number of tiles C was pressed
		lsr.w	#1,d1					; half pressed amount
		andi.w	#3,d1					; only four cheats are possible
		beq.s	Tit_PlayRing				; if C was not pressed, only activate level select
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	Tit_PlayRing				; if Japanese, branch
		moveq	#1,d1					; on non-Japanese console, force index to slow motion cheat
		move.b	d1,1(a0,d1.w)				; enable debug mode first (and slow motion in the next line)

Tit_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat depending on C-press count
		move.b	#sfx_Ring,d0				; set ring sound when code is entered
		bsr.w	QueueSound2				; play it
		bra.s	Tit_CountC				; skip over cheat reset
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0					; has D-Pad been pressed?
		beq.s	Tit_CountC				; if not, don't reset D-Pad counter
		cmpi.w	#9,(v_title_dcount).w			; has cheat reached index 9? (impossible condition)
		beq.s	Tit_CountC				; if yes, don't reset D-Pad counter
		move.w	#0,(v_title_dcount).w			; reset cheat index counter
	if FixBugs
		; Entering an incorrect cheat input normally resets the entire sequence.
		; If the incorrect input matches the first cheat button, it should be treated
		; as the first successful input to make repeated attempts less awkward.
		lea	(LevSelCode_J).l,a0			; reload J code
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	.chkUp					; if Japanese, branch
		lea	(LevSelCode_US).l,a0			; reload US code
	.chkUp:	cmp.b	(a0),d0					; was incorrect button press the first cheat input?
		beq.s	Tit_EnterCheat				; if yes, treat it as first correct input right away
	endif

Tit_CountC:
		move.b	(v_jpadpress1).w,d0			; get currently pressed buttons
		andi.b	#btnC,d0				; is C button pressed?
		beq.s	Tit_ChkStartOrDemo			; if not, branch
		addq.w	#1,(v_title_ccount).w			; increment C counter

; loc_3230:
Tit_ChkStartOrDemo:
		tst.w	(v_generictimer).w			; has title screen timer expired?
		beq.w	GotoDemo				; if yes, launch Demo mode
		andi.b	#btnStart,(v_jpadpress1).w		; check if Start is pressed
		beq.w	Tit_MainLoop				; if not, continue looping title screen

Tit_ChkLevSel:
		jmp	(TitleMenu_SelectionMade).l
		tst.b	(f_levselcheat).w			; check if level select code is on
		beq.w	PlayLevel				; if not, begin game by playing normal level
		btst	#bitA,(v_jpadhold1).w			; check if A was held while pressing Start
		beq.w	PlayLevel				; if not, begin game by playing normal level
; ---------------------------------------------------------------------------

Tit_EnterLevelSelect:
		move.b	#id_LevelSelect,(v_gamemode).w	; jump to level select
		rts

; ---------------------------------------------------------------------------
; Level Select main loop
; ---------------------------------------------------------------------------

PlayLevel:
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_lastspecial).w			; clear special stage number
		move.b	d0,(v_emeralds).w			; clear emeralds
		move.l	d0,(v_emldlist).w			; clear emeralds
		move.l	d0,(v_emldlist+4).w			; clear emeralds
		move.b	d0,(v_continues).w			; clear continues
	if Revision<>0
		move.l	#5000,(v_scorelife).w			; extra life is awarded at 50000 points
	endif
		move.b	#bgm_Fade,d0				; set music fade-out command
		bsr.w	QueueSound2				; fade out music
		rts						; return to MainGameLoop to start level
; End of function GM_Title

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select - level pointers
; ---------------------------------------------------------------------------

LevSel_Ptrs:
		dc.w id_GHZ_act1	; 0   GHZ 1
		dc.w id_GHZ_act2	; 1   GHZ 2
		dc.w id_GHZ_act3	; 2   GHZ 3
		dc.w id_MZ_act1		; 3   MZ 1
		dc.w id_MZ_act2		; 4   MZ 2
		dc.w id_MZ_act3		; 5   MZ 3
		dc.w id_SYZ_act1	; 6   SYZ 1
		dc.w id_SYZ_act2	; 7   SYZ 2
		dc.w id_SYZ_act3	; 8   SYZ 3
		dc.w id_LZ_act1		; 9   LZ 1
		dc.w id_LZ_act2		; 10  LZ 2
		dc.w id_LZ_act3		; 11  LZ 3
		dc.w id_SLZ_act1	; 12  SLZ 1
		dc.w id_SLZ_act2	; 13  SLZ 2
		dc.w id_SLZ_act3	; 14  SLZ 3
		dc.w id_SBZ_act1	; 15  SBZ 1
		dc.w id_SBZ_act2	; 16  SBZ 2
		dc.w id_LZ_act4		; 17  Scrap Brain Zone 3
		dc.w id_FZ		; 18  Final Zone
		dc.w id_SS<<8		; 19  Special Stage
		dc.b id_EndZ, 0		; Ending	
		dc.w $8000		; 20  Sound Test (negative → LevelSelect_Return)
LevSel_PtrsEnd:	even

LevelSelect_SwitchTable:
		dc.b $F		; 0   GHZ1 → SBZ1
		dc.b $10	; 1   GHZ2 → SBZ2
		dc.b $11	; 2   GHZ3 → SBZ3/LZ4
		dc.b $12	; 3   MZ1  → FZ
		dc.b $12	; 4   MZ2  → FZ
		dc.b $12	; 5   MZ3  → FZ
		dc.b $13	; 6   SYZ1 → Special
		dc.b $13	; 7   SYZ2 → Special
		dc.b $13	; 8   SYZ3 → Special
		dc.b $14	; 9   LZ1  → Ending
		dc.b $14	; $A  LZ2  → Ending
		dc.b $14	; $B  LZ3  → Ending
		dc.b $15	; $C  SLZ1 → Sound Test
		dc.b $15	; $D  SLZ2 → Sound Test
		dc.b $15	; $E  SLZ3 → Sound Test
		dc.b 0		; $F  SBZ1 → GHZ1
		dc.b 1		; $10 SBZ2 → GHZ2
		dc.b 2		; $11 SBZ3/LZ4 → GHZ3
		dc.b 3		; $12 FZ → MZ1
		dc.b 6		; $13 Special → SYZ1
		dc.b 9		; $14 Ending → LZ1
		dc.b $C		; $15 Sound Test → SLZ1
		even

; loc_95B8:
LevelSelect_MarkFields:
		lea	(v_ram_start).l,a4
		lea	(LevSel_MarkTable).l,a5
		lea	(vdp_data_port).l,a6
		moveq	#0,d0
		move.w	(v_levselzone).w,d0
		lsl.w	#2,d0
		lea	(a5,d0.w),a3
		moveq	#0,d0
		move.b	(a3),d0
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea	(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#-$4000,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#$4000,d1
		swap	d1
		move.l	d1,4(a6)

		moveq	#$D,d2
.drawloop:
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a6)
		dbf	d2,.drawloop

		addq.w	#2,a3
		moveq	#0,d0
		move.b	(a3),d0
		beq.s	.chksoundtest
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea	(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#-$4000,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#$4000,d1
		swap	d1
		move.l	d1,4(a6)
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a6)

.chksoundtest:
		cmpi.w	#$15,(v_levselzone).w
		bne.s	.rts
		bsr.w	LevelSelect_DrawSoundNumber
.rts:
		rts

; byte_96EE:
LevSel_MarkTable:	; 4 bytes per level select entry
; line primary, 2*column ($E fields), line secondary, 2*column secondary (1 field)
		dc.b   3,  6,  3,$24	; 0   GHZ1
		dc.b   3,  6,  4,$24	; 1   GHZ2
		dc.b   3,  6,  5,$24	; 2   GHZ3
		dc.b   7,  6,  7,$24	; 3   MZ1
		dc.b   7,  6,  8,$24	; 4   MZ2
		dc.b   7,  6,  9,$24	; 5   MZ3
		dc.b  $B,  6, $B,$24	; 6   SYZ1
		dc.b  $B,  6, $C,$24	; 7   SYZ2
		dc.b  $B,  6, $D,$24	; 8   SYZ3
		dc.b  $F,  6, $F,$24	; 9   LZ1
		dc.b  $F,  6,$10,$24	; $A  LZ2
		dc.b  $F,  6,$11,$24	; $B  LZ3
		dc.b $13,  6,$13,$24	; $C  SLZ1
		dc.b $13,  6,$14,$24	; $D  SLZ2
		dc.b $13,  6,$15,$24	; $E  SLZ3
		; --- second column ---
		dc.b   3,$2C,  3,$48	; $F  SBZ1
		dc.b   3,$2C,  4,$48	; $10 SBZ2
		dc.b   3,$2C,  5,$48	; $11 SBZ3/LZ4
		dc.b   7,$2C,  7,$48	; $12 FZ
		dc.b  $B,$2C, $B,$48	; $13 Special
		dc.b  $F,$2C, $F,$48	; $14 Ending
		dc.b $12,$2C,$12,$48	; $15 Sound Test

; loc_9688:
LevelSelect_DrawIcon:
		move.w	(v_levselzone).w,d0
		lea	(LevSel_IconTable).l,a3
		lea	(a3,d0.w),a3
		lea	(v_ram_start+$8C0).l,a1
		moveq	#0,d0
		move.b	(a3),d0
		lsl.w	#3,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(a1,d0.w),a1
		move.l	#$4B360003,d0
		moveq	#4-1,d1
		moveq	#3-1,d2
		bsr.w	TilemapToVRAM
		lea	(Pal_LevelSelectIcons).l,a1
		moveq	#0,d0
		move.b	(a3),d0
		lsl.w	#5,d0
		lea	(a1,d0.w),a1
		lea	(v_palette+$40).w,a2
		; Prepare the VDP for data transfer.
		move.l	#$C0400000,vdp_control_port-vdp_data_port(a6)
		moveq	#7,d1
.paletteloop:
		; Upload colours to the VDP.
		move.l	(a1),(a6)
		move.l	(a1)+,(a2)+
		dbf	d1,.paletteloop
		rts

; byte_96D8:
LevSel_IconTable:
		dc.b 0,0,0	; 0   GHZ
		dc.b 1,1,1	; 3   MZ
		dc.b 2,2,2	; 6   SYZ
		dc.b 3,3,3	; 9   LZ
		dc.b 4,4,4	; $C  SLZ
		dc.b 5,5,8	; $F  SBZ
		dc.b 6		; $12 FZ
		dc.b 7		; $13 Special Stage
		dc.b 0		; $14 Ending
		dc.b 17		; $15 Sound Test
		even

; loc_965A:
LevelSelect_DrawSoundNumber:
		move.l	#$49440003,(vdp_control_port).l
		move.w	(v_levselsound).w,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.s	.writedigit
		move.b	d2,d0

.writedigit:
		andi.w	#$F,d0
		cmpi.b	#$A,d0
		blo.s	.noadjust
		addi.b	#4,d0

.noadjust:
		addi.b	#$10,d0
		add.w	d3,d0
		move.w	d0,(a6)
		rts

; loc_9746:
CheckCheats:
		move.w	(v_cheatcount1).w,d0		; Get the number of correct sound IDs entered so far
		adda.w	d0,a0				; Skip to the next entry
		move.w	(v_levselsound).w,d0		; Get the current sound test sound
		cmp.b	(a0),d0				; Compare it to the cheat
		bne.s	.nomatch1			; If they're different, branch
		addq.w	#1,(v_cheatcount1).w		; Add 1 to the number of correct entries
		tst.b	1(a0)				; Is the next entry 0?
		bne.s	.chk2				; If not, branch
		move.b	#1,(f_debugcheat).w		; Enable the cheat
		move.b	#sfx_Ring,d0			; Play the ring sound
		bsr.w	QueueSound1
		clr.w	(v_cheatcount1).w
		bra.s	.rts
.nomatch1:
		clr.w	(v_cheatcount1).w		; Clear the number of correct entries
.chk2:
		move.w	(v_cheatcount2).w,d0		; Do the same procedure with the other cheat
		adda.w	d0,a2
		move.w	(v_levselsound).w,d0
		cmp.b	(a2),d0
		bne.s	.nomatch2
		addq.w	#1,(v_cheatcount2).w
		tst.b	1(a2)
		bne.s	.rts
		move.b	#6,(v_emeralds).w		; Give all 6 chaos emeralds
		move.b	#bgm_Emerald,d0			; Play the emerald jingle
		bsr.w	QueueSound1
		clr.w	(v_cheatcount2).w
		bra.s	.rts
.nomatch2:
		clr.w	(v_cheatcount2).w		; Clear the number of correct entries
.rts:
		rts

LevSel_DebugCheat:
		; 19921124 = 24th November 1992 (Sonic 2sday)
		dc.b   1,   9,   9,   2,   1,   1,   2,   4,   0
		even

LevSel_EmeraldCheat:
		; 4126 = Genesis 41:26 (seven = number of Chaos Emeralds)
		dc.b   4,   1,   2,   6,   0
		even

Dynamic_Menu:
		lea	(v_menuanimtimer).w,a3
; loc_3FF30:
.customCounters:
		move.w	(a2)+,d6	; Get number of scripts in list
; loc_3FF32:
.loop:
		subq.b	#1,(a3)		; Tick down frame duration
		bcc.s	.nextscript	; If frame isn't over, move on to next script

		moveq	#0,d0
		move.b	1(a3),d0	; Get current frame
		cmp.b	6(a2),d0	; Have we processed the last frame in the script?
		blo.s	.notlastframe
		moveq	#0,d0		; If so, reset to first frame
		move.b	d0,1(a3)
; loc_3FF48:
.notlastframe:
		addq.b	#1,1(a3)	; Consider this frame processed; set counter to next frame
		move.b	(a2),(a3)	; Set frame duration to global duration value
		bpl.s	.globalduration
		; If script uses per-frame durations, use those instead
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)	; Set frame duration to current frame's duration value
; loc_3FF56:
.globalduration:
		; Get relative address of frame's art
		move.b	8(a2,d0.w),d0	; Get tile ID
		lsl.w	#5,d0		; Turn it into an offset
		; Get VRAM destination address
		move.w	4(a2),d2
		; Get ROM source address
		move.l	(a2),d1		; Get start address of animated tile art
		andi.l	#$FFFFFF,d1
		add.l	d0,d1		; Offset into art, to get the address of new frame
		; Get size of art to be transferred
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3		; Turn it into actual size (in words)
		; Use d1, d2 and d3 to queue art for transfer
		jsr	(QueueDMATransfer).l
; loc_3FF78:
.nextscript:
		move.b	6(a2),d0	; Get total size of frame data
		tst.b	(a2)		; Is per-frame duration data present?
		bpl.s	.globalduration2
		add.b	d0,d0		; Double size to account for the additional frame duration data
; loc_3FF82:
.globalduration2:
		addq.b	#1,d0
		andi.w	#$FE,d0		; Round to next even address, if it isn't already
		lea	8(a2,d0.w),a2	; Advance to next script in list
		addq.w	#2,a3		; Advance to next script's slot in a3
		dbf	d6,.loop
		rts
; ===========================================================================
Anim_SonicMilesBG:
		dc.w   0
		dc.l $FF<<24|Art_MenuBackground
		dc.w $20
		dc.b 6
		dc.b $A
		dc.b   0,$C7
		dc.b  $A,  5
		dc.b $14,  5
		dc.b $1E,$C7
		dc.b $14,  5
		dc.b  $A,  5

; ---------------------------------------------------------------------------
; Change what you're selecting in the level select
; ---------------------------------------------------------------------------

LevSelControls:
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnUp|btnDn,d1
		bne.s	.ChkUpDown		; up/down pressed
		subq.w	#1,(v_levseldelay).w
		bpl.s	LevSelControls_CheckLR

.ChkUpDown:
		move.w	#$B,(v_levseldelay).w
		move.b	(v_jpadhold1).w,d1
		andi.b	#btnUp|btnDn,d1
		beq.s	LevSelControls_CheckLR	; up/down not pressed, check for left & right
		move.w	(v_levselzone).w,d0
		btst	#bitUp,d1
		beq.s	.ChkDown
		subq.w	#1,d0			; decrease by 1
		bcc.s	.ChkDown		; >= 0?
		moveq	#$15,d0			; set to $15

.ChkDown:
		btst	#bitDn,d1
		beq.s	.ChkUp
		addq.w	#1,d0			; yes, add 1
		cmpi.w	#$16,d0
		blo.s	.ChkUp			; smaller than $16?
		moveq	#0,d0			; if not, set to 0

.ChkUp:
		move.w	d0,(v_levselzone).w
		rts
; ===========================================================================
LevSelControls_CheckLR:
		cmpi.w	#$15,(v_levselzone).w	; are we in the sound test?
		bne.s	LevSelControls_SwitchSide	; no
		move.w	(v_levselsound).w,d0
		move.b	(v_jpadpress1).w,d1
		btst	#bitL,d1
		beq.s	.chkright
		subq.b	#1,d0

.chkright:
		btst	#bitR,d1
		beq.s	.chkA
		addq.b	#1,d0

.chkA:
		btst	#bitA,d1
		beq.s	.changesound
		addi.b	#$10,d0
		bcc.s	.changesound
		moveq	#0,d0

.changesound:
		move.w	d0,(v_levselsound).w
		andi.w	#btnBC,d1
		beq.s	.rts			; rts
		move.w	(v_levselsound).w,d0
		bsr.w	QueueSound1
		lea	(LevSel_DebugCheat).l,a0
		lea	(LevSel_EmeraldCheat).l,a2
		bsr.w	CheckCheats

.rts:
		rts
; ===========================================================================
LevSelControls_SwitchSide:	; not in sound test, not up/down pressed
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnL|btnR,d1
		beq.s	.rts			; no direction key pressed
		move.w	(v_levselzone).w,d0	; left or right pressed
		lea	LevelSelect_SwitchTable(pc),a0
		move.b	(a0,d0.w),d0
		move.w	d0,(v_levselzone).w
.rts:
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select codes
; ---------------------------------------------------------------------------

LevSelCode_J:
	if Revision=0
		dc.b btnUp,btnDn,btnL,btnR,0,$FF
	else
		dc.b btnUp,btnDn,btnDn,btnDn,btnL,btnR,0,$FF
	endif
		even

LevSelCode_US:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even

; ---------------------------------------------------------------------------
; Level Select (backported and modified from Sonic 2)
; ---------------------------------------------------------------------------

GM_LevelSelect:
		; --- Fade out and clear screen ---
		bsr.w	PaletteFadeOut
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)	; PNT A base: $C000
		move.w	#$8407,(a6)	; PNT B base: $E000
		move.w	#$8700,(a6)	; BG colour: palette 0 / colour 0
		move.w	#$8C81,(a6)	; H res 40 cells
		move.w	#$9001,(a6)	; Scroll table: 64x32

		clearRAM v_objspace

		ResetDMAQueue

		; --- Load menu font and zone icon art ---
		moveq	#plcid_S2LevSel,d0	; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		; Background - Load mappings first, tiles will be dynamically loaded
		lea	(v_ram_start).l,a1
		lea	(Eni_MenuBackground).l,a0
		move.w	#$6000,d0
		bsr.w	EniDec
		copyTilemap	v_ram_start, vram_bg, 40, 28

		; --- Load level select foreground layout ---
		lea	(v_ram_start).l,a1
		lea	(Eni_LevelSelect).l,a0
		moveq	#0,d0
		bsr.w	EniDec
		copyTilemap	v_ram_start, vram_fg, 40, 28

		moveq	#0,d3
		bsr.w	LevelSelect_DrawSoundNumber

		; Decode icon tilemap into scratch RAM, then draw the initial icon
		lea	(v_ram_start+$8C0).l,a1
		lea	(Eni_LevelSelectIcons).l,a0
		move.w	#make_art_tile(ArtTile_LevelSelectIcons,0,0),d0
		bsr.w	EniDec
		bsr.w	LevelSelect_DrawIcon

		clearRAM v_palette_fading
		clr.w	(v_cheatcount1).w
		clr.w	(v_cheatcount2).w

		; Kick off background animation and load palette with fade
		clr.w	(v_menuanimtimer).w
		lea	(Anim_SonicMilesBG).l,a2
		jsr	Dynamic_Menu
		moveq	#palid_Menu,d0
		bsr.w	PalLoad_Fade

		; Copy icon palette line to fading palette, clear source so it fades in from black
		lea	(v_palette+$40).w,a1
		lea	(v_palette_fading+$40).w,a2
		moveq	#7,d1
.palinit:
		move.l	(a1),(a2)+
		clr.l	(a1)+
		dbf	d1,.palinit

		move.b	#bgm_Options,d0
		bsr.w	QueueSound1

		move.b	#$16,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Level Select main loop
; ---------------------------------------------------------------------------

; loc_93AC:
LevelSelect_MainLoop:	; routine running during level select
		move.b	#$16,(v_vblank_routine).w
		bsr.w	WaitForVBlank

		disable_ints

		moveq	#0,d3				; palette line << 13
		bsr.w	LevelSelect_MarkFields		; unmark fields
		bsr.w	LevSelControls			; possible change selected fields
		move.w	#$6000,d3			; palette line << 13
		bsr.w	LevelSelect_MarkFields		; mark fields

		bsr.w	LevelSelect_DrawIcon

		enable_ints

		lea	(Anim_SonicMilesBG).l,a2
		jsr	Dynamic_Menu

		move.b	(v_jpadpress1).w,d0
		andi.b	#btnStart,d0			; start pressed?
		bne.s	LevelSelect_PressStart		; yes
		bra.w	LevelSelect_MainLoop		; no
; ===========================================================================

; loc_93F0:
LevelSelect_PressStart:
		move.w	(v_levselzone).w,d0
		add.w	d0,d0
		lea	LevSel_Ptrs(pc),a0
		move.w	(a0,d0.w),d0
		bmi.w	LevelSelect_Return		; sound test
		cmpi.w	#(id_EndZ<<8),d0
		beq.s	LevelSelect_Ending
		cmpi.w	#(id_SS<<8),d0
		bne.w	LevelSelect_StartZone
		move.b	#id_Special,(v_gamemode).w	; => SpecialStage
		move.b	#3,(v_lives).w
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.l	d0,(v_score).w
		move.b	d0,(v_lastspecial).w
		move.b	d0,(v_emeralds).w
		move.l	d0,(v_emldlist).w
		move.l	d0,(v_emldlist+4).w
		move.b	d0,(v_continues).w
	if Revision<>0
		move.l	#5000,(v_scorelife).w
	endif
		rts
; ===========================================================================

; loc_944C:
LevelSelect_Return:
		move.b	#id_Sega,(v_gamemode).w	; => SegaScreen
		rts
; ===========================================================================
LevelSelect_Ending:
		move.b	#id_Ending,(v_gamemode).w
		move.w	d0,(v_zone).w
		rts
; ===========================================================================

; loc_9480:
LevelSelect_StartZone:
		andi.w	#$3FFF,d0
		move.w	d0,(v_zone).w
		bra.w	PlayLevel

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo mode loading routine
; ---------------------------------------------------------------------------

GotoDemo:	; wait half a second on the final frame of Sonic's finger wagging before going to demo
		move.w	#30,(v_generictimer).w			; set timeout to 30 frames

; loc_33B6:
GotoDemo_PreDelayLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	DeformLayers				; run background deformation
		bsr.w	PaletteCycle				; run normal palette cycle routine (this briefly uses GHZ's cycle)

		move.w	(v_player+obX).w,d0			; get current title screen position (big Sonic object)
		addq.w	#2,d0					; move it 2px to the right
		move.w	d0,(v_player+obX).w			; write new X position
		cmpi.w	#$1C00,d0				; has Sonic object passed $1C00 on x-axis?
		blo.s	GotoDemo_ChkLoop			; if not, branch
		; Will never happen due to the short title screen generic timer.
		; This likely was an old failsafe before Demos were introduced.
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		rts
; ===========================================================================

; loc_33E4:
GotoDemo_ChkLoop:
		andi.b	#btnStart,(v_jpadpress1).w		; has Start button been pressed during pre-delay?
		bne.w	Tit_ChkLevSel				; if yes, abort loading demo and load normal level instead
		tst.w	(v_generictimer).w			; has pre-delay timer expired?
		bne.w	GotoDemo_PreDelayLoop			; if not, branch
; ---------------------------------------------------------------------------

		; start loading demo now
		move.b	#bgm_Fade,d0				; set music fade-out command
		bsr.w	QueueSound2				; fade out music

		move.w	(v_demonum).w,d0			; load demo number
		andi.w	#7,d0					; limit to four demo entries
		add.w	d0,d0					; double for word-based indexing
		move.w	Demo_Levels(pc,d0.w),d0			; load level number for demo
		move.w	d0,(v_zone_act).w			; set level for demo

		addq.w	#1,(v_demonum).w			; add 1 to demo number
		cmpi.w	#4,(v_demonum).w			; is demo number less than 4?
		blo.s	GotoDemo_NoReset			; if yes, branch
		move.w	#0,(v_demonum).w			; reset demo number to 0

; loc_3422:
GotoDemo_NoReset:
		move.w	#1,(f_demo).w				; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w			; set game mode to 08 (demo)

		cmpi.w	#$600,d0				; is level number 0600 (Special Stage dummy value)?
		bne.s	GotoDemo_NotSS				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set game mode to $10 (Special Stage)
		clr.w	(v_zone_act).w				; clear level number
		clr.b	(v_lastspecial).w			; clear special stage number to play demo in stage 1

; Demo_Level:
GotoDemo_NotSS:
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; clear d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
	if Revision<>0
		move.l	#5000,(v_scorelife).w			; extra life is awarded at 50000 points
	endif
		rts						; return to MainGameLoop to start demo
; End of function GotoDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------

Demo_Levels:	; previously in "misc/Demo Level Order - Intro.bin"
		dc.w id_GHZ_act1
		dc.w id_MZ_act1
		dc.w id_SYZ_act1
		dc.w $600 ; used as dummy value to start the Special Stage demo
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Music playlist for the start of a level. Note that restarting the music
; after invincibility has worn off is controlled in MusicList2 (part of
; Sonic's object). Bosses have the post-defeat music hardcoded.
; ---------------------------------------------------------------------------

MusicList:
		dc.b bgm_GHZ		; GHZ 1
		dc.b bgm_GHZ2		; GHZ 2
		dc.b bgm_GHZ3		; GHZ 3
		dc.b bgm_GHZ2		; GHZ 4 (unused)

		dc.b bgm_LZ		; LZ 1
		dc.b bgm_LZ		; LZ 2
		dc.b bgm_LZ		; LZ 3
		dc.b bgm_SBZ		; LZ 4 (SBZ act 3)

		dc.b bgm_MZ		; MZ 1
		dc.b bgm_MZ		; MZ 2
		dc.b bgm_MZ		; MZ 3
		dc.b bgm_MZ		; MZ 4 (unused)

		dc.b bgm_SLZ		; SLZ 1
		dc.b bgm_SLZ		; SLZ 2
		dc.b bgm_SLZ		; SLZ 3
		dc.b bgm_SLZ		; SLZ 4 (unused)

		dc.b bgm_SYZ		; SYZ 1
		dc.b bgm_SYZ		; SYZ 2
		dc.b bgm_SYZ		; SYZ 3
		dc.b bgm_SYZ		; SYZ 4 (unused)

		dc.b bgm_SBZ		; SBZ 1
		dc.b bgm_SBZ		; SBZ 2
		dc.b bgm_FZ		; SBZ 3 (Final Zone)
		dc.b bgm_SBZ		; SBZ 4 (unused)

		even
; ===========================================================================

PlayCurrentActMusic:
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current zone ID
		lsl.b	#2,d0					; times four entries per zone
		add.b	(v_act).w,d0				; add current act number
		move.b	MusicList(pc,d0.w),d0			; find music ID from MusicList
		bra.w	QueueSound1				; play current level music
; End of function PlayCurrentActMusic

; ===========================================================================
; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

; Level:
GM_Level:	; fading out from previous game mode
		bset	#7,(v_gamemode).w			; add $80 to screen mode (for pre level sequence)

		tst.w	(f_demo).w				; is an ending sequence demo running?
		bmi.s	Level_NoMusicFade			; if yes, don't fade out music
		move.b	#bgm_Fade,d0				; queue music fade-out command
		bsr.w	QueueSound2				; fade out music

Level_NoMusicFade:
		bsr.w	ClearPLC				; clear any remaining PLC entries
		bsr.w	PaletteFadeOut				; fade out from the previous screen
; ---------------------------------------------------------------------------

		; load title cards, queue PLCs, setup screen, play music
		tst.w	(f_demo).w				; is an ending sequence demo running?
		bmi.s	Level_ClrRam				; if yes, don't load title screen or main level patterns

		jsr	(TitleCards_LoadArt).l		; load level title card graphics

		jsr	(GetLevelHeader).l			; load level header for current zone/act into a2
		moveq	#0,d0					; clear d0
		move.b	(a2),d0					; get first PLC entry
		beq.s	Level_NoPLC				; if it's null, branch (never the case)
		bsr.w	AddPLC					; load level patterns for current Zone
; loc_37FC:
Level_NoPLC:
		moveq	#plcid_Main2,d0				; load secondary standard patterns (monitors, etc.)
		bsr.w	AddPLC					; (these can be overwritten by stuff like the sign post art)

Level_ClrRam:
		clearRAM v_objspace				; clear object RAM
		clearRAM v_misc_variables			; clear various miscellaneous RAM
		clearRAM v_levelvariables			; clear level variables RAM (camera position, etc.)
		clearRAM v_timingandscreenvariables		; clear various timing and screen RAM (for animated tiles, etc.)

		disable_ints					; disable interrupts
		bsr.w	ClearScreen				; wipe the screen
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_spritevram|(vram_sprites>>9),(a6)	; set sprite table address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (line 3; colour 0)
		move.w	#vreg_hintrate|223,(v_hblank_hreg).w	; set palette change position (for water)
		move.w	(v_hblank_hreg).w,(a6)			; write to VDP

		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
		bne.s	Level_LoadPal				; if not, branch
		move.w	#vreg_mode1|%010100,(a6)		; enable horizontal interrupts (HBlank)
		moveq	#0,d0					; clear d0
		move.b	(v_act).w,d0				; get current LZ act
		add.w	d0,d0					; double for word-based indexing
		lea	(WaterHeight).l,a1			; load water height array
		move.w	(a1,d0.w),d0				; get water height entries for current LZ act
		move.w	d0,(v_waterpos1).w			; set water height (actual)
		move.w	d0,(v_waterpos2).w			; set water height (ignoring surface sway)
		move.w	d0,(v_waterpos3).w			; set water height (target)
		clr.b	(v_wtr_routine).w			; clear water routine counter
		clr.b	(f_wtr_state).w				; clear water state
		move.b	#1,(f_water).w				; enable water

Level_LoadPal:
		move.w	#30,(v_air).w				; set Sonic's air timer to 30 seconds
		enable_ints					; enable interrupts

		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad					; ...directly to active palette (for title cards)
		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
		bne.s	Level_GetBgm				; if not, branch
		moveq	#palid_LZSonWater,d0			; palette number $F (LZ)
		cmpi.b	#act4,(v_act).w				; check if on act 4 (for SBZ3/LZ4)?
		bne.s	Level_WaterPal				; if not, branch
		moveq	#palid_SBZ3SonWat,d0			; palette number $10 (SBZ3)

Level_WaterPal:
		bsr.w	PalLoad_Fade_Water			; load underwater palette
		tst.b	(v_lastlamp).w				; are we respawning from a checkpoint?
		beq.s	Level_GetBgm				; if not, branch
		move.b	(v_lamp_wtrstat).w,(f_wtr_state).w	; restore water state from checkpoint



Level_GetBgm:
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; transfer data up to this point
		bsr.w	LoadZoneTiles				; load main zone art (S2 Art Loader)
		tst.w	(f_demo).w				; is this a credits demo?
		bmi.s	Level_SkipTtlCard			; if yes, don't load title cards or change music

		bsr.w	PlayCurrentActMusic			; play music for current act

		move.b	#id_TitleCard,(v_titlecard).w		; load title card object
; ---------------------------------------------------------------------------

Level_TtlCardLoop: ; move in title cards, stay on them until PLCs have finished
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		jsr	(ExecuteObjects).l			; execute title cards object
		jsr	(BuildSprites).l			; build sprites to show title cards
	if FixBugs=0
		move.w	(v_ttlcardact+obX).w,d0			; get current position of the "ACT" element of the title cards
		cmp.w	(v_ttlcardact+card_mainX).w,d0		; has "ACT" element reached its target position?
		bne.s	Level_TtlCardLoop			; if not, loop until it has
	else
		; Check if *every* title card element has reached their target position.
		; Decompression is normally slow enough that every element is able
		; to reach their target position before it's finished, but if
		; decompression is upgraded with something faster, then the risk
		; of decompression finishing and exiting this loop before all of the title
		; card is finished moving into place is increased.
		lea	(v_titlecard).w,a0			; get title card elements
		moveq	#4-1,d1					; number of title card elements

Level_CheckTtlCard:
		move.w	obX(a0),d0				; get current position of a title card element
		cmp.w	card_mainX(a0),d0			; has this title card element reached its target position?
		bne.s	Level_TtlCardLoop			; if not, loop until it has
		lea	object_size(a0),a0			; next title card element
		dbf	d1,Level_CheckTtlCard			; loop until every element has reached its target position
	endif
		tst.l	(v_plc_buffer).w			; have patterns been fully decompressed and loaded?
		bne.s	Level_TtlCardLoop			; if not, loop until they have
; ---------------------------------------------------------------------------

		; PLCs have finished, load/initialize remaining data

	if FixBugs
		; Do VBlank for one extra frame to provide enough processing time
		; for the remaining data initialization below. Without it, it's
		; possible for VBlank to interrupt in the middle of a transfer,
		; resulting in visual corruption. This will also make title cards
		; smoother should decompression get upgraded with something faster.
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
	endif

		jsr	(Hud_Base).l				; load basic HUD graphics (only in levels, not in the ending demos)

Level_SkipTtlCard:
		bsr.w	InitRingFrame
		moveq	#palid_Sonic,d0				; load Sonic's palette to fade-in buffer
		bsr.w	PalLoad_Fade				; (doesn't actually do anything, the PalFadeIn_Alt call below skips the first palette line)
		bsr.w	LevelSizeLoad				; load level size and set default level boundaries
		bsr.w	DeformLayers				; initialize background deformation
		bset	#2,(v_fg_scroll_flags).w		; draw an extra column at the left side of the screen during level start
		bsr.w	LevelDataLoad				; load block mappings and palettes
		bsr.w	LoadTilesFromStart			; fully draw the foreground and background once before fade-in
		jsr	(ConvertCollisionArray).l		; call a routine that immediately returns (this is a disabled development function)
		bsr.w	ColIndexLoad				; set collision index for current zone
		bsr.w	LZWaterFeatures				; initialize water features if zone is LZ

		move.b	#id_SonicPlayer,(v_player).w		; load Sonic object

		tst.w	(f_demo).w				; is this a credits demo?
		bmi.s	Level_ChkDebug				; if yes, don't load HUD
		move.b	#1,(v_draw_hud).w			; enable HUD drawing

Level_ChkDebug:
		tst.b	(f_debugcheat).w			; has debug cheat been entered?
		beq.s	Level_ChkWater				; if not, branch
		btst	#bitA,(v_jpadhold1).w			; is A button held?
		beq.s	Level_ChkWater				; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode

Level_ChkWater:
		move.w	#0,(v_jpadhold2).w			; clear button input states for Sonic player object
		move.w	#0,(v_jpadhold1).w			; clear actual button input states for controller 1

;		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
;		bne.s	Level_LoadObj				; if not, branch
;		move.b	#id_WaterSurface,(v_watersurface1).w	; load water surface object A
;		move.w	#$60,(v_watersurface1+obX).w		; set base X-position for surface A
;		move.b	#id_WaterSurface,(v_watersurface2).w	; load water surface object B
;		move.w	#$120,(v_watersurface2+obX).w		; set base X-position for surface B

Level_LoadObj:
		cmpi.b	#id_SLZ,(v_zone).w	; are we in SLZ?
		bne.s	.nopylon		; if not, don't load pylon
		jsr	(FindFreeObj).l		; find a free object slot
		bne.s	.nopylon		; if none are free, branch
		move.b	#id_Pylon,(a1)		; manually load SLZ pylon
.nopylon:
		jsr	(ObjPosLoad).l				; initialize object manager
		jsr	(ExecuteObjects).l			; load objects that are already visible during fade-in
		jsr	(BuildSprites).l			; build sprites for objects before fade-in

		moveq	#0,d0					; clear d0
		tst.b	(v_lastlamp).w				; are we starting from a lamppost?
		bne.s	Level_SkipClr				; if yes, branch
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.b	d0,(v_lifecount).w			; clear extra lives flags when getting 100/200 rings

Level_SkipClr:
		move.b	d0,(f_timeover).w			; clear time over flag
		move.b	d0,(v_shield).w				; clear shield
		move.b	d0,(v_shieldtype).w				; clear shield type
		move.b	d0,(v_invinc).w				; clear invincibility
		move.b	d0,(v_shoes).w				; clear speed shoes
		move.b	d0,(v_supersonic).w		; <-- add this
		move.b	d0,(v_ssframe).w		; <-- add this
		move.w	d0,(v_debuguse).w			; exit debug mode if necessary
		move.w	d0,(f_restart).w			; clear level restart flag
		move.w	d0,(v_framecount).w			; reset frames since level start to 0
		bsr.w	OscillateNumInit			; initialize oscillation values
		move.b	#1,(f_scorecount).w			; update score counter
		move.b	#1,(f_ringcount).w			; update rings counter
		move.b	#1,(f_timecount).w			; update time counter

		move.w	#0,(v_btnpushtime1).w			; clear button push counters for demos
		lea	(DemoDataPtr).l,a1			; load demo data
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current Zone ID
		lsl.w	#2,d0					; multiply by 4 for longword-based indexing
		movea.l	(a1,d0.w),a1				; get demo pointer for current level
		tst.w	(f_demo).w				; are we in a regular (not-credits) demo?
		bpl.s	Level_Demo				; if yes, branch
		lea	(DemoEndDataPtr).l,a1			; load ending demo data
		move.w	(v_creditsnum).w,d0			; get current credits page
		subq.w	#1,d0					; subtract by 1
		lsl.w	#2,d0					; multiply by 4 for longword-based indexing
		movea.l	(a1,d0.w),a1				; get demo pointer for current credits page

Level_Demo:
		move.b	1(a1),(v_btnpushtime2).w		; load initial demo key press duration
		subq.b	#1,(v_btnpushtime2).w			; subtract 1 from demo key pressduration
		move.w	#1800,(v_generictimer).w		; run regular demos for 30 seconds
		tst.w	(f_demo).w				; is this a regular (not-credits) demo?
		bpl.s	Level_ChkWaterPal			; if not, branch
		move.w	#540,(v_generictimer).w			; run credits demos for 9 seconds each
		cmpi.w	#4,(v_creditsnum).w			; is this credits demo 4? (Labyrinth)
		bne.s	Level_ChkWaterPal			; if not, branch
		move.w	#510,(v_generictimer).w			; run this specific demo for 0.5 seconds less

Level_ChkWaterPal:
		cmpi.b	#id_LZ,(v_zone).w			; is level LZ/SBZ3?
		bne.s	Level_Delay				; if not, branch
		moveq	#palid_LZWater,d0			; palette $B (LZ underwater)
		cmpi.b	#act4,(v_act).w				; check if on act 4 (for SBZ3/LZ4)
		bne.s	Level_WtrNotSbz				; if not, branch
		moveq	#palid_SBZ3Water,d0			; palette $D (SBZ3 underwater)

Level_WtrNotSbz:
		bsr.w	PalLoad_Water				; load underwater palette to active palette

Level_Delay:
		move.w	#$202F,(v_pfade_start).w		; set to fade in 2nd, 3rd & 4th palette lines
		bsr.w	PalFadeIn_Alt				; fade-in main palette
; ---------------------------------------------------------------------------

		; level has faded in, make title cards move and enter main loop
		tst.w	(f_demo).w				; is an ending sequence demo running?
		bmi.s	Level_ClrCardArt			; if yes, load explosion and animal graphics now
		addq.b	#2,(v_ttlcardname+obRoutine).w		; make title card move (name)
		addq.b	#4,(v_ttlcardzone+obRoutine).w		; make title card move ("ZONE")
		addq.b	#4,(v_ttlcardact+obRoutine).w		; make title card move ("ACT")
		addq.b	#4,(v_ttlcardoval+obRoutine).w		; make title card move (blue oval)
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrCardArt:
		; This portion is only for the credits demos to loads explosions
		; and animal graphics right now, as normally they get loaded by
		; the title cards (which aren't loaded for credits demos).
		moveq	#plcid_Explode,d0			; load explosion graphics
		jsr	(AddPLC).l				; queue PLC
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current Zone ID
		addi.w	#plcid_GHZAnimals,d0			; add offset to animal patterns (+$15)
		jsr	(AddPLC).l				; load animal patterns

Level_StartGame:
		bclr	#7,(v_gamemode).w			; subtract $80 from mode to end pre-level stuff
		; enter main loop...

; ---------------------------------------------------------------------------
; Main level loop (when all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame				; handle pausing the game when pressing start
		move.b	#id_VBlank_Levels,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		bsr.w	MoveSonicInDemo				; simulate controls in demos (immediately returns outside demos)
		bsr.w	LZWaterFeatures				; apply water features if in Labyrinth Zone
		jsr	(ExecuteObjects).l			; execute all objects in object RAM

	if FixBugs
		tst.w	(f_restart).w				; is the level set to restart?
		bne.s	Level_CheckRestart			; if yes, branch to check restart condition
	elseif Revision<>0
		; For REV01, this code has been relocated from below to avoid brief visual glitches
		; as a result of the zone ID changing. This, however, had the side effect of demos
		; restarting if Sonic dies, rather than immediately going to the next game mode.
		; In the case of the ending demos, it could result in the credits getting aborted.
		tst.w	(f_restart).w				; is the level set to restart?
		bne.w	GM_Level				; if yes, restart level immediately
	endif

		tst.w	(v_debuguse).w				; is debug mode being used?
		bne.w	Level_DoScroll				; if yes, continue plane scrolling even when dying
		;cmpi.b	#6,(v_player+obRoutine).w		; has Sonic just died?
		;bhs.s	Level_SkipScroll			; if yes, don't do plane scrolling

Level_DoScroll:
		bsr.w	DeformLayers				; scroll planes and do background deformation

Level_SkipScroll:
		jsr	(BuildSprites).l			; build sprite table
		jsr	(ObjPosLoad).l				; run the object manager to load level objects
		bsr.w	PaletteCycle				; run palette cycles
		bsr.w	OscillateNumDo				; advance oscillation values
		bsr.w	SynchroAnimate				; advance animation timers
		bsr.w	SignpostArtLoad				; check if sign post art needs to be loaded and lock left boundary

Level_CheckRestart:
		cmpi.b	#id_Demo,(v_gamemode).w			; are we in a demo?
		beq.s	Level_ChkDemo				; if yes, branch
	if FixBugs|(Revision=0)
		tst.w	(f_restart).w				; is the level set to restart?
		bne.w	GM_Level				; if yes, restart leve
	endif
		cmpi.b	#id_Level,(v_gamemode).w		; is game mode still set to level?
		beq.w	Level_MainLoop				; if yes, loop level game mode
		rts						; if game mode changed, return to MainGameLoop
; ===========================================================================

Level_ChkDemo:
		tst.w	(f_restart).w				; is level set to restart?
		bne.s	Level_EndDemo				; if yes, branch
		tst.w	(v_generictimer).w			; is there time left on the demo?
		beq.s	Level_EndDemo				; if not, branch
		cmpi.b	#id_Demo,(v_gamemode).w			; is game mode still demo?
		beq.w	Level_MainLoop				; if yes, loop level game mode
		move.b	#id_Sega,(v_gamemode).w			; otherwise, return to Sega screen
		rts						; return to MainGameLoop
; ===========================================================================

Level_EndDemo:
		cmpi.b	#id_Demo,(v_gamemode).w			; is game mode still demo?
		bne.s	Level_FadeDemo				; if not, slowly fade-out demo
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		tst.w	(f_demo).w				; is demo mode on & not ending sequence?
		bpl.s	Level_FadeDemo				; if yes, branch
		move.b	#id_Credits,(v_gamemode).w		; return to credits game mode (next credits page)

Level_FadeDemo:
		move.w	#60,(v_generictimer).w			; run fade-out for one second
		move.w	#$003F,(v_pfade_start).w		; set palette fade-out position and size
		clr.w	(v_palchgspeed).w			; do first palette dimming immediately

Level_FDLoop:
		move.b	#id_VBlank_Levels,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		bsr.w	MoveSonicInDemo				; continue updating demo controls during fade-out
		jsr	(ExecuteObjects).l			; continue executing objects during fade-out
		jsr	(BuildSprites).l			; continue building sprites during fade-out
		jsr	(ObjPosLoad).l				; continue running object manager during fade-out

		subq.w	#1,(v_palchgspeed).w			; decrement palette fade-out delay
		bpl.s	Level_FDLoop_NoDim			; if time remains, branch
		move.w	#2,(v_palchgspeed).w			; reset palette fade-out delay
		bsr.w	FadeOut_ToBlack				; dim palette further

; loc_3BC8:
Level_FDLoop_NoDim:
		tst.w	(v_generictimer).w			; has fade-out loop finished?
		bne.s	Level_FDLoop				; if not, loop
		rts						; return to MainGameLoop
; End of function GM_Level

; ===========================================================================
; >>> Misc level logic for specific circumstances
	include	"_inc/LZWaterFeatures.asm"
	include	"_inc/MoveSonicInDemo.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; ---------------------------------------------------------------------------

ColIndexLoad:
		jsr	(GetLevelHeader).l			; load level header for current zone/act into a2
		move.l	$C(a2),d0				; get collision/palette entry from level header
		lsr.l	#8,d0					; shift out palette to only have collision index left
		move.l	d0,(v_collindex).w			; write collision index to RAM
		rts

; ===========================================================================
; >>> Routines to set and update values that change on a fixed timer
	include	"_inc/Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; Queue ring frame graphics loading
; ---------------------------------------------------------------------------

InitRingFrame:
		st.b	(v_ani1_prev).w			; Make sure initial frame art loads
		st.b	(v_ani2_prev).w
		st.b	(v_ani3_prev).w

LoadRingFrame:
		cmpi.b	#6,(v_player+obRoutine).w	; Is Sonic dead?
		jhs	.end				; If so, branch

		moveq	#0,d1				; Get ring frame offset for regular rings
		move.b	(v_ani1_frame).w,d1
		cmp.b	(v_ani1_prev).w,d1		; Has it changed?
		beq.s	.noring				; If not, branch
		move.b	d1,(v_ani1_prev).w		; Mark frame's art as loaded

		lsl.l	#7,d1				; Each ring frame takes $80 bytes, so multiply by $80
		addi.l	#Art_Ring,d1			; Queue a DMA transfer for this ring frame
		move.w	#ArtTile_Ring*tile_size,d2
		move.w	#$80/2,d3
		jsr	(QueueDMATransfer).l		; (or DMA_68KtoVRAM)

.noring:
		cmpi.b	#id_Special,(v_gamemode).w	; Are we in a special stage?
		beq.s	.end				; If so, branch

		tst.b	(v_gfxbigring).w		; Is a there a special stage ring?
		beq.s	.nossring			; If not, branch

		move.l	#Art_BigRing,d2			; Use normal special stage ring graphics
		cmpi.b	#1,(v_gfxbigring).w		; Should we be using them?
		beq.s	.loadssring			; If so, branch
		move.l	#Art_BigFlash,d2		; Use special stage ring flash graphics

.loadssring:
		moveq	#0,d1				; Get ring frame offset for special stage rings
		move.b	(v_ani2_frame).w,d1
		cmp.b	(v_ani2_prev).w,d1		; Has it changed?
		beq.s	.nossring			; If not, branch
		move.b	d1,(v_ani2_prev).w		; Mark frame's art as loaded

		lsl.l	#8,d1				; Each giant ring frame takes $800 bytes, so multiply by $800
		lsl.l	#3,d1
		add.l	d2,d1				; Queue a DMA transfer for this ring frame
		move.w	#ArtTile_Giant_Ring*tile_size,d2
		move.w	#$800/2,d3
		jsr	(QueueDMATransfer).l		; (or DMA_68KtoVRAM)

.nossring:
		moveq	#0,d1				; Get ring frame offset for lost rings
		move.b	(v_ani3_frame).w,d1
		cmp.b	(v_ani3_prev).w,d1		; Has it changed?
		beq.s	.end				; If not, branch
		move.b	d1,(v_ani3_prev).w		; Mark frame's art as loaded

		lsl.l	#7,d1				; Each ring frame takes $80 bytes, so multiply by $80
		add.l	#Art_Ring,d1			; Queue a DMA transfer for this ring frame
		move.w	#ArtTile_Ring_Loss*tile_size,d2
		move.w	#$80/2,d3
		jmp	(QueueDMATransfer).l		; (or DMA_68KtoVRAM)

.end:
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change synchronised animation variables (rings, giant rings)
; ---------------------------------------------------------------------------

SynchroAnimate:
		bsr.w	LoadRingFrame
; Used for GHZ spiked log
Sync1:
		subq.b	#1,(v_ani0_time).w			; has first timer reached 0?
		bpl.s	Sync2					; if not, branch
		move.b	#12-1,(v_ani0_time).w			; reset first timer to 12 frames
		subq.b	#1,(v_ani0_frame).w			; go to next frame (backwards)
		andi.b	#7,(v_ani0_frame).w 			; limit to frames 0-7

; Used for rings
Sync2:
		subq.b	#1,(v_ani1_time).w
		bpl.s	Sync3
		move.b	#4-1,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#7,(v_ani1_frame).w

; Used for giant rings
Sync3:
		cmpi.b	#1,(v_gfxbigring).w
		bne.s	Sync4
		subq.b	#1,(v_ani2_time).w
		bpl.s	Sync4
		move.b	#4-1,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#7,(v_ani2_frame).w

; Used for bouncing rings
Sync4:
		tst.b	(v_ani3_time).w
		beq.s	SyncEnd
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0
		add.w	(v_ani3_buf).w,d0
		move.w	d0,(v_ani3_buf).w
		rol.w	#8,d0
		andi.w	#7,d0
		move.b	d0,(v_ani3_frame).w
		subq.b	#1,(v_ani3_time).w

SyncEnd:
		rts						; return
; End of function SynchroAnimate

; ===========================================================================
; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine. Also locks left boundary.
; ---------------------------------------------------------------------------

SignpostArtLoad:
		tst.w	(v_debuguse).w				; is debug mode being used?
		bne.w	.return					; if yes, do not lock screen or load art
		cmpi.b	#act3,(v_act).w				; is this a third act?
		beq.s	.return					; if yes, don't load art (due to the boss fight)

		move.w	(v_screenposx).w,d0			; get current X-camera position
		move.w	(v_limitright2).w,d1			; get right level boundary
		subi.w	#$100,d1				; check for $100 pixels before the right boundary
		cmp.w	d1,d0					; has Sonic reached the right edge of the level?
		blt.s	.return					; if not, branch

		tst.b	(f_timecount).w				; has time already stopped from touching the signpost?
		beq.s	.return					; if yes, branch
		cmp.w	(v_limitleft2).w,d1			; has left boundary already been locked?
		beq.s	.return					; if yes, branch
		move.w	d1,(v_limitleft2).w			; lock left level boundary to current screen position
		moveq	#plcid_Signpost,d0			; load signpost, hidden points, giant ring flash patterns
		bra.w	NewPLC					; add to new PLC queue

.return:
		rts						; return
; End of function SignpostArtLoad

; ===========================================================================
; >>> Demo inputs for title screen demos
Demo_GHZ:	include	"demodata/Intro - GHZ.asm"
Demo_MZ:	include	"demodata/Intro - MZ.asm"
Demo_SYZ:	include	"demodata/Intro - SYZ.asm"
Demo_SS:	include	"demodata/Intro - Special Stage.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

; SpecialStage:
GM_Special:		; white fade-out from previous game mode
		move.w	#sfx_EnterSS,d0				; set special stage entry sound
		bsr.w	QueueSound2				; play it
		bsr.w	PaletteWhiteOut				; fade-out to white
; ---------------------------------------------------------------------------

		; load special stage patterns
		disable_ints					; disable interrupts
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_hintrate|175,(v_hblank_hreg).w	; set HBlank counter to scanline 175 (even though horizontal interrupts aren't used here...)
		move.w	#$9011,(a6)				; 128-cell hscroll size
		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe screen
		enable_ints					; enable interrupts

		fillVRAM 0, ArtTile_SS_Plane_1*tile_size+plane_size_64x32, ArtTile_SS_Plane_5*tile_size ; clear nametables
		bsr.w	SS_BGLoad				; load background clouds/bubbles/birds/fish mappings
		moveq	#plcid_SpecialStage,d0			; load special stage patterns
		bsr.w	QuickPLC				; execute PLCs immediately (no queue)
		bsr.w	InitRingFrame

		clearRAM v_objspace				; clear object RAM space
		clearRAM v_levelvariables			; clear various level variables
		clearRAM v_timingvariables			; clear various timing variables
		clearRAM v_ngfx_buffer				; clear Nemesis decompression buffer

		clr.b	(f_wtr_state).w				; clear water state
		clr.w	(f_restart).w				; clear level restart flag
		moveq	#palid_Special,d0			; load special stage palette...
		bsr.w	PalLoad_Fade				; ...into the palette fade-in buffer
		jsr	(SS_Load).l				; load SS layout data (based on last stage entered and collected emeralds)

	if FixBugs
		; Set custom level boundaries so that the fixed
		; debug mode will not break for Special Stages.
		move.w	#$2B0,(v_limittop2).w			; set top boundary
		move.w	#$7D0,(v_limitbtm2).w			; set bottom boundary
		move.w	#$2E0,(v_limitleft2).w			; set left boundary
		move.w	#$7A0,(v_limitright2).w			; set right boundary
	endif

		move.l	#0,(v_screenposx).w			; reset X-camera position
		move.l	#0,(v_screenposy).w			; reset Y-camera position
		move.b	#id_SonicSpecial,(v_player).w		; load special stage Sonic object
		bsr.w	PalCycle_SS				; initialize palette cycle and background for fade-in
		clr.w	(v_ssangle).w				; set stage angle to "upright"
		move.w	#ss_rotatespeed,(v_ssrotate).w		; set initial stage rotation speed ($40, see object 09)
		move.w	#bgm_SS,d0				; play special stage BG music
		bsr.w	QueueSound1				; play it

		move.w	#0,(v_btnpushtime1).w			; clear button push counters for demos
		lea	(DemoDataPtr).l,a1			; load demo data
		moveq	#6,d0					; hardcoded to load the entry for the Special Stage demo
		lsl.w	#2,d0					; multiply by 4 for longword-based indexing
		movea.l	(a1,d0.w),a1				; get demo pointer for current level
		move.b	1(a1),(v_btnpushtime2).w		; load initial demo key press duration
		subq.b	#1,(v_btnpushtime2).w			; subtract 1 from demo key pressduration

		clr.w	(v_rings).w				; clear rings
		clr.b	(v_lifecount).w				; clear extra lives flags when getting 100/200 rings

		move.w	#0,(v_debuguse).w			; exit debug mode if necessary
		move.w	#1800,(v_generictimer).w		; run regular demos for 30 seconds
		tst.b	(f_debugcheat).w			; has debug cheat been entered?
		beq.s	SS_NoDebug				; if not, branch
		btst	#bitA,(v_jpadhold1).w			; is A button held?
		beq.s	SS_NoDebug				; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode

SS_NoDebug:
		enable_display					; enable screen out-put
		bsr.w	PaletteWhiteIn				; fade-in from white

; ---------------------------------------------------------------------------
; Special Stage main loop
; ---------------------------------------------------------------------------

SS_MainLoop:
		bsr.w	PauseGame				; handle pausing the game when pressing start
		move.b	#id_VBlank_SpecialStage,(v_vblank_routine).w ; set VBlank routine to $0A
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		bsr.w	MoveSonicInDemo				; simulate controls in demos (immediately returns outside demos)
		move.w	(v_jpadhold1).w,(v_jpadhold2).w		; copy controller 1 inputs to Sonic player object inputs

		jsr	(ExecuteObjects).l			; execute Special Stage object
		jsr	(BuildSprites).l			; build sprites
		bsr.w	LoadRingFrame
		jsr	(SS_ShowLayout).l			; render Special Stage layout
		bsr.w	SS_BGAnimate				; animate Special Stage background

		tst.w	(f_demo).w				; is demo mode on?
		beq.s	SS_ChkEnd				; if not, branch
		tst.w	(v_generictimer).w			; is there time left on the demo?
		beq.w	SS_ToSegaScreen				; if not, return to Sega screen

SS_ChkEnd:
		cmpi.b	#id_Special,(v_gamemode).w		; is game mode still the Special Stage?
		beq.w	SS_MainLoop				; if yes, loop game mode
; ---------------------------------------------------------------------------

		; Exiting Special Stage...
		tst.w	(f_demo).w				; are we exiting from a demo?
	if Revision=0
		bne.w	SS_ToSegaScreen				; if yes, return to Sega Screen
	else
		; REV01 added a small convenience improvement by returning straight
		; to the title screen when pressing start during the Special Stage demo,
		; rather than always being forced back to the Sega screen.
		bne.w	SS_ToNextScreen				; if yes, return to next game mode
	endif

		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		cmpi.w	#id_FZ+1,(v_zone_act).w			; is level number higher than FZ (0502)?
		blo.s	SS_Finish				; if not, branch
		clr.w	(v_zone_act).w				; set to GHZ1 (possibly as a failsafe)


SS_Finish:
		move.w	#60,(v_generictimer).w			; run fade-out for one second
		move.w	#$003F,(v_pfade_start).w		; set palette fade-out position and size
		clr.w	(v_palchgspeed).w			; do first palette brightening immediately

SS_FinLoop:
		move.b	#id_VBlank_Continue,(v_vblank_routine).w ; set VBlank routine to $16 (uses the same one as the continue screen)
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		bsr.w	MoveSonicInDemo				; continue updating demo controls during fade-out
		move.w	(v_jpadhold1).w,(v_jpadhold2).w		; continue copying 1P inputs to Sonic object (even though controls are locked...)
		jsr	(ExecuteObjects).l			; continue executing objects during fade-out
		jsr	(BuildSprites).l			; continue building sprites during fade-out
		jsr	(SS_ShowLayout).l			; continue rendering Special Stage layout
		bsr.w	SS_BGAnimate				; continue to animate background

		subq.w	#1,(v_palchgspeed).w			; decrement palette fade-out delay
		bpl.s	SS_FinLoop_NoBrighten			; if time remains, branch
		move.w	#2,(v_palchgspeed).w			; reset palette fade-out delay
		bsr.w	WhiteOut_ToWhite			; brighten palette further

; loc_47D4:
SS_FinLoop_NoBrighten:
		tst.w	(v_generictimer).w			; has fade-out loop finished?
		bne.s	SS_FinLoop				; if not, loop
; ---------------------------------------------------------------------------

		; Fade-out done, load Special Stage Results screen
		disable_ints					; disable interrupts
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		bsr.w	ClearScreen				; wipe screen

		jsr	(SpecStagResults_LoadArt).l	; load SSR title card graphics

		jsr	(Hud_Base).l				; load basic HUD graphics
		enable_ints					; enable interrupts

		moveq	#palid_SSResult,d0			; load Special Stage results screen palette...
		bsr.w	PalLoad					; ...directly to active palette
		moveq	#plcid_Main,d0				; load main patterns (rings, etc.)
		bsr.w	NewPLC					; add to new PLC queue
		moveq	#plcid_SSResult,d0			; load Special Stage results screen patterns
		bsr.w	AddPLC					; add to PLC queue

		move.b	#1,(f_scorecount).w			; update score counter
		move.b	#1,(f_endactbonus).w			; update ring bonus counter
		move.w	(v_rings).w,d0				; get rings collected in Special Stage
		mulu.w	#10,d0					; award 100 bonus points per collected ring
		move.w	d0,(v_ringbonus).w			; set rings bonus

		move.w	#bgm_GotThrough,d0			; play end-of-level music
		jsr	(QueueSound2).l	 			; play it

		clearRAM v_objspace				; clear object RAM

		move.b	#id_SSResult,(v_ssrescard).w		; load Special Stage Results screen object
; ---------------------------------------------------------------------------

SS_NormalExit:		; Special Stage results screen loop
		bsr.w	PauseGame				; allow pausing during the results screen
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		jsr	(ExecuteObjects).l			; execute SSR objects
		jsr	(BuildSprites).l			; build sprites
		tst.w	(f_restart).w				; has the SSR object signaled that we can exit?
		beq.s	SS_NormalExit				; if not, loop results screen
		tst.l	(v_plc_buffer).w			; is PLC buffer empty?
		bne.s	SS_NormalExit				; if not, loop (pointless here, SSR object has its own check)
; ---------------------------------------------------------------------------

		; Exit Special Stage normally
		move.w	#sfx_EnterSS,d0				; play special stage exit sound
		bsr.w	QueueSound2 				; play it
		bsr.w	PaletteWhiteOut				; fade-out to white
		rts						; return to MainGameLoop
; ===========================================================================

SS_ToSegaScreen:
		move.b	#id_Sega,(v_gamemode).w			; set game mode to Sega screen
		rts						; return to MainGameLoop
; ===========================================================================

	if Revision<>0
; SS_ToLevel: <-- old misnomer
SS_ToNextScreen:
		cmpi.b	#id_Level,(v_gamemode).w		; was demo exited with the instruction to go to a level next?
		beq.s	SS_ToSegaScreen				; if yes, return to the Sega screen instead (if demo finished)
		rts						; otherwise, go to new game mode (which is the title screen, if demo was aborted)
	endif
; ENd of function GM_Special

; ===========================================================================

; >>> Special Stage background drawing and palette cycle logic
	include	"_inc/Special Stage Background & Palette Cycle.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

; ContinueScreen:
GM_Continue:
		bsr.w	PaletteFadeOut				; fade-out palette from previous game mode

		disable_ints					; disable interrupts
		disable_display					; disable screen output
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_bgcolor|0<<4|0,(a6)		; background colour
		bsr.w	ClearScreen				; wipe screen

		clearRAM v_objspace				; clear object RAM

		moveq	#plcid_TitleCard,d0		; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		moveq	#plcid_Continue,d0		; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		moveq	#10,d1					; draw continue screen countdown to start with digits 10
		jsr	(ContScrCounter).l			; initialize countdown

		moveq	#palid_Continue,d0			; load continue screen palette...
		bsr.w	PalLoad_Fade				; ...into fade-in buffer
		move.b	#bgm_Continue,d0			; play continue screen music
		bsr.w	QueueSound1				; play it

		move.w	#(11*60)-1,(v_generictimer).w		; show continue screen for 11 seconds in total

		clr.l	(v_screenposx).w			; clear X-camera position
		move.l	#$1000000,(v_screenposy).w		; set Y-camera position to $100

		move.b	#id_ContSonic,(v_player).w		; load continue screen Sonic object
		move.b	#id_ContScrItem,(v_continuetext).w	; load continue screen objects (text and misc elements)
		move.b	#id_ContScrItem,(v_continuelight).w	; load floor light object Sonic is laying on
		move.b	#3,(v_continuelight+obPriority).w	; set priority to be behind Sonic
		move.b	#4,(v_continuelight+obFrame).w		; set correct frame for the light
		move.b	#id_ContScrItem,(v_continueicon).w	; load continue icons object
		move.b	#4,(v_continueicon+obRoutine).w		; set to continue icons routine

		jsr	(ExecuteObjects).l			; initialize objects
		jsr	(BuildSprites).l			; build sprites
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		enable_display					; enable screen output
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#id_VBlank_Continue,(v_vblank_routine).w ; set VBlank routine to $16
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		cmpi.b	#6,(v_player+obRoutine).w		; has continue screen Sonic object signaled that we want to continue?
		bhs.s	Cont_NoCountdown			; if yes, stop updating countdown timer

		disable_ints					; disable interrupts
		move.w	(v_generictimer).w,d1			; get remaining time for countdown (in frames)
		divu.w	#60,d1					; divide by 60 to get remaining time in seconds
		andi.l	#$F,d1					; mask off remainder and anything except the end digit
		jsr	(ContScrCounter).l			; update countdown digits
		enable_ints					; enable interrupts again
; loc_4DF2:
Cont_NoCountdown:
		jsr	(ExecuteObjects).l			; execute continue screen objects
		jsr	(BuildSprites).l			; build sprites

		cmpi.w	#320+64,(v_player+obX).w		; has Sonic run off screen after using a continue?
		bhs.s	Cont_GotoLevel				; if yes, return to level and continue game
		cmpi.b	#6,(v_player+obRoutine).w		; has continue screen Sonic object signaled that we want to continue?
		bhs.s	Cont_MainLoop				; if yes, Sonic is still running off-screen, loop until he is gone
		tst.w	(v_generictimer).w			; has countdown run out?
		bne.w	Cont_MainLoop				; if not, loop game mode

		; Continue wasn't used. Game Over.
		move.b	#id_Sega,(v_gamemode).w			; go to Sega screen
		rts						; return to MainGameLoop
; ===========================================================================

Cont_GotoLevel:
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; clear d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_lastlamp).w			; clear lamppost count
		subq.b	#1,(v_continues).w			; subtract 1 from continues
		rts						; return to MainGameLoop
; End of function GM_Continue

; ===========================================================================

; >>> Objects for the continue screen
	include	"_incObj/80, 81 Continue Screen Elements and Sonic.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence in Green Hill Zone. This is essentially a stripped-down
; copy-paste of regular levels with lots of hardcoding.
; ---------------------------------------------------------------------------

; EndingSequence:
GM_Ending:
		; fading out from previous game mode
		move.b	#bgm_Stop,d0				; set stop music command
		bsr.w	QueueSound2				; stop music
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		clearRAM v_objspace				; clear object RAM
		clearRAM v_misc_variables			; clear various miscellaneous RAM
		clearRAM v_levelvariables			; clear level variables RAM (camera position, etc.)
		clearRAM v_timingandscreenvariables		; clear various timing and screen RAM (for animated tiles, etc.)

		disable_ints					; disable interrupts
		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe the screen
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_spritevram|(vram_sprites>>9),(a6)	; set sprite table address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (line 3; colour 0)
		move.w	#vreg_hintrate|223,(v_hblank_hreg).w	; set palette change position (for water)
		move.w	(v_hblank_hreg).w,(a6)			; write to VDP
		move.w	#30,(v_air).w				; replenish air

		move.w	#id_EndZ_good,(v_zone_act).w		; set to good ending by default (level number 600, extra flowers)
		cmpi.b	#ss_emeralds_num,(v_emeralds).w		; do you have all 6 emeralds?
		beq.s	End_LoadData				; if yes, use good ending
		move.w	#id_EndZ_bad,(v_zone_act).w		; otherwise, set to bad ending (level number 601, no extra flowers)

End_LoadData:
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; transfer data up to this point
		bsr.w	LoadZoneTiles				; load main zone art (S2 Art Loader)
		moveq	#plcid_Ending,d0			; load ending sequence patterns (GHZ art, animals, etc.)
		bsr.w	QuickPLC				; execute PLCs immediately (no queue)
;		jsr	(Hud_Base).l				; load basic HUD graphics (only in levels, not in the ending demos)
		bsr.w	LevelSizeLoad				; load level size and set default level boundaries
		bsr.w	DeformLayers				; initialize background deformation
		bset	#2,(v_fg_scroll_flags).w		; draw an extra column at the left side of the screen during level start
		bsr.w	LevelDataLoad				; load block mappings and palettes
		bsr.w	LoadTilesFromStart			; fully draw the foreground and background once before fade-in
		move.l	#Col_GHZ,(v_collindex).w		; load collision index (hardcoded to GHZ instead of using ColIndexLoad)
		enable_ints					; enable interrupts

		lea	(Kos_EndFlowers).l,a0			; load extra flower patterns
		lea	(v_ram_start_def+$4A*chunk_size).w,a1	; set RAM address to be used as decompression buffer (this overwrites unused chunk RAM)
		bsr.w	KosDec					; decompress Kosinski-compressed chunks mappings to buffer

		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		move.w	#bgm_Ending,d0				; play ending sequence music
		bsr.w	QueueSound1				; play it

	if FixBugs
		; Fix being able to enable debug mode without having entered the cheat code for it
		tst.b	(f_debugcheat).w			; has debug cheat been entered?
		beq.s	End_LoadSonic				; if not, branch
	endif
		btst	#bitA,(v_jpadhold1).w			; was button A held while entering ending sequence?
		beq.s	End_LoadSonic				; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode

End_LoadSonic:
		move.b	#id_SonicPlayer,(v_player).w		; load Sonic object
		bset	#0,(v_player+obStatus).w		; make Sonic face left
		move.b	#1,(f_lockctrl).w			; lock controls to keep simulating D-Pad
		move.w	#(btnL<<8),(v_jpadhold2).w		; simulate holding down the left D-Pad button to move Sonic (and clear v_jpadpress2)
		move.w	#-$800,(v_player+obInertia).w		; set Sonic's initial speed (speed cap immediately limits this to -$600)

;		move.b	#1,(v_draw_hud).w			; enable HUD drawing
		jsr	(ObjPosLoad).l				; run the object manager to load level objects
		jsr	(ExecuteObjects).l			; execute all objects in object RAM
		jsr	(BuildSprites).l			; build sprite table

		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.b	d0,(v_lifecount).w			; clear extra lives flags when getting 100/200 rings
		move.b	d0,(v_shield).w				; clear shield
		move.b	d0,(v_shieldtype).w				; clear shield type
		move.b	d0,(v_invinc).w				; clear invincibility
		move.b	d0,(v_shoes).w				; clear speed shoes
		move.w	d0,(v_debuguse).w			; exit debug mode if necessary
		move.w	d0,(f_restart).w			; clear level restart flag
		move.w	d0,(v_framecount).w			; reset frames since level start to 0
		bsr.w	OscillateNumInit			; initialize oscillation values
		move.b	#1,(f_scorecount).w			; update score counter
		move.b	#1,(f_ringcount).w			; update rings counter
		move.b	#0,(f_timecount).w			; stop time counter for the ending sequence

		move.w	#1800,(v_generictimer).w		; set generic timer to 30 seconds (unused in ending sequence)
		move.b	#id_VBlank_Ending,(v_vblank_routine).w	; set VBlank routine to $18
		bsr.w	WaitForVBlank				; wait until VBlank has finished
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		enable_display					; enable screen output
		move.w	#$003F,(v_pfade_start).w		; set palette fade-in position and size	(redundant)
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; Ending sequence main loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame				; allow pausing during the ending sequence
		move.b	#id_VBlank_Ending,(v_vblank_routine).w	; set VBlank routine to $18
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		bsr.w	End_MoveSonic				; control simulated button inputs for Sonic during the cutscene

		jsr	(ExecuteObjects).l			; execute all objects in object RAM
		bsr.w	DeformLayers				; scroll planes and do background deformation
		jsr	(BuildSprites).l			; build sprite table
		jsr	(ObjPosLoad).l				; run the object manager to load level objects
		bsr.w	PaletteCycle				; run palette cycles
		bsr.w	OscillateNumDo				; advance oscillation values
		bsr.w	SynchroAnimate				; advance animation timers

		cmpi.b	#id_Ending,(v_gamemode).w		; is game mode still set to ending sequence?
		beq.s	End_ChkEmerald				; if yes, branch

End_GoToCredits:
		move.b	#id_Credits,(v_gamemode).w		; change game mode to credits
		move.b	#bgm_Credits,d0				; play credits music
		bsr.w	QueueSound2				; play it
		move.w	#0,(v_creditsnum).w			; set credits page number to 0 ("Sonic Team Staff")
		rts						; return to MainGameLoop
; ===========================================================================

End_ChkEmerald:
		tst.w	(f_restart).w				; is level restart flag set? (set while emeralds are spinning in the good ending)
		beq.w	End_MainLoop				; if not, loop ending sequence game mode normally
; ---------------------------------------------------------------------------

		; prepare slow white-in as the emeralds keep spinning in good ending
		clr.w	(f_restart).w				; clear level restart flag
		move.w	#$003F,(v_pfade_start).w		; prepare fade position and size
		clr.w	(v_palchgspeed).w			; trigger the first brightening immediately
; ---------------------------------------------------------------------------


End_AllEmlds:		; during the slow white-in
		bsr.w	PauseGame				; still allow pausing the game
		move.b	#id_VBlank_Ending,(v_vblank_routine).w	; set VBlank routine to $18
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		bsr.w	End_MoveSonic				; control simulated button inputs for Sonic (redundant at this point)

		jsr	(ExecuteObjects).l			; continue executing objects during white-in
		bsr.w	DeformLayers				; continue upgrading background deformation during white-in
		jsr	(BuildSprites).l			; continue building sprites during white-in
		jsr	(ObjPosLoad).l				; continue running object manager during white-in
		bsr.w	OscillateNumDo				; continue advancing oscillation values during white-in
		bsr.w	SynchroAnimate				; continue advancing animation timers during white-in

		subq.w	#1,(v_palchgspeed).w			; decrement palette white-in delay
		bpl.s	End_SlowFade				; if time remains, branch
		move.w	#2,(v_palchgspeed).w			; reset palette white-in delay
		bsr.w	WhiteOut_ToWhite			; brighten palette further

End_SlowFade:
	if FixBugs
		; Fix a softlock if Sonic somehow dies in the Ending Sequence
		cmpi.b	#6,(v_player+obRoutine).w		; has Sonic died?
		bhs.s	End_GoToCredits				; if yes, abort sequence, go straight to credits
	endif
		tst.w	(f_restart).w				; has flag been set signaling that the emeralds have disappeared?
		beq.w	End_AllEmlds				; if not, loop
; ---------------------------------------------------------------------------

		; screen is fully white and emeralds are gone, update level layout with extra flowers and fade back in
		clr.w	(f_restart).w				; clear level restart flag
		move.w	#$2E2F,(v_lvllayout_fg+layout_row).w	; swap chunks in level layout to the variants with flowers (chunks $2E / $2F) (row 1 / column 0)

		lea	(vdp_control_port).l,a5			; set VDP control port
		lea	(vdp_data_port).l,a6			; set VDP data port
		lea	(v_screenposx).w,a3			; get current foreground X position
		lea	(v_lvllayout_fg).w,a4			; get location in level layout RAM where foreground is stored
		move.w	#$4000,d2				; set VRAM write command to vram_fg nametable start address
		bsr.w	DrawChunks				; update drawn chunks to show the new flowers

		moveq	#palid_Ending,d0			; reload ending palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		bsr.w	PaletteWhiteIn				; fade-in from white

		bra.w	End_MainLoop				; return to main ending sequence loop for the rest of the scene
; End of function GM_Ending

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence.
; 
; Many aspects of the game use the concept of a state machine.
; If you are interested and want to learn more, these are Mealy and Moore machines
; which have plenty of resources to teach you! This subroutine is a Moore machine.
; Once you understand these concepts, Sonic 1's game logic will make a lot more sense to you!
; ---------------------------------------------------------------------------

End_MoveSonic:
		move.b	(v_sonicend).w,d0			; get ending cutscene routine number
		bne.s	End_MoveSon2				; if it's non-zero, branch to second script

		cmpi.w	#(320/2)-16,(v_player+obX).w		; has Sonic passed $90 on the X-axis (from the right)?
		bhs.s	End_MoveSonExit				; if not, branch

		addq.b	#2,(v_sonicend).w			; advance ending cutscene routine number
		move.b	#1,(f_lockctrl).w			; lock player's controls (redundant, already locked)
		move.w	#(btnR<<8),(v_jpadhold2).w		; simulate holding down the right D-Pad button to trigger skidding animation
		rts						; return
; ===========================================================================

End_MoveSon2:
		subq.b	#2,d0					; subtract 2 from cutscene routine number
		bne.s	End_MoveSon3				; if it's still non-zero, branch to third script

		cmpi.w	#320/2,(v_player+obX).w			; has Sonic passed $A0 on the X-axis (from the left)?
		blo.s	End_MoveSonExit				; if not, branch

		addq.b	#2,(v_sonicend).w			; advance ending cutscene routine number
		moveq	#0,d0					; clear d0
		move.b	d0,(f_lockctrl).w			; unlock controls (no effect, see below)
		move.w	d0,(v_jpadhold2).w			; clear simulated button inputs to stop Sonic moving
		move.w	d0,(v_player+obInertia).w		; clear ground speed to make Sonic stop immediately
		move.b	#$81,(f_playerctrl).w			; set control ignore and disabled object interaction flags

		move.b	#id_Victory,(v_player+obAnim).w ; use "standing" animation and prevent it from getting immediately restarted
		move.b	#3,(v_player+obTimeFrame).w		; set a bit of an animation interval so Sonic keeps looking when he gets replaced on the next frame
		rts						; return
; ===========================================================================

End_MoveSon3:
		subq.b	#2,d0					; subtract 2 from cutscene routine number
		bne.s	End_MoveSonExit				; if it's still non-zero, the below code has already run, branch to do nothing anymore

		addq.b	#2,(v_sonicend).w			; advance ending cutscene routine number
		move.w	#320/2,(v_player+obX).w			; force Sonic to the middle of the screen
		move.b	#id_EndSonic,(v_player).w		; replace real Sonic object with a fake ending sequence Sonic object
		clr.w	(v_player+obRoutine).w			; reset routine counter to initialize fake ending Sonic

End_MoveSonExit:
		rts						; return
; End of function End_MoveSonic

; ===========================================================================

; >>> Objects on the ending sequence
	include	"_incObj/87, 88, 89 Ending Sequence Sonic, Emeralds, Logo.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Credits ending sequence. This game mode works in tandem with the regular
; demo game mode, with both redirecting to here after their respective timer
; has expired. The variable v_creditsnum for the current page is deliberately
; located near the end of RAM so it doesn't get cleared during mode change.
; ---------------------------------------------------------------------------

; CreditsScreen:
GM_Credits:
		; fading out from previous game mode (music gets already started before this)
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		move.w	#vreg_winypos|0,(a6)			; window vertical position
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w				; clear water state
		bsr.w	ClearScreen				; wipe the screen

		clearRAM v_objspace				; clear object RAM

		moveq	#plcid_Credits,d0		; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		clearRAM v_palette_fading			; set palette fade-in buffer to all-black
		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad_Fade				; ...into fade-in buffer

		move.b	#id_CreditsText,(v_credits).w		; load credits text object
		jsr	(ExecuteObjects).l			; execute objects to load credits text object
		jsr	(BuildSprites).l			; build sprites for the credits text object

		bsr.w	EndingDemoLoad				; prepare loading the next ending demo

		jsr	(GetLevelHeader).l			; load level header for current zone/act into a2
		moveq	#0,d0					; clear d0
		move.b	(a2),d0					; get first PLC entry
		beq.s	Cred_SkipObjGfx				; if it's null, branch (never the case)
		bsr.w	AddPLC					; load level patterns for next credits demo

Cred_SkipObjGfx:
		moveq	#plcid_Main2,d0				; load secondary standard patterns
		bsr.w	AddPLC					; (monitors, etc.)
; ---------------------------------------------------------------------------

		; fade-in palette and enter wait loop
		move.w	#120,(v_generictimer).w			; display a single credits page for 2 seconds
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; Credits page main loop (only shown for 2 seconds)
; ---------------------------------------------------------------------------

Cred_WaitLoop:		; while a credits page is displayed and graphics are getting decompressed
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04 (uses the same one as the title screen)
		bsr.w	WaitForVBlank				; wait until VBlank has finished

		tst.w	(v_generictimer).w			; have at least 2 seconds elapsed?
		bne.s	Cred_WaitLoop				; if not, loop
		tst.l	(v_plc_buffer).w			; have 2 seconds elapsed but level gfx have not finished decompressing?
		bne.s	Cred_WaitLoop				; if yes, still loop until graphics are finished
; ---------------------------------------------------------------------------

		; credits page has finished displaying, go to next game mode
		cmpi.w	#9,(v_creditsnum).w			; are we past the final credits page?
		beq.w	TryAgainEnd				; if yes, go to Try Again/End screen instead
		rts						; otherwise, return to MainGameLoop to enter Demo mode
; End of function GM_Credits

; ===========================================================================
; ---------------------------------------------------------------------------
; Cool Awesome Splash Screen
; ---------------------------------------------------------------------------
GM_MySplash:
		; fade-out
		move.b  #bgm_Stop,d0			; set music to stop
		bsr.w   QueueSound2			; queue music command
		bsr.w   ClearPLC			; clear PLC queue
		bsr.w   PaletteFadeOut			; fade out palette (takes 22 frames)

		; initialize screen
		disable_ints				; disable interrupts (this is important as we are directly writing to the VDP now)
		lea     (vdp_control_port).l,a6		; set up VDP control port to a6
		move.w  #$8004,(a6)			; use 8-color mode
		move.w  #$8200+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w  #$8400+(vram_bg>>13),(a6)	; set background nametable address
		move.w  #$8700,(a6)			; set background color (line 1; entry 0)
		move.w  #$8B00,(a6)			; full-screen vertical scrolling
		clr.b   (f_wtr_state).w			; clear water state
		bsr.w   ClearScreen			; clear the screen (i.e. zero out the nametables)

		; load KosinskiM-compressed tile data
		moveq	#plcid_SplashScreen,d0	; load patterns through PLC list
		bsr.w	QuickPLC			; decompress PLC list now and return once done

		; load Enigma-compressed mapping data
		lea     (v_ram_start).l,a1		; set a1 to point to $FFFF0000 (will be used as Enigma-decompression buffer)
		lea     (Eni_MySplash).l,a0		; load compressed mapping data pointer to a0
		move.w  #$0000,d0			; set starting art tile to 0 (since the tile data was decompressed to VRAM address $0000 and we use palette line 1)
		bsr.w   EniDec				; decompress Enigma-compressed data to $FFFF0000
		copyTilemap v_ram_start,vram_fg,40,28	; copy decompressed mappings to Plane A nametable (width 40, height 28)

		; load palette
		lea     (Pal_MySplash).l,a0		; load palette data
		lea     (v_palette_fading).w,a1		; set destination to fade-in palette buffer
		moveq   #(16/2)-1,d0			; set to write 16 colors to CRAM
.write_Pal:	move.l  (a0)+,(a1)+			; copy two colors
		dbf     d0,.write_Pal			; repeat until all colors are in the buffer

		; fade-in
		move.w  #bgm_ExtraLife,d0			; set emerald jingle
		bsr.w   QueueSound2			; run music command

		move.w  #3*60,(v_generictimer).w	; run screen for a maximum of 3 seconds (3 times 60 frames per second)
		bsr.w   PaletteFadeIn			; fade in palette (takes 22 frames, interrupts are re-enabled here as well)

MySplash_MainLoop:
		move.b  #2,(v_vblank_routine).w		; set V-blank routine to VBla_02 (update sound driver, read joypads, and decrement v_generictimer)
		bsr.w   WaitForVBlank			; wait for V-blank

		tst.w   (v_generictimer).w		; has the generic timer been decremented to zero?
		beq.s   MySplash_ExitScreen		; if yes, exit screen

		move.b  (v_jpadpress1).w,d0		; get Player 1 joypad presses
		andi.b  #btnStart,d0			; check if Start button is pressed
		beq.s   MySplash_MainLoop		; if not, loop screen indefinitely
                ; otherwise, exit screen

MySplash_ExitScreen:
		move.b  #id_Title,(v_gamemode).w	; resume to title screen
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence demo loading subroutine
; ---------------------------------------------------------------------------

EndingDemoLoad:
		move.w	(v_creditsnum).w,d0			; get current credits page
		andi.w	#$F,d0					; limit to 16 possible entries (redundant)
		add.w	d0,d0					; double for word-based indexing
		move.w	EndDemo_Levels(pc,d0.w),d0		; get relevant zone and act for the next credits demo
		move.w	d0,(v_zone_act).w			; set level from level array

		addq.w	#1,(v_creditsnum).w			; increase credits page number for next time
		cmpi.w	#9,(v_creditsnum).w			; are we past the final credits page now?
		bhs.s	EndDemo_Exit				; if yes, don't load another demo

		move.w	#$8001,(f_demo).w 			; set demo mode to its credits/ending variant
		move.b	#id_Demo,(v_gamemode).w			; set game mode to demo (activates once credits page has finished)

		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_lastlamp).w			; clear lamppost counter

		cmpi.w	#4,(v_creditsnum).w			; is specifically the 4th demo about to run? (SLZ demo)
		bne.s	EndDemo_Exit				; if not, branch
		lea	(EndDemo_LampVar).l,a1			; load special lamppost variables for SLZ demo
		lea	(v_lastlamp).w,a2			; write to lamppost buffer
		move.w	#(EndDemo_LampVar_End-EndDemo_LampVar)/4-1,d0 ; write for all entries
EndDemo_LampLoad:
		move.l	(a1)+,(a2)+				; copy lamppost variables for SLZ demo
		dbf	d0,EndDemo_LampLoad			; loop until everything is loaded

EndDemo_Exit:
		rts						; return
; End of function EndingDemoLoad

; ---------------------------------------------------------------------------
; Levels used in the end sequence demos
; ---------------------------------------------------------------------------

EndDemo_Levels:		; previously in "misc/Demo Level Order - Ending.bin"
		dc.w id_GHZ_act1
		dc.w id_MZ_act2
		dc.w id_SYZ_act3
		dc.w id_LZ_act3
		dc.w id_SLZ_act3
		dc.w id_SBZ_act1
		dc.w id_SBZ_act2
		dc.w id_GHZ_act1
		even

; ---------------------------------------------------------------------------
; Lamppost variables in the Star Light Zone credits demo
; ---------------------------------------------------------------------------
EndDemo_LampVar:
		dc.b 1,	1					; number of the last lamppost
		dc.w $A00, $62C					; x/y-axis position
		dc.w 13						; rings
		dc.l 0						; time
		dc.b 0,	0					; dynamic level event routine counter
		dc.w $800					; level bottom boundary
		dc.w $957, $5CC					; x/y axis screen position
		dc.w $4AB, $3A6, 0, $28C, 0, 0			; scroll info
		dc.w $308					; water height
		dc.b 1,	1					; water routine and state
EndDemo_LampVar_End:
; ===========================================================================


; ===========================================================================
; ---------------------------------------------------------------------------
; "TRY AGAIN" screen (bad ending) and "END" screen (good ending). This is
; essentially a full game mode, although it's not called from the main
; game mode array, but rather directly from the credits.
; ---------------------------------------------------------------------------

; TryAgainScreen:
TryAgainEnd:		; fading out from previous game mode
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		move.w	#vreg_winypos|0,(a6)			; window vertical position
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w				; clear water state
		bsr.w	ClearScreen				; wipe the screen

		clearRAM v_objspace				; clear object RAM

		moveq	#plcid_TryAgain,d0			; load "TRY AGAIN" and "END" patterns
		bsr.w	QuickPLC				; execute PLCs immediately (no queue)

		clearRAM v_palette_fading			; set palette fade-in buffer to all-black
		moveq	#palid_Ending,d0			; load ending palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		clr.w	(v_palette_fading_line_3).w		; ensure the backdrop color is black

		move.b	#id_EndEggman,(v_endeggman).w		; load end Eggman object
		jsr	(ExecuteObjects).l			; execute objects to load end objects
		jsr	(BuildSprites).l			; build sprites for end objects
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		move.w	#1800,(v_generictimer).w		; automatically return to Sega screen after 30 seconds
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END" screen main loop
; ---------------------------------------------------------------------------

TryAg_MainLoop:
		bsr.w	PauseGame				; allow to pause game (redundant, start exits the screen)
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04 (uses the same one as the title screen)
		bsr.w	WaitForVBlank				; wait until VBlank has finished

		jsr	(ExecuteObjects).l			; update end objects
		jsr	(BuildSprites).l			; build sprites for end objects

		andi.b	#btnStart,(v_jpadpress1).w		; has Start button been pressed?
		bne.s	TryAg_Exit				; if yes, exit end screen
		tst.w	(v_generictimer).w			; have 30 seconds elapsed?
		beq.s	TryAg_Exit				; if yes, exit end screen
		cmpi.b	#id_Credits,(v_gamemode).w		; is game mode still set to show the end screen?
		beq.s	TryAg_MainLoop				; if yes, loop
; ---------------------------------------------------------------------------

TryAg_Exit:		; exit end screen and restart the gam
		move.b	#id_Sega,(v_gamemode).w			; set game mode to Sega screen
		rts						; return to MainGameLoop
; End of function TryAgainEnd
; ===========================================================================

; >>> Objects on final screen
	include	"_incObj/8B, 8C Try Again, End Eggman, End Emeralds.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence demos
; ---------------------------------------------------------------------------

Demo_EndGHZ1:	include	"demodata/Ending - GHZ1.asm"
Demo_EndMZ:	include	"demodata/Ending - MZ.asm"
Demo_EndSYZ:	include	"demodata/Ending - SYZ.asm"
Demo_EndLZ:	include	"demodata/Ending - LZ.asm"
Demo_EndSLZ:	include	"demodata/Ending - SLZ.asm"
Demo_EndSBZ1:	include	"demodata/Ending - SBZ1.asm"
Demo_EndSBZ2:	include	"demodata/Ending - SBZ2.asm"
Demo_EndGHZ2:	include	"demodata/Ending - GHZ2.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; >> END OF MAIN GAME LOGIC - Everything below this point is file includes <<
; ---------------------------------------------------------------------------
; ===========================================================================


; Where possible, includes to _maps and _anim were appended to the _incObj
; file includes themselves. However, in some cases this wasn't possible,
; as the developers weren't very consistent with the placement, especially
; during the early stages of production. Those includes are still here.


; ===========================================================================
; >>> Level rendering, loading, and updating
		include	"_inc/LevelSizeLoad & BgScrollSpeed.asm" ; merged with "LevelSizeLoad & BgScrollSpeed (JP1).asm"
	if Revision=0
		include	"_inc/DeformLayers (REV00).asm"
		include	"_inc/Level Drawing (REV00).asm"
	else
		include	"_inc/DeformLayers (REV01).asm"
		include	"_inc/Level Drawing (REV01).asm"
	endif
		include	"_inc/LevelLayoutLoad.asm" ; includes LevelDataLoad, LevelLayoutLoad, and LevelLayoutLoad2

		include	"_inc/DynamicLevelEvents.asm"


; ===========================================================================
; >>> Various level objects
		include	"_incObj/11 GHZ Bridge.asm"
		include	"_incObj/15 Swinging Platforms.asm" ; includes "MvSonicOnPtfm" subroutine
		include	"_incObj/17 GHZ Spiked Pole Helix.asm"
		include	"_incObj/18 Platforms.asm"
		include	"_incObj/19 Unused - Blank.asm" ; this was the rolling GHZ ball in the prototype
Map_GBall:	include	"_maps/GHZ Ball.asm"
		include	"_incObj/1A, 53 Collapsing Ledges and Floors.asm" ; includes "SlopeObject_AssumeStoodOn" subroutine
		include	"_incObj/1C GHZ, SYZ Scenery.asm"
		include	"_incObj/1D Unused - Switch.asm"
		include	"_incObj/2A SBZ Small Door.asm"
		include	"_incObj/sub SolidWall.asm"


; ===========================================================================
; >>> Badniks, explosions, and Badnik-related objects
		include	"_incObj/1E, 20 Badnik - Ball Hog and Cannonball.asm"
		include	"_incObj/24 Unused - Small Explosion.asm"
		include	"_incObj/27, 3F Explosions.asm"
		include	"_anim/Ball Hog.asm"
Map_Hog:	include	"_maps/Ball Hog.asm"
Map_UnkExplode:	include	"_maps/Unused Explosion.asm"
		include	"_maps/Explosions.asm"
		include	"_incObj/28, 29 Animals and Points.asm"
		include	"_incObj/1F Badnik - Crabmeat.asm"
		include	"_incObj/22, 23 Badnik - Buzz Bomber and Missile.asm"


; ===========================================================================
; >>> Rings
		include	"_incObj/25, 37 Rings.asm"
		include	"_incObj/4B, 7C Giant Ring and Flash.asm"
		include	"_anim/Rings.asm"
Map_Ring:	include "_maps/Rings.asm"
Map_GRing:	include	"_maps/Giant Ring.asm"


; ===========================================================================
; >>> Monitors
		include	"_incObj/26, 2E Monitors and Power-Ups.asm"


; ===========================================================================
; >>> Title screen objects (includes AnimateSprite)
		include	"_incObj/0E, 0F Title Screen - Sonic, Press Start, TM.asm"


; ===========================================================================
; >>> More Badniks and level objects
		include	"_incObj/2B Badnik - Chopper.asm"
		include	"_incObj/2C Badnik - Jaws.asm"
		include	"_incObj/2D Badnik - Burrobot.asm"
		include	"_incObj/2F, 35 MZ Large Grassy Platforms and Burning Grass.asm"
Map_Fire:	include	"_maps/Fireballs.asm"
		include	"_incObj/30 MZ Large Green Glass Blocks.asm"
		include	"_incObj/31 MZ Chained Stompers.asm"
		include	"_incObj/45 Unused - MZ Sideways Stomper.asm"
Map_CStom:	include	"_maps/Chained Stompers.asm"
Map_SStom:	include	"_maps/Sideways Stomper.asm"
		include	"_incObj/32 Button.asm"
		include	"_incObj/33 MZ, LZ Pushable Blocks.asm"


; ===========================================================================
; >>> Title card objects
		include	"_incObj/34 Title Cards.asm"
		include	"_incObj/39 Game Over.asm"
		include	"_incObj/3A Got Through Card.asm"
		include	"_incObj/7E, 7F Special Stage Results and Chaos Emeralds.asm"
Map_Over:	include	"_maps/Game Over.asm"
Map_SSRC:	include	"_maps/SS Result Chaos Emeralds.asm"


; ===========================================================================
; >>> More level objects
		include	"_incObj/36 Spikes.asm"
		include	"_incObj/3B GHZ Purple Rock.asm"
		include	"_incObj/49 GHZ Waterfall Sound.asm"
Map_PRock:	include	"_maps/Purple Rock.asm"
		include	"_incObj/3C GHZ, SLZ Smashable Wall.asm" ; includes SmashObject


; ===========================================================================
; Subroutines to run, render, and update objects
		include	"_inc/ExecuteObjects.asm"
		include	"_inc/Object Pointers.asm" ; includes Obj_Index
		include	"_incObj/sub ObjectFall & SpeedToPos.asm"
		include	"_incObj/sub DisplaySprite.asm"
		include	"_incObj/sub DeleteObject.asm"
		include	"_inc/BuildSprites.asm"
		include	"_incObj/sub ChkObjectVisible.asm"
		include	"_inc/ObjPosLoad.asm"
		include	"_incObj/sub FindFreeObj.asm"


; ===========================================================================
; >>> More level objects
		include	"_incObj/41 Springs.asm"
		include	"_incObj/42 Badnik - Newtron.asm"
		include	"_incObj/43 Badnik - Roller.asm"
		include	"_incObj/44 GHZ Edge Walls.asm"
		include	"_incObj/13, 14 MZ, SLZ Fire Balls and Maker.asm"
		include	"_incObj/6D SBZ Flamethrower.asm"
		include	"_incObj/46 MZ Bricks.asm"
		include	"_incObj/12 SYZ Search Light.asm"
		include	"_incObj/47 SYZ Bumper.asm"
		include	"_incObj/0D Signpost.asm" ; includes "GotThroughAct" subroutine
		include	"_incObj/4C, 4D MZ Lava Geyser and Maker.asm"
		include	"_incObj/4E MZ Wall of Lava.asm"
		include	"_incObj/54 MZ Invisible Lava Tag.asm"
		include	"_anim/Lava Geyser.asm"
		include	"_anim/Wall of Lava.asm"
Map_Geyser:	include	"_maps/Lava Geyser.asm"
Map_LWall:	include	"_maps/Wall of Lava.asm"
		include	"_incObj/40 Badnik - Moto Bug.asm" ; includes "_incObj/sub RememberState.asm" subroutine
		include	"_incObj/4F Unused - Blank.asm" ; this was Splats in the prototype
		include	"_incObj/50 Badnik - Yadrin.asm"
		include	"_incObj/sub SolidObject.asm"
		include	"_incObj/51 MZ Smashable Green Block.asm"
		include	"_incObj/52 Moving Blocks.asm"
		include	"_incObj/55 Badnik - Basaran.asm"
		include	"_incObj/56 SYZ, SLZ Floating Blocks and LZ Doors.asm"
		include	"_incObj/57 SYZ, LZ Spiked Ball and Chain.asm"
		include	"_incObj/58 SYZ Big Spiked Ball.asm"
		include	"_incObj/59 SLZ Elevators.asm"
		include	"_incObj/5A SLZ Circling Platform.asm"
		include	"_incObj/5B SLZ Staircase.asm"
		include	"_incObj/5C SLZ Foreground Pylon.asm"
		include	"_incObj/0B LZ Pole that Breaks.asm"
		include	"_incObj/0C LZ Flapping Door.asm"
		include	"_incObj/71 Invisible Solid Barriers.asm"
		include	"_incObj/5D SLZ Fan.asm"
		include	"_incObj/5E SLZ Seesaw.asm"
		include	"_incObj/5F Badnik - Walking Bomb.asm"
		include	"_incObj/60 Badnik - Orbinaut.asm"
		include	"_incObj/16 LZ Harpoon.asm"
		include	"_incObj/61 LZ Blocks.asm"
		include	"_incObj/62 LZ Gargoyle.asm"
		include	"_incObj/63 LZ Conveyor.asm"
		include	"_incObj/64 LZ Air Bubbles.asm"
		include	"_incObj/65 LZ Waterfalls.asm"
		include	"_incObj/05 SpinDust.asm"
		include	"_maps/SpinDust.asm"
		include	"_maps/SpinDust - Dynamic Gfx Script.asm"


; ===========================================================================
; >>> Main Sonic player object
		include	"_incObj/01 Sonic.asm"
		include	"_incObj/06 AfterImage.asm"


; ===========================================================================
; >>> Various unique objects
		include	"_incObj/0A LZ Drowning Countdown.asm" ; includes ResumeMusic
		include	"_incObj/38 Shield and Invincibility.asm"
		include	"_incObj/04 Super Sonic's star.asm"
Map_SuperSonicStar:	include	"_maps/Super Sonic's star.asm"
		include	"_incObj/4A Unused - Special Stage Entry.asm"
		include	"_incObj/08 LZ Water Splash.asm"
		include	"_anim/Shield and Invincibility.asm"
Map_Shield:	include	"_maps/Shield and Invincibility.asm"
		include	"_anim/Special Stage Entry (Unused).asm"
Map_Vanish:	include	"_maps/Special Stage Entry (Unused).asm"
		include	"_anim/Water Splash.asm"
Map_Splash:	include	"_maps/Water Splash.asm"


; ===========================================================================
; >>> Collision subroutines for Sonic and other objects
		include	"_incObj/Sonic AnglePos.asm"
		include	"_incObj/sub FindNearestTile & FindFloor & FindWall.asm"
		include "_inc/ConvertCollisionArray (Unused).asm"
		include	"_incObj/Sonic Collision.asm"


; ===========================================================================
; >>> SBZ level objects
		include	"_incObj/66 SBZ Rotating Junction.asm"
		include	"_incObj/67 SBZ Running Disc.asm"
		include	"_incObj/68 SBZ Conveyor Belt.asm"
		include	"_incObj/69 SBZ Spinning Platforms and Trapdoors.asm"
		include	"_incObj/6A SBZ Saws and Pizza Cutters.asm"
		include	"_incObj/6B SBZ Stomper and Sliding Door.asm"
		include	"_incObj/6C SBZ Vanishing Platforms.asm"
		include	"_incObj/6E SBZ Electrocuter.asm"
		include	"_incObj/6F SBZ Spin Platform Conveyor.asm"
		include	"_incObj/70 SBZ Girder Block.asm"
		include	"_incObj/72 SBZ Teleporter.asm"

; ===========================================================================
; >>> Misc objects
		include	"_incObj/78 Badnik - Caterkiller.asm"
		include	"_incObj/79 Lamppost.asm"
		include	"_incObj/7D Hidden Bonuses.asm"
		include	"_incObj/8A Credits and Sonic Team Presents.asm"


; ===========================================================================
; >>> Bosses and related objects
		include	"_incObj/3D, 48 Boss - GHZ Main and Wrecking Ball.asm" ; includes "BossDefeated" and "BossMove" subroutines
		include	"_anim/Eggman.asm"
Map_Eggman:	include	"_maps/Eggman.asm"
Map_BossItems:	include	"_maps/Boss Items.asm"
		include	"_incObj/77 Boss - LZ Main.asm"
		include	"_incObj/73, 74 Boss - MZ Main and Fire.asm"
		include	"_incObj/7A, 7B Boss - SLZ Main and Spike Balls.asm"
		include	"_incObj/75, 76 Boss - SYZ Main and Blocks.asm"
		include	"_incObj/82, 83 SBZ Eggman Cutscene and Crumbling Floor.asm"
		include	"_incObj/85,84,86 Boss - FZ Main, Cylinders, and Plasma Balls.asm"
		include	"_incObj/3E Prison Capsule.asm"


; ===========================================================================
; >>> Object-to-object touch response handler for Sonic
		include	"_incObj/Sonic ReactToItem.asm"


; ===========================================================================
; >>> Special Stage rendering and objects
		; The following includes "SS_ShowLayout", "SS_AniWallsRings",
		; "SS_FindFreeAnimationSlot", "SS_AniItems", and "SS_Load"
		include	"_inc/Special Stage Loading & Drawing.asm"

		include	"_inc/Special Stage Mappings & VRAM Pointers.asm"
Map_SS_Shared:	include	"_maps/SS Shared Block.asm"
Map_SS_Glass:	include	"_maps/SS Glass Block.asm"
Map_SS_Up:	include	"_maps/SS UP Block.asm"
Map_SS_Down:	include	"_maps/SS DOWN Block.asm"
Map_SS_Chaos:	include	"_maps/SS Chaos Emeralds.asm"
		include	"_incObj/09 Sonic in Special Stage.asm"


; ===========================================================================
; >>> Deleted, blank object that is randomly mixed in here
		include	"_incObj/10 Unused - Blank.asm" ; this was an animation test object for Sonic in the prototype


; ===========================================================================
; >>> Subroutine for in-place level animations in VRAM
		include	"_inc/AnimateLevelGfx.asm"


; ===========================================================================
; >>> HUD objects
Map_HUD:	include	"_maps/HUD.asm"
		include	"_incObj/sub AddPoints.asm"
		include	"_inc/HUD Update.asm" ; includes "ContScrCounter" subroutine

Art_Hud:	binclude "artunc/HUD Numbers.unc" ; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	binclude "artunc/Lives Counter Numbers.unc" ; 8x8 pixel numbers on lives counter
		even


; ===========================================================================
; >>> Debug Mode
		include	"_incObj/DebugMode.asm"


; ===========================================================================
; >>> Level definitions
		include	"_inc/LevelHeaders.asm"
		include	"_inc/Pattern Load Cues.asm"


; ===========================================================================

; ---------------------------------------------------------------------------
; >> END OF PRIMARY INCLUDES - Everything below this point is art includes <<
; ---------------------------------------------------------------------------

		; KosPM_SegaLogo has a bunch of padding before it that differs between revisions:
		; - in rev00, it starts at $1DC00, which amounts to $EE bytes
		; - in rev01/rev02, it starts at $1E700, which amounts to $48E bytes
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$200
		if Revision<>0
			dcb.b	$300,$FF
		endif
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Compressed graphics and mappings - Sega screen
; ---------------------------------------------------------------------------
	if Revision=0
KosPM_SegaLogo:	binclude	"artkospm/Sega Logo (REV00).kospm" ; large Sega logo
		even
Eni_SegaLogo:	binclude	"tilemaps/Sega Logo (REV00).eni" ; large Sega logo (mappings)
		even
	else
KosPM_SegaLogo:	binclude	"artkospm/Sega Logo (REV01).kospm" ; large Sega logo
		even
Eni_SegaLogo:	binclude	"tilemaps/Sega Logo (REV01).eni" ; large Sega logo (mappings)
		even
	endif

; ---------------------------------------------------------------------------
; Compressed graphics and mappings - Title screen
; ---------------------------------------------------------------------------
Eni_Title:	binclude	"tilemaps/Title Screen.eni" ; title screen foreground (mappings)
		even
KosPM_TitleFg:	binclude	"artkospm/Title Screen Foreground.kospm"
		even
KosPM_TitleSonic:	binclude	"artkospm/Title Screen Sonic.kospm"
		even
KosPM_TitleTM:	binclude	"artkospm/Title Screen TM.kospm"
		even
Eni_JapNames:	binclude	"tilemaps/Hidden Japanese Credits.eni" ; Japanese credits (mappings)
		even
KosPM_JapNames:	binclude	"artkospm/Hidden Japanese Credits.kospm"
		even
Eni_LevelSelect:	binclude	"tilemaps/Level Select.eni"
			even
Eni_LevelSelectIcons:	binclude	"tilemaps/Level Select Icons.eni"
			even
Eni_MenuBackground:	binclude	"tilemaps/Sonic and Miles animated background.eni"
			even
KosPM_LevelSelectIcons:	binclude	"artkospm/Pictures in level preview box from level select.kospm"
			even
KosPM_MenuFont:		binclude	"artkospm/Standard font.kospm"
			even
Art_MenuBackground:	binclude	"artunc/Sonic and Miles animated background.unc"
Art_MenuBackground_end:	even

; ---------------------------------------------------------------------------
; Uncompressed graphics - Sonic
; ---------------------------------------------------------------------------
Map_Sonic:	include	"_maps/Sonic.asm"

SonicDynPLC:	include	"_maps/Sonic - Dynamic Gfx Script.asm"

Art_Sonic:	binclude	"artunc/Sonic.unc"
		even
Art_SpinDust:	binclude	"artunc/SpinDust.unc"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
	if Revision=0
KosPM_Smoke:	binclude	"artkospm/Unused - Smoke.kospm"
		even
KosPM_SyzSparkle:	binclude	"artkospm/Unused - SYZ Sparkles.kospm"
		even
	endif

Art_SuperSonicStar:	binclude	"artunc/Super Sonic stars.unc"
Art_SuperSonicStarend:		even
Art_Shield:	binclude	"artunc/Shield.unc"
		even
Art_Stars:	binclude	"artunc/Invincibility Stars.unc"
		even

	if Revision=0
KosPM_LzSonic:	binclude	"artkospm/Unused - LZ Sonic.kospm" ; Sonic holding his breath
		even
KosPM_UnkFire:	binclude	"artkospm/Unused - Fireball.kospm" ; unused fireball
		even
KosPM_Warp:	binclude	"artkospm/Unused - SStage Flash.kospm" ; entry to special stage flash
		even
KosPM_Goggle:	binclude	"artkospm/Unused - Goggles.kospm" ; unused goggles
		even
	endif

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Map_SSWalls:	include	"_maps/SS Walls.asm"

KosPM_SSWalls:	binclude	"artkospm/Special Walls.kospm" ; special stage walls
		even
Eni_SSBg1:	binclude	"tilemaps/SS Background 1.eni" ; special stage background (mappings)
		even
KosPM_SSBgFish:	binclude	"artkospm/Special Birds & Fish.kospm" ; special stage birds and fish background
		even
Eni_SSBg2:	binclude	"tilemaps/SS Background 2.eni" ; special stage background (mappings)
		even
KosPM_SSBgCloud:	binclude	"artkospm/Special Clouds.kospm" ; special stage clouds background
		even
KosPM_SSGOAL:	binclude	"artkospm/Special GOAL.kospm" ; special stage GOAL block
		even
KosPM_SSRBlock:	binclude	"artkospm/Special R.kospm" ; special stage R block
		even
KosPM_SS1UpBlock:	binclude	"artkospm/Special 1UP.kospm" ; special stage 1UP block
		even
KosPM_SSEmStars:	binclude	"artkospm/Special Emerald Twinkle.kospm" ; special stage stars from a collected emerald
		even
KosPM_SSRedWhite:	binclude	"artkospm/Special Red-White.kospm" ; special stage red/white block
		even
KosPM_SSZone1:	binclude	"artkospm/Special ZONE1.kospm" ; special stage ZONE1 block
		even
KosPM_SSZone2:	binclude	"artkospm/Special ZONE2.kospm" ; ZONE2 block
		even
KosPM_SSZone3:	binclude	"artkospm/Special ZONE3.kospm" ; ZONE3 block
		even
KosPM_SSZone4:	binclude	"artkospm/Special ZONE4.kospm" ; ZONE4 block
		even
KosPM_SSZone5:	binclude	"artkospm/Special ZONE5.kospm" ; ZONE5 block
		even
KosPM_SSZone6:	binclude	"artkospm/Special ZONE6.kospm" ; ZONE6 block
		even
KosPM_SSUpDown:	binclude	"artkospm/Special UP-DOWN.kospm" ; special stage UP/DOWN block
		even
KosPM_SSEmerald:	binclude	"artkospm/Special Emeralds.kospm" ; special stage chaos emeralds
		even
KosPM_SSGhost:	binclude	"artkospm/Special Ghost.kospm" ; special stage ghost block
		even
KosPM_SSWBlock:	binclude	"artkospm/Special W.kospm" ; special stage W block
		even
KosPM_SSGlass:	binclude	"artkospm/Special Glass.kospm" ; special stage destroyable glass block
		even
KosPM_ResultEm:	binclude	"artkospm/Special Result Emeralds.kospm" ; chaos emeralds on special stage results screen
		even

; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
KosPM_Stalk:	binclude	"artkospm/GHZ Flower Stalk.kospm"
		even
KosPM_Swing:	binclude	"artkospm/GHZ Swinging Platform.kospm"
		even
KosPM_Bridge:	binclude	"artkospm/GHZ Bridge.kospm"
		even
KosPM_GhzUnkBlock:binclude	"artkospm/Unused - GHZ Block.kospm"
		even
KosPM_Ball:	binclude	"artkospm/GHZ Giant Ball.kospm"
		even
KosPM_Spikes:	binclude	"artkospm/Spikes.kospm"
		even
KosPM_GhzLog:	binclude	"artkospm/Unused - GHZ Log.kospm"
		even
KosPM_SpikePole:	binclude	"artkospm/GHZ Spiked Log.kospm"
		even
KosPM_PplRock:	binclude	"artkospm/GHZ Purple Rock.kospm"
		even
KosPM_GhzWall1:	binclude	"artkospm/GHZ Breakable Wall.kospm"
		even
KosPM_GhzWall2:	binclude	"artkospm/GHZ Edge Wall.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
KosPM_Splash:	binclude	"artkospm/LZ Water & Splashes.kospm"
		even
KosPM_LzSpikeBall:binclude	"artkospm/LZ Spiked Ball & Chain.kospm"
		even
KosPM_FlapDoor:	binclude	"artkospm/LZ Flapping Door.kospm"
		even
KosPM_Bubbles:	binclude	"artkospm/LZ Bubbles & Countdown.kospm"
		even
KosPM_LzBlock3:	binclude	"artkospm/LZ 32x16 Block.kospm"
		even
KosPM_LzDoor1:	binclude	"artkospm/LZ Vertical Door.kospm"
		even
KosPM_Harpoon:	binclude	"artkospm/LZ Harpoon.kospm"
		even
KosPM_LzPole:	binclude	"artkospm/LZ Breakable Pole.kospm"
		even
KosPM_LzDoor2:	binclude	"artkospm/LZ Horizontal Door.kospm"
		even
KosPM_LzWheel:	binclude	"artkospm/LZ Wheel.kospm"
		even
KosPM_Gargoyle:	binclude	"artkospm/LZ Gargoyle & Fireball.kospm"
		even
KosPM_LzBlock2:	binclude	"artkospm/LZ Blocks.kospm"
		even
KosPM_LzPlatfm:	binclude	"artkospm/LZ Rising Platform.kospm"
		even
KosPM_Cork:	binclude	"artkospm/LZ Cork.kospm"
		even
KosPM_LzBlock1:	binclude	"artkospm/LZ 32x32 Block.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
KosPM_MzMetal:	binclude	"artkospm/MZ Metal Blocks.kospm"
		even
KosPM_MzSwitch:	binclude	"artkospm/MZ Switch.kospm"
		even
KosPM_MzGlass:	binclude	"artkospm/MZ Green Glass Block.kospm"
		even
KosPM_UnkGrass:	binclude	"artkospm/Unused - Grass.kospm"
		even
KosPM_MzFire:	binclude	"artkospm/Fireballs.kospm"
		even
KosPM_Lava:	binclude	"artkospm/MZ Lava.kospm"
		even
KosPM_MzBlock:	binclude	"artkospm/MZ Green Pushable Block.kospm"
		even
KosPM_MzUnkBlock:	binclude	"artkospm/Unused - MZ Background.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
KosPM_Seesaw:	binclude	"artkospm/SLZ Seesaw.kospm"
		even
KosPM_SlzSpike:	binclude	"artkospm/SLZ Little Spikeball.kospm"
		even
KosPM_Fan:	binclude	"artkospm/SLZ Fan.kospm"
		even
KosPM_SlzWall:	binclude	"artkospm/SLZ Breakable Wall.kospm"
		even
KosPM_Pylon:	binclude	"artkospm/SLZ Pylon.kospm"
		even
KosPM_SlzSwing:	binclude	"artkospm/SLZ Swinging Platform.kospm"
		even
KosPM_SlzBlock:	binclude	"artkospm/SLZ 32x32 Block.kospm"
		even
KosPM_SlzCannon:	binclude	"artkospm/SLZ Cannon.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
KosPM_Bumper:	binclude	"artkospm/SYZ Bumper.kospm"
		even
KosPM_SyzSpike2:	binclude	"artkospm/SYZ Small Spikeball.kospm"
		even
KosPM_LzSwitch:	binclude	"artkospm/Switch.kospm"
		even
KosPM_SyzSpike1:	binclude	"artkospm/SYZ Large Spikeball.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
KosPM_SbzWheel1:	binclude	"artkospm/SBZ Running Disc.kospm"
		even
KosPM_SbzWheel2:	binclude	"artkospm/SBZ Junction Wheel.kospm"
		even
KosPM_Cutter:	binclude	"artkospm/SBZ Pizza Cutter.kospm"
		even
KosPM_Stomper:	binclude	"artkospm/SBZ Stomper.kospm"
		even
KosPM_SpinPform:	binclude	"artkospm/SBZ Spinning Platform.kospm"
		even
KosPM_TrapDoor:	binclude	"artkospm/SBZ Trapdoor.kospm"
		even
KosPM_SbzFloor:	binclude	"artkospm/SBZ Collapsing Floor.kospm"
		even
KosPM_Electric:	binclude	"artkospm/SBZ Electrocuter.kospm"
		even
KosPM_SbzBlock:	binclude	"artkospm/SBZ Vanishing Block.kospm"
		even
KosPM_FlamePipe:	binclude	"artkospm/SBZ Flaming Pipe.kospm"
		even
KosPM_SbzDoor1:	binclude	"artkospm/SBZ Small Vertical Door.kospm"
		even
KosPM_SlideFloor:	binclude	"artkospm/SBZ Sliding Floor Trap.kospm"
		even
KosPM_SbzDoor2:	binclude	"artkospm/SBZ Large Horizontal Door.kospm"
		even
KosPM_Girder:	binclude	"artkospm/SBZ Crushing Girder.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
KosPM_BallHog:	binclude	"artkospm/Enemy Ball Hog.kospm"
		even
KosPM_Crabmeat:	binclude	"artkospm/Enemy Crabmeat.kospm"
		even
KosPM_Buzz:	binclude	"artkospm/Enemy Buzz Bomber.kospm"
		even
KosPM_UnkExplode:	binclude	"artkospm/Unused - Explosion.kospm"
		even
KosPM_Burrobot:	binclude	"artkospm/Enemy Burrobot.kospm"
		even
KosPM_Chopper:	binclude	"artkospm/Enemy Chopper.kospm"
		even
KosPM_Jaws:	binclude	"artkospm/Enemy Jaws.kospm"
		even
KosPM_Roller:	binclude	"artkospm/Enemy Roller.kospm"
		even
KosPM_Motobug:	binclude	"artkospm/Enemy Motobug.kospm"
		even
KosPM_Newtron:	binclude	"artkospm/Enemy Newtron.kospm"
		even
KosPM_Yadrin:	binclude	"artkospm/Enemy Yadrin.kospm"
		even
KosPM_Basaran:	binclude	"artkospm/Enemy Basaran.kospm"
		even
KosPM_Splats:	binclude	"artkospm/Enemy Splats.kospm"
		even
KosPM_Bomb:	binclude	"artkospm/Enemy Bomb.kospm"
		even
KosPM_Orbinaut:	binclude	"artkospm/Enemy Orbinaut.kospm"
		even
KosPM_Cater:	binclude	"artkospm/Enemy Caterkiller.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
KosPM_TitleCard:	binclude	"artkospm/Title Cards.kospm"
		even
KosPM_Hud:	binclude	"artkospm/HUD.kospm" ; HUD (rings, time, score)
		even
KosPM_Lives:	binclude	"artkospm/HUD - Life Counter Icon.kospm"
		even
Art_Ring:	binclude	"artunc/Rings.unc"
		even
KosPM_Sparkles:	binclude	"artkospm/Ring Sparkles.kospm"
		even
KosPM_Monitors:	binclude	"artkospm/Monitors.kospm"
		even
KosPM_Explode:	binclude	"artkospm/Explosion.kospm"
		even
KosPM_ExplodeBoss: binclude	"artkospm/Explosion - Boss.kospm"
		 even
Art_Points:	binclude	"artunc/Points.unc"
		even
KosPM_GameOver:	binclude	"artkospm/Game Over.kospm" ; game over / time over
		even
KosPM_HSpring:	binclude	"artkospm/Spring Horizontal.kospm"
		even
KosPM_VSpring:	binclude	"artkospm/Spring Vertical.kospm"
		even
Art_SignPost:	binclude	"artunc/Signpost.unc" ; end of level signpost
		even
KosPM_Lamp:	binclude	"artkospm/Lamppost.kospm"
		even
Art_BigFlash:	binclude	"artunc/Giant Ring Flash.unc"
		even
KosPM_Bonus:	binclude	"artkospm/Hidden Bonuses.kospm" ; hidden bonuses at end of a level
		even

; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
KosPM_ContSonic:	binclude	"artkospm/Continue Screen Sonic.kospm"
		even
KosPM_MiniSonic:	binclude	"artkospm/Continue Screen Stuff.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
KosPM_Rabbit:	binclude	"artkospm/Animal Rabbit.kospm"
		even
KosPM_Chicken:	binclude	"artkospm/Animal Chicken.kospm"
		even
KosPM_Penguin:	binclude	"artkospm/Animal Penguin.kospm"
		even
KosPM_Seal:	binclude	"artkospm/Animal Seal.kospm"
		even
KosPM_Pig:	binclude	"artkospm/Animal Pig.kospm"
		even
KosPM_Flicky:	binclude	"artkospm/Animal Flicky.kospm"
		even
KosPM_Squirrel:	binclude	"artkospm/Animal Squirrel.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
Blk16_Title:	binclude	"map16/Title.unc"
		even
KosPM_Title:	binclude	"artkospm/8x8 - Title.kospm"	; Title screen patterns
		even
Blk256_Title:	binclude	"map256/Title.unc"
		even

Blk16_GHZ:	binclude	"map16/GHZ.unc"
		even
Kos_GHZ:	binclude	"artkos/8x8 - GHZ.kos"	; GHZ patterns
		even
Blk256_GHZ:	binclude	"map256/GHZ.unc"
		even

Blk16_LZ:	binclude	"map16/LZ.unc"
		even
Kos_LZ:		binclude	"artkos/8x8 - LZ.kos" ; LZ primary patterns
		even
Blk256_LZ:	binclude	"map256/LZ.unc"
		even

Blk16_MZ:	binclude	"map16/MZ.unc"
		even
Kos_MZ:		binclude	"artkos/8x8 - MZ.kos" ; MZ primary patterns
		even
Blk256_MZ:
	if Revision=0
		binclude	"map256/MZ (REV00).unc"
		even
	else
		binclude	"map256/MZ (REV01).unc"
		even
	endif

Blk16_SLZ:	binclude	"map16/SLZ.unc"
		even
Kos_SLZ:	binclude	"artkos/8x8 - SLZ.kos" ; SLZ primary patterns
		even
Blk256_SLZ:	binclude	"map256/SLZ.unc"
		even

Blk16_SYZ:	binclude	"map16/SYZ.unc"
		even
Kos_SYZ:	binclude	"artkos/8x8 - SYZ.kos" ; SYZ primary patterns
		even
Blk256_SYZ:	binclude	"map256/SYZ.unc"
		even

Blk16_SBZ:	binclude	"map16/SBZ.unc"
		even
Kos_SBZ:	binclude	"artkos/8x8 - SBZ.kos" ; SBZ primary patterns
		even
Blk256_SBZ:
	if Revision=0
		binclude	"map256/SBZ (REV00).unc"
		even
	else
		binclude	"map256/SBZ (REV01).unc"
		even
	endif

; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
KosPM_Eggman:	binclude	"artkospm/Boss - Main.kospm"
		even
KosPM_Weapons:	binclude	"artkospm/Boss - Weapons.kospm"
		even
KosPM_Prison:	binclude	"artkospm/Prison Capsule.kospm"
		even
KosPM_Sbz2Eggman:	binclude	"artkospm/Boss - Eggman in SBZ2 & FZ.kospm"
		even
KosPM_FzBoss:	binclude	"artkospm/Boss - Final Zone.kospm"
		even
KosPM_FzEggman:	binclude	"artkospm/Boss - Eggman after FZ Fight.kospm"
		even
KosPM_Exhaust:	binclude	"artkospm/Boss - Exhaust Flame.kospm"
		even
KosPM_EndEm:	binclude	"artkospm/Ending - Emeralds.kospm"
		even
KosPM_EndSonic:	binclude	"artkospm/Ending - Sonic.kospm"
		even
KosPM_TryAgain:	binclude	"artkospm/Ending - Try Again.kospm"
		even
	if Revision=0
KosPM_EndEggman:
		binclude	"artkospm/Unused - Eggman Ending.kospm"
		even
	endif
Kos_EndFlowers:	binclude	"artkos/Flowers at Ending.kos" ; ending sequence animated flowers
		even
KosPM_EndFlower:	binclude	"artkospm/Ending - Flowers.kospm"
		even
KosPM_CreditText:	binclude	"artkospm/Ending - Credits.kospm"
		even
KosPM_EndStH:	binclude	"artkospm/Ending - StH Logo.kospm"
		even

; ---------------------------------------------------------------------------

		; AngleMap starts at $62900 in all revisions, which amounts
		; to $104 bytes of padding for rev00 and $40 for rev01/rev02.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		if Revision=0
			dcb.b	$104,$FF
		else
			dcb.b	$40,$FF
		endif
	endif

; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	binclude	"collide/Angle Map.bin"
		even
CollArray1:	binclude	"collide/Collision Array (Normal).bin"
		even
CollArray2:	binclude	"collide/Collision Array (Rotated).bin"
		even
Col_GHZ:	binclude	"collide/GHZ.bin" ; GHZ index
		even
Col_LZ:		binclude	"collide/LZ.bin" ; LZ index
		even
Col_MZ:		binclude	"collide/MZ.bin" ; MZ index
		even
Col_SLZ:	binclude	"collide/SLZ.bin" ; SLZ index
		even
Col_SYZ:	binclude	"collide/SYZ.bin" ; SYZ index
		even
Col_SBZ:	binclude	"collide/SBZ.bin" ; SBZ index
		even

; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
SS_1:		binclude	"sslayout/1.eni"
		even
SS_2:		binclude	"sslayout/2.eni"
		even
SS_3:		binclude	"sslayout/3.eni"
		even
SS_4:		binclude	"sslayout/4.eni"
		even
	if Revision=0
SS_5:		binclude	"sslayout/5 (REV00).eni"
		even
SS_6:		binclude	"sslayout/6 (REV00).eni"
		even
	else
		; SS 5 and 6 had broken objects outside the accessible layout;
		; REV01 removes those - remaining layouts stay unchanged.
SS_5:		binclude	"sslayout/5 (REV01).eni"
		even
SS_6:		binclude	"sslayout/6 (REV01).eni"
		even
	endif

; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	binclude	"artunc/GHZ Waterfall.unc"
		even
Art_GhzFlower1:	binclude	"artunc/GHZ Flower Large.unc"
		even
Art_GhzFlower2:	binclude	"artunc/GHZ Flower Small.unc"
		even
Art_MzLava1:	binclude	"artunc/MZ Lava Surface.unc"
		even
Art_MzLava2:	binclude	"artunc/MZ Lava.unc"
		even
Art_MzTorch:	binclude	"artunc/MZ Background Torch.unc"
		even
Art_SbzSmoke:	binclude	"artunc/SBZ Background Smoke.unc"
		even

; ---------------------------------------------------------------------------
; Level layout index
; Format: foreground, background, leftover/unused
; ---------------------------------------------------------------------------
Level_Index:
		; GHZ
		dc.w Level_GHZ1-Level_Index, Level_GHZbg-Level_Index, Level_GHZ1Unk-Level_Index
		dc.w Level_GHZ2-Level_Index, Level_GHZbg-Level_Index, Level_GHZ2Unk-Level_Index
		dc.w Level_GHZ3-Level_Index, Level_GHZbg-Level_Index, Level_GHZ3Unk-Level_Index
		dc.w Level_GHZ4Unk-Level_Index, Level_GHZ4Unk-Level_Index, Level_GHZ4Unk-Level_Index
		; LZ
		dc.w Level_LZ1-Level_Index, Level_LZbg-Level_Index, Level_LZ1Unk-Level_Index
		dc.w Level_LZ2-Level_Index, Level_LZbg-Level_Index, Level_LZ2Unk-Level_Index
		dc.w Level_LZ3-Level_Index, Level_LZbg-Level_Index, Level_LZ3Unk-Level_Index
		dc.w Level_SBZ3-Level_Index, Level_LZbg-Level_Index, Level_SBZ3Unk-Level_Index
		; MZ
		dc.w Level_MZ1-Level_Index, Level_MZ1bg-Level_Index, Level_MZ1-Level_Index
		dc.w Level_MZ2-Level_Index, Level_MZ2bg-Level_Index, Level_MZ2Unk-Level_Index
		dc.w Level_MZ3-Level_Index, Level_MZ3bg-Level_Index, Level_MZ3Unk-Level_Index
		dc.w Level_MZ4Unk-Level_Index, Level_MZ4Unk-Level_Index, Level_MZ4Unk-Level_Index
		; SLZ
		dc.w Level_SLZ1-Level_Index, Level_SLZbg-Level_Index, Level_SLZ1Unk-Level_Index
		dc.w Level_SLZ2-Level_Index, Level_SLZbg-Level_Index, Level_SLZ1Unk-Level_Index
		dc.w Level_SLZ3-Level_Index, Level_SLZbg-Level_Index, Level_SLZ1Unk-Level_Index
		dc.w Level_SLZ1Unk-Level_Index, Level_SLZ1Unk-Level_Index, Level_SLZ1Unk-Level_Index
		; SYZ
		dc.w Level_SYZ1-Level_Index, Level_SYZbg-Level_Index, Level_SYZ1Unk-Level_Index
		dc.w Level_SYZ2-Level_Index, Level_SYZbg-Level_Index, Level_SYZ2Unk-Level_Index
		dc.w Level_SYZ3-Level_Index, Level_SYZbg-Level_Index, Level_SYZ3Unk-Level_Index
		dc.w Level_SYZ4Unk-Level_Index, Level_SYZ4Unk-Level_Index, Level_SYZ4Unk-Level_Index
		; SBZ
		dc.w Level_SBZ1-Level_Index, Level_SBZ1bg-Level_Index, Level_SBZ1bg-Level_Index
		dc.w Level_SBZ2-Level_Index, Level_SBZ2bg-Level_Index, Level_SBZ2bg-Level_Index
		dc.w Level_SBZ2-Level_Index, Level_SBZ2bg-Level_Index, Level_SBZ2Unk-Level_Index
		dc.w Level_SBZ4Unk-Level_Index, Level_SBZ4Unk-Level_Index, Level_SBZ4Unk-Level_Index
		zonewarning Level_Index,24
		; Ending
		dc.w Level_End-Level_Index, Level_GHZbg-Level_Index, Level_EndUnk-Level_Index
		dc.w Level_End-Level_Index, Level_GHZbg-Level_Index, Level_EndUnk-Level_Index
		dc.w Level_EndUnk-Level_Index, Level_EndUnk-Level_Index, Level_EndUnk-Level_Index
		dc.w Level_EndUnk-Level_Index, Level_EndUnk-Level_Index, Level_EndUnk-Level_Index

Level_GHZ1:	binclude	"levels/ghz1.bin"
		even
Level_GHZ1Unk:	dc.l 0
Level_GHZ2:	binclude	"levels/ghz2.bin"
		even
Level_GHZ2Unk:	dc.l 0
Level_GHZ3:	binclude	"levels/ghz3.bin"
		even
Level_GHZbg:	binclude	"levels/ghzbg.bin"
		even
Level_GHZ3Unk:	dc.l 0
Level_GHZ4Unk:	dc.l 0

Level_LZ1:	binclude	"levels/lz1.bin"
		even
Level_LZbg:	binclude	"levels/lzbg.bin"
		even
Level_LZ1Unk:	dc.l 0
Level_LZ2:	binclude	"levels/lz2.bin"
		even
Level_LZ2Unk:	dc.l 0
Level_LZ3:	binclude	"levels/lz3.bin"
		even
Level_LZ3Unk:	dc.l 0
Level_SBZ3:	binclude	"levels/sbz3.bin"
		even
Level_SBZ3Unk:	dc.l 0

Level_MZ1:	binclude	"levels/mz1.bin"
		even
Level_MZ1bg:	binclude	"levels/mz1bg.bin"
		even
Level_MZ2:	binclude	"levels/mz2.bin"
		even
Level_MZ2bg:	binclude	"levels/mz2bg.bin"
		even
Level_MZ2Unk:	dc.l 0
Level_MZ3:	binclude	"levels/mz3.bin"
		even
Level_MZ3bg:	binclude	"levels/mz3bg.bin"
		even
Level_MZ3Unk:	dc.l 0
Level_MZ4Unk:	dc.l 0

Level_SLZ1:	binclude	"levels/slz1.bin"
		even
Level_SLZbg:	binclude	"levels/slzbg.bin"
		even
Level_SLZ2:	binclude	"levels/slz2.bin"
		even
Level_SLZ3:	binclude	"levels/slz3.bin"
		even
Level_SLZ1Unk:	dc.l 0

Level_SYZ1:	binclude	"levels/syz1.bin"
		even
Level_SYZbg:
	if Revision=0
		binclude	"levels/syzbg (REV00).bin"
	else
		binclude	"levels/syzbg (REV01).bin"
	endif
		even
Level_SYZ1Unk:	dc.l 0
Level_SYZ2:	binclude	"levels/syz2.bin"
		even
Level_SYZ2Unk:	dc.l 0
Level_SYZ3:	binclude	"levels/syz3.bin"
		even
Level_SYZ3Unk:	dc.l 0
Level_SYZ4Unk:	dc.l 0

Level_SBZ1:	binclude	"levels/sbz1.bin"
		even
Level_SBZ1bg:	binclude	"levels/sbz1bg.bin"
		even
Level_SBZ2:	binclude	"levels/sbz2.bin"
		even
Level_SBZ2bg:	binclude	"levels/sbz2bg.bin"
		even
Level_SBZ2Unk:	dc.l 0
Level_SBZ4Unk:	dc.l 0
Level_End:	binclude	"levels/ending.bin"
		even
Level_EndUnk:	dc.l 0

; ---------------------------------------------------------------------------
; Uncompressed graphics - Giant Rings
; ---------------------------------------------------------------------------
Art_BigRing:	binclude	"artunc/Giant Ring.unc"
Art_BigRing_size:	equ	*-Art_BigRing
		even

KosPM_MySplash:   binclude        "MySplashScreen/Art.kospm"
                even
Eni_MySplash:   binclude        "MySplashScreen/Map.eni"
                even
Pal_MySplash:   binclude        "MySplashScreen/Palette.bin"
                even

; ---------------------------------------------------------------------------

		; ObjPos_Index starts at $6B000 in all revisions, which amounts
		; to $9C bytes of padding for rev00 and $DC for rev01/rev02.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$100
	endif

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Index:
		; GHZ
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; LZ
		dc.w ObjPos_LZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; MZ
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SLZ
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SYZ
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SBZ
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_FZ-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		zonewarning ObjPos_Index,$10
		; Ending
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; --- Put extra object data here. ---
ObjPosLZPlatform_Index:
		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
		dc.w ObjPos_LZ2pf1-ObjPos_Index, ObjPos_LZ2pf2-ObjPos_Index
		dc.w ObjPos_LZ3pf1-ObjPos_Index, ObjPos_LZ3pf2-ObjPos_Index
		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
ObjPosSBZPlatform_Index:
		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.w ObjPos_SBZ1pf3-ObjPos_Index, ObjPos_SBZ1pf4-ObjPos_Index
		dc.w ObjPos_SBZ1pf5-ObjPos_Index, ObjPos_SBZ1pf6-ObjPos_Index
		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.b $FF, $FF, 0, 0, 0,	0

ObjPos_GHZ1:	binclude	"objpos/ghz1.bin"
		even
ObjPos_GHZ2:	binclude	"objpos/ghz2.bin"
		even
ObjPos_GHZ3:
	if Revision=0
		binclude	"objpos/ghz3 (REV00).bin"
		even
	else
		binclude	"objpos/ghz3 (REV01).bin"
		even
	endif

ObjPos_LZ1:
	if Revision=0
		binclude	"objpos/lz1 (REV00).bin"
		even
	else
		binclude	"objpos/lz1 (REV01).bin"
		even
	endif
ObjPos_LZ2:	binclude	"objpos/lz2.bin"
		even
ObjPos_LZ3:
	if Revision=0
		binclude	"objpos/lz3 (REV00).bin"
		even
	else
		binclude	"objpos/lz3 (REV01).bin"
		even
	endif
ObjPos_SBZ3:	binclude	"objpos/sbz3.bin"
		even

ObjPos_LZ1pf1:	binclude	"objpos/platforms/lz1pf1.bin"
		even
ObjPos_LZ1pf2:	binclude	"objpos/platforms/lz1pf2.bin"
		even
ObjPos_LZ2pf1:	binclude	"objpos/platforms/lz2pf1.bin"
		even
ObjPos_LZ2pf2:	binclude	"objpos/platforms/lz2pf2.bin"
		even
ObjPos_LZ3pf1:	binclude	"objpos/platforms/lz3pf1.bin"
		even
ObjPos_LZ3pf2:	binclude	"objpos/platforms/lz3pf2.bin"
		even

ObjPos_MZ1:
	if Revision=0
		binclude	"objpos/mz1 (REV00).bin"
		even
	else
		binclude	"objpos/mz1 (REV01).bin"
		even
	endif
ObjPos_MZ2:	binclude	"objpos/mz2.bin"
		even
ObjPos_MZ3:	binclude	"objpos/mz3.bin"
		even

ObjPos_SLZ1:	binclude	"objpos/slz1.bin"
		even
ObjPos_SLZ2:	binclude	"objpos/slz2.bin"
		even
ObjPos_SLZ3:	binclude	"objpos/slz3.bin"
		even
ObjPos_SYZ1:	binclude	"objpos/syz1.bin"
		even
ObjPos_SYZ2:	binclude	"objpos/syz2.bin"
		even
ObjPos_SYZ3:
	if Revision=0
		binclude	"objpos/syz3 (REV00).bin"
		even
	else
		binclude	"objpos/syz3 (REV01).bin"
		even
	endif

ObjPos_SBZ1:
	if Revision=0
		binclude	"objpos/sbz1 (REV00).bin"
		even
	else
		binclude	"objpos/sbz1 (REV01).bin"
		even
	endif
ObjPos_SBZ2:	binclude	"objpos/sbz2.bin"
		even
ObjPos_FZ:	binclude	"objpos/fz.bin"
		even

ObjPos_SBZ1pf1:	binclude	"objpos/platforms/sbz1pf1.bin"
		even
ObjPos_SBZ1pf2:	binclude	"objpos/platforms/sbz1pf2.bin"
		even
ObjPos_SBZ1pf3:	binclude	"objpos/platforms/sbz1pf3.bin"
		even
ObjPos_SBZ1pf4:	binclude	"objpos/platforms/sbz1pf4.bin"
		even
ObjPos_SBZ1pf5:	binclude	"objpos/platforms/sbz1pf5.bin"
		even
ObjPos_SBZ1pf6:	binclude	"objpos/platforms/sbz1pf6.bin"
		even

ObjPos_End:	binclude	"objpos/ending.bin"
		even

ObjPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0

; ---------------------------------------------------------------------------

		; SoundDriver starts at $71990 in all revisions, which amounts
		; to $62A bytes of padding for rev00 and $63C for rev01/rev02.
		; It appears to be placed in such a way that the sound driver
		; ends right on the $80000 mark in the ROM in all revisions.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		if Revision=0
			dcb.b	$62A,$FF
		else
			dcb.b	$63C,$FF
		endif
	endif

; ---------------------------------------------------------------------------

		include	"_inc/Title Cards Extended.asm"

SoundDriver:	include "s1.sounddriver.asm"
		even

; ---------------------------------------------------------------------------

; =============================================================
; --------------------------------------------------------------
; Debugging modules
; --------------------------------------------------------------

	include	"ErrorHandler.asm"

; --------------------------------------------------------------
; WARNING!
;	DO NOT put any data from now on! DO NOT use ROM padding!
;	Symbol data should be appended here after ROM is compiled
;	by ConvSym utility, otherwise debugger modules won't be able
;	to resolve symbol names.
; --------------------------------------------------------------

; end of 'ROM'
EndOfRom:

		END
