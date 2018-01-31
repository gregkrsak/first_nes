;
; first_nes
; first_nes.s
;
; A "starter" assembly language game for the Nintendo Entertainment System.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
;
; Based on the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
;   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
; Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
;   http://fms.komkon.org/EMUL8/NES.html
; Based on "Nintendo Entertainment System Documentation", by an unknown author:
;   https://emu-docs.org/NES/nestech.txt
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: ca65 (cc65 binutils)
;
; Tested with:
;  ca65 first_nes.s
;  ld65 first_nes.o -C config/ines.cfg
;  cat bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin > first_nes.nes
;  rm a.out && rm first_nes.o
;  nestopia first_nes.nes
;
; Tested on:
;  Nestopia UE 1.47
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the ca65 assembler, try these references:
; https://github.com/cc65/cc65
; http://cc65.github.io/doc/ca65.html
;


; =================================================================================================
;  Common include files for NES development. These files are not specific to this project. You
;  should study each of them, individually.
; =================================================================================================


; CPU-Specific directives
.INCLUDE "shared_code/cpu.inc"

; Audio-specific directives
.INCLUDE "shared_code/apu.inc"

; Video-specific directives
.INCLUDE "shared_code/ppu.inc"

; Joystick-specific directives
.INCLUDE "shared_code/controllers.inc"



; =================================================================================================
;  ROM (PRG) DATA
; =================================================================================================


; iNES File header, used by NES emulators
.SEGMENT "HEADER"
.INCLUDE "data/header/ines_simple.inc"


; Palette data
.SEGMENT "PALETTE"
.INCLUDE "data/palette/example.inc"


; Sprite data
.SEGMENT "SPRITES"
.INCLUDE "data/sprites/small_mario.inc"


; =================================================================================================
;  VROM (CHR) DATA
; =================================================================================================


; Graphics tile data, used by the sprites
.SEGMENT "TILES"
.INCBIN "data/tiles/smb1_chr.bin"


; =================================================================================================
;  ROM CODE
; =================================================================================================

.SEGMENT "CODE"

; Interrupt service routines
.INCLUDE "lib/isr/poweron_reset.s"
.INCLUDE "lib/isr/vertical_blank.s"
.INCLUDE "lib/isr/custom.s"

; Your library files get included here
.INCLUDE "lib/sprite/basic_movement.s"


; =================================================================================================
;  INTERRUPT VECTOR TABLE
; =================================================================================================

.SEGMENT "VECTORS"

; These addresses must be in this order
.WORD ISR_Vertical_Blank
.WORD ISR_PowerOn_Reset
.WORD ISR_Custom


; End of first_nes.s
