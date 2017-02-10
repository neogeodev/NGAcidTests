;Basic sound driver
;furrtek CC BY-NC 2017

.memorymap
DEFAULTSLOT 0
SLOTSIZE $1000
SLOT 0 $0000
SLOTSIZE $1000
SLOT 1 $1000
.ENDME
.ROMBANKMAP
BANKSTOTAL 1
BANKSIZE $1000
BANKS 1
.ENDRO

; Command format:
; ////////

.DEFINE STACK			$FFFC
.DEFINE	FIFO_BUFFER		$F800	; 64 bytes, must be 256-bytes aligned
.DEFINE RAM_ADDR		$F840

.MACRO write_port_A
	rst $08
.ENDM
.MACRO write_port_B
	rst $28
.ENDM

.INCLUDE "ram.asm"

.BANK 0 SLOT 0
.ORG $0000
	di
	jp    Start

.INCLUDE "ym2610.asm"

; IRQ: YM2610 timer
.ORG $0038
	push  af
	push  bc
	push  de
	ld    a,(beeping)
	or    a
	jr    z,+
	; Stop beep
	ld    de,$2728			; Reset timer B flag
	write_port_A
	ld    de,$0800			; SSG channel A volume
	write_port_A
	ld    de,$073F			; SSG all channels disabled
	write_port_A
	xor   a
	ld    (beeping),a
+:
    pop   de
    pop   bc
	pop   af
	ei
	ret

; NMI: Command receive
.ORG $0066
	push  af
	xor   a
	out   ($0C),a			; Clear reply
	push  bc
	push  de
	push  hl

	in    a,($00)			; Read command
	cp    1
	jp    z,Command_01
	cp    3
	jp    z,Command_03

	ld    b,a
	ld    hl,FIFO_BUFFER
	ld    a,(PutPointer)
	ld    l,a
	ld    (hl),b
	inc   a
	and   $3F				; FIFO is 64 bytes
	ld    (PutPointer),a

NMI_End:
	pop   hl
	pop   de
	pop   bc
	ld    a,$9B
	out   ($0C),a			; Reply ack
	pop   af
	retn

.INCLUDE "cmd01.asm"
.INCLUDE "cmd03.asm"



ProcessCommands:
    ld    a,(ToProcess)
    cp    10
    jp    z,Do_Beep
    ret

; SSG beep
Do_Beep:
	ld    de,$2620			; Timer B reload value
	write_port_A
	ld    de,$2700			; Clear timer B
	write_port_A
	ld    de,$270A			; Reload timer B and enable IRQ
	write_port_A

	ld    de,$073E			; SSG channel A enable
	write_port_A
	ld    de,$0080			; SSG channel A fine tune
	write_port_A
	ld    de,$0100			; SSG channel A coarse tune
	write_port_A
	ld    de,$080F			; SSG channel A volume
	write_port_A
	
	ld    a,1
	ld    (beeping),a
    ret


Start:
	di
	im    1
	ld    sp,STACK

	xor   a
	out   ($0C),a			; Clear reply

	ld    b,100				; Wait a bit
-:
	nop
	djnz  -

	xor   a
	out   ($0C),a			; Clear reply

	xor   a					; Clear RAM
    ld    ($F800),a
    ld    hl,$F800
    ld    de,$F801
    ld    bc,$800-1
    ldir

	xor   a
	ld    (GetPointer),a
	ld    (PutPointer),a
	ld    (beeping),a

	ld    a,$1E				; Bank setup
	in    a,($08)			; $F000
	ld    a,$0E
	in    a,($09)			; $E000
	ld    a,$06
	in    a,($0A)			; $C000
	ld    a,$02
	in    a,($0B)			; $8000

	out   ($08),a			; Enable NMIs
	
	call  Reset_YM2610

	ei

MainLoop:
	ld    a,(GetPointer)
	ld    b,a
	ld    a,(PutPointer)
	cp    b
	jr    z,MainLoop		; FIFO empty ?

	ld    hl,FIFO_BUFFER	; New command
	ld    l,b
	ld    a,(hl)			; Retrieve
	ld    (ToProcess),a

	ld    a,b
	inc   a
	and   $3F				; FIFO is 64 bytes
	ld    (GetPointer),a

	call  ProcessCommands

	jr    MainLoop
