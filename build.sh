#!/bin/bash
SSD=serial.ssd
rm -f ${SSD}

rm -f serial.p SERIAL
asl -L -cpu 6800 serial.asm
p2bin -k serial.p
mv serial.bin SERIAL

beeb blank_ssd ${SSD}
beeb title ${SSD} "6800 SERIAL"
beeb putfile ${SSD} SERIAL
beeb info ${SSD}
