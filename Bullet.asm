#importonce
#import "C64Constants.asm"
#import "Memory.asm"
#import "Utils.asm"
#import "SID.asm"

*=* "Bullet Code"
.namespace Bullet 
{
    RemoveFromScreen:
        ldx #MaxNoOfBullets - 1

    !BulletLooper:
        txa
        pha
        lda BulletXArray,x
        bmi !NoBulletFound+
        pha
        lda BulletYArray,x
        tax
        jsr Utils.GetScreenRowLocation
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

    PlaceToScreen:
        lda #128
        sta BombActive
        ldx #MaxNoOfBullets - 1

    !BulletLooper:
        txa
        pha
        lda BulletXArray,x
        bmi !NoBulletFound+
        pha
        lda #0
        sta BombActive
        lda BulletYArray,x
        tax
        jsr SID.LaserSFX
        jsr Utils.GetScreenRowLocation
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
        lda BombActive
        bpl !Exit+
        jsr SID.TurnOffVoice2
    !Exit:
        rts

    ChangePosition:
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

    CheckCollision:
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
        jsr Utils.GetScreenRowLocation
        pla
        tay
        lda (zpScreenLocLo),y
        cmp #30                 // Rocket
        bne !NotTheRocket+
        lda #$00
        ldy #$01
        jsr Utils.AddingScore
        jmp !NotTheSpace+

    !NotTheRocket:
        cmp #94
        bne !NotTheShips+
        lda #$50
        ldy #$00
        jsr Utils.AddingScore
        jmp !NotTheSpace+

    !NotTheShips:
        cmp #81
        bne !NotTheFuel+
        jsr SID.WeaponExplosionSFX
        lda #24
        clc
        adc FuelTank
        bcc !Exit+
        lda #248
    !Exit:
        sta FuelTank
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
}
