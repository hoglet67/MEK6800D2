        ORG     $C800

        BSR     SERIALINIT
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

        include "serialinit.inc"


        include "serial9600.inc"
        include "serial19200.inc"
        include "serial38400.inc"
