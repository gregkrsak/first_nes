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
; Tested with:
;  make
;  nestopia first_nes.nes
;
; Tested on:
;  - Linux with Nestopia UE 1.47
;  - Windows with Nestopia UE 1.48
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the ca65 assembler, try these references:
; https://github.com/cc65/cc65
; http://cc65.github.io/doc/ca65.html
;


_PALETTE:

; Background palettes
.BYTE $0f, $31, $32, $33
.BYTE $0f, $35, $36, $37
.BYTE $0f, $39, $3a, $3b
.BYTE $0f, $3d, $3e, $0f

 ; Sprite palettes (selected by the attribute bits 0-1 of the sprites)
.BYTE $0f, $1c, $15, $14
.BYTE $0f, $02, $38, $3c
.BYTE $0f, $30, $37, $1a  ; Luigi-like colors
.BYTE $0f, $0f, $0f, $0f  ; All black

; End of data/palette/example.inc
