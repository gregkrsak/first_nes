;
; first_nes
; lib/shared_code/cpu.s
;
; Common CPU-related routines.
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


; =======================================
; Subroutine to initiate an endless loop.
; =======================================

.PROC EndlessLoop

   endlessLoop:
    jmp endlessLoop

    rts

.ENDPROC


; =================================================
; (unsafe) Subroutine to clear the internal CPU RAM
; =================================================

__ClearCPUMemory:
    ldx     #$00
   __clearMemoryLoop:
    lda     #_RAM_CLEAR_VALUE
    sta     $0000, x
    sta     $0100, x
    sta     $0300, x
    sta     $0400, x
    sta     $0500, x
    sta     $0600, x
    sta     $0700, x

    ; $0200-$02FF is the CPU-side OAM shadow page. OAM DMA always copies
    ; the complete 256-byte page, so initialize every unused sprite with
    ; an off-screen Y position before active sprite entries are loaded.
    lda     #_OAM_HIDDEN_Y
    sta     $0200, x

    inx
    bne     __clearMemoryLoop
    jmp     ISR_PowerOn_Reset::__CPUMemoryCleared

; End of lib/shared_code/cpu.s
