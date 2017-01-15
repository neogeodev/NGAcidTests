;NeoGeo lagtest v1
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

    move.w  #BLACK,PALETTES			; Palette 0 color 0
    move.w  #WHITE,PALETTES+2		; Palette 0 color 1: Text
    move.w  #BLACK,PALETTES+4		; Palette 0 color 2
    move.w  #$0BBB,PALETTES+8		; Palette 0 color 4: Box
    move.w  #BLACK,PALETTES+20		; Palette 1 color 2
    move.w  #RED,PALETTES+24		; Palette 1 color 4: Line
    move.w  #BLACK,BACKDROPCOLOR

    jsr     BIOSF_FIX_CLEAR
    jsr     BIOSF_LSP_1ST

    ; Display box
    lea     box_data,a0
	move.w  #$716C,d1
	move.w  #$0300,d2
    jsr     automap
    
    ; Display menu
	bset.b  #0,BIOS_MESS_BUSY       ; Busy
	movea.l BIOS_MESS_POINT,a0  	; Get current pointer
	move.l  #MESS_MENU,(a0)+
	move.l  a0,BIOS_MESS_POINT  	; Update pointer
	bclr.b  #0,BIOS_MESS_BUSY   	; Ready to go

    clr.b   FLAGS

	move.w  #$00D0,REG_LSPCMODE 	; Timer frame reload, zero reload, and IRQ enable
	move.w  #$0000,REG_TIMERHIGH
	move.w  #$017F,REG_TIMERLOW	 	; 384-1 pixels
    move.w  #7,REG_IRQACK			; Clear IRQs

MainLoop:
    tst.b   FLAGS					; Wait for VBI
    beq     MainLoop
    clr.b   FLAGS

	; Update screen as quickly as possible
	move.w  #$20,VRAM_MOD

	; Flash
    move.w  #$0BBB,d0
	cmp.b   #56,COUNT
	beq     .flash
	cmp.b   #58,COUNT
	beq     .flash
	cmp.b   #60,COUNT
	bne     .no_flash
.flash:
    move.w  #$0F00,d0
.no_flash:
    move.w  d0,PALETTES+8

	; Draw bar
	move.w  #$718D,VRAM_ADDR
	nop
	nop
    moveq.l #15,d7
	jsr     vramcopy

	move.w  #$718E,VRAM_ADDR
	nop
	nop
    moveq.l #15,d7
	jsr     vramcopy



	; Trigger loop
.trig_loop:
	move.w  REG_LSPCMODE,d4
	lsr.w   #7,d4          		; Raster #
	; Get reference timing
	cmp.b   #58,COUNT
	bne     .no_ref
	; Display just hit the drawing of the line ?
	cmp.w   #$170,d4			; Approx.
	bne     .no_ref
    clr.w   LAG_LINES			; Right here, right now
.no_ref:

    move.b  REG_P1CNT,d0
    move.b  REG_P2CNT,d1
    move.b  PREV_INPUT,d2		; MacroAS bug workaround
    and.b   d1,d0				; Mix
    not.b   d0
    andi.b  #$F0,d0				; Keep A/B/C/D only
	move.b  d0,d1
	eor.b   d2,d0				; Difference
	move.b  d1,PREV_INPUT
	and.b   d1,d0				; Test for rising edge
	beq     .no_input
	move.w  LAG_LINES,d0		; Quick, latch !
	; LAG_LINES = number of lines
	; 1 line = 384px = 384/6000000s = 64us
	; LAG_LATCH = ms value = LAG_LINES * 64 / 1000
	moveq.l #0,d1
    move.w  d0,d1
	lsl.l   #6,d1				; *64
	divu.w  #1000,d1			; /1000
	clr.b   LAG_SIGN
	cmp.w   #7656,d1            ; 116 / 2 / 2 * 264 = 7656
	bls     .positive
	st.b    LAG_SIGN			; Negative
.positive:
	move.w  d1,LAG_LATCH
.no_input:

	cmp.w   #$1F0,d4
	bne     .trig_loop			; Exit loop at end of active display


	move.b  REG_STATUS_A,d0		; :)
	andi.b  #3,d0
	cmp.b   #3,d0
    beq     .no_ee
    move.w  #$1,VRAM_MOD
    move.w  #YELLOW,PALETTES+2
    move.w  #MAGENTA,PALETTES+4
    move.w  #MAGENTA,BACKDROPCOLOR
    move.w  #BLACK,PALETTES+8
    move.w  #$7284,VRAM_ADDR
    move.w  #MAGENTA,PALETTES+20
    move.w  #GREEN,PALETTES+24
    nop
    move.w  #$146,VRAM_RW
    nop
    nop
    nop
    move.w  #$246,VRAM_RW
.no_ee:


    ; Do housekeeping now
    ;jsr     BIOSF_SYSTEM_IO	Do not want
    jsr     BIOSF_MESS_OUT

	; Animate
	tst.b   DIRECTION
	beq     .dir_up
	subq.b  #2,COUNT
    tst.b   COUNT
    bne     .dir_end
    clr.b  	DIRECTION
    bra     .dir_end
.dir_up:
	addq.b  #2,COUNT
    cmp.b   #116,COUNT
    bne     .dir_end
    st.b    DIRECTION
.dir_end:

    ; 0~116, 116~0, ping-pong line animation
    ; 15-tiles bar
    ; 0: 80000000...
    ; 1: 70000000...
    ; 2: 60000000...
    ; 3: 50000000...
    ; 4: 40000000...
    ; 5: 3B000000...
    ; 6: 2A000000...
    ; 7: 19000000...
    ; 8: 08000000...
    ; First empty tiles = N / 8
    ; Left tile # = 8 - (N & 7)
    ; Right tile # = (N & 7) > 4 ? 16 - (N & 7) : 0
	; Tile # offset = $300

	; Render in RAM
	lea     VRAM_BUFFER,a0
	move.b  #1,d1
	move.b  COUNT,d0
	move.b  d0,d2
	lsr.b   #3,d0				; N / 8
	beq     .no_padding
	add.b   d0,d1
.pad:
	move.w  #$0300,(a0)+		; Empty tile
	subq.b  #1,d0
	bne     .pad

.no_padding:
	andi.b  #7,d2
	move.b  d2,d0				; N & 7
	neg.b   d0
	addi.b  #8,d0
	andi.w  #$000F,d0
	ori.w   #$0300,d0
	move.w  d0,(a0)+			; Left tile

	move.b  d2,d0
	cmp.b   #4,d0
	bls     .no_right
	addq.b  #1,d1
	neg.b   d0
	addi.b  #16,d0
	andi.w  #$001F,d0
	ori.w   #$0300,d0
	move.w  d0,(a0)+			; Right tile

.no_right:
.fill:
	cmp.b   #15,d1
	beq     .no_fill
	move.w  #$0300,(a0)+
	addq.b  #1,d1
	bne     .fill
.no_fill:


	bra     MainLoop


MESS_MENU:
	dc.w $0001
	dc.w $00FF

	dc.w $0003
	dc.w $7184

	dc.w $0108
	dc.b "NEOGEO  LAG TEST", $FF

	dc.w $0000

box_data:
    dc.w 17, 4
    dc.w 12,13,13,13,13,13,13,13,20,13,13,13,13,13,13,13,14
    dc.w 15,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16
    dc.w 15,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16
    dc.w 17,18,18,18,18,18,18,18,21,18,18,18,18,18,18,18,19
    
    INCLUDE "video.asm"
