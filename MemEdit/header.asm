    ORG $0
    dc.l $10F300		; Initial SP
    dc.l $C01000		; Initial PC
    dc.l $C00500, $C00500, $C00500, $C00500		; Bus error, Address error, Illegal Instruction, Divide by 0
    dc.l $C00500, $C00500, $C00500, $C00500		; CHK, TRAPV ,Privilege Violation, Trace
    dc.l $C00500, $C00500, $C00500, $C00500		; Emu, Emu, Reserved, Reserved
    dc.l $C00500, $C00500, $C00500, $C00500		; Reserved, Reserved, Reserved, Reserved
    dc.l $C00500, $C00500, $C00500, $C00500		; Reserved, Reserved, Reserved, Reserved
    dc.l $C00500, $C00500, $C00500, $C00400		; Reserved, Reserved, Spurious Interrupt, Vertical blank
    dc.l $C00300, $C00200, $C00600, $C00600		; Timer interrupt, Cold boot interrupt
    dc.l $C00600, $C00600, $C00600, $C00600		; Auto, Auto, Trap 0, Trap1...
    dc.l $C00600, $C00600, $C00600, $C00600
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF
