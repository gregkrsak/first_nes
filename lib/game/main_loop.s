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

    ; Preserve the original starter controls until the gameplay-modernization pass switches to D-pad.
    lda     Controller1Current
    and     #BUTTON_A
    beq     mainButtonAEnd
    jsr     MoveHeroRight
  mainButtonAEnd:

    lda     Controller1Current
    and     #BUTTON_B
    beq     mainButtonBEnd
    jsr     MoveHeroLeft
  mainButtonBEnd:

    jmp     waitForNextFrame

.ENDPROC

; End of lib/game/main_loop.s
