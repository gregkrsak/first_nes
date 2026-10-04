;
; first_nes
; data/tiles/neon_ranger.inc
;
; Original CHR tile data for the first_nes demo.
;
; "Neon Ranger" was created for this project in 2026. The design and tile data are original and may
; be used under the same license as first_nes. Two 16x16 character frames are provided, followed by
; a handful of tiny sci-fi background tiles for the demo scene.
;
; NES CHR tiles are 8x8 pixels, 2 bits per pixel: 8 bytes of low bit-plane data followed by 8 bytes
; of high bit-plane data.
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
;  ORIGINAL BACKGROUND TILES ($40-$44)
; =================================================================================================

; $40 - tiny star
.BYTE $00, $10, $10, $7C, $10, $10, $00, $00
.BYTE $00, $00, $00, $00, $00, $00, $00, $00

; $41 - circuit trace
.BYTE $00, $20, $38, $08, $0E, $02, $00, $00
.BYTE $00, $00, $00, $00, $00, $00, $00, $00

; $42 - neon floor stripe
.BYTE $FF, $00, $FF, $00, $FF, $00, $FF, $00
.BYTE $00, $FF, $00, $00, $00, $FF, $00, $00

; $43 - pillar / wall rib
.BYTE $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3
.BYTE $00, $00, $00, $00, $00, $00, $00, $00

; $44 - sparkle / portal glint
.BYTE $00, $81, $42, $24, $18, $24, $42, $81
.BYTE $00, $00, $00, $00, $00, $00, $00, $00

; Remaining CHR space is filled with $00 by the linker configuration.
;
; End of data/tiles/neon_ranger.inc
