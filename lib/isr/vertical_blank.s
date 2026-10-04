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

  ; ---------------------------------------------------------------------------------------------
  ; NMI can interrupt foreground code between almost any two instructions. Preserve the general
  ; purpose registers before doing interrupt work, then restore them in reverse order before RTI.
  ; The processor status and return address are already saved automatically by the 6502.
  ; ---------------------------------------------------------------------------------------------

    pha
    txa
    pha
    tya
    pha
  
  ; -------------------------------------------------
  ; Copy the CPU-side OAM shadow page into PPU OAM.
  ; -------------------------------------------------

    lda     #$00
    sta     _OAMADDR

    lda     #$02
    sta     _OAMDMA                 ; DMA $0200-$02FF into PPU OAM

  ; ---------------------------------------------------------------------------------------------
  ; Publish one frame tick to the foreground. MainLoop consumes this counter and performs controller
  ; polling plus game-state updates outside the time-critical NMI window.
  ; ---------------------------------------------------------------------------------------------

    inc     FrameCounter

  ; ---------------------------
  ; Restore interrupted context.
  ; ---------------------------

    pla
    tay
    pla
    tax
    pla

    rti

.ENDPROC

; End of lib/isr/vertical_blank.s
