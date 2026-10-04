;
; first_nes
; lib/game/jump_assist.s
;
; Small quality-of-life helpers that make the platformer jump feel forgiving without hiding the
; mechanics. These values are intentionally easy to tune while testing on real hardware/emulators.
;


COYOTE_FRAMES          = $04        ; grace frames after leaving a platform
JUMP_BUFFER_FRAMES     = $04        ; remember a slightly-early A press for this many frames
JUMP_CUT_SPEED_LO      = $00        ; releasing A while rising clamps velocity to -2.0 px/frame
JUMP_CUT_SPEED_HI      = $FE


.SEGMENT "ZEROPAGE"

HeroCoyoteFrames:      .res 1
HeroJumpBufferFrames:  .res 1


.SEGMENT "CODE"


.PROC InitializeHeroJumpAssist

    lda     #COYOTE_FRAMES
    sta     HeroCoyoteFrames

    lda     #$00
    sta     HeroJumpBufferFrames

    rts

.ENDPROC


.PROC CaptureHeroJumpInput

    lda     Controller1Pressed
    and     #BUTTON_A
    beq     captureHeroJumpInputDone

    lda     #JUMP_BUFFER_FRAMES
    sta     HeroJumpBufferFrames

  captureHeroJumpInputDone:
    rts

.ENDPROC


.PROC ApplyHeroJumpCut

    ; Grounded characters have no upward velocity to shorten.
    lda     HeroGrounded
    bne     applyHeroJumpCutDone

    ; Holding A preserves the full jump arc.
    lda     Controller1Current
    and     #BUTTON_A
    bne     applyHeroJumpCutDone

    ; Only change a rising (negative) velocity.
    lda     HeroVelocityYHi
    bpl     applyHeroJumpCutDone

    ; $FBxx-$FDxx are faster upward than -2.0. $FExx/$FFxx are already gentle enough.
    cmp     #JUMP_CUT_SPEED_HI
    bcs     applyHeroJumpCutDone

    lda     #JUMP_CUT_SPEED_LO
    sta     HeroVelocityYLo
    lda     #JUMP_CUT_SPEED_HI
    sta     HeroVelocityYHi

  applyHeroJumpCutDone:
    rts

.ENDPROC


.PROC TickHeroJumpAssist

    ; Standing on a surface continually refreshes coyote time. Once airborne, it counts down.
    lda     HeroGrounded
    beq     tickHeroCoyoteAirborne

    lda     #COYOTE_FRAMES
    sta     HeroCoyoteFrames
    jmp     tickHeroJumpBuffer

  tickHeroCoyoteAirborne:
    lda     HeroCoyoteFrames
    beq     tickHeroJumpBuffer
    dec     HeroCoyoteFrames

  tickHeroJumpBuffer:
    lda     HeroJumpBufferFrames
    beq     tickHeroJumpAssistDone
    dec     HeroJumpBufferFrames

  tickHeroJumpAssistDone:
    rts

.ENDPROC

; End of lib/game/jump_assist.s
