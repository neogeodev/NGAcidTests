    cpu 68000

    supmode on

    INCLUDE "regdefs.asm"

                     org RAMSTART

FLAGS:               	ds.b 1
FRAMES:                 ds.b 1

    INCLUDE "header.asm"

RLI:
    move.w  #2,REG_IRQACK
    rte

IRQ3:
    move.w  #1,REG_IRQACK
    rte
    
VBlank:
    btst    #7,BIOS_SYSTEM_MODE
    bne     .getvbl
    jmp     BIOSF_SYSTEM_INT1
.getvbl:
    move.w  #4,REG_IRQACK
    move.w  #$2000,sr
    movem.l d0-d7/a0-a6,-(a7)
    move.b  d0,REG_DIPSW
    jsr     BIOSF_SYSTEM_IO
    addq.b  #1,FRAMES
    st.b    FLAGS
    movem.l (a7)+,d0-d7/a0-a6
    rte


Start:
    move.w  #$4000,REG_LSPCMODE
    move.b  d0,REG_DIPSW
    move.w  #7,REG_IRQACK
    move.w  #$2000,sr

    jsr     BIOSF_FIX_CLEAR

    lea     $10F300,a7

    move.l  #($F300/32)-1,d7
    lea     RAMSTART,a0
clram:
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    dbra    d7,clram

Loop:
    ;tst.b   FLAGS
    ;beq     Loop
    ;clr.b   FLAGS

    move.b  BIOS_P1CURRENT,d0
    
    ; REG_LSPCMODE byte = Write:1 Read:0
    ; $3E0000 byte = Rien sur /LSPWE ni sur /LSPOE
    ; PALETTES byte = Write:1 Read:0
    ; REG_DIPSW byte = Read:0
    ; PORT byte:
    ; W1 W0 PDTACK AS2WE WE2DTACK AS2OE OE2DTACK
    ; 0  0  0      1     0        0     0
    ; 0  1  1      1     0        0     0
    ; 1  1  1      1     0        0     0
    ; 0  0  1      1     1        0     2
    ; 1  0  1      1     1        0     2
    ; 0  1  0      1     2        0     3
    ; 1  1  0      1     2        0     3
    ; 1  0  0      Nothing, always H


    btst    #3,d0
    beq     .noright		; Right: R/W to REG_LSPCMODE or $3E0000 (range check)
    btst    #4,d0
    beq     .nora		; Right + A : REG_LSPCMODE
    move.b  #$55,$3C0006
    move.b  $3C0006,d0
    bra     Loop
.nora:
    move.b  #$55,$3E0000	; Only right: $3E0000
    move.b  $3E0000,d0
    bra     Loop
.noright:

    btst    #2,d0
    beq     .noleft		; Left
    btst    #4,d0
    beq     .nola		; Left + A: Read from REG_DIPSW = DIPRD0
    move.b  $300001,d0
    bra     Loop
.nola:
    move.b  #$55,$400000	; Only left: R/W to PALETTES
    move.b  #$AA,$400001
    move.b  $400000,d0
    move.b  $400001,d0
    bra     Loop

.noleft:

    btst    #4,d0
    beq     .noa		; A: R/W to PORT
    move.b  #$55,$200000
    move.b  #$AA,$200001
    move.b  $200000,d0
    move.b  $200001,d0
    bra     Loop
.noa:
    btst    #5,d0
    beq     .nob		; B: R/W to REG_SOUND (= internal to C1)
    move.b  #$55,$320000
    move.b  $320000,d0
    bra     Loop
.nob:
    btst    #6,d0
    beq     .noc		; C: R/W to REG_STATUS_A = nDIPRD1
    move.b  #$55,$320001
    move.b  $320001,d0
    bra     Loop
.noc:
    btst    #7,d0
    beq     .nod		; D: Write to REG_POUTPUT = nBITWD0
    move.b  #$55,$380001
    move.b  $380001,d0
    bra     Loop
.nod:
    btst    #0,d0
    beq     .noup		; Up: Write to REG_RTCCTRL = nBITW0
    move.b  #$55,$380051
    move.b  $380051,d0
    bra     Loop
.noup:
    btst    #1,d0
    beq     .nodown		; Down: Write to REG_NOSHADOW = nBITW1
    move.b  #$55,$3A0001
    move.b  $3A0001,d0
    bra     Loop
.nodown:

    bra     Loop
