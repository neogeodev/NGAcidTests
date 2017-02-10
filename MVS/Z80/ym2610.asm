.ORG $0008
	nop						; write_port_A
	nop
	push  af
	ld    a,d
	out   (4),a
	ld    a,e
	out   (5),a
	pop   af
	nop
	nop
	ret

.ORG $0028
	nop						; write_port_B
	nop
	push  af
	ld    a,d
	out   (6),a
	ld    a,e
	out   (7),a
	pop   af
	nop
	nop
	ret

.ORG $0800
Reset_YM2610:
	ld    de,$2801			; Key off FM channel 1
	write_port_A
	ld    de,$2802			; Key off FM channel 2
	write_port_A
	ld    de,$2805			; Key off FM channel 3
	write_port_A
	ld    de,$2806			; Key off FM channel 4
	write_port_A
	ld    de,$0800			; SSG channel A volume = 0
	write_port_A
	ld    de,$0900			; SSG channel B volume = 0
	write_port_A
	ld    de,$0A00			; SSG channel C volume = 0
	write_port_A
	ld    de,$1001			; Reset ADPCM-B
	write_port_A
	ld    de,$1C00			; Unmask ADPCM flags
	write_port_A
	ld    de,$1000			; Release reset ADPCM-B
	write_port_A
	ld    de,$2730			; Reset both timer flags
	write_port_A
	ret
