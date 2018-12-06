;
; first_nes
; lib/shared_code/controllers.inc
;
; Joystick-related assembler directives for Nintendo Entertainment System assembly language.
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


; Two NES controllers are accessed via memory locations $4016 and $4017, respectively.
_JOY1       = $4016
_JOY2       = $4017

; End of lib/shared_code/controllers.inc
