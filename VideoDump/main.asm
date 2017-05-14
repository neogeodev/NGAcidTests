;NeoGeo CD system ROM video dumper V1
;furrtek CC BY-NC 2017

    cpu 68000

    supmode on

	INCLUDE "regdefs.asm"
    INCLUDE "ram.asm"
    INCLUDE "header.asm"
	INCLUDE "irq.asm"

	ORG $400
User:
Start:
    lea     $10F300,a7
    lea     $10F300,sp
    move.b  d0,REG_DIPSW			; Watchdoge
    move.w  #$0000,REG_LSPCMODE
    
    move.w  #7,REG_IRQACK
    move.w  #$2000,sr           	; Enable interrupts

    ;move.b  d0,REG_SWPBIOS
    ;move.b  d0,REG_PALBANK0

    move.l  #($F300/32)-1,d7		; Clear work RAM
    lea     RAMSTART,a0
    moveq.l #0,d0
.clear_ram:
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    dbra    d7,.clear_ram

    move.l  #16-1,d7				; Load palette
    lea     palette,a0
    lea     PALETTES,a1
.load_pal:
    move.w  (a0)+,(a1)+
    dbra    d7,.load_pal

    move.w  #BLACK,BACKDROPCOLOR

	lea     VRAM_ADDR,a2			; Clear VRAM

	jsr     clear_fix

	; Sprite heights
	move.w  #$8200,0(a2)			; VRAM address
    move.l  #$200-1,d7
    move.w  #$7800,d0				; Y=256, height=0
	move.w  #$1,4(a2)				; VRAM mod
    nop
    nop
.clear_spr:
    move.w  d0,2(a2)				; VRAM data
    nop
    nop
    dbra    d7,.clear_spr

	clr.w   CHECKSUM
	clr.b   FLAG_VBI

.wait_start:
    tst.b   FLAG_VBI				; Wait for VBI
    beq     .wait_start
    clr.b   FLAG_VBI

	move.b  REG_STATUS_B,d0			; Wait for start press on any joypad
	andi.b  #5,d0
	cmp.b   #5,d0
	beq     .wait_start
	
	lea     $C00000,a3				; Start
	lea     $C80000,a4              ; Stop

	move.w  #$20,4(a2)				; VRAM mod

main_loop:
    tst.b   FLAG_VBI				; Wait for VBI
    beq     main_loop
    clr.b   FLAG_VBI
    
    move.b  FRAME,d0
    andi.b  #3,d0
    bne     main_loop
    move.b  FRAME,d0
    andi.b  #4,d0
	bne     set_clock

	; Reset clock
	move.w  #$0000,d0
	move.w  #$7045,0(a2)			; VRAM address
	move.l  #35-1,d7
.rst_clock_lp:
	move.w  d0,2(a2)
	nop
	nop
    dbra    d7,.rst_clock_lp

	; Copy BUFFER to VRAM
	lea     BUFFER,a0
	move.w  #$7046,d1
	move.l  #21-1,d6
.copy_full:
	move.w  d1,0(a2)				; VRAM address
	move.l  #35-1,d7				; 12 clk
.copy_line:
	move.w  (a0)+,2(a2)
	nop                 			; 4 clk
    dbra    d7,.copy_line			; 10 clk
	addq.w  #1,d1
	dbra    d6,.copy_full

	; Prepare next buffer
	lea     BUFFER,a0
	move.w  #0,d1
	move.l  #20-1,d5
.fill_full:

	move.l  #4-1,d6
.fill_line:
	move.l  (a3)+,d0				; 32 bits
	move.l  d0,d2
	swap    d2
	add.w   d0,CHECKSUM
	add.w   d2,CHECKSUM

	move.l  #8-1,d7
.fill_bits:
	move.b  d0,d1
	andi.b  #$F,d1
	move.w  d1,(a0)+
    lsr.l   #4,d0
    dbra    d7,.fill_bits
	move.w  #$0018,(a0)+

	dbra    d6,.fill_line

	lea     -2(a0),a0
	dbra    d5,.fill_full

	move.w  CHECKSUM,d0
	move.l  #4-1,d7
.fill_csum:
	move.b  d0,d1
	andi.b  #$F,d1
	move.w  d1,(a0)+
    lsr.l   #4,d0
    dbra    d7,.fill_csum
	
	cmpa.l  a3,a4
	bhi     main_loop
	
	jsr     clear_fix
    move.w  #GREEN,BACKDROPCOLOR	; Done

lock:
	bra     lock
	

set_clock:
	move.w  #$0007,d0
	move.w  #$7045,0(a2)			; VRAM address
	move.l  #35-1,d7
.set_clock_lp:
	move.w  d0,2(a2)
	nop
	nop
    dbra    d7,.set_clock_lp
    bra     main_loop

clear_fix:
	move.w  #$7000,0(a2)			; VRAM address
    move.l  #$1000-1,d7
    move.w  #$0018,d0				; Tile $18, palette 0
	move.w  #$1,4(a2)				; VRAM mod
    nop
    nop
.clear_fix:
    move.w  d0,2(a2)				; VRAM data
    nop
    nop
    dbra    d7,.clear_fix
    rts
	
palette:
    dc.w $0000, $0F00, $0090, $043F
    dc.w $0000, $0000, $0000, $0000
    dc.w $0000, $0000, $0000, $0000
    dc.w $0000, $0000, $0000, $0FFF
