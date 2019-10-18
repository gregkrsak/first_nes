;
; first_nes
; lib/shared_code/ppu.s
;
; Common PPU-related routines.
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


; ======================================================================================
; Subroutine to disable video output. This will cause a black screen and disable vblank.
; ======================================================================================

.PROC DisableVideoOutput

    lda     #%00000000              ;
    sta     _PPUCTRL                ; Disable vertical blank interrupt   
    sta     _PPUMASK                ; Disable sprite rendering

    rts
    
.ENDPROC


; ===========================================================
; Subroutine to enable video output. This will enable vblank.
; ===========================================================

.PROC EnableVideoOutput

    lda     #%10010000              ; Background pattern $0000
    sta     _PPUCTRL                ; Enable vertical blank interrupt

    lda     #%00011110              ;
    sta     _PPUMASK                ; Enable sprite and background rendering

    rts
    
.ENDPROC


; ==============================
; Subroutine to wait for vblank.
; ==============================

.PROC WaitForVBlank

   vBlankWaitLoop:
    bit     _PPUSTATUS
    bpl     vBlankWaitLoop

    rts

.ENDPROC


; ====================================
; Subroutine to clear the vblank flag.
; ====================================

.PROC ClearVBlankFlag

    bit     _PPUSTATUS

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
    cpx     #32                     ; 16 background bytes and 16 sprite
    bne     loadPalettesLoop        ; bytes containing palette

    rts

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

    rts

.ENDPROC 


; ==================================
; Subroutine to load attribute data.
; ==================================

.PROC LoadBackgroundAttribute
 
    lda     _PPUSTATUS
    lda     #$23
    sta     _PPUADDR
    lda     #$c0
    sta     _PPUADDR
    ldx     #$00
  loadBackgroundAttributeLoop:
    lda     _ATTRIBUTE, x
    sta     _PPUDATA
    inx
    cpx     #16
    bne     loadBackgroundAttributeLoop  

    rts

.ENDPROC


; ========================================
; Subroutine to copy background tile data.
; ========================================

.PROC LoadBackgroundNametable
    ;first clear nametable ram
    lda _PPUSTATUS
    lda #$20
    sta _PPUADDR
    lda #$00
    sta _PPUADDR
    ldy #$00
  loadBackgroundNametableClearRAMLoopY:
    ldx #$00
  loadBackgroundNametableClearRAMLoopX:
    lda #$24
    sta _PPUDATA
    inx
    cpx #30
    bne loadBackgroundNametableClearRAMLoopX
    iny
    cpy #32
    bne loadBackgroundNametableClearRAMLoopY
    ; begin copying nametable bytes
    lda _PPUSTATUS
    lda #$20
    sta _PPUADDR
    lda #$00
    sta _PPUADDR
    ldx #$00
  loadBackgroundNametableLoop:
    lda _NAMETABLE, x
    sta _PPUDATA
    inx
    cpx #32    ; copy 32 bytes 
    bne loadBackgroundNametableLoop

    rts

.ENDPROC

; End of lib/shared_code/ppu.s
