;NeoGeo memory editor system ROM v1
;furrtek CC BY-NC 2017

    cpu 68000

    supmode on

	INCLUDE "regdefs.asm"
    INCLUDE "ram.asm"
    INCLUDE "header.asm"

	PHASE $C00000

	INCLUDE "irq.asm"
	
    ORG $500
Err:
    rts

    ORG $600
ErrG:
	rte

	ORG $1000
Start:
    lea     $10F300,a7
    move.w  #$0000,REG_LSPCMODE

    move.b  d0,REG_SWPBIOS
    move.b  d0,REG_PALBANK0

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

    move.w  #BLACK,PALETTES+32		; Palette 1 color 0
    move.w  #RED,PALETTES+34		; Palette 1 color 1: Text
    move.w  #BLACK,PALETTES+36		; Palette 1 color 2

    move.w  #BLACK,BACKDROPCOLOR

	lea     VRAM_ADDR,a2			; Clear VRAM

	; Fix
	move.w  #$7000,0(a2)			; VRAM address
    move.l  #$1000-1,d7
    move.w  #$00FF,d0				; Tile $FF, palette 0
    nop
	move.w  #$1,4(a2)				; VRAM mod
.clear_fix:
    move.w  d0,2(a2)				; VRAM data
    nop
    nop
    dbra    d7,.clear_fix

	; Sprite heights
	move.w  #$8200,0(a2)			; VRAM address
    move.l  #$200-1,d7
    move.w  #$7800,d0				; Y=256, height=0
    nop
	move.w  #$1,4(a2)				; VRAM mod
.clear_spr:
    move.w  d0,2(a2)				; VRAM data
    nop
    nop
    dbra    d7,.clear_spr

    move.b  d0,REG_BRDFIX

	move.b  #6,CUR_X
	move.b  #0,CUR_Y
    move.l  #$300000,BASE_ADDR

	clr.b   FLAG_VBI

MainLoop:
    tst.b   FLAG_VBI				; Wait for VBI
    beq     MainLoop
    clr.b   FLAG_VBI
    
    ; Read inputs
    

    ; Update values
    movea.l BASE_ADDR,a0
	lea     $C02000,a1
    move.w  #$7064,d4				; VRAM start address

    move.l  #16-1,d6
.write_lines:

	move.w  #-$20,4(a2)				; VRAM mod

	; Is cursor on this line ?
	move.b  CUR_X,d2
	move.b  CUR_Y,d0
	neg.b   d0
	addi.b  #15,d0
	cmp.b   d6,d0
	beq     .no_hl_l
	st.b    d2						; Cursor isn't on line, trash X position to make it invisible
.no_hl_l:

	; Write address
	addi.w  #$C0,d4
	move.w  d4,0(a2)				; VRAM address
	movea.l a0,d0
    move.l  #6-1,d7
.write_addr:
	move.b  d0,d1
	andi.w  #$0F,d1
	move.b  (a1,d1),d1
	cmp.b  	d7,d2					; Cursor check
	bne     .no_hl_a
	ori.w   #$1000,d1				; Highlight
.no_hl_a:
    move.w  d1,2(a2)				; VRAM data
    lsr.l   #4,d0
	dbra    d7,.write_addr

	addi.w  #$40,d4

	move.w  #$20,4(a2)				; VRAM mod

	move.l  #6,d3
    move.l  #8-1,d7
.write_bytes:
	move.b  (a0)+,d0
	move.b  d0,d1

	move.w  d4,0(a2)				; VRAM address

	lsr.b   #4,d1
	andi.w  #$0F,d1
	move.b  (a1,d1),d1
	cmp.b  	d3,d2					; Cursor check
	bne     .no_hl_va
	ori.w   #$1000,d1				; Highlight
.no_hl_va:
    move.w  d1,2(a2)				; VRAM data
    
    addq.b  #1,d3

	andi.w  #$0F,d0
	move.b  (a1,d0),d0
	cmp.b  	d3,d2					; Cursor check
	bne     .no_hl_vb
	ori.w   #$1000,d0				; Highlight
.no_hl_vb:
    move.w  d0,2(a2)				; VRAM data

    addq.b  #1,d3

    addi.w  #$60,d4
    dbra    d7,.write_bytes

    subi.w  #$3FF,d4
    dbra    d6,.write_lines


	bra     MainLoop

    INCLUDE "video.asm"

	ORG $2000
	dc.b $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46
