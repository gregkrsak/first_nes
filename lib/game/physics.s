;
; first_nes
; lib/game/physics.s
;
; Simple fixed-point platformer physics for Neon Ranger.
;
; Position uses 8.8 fixed point: HeroY is the visible whole-pixel byte and HeroYSubpixel stores the
; fractional byte. Vertical velocity is a signed 8.8 value split into high/low bytes.
;
; Core tuning constants live together here; jump-assist timing lives in lib/game/jump_assist.s.
;


HERO_WIDTH           = $10
HERO_HEIGHT          = $10

GRAVITY_LO           = $40          ; +0.25 px/frame^2
GRAVITY_HI           = $00
MAX_FALL_SPEED_LO    = $00          ; +4.0 px/frame
MAX_FALL_SPEED_HI    = $04
JUMP_SPEED_LO        = $80          ; -4.5 px/frame = $FB80 in signed 8.8
JUMP_SPEED_HI        = $FB

HERO_AIRBORNE        = $00
HERO_GROUNDED        = $01


.SEGMENT "ZEROPAGE"

HeroYSubpixel:     .res 1
HeroVelocityYLo:   .res 1
HeroVelocityYHi:   .res 1
HeroGrounded:      .res 1
HeroPreviousY:     .res 1


.SEGMENT "CODE"


.PROC InitializeHeroPhysics

    lda     #$00
    sta     HeroYSubpixel
    sta     HeroVelocityYLo
    sta     HeroVelocityYHi

    lda     #HERO_GROUNDED
    sta     HeroGrounded

    lda     HeroY
    sta     HeroPreviousY

    rts

.ENDPROC


.PROC TryStartHeroJump

    ; A press is buffered separately so a slightly-early press can survive until landing.
    lda     HeroJumpBufferFrames
    beq     tryStartHeroJumpDone

    ; A grounded hero may jump immediately. An airborne hero may still jump while coyote time lasts.
    lda     HeroGrounded
    bne     startHeroJump

    lda     HeroCoyoteFrames
    beq     tryStartHeroJumpDone

  startHeroJump:
    lda     #HERO_AIRBORNE
    sta     HeroGrounded

    lda     #$00
    sta     HeroCoyoteFrames
    sta     HeroJumpBufferFrames

    lda     #JUMP_SPEED_LO
    sta     HeroVelocityYLo
    lda     #JUMP_SPEED_HI
    sta     HeroVelocityYHi

  tryStartHeroJumpDone:
    rts

.ENDPROC


.PROC UpdateHeroVerticalPhysics

    lda     HeroY
    sta     HeroPreviousY

    ; A grounded hero is stationary vertically until a jump or loss of support makes them airborne.
    lda     HeroGrounded
    bne     updateHeroVerticalDone

    ; Position += signed 8.8 velocity.
    clc
    lda     HeroYSubpixel
    adc     HeroVelocityYLo
    sta     HeroYSubpixel

    lda     HeroY
    adc     HeroVelocityYHi
    sta     HeroY

    ; Velocity += +0.25 px/frame^2.
    clc
    lda     HeroVelocityYLo
    adc     #GRAVITY_LO
    sta     HeroVelocityYLo
    lda     HeroVelocityYHi
    adc     #GRAVITY_HI
    sta     HeroVelocityYHi

    ; Negative velocity means the hero is still rising; terminal fall speed only applies downward.
    bmi     updateHeroVerticalDone

    cmp     #MAX_FALL_SPEED_HI
    bcc     updateHeroVerticalDone
    bne     clampHeroFallSpeed

    lda     HeroVelocityYLo
    beq     updateHeroVerticalDone

  clampHeroFallSpeed:
    lda     #MAX_FALL_SPEED_LO
    sta     HeroVelocityYLo
    lda     #MAX_FALL_SPEED_HI
    sta     HeroVelocityYHi

  updateHeroVerticalDone:
    rts

.ENDPROC

; End of lib/game/physics.s
