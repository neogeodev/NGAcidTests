    cpu 68000

    supmode on

	INCLUDE "regdefs.asm"
    INCLUDE "header.asm"
    INCLUDE "ram.asm"

    org $200
TMRI:
    move.w  #2,REG_IRQACK
    rte

IRQ3:
    move.w  #1,REG_IRQACK
    rte
    
VBI:
    btst    #7,BIOS_SYSTEM_MODE
    bne     .getvbi
    jmp     BIOSF_SYSTEM_INT1
.getvbi:
    move.w  #4,REG_IRQACK
    move.w  #$2000,sr
    movem.l d0-d7/a0-a6,-(a7)
    move.b  d0,REG_DIPSW
    jsr     BIOSF_SYSTEM_IO
    jsr     BIOSF_MESS_OUT
    addq.b  #1,FRAMES
    st.b    FLAGS
    movem.l (a7)+,d0-d7/a0-a6
    rte


Start:
    lea     $10F300,a7
    move.w  #$4000,REG_LSPCMODE
    
    move.b  #2,BIOS_USER_REQUEST	; Game in progress

    move.l  #($F300/32)-1,d7
    lea     RAMSTART,a0
    moveq.l #0,d0
.clram:
    move.b  d0,REG_DIPSW
    move.l  d0,(a0)+		; 12
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    dbra    d7,.clram

    move.w  #7,REG_IRQACK
    move.w  #$2000,sr

    move.w  #$8000,PALETTES
    move.w  #$8000,BACKDROPCOLOR

    move.w  #$7FFF,PALETTES+2
    move.w  #$8000,PALETTES+4

    jsr     BIOSF_FIX_CLEAR
    jsr     BIOSF_LSP_1ST
    
    ; Display menu
	bset.b  #0,BIOS_MESS_BUSY
	movea.l BIOS_MESS_POINT,a0  ; Get current pointer in buffer
	move.l  #MESS_MENU,(a0)+
	move.l  a0,BIOS_MESS_POINT  ; Update pointer
	bclr.b  #0,BIOS_MESS_BUSY   ; Ready to go

    clr.b   FLAGS
    move.b  #1,PREV_CURSOR		; Force refresh

MainLoop:
    tst.b   FLAGS				; Wait for VBI
    beq     MainLoop
    clr.b   FLAGS

    move.b  BIOS_P1CHANGE,d0

	move.b  CURSOR,d1

    btst    #CNT_UP,d0
    beq     .noup
    tst.b   d1
    beq     .noup
    subq.b  #1,d1
.noup:

    btst    #CNT_DN,d0
    beq     .nodn
    cmp.b   #5-1,d1
    beq     .nodn
    addq.b  #1,d1
.nodn:

	cmp.b   PREV_CURSOR,d1
	beq     .norefresh
	move.b  d1,CURSOR
	clr.w   d0
	move.b  PREV_CURSOR,d0		; Clear old cursor
	addi.w  #$7188,d0
	move.w  d0,VRAM_ADDR
	nop
	nop
	move.w  #$00FF,VRAM_RW
	clr.w   d0
	move.b  CURSOR,d0			; Draw new cursor
	addi.w  #$7188,d0
	move.w  d0,VRAM_ADDR
	nop
	nop
	move.w  #$0011,VRAM_RW		; >
	move.b  CURSOR,PREV_CURSOR
.norefresh:
    
    bra     MainLoop
    


    btst    #CNT_RI,d0
    beq     .noright		; Right: R/W to REG_LSPCMODE or $3E0000 (range check)
    btst    #CNT_A,d0
    beq     .nora			; Right + A : REG_LSPCMODE
    move.b  #$55,$3C0006
    move.b  $3C0006,d0
    bra     MainLoop
.nora:
    move.b  #$55,$3E0000	; Only right: $3E0000
    move.b  $3E0000,d0
    bra     MainLoop
.noright:

    btst    #2,d0
    beq     .noleft		; Left
    btst    #4,d0
    beq     .nola		; Left + A: Read from REG_DIPSW = DIPRD0
    move.b  $300001,d0
    bra     MainLoop
.nola:
    move.b  #$55,$400000	; Only left: R/W to PALETTES
    move.b  #$AA,$400001
    move.b  $400000,d0
    move.b  $400001,d0
    bra     MainLoop

.noleft:

    btst    #4,d0
    beq     .noa		; A: R/W to PORT
    move.b  #$55,$200000
    move.b  #$AA,$200001
    move.b  $200000,d0
    move.b  $200001,d0
    bra     MainLoop
.noa:
    btst    #5,d0
    beq     .nob		; B: R/W to REG_SOUND (= internal to C1)
    move.b  #$55,$320000
    move.b  $320000,d0
    bra     MainLoop
.nob:
    btst    #6,d0
    beq     .noc		; C: R/W to REG_STATUS_A = nDIPRD1
    move.b  #$55,$320001
    move.b  $320001,d0
    bra     MainLoop
.noc:
    btst    #7,d0
    beq     .nod		; D: Write to REG_POUTPUT = nBITWD0
    move.b  #$55,$380001
    move.b  $380001,d0
    bra     MainLoop
.nod:
    btst    #1,d0
    beq     .nodown		; Down: Write to REG_NOSHADOW = nBITW1
    move.b  #$55,$3A0001
    move.b  $3A0001,d0
    bra     MainLoop
.nodown:

    bra     MainLoop

    INCLUDE "mess.asm"
