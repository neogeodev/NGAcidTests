;NeoGeo spritetest v1
;furrtek CC BY-NC 2017

    cpu 68000

    supmode on

	INCLUDE "regdefs.asm"
    INCLUDE "header.asm"
    INCLUDE "ram.asm"

    ORG $300
	INCLUDE "irq.asm"

	ORG $1000
Start:
    lea     $10F300,a7
    move.w  #$0000,REG_LSPCMODE

    move.b  #2,BIOS_USER_REQUEST	; Game in progress

    move.l  #($F300/32)-1,d7		; Clear work RAM
    lea     RAMSTART,a0
    moveq.l #0,d0
.clear_ram:
    move.b  d0,REG_DIPSW			; Watchdoge
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    dbra    d7,.clear_ram

    move.w  #7,REG_IRQACK
    move.w  #$2000,sr 				; Allow IRQs

    move.w  #BLACK,PALETTES+0		; Set palette 0
    move.w  #WHITE,PALETTES+2
    move.w  #BLUE,PALETTES+4
    move.w  #RED,PALETTES+6

    move.l  #16-1,d7				; Set palette 1
    lea     PALETTES+32,a0
.set_pal:
    move.w  #WHITE,(a0)+
    dbra    d7,.set_pal

    move.l  #$500-1,d7				; Clear fix layer
	move.w  #$7000,VRAM_ADDR
	ori.l	#0,d0 					; 16clk
	move.w  #$0001,VRAM_MOD
	ori.l	#0,d0 					; 16clk
    moveq.l #0,d0
.clear_fix:
	move.w  #$00FF,VRAM_RW
	nop
	nop
	nop
    dbra    d7,.clear_fix

    jsr     BIOSF_LSP_1ST
    
    ; Set up sprite
	move.w  #$0040,VRAM_ADDR
	ori.l	#0,d0 					; 16clk
	move.w  #268,VRAM_RW
	ori.l	#0,d0 					; 16clk
	move.w  #$0041,VRAM_ADDR
	ori.l	#0,d0 					; 16clk
	move.w  #$0100,VRAM_RW
	ori.l	#0,d0 					; 16clk
	move.w  #$8001,VRAM_ADDR
	ori.l	#0,d0 					; 16clk
	move.w  #$0FFF,VRAM_RW
	ori.l	#0,d0 					; 16clk
	move.w  #$8201,VRAM_ADDR
	ori.l	#0,d0 					; 16clk
	move.w  #$F801,VRAM_RW
	ori.l	#0,d0 					; 16clk
	move.w  #$8401,VRAM_ADDR
	ori.l	#0,d0 					; 16clk
	move.w  #$0400,VRAM_RW
	ori.l	#0,d0 					; 16clk

	move.b  #$0F,SHRINK_W

	clr.b   FLAG_VBI

MainLoop:
    tst.b   FLAG_VBI				; Wait for VBI
    beq     MainLoop
    clr.b   FLAG_VBI

    move.b  BIOS_P1CHANGE,d0
    btst    #2,d0
    beq     .noleft
    move.b  SHRINK_W,d0
	tst.b   d0
	beq     .noleft
	subq.b  #1,d0
    move.b  d0,SHRINK_W
.noleft:

    move.b  BIOS_P1CHANGE,d0
    btst    #3,d0
    beq     .noright
    move.b  SHRINK_W,d0
	cmp.b   #15,d0
	beq     .noright
	addq.b  #1,d0
    move.b  d0,SHRINK_W
.noright:

	; Update VRAM
	move.w  #$8001,VRAM_ADDR
	ori.l	#0,d0 					; 16clk
    move.b  SHRINK_W,d0
    lsl.w   #8,d0
	ori.w   #$00FF,d0
	move.w  d0,VRAM_RW

	; Display frame counter
	moveq.l #0,d0
    move.b  SHRINK_W,d0
	jsr     hex2bcd
    move.w  d2,d0
    move.w  #$7210,VRAM_ADDR
    jsr     digiwrite

	bra     MainLoop


hex2bcd:
    moveq.l #4,d7				; 4 digits
	moveq.l #0,d2
.conv_loop:
	divu.w  #10,d0
	move.l  d0,d1
    and.l   #$FFFF,d0			; Keep quotient
    clr.w   d1					; Keep remainder
    lsr.l   #4,d1
    lsr.w   #4,d2
    add.w   d1,d2				; Insert new digit
    subq.b  #1,d7
    bne     .conv_loop
    rts

    INCLUDE "video.asm"
