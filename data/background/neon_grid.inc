;
; first_nes
; data/background/neon_grid.inc
;
; Original 32x30 nametable + 64-byte attribute table for the Neon Ranger demo scene.
; Tiles $40-$44 come from data/tiles/neon_ranger.inc.
;


DemoNametable:

; 24 rows of sparse neon "space-lab" sky. Two 32-tile rows repeat twelve times.
.REPEAT 12
.BYTE $00,$00,$00,$40,$00,$00,$00,$00, $00,$00,$41,$00,$00,$00,$00,$00
.BYTE $00,$00,$00,$00,$44,$00,$00,$00, $00,$40,$00,$00,$00,$00,$00,$00

.BYTE $00,$41,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$40,$00,$00
.BYTE $00,$00,$00,$00,$00,$00,$00,$41, $00,$00,$44,$00,$00,$00,$00,$00
.ENDREPEAT

; Six rows of cyber-floor. The ribbed row gives the room structure; the stripe row reads as a
; glowing floor when rendered with background palette 1.
.REPEAT 3
.BYTE $43,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$43
.BYTE $43,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$43

.REPEAT 32
.BYTE $42
.ENDREPEAT
.ENDREPEAT

; 64 attribute bytes. $55 selects background palette 1 for every 16x16-tile quadrant, giving the
; scene the same blue/cyan/magenta neon vocabulary as the character.
.REPEAT 64
.BYTE $55
.ENDREPEAT

; End of data/background/neon_grid.inc
