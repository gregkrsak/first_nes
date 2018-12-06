;
; first_nes
; lib/shared_code/cpu.inc
;
; CPU-Related assembler directives for Nintendo Entertainment System assembly language.
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


;
; The NES's 6502 does not contain support for decimal mode. Both the
; CLD and SED opcodes function normally, but the 'd' bit of P is unused
; in both ADC and SBC. It is common practice for games to CLD prior to
; code execution, as the status of 'd' is unknown on power-on and on
; reset.
; 
; Audio registers are mapped internal to the CPU; all waveform gener-
; ation is done internal to the CPU as well.
;


;
; CPU MEMORY MAP
;
; --------------------------------------- $10000
; Upper Bank of Cartridge ROM
; --------------------------------------- $C000
; Lower Bank of Cartridge ROM
; --------------------------------------- $8000
; Cartridge RAM (may be battery-backed)
; --------------------------------------- $6000
; Expansion Modules
; --------------------------------------- $5000
; Input/Output
; --------------------------------------- $2000
; 2kB Internal RAM, mirrored 4 times
; --------------------------------------- $0000
;


_RAM_CLEAR_PATTERN_1	= $00
_RAM_CLEAR_PATTERN_2	= $FE

; End of lib/shared_code/cpu.inc
