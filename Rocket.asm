#importonce
#import "C64Constants.asm"
#import "Memory.asm"
#import "Utils.asm"

ScanForRockets:
    ldy ShipXValue
    iny
    iny
    sty ZeroPageTemp

    ldx #24
!RocketLooper:
    jsr GetScreenRowLocation
    ldy ZeroPageTemp
    lda (zpScreenLocLo),y
    cmp #30
    bne !NotARocket+

    ldy #MaxNoOfRockets - 1
!CheckRocketEmptyLoop:
    lda RocketXArray,y
    bpl !NotAvaliable+
    txa
    sta RocketYArray,y
    lda ZeroPageTemp 
    sta RocketXArray,y
    jmp !Exit+

!NotAvaliable:
    dey
    bpl !CheckRocketEmptyLoop-

!NotARocket:
    dex
    cpx #4
    bne !RocketLooper-
!Exit:
    rts

RemoveRocketsFromScreen:
    ldx #MaxNoOfRockets - 1

!RocketLooper:
    txa
    pha
    lda RocketXArray,x
    bmi !NoRocketFound+
    pha
    lda RocketYArray,x
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda #32
    sta (zpScreenLocLo),y
    lda #0
    sta (zpColourLocLo),y

!NoRocketFound:
    pla
    tax
    dex
    bpl !RocketLooper-
    rts

PlaceRocketToScreen:
    ldx #MaxNoOfRockets - 1

!RocketLooper:
    txa
    pha
    lda RocketXArray,x
    bmi !NoRocketFound+
    pha
    lda RocketYArray,x
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda #30
    sta (zpScreenLocLo),y
    lda #YELLOW
    sta (zpColourLocLo),y

!NoRocketFound:
    pla
    tax
    dex
    bpl !RocketLooper-
    rts

ChangeRocketsPosition:
    ldx #MaxNoOfRockets - 1

!RocketLooper:
    lda RocketXArray,x
    bmi !NoRocketFound+
    lda RocketYArray,x
    cmp #4
    bne !StillActive+
    lda #128
    sta RocketXArray,x
    bmi !NoRocketFound+

!StillActive:
    dec RocketYArray,x

!NoRocketFound:
    dex
    bpl !RocketLooper-
    rts

CheckRocketCollision:
    ldx #MaxNoOfRockets - 1

!RocketLooper:
    txa
    pha
    lda RocketXArray,x
    bmi !ThisIsASpace+
    pha
    lda RocketYArray,x
    tay
    pla
    pha
    tya
    tax
    jsr GetScreenRowLocation
    pla
    tay
    lda (zpScreenLocLo),y
    cmp #32                 
    beq !ThisIsASpace+
    cmp #30                 
    beq !ThisIsASpace+


    // Turn Off Rocket
    pla
    pha
    tax
    lda #128
    sta RocketXArray,x

!ThisIsASpace:
    pla
    tax
    dex
    bpl !RocketLooper-
    rts

