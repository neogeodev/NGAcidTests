@echo off

d:\neogeo\asw\asw main -L

d:\neogeo\asw\p2bin main -r $000000-$01FFFF

d:\neogeo\sgcc\flip main.bin sp-s2.sp1
copy sp-s2.sp1 D:\mame\roms\neogeo\sp-s2.sp1
