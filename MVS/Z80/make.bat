del object.o
"D:\Program Files\WLA-DX\wla-z80.exe" -o z80.asm object.o
echo [objects]>linkfile
echo object.o>>linkfile
"D:\Program Files\WLA-DX\wlalink.exe" -drv linkfile 052-m1.m1
del linkfile
del object.o
copy 052-m1.m1 d:\mame\roms\ssideki\052-m1.m1
