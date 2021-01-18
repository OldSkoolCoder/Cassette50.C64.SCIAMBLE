#import "C64Constants.asm"
#import "Memory.asm"

// TODO: Check For Collision Detection on Bombs

RemoveBombsFromScreen:
    ldx #MaxNoOfBombs - 1

!BombLooper:
    txa
    pha
    lda BombXArray,x
    bmi !NoBombFound+
    pha
    lda BombYArray,x
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda #32
    sta (zpScreenLocLo),y
    lda #0
    sta (zpColourLocLo),y

!NoBombFound:
    pla
    tax
    dex
    bpl !BombLooper-
    rts

PlaceBombToScreen:
    ldx #MaxNoOfBombs - 1

!BombLooper:
    txa
    pha
    lda BombXArray,x
    bmi !NoBombFound+
    pha
    lda BombYArray,x
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda #42
    sta (zpScreenLocLo),y
    lda #PURPLE
    sta (zpColourLocLo),y

!NoBombFound:
    pla
    tax
    dex
    bpl !BombLooper-
    rts

ChangeBombsPosition:
    ldx #MaxNoOfBombs - 1

!BombLooper:
    lda BombXArray,x
    bmi !NoBombFound+
    lda BombYArray,x
    cmp #24
    bne !StillActive+
    lda #128
    sta BombXArray,x
    bmi !NoBombFound+

!StillActive:
    inc BombYArray,x

!NoBombFound:
    dex
    bpl !BombLooper-
    rts


CheckBombCollision:
    ldx #MaxNoOfBombs - 1

!BombLooper:
    txa
    pha
    lda BombXArray,x
    bmi !NoBombFound+
    pha
    lda BombYArray,x
    tay
    pla
    tax
    jsr CheckLocationForPoints
    bcc !NoBombFound+
    pla
    pha
    tax
    lda #128
    sta BombXArray,x

!NoBombFound:
    pla
    tax
    dex
    bpl !BombLooper-
    rts






//     ldx ShipYValue
//     jsr GetScreenRowLocation
//     ldy ShipXValue
//     lda (zpScreenLocLo),y
//     iny
//     ora (zpScreenLocLo),y
//     iny
//     ora (zpScreenLocLo),y
//     iny
//     ora (zpScreenLocLo),y 
//     and #%11011111
//     beq !Exit+
//     lda #128
//     sta AreWeDeadYet

// !Exit:
//     rts
