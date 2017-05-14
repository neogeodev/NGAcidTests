	ORG RAMSTART

FLAG_VBI:		ds.b 1
FLAG_UPDATE:	ds.b 1
FRAMES:			ds.b 1

CUR_X			ds.b 1
CUR_Y			ds.b 1

PREV_INPUT:		ds.b 1
ACTIVE_INPUT:	ds.b 1

BASE_ADDR:		ds.l 1
