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
