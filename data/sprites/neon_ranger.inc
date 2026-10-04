;
; first_nes
; data/sprites/neon_ranger.inc
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Define the initial four OAM entries that compose the original 16x16 Neon Ranger character.
;
; Beginner note: every NES hardware sprite uses four bytes in this order: Y position, CHR tile number,
; attribute byte, X position. Neon Ranger uses four 8x8 sprites arranged as a 2x2 square. The runtime
; player/animation code later updates these same OAM-shadow bytes every frame.
;


_SPRITES:
; =================================
;     Y     TILE  ATTR        X
; =================================

; --- BEGIN Neon Ranger ---
.BYTE 128,  $36,  %00000010,  128    ; Sprite 0: upper-left; sprite palette 2
.BYTE 128,  $37,  %00000010,  136    ; Sprite 1: upper-right; eight pixels to the right
.BYTE 136,  $38,  %00000010,  128    ; Sprite 2: lower-left; eight pixels below
.BYTE 136,  $39,  %00000010,  136    ; Sprite 3: lower-right
; --- END Neon Ranger ---

; End of data/sprites/neon_ranger.inc
