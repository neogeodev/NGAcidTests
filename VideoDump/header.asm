    ORG  $0
    dc.l $0010F300,$00C00402,$00C00408,$00C0040E
    dc.l $00C00414,$00C00426,$00C00426,$00C00426
    dc.l $00C0041A,$00C00420,$00C00426,$00C00426
    dc.l $00C00426,$00C00426,$00C00426,$00C0042C
    dc.l $00C00522,$00C00528,$00C0052E,$00C00534
    dc.l $00C0053A,$00C004F2,$00C004EC,$00C004E6
    dc.l $00C004E0,     TMRI,      VBI,     IRQ3
    dc.l   Generic,  Generic,  Generic,  Generic
    dc.l   Generic,  Generic,  Generic,  Generic
    dc.l   Generic,  Generic,  Generic,  Generic
    dc.l   Generic,  Generic,  Generic,  Generic
    dc.l   Generic,  Generic,  Generic,  Generic
    dc.l $00C00426,$00C00426,$00C00426,$00C00426
    dc.l $00C00426,$00C00426,$00C00426,$00C00426
    dc.l $00C00426,$00C00426,$00C00426,$00C00426
    dc.l $00C00426,$00C00426,$00C00426,$00C00426

    ORG $0100
    dc.b "NEO-GEO", $02
    dc.w $0029			; NGH (Legend of Success Joe, because nobody wants that)
    dc.l $00100000      ; P1 size (64KiB)
    dc.l $0010F000		; Pointer to debug DIPs (none)
	dc.w $007A			; Save size ?
	dc.w $00A1       	; Not used ?
	
	dc.l	JapaneseConfig
	dc.l	EnglishConfig
	dc.l	SpanishConfig

    ORG $0122
	jmp User
    ORG $0128
	jmp Generic			; Player_start
    ORG $012E
	jmp Generic			; Demo_end
    ORG $0134
	jmp Generic			; Coin_sound
	
    ORG $013A
    dc.w $0000			; CDDA commands not issued by Z80

    ORG $0182
	dc.l SCode			; Pointer to security code

SCode:
	dc.l $76004A6D, $0A146600, $003C206D, $0A043E2D
	dc.l $0A0813C0, $00300001, $32100C01, $00FF671A
	dc.l $30280002, $B02D0ACE, $66103028, $0004B02D
	dc.l $0ACF6606, $B22D0AD0, $67085088, $51CFFFD4
	dc.l $36074E75, $206D0A04, $3E2D0A08, $3210E049
	dc.l $0C0100FF, $671A3010, $B02D0ACE, $66123028
	dc.l $0002E048, $B02D0ACF, $6606B22D, $0AD06708
	dc.l $588851CF, $FFD83607
	dc.w $4E75

Generic:
	rte
	rts

jt_user:
	dc.l   Init			; Start-up init
	dc.l   _rt			; Eye-catcher
	dc.l   Start        ; Game/demo
	dc.l   _rt			; Title display

;User:
    ;move.b  d0,REG_DIPSW
    ;move.b  BIOS_USER_REQUEST,d0
    ;andi.b  #3,d0
    ;lsl.w   #2,d0
    ;lea     jt_user,a0
    ;movea.l (a0,d0),a0
    ;jsr     (a0)
    ;jmp     BIOSF_SYSTEM_RETURN

_rt:
	rts

Init:
	move.w  #1337,$10F000		; Backup RAM init
	rts
	
JapaneseConfig:
	dc.b	"NGCDJ BOOTLOADER"
	dc.l	$FFFFFFFF
	dc.w	$0364
	dc.b	$14, $13, $24, $01

EnglishConfig:
	dc.b	"NGCDE BOOTLOADER"
	dc.l	$FFFFFFFF
	dc.w	$0364
	dc.b	$14, $13, $24, $01

SpanishConfig:
	dc.b	"NGCDS BOOTLOADER"
	dc.l	$FFFFFFFF
	dc.w	$0364
	dc.b	$14, $13, $24, $01

