;
; first_nes
; lib/game/physics.s
;
; Simple fixed-point platformer physics for Neon Ranger.
;
; Position uses 8.8 fixed point: HeroY is the visible whole-pixel byte and HeroYSubpixel stores the
; fractional byte. Vertical velocity is a signed 8.8 value split into high/low bytes.
;


HERO_HEIGHT          = $10
FLOOR_Y              = $C0          ; visible floor begins at screen Y = 192
HERO_FLOOR_Y         = FLOOR_Y-HERO_HEIGHT

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

    lda     Controller1Pressed
    and     #BUTTON_A
    beq     tryStartHeroJumpDone

    lda     HeroGrounded
    beq     tryStartHeroJumpDone

    lda     #HERO_AIRBORNE
    sta     HeroGrounded

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

    ; A grounded hero is resting on the floor. General platform support checks arrive in #86.
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

    ; Only a non-negative velocity can land. While rising, bit 7 of the signed high byte is set.
    lda     HeroVelocityYHi
    bmi     applyHeroGravity

    lda     HeroY
    cmp     #HERO_FLOOR_Y
    bcc     applyHeroGravity

    ; Snap exactly onto the floor so the 16x16 sprite never sinks into the background geometry.
    lda     #HERO_FLOOR_Y
    sta     HeroY
    lda     #$00
    sta     HeroYSubpixel
    sta     HeroVelocityYLo
    sta     HeroVelocityYHi
    lda     #HERO_GROUNDED
    sta     HeroGrounded
    rts

  applyHeroGravity:
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
