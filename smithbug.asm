        include "smithbug.inc"
;       title "MIKES-M6802 OPERATING SYSTEM"
;       REV 2.0
;
; This is the latest SMITHBUG+S1 source
; with the Disassembler "PSH A = MISSING A" bug removed
; [see TBLKUP routine, # sign did not replace  � ].
; I emailed Ed Smith but as yet no reply. - Mike Lee, April 24 2019
;
; July 30 2019 HRJ
; - corrected TBLKUP routine as above, adds 4 bytes to code
; -  CMPX       VAR non- instruction commented out near GETCNT in S-record routine
; -  SLOAD routine starts NINE bytes from previous code, TBLKUP only accounts for four
; -- difference of 5 occurs apparently in counting bytes in S1STRING
;
;       M       MOVE MEMORY
;       E       CHANGE MEMORY
;       G       GO TO PROGRAM
;       R       PRINT
;       T       TRACE PROGRAM
;       @       ASCII CONVERSION
;       H       PRINTER ON
;       V       VIEW MEMORY
;       I       FILL MEMORY
;       J       JUMP TO TARGET PROGRAM
;       F       FIND
;       Q       HARDWARE LOCATION
;       D       DISASSEMBLE CODE
;       K       CONTINUE AFTER BREAK
;       1       BREAKPOINT ONE
;       2       BREAKPOINT TWO
;       &       S1 LOAD PROGRAMME
;       *       Jump to Start
;       O       ECHO ON
;       N       ECHO OFF
;       U       Jump to user code at vector USERV
;

;
;
        ORG     $C000
;
;       ENTER POWER ON SEQUENCE
;

;; DMB 	LDAD    #START

START   EQU     *
        LDS     #STACK
        STS     SP
        CLR     ECHO
        LDX     #SFE
        STX     SWIPTR
        STX     NIO
;
;       ACIA INITIALISE
                                ;
        JSR     SERIALINIT
;
;       COMMAND CONTROL
;
CONTRL

        ;; LDAA    ACIAT
        ;; STAA    ACIACS

   ;;
        ;; What is this? Done twice?
        ;;
        LDS     #STACK  ; SET CONTRL STACK POINTER
        ;LDS    #TSTACK ; Weird, either dobule or should be TSTACK not #TSTACK
        CLR     TFLAG
        CLR     BKFLG
        CLR     BKFLG2
        LDX     #PROMPT
        BSR     PDATA1
        BSR     INCH
        TAB
        JSR     OUTS
;
; CHECK IF COMMAND IS VALID AND JUMP TO APPLICATION
;
        LDX     #FUTABL
NXTCHR  CMPB    0,X
        BEQ     GOODCH
        INX
        INX
        INX
        CPX     #TBLEND
        BNE     NXTCHR
        JMP     CKCBA ;
;
GOODCH  LDX     1,X
        JMP     0,X   ;JUMP TO COMMAND
;
;  IRQ INTERUPT SEQUENCE
;
USER    LDX USERV
        JMP 0,X
;
;  IRQ INTERUPT SEQUENCE
;
IO      LDX IOV
        JMP 0,X
;
;  NMI SEQUENCE
;
POWDWN  LDX NIO
        JMP 0,X
;
;  SWI SEQUENCE
;
SWI     LDX     SWIPTR
        JMP     0,X
;
LOAD19  LDAA    #$3F
        BSR     OUTCH
C1      BRA     CONTRL
;
;  BUILD ADDRESS
;
BADDR   BSR     BYTE
        STAA    XHI
        BSR     BYTE
        STAA    XLOW
        LDX     XHI
        RTS
;
;  INPUT ONE BYTE
;
BYTE    BSR     INHEX
        ASLA
        ASLA
        ASLA
        ASLA
        TAB
        BSR     INHEX
        ABA
        RTS
;
;  OUTPUT LEFT HEX NUMBER
;
OUTHL   LSRA
        LSRA
        LSRA
        LSRA
;
;  OUTPUT RIGHT HEX NUMBER
;
OUTHR   ANDA    #$F
        ADDA    #$30
        CMPA    #$39
        BLS     OUTCH
        ADDA    #$7
OUTCH   JMP     OUTEEE
INCH    JMP     INEEE
;
PDATA2  BSR     OUTCH
        INX
PDATA1  LDAA    0,X
        CMPA    #$4
        BNE     PDATA2
        RTS
;
; CHANGE MEMORY
;
CHANGE  BSR     BADDR
CHA51   LDX     #PROMPT
        BSR     PDATA1
        BSR     OUTXHI
        BSR     OUT2HS
        STX     XHI
        BSR     INCH
        CMPA    #$20
        BEQ     CHA51
        CMPA    #$5E
        BNE     CHM1
        DEX
        DEX
        STX     XHI
        BRA     CHA51
CHM1    BSR     INHEX+2
        BSR     BYTE+2
        DEX
        STAA    0,X
        CMPA    0,X
        BEQ     CHA51
;
XBK     BRA     LOAD19
;
INHEX   BSR     INCH
        SUBA    #$30
        BMI     C1
        CMPA    #$9
        BLE     IN1HG
        CMPA    #$11
        BMI     C1
        CMPA    #$16
        BGT     C1
        SUBA    #$7
IN1HG   RTS
;
;
OUT2H   LDAA 0,X
        BSR OUTHL
        LDAA 0,X
        INX
        BRA OUTHR
;
OUT4HS  BSR OUT2H
OUT2HS  BSR OUT2H
OUTS    LDAA #$20
        BRA OUTCH
;
; SET BREAK POINTS
;
BKPNT2  JSR ADDR
        STX PC1
        LDAA 0,X
        STAA BKFLG2
        BEQ XBK
        LDAA #$3F
        STAA 0,X
BKPNT   JSR ADDR
        STX PB2
        LDAA 0,X
        STAA BKFLG
        BEQ XBK
        LDAA #$3F
        STAA 0,X
        JSR CRLF
;
; FALL INTO GO COMMAND
;
CONTG   LDS SP
        RTI
;
; PRINT XHI ADDRESS SUB
;
OUTXHI  LDX #XHI
        BSR OUT4HS
        LDX XHI
        RTS
;
; VECTORED SWI ROUTINE
;
SFE     STS SP
        TSX
        TST 6,X
        BNE *+4
        DEC 5,X
        DEC 6,X
        LDS #TSTACK             ; ??? What is this
        TST TFLAG
        BEQ PRINT
        LDX PC1
        LDAA OPSAVE
        STAA 0,X
        TST BFLAG
        BEQ DISPLY
        LDX BPOINT
        LDAA BPOINT+2
        STAA 0,X
DISPLY  JMP RETURN
;
; PRINT REGISTERS
;
PRINT   LDX SP
        LDAA #6
        STAA MCONT
        LDAB 1,X
        ASLB
        ASLB
        LDX #CSET
;
DSOOP   LDAA #$2D
        ASLB
        BCC DSOOP1
        LDAA 0,X
DSOOP1  JSR OUTEEE
        INX
        DEC MCONT
        BNE DSOOP
        LDX #BREG
        BSR PDAT
        LDX SP
        INX
        INX
        JSR OUT2HS
        STX TEMP
        LDX #AREG
        BSR PDAT
        LDX TEMP
        JSR OUT2HS
        STX TEMP
        LDX #XREG
        BSR PDAT
        LDX TEMP
        BSR PRTS
        STX TEMP
        TST TFLAG
        BNE PNTS
        LDX #PCTR
        BSR PDAT
        LDX TEMP
        BSR PRTS
PNTS    LDX #SREG
        BSR PDAT
        LDX #SP
        TST TFLAG
        BNE PRINTS
        BSR PRTS
;
; CHECK IF ANY BREAK POINTS ARE SET
;
        LDAA BKFLG
        BNE C2
        LDX PB2
        STAA 0,X
        LDAA BKFLG2
        BEQ C2
        LDX PC1
        STAA 0,X
C2      BRA CR8
PDAT    JMP PDATA1
;
; SET ECHO FUNCTION
;
ECHON   CLRB
PRNTON  NEGB
ECHOFF  STAB    ECHO
        BRA     CR8
;
;  PRINT STACK POINTER
;
PRINTS  LDAB    0,X
        LDAA    1,X
        ADDA    #7
        ADCB    #0
        STAB    TEMP
        STAA    TEMP+1
        LDX     #TEMP
PRTS    JMP     OUT4HS
;
;changes from version 1 are below see 006.jpg
;
CR8     BRA     IFILL1
;
;     SAVE X REGISTER
;
SAV     STX     XTEMP
        RTS

INEEE   BSR     SAV
IN1     JSR     SERIALINCH
        ANDA    #$7F    ;RESET PARITY BIT
        CMPA    #$7F
        BEQ     IN1     ;IF RUBOUT, GET NEXT CHAR
        TST     ECHO
        BLE     OUTEEE
        RTS
;
;       OUTPUT ONE CHAR
;
OUTEEE  JMP     SERIALOUTCH

;; ;
;; ;       INPUT ONE CHAR INTO A-REGISTER
;; ;
;; ; |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
;; ; | IRQ |  PE | ROV |  FE | CTS | DCD | TDR | RDR |
;; ;
;; INEEE   BSR     SAV
;; IN1     LDAA    ACIACS
;;         ASRA                    ;
;;         BCC     IN1     ;RECEIVE NOT READY
;;         LDAA    ACIADA  ;INPUT CHARACTER
;;         ANDA    #$7F    ;RESET PARITY BIT
;;         CMPA    #$7F
;;         BEQ     IN1     ;IF RUBOUT, GET NEXT CHAR
;;         TST     ECHO
;;         BLE     OUTEEE
;;         RTS
;; ;
;; ;       OUTPUT ONE CHAR
;; ;
;; OUTEEE  PSHA
;; OUTEEE1 LDAA    ACIACS
;;         ASRA
;;         ASRA
;;         BCC     OUTEEE1
;;         PULA
;;         STAA    ACIADA
;;         RTS
;
; changes from V1 are above
;
;  HERE ON JUMP COMMAND
;
JUMP    LDX #TOADD
        BSR ENDADD+3
        LDS #STACK
        JMP 0,X
;
;  ASCII IN "@" COMMAND
;
ASCII   BSR BAD2
        INX
ASC01   DEX
ASC02   BSR INEEE
        CMPA #$8
        BEQ ASC01
        STAA 0,X
        CMPA #$4
        BEQ CR9
        INX
        BRA ASC02
;
;  FILL MEMORY "I" COMMAND
;
IFILL   BSR LIMITS
        BSR VALUE
        LDX BEGA
        DEX
IFILL2  INX
        STAA 0,X
        CPX ENDA
        BNE IFILL2
IFILL1  BRA CR9
;
;  INPUT DATA SUB ROUTINE
;
BAD2    LDX #FROMAD
        BRA *+5
ENDADD  LDX #THRUAD
        JSR PDATA1
        JMP BADDR
LIMITS  BSR BAD2
        STX BEGA
        BSR ENDADD
        STX ENDA
        JMP CRLF
ADDR    LDX ADASC
        BRA ENDADD+3
VALUE   LDX #VALASC
        JSR PDATA1
        JMP BYTE
;
; BLOCK MOVE "M" COMMAND
;
MOVE    BSR LIMITS
        LDX #TOADD
        BSR ENDADD+3
        LDX BEGA
        DEX
BMC1    INX
        LDAA 0,X
        STX BEGA
        LDX XHI
        STAA 0,X
        INX
        STX XHI
        LDX BEGA
        CPX ENDA
        BNE BMC1
CR9     JMP CONTRL
;
;  SEARCH MEMORY "S" COMMAND
;
FIND    BSR LIMITS
        BSR VALUE
        TAB
        LDX BEGA
        DEX
SMC1    INX
        LDAA 0,X
        CBA
        BNE SMC2
        STX XHI
        BSR CRLF
        JSR OUTXHI
SMC2    CPX ENDA
        BNE SMC1
        BRA CR9
;
;  SUB ROUTINE TO ADD SPACE
;
SKIP    LDAA #$20
        JSR OUTEEE
        DECB
        BNE SKIP
        RTS
;
;  PRINT BYTE IN A REGISTER
;
PNTBYT  STAA BYTECT
        LDX #BYTECT
        JMP OUT2H
;
;  CARRIAGE RETURN NON PROMPT
;
CRLF    LDX #CRLFAS
        JMP PDATA1
;
;  DISASSEMBLE "D" COMMAND
;
DISSA   JSR BAD2
        BRA DISS
;
;  TRACE COMMAND "T"
;
TRACE   JSR     BAD2
        BSR     CRLF
        LDX     SP
        LDAB    XHI
        STAB    6,X
        LDAA    XLOW
        STAA    7,X
KONTIN  INC     TFLAG
RETURN  JSR     PRINT
        LDX     SP
        LDX     6,X
DISS    STX     PC1
DISIN   BSR     CRLF
        LDX     #PC1
        JSR     OUT4HS
        LDX     #BFLAG
        LDAA    #5
CLEAR   CLR     0,X
        INX
        DECA
        BNE     CLEAR
        LDX     PC1
        LDAB 0,X
        JSR     OUT2HS
        STX     PC1
        LDAA    0,X
        STAA    PB2
        LDAA    1,X
        STAA    PB3
        STAB    PB1
        TBA
        JSR     TBLKUP
        LDAA    TEMP
        CMPA    #$2A
        BNE     OKOP
        JMP     NOTBB
OKOP    LDAA    PB1
        CMPA    #$8D
        BNE     NEXT
        INC     BFLAG
        BRA     PUT1
NEXT    ANDA    #$F0
        CMPA    #$60
        BEQ     ISX
        CMPA    #$A0
        BEQ     ISX
        CMPA    #$E0
        BEQ     ISX
        CMPA    #$80
        BEQ     IMM
        CMPA    #$C0
        BNE     PUT1
IMM     INC     MFLAG
        LDX     #SPLBD0
        BRA     PUT
ISX     INC     XFLAG
        LDAA    PB2
        JSR     PNTBYT
        LDX     #COMMX
PUT     JSR     PDATA1
PUT1    LDX     PC1
        LDAA    PB1
        CMPA    #$8C
        BEQ     BYT3
        CMPA    #$8E
        BEQ     BYT3
        CMPA    #$CE
        BEQ     BYT3
        ANDA    #$F0
        CMPA    #$20
        BNE     NOTB
        INC     BFLAG
        BRA     BYT2
NOTB    CMPA    #$60
        BCS     BYT1
        ANDA    #$30
        CMPA    #$30
        BNE     BYT2
BYT3    INC     BITE3
        TST     MFLAG
        BNE     BYT31
        LDAA    #$24
        JSR     OUTEEE
BYT31   LDAA    0,X
        INX
        STX     PC1
        JSR     PNTBYT
        LDX     PC1
        BRA     BYT21
BYT2    INC     BITE2
BYT21   LDAA    0,X
        INX
        STX     PC1
        TST     XFLAG
        BNE     BYT1
        TST     BITE3
        BNE     BYT22
        TST     MFLAG
        BNE     BYT22
        TAB
        LDAA    #$24
        JSR     OUTEEE
        TBA
BYT22   JSR     PNTBYT
BYT1    TST     BFLAG
        BEQ     NOTBB
        LDAB    #3
        JSR     SKIP
        CLRA
        LDAB    PB2
        BGE     DPOS
        LDAA    #$FF
DPOS    ADDB    PC2
        ADCA    PC1
        STAA    BPOINT
        STAB    BPOINT+1
        LDX     #BPOINT
        JSR     OUT4HS
;
; PRINT ASCII VALUE OF INST
;
NOTBB   LDAB #$D
        LDAA #1
        TST BITE2
        BEQ PAVOI3
        LDAB #1
        TST BFLAG
        BNE PAVOI2
        LDAB #8
        TST MFLAG
        BNE PAVOI2
        TST MFLAG
        BNE PAVOI2
        LDAB #9
PAVOI2  LDAA #2
        BRA PAVOI8
;
PAVOI3  TST BITE3
        BEQ PAVOI8
        LDAA #3
        LDAB #6
        TST MFLAG
        BEQ PAVOI8
        LDAB #5
PAVOI8  PSHA
        JSR SKIP
        PULB
        LDX #PB1
PAVOI4  LDAA 0,X
        CMPA #$20
        BLE PAVOI5
        CMPA #$60
        BLE PAVOI9
PAVOI5  LDAA #$2E
PAVOI9  INX
        JSR OUTEEE
        DECB
        BNE PAVOI4
NOT1    JSR INEEE
        TAB
        JSR OUTS
        CMPB #$20
        BEQ DOT
;
;  CHECK INPUT COMMAND
;  A, B, C, X, OR S
;
CKCBA   LDX SP
        INX
        CMPB #$43
        BEQ RDC
        INX
        CMPB #$42
        BEQ RDC
        INX
        CMPB #$41
        BEQ RDC
        INX
        CMPB #$58
        BEQ RDX
        LDX #SP
        CMPB #$53
        BNE RETNOT
RDX     JSR BYTE
        STAA 0,X
        INX
RDC     JSR BYTE
        STAA 0,X
        JSR CRLF
        JSR PRINT
;
;  WILL RETURN HERE IN TRACE
;
        BRA NOT1
RETNOT  JMP CONTRL
DOT     TST TFLAG
        BNE DOT1
        JMP DISIN
;
DOT1    LDAB #$3F
        LDAA PB1
        CMPA #$8D
        BNE TSTB
        LDX BPOINT
        STX PC1
        CLR BFLAG
TSTB    TST BFLAG
        BEQ TSTJ
        LDX BPOINT
        LDAA 0,X
        STAA BPOINT+2
        STAB 0,X
        BRA EXEC
;
TSTJ    CMPA #$6E
        BEQ ISXD
        CMPA #$AD
        BEQ ISXD
        CMPA #$7E
        BEQ ISJ
        CMPA #$BD
        BNE NOTJ
ISJ     LDX PB2
        STX PC1
        BRA EXEC
ISXD    LDX SP
        LDAA 5,X
        ADDA PB2
        STAA PC2
        LDAA 4,X
        ADCA #0
        STAA PC1
        BRA EXEC
;
NOTJ    LDX SP
        CMPA #$39
        BNE NOTRTS
NOTJ1   LDX 8,X
        BRA EXR
;
NOTRTS  CMPA #$38
        BNE NOTRTI
        LDX 13,X
EXR     STX PC1
NOTRTI  CMPA #$3F
        BEQ NONO
        CMPA #$3E
        BEQ NONO
;
EXEC    LDX PC1
        LDAA 0,X
        STAA OPSAVE
        STAB 0,X
        CMPB 0,X
        BNE CKROM
        JMP CONTG
;
NONO    JMP LOAD19
;
CKROM   LDAA PC1
        CMPA #$E0
        BCS NONO
;
;  GET JSR OR JMP
;
        LDX SP
        LDAA PB1
        CMPA #$7E
        BEQ NOTJ1
        CMPA #$BD
        BNE NONO
        LDX 6,X
        INX
        INX
        INX
        BRA ISJ+3
;
;Disassembler "PSH A = MISSING A" bug removed......
;
;  INSTRUCTION NMEMONIC LOOKUP
;  ROUTINE FOR 68XX OP CODES
;
TBLKUP CMPA #$40
        BCC IMLR6
IMLR1   JSR PNT3C
        LDAA PB1
        CMPA #$32
        BEQ IMLR3
        CMPA #$36  ;had � instead of #
        BEQ IMLR3
        CMPA #$33
        BEQ IMLR4
        CMPA #$37
        BEQ IMLR4
IMLR2   LDX #BLANK
        BRA IMLR5
;
IMLR3   LDX #PNTA
        BRA IMLR5       ;end of "bug removed"
;
IMLR4   LDX #PNTB
IMLR5   JMP PDATA1
IMLR6   CMPA #$4E
        BEQ IMLR7
        CMPA #$5E
        BNE IMLR8
;
IMLR7   CLRA
        BRA IMLR1
;
IMLR8   CMPA #$80
        BCC IMLR9
        ANDA #$4F
        JSR PNT3C
        LDAA TEMP
        CMPA #$2A
        BEQ IMLR2
        LDAA PB1
        CMPA #$60
        BCC IMLR2
        ANDA #$10
        BEQ IMLR3
        BRA IMLR4
;
IMLR9   ANDA #$3F
        CMPA #$F
        BEQ IMLR7
        CMPA #$7
        BEQ IMLR7
        ANDA #$F
        CMPA #$3
        BEQ IMLR7
        CMPA #$C
        BGE IMLR10
        ADDA #$50
        JSR PNT3C
        LDAA PB1
        ANDA #$40
        BEQ IMLR3
        BRA IMLR4
;
IMLR10  LDAA PB1
        CMPA #$8D
        BNE IMLR11
        LDAA #$53
        BRA IMLR1
;
IMLR11  CMPA #$C0
        BCC IMLR12
        CMPA #$9D
        BEQ IMLR7
        ANDA #$F
        ADDA #$50
        BRA IMLR13
;
IMLR12  ANDA #$F
        ADDA #$52
        CMPA #$60
        BLT IMLR7
;
IMLR13  JMP IMLR1
;
PNT3C   CLRB
        STAA TEMP
        ASLA
        ADDA TEMP
        ADCB #$0
        LDX #TBL
        STX XTEMP
        ADDA XTEMP+1
        ADCB XTEMP
        STAB XTEMP
        STAA XTEMP+1
        LDX XTEMP
        LDAA 0,X
        STAA TEMP
        BSR OUTA
        LDAA 1,X
        BSR OUTA
        LDAA 2,X
;
OUTA    JMP     OUTEEE
;
;  "V" COMMAND
;
; >V
; FROM ADDR DF71
; DF71 20 0B 10 1D  6E BC 7B D4  AA 0B 88 2A  FA 44 0E FA
;      ..........*.D..
;
; DF71 20 0B 10 1D  6E BC 7B D4  AA 0B 88 2A  FA 44 0E FA     ..........*.D..
;
VIEW    JSR     BAD2
VCOM1   LDAA    #8
        STAA    MCONT
VCOM5   JSR     CRLF
        JSR     OUTXHI
        LDAB    #$10
VCOM9   JSR     OUT2HS
        DECB
        BITB    #3
        BNE     VCOM10
        JSR     OUTS
        CMPB    #$0
VCOM10  BNE     VCOM9
    IFDEF ORIG
        JSR     CRLF            ; New line
        LDAB    #$5             ; Skip 5 spaces
    ELSE
        LDAB    #$4             ; Skip 4 spaces
    ENDIF
        JSR     SKIP            ; Skip
        LDX     XHI
        LDAB    #$10
VCOM2   LDAA    0,X
        CMPA    #$20
        BCS     VCOM3
        CMPA    #$5F
        BCS     VCOM4
VCOM3   LDAA    #$2E
VCOM4   BSR     OUTA            ; LBSR OUTEEE
        INX
        DECB
        BNE     VCOM2
        STX     XHI
        DEC     MCONT
        BNE     VCOM5
        JSR     INEEE
        CMPA    #$20
        BEQ     VCOM1
        CMPA    #$56
        BEQ     VIEW
        JMP     CONTRL
;
; MNKEMONIC TABLE
;
TBL     FCC "***NOPNOP***"
        FCC "******TAPTPA"
        FCC "INXDEXCLVSEV"
        FCC "CLCSECCLISEI"
        FCC "SBACBA******"
        FCC "******TABTBA"
        FCC "***DAA***ABA"
        FCC "************"
        FCC "BRA***BHIBLS"
        FCC "BCCBCSBNEBEQ"
        FCC "BVCBVSBPLBMI"
        FCC "BGEBLTBGTBLE"
        FCC "TSXINSPULPUL"
        FCC "DESTXSPSHPSH"
        FCC "***RTS***RTI"
        FCC "******WAISWI"
        FCC "NEG******COM"
        FCC "LSR***RORASR"
        FCC "ASLROLDEC***"
        FCC "INCTSTJMPCLR"
        FCC "SUBCMPSBCBSR"
        FCC "ANDBITLDASTA"
        FCC "EORADCORAADD"
        FCC "CPXJSRLDSSTS"
        FCC "LDXSTX"
SPLBD0  FCC "#$"
        FCB $04
COMMX   FCC ",X"                ; $2C,$58
        FCB $04
BLANK   FCC "   "               ; $20,$20,$20
        FCB $04
PNTA    FCC "A "                ; Like LDAA rather than LDA A
        FCB $04
PNTB    FCC "B "                ;
        FCB $04
    IFDEF ORIG
PROMPT  FCB $D,$A,$15,$13,$3E,$04 ; "\r\n^U^Q>^D"
BREG    FCB $20,$42,$3D,$04
AREG    FCB $41,$3D,$04
XREG    FCB $58,$3D,$04
SREG    FCB $53,$3D,$04
PCTR    FCB $50,$43,$3D,$04
CSET    FCB $48,$49,$4E,$5A,$56,$43
CRLFAS  FCB $0D,$0A,$15,$04
ADASC   FCB $0D,$0A
        FCB $42,$4B,$41,$44,$44,$52,$20,$04
FROMAD  FCB $0D,$0A,$46,$52,$4F,$4D,$20
        FCB $41,$44,$44,$52,$20,$04
THRUAD  FCB $0D,$0A,$54,$48,$52,$55,$20,$41
        FCB $44,$44,$52,$20,$04
TOADD   FCB $54,$4F,$20,$41,$44,$44,$52,$20,$04
VALASC  FCB $56,$41,$4C,$55,$45,$20,$04
    ELSE
PROMPT  FCC "\r\n> "            ; $D,$A,$3E,$20,$04
	FCB $04
BREG    FCC " B="
        FCB $04              ; FCB $20,$42,$3D,$04
AREG    FCC "A="
        FCB $04
XREG    FCC "X="
        FCB $04
SREG    FCC "S="
        FCB $04
PCTR    FCC "PC="
        FCB $04
CSET    FCC "HINZVC"            ; $48,$49,$4E,$5A,$56,$43
CRLFAS  FCC "\r\n"
        FCB $04
ADASC   FCC "\r\nBKADDR "       ; $42,$4B,$41,$44,$44,$52,$20
        FCB $04
FROMAD  FCB "\r\nFROM ADDR "    ; $0D,$0A,$46,$52,$4F,$4D,$20,$41,$44,$44,$52,$20
        FCB $04
THRUAD  FCC "\r\nTHRU ADDR "    ; $0D,$0A,$54,$48,$52,$55,$20,$41,$44,$44,$52,$20
        FCB $04
TOADD   FCB "TO ADDR "          ; $54,$4F,$20,$41,$44,$44,$52,$20
        FCB $04
VALASC  FCB "VALUE "            ; $56,$41,$4C,$55,$45,$20
        FCB $04
    ENDIF
;
;   COMMAND JUMP TABLE
;
FUTABL  FCC "M"
        FDB MOVE
        FCC "E"
        FDB CHANGE
        FCC "G"
        FDB CONTG               ; Go command
        FCC "R"
        FDB PRINT
        FCC "T"
        FDB TRACE
        FCC "@"
        FDB ASCII
        FCC "H"
        FDB PRNTON
        FCC "V"
        FDB VIEW
        FCC "I"
        FDB IFILL
        FCC "J"
        FDB JUMP
        FCC "F"
        FDB FIND
        FCC "Q"
        FDB $8020
        FCC "D"
        FDB DISSA
        FCC "K"
        FDB KONTIN              ; Continue, Trace
;
; Break points
;       FCC "1"
        FCC "["
        FDB BKPNT
;       FCC "2"
        FCC "]"
        FDB BKPNT2
        FCC "&"
        FDB SLOAD               ; new for V2 was FDB $7283
        ;;
        ;; Didn't see this before
        ;;
        FCC "*"
        FDB START               ; Hard coded, not a great idea (was $F800)
        FCC "O"
        FDB ECHON
        FCC "N"
        FDB ECHOFF
        FCC "U"
        FDB USER
TBLEND  EQU *
;
;       ADDED TO VERSION 2:
;       MOTOROLA "S" LOADER PROGRAMME "S1" STARTS LOAD
;       END OF LOAD "S9" RUN START END PLUS ADDRESS
;
;       "S" LOADER PROGRAMME START
;
S1STRING        FCC     "\r\nThis S1 load has entered system scratch area\r\n"
                FCB     $04
;
; S1 13 2000 BD FC BC 86 01 20 07 D6 F1 CB 10 D7 F1 48 BD FE 3C
;
; ADDRESS  = $20 (Hi)
; ADDRESS1 = $00 (Lo)
;
SLOAD   EQU     *
        PSHA                    ; Save A register
        STX     TEMPX1          ; Save X register
GOAGAIN JSR     GETCHAR         ; Get first character from ACIA
        CMPA    #"S"            ; Is it "S"
        BNE     GOAGAIN         ; If not go read again
        JSR     GETCHAR         ; Get second character in frame
        CMPA    #"9"            ; Is it "9"
        BEQ     RECOVER         ; If "9" go and end read
        CMPA    #"1"            ; Is it a "1"
        BNE     GOAGAIN         ; If no then go start again
; Okay we've got S1
        CLR     TEMPA           ; Clear Frame length
        BSR     GETHEX          ; Get frame length from input stream
        SUBA    #$02            ; Subtract the checksum
; Save the count
        STAA    BYTESTORE       ; Save frame length
        BSR     GETADD          ; Read next two bytes for dest address
GETCNT  BSR     GETHEX          ; Get the byte number
        DEC     BYTESTORE       ; decrement counter
        BEQ     INCOUNT         ; If zero go to increment byte count
        STAA    0,X             ; Store read byte into memory
        CMPA    0,X             ; Test if RAM OK
        BNE     QUESTN          ; If write failed send Question and abort
        INX                     ; Increment address pointer
    IFDEF ORIG
        ; bad op code: CMPX  UPRAM
;;;
;;; @FIXME: Need to fix this check for S1DUMP into Scratch RAM
;;;
        CPX     #UPRAM          ; Is it the system scratch area
        BGT     S1EXIT          ; Abort if close to system scratch
    ENDIF
        BRA     GETCNT          ; go get another byte
;
S1EXIT  LDX     #S1STRING       ; Protect System Scratch Abort S1
        JSR     OUTSTR          ; Print abort string
        BRA     RECOVER         ; Back to console prompt
;
INCOUNT INC     TEMPA           ; Increment tempa
        BEQ     GOAGAIN         ; If zero go for another frame
QUESTN  LDAA    #"?"            ; Load question mark
        JSR     OUTPUTA         ; Send to console
RECOVER LDX     TEMPX1          ; Restore "X"
        PULA                    ; Restore A
        JMP     CONTRL          ; Jump to exit

;; GETCHAR PSHB
;; WAITIN  LDAB ACIACS             ; LOAD ACIA CONTROL REGISTER
;;         ASRB                    ; SHIFT RIGHT  ACIADA
;;         BCC     WAITIN          ; IF CARRY NOT SET THEN AGAIN
;;         LDAA    ACIADA          ; LOAD DATA REGISTER
;;         PULB                    ; RESTORE B REGISTER
;;         BSR     OUTPUTA         ; ECHO INPUT
;;         RTS
;
GETADD  JSR     GETHEX          ; Read in byte
        STAA    ADDRESS         ; store in first part of address
        BSR     GETHEX          ; Get another byte of data
        STAA    ADDRESS1        ; store in second address register
        LDX     ADDRESS         ; Load X register both bytes of address
        RTS                     ; Return from sub routine
;
;       ADD IN THE ADDRESS OFFSET
;
GETHEX  BSR     CONVHEX         ; Go get byte of data and convert to binary
        ASLA                    ; Shift the the 4 bits into msb
        ASLA                    ; Shift the the 4 bits into msb
        ASLA                    ; Shift the the 4 bits into msb
        ASLA                    ; Shift the the 4 bits into msb
        TAB                     ; Transfer "A" to "B"
        BSR     CONVHEX         ; Go get byte of data and convert to binary
        ABA                     ; Add 4 bits in "A" and "B" into "B"
        TAB                     ; Transfer "A" to "B"
        ADDB    TEMPA           ; Add into checksum
        STAB    TEMPA           ; Add into checksum
        RTS                     ; Return from sub routine
;
CONVHEX BSR     GETCHAR         ; Get HEX character from ACIA
        SUBA    #$30            ; Convert to binary
        BMI     QUESTN          ; Convert to binary
        CMPA    #$09            ; Convert to binary
        BLE     RETURN2         ; Convert to binary
        CMPA    #$11            ; Convert to binary
        BMI     INCSTACK        ; Convert to binary
        CMPA    #$16            ; Convert to binary
        BGT     INCSTACK        ; Convert to binary
        SUBA    #$07            ; Convert to binary
RETURN2 RTS                     ; Return from sub routine
;
INCSTACK INS                    ; Restore stack position
        INS                     ; Restore stack position
        BRA     QUESTN         ; Go send ? and exit

        include   "serialinit"
GETCHAR
        include   "serial9600"

;; OUTPUTA PSHB                    ; SAVE B
;; WAITOUT LDAB ACIACS             ; LOAD ACIA CONTROL REGISTER
;;         ASRB                    ; SHIFT RIGHT
;;         ASRB                    ; SHIFT RIGHT
;;         BCC     WAITOUT ; IF CARRY NOT SET DO AGAIN
;;         STAA ACIADA             ; SEND CHARACTOR TO ACIA
;;         PULB                    ; RESTORE B
;;         RTS                     ; RETURN FROM ROUTINE
OUTPUTA JMP     SERIALOUTCH
                                ;
OUTSTR  LDAA    0,X                     ; Read String
        CMPA    #$4             ; Is it EOT?
        BEQ     STEXIT          ; Exit if EOT
        BSR     OUTPUTA ; Print Character
        INX                     ; Point at next character
        BRA     OUTSTR          ; Loop and read next
STEXIT  RTS                     ;

SERIALINCH   EQU INCH9600
SERIALOUTCH  EQU OUTCH9600

;;;
RFINI   EQU *
;;;
;asl -i . -D _SIM -L smithbug.asm
;p2hex +5 -F Moto -r '$-$' smithbug.p smithbug.s19
;srec_info smithbug.s19
;nano smithbug.s19
;srec_cat  smithbug.s19 -offset -0xC000 -o smithbug.bin -binary
;sim6800 smithbug.s19
;
;asl -i . -D _E000 -L smithbug.asm
;p2hex +5 -F Moto -r '$-$' smithbug.p smithbug.s19
;srec_info smithbug.s19
;miniprohex --offset -0xE000 -p AT28C64B -w smithbug.s19
;
;/* Local Variables: */
;/* mode:asm         */
;/* End:             */
