;
; first_nes
; lib/game/physics.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Implement Neon Ranger's vertical platformer physics using simple signed 8.8 fixed-point
;          position and velocity values.
;
; Beginner note: 8.8 fixed point stores the whole-pixel part in one byte and the fractional part in
; another byte. For example, a low byte of $80 means one-half pixel. This lets the game accelerate
; smoothly even though the NES ultimately draws sprites only at whole-pixel coordinates.
;


HERO_WIDTH           = $10          ; 16 pixels wide
HERO_HEIGHT          = $10          ; 16 pixels tall

GRAVITY_LO           = $40          ; +0.25 px/frame^2: fractional half of gravity
GRAVITY_HI           = $00          ; +0.25 is positive and smaller than one whole pixel
MAX_FALL_SPEED_LO    = $00          ; +4.0 px/frame: fractional byte
MAX_FALL_SPEED_HI    = $04          ; +4.0 px/frame: whole/signed byte
JUMP_SPEED_LO        = $80          ; -4.5 px/frame = $FB80 in signed 8.8
JUMP_SPEED_HI        = $FB          ; Signed high byte; bit 7 set means the velocity is negative/upward

HERO_AIRBORNE        = $00          ; Zero is convenient for branch-on-zero airborne tests
HERO_GROUNDED        = $01          ; Nonzero means the hero is currently standing on a surface


.SEGMENT "ZEROPAGE"

HeroYSubpixel:     .res 1           ; Fractional 1/256-pixel portion of vertical position
HeroVelocityYLo:   .res 1           ; Fractional byte of signed 8.8 vertical velocity
HeroVelocityYHi:   .res 1           ; Whole/signed byte of signed 8.8 vertical velocity
HeroGrounded:      .res 1           ; HERO_GROUNDED or HERO_AIRBORNE
HeroPreviousY:     .res 1           ; Whole-pixel Y from the previous physics step, used by collision


.SEGMENT "CODE"


; =================================================================================================
; InitializeHeroPhysics
;
; Purpose:
;   Reset all vertical-physics state after power-on/reset so the hero begins stationary and standing
;   on the starting floor.
;
; Inputs:
;   HeroY must already contain the logical spawn Y set by InitializeHeroState.
;
; Outputs / side effects:
;   Fractional position and vertical velocity are cleared to zero.
;   HeroGrounded is set to HERO_GROUNDED.
;   HeroPreviousY receives the starting HeroY.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC InitializeHeroPhysics

    lda     #$00                    ; A zero value can initialize all fractional/velocity bytes.
    sta     HeroYSubpixel           ; Spawn exactly on a whole-pixel boundary.
    sta     HeroVelocityYLo         ; No fractional vertical speed at reset.
    sta     HeroVelocityYHi         ; No whole-pixel vertical speed at reset.

    lda     #HERO_GROUNDED          ; The spawn point is deliberately placed on the floor.
    sta     HeroGrounded

    lda     HeroY                   ; Collision needs a previous-frame Y value even on frame one.
    sta     HeroPreviousY

    rts                             ; Return to reset initialization.

.ENDPROC


; =================================================================================================
; TryStartHeroJump
;
; Purpose:
;   Convert a buffered A-button press into an actual upward jump when jumping is currently legal.
;   A jump is legal while grounded or while the short coyote-time grace counter is still nonzero.
;
; Inputs:
;   HeroJumpBufferFrames tells us whether a recent A press is waiting to be consumed.
;   HeroGrounded and HeroCoyoteFrames tell us whether the jump is allowed.
;
; Outputs / side effects:
;   On a successful jump, the hero becomes airborne, coyote/buffer counters are cleared, and vertical
;   velocity becomes JUMP_SPEED ($FB80 = -4.5 pixels per frame).
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS whether a jump starts or not.
; =================================================================================================

.PROC TryStartHeroJump

    lda     HeroJumpBufferFrames    ; Is there a recent A-button press waiting to be used?
    beq     tryStartHeroJumpDone    ; No buffered press means there is nothing to do.

    lda     HeroGrounded            ; A grounded hero may always start a normal jump.
    bne     startHeroJump

    lda     HeroCoyoteFrames        ; Airborne: check the short grace period after leaving a ledge.
    beq     tryStartHeroJumpDone    ; Grace period expired, so this buffered press cannot launch yet.

  startHeroJump:
    lda     #HERO_AIRBORNE          ; The instant the jump starts, the hero is no longer supported.
    sta     HeroGrounded

    lda     #$00                    ; Consume both forms of jump grace so they cannot be reused.
    sta     HeroCoyoteFrames
    sta     HeroJumpBufferFrames

    lda     #JUMP_SPEED_LO          ; Store the fractional byte of -4.5 pixels/frame.
    sta     HeroVelocityYLo

    lda     #JUMP_SPEED_HI          ; Store the signed whole byte. $FB is negative in two's complement.
    sta     HeroVelocityYHi

  tryStartHeroJumpDone:
    rts                             ; Return whether or not a jump actually started.

.ENDPROC


; =================================================================================================
; UpdateHeroVerticalPhysics
;
; Purpose:
;   Advance one frame of vertical motion for an airborne hero: remember the previous Y coordinate,
;   add signed velocity to position, add gravity to velocity, and clamp downward speed.
;
; Inputs:
;   HeroY/HeroYSubpixel contain the current 8.8 vertical position.
;   HeroVelocityYHi/HeroVelocityYLo contain signed 8.8 vertical velocity.
;   HeroGrounded tells us whether vertical integration should be skipped.
;
; Outputs / side effects:
;   HeroPreviousY receives the pre-movement whole-pixel Y.
;   Airborne position and velocity are updated by one frame.
;   Downward velocity will never exceed MAX_FALL_SPEED (+4.0 px/frame).
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the main loop.
; =================================================================================================

.PROC UpdateHeroVerticalPhysics

    lda     HeroY                   ; Preserve the old whole-pixel top edge for crossing tests.
    sta     HeroPreviousY

    lda     HeroGrounded            ; Grounded characters should not drift vertically under gravity.
    bne     updateHeroVerticalDone

    ; ---------------------------------------------------------------------------------------------
    ; Position += velocity.
    ;
    ; Add the fractional low bytes first. ADC then carries any overflow into the high-byte addition,
    ; exactly like adding a normal 16-bit integer split across two 8-bit registers/memory locations.
    ; ---------------------------------------------------------------------------------------------

    clc                             ; Start a fresh 16-bit addition with no incoming carry.
    lda     HeroYSubpixel
    adc     HeroVelocityYLo         ; Add the fractional portion of velocity.
    sta     HeroYSubpixel

    lda     HeroY
    adc     HeroVelocityYHi         ; Add the signed whole-pixel portion plus carry from the low byte.
    sta     HeroY

    ; ---------------------------------------------------------------------------------------------
    ; Velocity += gravity.
    ;
    ; GRAVITY is +$0040 in 8.8 fixed point, or +0.25 pixels/frame every frame. While rising, this
    ; steadily makes the negative velocity less negative; after the apex it becomes positive and the
    ; hero accelerates downward.
    ; ---------------------------------------------------------------------------------------------

    clc                             ; Begin the second 16-bit addition with carry cleared.
    lda     HeroVelocityYLo
    adc     #GRAVITY_LO
    sta     HeroVelocityYLo

    lda     HeroVelocityYHi
    adc     #GRAVITY_HI
    sta     HeroVelocityYHi

    ; ---------------------------------------------------------------------------------------------
    ; Clamp only downward velocity.
    ;
    ; BMI tests bit 7 of the signed high byte. If it is set, the velocity is negative and the hero is
    ; still moving upward, so a positive terminal-fall-speed clamp does not apply.
    ; ---------------------------------------------------------------------------------------------

    bmi     updateHeroVerticalDone  ; Negative high byte = still rising.

    cmp     #MAX_FALL_SPEED_HI      ; Compare whole-pixel speed against +4.
    bcc     updateHeroVerticalDone  ; Less than +4: still below terminal speed.
    bne     clampHeroFallSpeed      ; Greater than +4: definitely clamp.

    lda     HeroVelocityYLo         ; High byte equals +4; inspect the fractional remainder.
    beq     updateHeroVerticalDone  ; Exactly +4.0 is already the allowed maximum.

  clampHeroFallSpeed:
    lda     #MAX_FALL_SPEED_LO      ; Force velocity to exactly +4.0 pixels/frame.
    sta     HeroVelocityYLo
    lda     #MAX_FALL_SPEED_HI
    sta     HeroVelocityYHi

  updateHeroVerticalDone:
    rts                             ; Return after one vertical-physics step (or no step if grounded).

.ENDPROC

; End of lib/game/physics.s
