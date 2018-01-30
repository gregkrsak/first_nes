;
; first_nes
; rom_header_ines_simple.inc
;
; iNES Extended (simple) assembler directives for Nintendo Entertainment System assembly language.
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


;
; Extended iNES file header
;

  ; 'N', 'E', 'S', $1a

  .INESCHR $01                      ; 1x 8KB VROM (CHR)
  
  .INESPRG $01                      ; 1x 16KB ROM (PRG)
  
  .INESMAP %0000                    ; Mapper 0 == No mapping (a simple 16KB PRG + 8KB CHR game)
  
  .INESMIR %0001                    ; Mirroring 1 == Vertical mirroring only
  
  ; $00, $00, $00, $00, $00, $00, $00, $00, $00


; End of rom_header_ines_simple.inc
