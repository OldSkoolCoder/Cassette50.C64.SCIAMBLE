*=$0120
entry:
  ldx #$1f
  txs
  jmp start
  
  *=$01f8
  .byte <[entry-1], >[entry-1]
  
*=$0200
// Space for stuff
  
*=$028f
  .byte $48,$eb // Keep keyboard matrix
  
*=$0314
  .byte $31, $ea, $66, $fe, $47, $fe
  // Keep following vectors
  .byte $4a, $f3, $91, $f2, $0e, $f2
  .byte $50, $f2, $33, $f3, $57, $f1
  .byte $ca, $f1, $ed, $f6 // STOP vector - Essential to avoid JAM

*=$0400
  .fill 1000,$20

*=$0801
init:
#import "SideScroller.asm"