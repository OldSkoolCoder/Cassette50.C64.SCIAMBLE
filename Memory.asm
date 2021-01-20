#importonce

// Arrays
.label MaxNoOfBullets       = 5
.label BulletXArray         = $033C         // %00000000
                                            //  ^ ^^^^^^
                                            //  ! !!!!!! = X Position
                                            //  !
                                            //  ! = Allocatced
.label BulletYArray         = BulletXArray + MaxNoOfBullets
.label MaxNoOfBombs         = 3
.label BombXArray           = BulletYArray + MaxNoOfBullets
.label BombYArray           = BombXArray + MaxNoOfBombs
.label MaxNoOfRockets       = 5
.label RocketXArray         = BombYArray + MaxNoOfBombs
.label RocketYArray         = RocketXArray + MaxNoOfBombs
.label NextVar              = RocketYArray + MaxNoOfRockets


.label RowScreenLocationHi  = $D9
.label RowScreenLocationLo  = $ECF0
.label ScoreLoc             = $0409
.label FuelGaugeStart       = $042F

.label zpScreenLocLo        = $C1
.label zpColourLocLo        = $C3

.label BottomCounter        = $02A7
.label BottomRowPos         = BottomCounter + 1
.label BottomDataIndex      = BottomRowPos + 1
.label BottomCurrent        = BottomDataIndex + 1
.label BottomRowCounter     = BottomCurrent + 1

.label TopCounter        = BottomRowCounter + 1
.label TopRowPos         = TopCounter + 1
.label TopDataIndex      = TopRowPos + 1
.label TopCurrent        = TopDataIndex + 1
.label TopRowCounter     = TopCurrent + 1
.label SurfaceTargetsIndex = TopRowCounter + 1

.label ShipXValue        = SurfaceTargetsIndex + 1
.label ShipYValue        = ShipXValue + 1
.label ShipXDeltaValue   = ShipYValue + 1
.label ShipYDeltaValue   = ShipXDeltaValue + 1
.label ShipInputControl  = ShipYDeltaValue + 1
.label AreWeDeadYet      = ShipInputControl + 1
.label ShipsRemaining    = AreWeDeadYet + 1
.label Level             = ShipsRemaining + 1
.label Score             = Level + 1
.label FuelTank          = Score + 3


.const RocketChar       = 30
.const ShipChar         = 94
.const FuelChar         = 81


txtScoringLine:
    .byte 1,0  // X,Y
    .text "SCORE: 000000  HI: 000000 LV: 00 SH:00"
    .byte 0

txtFuelLine:
    .byte 1,1
    .text "FUEL:"
    .byte 0

XBarCharacters:
    .byte 32,101,116,117,97,246,234,231,160
