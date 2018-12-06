;
; first_nes
; data/header/ines_simple.inc
;
; ROM Header information required to output an iNES-format (.NES) file. This type of ROM file is
; commonly used by NES emulators, but is generally unsuitable for hardware cartridges. While iNES
; supports much larger ROM/VROM configurations, this is a "simple" header that only supports 1
; (one) 16K PRG and 1 (one) 8K CHR.
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


.BYTE   "NES", $1a
.BYTE   $01           ; 1x 8KB VROM (CHR)
.BYTE   $01           ; 1x 16KB ROM (PRG)
.BYTE   %00000001     ; Mapper nibble 0000 == No mapping (a simple 16KB PRG + 8KB CHR game)
                      ; Mirroring nibble 0001 == Vertical mirroring only

;
; NOTE: The remainder of the header should be zero-padded to $10 (sixteen) bytes. This
; should generally be accomplished by a linker (vs. doing it in code) if possible.
;


; End of data/header/ines_simple.inc
