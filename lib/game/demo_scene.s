;
; first_nes
; lib/game/demo_scene.s
;
; Loads the original Neon Grid nametable into PPU VRAM while rendering is disabled.
;


.SEGMENT "ZEROPAGE"

BackgroundPtr:  .res 2


.SEGMENT "CODE"


.PROC LoadDemoBackground

    ; Reset the shared $2005/$2006 write toggle, then point PPUDATA at nametable 0 ($2000).
    bit     _PPUSTATUS
    lda     #$20
    sta     _PPUADDR
    lda     #$00
    sta     _PPUADDR

    lda     #<DemoNametable
    sta     BackgroundPtr
    lda     #>DemoNametable
    sta     BackgroundPtr + 1

    ; Nametable + attributes = 1024 bytes = four complete 256-byte pages.
    ldx     #$04
    ldy     #$00
   loadBackgroundPage:
   loadBackgroundByte:
    lda     (BackgroundPtr), y
    sta     _PPUDATA
    iny
    bne     loadBackgroundByte

    inc     BackgroundPtr + 1
    dex
    bne     loadBackgroundPage

    ; Start the camera at the upper-left corner.
    bit     _PPUSTATUS
    lda     #$00
    sta     _PPUSCROLL              ; X first
    sta     _PPUSCROLL              ; Y second

    rts

.ENDPROC

; End of lib/game/demo_scene.s
