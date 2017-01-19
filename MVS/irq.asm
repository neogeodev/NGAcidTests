IRQ3:
    move.w  #1,REG_IRQACK
    rte

TMRI:
	addq.w  #1,LAG_LINES
    move.w  #2,REG_IRQACK
    rte

VBI:
    btst    #7,BIOS_SYSTEM_MODE
    bne     .uservbi
    jmp     BIOSF_SYSTEM_INT1
.uservbi:
	move.l  d0,-(a7)
    move.w  #4,REG_IRQACK
    move.w  #$2000,sr

    move.b  d0,REG_DIPSW			; Watchdoge
    addq.b  #1,FRAMES
    st.b    FLAG_VBI
	move.l  (a7)+,d0
    rte
