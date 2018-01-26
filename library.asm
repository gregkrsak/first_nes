;
; first_nes
; library.asm
;
; This is the data and subroutine library used by the ISRs of the first_nes project.
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


  .DATA

  .BANK 1
  .ORG $e000


; --- BEGIN Color palette ---
DATAPalette:
  .DB $0f, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $0f
  .DB $0f, $1c, $15, $14, $31, $02, $38, $3c, $0f, $1c, $15, $14, $31, $02, $38, $3c
ENDDATAPalette:
; --- END Color palette ---


; --- BEGIN Sprite definitions ---
DATASprites:
  ;   VERT TILE ATTR HORIZ
  .DB $80, $32, $00, $80            ; Sprite0
  .DB $80, $33, $00, $88            ; Sprite1
  .DB $88, $34, $00, $80            ; Sprite2
  .DB $88, $35, $00, $88            ; Sprite3
ENDDATASprites:
; --- END Sprite definitions ---


; --- BEGIN Raw graphics data ---
  .BANK 2
  .ORG $0000

  .INCBIN "sprite/mario.chr"     ; 8KB Graphics file from SMB1
; --- END Raw graphics data ---


  .CODE

  .BANK 0
  .ORG $c000 


  jmp     __ISREntryPoint


; --- BEGIN Subroutine to move the Mario sprites right ---
PROCMoveMarioRight:
  lda     $0203                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $0203                   ; Increment the Sprite0 X position

  lda     $0207                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $0207                   ; Increment the Sprite1 X position

  lda     $020b                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $020b                   ; Increment the Sprite2 X position
  
  lda     $020f                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $020f                   ; Increment the Sprite3 X position
ENDPROCMoveMarioRight:
  rts                             ; Return from subroutine
; --- END Subroutine to move the Mario sprites right ---


; --- BEGIN Subroutine to move the Mario sprites left ---
PROCMoveMarioLeft:
  lda     $0203                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $0203                   ; Decrement Sprite0 X position

  lda     $0207                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $0207                   ; Decrement Sprite1 X position

  lda     $020b                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $020b                   ; Decrement Sprite2 X position

  lda     $020f                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $020f                   ; Decrement Sprite3 X position
ENDPROCMoveMarioLeft:
  rts                             ; Return from subroutine
; --- END Subroutine to move the Mario sprites left ---


__ISREntryPoint:


; End of first_nes.inc
