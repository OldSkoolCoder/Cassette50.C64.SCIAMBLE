#import "C64Constants.asm"
#import "Memory.asm"

// TODO: Check For Collision Detection on Bullets

RemoveBulletsFromScreen:
    ldx #MaxNoOfBullets - 1

!BulletLooper:
    txa
    pha
    lda BulletXArray,x
    bmi !NoBulletFound+
    pha
    lda BulletYArray,x
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda #32
    sta (zpScreenLocLo),y
    lda #0
    sta (zpColourLocLo),y

!NoBulletFound:
    pla
    tax
    dex
    bpl !BulletLooper-
    rts

PlaceBulletToScreen:
    ldx #MaxNoOfBullets - 1

!BulletLooper:
    txa
    pha
    lda BulletXArray,x
    bmi !NoBulletFound+
    pha
    lda BulletYArray,x
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda #67
    sta (zpScreenLocLo),y
    lda #GREEN
    sta (zpColourLocLo),y

!NoBulletFound:
    pla
    tax
    dex
    bpl !BulletLooper-
    rts

ChangeBulletsPosition:
    ldx #MaxNoOfBullets - 1

!BulletLooper:
    lda BulletXArray,x
    bmi !NoBulletFound+
    cmp #39
    bne !StillActive+
    lda #127
    sta BulletXArray,x

!StillActive:
    inc BulletXArray,x

!NoBulletFound:
    dex
    bpl !BulletLooper-
    rts

CheckBulletCollision:
    ldx #MaxNoOfBullets - 1

!BulletLooper:
    txa
    pha
    lda BulletXArray,x
    bmi !NoBulletFound+
    pha
    lda BulletYArray,x
    tay
    pla
    tax
    jsr CheckLocationForPoints
    bcc !NoBulletFound+
    pla
    pha
    tax
    lda #128
    sta BulletXArray,x

!NoBulletFound:
    pla
    tax
    dex
    bpl !BulletLooper-
    rts





CheckLocationForPoints:
// Input Parameters : XReg = Column
//                  : YReg = Row
    txa
    pha
    tya
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda (zpScreenLocLo),y
    cmp #30                 // Rocket
    bne !NotTheRocket+
    jmp !CleanExit+

!NotTheRocket:
    cmp #94
    bne !NotTheShips+
    jmp !CleanExit+

!NotTheShips:
    cmp #81
    bne !NotTheFuel+
    jmp !CleanExit+

!NotTheFuel:
    cmp #32
    bne !NotTheSpace+
!CleanExit:
    clc
    rts

!NotTheSpace:
    sec
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
