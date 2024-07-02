; ===========================================================================
        cpu 6800
; ===========================================================================
UPRAM   EQU     $A000           ; TOP OF USER MEMORY
;
        ORG     UPRAM           ; V1 has ORG at $A000H

IOV     RMB 2                   ; Vector -here and below same as V1
BEGA    RMB 2
ENDA    RMB 2
NIO     RMB 2                   ; Vector
SP      RMB 2
ACIAT   RMB 1
ECHO    RMB 1
XHI     RMB 1
XLOW    RMB 1
TEMP    RMB 1
TW      RMB 2
TFLAG   RMB 1
XTEMP   RMB 2
BKFLG   RMB 1
SWIPTR  RMB 45                  ; Vector
STACK   RMB 8
PRINTR  RMB 3
BFLAG   RMB 1
MFLAG   RMB 1
XFLAG   RMB 1
BITE2   RMB 1
BITE3   RMB 15
TSTACK  RMB 2                   ; Fixed with 2?
OPSAVE  RMB 1
PB1     RMB 1
PB2     RMB 1
PB3     RMB 1
BYTECT  RMB 1
PC1     RMB 1
PC2     RMB 1
BPOINT  RMB 3
BKFLG2  RMB 1
MCONT   RMB 1
; V2 S-record data area
TEMPX1  RMB 2                   ; S-Load Temporary X register
ADDRESS RMB 1                   ; Build 16 bit address byte 1
;
ADDRESS1        RMB 1           ; Build 16 bit address byte 2
BYTESTORE       RMB 1           ; Save Byte Count
TEMPA           RMB 1           ; Save A Register
;
USERV   RMB 2                   ; User Vector
