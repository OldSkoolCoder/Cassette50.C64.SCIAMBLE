#importonce

.label RowScreenLocationHi  = $D9
.label RowScreenLocationLo  = $ECF0

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


.const RocketChar       = 30
.const ShipChar         = 94
.const FuelChar         = 81