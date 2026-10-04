;
; first_nes
; lib/isr/custom.s
;
; IRQ/BRK interrupt service routine. On the 6502, maskable hardware IRQs and the BRK instruction
; share the same vector at $FFFE-$FFFF. The starter project does not currently use a mapper IRQ or
; APU IRQ, but this handler is kept safe and ready for future expansion.
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


.PROC ISR_IRQ_BRK

    pha
    txa
    pha
    tya
    pha

    ; No IRQ/BRK-specific work is required yet.
    nop

    pla
    tay
    pla
    tax
    pla

    rti
    
.ENDPROC

; End of lib/isr/custom.s
