;
; first_nes
; isr_reset.asm
;
; This is the RESET Interrupt Service Routine for the first_nes project.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, Feb. 2017
;
; Based on the the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
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
  .ORG ISREntryPoint 


; --- BEGIN "Reset" (Power on) Interrupt Service Routine ---
ISRReset:

    sei                             ; disable IRQs
    cld                             ; disable decimal mode

    ldx     #$40
    stx     FR_COUNTER              ; disable APU frame IRQ

    ldx     #$FF
    txs                             ; Set up stack
    inx                             ; now X = 0
    stx     PPUCTRL                 ; disable NMI
    stx     PPUMASK                 ; disable rendering
    stx     $4010                   ; disable DMC IRQs

  ; Note: The PPU may not be in a usable state when the system is first turned on or reset.

  ; Wait for Vertical Blank to make sure PPU is ready
  vBlankWait1:       
    bit     PPUSTATUS
    bpl     vBlankWait1

  clearMemory:
    lda     #$00
    sta     $0000, x
    sta     $0100, x
    sta     $0200, x
    sta     $0400, x
    sta     $0500, x
    sta     $0600, x
    sta     $0700, x
    lda     #$FE
    sta     $0300, x
    inx
    bne     clearMemory

  ; Second wait for vblank, PPU is ready after this 
  vBlankWait2:
    bit     PPUSTATUS
    bpl     vBlankWait2

  loadPalettes:
    lda     PPUSTATUS               ; read PPU status to reset the high/low latch
    lda     #$3F
    sta     PPUADDR                 ; write the high byte of $3F00 address
    lda     #$00
    sta     PPUADDR                 ; write the low byte of $3F00 address
    ldx     #$00                    ; start out at 0

  ; Load data from address (palette + the value in x)
  ; 1st time through loop it will load palette+0
  ; 2nd time through loop it will load palette+1
  ; etc.
  loadPalettesLoop:
    lda     palette, x              
    sta     PPUDATA                 ; write to PPU
    inx                             ; X = X + 1
    cpx     #$20                    ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
    bne     loadPalettesLoop        ; Branch to loadPalettesLoop if compare was Not Equal to zero
                                    ; if compare was equal to 32, keep going down
  loadSprites:
    ldx     #$00                    ; start at 0

  loadSpritesLoop:
    lda     sprites, x              ; load data from address (sprites +  x)
    sta     $0200, x                ; store into RAM address ($0200 + x)
    inx                             ; X = X + 1
    cpx     #$20                    ; Compare X to hex $20, decimal 32
    bne     loadSpritesLoop         ; Branch to loadSpritesLoop if compare was Not Equal to zero
                                    ; if compare was equal to 32, keep going down
    lda     #%10000000              ; enable NMI, sprites from Pattern Table 1
    sta     PPUCTRL

    lda     #%00010000              ; enable sprites
    sta     PPUMASK

  forever:                          ;
    jmp     forever                 ; THIS IS AN INFINITE LOOP

  isrResetEnd:
    rti                             ; Return from interrupt
  isrVerticalBlankBegin:
; --- END "Reset" (Power on) Interrupt Service Routine ---


; End of isr_reset.inc
