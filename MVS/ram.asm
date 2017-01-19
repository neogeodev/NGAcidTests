	ORG RAMSTART

FLAG_VBI:		ds.b 1
FLAG_UPDATE:	ds.b 1
FRAMES:			ds.b 1
LAG_LINES:		ds.w 1
LAG_LATCH:		ds.w 1
LAG_SIGN:		ds.b 1

COUNT:			ds.b 1
DIRECTION:		ds.b 1

VRAM_BUFFER:	ds.w 16
PREV_INPUT:		ds.b 1
