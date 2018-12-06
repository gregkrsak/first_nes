;
; first_nes
; lib/isr/vertical_blank.s
;
; After the NES displays a frame of graphics, it stops drawing for a while. This period is known
; as the vertical blank, or "vblank", and is a good choice for performing graphics updates. Note
; that this interrupt is non-maskable (NMI).
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


.PROC ISR_Vertical_Blank
  
  ; -------------------------------------------------
  ; Refresh DRAM-stored sprite data before it decays.
  ; -------------------------------------------------

    lda     #$00                    ;
    sta     _OAMADDR                ; Set the low byte (00) of the RAM address

    lda     #$02                    ;
    sta     _OAMDMA                 ; Set the high byte (02) of the RAM address and start the
                                    ; DMA transfer
  ; ----------------------------
  ; Freeze the button positions.
  ; ----------------------------

    lda     #$01                    ;
    sta     _JOY1                   ;
    lda     #$00                    ;
    sta     _JOY1                   ; Controllers for first and second player are now latched
                                    ; and will not change
  ; --------------
  ; Read button A.
  ; --------------

    lda     _JOY1                   ; 
    and     #%00000001              ; Only look at bit 0
    beq     readButtonAEnd          ; Branch to readButtonAEnd if button A is NOT pressed (0)                                    
    jsr     MoveLuigiRight          ; Call the procedure that moves the Luigi sprites right
  readButtonAEnd:                   ;

  ; ---------------
  ; Read button B.
  ; ---------------
 
    lda     _JOY1                    
    and     #%00000001              ; Only look at bit 0
    beq     readButtonBEnd          ; Branch to readButtonBEnd if button B is NOT pressed (0)                                    
    jsr     MoveLuigiLeft           ; Call the procedure that moves the Luigi sprites left
  readButtonBEnd:                   ;
  
    rti                             ; Return from interrupt 

.ENDPROC

; End of lib/isr/vertical_blank.s
