automap:
	move.w  d1,VRAM_ADDR
    move.w  (a0)+,d3			    ; Width
    move.w  (a0)+,d4			    ; Height
    move.w  d3,d5
	move.w  #$20,VRAM_MOD
.height_loop:
    move.w  d5,d3					; Reload width
.width_loop:
    move.w  (a0)+,d0
	add.w   d2,d0
	move.w  d0,VRAM_RW
    nop
    subq.w  #1,d3
    bne     .width_loop
	addq.w  #1,d1
	move.w  d1,VRAM_ADDR			; Next line
    subq.w  #1,d4
    bne     .height_loop
	rts

vramcopy:
	lea     VRAM_BUFFER,a0
.copy_loop:
    move.w  (a0)+,VRAM_RW
    nop                  		; Slow the fuck down
    subq.b  #1,d7
    bne     .copy_loop
    rts
