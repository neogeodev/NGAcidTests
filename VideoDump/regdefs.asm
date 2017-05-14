SCB1            equ $0000   ;VRAM, Sprite tilemaps
FIXMAP          equ $7000   ;VRAM, Fix map
SCB2            equ $8000   ;VRAM, Sprite shrink ratios
SCB3            equ $8200   ;VRAM, Sprite Y positions and sizes
SCB4            equ $8400   ;VRAM, Sprite X positions

BLACK           equ $8000
MIDBLUE         equ $1007
BLUE            equ $100F
MIDGREEN        equ $2070
GREEN           equ $20F0
MIDCYAN         equ $3077
CYAN            equ $30FF
MIDRED          equ $4700
RED             equ $4F00
MIDMAGENTA      equ $5707
MAGENTA         equ $5F0F
ORANGE          equ $6F70
MIDYELLOW       equ $6770
YELLOW          equ $6FF0
MIDGREY         equ $7777
WHITE           equ $7FFF

RAMSTART        equ $100000 ;User RAM start
PALETTES        equ $400000 ;Palette RAM start
BACKDROPCOLOR   equ PALETTES+(16*2*256)-2

REG_P1CNT       equ $300000 ;Joystick port 1
REG_DIPSW       equ $300001 ;Dipswitches/Watchdog
REG_SOUND       equ $320000 ;In/Out Z80
REG_STATUS_A    equ $320001
REG_P2CNT       equ $340000 ;Joystick port 2
REG_STATUS_B    equ $380000
REG_POUTPUT     equ $380001 ;Joypad port outputs 	 
REG_SLOT        equ $380021 ;Slot selection

REG_DISPENABL   equ $3A0001 ;Video output ON
REG_DISPDSABL   equ $3A0011 ;Video output OFF
REG_SWPBIOS     equ $3A0003 ;Use BIOS vector table
REG_SWPROM      equ $3A0013 ;Use ROM vector table
REG_CRDUNLOCK1  equ $3A0005 ;Allow /WE to pass through to memory card when low
REG_CRDLOCK1    equ $3A0015 ;Don't allow /WE to pass through to memory card
REG_CRDLOCK2    equ $3A0007 ;Don't allow /WE to pass through to memory card
REG_CRDUNLOCK2  equ $3A0017 ;Allow /WE to pass through to memory card when high
REG_CRDREGSEL 	equ $3A0009
REG_CRDNORMAL   equ $3A0019
REG_BRDFIX      equ $3A000B ;Use board fix tileset
REG_CRTFIX      equ $3A001B ;Use ROM fix tileset
REG_SRAMLOCK    equ $3A000D ;Write-protect SRAM
REG_SRAMUNLOCK  equ $3A001D ;Write-unprotect SRAM
REG_PALBANK1    equ $3A000F ;Use palette bank 1
REG_PALBANK0    equ $3A001F ;Use palette bank 0 (default)

VRAM_ADDR       equ $3C0000
VRAM_RW         equ $3C0002
VRAM_MOD        equ $3C0004
REG_LSPCMODE    equ $3C0006
REG_TIMERHIGH   equ $3C0008
REG_TIMERLOW    equ $3C000A
REG_IRQACK      equ $3C000C
REG_TIMERSTOP   equ $3C000E

; BIOS calls
BIOSF_SYSTEM_INT1   equ $C00438
BIOSF_SYSTEM_RETURN equ $C00444
BIOSF_SYSTEM_IO     equ $C0044A ;Sets RAM values from I/O ports
BIOSF_CREDIT_CHECK  equ $C00450
BIOSF_CREDIT_DOWN   equ $C00456
BIOSF_READ_CALENDAR equ $C0045C ;Set calendar addresses (10FDD2+), MVS only
BIOSF_CARD          equ $C00468 ;Perform memory card operations
BIOSF_CARD_ERROR    equ $C0046E ;In case a memory card error occurred, prompt user for action
BIOSF_VIDEOEN       equ $C00470 ;Enable/disable video layers, CD only
BIOSF_HOWTOPLAY     equ $C00474 ;Show how-to-play presentation, MVS only
BIOSF_FIX_CLEAR     equ $C004C2 ;Clear fix layer
BIOSF_LSP_1ST       equ $C004C8 ;Clear sprites
BIOSF_MESS_OUT      equ $C004CE
BIOSF_UPLOAD        equ $C00546 ;Upload data to DRAM, CD only 
BIOSF_CDDACMD       equ $C0056A ;Issue CDDA command, CD only

BIOS_SYSTEM_MODE  equ $10FD80 ;Game/system mode (bit 7)
BIOS_MVS_FLAG     equ $10FD82
BIOS_COUNTRY_CODE equ $10FD83
BIOS_GAME_DIP     equ $10FD84 ;start of soft DIPs settings (up to $10FD93)

; Set by BIOSF_SYSTEM_IO
BIOS_P1STATUS   equ $10FD94
BIOS_P1PREVIOUS equ $10FD95 ;previous joystick 1 state
BIOS_P1CURRENT  equ $10FD96 ;joystick 1 state
BIOS_P1CHANGE   equ $10FD97 ;joystick 1 state change
BIOS_P1REPEAT   equ $10FD98 ;joystick 1 repeat
BIOS_P1TIMER    equ $10FD99

BIOS_P2STATUS   equ $10FD9A
BIOS_P2PREVIOUS equ $10FD9B ;previous joystick 2 state
BIOS_P2CURRENT  equ $10FD9C ;joystick 2 state
BIOS_P2CHANGE   equ $10FD9D ;joystick 2 state change
BIOS_P2REPEAT   equ $10FD9E ;joystick 2 repeat
BIOS_P2TIMER    equ $10FD99

;button definitions
CNT_UP	        equ 0
CNT_DN	        equ 1
CNT_LE	        equ 2
CNT_RI	        equ 3
CNT_A	        equ 4
CNT_B	        equ 5
CNT_C	        equ 6
CNT_D	        equ 7

BIOS_STATCURNT    equ $10FDAC ;joystick 1/2 start/select
BIOS_STATCHANGE   equ $10FDAD ;previous joystick 1/2 start/select
BIOS_USER_REQUEST equ $10FDAE
BIOS_USER_MODE    equ $10FDAF
BIOS_START_FLAG   equ $10FDB4
BIOS_MESS_POINT   equ $10FDBE
BIOS_MESS_BUSY    equ $10FDC2

; Memory card related:
BIOS_CRDF       equ $10FDC4 ;byte: function to perform when calling BIOSF_CRDACCESS, see below table
BIOS_CRDRESULT  equ $10FDC6 ;byte: 00 on success, else 80+ and encodes the error, see below table
BIOS_CRDPTR     equ $10FDC8 ;longword: pointer to read from/write to
BIOS_CRDSIZE    equ $10FDCC ;word: how much data to read/write from/to card
BIOS_CRDNGH     equ $10FDCE ;word: usually game NGH. Unique identifier for the game that 'owns' the save file
BIOS_CRDFILE    equ $10FDD0 ;word: each NGH has up to 16 save 'files' associated with

; Calendar, only on MVS (in BCD)
BIOS_YEAR       equ $10FDD2 ;last 2 digits of year
BIOS_MONTH      equ $10FDD3
BIOS_DAY        equ $10FDD4
BIOS_WEEKDAY    equ $10FDD5 ;Sunday = 00, Monday = 01 ... Saturday = 06
BIOS_HOUR       equ $10FDD6 ;24 hour time
BIOS_MINUTE     equ $10FDD7
BIOS_SECOND     equ $10FDD8

BIOS_SELECT_TIMER equ $10FDDA ;Byte: game start countdown
BIOS_DEVMODE      equ $10FE80 ;Byte: non-zero for developer mode

; Upload to DRAM
BIOS_UPDEST     equ $10FEF4 ;longword: destination address (!)
BIOS_UPSRC      equ $10FEF8 ;longword: source address
BIOS_UPSIZE     equ $10FEFC ;longword: size
BIOS_UPZONE     equ $10FEDA ;byte: zone (0=PRG, 1=FIX, 2=SPR, 3=Z80, 4=PCM, 5=PAT)
BIOS_UPBANK     equ $10FEDB ;byte: bank

SOUND_STOP      equ $D00046 ;byte