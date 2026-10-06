Splash_Hill_Header:
	smpsHeaderStartSong 1
	smpsHeaderVoice     Splash_Hill_Voices
	smpsHeaderChan      $06, $03
	smpsHeaderTempo     $02, $00

	smpsHeaderDAC       Splash_Hill_DAC
	smpsHeaderFM        Splash_Hill_FM1,	$00, $18
	smpsHeaderFM        Splash_Hill_FM2,	$00, $15
	smpsHeaderFM        Splash_Hill_FM3,	$00, $15
	smpsHeaderFM        Splash_Hill_FM4,	$00, $14
	smpsHeaderFM        Splash_Hill_FM5,	$00, $1B
	smpsHeaderPSG       Splash_Hill_PSG1,	$00, $00, $00, $00
	smpsHeaderPSG       Splash_Hill_PSG2,	$00, $00, $00, $00
	smpsHeaderPSG       Splash_Hill_PSG3,	$00, $07, $00, $00

; DAC Data
Splash_Hill_DAC:
	dc.b	dKick, $0C, dSnare, dKick, $06, $06, dSnare, $0C
	smpsLoop            $00, $03, Splash_Hill_DAC
	dc.b	dKick, dSnare, dKick, $06, $06, dSnare, dSnare

Splash_Hill_Loop00:
	dc.b	dKick, $0C, dSnare, dKick, $06, $06, dSnare, $0C
	smpsLoop            $00, $03, Splash_Hill_Loop00
	dc.b	dKick, dSnare, dKick, $06, dSnare, dSnare, dSnare
	smpsLoop            $01, $02, Splash_Hill_DAC
	dc.b	dKick, $0C, dSnare, dKick, $06, $06, dSnare, dKick, $0C, $06

Splash_Hill_Loop01:
	dc.b	dSnare, $0C, dKick, $06, $06, dSnare, $0C, dKick
	smpsLoop            $00, $02, Splash_Hill_Loop01
	dc.b	dSnare, dKick, $06, $06, dSnare, dSnare, dKick, $0C, dSnare, dKick, $06, $06
	dc.b	dSnare, $0C, dKick, dSnare, dKick, $06, $06, dSnare, dKick, $0C, dSnare, $06
	dc.b	$06, $06, $06, dKick, dSnare, dSnare
	smpsJump            Splash_Hill_DAC

; FM1 Data
Splash_Hill_FM1:
	smpsSetvoice        $00

Splash_Hill_Loop05:
	dc.b	nF3, $06, nF4
	smpsLoop            $00, $04, Splash_Hill_Loop05

Splash_Hill_Loop06:
	dc.b	nEb3, nEb4
	smpsLoop            $00, $04, Splash_Hill_Loop06

Splash_Hill_Loop07:
	dc.b	nBb2, nBb3
	smpsLoop            $00, $04, Splash_Hill_Loop07
	dc.b	nC3, nC4, nC3, nC4, nC3, nC4, nD3, nE3
	smpsLoop            $01, $03, Splash_Hill_Loop05

Splash_Hill_Loop08:
	dc.b	nF3, nF4
	smpsLoop            $00, $04, Splash_Hill_Loop08

Splash_Hill_Loop09:
	dc.b	nEb3, nEb4
	smpsLoop            $00, $04, Splash_Hill_Loop09

Splash_Hill_Loop0A:
	dc.b	nD3, nD4
	smpsLoop            $00, $04, Splash_Hill_Loop0A

Splash_Hill_Loop0B:
	dc.b	nC3, nC4
	smpsLoop            $00, $04, Splash_Hill_Loop0B
	dc.b	nBb2, nBb3, nBb2, nBb3, nBb2, nBb3, nBb2, nC3, $0C, nC4, $06, nC3
	dc.b	nC4, nC3, nC4, nC3, nC4

Splash_Hill_Loop0C:
	dc.b	nD3, nD4
	smpsLoop            $00, $04, Splash_Hill_Loop0C

Splash_Hill_Loop0D:
	dc.b	nEb3, nEb4
	smpsLoop            $00, $04, Splash_Hill_Loop0D

Splash_Hill_Loop0E:
	dc.b	nBb2, nBb3
	smpsLoop            $00, $04, Splash_Hill_Loop0E
	dc.b	nC3, nC4, nC3, nC4, nC3, nF3, nFs3, nG3, $0C, $06, nF3, $0C
	dc.b	nE3, nD3, $06, nC3
	smpsJump            Splash_Hill_FM1

; FM2 Data
Splash_Hill_FM2:
	smpsSetvoice        $01

Splash_Hill_Loop04:
	dc.b	nF4, $06, nC4, $30, $2A, nG4, $0C, nA4, $06, nF4, $1E, $18
	dc.b	nE4
	smpsLoop            $00, $02, Splash_Hill_Loop04
	dc.b	nC5, $0C, nF4, $48, $0C, nG4, nD4, $24, $18, nE4, nC5, $0C
	dc.b	nF4, $48, $0C, nG4, nF4, $3C, nRst, $06, nE5, nC5, $0C, nD5
	dc.b	$12, nE5, $0C, nF5, nE5, $06, nRst, nE5, nD5, $0C, nC5, nG4
	dc.b	nA4, $12, nD5, $1E, nG4, $12, $1E, nBb4, $12, nC5, $0C, nD5
	dc.b	$06, nF5, $0C, nC5, $12, nF5, $0C, nA5, $06, nC5, nG5, $18
	dc.b	nC6, $1E
	smpsJump            Splash_Hill_FM2

; FM3 Data
Splash_Hill_FM3:
	smpsSetvoice        $01

Splash_Hill_Loop03:
	dc.b	nRst, $0C, nG4, $06, nF4, $24, nRst, $06, nF4, nG4, nBb4, nA4
	dc.b	nG4, nF4, nD4, $30, nC4, $18, $18
	smpsLoop            $00, $02, Splash_Hill_Loop03
	dc.b	nRst, $12, nG4, $0C, nA4, nBb4, nC5, $12, nA4, $0C, nRst, $1E
	dc.b	nF4, nF4, $18, nC4, nRst, $12, nG4, $0C, nA4, nBb4, nC5, $12
	dc.b	nA4, $0C, nRst, $1E, nC5, $30, nF5, $0C, nRst, $06, nA4, $0C
	dc.b	nBb4, $12, nF4, $0C, nBb4, nG4, $06, nRst, nG4, nG4, $0C, $0C
	dc.b	nRst, nF4, $12, $1E, nD5, $12, nC5, $1E, nF4, $12, $0C, $06
	dc.b	nBb4, $0C, nG4, $12, nC5, $0C, nF5, $06, nRst, nE5, $18, nG5
	dc.b	$1E
	smpsJump            Splash_Hill_FM3

; FM4 Data
Splash_Hill_FM4:
	smpsPan             panLeft, $00
	smpsSetvoice        $02
	dc.b	nRst, $1E, nF5, $06, nC5, nG5, nF5, $30, nRst, $78, nF5, $06
	dc.b	nC5, nG5, nA5, $36, nRst, $7F, $59, nG5, $0C, nD5, $06, nF5
	dc.b	$24, nE5, $06, nF5, nG5, nRst, $78, nG5, $0C, nA5, $06, nBb5
	dc.b	nC6, $24, nA5, $0C, nRst, $42
	smpsAlterVol        $07
	dc.b	nD5, $06, nRst, $0C, nC5, $06, $06, nRst, $72, nC5, $06, nRst
	dc.b	$78
	smpsAlterVol        $F9
	smpsJump            Splash_Hill_FM4

; FM5 Data
Splash_Hill_FM5:
	smpsPan             panRight, $00
	smpsSetvoice        $02
	dc.b	nRst, $2A, nF5, $06, nC5, nG5, nF5, $30, nRst, $78, nF5, $06
	dc.b	nC5, nG5, nA5, $36, nRst, $7F, $59, nG5, $0C, nD5, $06, nF5
	dc.b	$24, nE5, $06, nF5, nG5, nRst, $78, nG5, $0C, nA5, $06, nBb5
	dc.b	nC6, $24, nA5, $06, nF5, nRst, nD5, nRst, nD5

Splash_Hill_Loop02:
	dc.b	nRst, nG5
	smpsLoop            $00, $04, Splash_Hill_Loop02
	dc.b	nRst, $12, nF5, $06, nD5, nRst, nF5, nD5, nRst, nF5, nRst, nG5
	dc.b	nRst, nG5, nRst, nG5, nC5, nC5, nRst, nF5, nD5, nRst, nF5, nD5
	dc.b	nD5, nD5, nRst, nG5, nE5, nF5, nRst, nA5, nRst, nG5, nRst, nE5
	dc.b	nF5, nG5, nRst, $18
	smpsJump            Splash_Hill_FM5

; PSG3 Data
Splash_Hill_PSG3:
	smpsPSGform         $E7

Splash_Hill_Jump00:
	dc.b	nRst, $06
	smpsPSGvoice        fTone_01
	dc.b	nMaxPSG

Splash_Hill_Loop0F:
	dc.b	$0C, $0C, $06, $06, $0C
	smpsLoop            $00, $10, Splash_Hill_Loop0F

Splash_Hill_Loop10:
	dc.b	$06, $06, $0C, $0C, $0C
	smpsLoop            $00, $06, Splash_Hill_Loop10
	dc.b	$06, $06, $0C, $0C, $06
	smpsJump            Splash_Hill_Jump00

; PSG1 Data
Splash_Hill_PSG1:
; PSG2 Data
Splash_Hill_PSG2:
	smpsStop

Splash_Hill_Voices:
;	Voice $00
;	$2C
;	$70, $40, $21, $60, 	$9F, $1F, $1F, $5F, 	$0C, $09, $0C, $15
;	$04, $04, $06, $06, 	$56, $46, $46, $4F, 	$0C, $00, $10, $00
	smpsVcAlgorithm     $04
	smpsVcFeedback      $05
	smpsVcUnusedBits    $00
	smpsVcDetune        $06, $02, $04, $07
	smpsVcCoarseFreq    $00, $01, $00, $00
	smpsVcRateScale     $01, $00, $00, $02
	smpsVcAttackRate    $1F, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $15, $0C, $09, $0C
	smpsVcDecayRate2    $06, $06, $04, $04
	smpsVcDecayLevel    $04, $04, $04, $05
	smpsVcReleaseRate   $0F, $06, $06, $06
	smpsVcTotalLevel    $00, $10, $00, $0C

;	Voice $01
;	$3A
;	$01, $07, $31, $71, 	$8E, $8E, $8D, $53, 	$0E, $0E, $0E, $06
;	$00, $00, $00, $00, 	$1F, $FF, $1F, $2F, 	$18, $28, $27, $00
	smpsVcAlgorithm     $02
	smpsVcFeedback      $07
	smpsVcUnusedBits    $00
	smpsVcDetune        $07, $03, $00, $00
	smpsVcCoarseFreq    $01, $01, $07, $01
	smpsVcRateScale     $01, $02, $02, $02
	smpsVcAttackRate    $13, $0D, $0E, $0E
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $06, $0E, $0E, $0E
	smpsVcDecayRate2    $00, $00, $00, $00
	smpsVcDecayLevel    $02, $01, $0F, $01
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $00, $27, $28, $18

;	Voice $02
;	$3D
;	$01, $01, $01, $01, 	$94, $19, $19, $19, 	$0F, $0D, $0D, $0D
;	$07, $04, $04, $04, 	$25, $1A, $1A, $1A, 	$15, $00, $00, $00
	smpsVcAlgorithm     $05
	smpsVcFeedback      $07
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $00, $00, $00
	smpsVcCoarseFreq    $01, $01, $01, $01
	smpsVcRateScale     $00, $00, $00, $02
	smpsVcAttackRate    $19, $19, $19, $14
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $0D, $0D, $0D, $0F
	smpsVcDecayRate2    $04, $04, $04, $07
	smpsVcDecayLevel    $01, $01, $01, $02
	smpsVcReleaseRate   $0A, $0A, $0A, $05
	smpsVcTotalLevel    $00, $00, $00, $15

