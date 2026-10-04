;
; first_nes
; lib/game/main_loop.s
;
; Foreground game loop synchronized to NMI with an 8-bit frame counter.
;
; Why a counter instead of a simple ready flag? NMI is non-maskable, so a flag can be cleared at
; exactly the wrong moment and lose a frame notification. Comparing counters avoids that race while
; keeping the pattern easy to understand.
;


.SEGMENT "ZEROPAGE"

FrameCounter:      .res 1            ; incremented by NMI
LastFrameCounter:  .res 1            ; most recent frame consumed by MainLoop


.SEGMENT "CODE"


.PROC MainLoop

  waitForNextFrame:
    lda     FrameCounter
    cmp     LastFrameCounter
    beq     waitForNextFrame
    sta     LastFrameCounter

    ; Controller polling and game-state changes happen in foreground time, not inside NMI.
    jsr     ReadController1

    lda     Controller1Current
    and     #BUTTON_RIGHT
    beq     mainRightDone
    jsr     MoveHeroRight
  mainRightDone:

    lda     Controller1Current
    and     #BUTTON_LEFT
    beq     mainLeftDone
    jsr     MoveHeroLeft
  mainLeftDone:

    ; Vertical motion is intentionally no longer driven directly by Up/Down. The next platformer
    ; step gives HeroY to gravity/jump physics instead.
    jsr     UpdateHeroAnimation
    jsr     RenderHeroToOAM

    jmp     waitForNextFrame

.ENDPROC

; End of lib/game/main_loop.s
