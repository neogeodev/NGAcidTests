MESS_MENU:
	dc.w $0001
	dc.w $00FF

	dc.w $0003
	dc.w $7144

	dc.w $0108
	dc.b "The NEOGEO Acid Test", $FF

	dc.w $0003
	dc.w $71A8

	dc.w $0007
	dc.b "1. Mem. map test", $FF
	
	dc.w $0005
	dc.w $0001
	
	dc.w $0007
	dc.b "2. LSPC test", $FF
	
	dc.w $0005
	dc.w $0001
	
	dc.w $0007
	dc.b "3. WAIT test", $FF

	dc.w $0005
	dc.w $0001
	
	dc.w $0007
	dc.b "4. Cab I/O test", $FF
	
	dc.w $0005
	dc.w $0001
	
	dc.w $0007
	dc.b "5. Z80 I/O test", $FF

	dc.w $0000
