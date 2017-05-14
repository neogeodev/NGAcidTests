    ORG $280
IRQ3:
    move.w  #1,REG_IRQACK
    rte

    ORG $300
TMRI:
    move.w  #2,REG_IRQACK
    rte

    ORG $380
VBI:
    btst    #7,BIOS_SYSTEM_MODE
    bne     .getvbl
    jmp     BIOSF_SYSTEM_INT1
.getvbl:
	move.l  d0,-(a7)

    move.w  #4,REG_IRQACK

    move.b  d0,REG_DIPSW			; Watchdoge
    st.b    FLAG_VBI
    addq.b  #1,FRAME

	move.l  (a7)+,d0
    rte
