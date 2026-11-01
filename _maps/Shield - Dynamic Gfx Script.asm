; --------------------------------------------------------------------------------
; Dynamic Pattern Loading Cues - output from ClownMapEd - MapMacros format
; --------------------------------------------------------------------------------

.offsets:	mappingsTable
	mappingsTableEntry.w	.frame0
	mappingsTableEntry.w	.frame1
	mappingsTableEntry.w	.frame2
	mappingsTableEntry.w	.frame3
	mappingsTableEntry.w	.frame4
	mappingsTableEntry.w	.frame5
	mappingsTableEntry.w	.frame6

.frame0:	dplcHeader
.frame0_End

.frame1:	dplcHeader
	dplcEntry	4, 0
.frame1_End

.frame2:	dplcHeader
	dplcEntry	4, 4
.frame2_End

.frame3:	dplcHeader
	dplcEntry	4, 8
.frame3_End

.frame4:	dplcHeader
	dplcEntry	4, 12
.frame4_End

.frame5:	dplcHeader
	dplcEntry	4, 16
.frame5_End

.frame6:	dplcHeader
	dplcEntry	12, 20
.frame6_End

	even
