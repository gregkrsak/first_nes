;
; first_nes
; lib/game/demo_scene.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Copy the complete Neon Ranger demo-room nametable and attribute table from PRG ROM into
;          PPU VRAM while rendering is disabled during reset.
;
; The background data is exactly 1024 bytes: 960 nametable tile bytes followed by 64 attribute-table
; bytes. That conveniently equals four complete 256-byte pages.
;


.SEGMENT "ZEROPAGE"

BackgroundPtr:  .res 2              ; 16-bit pointer to the next 256-byte page of background data


.SEGMENT "CODE"


; =================================================================================================
; LoadDemoBackground
;
; Purpose:
;   Write DemoNametable to PPU nametable 0 ($2000-$23FF), then reset scroll to the upper-left corner.
;
; Inputs:
;   DemoNametable must point to exactly 1024 bytes of nametable + attribute data in PRG ROM.
;   Rendering must be disabled while this bulk VRAM transfer occurs.
;
; Outputs / side effects:
;   $2000-$23FF in PPU VRAM receives the complete demo room.
;   BackgroundPtr advances through four 256-byte source pages.
;   PPUSCROLL is set to X=0, Y=0.
;
; Registers:
;   A, X, and Y are modified.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC LoadDemoBackground

    ; ---------------------------------------------------------------------------------------------
    ; Select PPU VRAM address $2000.
    ;
    ; Reading PPUSTATUS resets the shared $2005/$2006 write toggle. PPUADDR then expects the high
    ; address byte first ($20) and the low address byte second ($00).
    ; ---------------------------------------------------------------------------------------------

    bit     _PPUSTATUS              ; Reset the PPU's internal address/scroll write latch.

    lda     #$20                    ; High byte of nametable-0 address $2000.
    sta     _PPUADDR

    lda     #$00                    ; Low byte of nametable-0 address $2000.
    sta     _PPUADDR

    ; ---------------------------------------------
    ; Build a 16-bit pointer to DemoNametable in RAM.
    ; ---------------------------------------------

    lda     #<DemoNametable         ; ca65 '<' selects the low byte of an address.
    sta     BackgroundPtr

    lda     #>DemoNametable         ; ca65 '>' selects the high byte of an address.
    sta     BackgroundPtr + 1

    ; ---------------------------------------------------------------------------------------------
    ; Copy 1024 bytes = four complete 256-byte pages.
    ;
    ; Y naturally counts from $00 through $FF. When INY wraps back to zero, one page is complete;
    ; incrementing BackgroundPtr+1 advances the 16-bit source pointer by exactly $0100 bytes.
    ; ---------------------------------------------------------------------------------------------

    ldx     #$04                    ; Four 256-byte pages remain to be copied.
    ldy     #$00                    ; Y is the byte index inside the current source page.

   loadBackgroundPage:
   loadBackgroundByte:
    lda     (BackgroundPtr), y      ; Read one source byte through the zero-page indirect pointer.
    sta     _PPUDATA                ; Write it to VRAM; PPUADDR automatically advances by one.

    iny                             ; Advance to the next byte in the current 256-byte page.
    bne     loadBackgroundByte      ; Nonzero means Y has not wrapped after $FF yet.

    inc     BackgroundPtr + 1       ; Y wrapped to zero, so move the source pointer to the next page.
    dex                             ; One fewer 256-byte page remains.
    bne     loadBackgroundPage

    ; ---------------------------------------------------------------------------------------------
    ; Start the camera at scroll position (0,0).
    ; PPUSCROLL is also a two-write register: X/horizontal first, Y/vertical second.
    ; ---------------------------------------------------------------------------------------------

    bit     _PPUSTATUS              ; Reset the shared $2005/$2006 write toggle again.

    lda     #$00
    sta     _PPUSCROLL              ; First $2005 write = horizontal/X scroll.
    sta     _PPUSCROLL              ; Second $2005 write = vertical/Y scroll.

    rts                             ; Background loading is complete.

.ENDPROC

; End of lib/game/demo_scene.s
