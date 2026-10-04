;
; first_nes
; data/palette/example.inc
;
; Palette data for an NES ROM.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
;
; Based on the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
;   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
; Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
;   http://fms.komkon.org/EMUL8/NES.html
; Based on "Nintendo Entertainment System Documentation", by Jeremy Chadwick:
;   https://emu-docs.org/NES/nestech.txt
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: ca65 (cc65 binutils)
;


_PALETTE:

; Background palettes
.BYTE $0f, $31, $32, $33
.BYTE $0f, $21, $2c, $24            ; neon blue / cyan / magenta scene accents
.BYTE $0f, $39, $3a, $3b
.BYTE $0f, $3d, $3e, $0f

; Sprite palettes (selected by sprite attribute bits 0-1)
.BYTE $0f, $1c, $15, $14
.BYTE $0f, $02, $38, $3c
.BYTE $0f, $21, $2c, $24            ; Neon Ranger: blue / cyan / magenta
.BYTE $0f, $0f, $0f, $0f

; End of data/palette/example.inc
