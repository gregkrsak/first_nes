;
; first_nes
; lib/isr/poweron_reset.s
;
; This Interrupt Service Routine is called when the NES is reset, including when it is turned on.
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


.PROC ISR_PowerOn_Reset

  ; ---------------------------------------------------------------------------------------------
  ; Initialization sequence for the NES. These tasks should generally be performed every time the
  ; system is reset.
  ; ---------------------------------------------------------------------------------------------
  
    cld                             ; Disable unsupported BCD mode (useful in some debuggers)

    ldx     #255
    txs                             ; Initialize stack pointer to $FF
    jsr     DisableVideoOutput
    jsr     DisableAudioOutput

    jsr     ClearVBlankFlag         ; Clear vblank in case reset happened during vblank

  ; ---------------------------------------------------------------------------------------------
  ; The PPU is not ready immediately after reset. Waiting for two vblank intervals provides the
  ; startup time required before normal PPU access.
  ; ---------------------------------------------------------------------------------------------

    jsr     WaitForVBlank

    jmp     __ClearCPUMemory
   __CPUMemoryCleared:

    jsr     WaitForVBlank

  ; ---------------------
  ; Now the PPU is ready.
  ; ---------------------

    jsr     LoadPaletteData
    jsr     LoadDemoBackground
    jsr     LoadSpriteData
    jsr     InitializeHeroState
    jsr     InitializeHeroPhysics
    jsr     RenderHeroToOAM
    jsr     EnableVideoOutput

  ; ---------------------------------------------------------------------------------------------
  ; Reset initialization is complete. MainLoop now owns foreground execution; NMI will interrupt it
  ; once per frame to perform time-critical PPU work and advance FrameCounter.
  ; ---------------------------------------------------------------------------------------------

    jmp     MainLoop

.ENDPROC 

; End of lib/isr/poweron_reset.s
