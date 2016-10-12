@echo off

d:\neogeo\asw\asw main -L

d:\neogeo\asw\p2bin main -r $000000-$01FFFF

d:\neogeo\sgcc\flip main.bin 052-p1.p1
d:\neogeo\sgcc\pad 052-p1.p1 524288 255
copy 052-p1.p1 d:\mame\roms\ssideki\052-p1.p1
