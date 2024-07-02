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
