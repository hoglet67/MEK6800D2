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
