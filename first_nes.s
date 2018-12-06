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


; =================================================================================================
;  Common include files for NES development. These files are not specific to this project. You
;  should study each of them, individually.
; =================================================================================================

; CPU-Specific directives
.INCLUDE "lib/shared_code/cpu.inc"

; Audio-specific directives
.INCLUDE "lib/shared_code/apu.inc"

; Video-specific directives
.INCLUDE "lib/shared_code/ppu.inc"

; Joystick-specific directives
.INCLUDE "lib/shared_code/controllers.inc"


; =================================================================================================
;  Environment-specific metadata
; =================================================================================================

; iNES File header, used by NES emulators
.SEGMENT "HEADER"
.INCLUDE "data/header/ines_simple.inc"


; =================================================================================================
;  ROM (PRG) Data
; =================================================================================================

; Palette data
.SEGMENT "PALETTE"
.INCLUDE "data/palette/example.inc"


; Sprite data
.SEGMENT "SPRITES"
.INCLUDE "data/sprites/small_luigi.inc"


; =================================================================================================
;  VROM (CHR) Data
; =================================================================================================

; Graphics tile data, used by the sprites
.SEGMENT "TILES"
.INCBIN "data/tiles/smb1_chr.bin"


; =================================================================================================
;  ROM Code. Your NES game will be driven by three interrupt service routines, from which you will
;  call other procedures that are stored in seperate libraries (see the /lib project directory).
; =================================================================================================

.SEGMENT "CODE"

; Interrupt service routines
.INCLUDE "lib/isr/poweron_reset.s"
.INCLUDE "lib/isr/vertical_blank.s"
.INCLUDE "lib/isr/custom.s"

; Non-project-specific libraries. These may be shared across projects.
.INCLUDE "lib/shared_code/cpu.s"
.INCLUDE "lib/shared_code/apu.s"
.INCLUDE "lib/shared_code/ppu.s"

; YOUR LIBRARY FILES GET INCLUDED HERE
; <libraries>
.INCLUDE "lib/sprite/basic_movement.s"
; </libraries>


; =================================================================================================
;  Interrupt Vector Table. Each of these three 16 (sixteen) bit addresses points to a procedure
;  that is called automatically by the NES hardware.
; =================================================================================================

.SEGMENT "VECTORS"

; These addresses must be in this order
.WORD ISR_Vertical_Blank
.WORD ISR_PowerOn_Reset
.WORD ISR_Custom

; End of first_nes.s
