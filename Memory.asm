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