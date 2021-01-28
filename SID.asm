#importonce
#import "C64Constants.asm"
#import "Memory.asm"

//* =$033C "SID Code"
*=* "SID Code"
.namespace SID
{
    SetVolume:
        sta SID_SIGVOL
        rts

    //---------------------------------------------------------------------------
    // Input : YReg = Voice Number
    //----------------------------------------------------------------------------
    SetUpVoice:
        dey
        tya
        asl
        asl
        asl
        tay
        lda #128
        sta SID_PWLO1,y
        lda #8
        sta SID_PWHI1,y
        lda #53
        sta SID_ATDCY1,y
        lda #102
        sta SID_SUREL1,y
        lda #0
        sta SID_FRELO1,y
        rts

    //--------------------------------------------------------------------------
    // Input : XReg : BombYPosition
    //--------------------------------------------------------------------------
    BombSFX:
        lda #0
        sta SID_VCREG1
        ldy #1
        jsr SetUpVoice
        txa
        asl
        asl
        asl
        sta ZeroPageParam9
        lda #200
        sec
        sbc ZeroPageParam9
        sta SID_FREHI1
        lda #17
        sta SID_VCREG1
        rts

    TurnOffVoice1:
        lda #0
        sta SID_VCREG1
        rts

    LaserSFX:
        ldy #2
        jsr SetUpVoice
        lda #105
        sta SID_SUREL2
        lda #71
        sta SID_FRELO2
        lda #5
        sta SID_FREHI2
        lda #81
        sta SID_VCREG2
        rts

    TurnOffVoice2:
        lda #0
        sta SID_VCREG2
        rts

    WeaponExplosionSFX:
        ldy #3
        jsr SetUpVoice
        lda #105
        sta SID_SUREL3
        lda #145
        sta SID_FRELO3
        lda #01
        sta SID_FREHI3
        lda #129
        sta SID_VCREG3
        rts

    TurnOffVoice3:
        lda #0
        sta SID_VCREG3
        rts

    ShipExplosionSFX:
        ldy #3
        jsr SetUpVoice
        lda #107
        sta SID_SUREL3
        lda #145
        sta SID_FRELO3
        lda #01
        sta SID_FREHI3
        lda #129
        sta SID_VCREG3
        dec SID_VCREG3
        rts
}

