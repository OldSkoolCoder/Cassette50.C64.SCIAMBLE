#importonce
#import "C64Constants.asm"
#import "Memory.asm"
#import "Bullet.asm"

*=* "BombCode"
.namespace Bomb 
{
    RemoveFromScreen:
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

    PlaceToScreen:
        lda #128
        sta BombActive
        ldx #MaxNoOfBombs - 1

    !BombLooper:
        txa
        pha
        lda BombXArray,x
        bmi !NoBombFound+
        pha
        lda #0
        sta BombActive
        lda BombYArray,x
        tax
        jsr SID.BombSFX
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
        lda BombActive
        bpl !Exit+
        jsr SID.TurnOffVoice1
    !Exit:
        rts

    ChangePosition:
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

    CheckCollision:
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
        jsr Bullet.CheckLocationForPoints
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
}

