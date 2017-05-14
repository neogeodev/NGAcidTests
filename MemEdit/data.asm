hex_lut:
	dc.b $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46

MESS_MENU:
	dc.w $0001					; Bytes, end code = $FF
	dc.w $00FF

	dc.w $2002  				; Set auto-inc

	dc.w $0003					; Set VRAM address
	dc.w $7184
	dc.w $0108					; Write with big font
	dc.b "NEOGEO  LAG TEST", $FF

	dc.w $0003					; Set VRAM address
	dc.w $7230
	dc.w $0007					; Write
	dc.b "ms", $FF

	dc.w $0003					; Set VRAM address
	dc.w $7196
	dc.w $0007					; Write
	dc.b "1 frame = 16.8ms", $FF
	
	dc.w $0001					; Bytes, end code = $FF
	dc.w $10FF

	dc.w $0003					; Set VRAM address
	dc.w $719A
	dc.w $0007					; Write
	dc.b "BEEP ON", $FF

	dc.w $0000

box_data:
    dc.w 17, 4
    dc.w 12,13,13,13,13,13,13,13,20,13,13,13,13,13,13,13,14
    dc.w 15,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16
    dc.w 15,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16
    dc.w 17,18,18,18,18,18,18,18,21,18,18,18,18,18,18,18,19
