DPLC_cf64: mappingsTable
	mappingsTableEntry.w	ShieldDPLC0
	mappingsTableEntry.w	ShieldDPLC1
	mappingsTableEntry.w	ShieldDPLC2
	mappingsTableEntry.w	ShieldDPLC3
	mappingsTableEntry.w	ShieldDPLC4
	mappingsTableEntry.w	ShieldDPLC5
	mappingsTableEntry.w	ShieldDPLC6
	mappingsTableEntry.w	ShieldDPLC7
	mappingsTableEntry.w	ShieldDPLC8
	mappingsTableEntry.w	ShieldDPLC9
	mappingsTableEntry.w	ShieldDPLCA

ShieldDPLC0:	dplcHeader
ShieldDPLC0_End

ShieldDPLC1:	dplcHeader
 dplcEntry 4, 0
ShieldDPLC1_End

ShieldDPLC2:	dplcHeader
 dplcEntry 4, 4
ShieldDPLC2_End

ShieldDPLC3:	dplcHeader
 dplcEntry 4, 8
ShieldDPLC3_End

ShieldDPLC4:	dplcHeader
 dplcEntry 4, $C
ShieldDPLC4_End

ShieldDPLC5:	dplcHeader
 dplcEntry 4, $10
ShieldDPLC5_End

ShieldDPLC6:	dplcHeader
 dplcEntry $C, $14
ShieldDPLC6_End

ShieldDPLC7:	dplcHeader
 dplcEntry $10, 0
 dplcEntry 2, $10
ShieldDPLC7_End

ShieldDPLC8:	dplcHeader
 dplcEntry $10, 0
 dplcEntry 2, $10
ShieldDPLC8_End

ShieldDPLC9:	dplcHeader
 dplcEntry $10, $12
 dplcEntry 2, $22
ShieldDPLC9_End

ShieldDPLCA:	dplcHeader
 dplcEntry $10, $12
 dplcEntry 2, $22
ShieldDPLCA_End

	even