;
; cpu.inc
;
; CPU-Related assembler directives for Nintendo Entertainment System assembly language.
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


; End of cpu.inc
