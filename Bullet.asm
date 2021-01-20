#importonce
#import "C64Constants.asm"
#import "Memory.asm"
#import "Utils.asm"

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
    lda #$00
    ldy #$01
    jsr AddingScore
    jmp !NotTheSpace+

!NotTheRocket:
    cmp #94
    bne !NotTheShips+
    lda #$50
    ldy #$00
    jsr AddingScore
    jmp !NotTheSpace+

!NotTheShips:
    cmp #81
    bne !NotTheFuel+
    lda #24
    clc
    adc FuelTank
    sta FuelTank
    bcc !Exit+
    lda #248
    sta FuelTank
!Exit:
    jmp !NotTheSpace+

!NotTheFuel:
    cmp #32
    bne !NotTheSpace+
!CleanExit:
    clc
    rts

!NotTheSpace:
    sec
    rts






