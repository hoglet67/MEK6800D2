        ORG     $C000

; Output port bit
OUTMASK EQU     $01             ; Bit 0 -- DO NOT CHANGE!

; Input port bit
INMASK  EQU     $02             ; Bit 1

; PIA Port A
PORT    EQU     $8004

; Working variables
TMP     EQU     $0080           ; Must be direct page
MASK    EQU     $0080           ; Can be anywhere


        BSR     INIT
        SWI
        JMP     OUTCH9600       ; C003
        JMP     INCH9600        ; C006
        JMP     TEST9600        ; C009
        JMP     OUTCH19200      ; C00C
        JMP     INCH19200       ; C00F
        JMP     TEST19200       ; C012
        JMP     OUTCH38400      ; C015
        JMP     INCH38400       ; C018
        JMP     TEST38400       ; C01B

INIT:
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

TEST9600:
        SECTION TEST9600
        LDAA    #$20
LOOP1:
        JSR     OUTCH9600
        INCA
        CMPA    #$7F
        BNE     LOOP1
LOOP2:
        JSR     INCH9600
        JSR     OUTCH9600
        JMP     LOOP2
        ENDSECTION


TEST19200:
        SECTION TEST19200
        LDAA    #$20
LOOP1:
        JSR     OUTCH19200
        INCA
        CMPA    #$7F
        BNE     LOOP1
LOOP2:
        JSR     INCH19200
        JSR     OUTCH19200
        JMP     LOOP2
        ENDSECTION

TEST38400:
        SECTION TEST38400
        LDAA    #$20
LOOP1:
        JSR     OUTCH38400
        INCA
        CMPA    #$7F
        BNE     LOOP1
LOOP2:
        JSR     INCH38400
        JSR     OUTCH38400
        JMP     LOOP2
        ENDSECTION


; 6800 Bit Banged Serial I/O at 9,600 Baud
; ========================================

OUTCH9600:
        SECTION OUTCH9600

        PSHA
        PSHB
        LDAB    #10             ; total of 10 bits to send
        CLC                     ; start bit
LOOP:
        PSHB                    ;  4
        LDAB    PORT            ;  4
        ANDB    #$FF-OUTMASK    ;  2
        ADCB    #$00            ;  2 - C = bit to send
        STAB    PORT            ;  5
        PULB                    ;  4
        SEC                     ;  2 - stop bit
        RORA                    ;  2 - shift next bit into C
        DECB                    ;  2
        BSR     D34             ; 33
        BNE     LOOP            ;  4
                                ; 64 cycles in loop = 9,600 baud
        PULB
        PULA
        RTS

        ENDSECTION

INCH9600:
        SECTION INCH9600
        PSHB
        LDAA    #$80            ; b7 shifted down acts as a counter
        LDAB    #INMASK
START0: BITB    PORT            ; wait for line idle
        BEQ     START0          ;
START1: BITB    PORT            ; wait for start bit
        BNE     START1          ;  4
        JSR     D20             ; 20
        BITB    PORT            ;  4 - confirm start bit 28->36 cycle after edge
        BNE     START1          ;  4
        JSR     D30             ; 30
LOOP:   JSR     D26             ; 26
        LDAB    PORT            ;  4 - sample data bit 64 cycles later
        ANDB    #INMASK         ;  2
        ADDB    #$100-INMASK    ;  2
        RORA                    ;  2
        JSR     D24             ; 24
        BCC     LOOP            ;  4
                                ; 64 cycles in loop = 9,600 baud
        PULB
        RTS
        ENDSECTION


; 6800 Bit Banged Serial I/O at 19,200 Baud
; =========================================

OUTCH19200:
        SECTION OUTCH19200
        PSHA
        PSHB
        STAA    TMP
        LDAA    #10             ; total of 10 bits to send
        CLC                     ; start bit
LOOP:
        LDAB    PORT            ;  4
        ANDB    #$FF-OUTMASK    ;  2
        ADCB    #$00            ;  2 - C = bit to send
        STAB    PORT            ;  5
        STAB    PORT            ;  5 - waste 5 cycles
        SEC                     ;  2 - stop bit
        ROR     TMP             ;  6 - shift next bit into C
        DECA                    ;  2
        BNE     LOOP            ;  4
                                ; 32 cycles in loop = 19,200 baud
        PULB
        PULA
        RTS
        ENDSECTION



INCH19200:
        SECTION INCH19200
        PSHB
        LDAA    #$80            ; b7 shifted down acts as a counter
        LDAB    #INMASK
START0: BITB    PORT            ; wait for line idle
        BEQ     START0          ;
START1: BITB    PORT            ; wait for start bit
        BNE     START1          ;  4
        NOP                     ;  2
        NOP                     ;  2
        BITB    PORT            ;  4 - confirm start bit 12->20 cycle after edge
        BNE     START1          ;  4
        JSR     D24             ; 24
LOOP:   LDAB    PORT            ;  4 - sample data bit 32 cycles later
        ANDB    #INMASK         ;  2
        ADDB    #$100-INMASK    ;  2
        RORA                    ;  2
        JSR     D18             ; 18
        BCC     LOOP            ;  4
                                ; 32 loop in cycles = 19,200 baud
        PULB
        RTS
        ENDSECTION

; 6800 Bit Banged Serial I/O at 38,400 Baud
; =========================================


OUTCH38400:
        SECTION OUTCH38400
        PSHA
        PSHB
        LDAB    #10             ; total of 10 bits to send
        CLC                     ; start bit
LOOP:
        ROL     PORT            ;  6
        SEC                     ;  2 - stop bit
        RORA                    ;  2 - shift next bit into C
        DECB                    ;  2
        BNE     LOOP            ;  4
                                ; 16 cycles in loop = 38,400 baud
        PULB
        PULA
        RTS
        ENDSECTION

; Note: the start bit samplimng error of 8 bits is now half a cycle!

INCH38400:
        SECTION INCH38400
        PSHB
        LDAA    #$80            ; b7 shifted down acts as a counter
        LDAB    #INMASK
START0: BITB    PORT            ; wait for line idle
        BEQ     START0          ;
START1: BITB    PORT            ; wait for start bit
        BNE     START1          ;  4
        PSHA                    ;  4 }
        PULA                    ;  4 } 12 cycles of delay
        NOP                     ;  2 }
        NOP                     ;  2 }
LOOP:   LDAB    PORT            ;  4 - sample data bit 20->28 cycles later
        ANDB    #INMASK         ;  2
        ADDB    #$100-INMASK    ;  2
        RORA                    ;  2
        NOP                     ;  2
        BCC     LOOP            ;  4
                                ; 16 loop in cycles = 38,400 baud
        PULB
        RTS
        ENDSECTION
