Command_01:
	di						; Freeze in RAM
	xor   a
	out   ($0C),a			; Clear reply
	out   ($00),a			; Clear command
	
	ld    hl,$FFFD
	ld    (hl),$C3			; JP opcode
	ld    ($FFFE),hl		; JP $FFFD
	ld    a,1
	out   ($0C),a			; Reply
	jp    $FFFD
