#!/bin/bash
SSD=serial.ssd
rm -f ${SSD}

rm -f serial.p SERIAL
asl -L -cpu 6800 serial.asm
p2bin -k serial.p
mv serial.bin SERIAL

rm -f smithbug.p SMITHBUG
asl -L -cpu 6800 smithbug.asm
p2bin -k smithbug.p
mv smithbug.bin SMTHBG

beeb blank_ssd ${SSD}
beeb title ${SSD} "6800 MONITOR"
beeb putfile ${SSD} SERIAL
beeb putfile ${SSD} SMTHBG
beeb info ${SSD}
