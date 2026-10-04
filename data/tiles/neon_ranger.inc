;
; first_nes
; data/tiles/neon_ranger.inc
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Define the original CHR tile graphics for Neon Ranger, the platformer chamber, and the
;          character's standing, stepping, jumping, and falling poses.
;
; "Neon Ranger" was created for this project in 2026. The design and tile data are original and may
; be used under the same license as first_nes.
;
; Beginner note: every NES CHR tile is 8x8 pixels at 2 bits per pixel. Each tile therefore uses 16
; bytes: eight bytes for bit-plane 0 followed by eight bytes for bit-plane 1. Together the two bits
; select one of four palette entries for every pixel.
;


; -------------------------------------------------------------------------------------------------
; Tiles $00-$35: intentionally blank. Keeping the demo sprite at the historical $36 start means old
; explanations of four-tile sprite composition remain easy to compare with earlier versions.
; -------------------------------------------------------------------------------------------------

.REPEAT $0360
.BYTE $00
.ENDREPEAT


; =================================================================================================
;  NEON RANGER - standing frame ($36-$39)
;
;  .....BBBBBB.....
;  ...BCCCCCCCB....
;  ..BCCMMMMMCCB...
;  ..BCMMMMMMMBC...
;  ..BCCMMMMMCCB...
;  ...BCCCCCCCB....
;  ....BBBBBBB.....
;  ...BBBCCCBBB....
;  ..BBBCCCCCCBBB..
;  .BBBCCBBCCCBBB..
;  .BBBCCBBCCCBBB..
;  ..BBCCBBCCBB....
;  ..BBCCCCCCBB....
;  ..BBB.BB.BBB....
;  .BBB..BB..BBB...
;  .BB...BB...BB...
;
;  B = blue suit, C = cyan armor, M = magenta visor
; =================================================================================================

; $36 - upper-left
.BYTE $07, $10, $27, $2F, $27, $10, $0F, $1C
.BYTE $00, $0F, $1F, $1F, $1F, $0F, $00, $03

; $37 - upper-right
.BYTE $E0, $10, $C8, $E8, $C8, $10, $E0, $70
.BYTE $00, $E0, $F0, $F0, $F0, $E0, $00, $80

; $38 - lower-left
.BYTE $38, $73, $73, $33, $30, $3B, $73, $63
.BYTE $07, $0C, $0C, $0C, $0F, $00, $00, $00

; $39 - lower-right
.BYTE $38, $1C, $1C, $30, $30, $70, $38, $18
.BYTE $C0, $E0, $E0, $C0, $C0, $00, $00, $00


; =================================================================================================
;  NEON RANGER - step frame ($3A-$3D)
;  Helmet/torso stay readable while the lower tiles shift the stance for a tiny two-frame walk.
; =================================================================================================

; $3A - upper-left
.BYTE $07, $10, $27, $2F, $27, $10, $0F, $1C
.BYTE $00, $0F, $1F, $1F, $1F, $0F, $00, $03

; $3B - upper-right
.BYTE $E0, $10, $C8, $E8, $C8, $10, $E0, $70
.BYTE $00, $E0, $F0, $F0, $F0, $E0, $00, $80

; $3C - lower-left (stepping)
.BYTE $38, $73, $73, $33, $30, $3B, $31, $70
.BYTE $07, $0C, $0C, $0C, $0F, $00, $00, $00

; $3D - lower-right (stepping)
.BYTE $38, $1C, $1C, $30, $30, $70, $B8, $C0
.BYTE $C0, $E0, $E0, $C0, $C0, $00, $00, $00


; Tiles $3E-$3F: blank spacer tiles.
.REPEAT $20
.BYTE $00
.ENDREPEAT


; =================================================================================================
;  NEON INDUSTRIAL PLATFORMER TILES ($40-$49)
;  Background palette 1 maps pixel values 1/2/3 to blue/cyan/magenta.
; =================================================================================================

; $40 - glowing platform/floor surface
.BYTE $00, $FF, $FF, $81, $BD, $99, $A5, $FF
.BYTE $FF, $FF, $00, $00, $00, $00, $00, $00

; $41 - vertical structural support with magenta couplers
.BYTE $24, $24, $3C, $24, $24, $3C, $24, $24
.BYTE $18, $18, $18, $18, $18, $18, $18, $18

; $42 - framed wall panel
.BYTE $FF, $81, $81, $99, $99, $81, $81, $FF
.BYTE $00, $7E, $42, $5A, $5A, $42, $7E, $00

; $43 - cyan/magenta energy lamp
.BYTE $00, $24, $5A, $BD, $BD, $5A, $24, $00
.BYTE $00, $18, $3C, $7E, $7E, $3C, $18, $00

; $44 - horizontal conduit / pipe
.BYTE $00, $FF, $00, $18, $00, $FF, $00, $00
.BYTE $00, $00, $FF, $18, $FF, $00, $00, $00

; $45 - diamond-shaped technology panel
.BYTE $81, $42, $24, $18, $18, $24, $42, $81
.BYTE $00, $00, $18, $18, $18, $18, $00, $00

; $46 - heavy floor plating
.BYTE $FF, $99, $81, $BD, $81, $99, $FF, $00
.BYTE $00, $00, $3C, $3C, $3C, $00, $00, $00

; $47 - magenta hazard chevrons
.BYTE $88, $44, $22, $11, $88, $44, $22, $11
.BYTE $88, $44, $22, $11, $88, $44, $22, $11

; $48 - cyan vent/grille inset
.BYTE $FF, $81, $81, $81, $81, $81, $FF, $00
.BYTE $00, $24, $24, $24, $24, $24, $00, $00

; $49 - reinforced ceiling/bottom beam
.BYTE $FF, $00, $81, $FF, $81, $00, $FF, $00
.BYTE $00, $FF, $00, $7E, $00, $FF, $00, $00


; =================================================================================================
;  NEON RANGER - airborne lower-body poses ($4A-$4D)
;  The upper half reuses standing tiles $36/$37. Only the legs change, saving four CHR tiles.
; =================================================================================================

; Jump/tuck lower half:
;  ..BBBCCCCCCBBB..
;  .BBBCCBBBBCCBBB.
;  .BBBCCBBBBCCBBB.
;  ..BBCCCCCCCCBB..
;  ...BBBBBBBB.....
;  ....BB..BB......
;  ...BBB..BBB.....
;  ....BBBBBB......
;
; $4A - jump lower-left
.BYTE $38, $73, $73, $30, $1F, $0C, $1C, $0F
.BYTE $07, $0C, $0C, $0F, $00, $00, $00, $00

; $4B - jump lower-right
.BYTE $1C, $CE, $CE, $0C, $E0, $C0, $E0, $C0
.BYTE $E0, $30, $30, $F0, $00, $00, $00, $00

; Falling/spread lower half:
;  ..BBBCCCCCCBBB..
;  .BBBCCBBBBCCBBB.
;  .BBBCCBBBBCCBBB.
;  ..BBCCCCCCCCBB..
;  ..BBCCCCCCBB....
;  ..BBB....BBB....
;  .BBB......BBB...
;  BBB........BBB..
;
; $4C - fall lower-left
.BYTE $38, $73, $73, $30, $30, $38, $70, $E0
.BYTE $07, $0C, $0C, $0F, $0F, $00, $00, $00

; $4D - fall lower-right
.BYTE $1C, $CE, $CE, $0C, $30, $70, $38, $1C
.BYTE $E0, $30, $30, $F0, $C0, $00, $00, $00

; Remaining CHR space is filled with $00 by the linker configuration.
;
; End of data/tiles/neon_ranger.inc
