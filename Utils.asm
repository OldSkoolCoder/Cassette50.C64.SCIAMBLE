#importonce

#import "C64Constants.asm"
#import "Memory.asm"

// ========================================================================
// Prints Text at a certain point on the screen
// Inputs   : Acc = Low Byte of Target Text
//          : Y = Hi Byte of Target Text
// ========================================================================
PrintAtPoint:
    sta ZeroPageLow2
    sty ZeroPageHigh2
    ldy #0
    lda (ZeroPageLow2),y
    pha
    iny
    lda (ZeroPageLow2),y
    tax
    pla
    tay
    clc
    jsr krljmp_PLOT
    clc
    lda ZeroPageLow2
    adc #2
    sta ZeroPageLow2
    bcc !ByPassInc+
    inc ZeroPageHigh2
!ByPassInc:
    lda ZeroPageLow2
    ldy ZeroPageHigh2
    jmp bas_PrintString

// ========================================================================
// Inputs : Accumulator : Byte Value To Extract
// Outputs: XReg : Hi Nibble
//        : Acc : Lo Nibble
// ========================================================================
ExtractSingleByteDisplay:
    pha
    and #$F0        // hundred-thousands
    lsr
    lsr
    lsr
    lsr
    ora #$30        // -->ascii
    tax             // print on screen
    pla
    and #$0F        // ten-thousands
    ora #$30        // -->ascii
    rts        // print on next screen position

// ========================================================================
// Inputs : Accumulator : Byte Value To Extract
// Outputs: XReg : Hi Nibble
//        : Acc : Lo Nibble
// ========================================================================
ExtractSingleByte:
    pha
    and #$F0        // hundred-thousands
    lsr
    lsr
    lsr
    lsr
    tax             // print on screen
    pla
    and #$0F        // ten-thousands
    rts        // print on next screen position

DisplayScore:
    lda Score
    jsr ExtractSingleByteDisplay
    sta ScoreLoc + 5
    stx ScoreLoc + 4

    lda Score + 1
    jsr ExtractSingleByteDisplay
    sta ScoreLoc + 3
    stx ScoreLoc + 2

    lda Score + 2
    jsr ExtractSingleByteDisplay
    sta ScoreLoc + 1
    stx ScoreLoc + 0
    rts

// ========================================================================
// DisplayHiScore:
//     lda HiScore
//     jsr ExtractSingleByteDisplay
//     sta HiScoreLoc + 5
//     stx HiScoreLoc + 4

//     lda HiScore + 1
//     jsr ExtractSingleByteDisplay
//     sta HiScoreLoc + 3
//     stx HiScoreLoc + 2

//     lda HiScore + 2
//     jsr ExtractSingleByteDisplay
//     sta HiScoreLoc + 1
//     stx HiScoreLoc + 0

//     jmp DisplayBestLevel

// BestScore:
//     lda Score
//     cmp HiScore
//     beq !NextStage+
//     bcs !Exit+
//     jmp NewBestScore

// !NextStage:
//     lda Score + 1
//     cmp HiScore + 1
//     beq !NextStage+
//     bcs !Exit+
//     jmp NewBestScore

// !NextStage:
//     lda Score + 2
//     cmp HiScore + 2
//     bcs !Exit+

// NewBestScore:
//     lda Score
//     sta HiScore
//     lda Score + 1
//     sta HiScore + 1
//     lda Score + 2
//     sta HiScore + 2

//     lda LevelBDC
//     sta BestLevelBDC
// !Exit:
//     rts

// $AB1E = Prints Text From Location A = LoByte Y = Hi Byte
// $FFF0
// ------------------------------------------------------------
// Inputs : Acc = 00 = Tens and Ones
//        : Y   = 00xx = Thousands and Hundreds

AddingScore:
    sed             // set decimal mode
    clc
    adc Score       // ones and tens
    sta Score
    tya
    adc Score + 1   // hundreds and thousands
    sta Score + 1
    lda Score + 2   // ten-thousands and hundred-thousands
    adc #00
    sta Score + 2
    cld
    rts

InitXBar:
    ldx #0
!LOOP:
    lda #160
    sta FuelGaugeStart,x
    inx
    cpx #31
    bne !LOOP-
    rts

ShowXBar:
    lda FuelTank
    lsr                 // Divide By 2
    lsr                 // Divide By 4
    lsr                 // Divide By 8
    tax
    tay
    lda FuelTank
    and #%00000111
    pha
!Looper:
    lda #160
    sta FuelGaugeStart,y        // Blank out last location
    dey
    bpl !Looper-
    txa
    tay
    pla
    tax
    lda XBarCharacters,x
    //ora #$80
    sta FuelGaugeStart,y        // Blank out last location
    rts