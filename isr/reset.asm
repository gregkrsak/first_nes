;
; first_nes
; reset.asm
;
; This is the RESET Interrupt Service Routine for the first_nes project.
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
  .ORG __ISREntryPoint 


; --- BEGIN "Reset" (Power on) Interrupt Service Routine ---
ISRReset:

  ; Initialization sequence for the NES
  .initBegin:
    cld                             ; Disable decimal mode in case someone is using a 6502 debugger

    ldx     #$00                    ; Set X register to $00
    stx     _PPUCTRL                ; Disable vertical blank interrupt
    stx     _PPUMASK                ; Disable sprite rendering

    ldx     #$FF                    ; Set X register to $FF
    txs                             ; Set the value of the stack pointer to $FF

    ldx     #$40                    ; Set X Register to $40
    stx     _FR_COUNTER             ; Disable APU frame IRQ
    stx     _DMC_FREQ               ; Disable DMC IRQs

    bit     _PPUSTATUS              ; Clear the vblank flag in case the user reset during vblank
  .initEnd:

  ;
  ; Note: When the system is first turned on or reset, the PPU may not be in a usable state right
  ; away. You should wait at least 30,000 (thirty thousand) CPU cycles for the PPU to initialize, 
  ; which may be accomplished by waiting for 2 (two) vertical blank intervals.
  ;

  ; Wait for a Vertical Blank
  .vBlankWait1Begin:
    ..vBlankWait1Loop:       
    bit     _PPUSTATUS
    bpl     ..vBlankWait1Loop
  .vBlankWait1End:

  ; Clear internal RAM
  .clearMemoryBegin:
    ldx     #$00
    ..clearMemoryLoop:
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
    bne     ..clearMemoryLoop
  .clearMemoryEnd:

  ; Wait for another vertical blank
  .vBlankWait2Begin:
    ..vBlankWait2Loop:
    bit     _PPUSTATUS
    bpl     ..vBlankWait2Loop
  .vBlankWait2End:

  ;
  ; Now the PPU is ready.
  ;

  .loadPalettesBegin:
    lda     _PPUSTATUS              ; read PPU status to reset the high/low latch
    lda     #$3F
    sta     _PPUADDR                ; write the high byte of $3F00 address
    lda     #$00
    sta     _PPUADDR                ; write the low byte of $3F00 address
    ldx     #$00                    ; start out at 0
    ; Load data from address (palette + the value in x)
    ; 1st time through loop it will load palette+0
    ; 2nd time through loop it will load palette+1
    ; etc.
    ..loadPalettesLoop:
    lda     DATAPalette, x              
    sta     _PPUDATA                ; write to PPU
    inx                             ; X = X + 1
    cpx     #$10                    ; Compare X to hex $10, decimal 16 (copying 4 sprites)
    bne     ..loadPalettesLoop      ; Branch to loadPalettesLoop if compare was Not Equal to zero
                                    ; if compare was equal to 32, keep going down
  .loadPaletteEnd:

  .loadSpritesBegin:
    ldx     #$00                    ; start at 0
    ..loadSpritesLoop:
    lda     DATASprites, x          ; Set register A to (DATASprites + x)
    sta     $0200, x                ; Store the value of register A into RAM address ($0200 + x)
    inx                             ; X = X + 1
    cpx     #$20                    ; Compare X to hex $20, decimal 32
    bne     ..loadSpritesLoop       ; Branch to loadSpritesLoop if compare was Not Equal to zero
                                    ; if compare was equal to 32, keep going down
  .loadSpritesEnd:

  .enableGraphicsBegin:
    lda     #%10000000              ; Enable vertical blank interrupt
    sta     _PPUCTRL                ;

    lda     #%00010000              ; Enable sprite rendering
    sta     _PPUMASK                ;
  .enableGraphicsEnd:

  .doNothingBegin:
    ..endlessLoop:
    jmp     ..endlessLoop           ; THIS IS AN INFINITE LOOP
  .doNothingEnd:

ENDISRReset:
    rti                             ; Return from interrupt
; --- END "Reset" (Power on) Interrupt Service Routine ---


__ISRVerticalBlankBegin:


; End of reset.inc
