digiwrite:
	ori.l	#0,d0 				; 16clk
    moveq.l #4,d7				; 4 digits
	moveq.l #0,d1
    move.w  #-$20,VRAM_MOD		; Draw backwards (simpler)
.disp_loop:
	move.b  d0,d1
	andi.b  #$F,d1
	cmp.b   #9,d1				; Hex to ASCII
	bls     .num
	addq.b  #7,d1
.num:
	addi.w  #$30,d1
    move.w  d1,VRAM_RW
	ori.l	#0,d0 				; 16clk
    lsr.w   #4,d0				; Next nibble
	subq.b  #1,d7
    bne     .disp_loop
    rts
