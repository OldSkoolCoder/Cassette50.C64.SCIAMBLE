#import "C64Constants.asm"
#import "Memory.asm"

BasicUpstart2(start)

start:
    lda #0
    sta BottomDataIndex
    sta BottomRowPos
    sta BottomCounter

GameLoop:
    jsr ScrollScreen
    jsr BuildScene
    jmp GameLoop



ScrollScreen:
    ldx #0
RowLooper:
    lda RowScreenLocationHi,x
    and #%00001111
    sta zpScreenLocLo + 1
    clc
    adc #$D4
    sta zpColourLocLo + 1
    lda RowScreenLocationLo,x
    sta zpScreenLocLo
    sta zpColourLocLo

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


// 3 Direction ... stay, up, down 00 01 10 11
//                                ^^ = Absolute
// # in that direction               ^^ Stay
//                                      ^^ Up
//                                         ^^ Down

// 000000 = # 11 = Direction

BuildScene:
    jsr BuildBottomScene
    rts

BuildBottomScene:
    lda BottomCounter
    bne BottomDraw

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
    jmp BottomDraw

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
    lda #227
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
    lda RowScreenLocationHi,x
    and #%00001111
    sta zpScreenLocLo + 1
    clc
    adc #$D4
    sta zpColourLocLo + 1
    lda RowScreenLocationLo,x
    sta zpScreenLocLo
    sta zpColourLocLo

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

    lda RowScreenLocationHi,x
    and #%00001111
    sta zpScreenLocLo + 1
    clc
    adc #$D4
    sta zpColourLocLo + 1
    lda RowScreenLocationLo,x
    sta zpScreenLocLo
    sta zpColourLocLo

    pla
    ldy #39
    sta (zpScreenLocLo),y
    lda #RED
    sta (zpColourLocLo),y
    rts
