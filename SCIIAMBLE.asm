#import "C64Constants.asm"

BasicUpstart2(start)

#import "Memory.asm"
#import "Ship.asm"
#import "Bullet.asm"
#import "Bombs.asm"
#import "Utils.asm"
#import "Rocket.asm"
#import "SID.asm"

start:
*=* "Game Code"
NewGame:
    jsr SetUpSystem

    jsr SessionSetUp
    jsr Utils.DisplayShipsRemaining

    lda #0
    sta AreWeDeadYet
    sta Score
    sta Score + 1
    sta Score + 2
    sta HardnessInterval

GameLoop:
    jsr Rocket.RemoveFromScreen
    jsr Bomb.RemoveFromScreen
    jsr Bullet.RemoveFromScreen
    jsr Ship.RemoveFromScreen

    jsr Ship.ChangePosition
    jsr Bullet.ChangePosition
    jsr Rocket.ChangePosition
    jsr Bomb.ChangePosition

    jsr Bullet.CheckCollision
    jsr ScrollScreen
    jsr Bomb.CheckCollision
    jsr Ship.CheckPosition
    jsr Ship.PlaceToScreen
    jsr Rocket.Scan

    jsr Bullet.PlaceToScreen
    jsr Bomb.PlaceToScreen
    jsr Rocket.CheckCollision
    jsr Rocket.PlaceToScreen

    jsr BuildScene
    jsr Ship.Control
    jsr Utils.DisplayScore
    jsr Utils.ShowXBar
    dec FuelTank
    bne !NotDead+
    lda #128
    sta AreWeDeadYet
    //inc FuelTank
!NotDead:
    ldy #80
!Outer:
    ldx #255
!Loop:
    dex
    bne !Loop-
    dey
    bne !Outer-
    lda AreWeDeadYet
    bmi WeDied
    jsr SID.TurnOffVoice3
    jmp GameLoop

WeDied:
    jsr SID.ShipExplosionSFX
    jsr Ship.Explode
    jsr SID.TurnOffVoice1
    jsr SID.TurnOffVoice2
    //jsr TurnOffVoice3 
    dec ShipsRemaining
    beq !NoMoreShips+
    lda #<txtGameOver2
    ldy #>txtGameOver2
    jsr Utils.PrintAtPoint
FireButtonTest:
    // lda CIAPRA
    // eor #$FF                // Inverts the Bits
    // and #%00011111          // Mask Off only important Bits
    // and #joystickFire
    // cmp #joystickFire
    lda krljmpLSTX
    cmp #scanCode_SPACEBAR
    bne FireButtonTest

    jsr SessionSetUp
    jsr Utils.DisplayShipsRemaining
    //lda #0
    //sta AreWeDeadYet
    asl AreWeDeadYet

    jmp GameLoop

!NoMoreShips:
    lda #<txtGameOver
    ldy #>txtGameOver
    jsr Utils.PrintAtPoint
    lda #<txtGameOver2
    ldy #>txtGameOver2
    jsr Utils.PrintAtPoint
FireButtonTestAgain:
    lda krljmpLSTX
    cmp #scanCode_SPACEBAR
    bne FireButtonTestAgain
    jmp NewGame

SetUpSystem:
    lda VIC_SCROLX
    and #%11110111
    sta VIC_SCROLX

    lda #4
    sta ShipsRemaining

    lda #BLUE
    sta VIC_EXTCOL

    lda #15
    jsr SID.SetVolume
    rts

SessionSetUp:
    jsr $E544

    lda #<txtScoringLine
    ldy #>txtScoringLine
    jsr Utils.PrintAtPoint
    //lda #<txtFuelLine
    //ldy #>txtFuelLine
    //jsr Utils.PrintAtPoint

    jsr Utils.InitXBar

    lda #0
    sta BottomDataIndex
    //sta BottomRowPos
    sta BottomCounter
    sta TopDataIndex
    //sta TopRowPos
    sta TopCounter

    ldx #MaxNoOfBullets - 1
    lda #128
!BulletLoop:
    sta BulletXArray,x
    sta RocketXArray,x
    sta BombXArray,x
    dex
    bpl !BulletLoop-

//     ldx #MaxNoOfBombs - 1
// //    lda #128
// !BombLoop:
//     sta BombXArray,x
//     dex
//     bpl !BombLoop-

//     ldx #MaxNoOfRockets - 1
// //    lda #128
// !RocketLoop:
//     sta RocketXArray,x
//     dex
//     bpl !RocketLoop-

    lda #6
    sta ShipYValue
    lda #248
    sta FuelTank
    lda #120
    sta HardnessDelay
    ldy #1
    sty ShipXValue
    dey
    //lda #0
    sty ShipXDeltaValue
    sty ShipYDeltaValue

    jsr ResetBottomLocator
    // lda #<BottomGround
    // sta BGLoc
    // lda #>BottomGround
    // sta BGLoc + 1
    jmp ResetTopLocator
    // lda #<TopGround
    // sta TGLoc
    // lda #>TopGround
    // sta TGLoc + 1
    //rts

ScrollScreen:
    ldx #2
RowLooper:
    jsr Utils.GetScreenRowLocation

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
    // .byte %00001000
    // .byte %10000000

    .byte %00010000
    .byte %00001101
    .byte %00001111
    .byte %00001101
    .byte %00001110
    .byte %00001111
    .byte %00011101
    .byte %00001110
    .byte %10000000

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
    jmp TopDraw
    //rts

BuildBottomScene:
    lda BottomCounter
    beq BuildBottomStart
    rts

BuildBottomStart:
    lda BGLoc: BottomGround
    sta BottomCurrent
    and #%01111100
    lsr
    lsr
    sta BottomCounter
    // clc
    // lda BGLoc
    // adc #1
    // sta BGLoc
    // bcc !ByPassInc+
    inc BGLoc
    bne !ByPassInc+
    inc BGLoc + 1
!ByPassInc:
    lda BottomCurrent
    bpl !Continue+
    jsr ResetBottomLocator
    // lda #<BottomGround
    // sta BGLoc
    // lda #>BottomGround
    // sta BGLoc + 1
    jmp BuildBottomScene

!Continue:
    and #%00000011
    cmp #%00000000
    bne !Exit+
    lda BottomCounter 
    sta BottomRowPos
    lda #1
    sta BottomCounter

!Exit:
    rts

ResetBottomLocator:
    lda #<BottomGround
    sta BGLoc
    lda #>BottomGround
    sta BGLoc + 1
    rts

BottomDraw:
    lda #RED
    sta PillarColour
    lda #24
    sta PillarXStart
    lda #$CA                // DEX Instruction
    sta LocationOfDEX_INX
    lda BottomCurrent
    and #%00000011
    cmp #%00000000
    bne DrawBottomStay
    jmp !DrawBottomStayExecute+

DrawBottomStay:
    cmp #%00000001
    bne DrawBottomUp
!DrawBottomStayExecute:
    lda #160 //#227
    ldy BottomRowPos
    jsr DrawPillar
    jsr PlaceSurfaceAssets
    jmp DrawBottomUpdate

DrawBottomUp:
    cmp #%00000010
    bne DrawBottomDown
    inc BottomRowPos
    lda #233        // Going Up Triangle
    ldy BottomRowPos
    jsr DrawPillar
    jmp DrawBottomUpdate

DrawBottomDown:
    lda #223        // Going Down Triangle
    ldy BottomRowPos
    jsr DrawPillar
    dec BottomRowPos
    jmp DrawBottomUpdate

DrawBottomUpdate:
    dec BottomCounter
    rts

DrawPillar:
    pha
    sty PillarRowPos
    lda #0
    sta BottomRowCounter
    ldx PillarXStart

!RowLooper:
    jsr Utils.GetScreenRowLocation

    ldy #39
    lda #160
    sta (zpScreenLocLo),y
    lda PillarColour
    sta (zpColourLocLo),y

LocationOfDEX_INX:
    dex                 // dex or inx
    inc BottomRowCounter
    lda BottomRowCounter
    cmp PillarRowPos
    bne !RowLooper-

    jsr Utils.GetScreenRowLocation

    pla
    ldy #39
    sta (zpScreenLocLo),y
    lda PillarColour
    sta (zpColourLocLo),y
    rts

PlaceSurfaceAssets:
    dex
    jsr Utils.GetScreenRowLocation
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

BuildTopScene:
    lda TopCounter
    beq BuildTopStart
    rts

BuildTopStart:
    lda TGLoc: TopGround
    sta TopCurrent
    and #%01111100
    lsr
    lsr
    sta TopCounter
    // clc
    // lda TGLoc
    // adc #1
    // sta TGLoc
    // bcc !ByPassInc+
    inc TGLoc
    bne !ByPassInc+
    inc TGLoc + 1
!ByPassInc:
    lda TopCurrent
    bpl !Continue+
    jsr ResetTopLocator
    // lda #<TopGround
    // sta TGLoc
    // lda #>TopGround
    // sta TGLoc + 1
    jmp BuildTopScene

!Continue:
    and #%00000011
    cmp #%00000000
    bne !Exit+
    lda TopCounter 
    sta TopRowPos
    lda #1
    sta TopCounter

!Exit:
    rts

ResetTopLocator:
    lda #<TopGround
    sta TGLoc
    lda #>TopGround
    sta TGLoc + 1
    rts

TopDraw:
    lda #GREEN
    sta PillarColour
    lda #2
    sta PillarXStart
    lda #$E8                // INX Instruction
    sta LocationOfDEX_INX
    lda TopCurrent
    and #%00000011
    cmp #%00000000
    bne DrawTopStay
    jmp !DrawTopStayExecute+

DrawTopStay:
    cmp #%00000001
    bne DrawTopUp
!DrawTopStayExecute:
    lda #160 //#228
    ldy TopRowPos
    jsr DrawPillar
    jmp DrawTopUpdate

DrawTopUp:
    cmp #%00000010
    bne DrawTopDown
    lda #105        // Going Up Triangle
    ldy TopRowPos
    jsr DrawPillar
    dec TopRowPos
    jmp DrawTopUpdate

DrawTopDown:
    inc TopRowPos
    lda #95        // Going Down Triangle
    ldy TopRowPos
    jsr DrawPillar
    jmp DrawTopUpdate

DrawTopUpdate:
    dec TopCounter
    rts

