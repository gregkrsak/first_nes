;
; first_nes
; lib/game/jump_assist.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Add small, explicit quality-of-life helpers to Neon Ranger's jump: coyote time, jump
;          buffering, and variable jump height when the A button is released early.
;
; These helpers do not replace the core gravity code in physics.s. They only decide when a jump may
; begin and whether an upward velocity should be shortened.
;


COYOTE_FRAMES          = $04        ; Grace frames after walking off a platform
JUMP_BUFFER_FRAMES     = $04        ; Remember a slightly-early A press for this many frames
JUMP_CUT_SPEED_LO      = $00        ; Low byte of -2.0 px/frame in signed 8.8 fixed point
JUMP_CUT_SPEED_HI      = $FE        ; High byte of -2.0 px/frame in signed 8.8 fixed point


.SEGMENT "ZEROPAGE"

HeroCoyoteFrames:      .res 1       ; Frames remaining in the "just left the ledge" grace period
HeroJumpBufferFrames:  .res 1       ; Frames remaining for a recent A press to become a jump


.SEGMENT "CODE"


; =================================================================================================
; InitializeHeroJumpAssist
;
; Purpose:
;   Put the jump-assist counters into a predictable state after reset.
;
; Inputs:
;   None.
;
; Outputs / side effects:
;   HeroCoyoteFrames starts full because the hero initially stands on the floor.
;   HeroJumpBufferFrames starts empty because no A press has occurred yet.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC InitializeHeroJumpAssist

    lda     #COYOTE_FRAMES          ; A grounded spawn begins with the full grace window available.
    sta     HeroCoyoteFrames

    lda     #$00                    ; No button press is waiting to become a jump at reset.
    sta     HeroJumpBufferFrames

    rts                             ; Return to reset initialization.

.ENDPROC


; =================================================================================================
; CaptureHeroJumpInput
;
; Purpose:
;   Watch for a NEW A-button press and, when one occurs, load the jump-buffer countdown. Using the
;   newly-pressed mask means holding A does not continually refresh the buffer every frame.
;
; Inputs:
;   Controller1Pressed contains buttons that changed from released to pressed this frame.
;
; Outputs / side effects:
;   HeroJumpBufferFrames becomes JUMP_BUFFER_FRAMES when A was newly pressed.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to MainLoop.
; =================================================================================================

.PROC CaptureHeroJumpInput

    lda     Controller1Pressed      ; Read only edge-triggered button presses for this frame.
    and     #BUTTON_A               ; Ignore every button except A.
    beq     captureHeroJumpInputDone; A was not newly pressed, so leave the existing timer alone.

    lda     #JUMP_BUFFER_FRAMES     ; Remember this press for a few frames.
    sta     HeroJumpBufferFrames    ; A landing during this window may immediately consume it.

  captureHeroJumpInputDone:
    rts                             ; Return whether or not the buffer was refreshed.

.ENDPROC


; =================================================================================================
; ApplyHeroJumpCut
;
; Purpose:
;   Make jump height depend on how long A is held. If A is released while the hero is moving upward
;   faster than -2.0 px/frame, clamp the upward velocity to -2.0. This produces a short hop from a
;   tap while preserving the full arc when A remains held.
;
; Inputs:
;   HeroGrounded tells whether jump-cut logic is relevant.
;   Controller1Current tells whether A is still held.
;   HeroVelocityYHi/Lo contain signed 8.8 vertical velocity.
;
; Outputs / side effects:
;   HeroVelocityYHi/Lo may be replaced with JUMP_CUT_SPEED.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to MainLoop.
; =================================================================================================

.PROC ApplyHeroJumpCut

    lda     HeroGrounded            ; A grounded hero has no active upward jump to shorten.
    bne     applyHeroJumpCutDone

    lda     Controller1Current      ; Variable height depends on the button's held state.
    and     #BUTTON_A
    bne     applyHeroJumpCutDone    ; A is still held, so preserve the full upward velocity.

    lda     HeroVelocityYHi         ; Inspect the signed whole-byte portion of vertical velocity.
    bpl     applyHeroJumpCutDone    ; Positive/zero means falling or at the apex, so do nothing.

    ; $FBxx-$FDxx are more negative (faster upward) than -2.0. $FExx/$FFxx are already gentle enough.
    cmp     #JUMP_CUT_SPEED_HI
    bcs     applyHeroJumpCutDone

    lda     #JUMP_CUT_SPEED_LO      ; Replace the faster upward speed with exactly -2.0 px/frame.
    sta     HeroVelocityYLo
    lda     #JUMP_CUT_SPEED_HI
    sta     HeroVelocityYHi

  applyHeroJumpCutDone:
    rts                             ; Return after either preserving or shortening the jump.

.ENDPROC


; =================================================================================================
; TickHeroJumpAssist
;
; Purpose:
;   Advance the small frame counters once per game frame. Grounded play continually refreshes coyote
;   time; airborne play counts it down. The jump buffer always counts down until consumed or expired.
;
; Inputs:
;   HeroGrounded, HeroCoyoteFrames, and HeroJumpBufferFrames contain current state.
;
; Outputs / side effects:
;   Refreshes or decrements HeroCoyoteFrames.
;   Decrements HeroJumpBufferFrames when nonzero.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to MainLoop.
; =================================================================================================

.PROC TickHeroJumpAssist

    lda     HeroGrounded            ; Ground contact determines whether coyote time refreshes or ages.
    beq     tickHeroCoyoteAirborne  ; Zero means airborne: begin/continue counting down.

    lda     #COYOTE_FRAMES          ; Standing on a surface continuously restores the full window.
    sta     HeroCoyoteFrames
    jmp     tickHeroJumpBuffer      ; Skip the airborne countdown logic.

  tickHeroCoyoteAirborne:
    lda     HeroCoyoteFrames        ; Do not DEC an already-zero byte or it would wrap to $FF.
    beq     tickHeroJumpBuffer
    dec     HeroCoyoteFrames        ; One more frame has passed since leaving support.

  tickHeroJumpBuffer:
    lda     HeroJumpBufferFrames    ; The buffered press expires independently of coyote time.
    beq     tickHeroJumpAssistDone  ; Again, avoid decrementing zero and wrapping around.
    dec     HeroJumpBufferFrames    ; Age the remembered A press by one frame.

  tickHeroJumpAssistDone:
    rts                             ; Return after both helper timers are updated.

.ENDPROC

; End of lib/game/jump_assist.s
