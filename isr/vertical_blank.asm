;
; first_nes
; vertical_blank.asm
;
; This is the NMI Interrupt Service Routine for the first_nes project.
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
; http://nixw0rm.altervista.org/files/nesasm.pdf
; https://patater.com/nes-asm-tutorials/
; https://en.wikibooks.org/wiki/NES_Programming/Memory_Map
;
; For more information on the NESASM assembler, try these references:
; http://www.nespowerpak.com/nesasm/usage.txt
;


  .CODE

  .BANK 0
  .ORG __ISRVerticalBlankBegin


; --- BEGIN "Vertical Blank" (Non-Maskable Interrupt) Interrupt Service Routine ---
ISRVerticalBlank:

    lda     #$00
    sta     _OAMADDR                ; set the low byte (00) of the RAM address
    lda     #$02
    sta     _OAMDMA                 ; set the high byte (02) of the RAM address, start the transfer

  ; Freeze the button positions
  .latchControllerBegin:
    lda     #$01
    sta     _JOY1
    lda     #$00
    sta     _JOY1                   ; tell both the controllers to latch buttons
  .latchControllerEnd:
  
  ; Button A
  .readButtonABegin: 
    lda     _JOY1                    
    and     #%00000001              ; only look at bit 0
    beq     .readButtonAEnd         ; branch to readButtonAEnd if button A is NOT pressed (0)                                    
    jsr     PROCMoveMarioRight      ; Jump to the subroutine that move all of the sprites to the right
  .readButtonAEnd:

  ; Button B
  .readButtonBBegin: 
    lda     _JOY1                    
    and     #%00000001              ; only look at bit 0
    beq     .readButtonBEnd         ; branch to readButtonBEnd if button B is NOT pressed (0)                                    
    jsr     PROCMoveMarioLeft       ; Jump to the subroutine that move all of the sprites to the left
  .readButtonBEnd:

ENDISRVerticalBlank:  
    rti                             ; Return from interrupt
; --- END "Vertical Blank" (Non-Maskable Interrupt) Interrupt Service Routine ---


__ISRBreakBegin:


; End of vertical_blank.inc
