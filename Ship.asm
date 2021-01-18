#import "C64Constants.asm"
#import "Memory.asm"

RemoveShipFromScreen:
    ldx ShipYValue
    jsr GetScreenRowLocation
    ldy ShipXValue
    lda #32
    sta (zpScreenLocLo),y
    iny
    sta (zpScreenLocLo),y
    iny
    sta (zpScreenLocLo),y
    iny
    sta (zpScreenLocLo),y

    ldy ShipXValue
    lda #0
    sta (zpColourLocLo),y
    iny
    sta (zpColourLocLo),y
    iny
    sta (zpColourLocLo),y
    iny
    sta (zpColourLocLo),y
    rts

PlaceShipToScreen:
    ldx ShipYValue
    jsr GetScreenRowLocation
    ldy ShipXValue
    lda #62
    sta (zpScreenLocLo),y
    lda #ORANGE
    sta (zpColourLocLo),y
    iny
    lda #252
    sta (zpScreenLocLo),y
    lda #YELLOW
    sta (zpColourLocLo),y
    iny
    lda #62
    sta (zpScreenLocLo),y
    lda #YELLOW
    sta (zpColourLocLo),y
    iny
    lda #61
    sta (zpScreenLocLo),y
    lda #RED
    sta (zpColourLocLo),y
    rts

ChangeShipsPosition:
    lda ShipXValue
    clc
    adc ShipXDeltaValue
    sta ShipXValue

    lda ShipYValue
    clc
    adc ShipYDeltaValue
    sta ShipYValue

    lda #0
    sta ShipXDeltaValue
    sta ShipYDeltaValue

    ldx ShipYValue
    jsr GetScreenRowLocation
    ldy ShipXValue
    lda (zpScreenLocLo),y
    iny
    ora (zpScreenLocLo),y
    iny
    ora (zpScreenLocLo),y
    iny
    ora (zpScreenLocLo),y 
    and #%11011111
    beq !Exit+
    lda #128
    sta AreWeDeadYet

!Exit:
    rts

ShipControl:
    lda CIAPRA
    eor #$FF                // Inverts the Bits
    and #%00011111          // Mask Off only important Bits
    sta ShipInputControl

    cmp #0
    bne !IsItUp+
    lda ShipXValue
    cmp #1
    bne !ByPassJump+
    jmp !ExitControlFunction+
!ByPassJump:
    lda #255
    sta ShipXDeltaValue
    jmp !ExitControlFunction+

!IsItUp:
    lda ShipInputControl

    and #joystickUp
    cmp #joystickUp
    bne !IsItDown+
    lda ShipYValue
    cmp #03
    beq !IsItDown+
    lda #255
    sta ShipYDeltaValue

!IsItDown:
    lda ShipInputControl

    and #joystickDown
    cmp #joystickDown
    bne !IsItRight+
    lda ShipYValue
    cmp #23
    beq !IsItRight+
    lda #1
    sta ShipYDeltaValue

!IsItRight:
    lda ShipInputControl

    and #joystickRight
    cmp #joystickRight
    bne !IsItLeft+
    lda ShipXValue
    cmp #30
    beq !IsItLeft+
    lda #1
    sta ShipXDeltaValue

!IsItLeft:
    lda ShipInputControl

    and #joystickLeft
    cmp #joystickLeft
    bne !IsItFire+

    ldx #MaxNoOfBombs - 1
!CheckAvaliableArray:
    lda BombXArray,x
    bpl !NextBomb+
    lda ShipXValue
    clc
    adc #1
    sta BombXArray,x
    lda ShipYValue
    clc
    adc #1
    sta BombYArray,x
    jmp !ExitControlFunction+

!NextBomb:
    dex
    bpl !CheckAvaliableArray-

!IsItFire:
    lda ShipInputControl

    and #joystickFire
    cmp #joystickFire
    bne !ExitControlFunction+

    ldx #MaxNoOfBullets - 1
!CheckAvaliableArray:
    lda BulletXArray,x
    bpl !NextBullet+
    lda ShipXValue
    clc
    adc #4
    sta BulletXArray,x
    lda ShipYValue
    sta BulletYArray,x
    jmp !ExitControlFunction+

!NextBullet:
    dex
    bpl !CheckAvaliableArray-

!ExitControlFunction:
    rts


// 0 - Scroring Row
// 1 - Title
// 2 - Solid Line
// 3 - First Row of Ship