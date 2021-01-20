#import "C64Constants.asm"

BasicUpstart2(start)

#import "Memory.asm"
#import "Ship.asm"
#import "Bullet.asm"
#import "Bombs.asm"
#import "Utils.asm"
#import "Rocket.asm"

start:
    jsr $E544

    lda #<txtScoringLine
    ldy #>txtScoringLine
    jsr PrintAtPoint
    lda #<txtFuelLine
    ldy #>txtFuelLine
    jsr PrintAtPoint
    lda #0
    sta BottomDataIndex
    sta BottomRowPos
    sta BottomCounter
    sta TopDataIndex
    sta TopRowPos
    sta TopCounter
    sta AreWeDeadYet
    sta Score
    sta Score + 1
    sta Score + 2

    lda #1
    sta ShipXValue
    lda #6
    sta ShipYValue
    lda #248
    sta FuelTank

    jsr SetUpSystem

GameLoop:
    jsr RemoveRocketsFromScreen
    jsr RemoveBombsFromScreen
    jsr RemoveBulletsFromScreen
    jsr RemoveShipFromScreen
    jsr ChangeShipsPosition
    jsr ChangeBulletsPosition
    jsr ChangeRocketsPosition
    jsr ChangeBombsPosition
    jsr CheckBulletCollision
    jsr ScrollScreen
    jsr CheckBombCollision
    jsr PlaceShipToScreen
    jsr ScanForRockets
    jsr PlaceBulletToScreen
    jsr PlaceBombToScreen
    jsr CheckRocketCollision
    jsr PlaceRocketToScreen
    jsr BuildScene
    jsr ShipControl
    jsr DisplayScore
    jsr ShowXBar
    dec FuelTank
    bne !NotDead+
    lda #128
    sta AreWeDeadYet
    inc FuelTank
!NotDead:
    ldy #50
!Outer:
    ldx #255
!Loop:
    dex
    bne !Loop-
    dey
    bne !Outer-
    jmp GameLoop

SetUpSystem:
    lda VIC_SCROLX
    and #%11110111
    sta VIC_SCROLX

    ldx #MaxNoOfBullets - 1
    lda #128
!BulletLoop:
    sta BulletXArray,x
    dex
    bpl !BulletLoop-

    ldx #MaxNoOfBombs - 1
    lda #128
!BombLoop:
    sta BombXArray,x
    dex
    bpl !BombLoop-

    ldx #MaxNoOfRockets - 1
    lda #128
!RocketLoop:
    sta RocketXArray,x
    dex
    bpl !RocketLoop-

    jsr InitXBar
    rts


ScrollScreen:
    ldx #2
RowLooper:
    // lda RowScreenLocationHi,x
    // and #%00001111
    // sta zpScreenLocLo + 1
    // clc
    // adc #$D4
    // sta zpColourLocLo + 1
    // lda RowScreenLocationLo,x
    // sta zpScreenLocLo
    // sta zpColourLocLo
    jsr GetScreenRowLocation


    ldy #1
ColLooper:
    lda (zpScreenLocLo),y
    dey
    sta (zpScreenLocLo),y
    iny
    lda (zpColourLocLo),y
    dey
    sta (zpColourLocLo),y
    iny
    iny
    cpy #40
    bcc ColLooper
    dey
    lda #32
    sta (zpScreenLocLo),y
    lda #0
    sta (zpColourLocLo),y

    inx
    cpx #25
    bcc RowLooper
    rts


BottomGround:
    .byte %00011000
    .byte %00001101
    .byte %00001111
    .byte %00001101
    .byte %00001110
    .byte %00001111
    .byte %00011101
    .byte %00001110
    .byte %10000000

TopGround:
    // Level 1
    .byte %00001000
    .byte %10000000

    // .byte %00011000
    // .byte %00001101
    // .byte %00001111
    // .byte %00001101
    // .byte %00001110
    // .byte %00001111
    // .byte %00011101
    // .byte %00001110
    // .byte %10000000

SurfaceTargetCycle:
    .byte RocketChar,ShipChar,FuelChar,FuelChar,ShipChar,RocketChar,FuelChar,FuelChar
    .byte RocketChar,ShipChar,FuelChar,FuelChar,ShipChar,ShipChar,RocketChar,FuelChar

SurfaceTargetColourCycle:
    .byte YELLOW,PURPLE,GREEN,GREEN,PURPLE,YELLOW,GREEN,GREEN
    .byte YELLOW,PURPLE,GREEN,GREEN,PURPLE,PURPLE,YELLOW,GREEN


// 3 Direction ... stay, up, down 00 01 10 11
//                                ^^ = Absolute
// # in that direction               ^^ Stay
//                                      ^^ Up
//                                         ^^ Down

// 000000 = # 11 = Direction

// Single Flat = Rocket
// Two Flat = Rocket and Ship
// Three Flat = Rocket, Ship and Fuel
// 

BuildScene:
    jsr BuildBottomScene
    jsr BottomDraw
    jsr BuildTopScene
    jsr TopDraw
    rts

BuildBottomScene:
    lda BottomCounter
    beq BuildBottomStart
    rts

BuildBottomStart:
    lda BGLoc: BottomGround
    sta BottomCurrent

    clc
    lda BGLoc
    adc #1
    sta BGLoc
    bcc !ByPassInc+
    inc BGLoc + 1
!ByPassInc:
    lda BottomCurrent
    bpl !Continue+
    lda #<BottomGround
    sta BGLoc
    lda #>BottomGround
    sta BGLoc + 1
    jmp BuildBottomScene

!Continue:
    and #%00000011
    cmp #%00000000
    bne !PossibleStay+
    lda BottomCurrent 
    and #%01111100
    lsr
    lsr
    sta BottomRowPos
    lda #1
    jmp !StoreBottomCounter+

!PossibleStay:
    cmp #%00000001
    bne !PossibleUp+
    lda BottomCurrent
    and #%01111100
    lsr
    lsr
    jmp !StoreBottomCounter+

!PossibleUp:    
    cmp #%00000010
    bne !PossibleDown+
    lda BottomCurrent
    and #%01111100
    lsr
    lsr
    jmp !StoreBottomCounter+

!PossibleDown:
    lda BottomCurrent
    and #%01111100
    lsr
    lsr

!StoreBottomCounter:
    sta BottomCounter
    //jmp BottomDraw
    rts

BottomDraw:
    lda BottomCurrent
    and #%00000011
    cmp #%00000000
    bne DrawBottomStay
    lda BottomCurrent
    and #%01111100
    lsr
    lsr
    sta BottomRowPos
    jmp !DrawBottomStayExecute+

DrawBottomStay:
    cmp #%00000001
    bne DrawBottomUp
!DrawBottomStayExecute:
    lda #160 //#227
    jsr DrawBottomPillar
    jmp DrawBottomUpdate

DrawBottomUp:
    cmp #%00000010
    bne DrawBottomDown
    inc BottomRowPos
    lda #233        // Going Up Triangle
    jsr DrawBottomPillar
    jmp DrawBottomUpdate

DrawBottomDown:
    lda #223        // Going Down Triangle
    jsr DrawBottomPillar
    dec BottomRowPos
    jmp DrawBottomUpdate

DrawBottomUpdate:
    dec BottomCounter
    rts

DrawBottomPillar:
    pha
    lda #0
    sta BottomRowCounter
    ldx #24

!RowLooper:
    // lda RowScreenLocationHi,x
    // and #%00001111
    // sta zpScreenLocLo + 1
    // clc
    // adc #$D4
    // sta zpColourLocLo + 1
    // lda RowScreenLocationLo,x
    // sta zpScreenLocLo
    // sta zpColourLocLo
    jsr GetScreenRowLocation

    ldy #39
    lda #160
    sta (zpScreenLocLo),y
    lda #RED
    sta (zpColourLocLo),y

    dex
    inc BottomRowCounter
    lda BottomRowCounter
    cmp BottomRowPos
    bne !RowLooper-

    // lda RowScreenLocationHi,x
    // and #%00001111
    // sta zpScreenLocLo + 1
    // clc
    // adc #$D4
    // sta zpColourLocLo + 1
    // lda RowScreenLocationLo,x
    // sta zpScreenLocLo
    // sta zpColourLocLo
    jsr GetScreenRowLocation

    pla
    pha
    ldy #39
    sta (zpScreenLocLo),y
    lda #RED
    sta (zpColourLocLo),y

    dex
    jsr GetScreenRowLocation
    pla
    cmp #160
    bne !ResetSurfaceTargetIndex+
    ldy SurfaceTargetsIndex
    lda SurfaceTargetColourCycle,y
    pha
    lda SurfaceTargetCycle,y 
    pha
    iny
    cpy #16
    bne !ApplyTarget+
    ldy #0

!ApplyTarget:
    sty SurfaceTargetsIndex
    ldy #39
    pla
    sta (zpScreenLocLo),y
    pla
    sta (zpColourLocLo),y
    rts

!ResetSurfaceTargetIndex:
    lda #0
    sta SurfaceTargetsIndex
    rts

GetScreenRowLocation:
// Input : XReg = Row #
    lda RowScreenLocationHi,x
    and #%00001111
    sta zpScreenLocLo + 1
    clc
    adc #$D4
    sta zpColourLocLo + 1
    lda RowScreenLocationLo,x
    sta zpScreenLocLo
    sta zpColourLocLo
    rts

BuildTopScene:
    lda TopCounter
    beq BuildTopStart
    rts

BuildTopStart:
    lda TGLoc: TopGround
    sta TopCurrent

    clc
    lda TGLoc
    adc #1
    sta TGLoc
    bcc !ByPassInc+
    inc TGLoc + 1
!ByPassInc:
    lda TopCurrent
    bpl !Continue+
    lda #<TopGround
    sta TGLoc
    lda #>TopGround
    sta TGLoc + 1
    jmp BuildTopScene

!Continue:
    and #%00000011
    cmp #%00000000
    bne !PossibleStay+
    lda TopCurrent 
    and #%01111100
    lsr
    lsr
    sta TopRowPos
    lda #1
    jmp !StoreTopCounter+

!PossibleStay:
    cmp #%00000001
    bne !PossibleUp+
    lda TopCurrent
    and #%01111100
    lsr
    lsr
    jmp !StoreTopCounter+

!PossibleUp:    
    cmp #%00000010
    bne !PossibleDown+
    lda TopCurrent
    and #%01111100
    lsr
    lsr
    jmp !StoreTopCounter+

!PossibleDown:
    lda TopCurrent
    and #%01111100
    lsr
    lsr

!StoreTopCounter:
    sta TopCounter
    //jmp TopDraw
    rts

TopDraw:
    lda TopCurrent
    and #%00000011
    cmp #%00000000
    bne DrawTopStay
    lda TopCurrent
    and #%01111100
    lsr
    lsr
    sta TopRowPos
    jmp !DrawTopStayExecute+

DrawTopStay:
    cmp #%00000001
    bne DrawTopUp
!DrawTopStayExecute:
    lda #160 //#228
    jsr DrawTopPillar
    jmp DrawTopUpdate

DrawTopUp:
    cmp #%00000010
    bne DrawTopDown
    lda #105        // Going Up Triangle
    jsr DrawTopPillar
    dec TopRowPos
    jmp DrawTopUpdate

DrawTopDown:
    inc TopRowPos
    lda #95        // Going Down Triangle
    jsr DrawTopPillar
    jmp DrawTopUpdate

DrawTopUpdate:
    dec TopCounter
    rts

DrawTopPillar:
    pha
    lda #0
    sta TopRowCounter
    ldx #2

!RowLooper:
    // lda RowScreenLocationHi,x
    // and #%00001111
    // sta zpScreenLocLo + 1
    // clc
    // adc #$D4
    // sta zpColourLocLo + 1
    // lda RowScreenLocationLo,x
    // sta zpScreenLocLo
    // sta zpColourLocLo
    jsr GetScreenRowLocation

    ldy #39
    lda #160
    sta (zpScreenLocLo),y
    lda #GREEN
    sta (zpColourLocLo),y

    inx
    inc TopRowCounter
    lda TopRowCounter
    cmp TopRowPos
    bne !RowLooper-

    // lda RowScreenLocationHi,x
    // and #%00001111
    // sta zpScreenLocLo + 1
    // clc
    // adc #$D4
    // sta zpColourLocLo + 1
    // lda RowScreenLocationLo,x
    // sta zpScreenLocLo
    // sta zpColourLocLo
    jsr GetScreenRowLocation

    pla
    ldy #39
    sta (zpScreenLocLo),y
    lda #GREEN
    sta (zpColourLocLo),y
    rts
