;
; first_nes
; data/palette/example.inc
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Define the 32 palette bytes copied to NES PPU palette RAM at $3F00 during reset.
;
; Beginner note: the first 16 bytes are four background palettes; the second 16 bytes are four
; sprite palettes. Each palette contains four NES color indices. Sprite attribute bits 0-1 select
; which sprite palette a hardware sprite uses.
;


_PALETTE:

; Background palette 0
.BYTE $0f, $31, $32, $33

; Background palette 1 - used by the Neon Ranger chamber: blue / cyan / magenta
.BYTE $0f, $21, $2c, $24

; Background palette 2
.BYTE $0f, $39, $3a, $3b

; Background palette 3
.BYTE $0f, $3d, $3e, $0f


; Sprite palette 0
.BYTE $0f, $1c, $15, $14

; Sprite palette 1
.BYTE $0f, $02, $38, $3c

; Sprite palette 2 - selected by Neon Ranger: blue / cyan / magenta
.BYTE $0f, $21, $2c, $24

; Sprite palette 3 - currently unused/black
.BYTE $0f, $0f, $0f, $0f

; End of data/palette/example.inc
