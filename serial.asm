        ORG     $C000

PORT    EQU     $8004
MASK    EQU     $0080

        JMP     INIT
        JMP     OUTCH9600
        JMP     INCH9600
        JMP     TEST9600
        JMP     OUTCH19200
        JMP     INCH19200
        JMP     TEST19200

INIT:
        LDAA    PORT+1          ; Access DDR
        ANDA    #$FB
        STAA    PORT+1
        LDAB    #$01            ; Write DDR
        STAB    PORT
        ORAA    #$04
        STAA    PORT+1          ; Access Peripheral
        RTS

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



; 6800 Bit Banged Serial I/O at 9,600 Baud
; ========================================

OUTCH9600:
        SECTION OUTCH9600

        PSHA
        PSHB
        LDAB    #10             ; total of 10 bits to send
        CLC                     ; start bit
OLOOP:
        PSHB                    ;  4
        LDAB    PORT            ;  4
        ANDB    #$FE            ;  2
        ADCB    #$00            ;  2 - C = bit to send
        STAB    PORT            ;  5
        STAB    PORT            ;  5 - waste 5 cycles (STS addr8 also 5 cycles)
        PULB                    ;  4
        SEC                     ;  2 - stop bit
        RORA                    ;  2 - shift next bit into C
        DECB                    ;  2
        JSR     D28             ; 28 - waste 28 cycles JSR=9 RTS=5
        BNE     OLOOP           ;  4
                                ; 64 cycles = 9600 baud
        PULB
        PULA
        RTS

        ENDSECTION

INCH9600:
        SECTION INCH9600
        LDAA    #$02
START0: BITA    PORT            ;  wait for line idle
        BEQ     START0          ;
START1: BITA    PORT            ;  wait for start bit
        BNE     START1          ;  4
        JSR     D14             ; 14
        LDAA    #$80            ;  2
ILOOP:  PSHA                    ;  4
        LDAA    PORT            ;  4 - first sample 28->34 cycles after edge
        ANDA    #$02            ;  2
        ADCA    #$FE            ;  2
        PULA                    ;  4
        RORA                    ;  2
        JSR     D28             ; 28
        JSR     D14             ; 14
        BCC     ILOOP           ;  4
                                ; 64 cycles = 9600 baud
        RTS
        ENDSECTION

D28:    JSR D14                 ;  9
D14:    RTS                     ;  5

;6800 Bit Banged Serial I/O at 19,200 Baud
;=========================================

OUTCH19200:
        SECTION OUTCH19200
        PSHA
        PSHB
        LDAB    #$FE
        STAB    MASK
        LDAB    #10             ; total of 10 bits to send
        CLC                     ; start bit
LOOP:
        PSHB                    ;  4
        LDAB    PORT            ;  4
        ANDB    MASK            ;  3
        ADCB    #$00            ;  2 - C = bit to send
        STAB    PORT            ;  5
        PULB                    ;  4
        SEC                     ;  2 - stop bit
        RORA                    ;  2 - shift next bit into C
        DECB                    ;  2
        BNE     LOOP            ;  4
                                ; 32 cycles = 19200 baud
        PULB
        PULA
        RTS
        ENDSECTION



INCH19200:
        SECTION INCH19200
        LDAA    #$80
        PSHA
        LDAA    #$02
START0: BITA    PORT            ;  wait for line idle
        BEQ     START0          ;
START1: BITA    PORT            ;  wait for start bit
        BNE     START1          ;  4
LOOP:   NOP                     ;  2
        NOP                     ;  2
        LDAA    PORT            ;  4 - first sample 12->20 cycles after edge
        ANDA    #$02            ;  2
        ADCA    #$FE            ;  2
        PULA                    ;  4
        RORA                    ;  2
        PSHA                    ;  4
        NOP                     ;  2
        NOP                     ;  2
        NOP                     ;  2
        BCC     LOOP            ;  4 - loop is 32 cycles
        PULA
        RTS
        ENDSECTION
