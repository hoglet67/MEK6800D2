; Output port bit
OUTMASK EQU     $01             ; Bit 0 -- DO NOT CHANGE!

; Input port bit
INMASK  EQU     $02             ; Bit 1

; PIA Port A
PORT    EQU     $8004

; Working variables
TMP     EQU     $A07F           ; Can be anywhere

SERIALINIT:
        LDAA    PORT+1
        ANDA    #$FB
        STAA    PORT+1          ; Access DDR
        LDAB    PORT            ; Read DDR
        ANDB    #$FF-INMASK     ; 0 in DDR = input
        ORAB    #OUTMASK        ; 1 in DDR = output
        STAB    PORT            ; Write DDR
        ORAA    #$04
        STAA    PORT+1          ; Access Peripheral
        LDAB    PORT
        ORAB    #$01
        STAB    PORT
        RTS

; Various Delays (invoked with JSR)
; for one cycle less, invoke with BSR
D34:    NOP                     ;  2
D32:    NOP                     ;  2
D30:    NOP                     ;  2
D28:    NOP                     ;  2
D26:    NOP                     ;  2
D24:    NOP                     ;  2
D22:    NOP                     ;  2
D20:    NOP                     ;  2
D18:    NOP                     ;  2
D16:    NOP                     ;  2
D14:    RTS                     ;  5
