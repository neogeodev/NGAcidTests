Command_03:
	xor   a
	out   ($0C),a			; Clear reply
	out   ($00),a			; Clear command
	jp    0					; Reset
