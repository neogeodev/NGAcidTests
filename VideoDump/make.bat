@echo off

d:\neogeo\asw\asw main -L

d:\neogeo\asw\p2bin main -r $000000-$00FFFF

mv main.bin MAIN.PRG
d:\neogeo\sgcc\ngcdiso\mkisofs -iso-level 1 -o videodump.iso -pad -N -V "VIDEODMP" MAIN.PRG M1.Z80 SPR.SPR V1.PCM FIX.FIX ABS.TXT BIB.TXT CPY.TXT IPL.TXT
