;
; first_nes
; lib/shared_code/ppu.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Provide reusable Picture Processing Unit (PPU) helper routines for enabling/disabling
;          rendering, waiting for vertical blank, and copying palette/sprite data into NES video state.
;


; =================================================================================================
; DisableVideoOutput
;
; Purpose:
;   Turn off NMI generation and both background/sprite rendering before reset-time video memory work.
;
; Inputs:
;   None.
;
; Outputs / side effects:
;   PPUCTRL ($2000) becomes $00.
;   PPUMASK ($2001) becomes $00.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC DisableVideoOutput

    lda     #%00000000              ; One zero value can safely clear both video-control registers.
    sta     _PPUCTRL                ; Disable vblank NMI and select the default PPU control settings.
    sta     _PPUMASK                ; Disable background and sprite rendering.

    rts                             ; Return with the screen disabled for safe initialization work.

.ENDPROC


; =================================================================================================
; EnableVideoOutput
;
; Purpose:
;   Enable vblank NMI plus normal background and sprite rendering after the reset routine has loaded
;   all initial graphics data.
;
; Inputs:
;   PPU palette, nametable, and initial OAM shadow should already be prepared.
;
; Outputs / side effects:
;   PPUCTRL enables NMI while keeping pattern tables at $0000.
;   PPUMASK enables background and sprites, including the left-most eight screen pixels.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC EnableVideoOutput

    lda     #%10000000              ; Bit 7 = generate NMI at the beginning of vertical blank.
    sta     _PPUCTRL                ; Other bits remain zero: pattern tables at $0000, +1 VRAM writes.

    lda     #%00011110              ; Bits 1/2 show left edge; bits 3/4 show background and sprites.
    sta     _PPUMASK

    rts                             ; Video output and once-per-frame NMI are now active.

.ENDPROC


; =================================================================================================
; WaitForVBlank
;
; Purpose:
;   Busy-wait until PPUSTATUS bit 7 reports that vertical blank has begun. Reset initialization uses
;   this simple polling loop before NMI has been enabled.
;
; Inputs:
;   None.
;
; Outputs / side effects:
;   Repeatedly reads PPUSTATUS. Reading $2002 also clears the vblank flag and resets the PPU's shared
;   $2005/$2006 write toggle.
;
; Registers:
;   Processor flags change because BIT is used. A, X, and Y are preserved.
;
; Returns:
;   RTS after BIT observes PPUSTATUS bit 7 set.
; =================================================================================================

.PROC WaitForVBlank

   vBlankWaitLoop:
    bit     _PPUSTATUS              ; Copy PPUSTATUS bit 7 into the 6502 negative flag.
    bpl     vBlankWaitLoop          ; BPL repeats while bit 7 is clear (negative flag = 0).

    rts                             ; Bit 7 was set: a vertical blank has begun.

.ENDPROC


; =================================================================================================
; ClearVBlankFlag
;
; Purpose:
;   Read PPUSTATUS once during reset to acknowledge/clear any vblank flag that may already be set and
;   to reset the internal two-write latch shared by PPUSCROLL/PPUADDR.
;
; Inputs:
;   None.
;
; Outputs / side effects:
;   PPUSTATUS is read; hardware clears its vblank flag as a consequence of that read.
;
; Registers:
;   Processor flags change because BIT is used. A, X, and Y are preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC ClearVBlankFlag

    bit     _PPUSTATUS              ; The read itself performs the required PPU hardware side effects.

    rts                             ; No value from the status register needs to be retained.

.ENDPROC


; =================================================================================================
; LoadPaletteData
;
; Purpose:
;   Copy the project's complete 32-byte palette table from PRG ROM into PPU palette RAM beginning at
;   $3F00. The first 16 bytes are background palettes; the next 16 bytes are sprite palettes.
;
; Inputs:
;   _PALETTE points to at least 32 palette bytes.
;   Rendering is expected to be disabled during this reset-time transfer.
;
; Outputs / side effects:
;   Writes 32 sequential bytes to PPU VRAM $3F00-$3F1F through PPUDATA.
;
; Registers:
;   A and X are modified. Y is preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC LoadPaletteData

    lda     _PPUSTATUS              ; Reset the shared $2005/$2006 write latch to its first-write state.

    lda     #$3F                    ; High byte of palette RAM base address $3F00.
    sta     _PPUADDR                ; PPUADDR always receives the high byte first.

    lda     #$00                    ; Low byte of palette RAM base address $3F00.
    sta     _PPUADDR                ; Second write completes the 14-bit PPU address.

    ldx     #$00                    ; X indexes the 32 source bytes in _PALETTE.
   loadPalettesLoop:
    lda     _PALETTE, x             ; Read one palette byte from PRG ROM.
    sta     _PPUDATA                ; Write it to current PPUADDR; hardware increments address by one.

    inx                             ; Advance to the next palette byte.
    cpx     #32                     ; All NES background + sprite palette entries total 32 bytes.
    bne     loadPalettesLoop

    rts                             ; All palette RAM needed by the demo has been initialized.

.ENDPROC


; =================================================================================================
; LoadSpriteData
;
; Purpose:
;   Copy the four 4-byte Neon Ranger seed sprite entries from _SPRITES into the CPU-side OAM shadow
;   page at $0200. The rest of that page was already filled with hidden-sprite values by RAM init.
;
; Inputs:
;   _SPRITES points to exactly 16 bytes describing four hardware sprites.
;
; Outputs / side effects:
;   $0200-$020F receive the initial Y/tile/attribute/X bytes for the four-sprite character.
;
; Registers:
;   A and X are modified. Y is preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC LoadSpriteData

    ldx     #$00                    ; X indexes the 16 source bytes and their OAM-shadow destinations.
  loadSpritesLoop:
    lda     _SPRITES, x             ; Read one byte of initial sprite data from PRG ROM.
    sta     $0200, x                ; Store it in the CPU-side OAM shadow page.

    inx                             ; Advance to the next byte.
    cpx     #16                     ; Four sprites x four OAM bytes each = 16 bytes total.
    bne     loadSpritesLoop

    rts                             ; Initial active sprite entries are now ready for OAM DMA.

.ENDPROC

; End of lib/shared_code/ppu.s
