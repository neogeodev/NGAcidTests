@echo off

d:\neogeo\asw\asw main -L

d:\neogeo\asw\p2bin main -r $000000-$0FFFFF

d:\neogeo\sgcc\flip main.bin 058-p1.p1
copy 058-p1.p1 D:\mame\roms\fatfursp\058-p1.p1
