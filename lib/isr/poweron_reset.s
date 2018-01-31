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


.PROC ISR_PowerOn_Reset
  ; ---------------------------------------------------------------------------------------------
  ; Initialization sequence for the NES. These tasks should generally be performed every time the
  ; system is reset.
  ; ---------------------------------------------------------------------------------------------
    cld                             ; Disable decimal mode in case someone is using a 6502 debugger

    ldx     #$00                    ; 
    stx     _PPUCTRL                ; Disable vertical blank interrupt
    stx     _PPUMASK                ; Disable sprite rendering

    ldx     #$FF                    ; 
    txs                             ; Set the value of the stack pointer to $FF

    ldx     #$40                    ; 
    stx     _FR_COUNTER             ; Disable APU frame IRQ
    stx     _DMC_FREQ               ; Disable DMC IRQs

    bit     _PPUSTATUS              ; Clear the vblank flag in case the user reset during vblank

  ; ---------------------------------------------------------------------------------------------
  ; Note: When the system is first turned on or reset, the PPU may not be in a usable state right
  ; away. You should wait at least 30,000 (thirty thousand) CPU cycles for the PPU to initialize, 
  ; which may be accomplished by waiting for 2 (two) vertical blank intervals.
  ; ---------------------------------------------------------------------------------------------

  ; --------------------------
  ; Wait for a Vertical Blank.
  ; --------------------------
  vBlankWait1Loop:       
    bit     _PPUSTATUS
    bpl     vBlankWait1Loop

  ; -------------------
  ; Clear internal RAM.
  ; -------------------
    ldx     #$00
    clearMemoryLoop:
    lda     _RAM_CLEAR_PATTERN_1
    sta     $0000, x
    sta     $0100, x
    sta     $0200, x
    sta     $0400, x
    sta     $0500, x
    sta     $0600, x
    sta     $0700, x
    lda     _RAM_CLEAR_PATTERN_2
    sta     $0300, x
    inx
    bne     clearMemoryLoop

  ; --------------------------
  ; Wait for a Vertical Blank.
  ; --------------------------
  vBlankWait2Loop:
    bit     _PPUSTATUS
    bpl     vBlankWait2Loop

  ; ---------------------
  ; Now the PPU is ready.
  ; ---------------------

  ; -------------------------------
  ; Load palette data into the PPU.
  ; -------------------------------
    lda     _PPUSTATUS              ; Read PPU status to reset the high/low latch
    lda     #$3F
    sta     _PPUADDR                ; Write the high byte of $3F00 address
    lda     #$00
    sta     _PPUADDR                ; Write the low byte of $3F00 address
    ldx     #$00                    ; Start out at 0
    ; Load data from address (palette + the value in x)
    ; 1st time through loop it will load palette+0
    ; 2nd time through loop it will load palette+1
    ; etc.
  loadPalettesLoop:
    lda     _PALETTE, x              
    sta     _PPUDATA                ; Write to PPU
    inx                             ; X = X + 1
    cpx     #$10                    ; Compare X to hex $10, decimal 16 (copying 4 sprites)
    bne     loadPalettesLoop        ; Branch to loadPalettesLoop if compare was Not Equal to zero
                                    ; If compare was equal to 32, keep going down

  ; ------------------------------
  ; Load sprite data into the PPU.
  ; ------------------------------
    ldx     #$00                    ; Start at 0
  loadSpritesLoop:
    lda     _SPRITES, x             ; Set register A to (Sprites + x)
    sta     $0200, x                ; Store the value of register A into RAM address ($0200 + x)
    inx                             ; X = X + 1
    cpx     #$20                    ; Compare X to hex $20, decimal 32
    bne     loadSpritesLoop         ; Branch to loadSpritesLoop if compare was Not Equal to zero
                                    ; If compare was equal to 32, keep going down

  ; --------------------
  ; Enable video output.
  ; --------------------
    lda     #%10000000              ; Enable vertical blank interrupt
    sta     _PPUCTRL                ;

    lda     #%00010000              ; Enable sprite rendering
    sta     _PPUMASK                ;

  ; -------------
  ; ENDLESS LOOP.
  ; -------------
  doNothingBegin:
    endlessLoop:
    jmp     endlessLoop

    rti                             ; Return from interrupt
.ENDPROC


; End of lib/isr/poweron_reset.s
