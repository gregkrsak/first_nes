;
; first_nes
; first_nes.asm
;
; A "starter" assembly language game for the Nintendo Entertainment System.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, Feb. 2017
;
; Based on the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
;   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
; Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
;   http://fms.komkon.org/EMUL8/NES.html
; Based on "Nintendo Entertainment System Documentation", by an unknown author:
;   https://emu-docs.org/NES/nestech.txt
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: NESASM 3.1
;
; Tested with:
; nesasm3 "first_nes.asm"
;
; Tested on:
; Nestopia 1.40
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the NESASM assembler, try these references:
; http://www.nespowerpak.com/nesasm/usage.txt
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

  .INCLUDE "library.asm"


; =================================================================================================
; Main Program Interrupt Service Routines. Called by the NES hardware, in an event-driven manner.
; These ISRs are the main, high-level code blocks of the program.
; =================================================================================================

  ; Called at system power-on or reset
  .INCLUDE "isr/reset.asm"

  ; Called when the current graphics frame has finished drawing
  .INCLUDE "isr/vertical_blank.asm"

  ; Called when a "break" opcode is executed
  .INCLUDE "isr/break.asm"


; End of first_nes.asm
