;
; first_nes
; shared_code/ppu.s
;
; Common PPU-related routines.
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
;  ca65 first_nes.s
;  ld65 first_nes.o -C config/ines.cfg
;  cat bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin > first_nes.nes
;  rm a.out && rm first_nes.o
;  nestopia first_nes.nes
;
; Tested on:
;  Nestopia UE 1.47
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the ca65 assembler, try these references:
; https://github.com/cc65/cc65
; http://cc65.github.io/doc/ca65.html
;


; ======================================================================================
; Subroutine to disable video output. This will cause a black screen and disable vblank.
; ======================================================================================

.PROC     DisableVideoOutput

    ldx     #%00000000              ;
    stx     _PPUCTRL                ; Disable vertical blank interrupt   
    stx     _PPUMASK                ; Disable sprite rendering

    rts
    
.ENDPROC


; ===========================================================
; Subroutine to enable video output. This will enable vblank.
; ===========================================================

.PROC     EnableVideoOutput

    lda     #%10000000              ;
    sta     _PPUCTRL                ; Enable vertical blank interrupt

    lda     #%00010000              ;
    sta     _PPUMASK                ; Enable sprite rendering

    rts
    
.ENDPROC


; ==============================
; Subroutine to wait for vblank.
; ==============================

.PROC     WaitForVBlank

   vBlankWaitLoop:
    bit     _PPUSTATUS
    bpl     vBlankWaitLoop

    rts

.ENDPROC


; ================================
; Subroutine to load palette data.
; ================================

.PROC LoadPaletteData

    lda     _PPUSTATUS              ; Reset the high/low latch to "high"

    lda     #$3F                    ;
    sta     _PPUADDR                ; Write the high byte of $3F00 address

    lda     #$00                    ;
    sta     _PPUADDR                ; Write the low byte of $3F00 address

    ldx     #$00                    ; 
   loadPalettesLoop:                ;
    lda     _PALETTE, x             ; 
    sta     _PPUDATA                ; Write to PPU
    inx                             ;
    cpx     #32                     ;
    bne     loadPalettesLoop        ;

.ENDPROC 


; ===============================
; Subroutine to load sprite data.
; ===============================

.PROC LoadSpriteData

    ldx     #$00                    ;
  loadSpritesLoop:                  ;
    lda     _SPRITES, x             ;
    sta     $0200, x                ; Write to PPU
    inx                             ;
    cpx     #16                     ;
    bne     loadSpritesLoop         ;

.ENDPROC 

; End of shared_code/ppu.s
