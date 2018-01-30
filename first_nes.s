;
; first_nes
; first_nes.s
;
; A "starter" assembly language game for the Nintendo Entertainment System.
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
;  ld65 first_nes.o -C ld65.cfg
;  cat first_nes_hdr.bin first_nes_prg.bin first_nes_chr.bin > first_nes.nes
;  rm a.out
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


  .SEGMENT "ZP"

  .SEGMENT "BSS"


; =================================================================================================
; Non-project-specific helper files. You should study each of these, individually.
; =================================================================================================

  ; CPU-Specific directives
  .INCLUDE "common/cpu.inc"

  ; Audio-specific directives
  .INCLUDE "common/apu.inc"

  ; Graphics-specific directives
  .INCLUDE "common/ppu.inc"

  ; Joystick-specific directives
  .INCLUDE "common/controllers.inc"


; =================================================================================================
;  DATA
; =================================================================================================

.SEGMENT "HEADER"


.BYTE   "NES", $1a
.BYTE   $01           ; 1x 8KB VROM (CHR)
.BYTE   $01           ; 1x 16KB ROM (PRG)
.BYTE   %00000001     ; Mapper 0000 == No mapping (a simple 16KB PRG + 8KB CHR game)
                      ; Mirroring 0001 == Vertical mirroring only


.SEGMENT "PALETTE"


; --- BEGIN Color palette ---
Palette:
  .BYTE $0f, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $0f
  .BYTE $0f, $1c, $15, $14, $31, $02, $38, $3c, $0f, $1c, $15, $14, $31, $02, $38, $3c
; --- END Color palette ---


; --- BEGIN Sprite definitions ---
Sprites:
  ;     VERT TILE ATTR HORIZ
  .BYTE $80, $32, $00, $80            ; Sprite0
  .BYTE $80, $33, $00, $88            ; Sprite1
  .BYTE $88, $34, $00, $80            ; Sprite2
  .BYTE $88, $35, $00, $88            ; Sprite3
; --- END Sprite definitions ---


; --- BEGIN Raw graphics data ---
.SEGMENT "TILES"


.INCBIN "sprite/mario.chr"     ; 8KB Graphics file from SMB1
; --- END Raw graphics data ---


; =================================================================================================
;  CODE
; =================================================================================================

.SEGMENT "CODE"


  jmp     __ISREntryPoint


; --- BEGIN Subroutine to move the Mario sprites right ---
.PROC     MoveMarioRight
  lda     $0203                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $0203                   ; Increment the Sprite0 X position

  lda     $0207                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $0207                   ; Increment the Sprite1 X position

  lda     $020b                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $020b                   ; Increment the Sprite2 X position
  
  lda     $020f                   ; 
  clc                             ;
  adc     #$01                    ; 
  sta     $020f                   ; Increment the Sprite3 X position

  rts
.ENDPROC
; --- END Subroutine to move the Mario sprites right ---


; --- BEGIN Subroutine to move the Mario sprites left ---
.PROC     MoveMarioLeft
  lda     $0203                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $0203                   ; Decrement Sprite0 X position

  lda     $0207                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $0207                   ; Decrement Sprite1 X position

  lda     $020b                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $020b                   ; Decrement Sprite2 X position

  lda     $020f                   ; 
  sec                             ; 
  sbc     #$01                    ; 
  sta     $020f                   ; Decrement Sprite3 X position

  rts
.ENDPROC
; --- END Subroutine to move the Mario sprites left ---


__ISREntryPoint:


; --- BEGIN "Reset" (Power on) Interrupt Service Routine ---
.PROC ISRReset

  ; Initialization sequence for the NES
  initBegin:
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


  ;
  ; Note: When the system is first turned on or reset, the PPU may not be in a usable state right
  ; away. You should wait at least 30,000 (thirty thousand) CPU cycles for the PPU to initialize, 
  ; which may be accomplished by waiting for 2 (two) vertical blank intervals.
  ;

  ; Wait for a Vertical Blank
  vBlankWait1Begin:
    vBlankWait1Loop:       
    bit     _PPUSTATUS
    bpl     vBlankWait1Loop


  ; Clear internal RAM
  clearMemoryBegin:
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


  ; Wait for another vertical blank
  vBlankWait2Begin:
    vBlankWait2Loop:
    bit     _PPUSTATUS
    bpl     vBlankWait2Loop

  ;
  ; Now the PPU is ready.
  ;

  loadPalettesBegin:
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
    lda     Palette, x              
    sta     _PPUDATA                ; Write to PPU
    inx                             ; X = X + 1
    cpx     #$10                    ; Compare X to hex $10, decimal 16 (copying 4 sprites)
    bne     loadPalettesLoop        ; Branch to loadPalettesLoop if compare was Not Equal to zero
                                    ; If compare was equal to 32, keep going down


  loadSpritesBegin:
    ldx     #$00                    ; Start at 0
    loadSpritesLoop:
    lda     Sprites, x              ; Set register A to (Sprites + x)
    sta     $0200, x                ; Store the value of register A into RAM address ($0200 + x)
    inx                             ; X = X + 1
    cpx     #$20                    ; Compare X to hex $20, decimal 32
    bne     loadSpritesLoop         ; Branch to loadSpritesLoop if compare was Not Equal to zero
                                    ; If compare was equal to 32, keep going down
 

  enableGraphicsBegin:
    lda     #%10000000              ; Enable vertical blank interrupt
    sta     _PPUCTRL                ;

    lda     #%00010000              ; Enable sprite rendering
    sta     _PPUMASK                ;


  doNothingBegin:
    endlessLoop:
    jmp     endlessLoop             ; THIS IS AN INFINITE LOOP


    rti                             ; Return from interrupt

.ENDPROC
; --- END "Reset" (Power on) Interrupt Service Routine ---


; --- BEGIN "Vertical Blank" (Non-Maskable Interrupt) Interrupt Service Routine ---
.PROC ISRVerticalBlank

    lda     #$00
    sta     _OAMADDR                ; Set the low byte (00) of the RAM address
    lda     #$02
    sta     _OAMDMA                 ; Set the high byte (02) of the RAM address, start the transfer

  ; Freeze the button positions
  latchControllerBegin:
    lda     #$01
    sta     _JOY1
    lda     #$00
    sta     _JOY1                   ; Tell both the controllers to latch buttons
  latchControllerEnd:
  
  ; Check button A
  readButtonABegin: 
    lda     _JOY1                    
    and     #%00000001              ; Only look at bit 0
    beq     readButtonAEnd          ; Branch to readButtonAEnd if button A is NOT pressed (0)                                    
    jsr     MoveMarioRight          ; Jump to the subroutine that moves the Mario sprites right
  readButtonAEnd:

  ; Check button B
  readButtonBBegin: 
    lda     _JOY1                    
    and     #%00000001              ; Only look at bit 0
    beq     readButtonBEnd          ; Branch to readButtonBEnd if button B is NOT pressed (0)                                    
    jsr     MoveMarioLeft           ; Jump to the subroutine that moves the Mario sprites left
  readButtonBEnd:
  
    rti                             ; Return from interrupt
    
.ENDPROC
; --- END "Vertical Blank" (Non-Maskable Interrupt) Interrupt Service Routine ---


; --- Begin "Break" Interrupt Service Routine ---
.PROC ISRBreak

  nop               ; Do nothing

    rti                             ; Return from interrupt

.ENDPROC
; --- End "Break" Interrupt Service Routine ---


; --- BEGIN Interrupt vector table ---
.SEGMENT "VECTORS"


.WORD  ISRVerticalBlank
.WORD  ISRReset
.WORD  ISRBreak
; --- END Interrupt vector table ---


; End of first_nes.s
