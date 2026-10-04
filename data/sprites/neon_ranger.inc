;
; first_nes
; data/sprites/neon_ranger.inc
;
; OAM shadow data for the original 16x16 "Neon Ranger" demo character.
;
; Four 8x8 hardware sprites compose one 16x16 character. Attribute bits 0-1 select sprite palette 2,
; which is the project's blue/cyan/magenta neon palette.
;


_SPRITES:
; =================================
;     Y     TILE  ATTR        X
; =================================

; --- BEGIN Neon Ranger ---
.BYTE 128,  $36,  %00000010,  128    ; upper-left
.BYTE 128,  $37,  %00000010,  136    ; upper-right
.BYTE 136,  $38,  %00000010,  128    ; lower-left
.BYTE 136,  $39,  %00000010,  136    ; lower-right
; --- END Neon Ranger ---

; End of data/sprites/neon_ranger.inc
