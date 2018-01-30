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
; (untested)
;
; Tested on:
; (untested)
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the ca65 assembler, try these references:
; https://github.com/cc65/cc65
; http://cc65.github.io/doc/ca65.html
;


; =================================================================================================
; Non-project-specific helper files. You should study each of these, individually.
; =================================================================================================

  ; CPU-Specific directives
  .INCLUDE "common/cpu.inc"

  ; Audio-specific directives
  .INCLUDE "common/apu.inc"

  ; Graphics-specific directives
  .INCLUDE "common/ppu.inc"

  ; Joystick-specific directives
  .INCLUDE "common/controllers.inc"

  ; The ROM header
  .INCLUDE "common/rom_header_ines_simple.inc"

  ; The interrupt vector table
  .INCLUDE "common/int_vector_table_simple.inc"


; =================================================================================================
; Main Program subroutines and data. These will be called by the ISRs.
; =================================================================================================

  .INCLUDE "library.s"


; =================================================================================================
; Main Program Interrupt Service Routines. Called by the NES hardware, in an event-driven manner.
; These ISRs are the main, high-level code blocks of the program.
; =================================================================================================

  ; Called at system power-on or reset
  .INCLUDE "isr/reset.s"

  ; Called when the current graphics frame has finished drawing
  .INCLUDE "isr/vertical_blank.s"

  ; Called when a "break" opcode is executed
  .INCLUDE "isr/break.s"


; End of first_nes.s
