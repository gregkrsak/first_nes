;
; first_nes
; lib/game/platform_collision.s
;
; Small, explicit platform-surface collision system for the single-screen demo room.
;
; Each platform is represented by an inclusive X minimum, exclusive X maximum, and top-surface Y.
; The matching background art uses the same pixel/tile coordinates so what the player sees is what
; the collision system uses.
;


PLATFORM_COUNT = 4


.SEGMENT "ZEROPAGE"

CollisionOldFeetY:  .res 1
CollisionNewFeetY:  .res 1


.SEGMENT "CODE"


.PROC CheckHeroGroundSupport

    ; Only a grounded hero needs to ask whether there is still something beneath their feet.
    lda     HeroGrounded
    beq     checkHeroGroundSupportDone

    clc
    lda     HeroY
    adc     #HERO_HEIGHT
    sta     CollisionNewFeetY

    ldx     #$00
  supportLoop:
    ; Feet must sit exactly on this platform's top surface.
    lda     CollisionNewFeetY
    cmp     PlatformY,x
    bne     supportNext

    ; Horizontal overlap: hero left < platform right ...
    lda     HeroX
    cmp     PlatformXMax,x
    bcs     supportNext

    ; ...and hero right >= platform left. HeroX never exceeds 232, so +15 cannot wrap.
    clc
    adc     #(HERO_WIDTH-1)
    cmp     PlatformXMin,x
    bcc     supportNext

    ; Still supported.
    rts

  supportNext:
    inx
    cpx     #PLATFORM_COUNT
    bne     supportLoop

    ; Walking beyond every supporting surface begins a fall.
    lda     #HERO_AIRBORNE
    sta     HeroGrounded

  checkHeroGroundSupportDone:
    rts

.ENDPROC


.PROC ResolveHeroPlatformLanding

    lda     HeroGrounded
    bne     resolveHeroLandingDone

    ; A negative signed velocity means the hero is rising and cannot land on a top surface.
    lda     HeroVelocityYHi
    bmi     resolveHeroLandingDone

    clc
    lda     HeroPreviousY
    adc     #HERO_HEIGHT
    sta     CollisionOldFeetY

    clc
    lda     HeroY
    adc     #HERO_HEIGHT
    sta     CollisionNewFeetY

    ldx     #$00
  landingLoop:
    ; Horizontal overlap test.
    lda     HeroX
    cmp     PlatformXMax,x
    bcs     landingNext

    clc
    adc     #(HERO_WIDTH-1)
    cmp     PlatformXMin,x
    bcc     landingNext

    ; Previous feet must have been at or above the platform top.
    lda     CollisionOldFeetY
    cmp     PlatformY,x
    bcc     landingOldOkay
    beq     landingOldOkay
    bne     landingNext

  landingOldOkay:
    ; Current feet must have reached or crossed that same surface this frame.
    lda     CollisionNewFeetY
    cmp     PlatformY,x
    bcc     landingNext

    ; Snap the 16x16 hero precisely onto the platform and stop vertical motion.
    lda     PlatformY,x
    sec
    sbc     #HERO_HEIGHT
    sta     HeroY

    lda     #$00
    sta     HeroYSubpixel
    sta     HeroVelocityYLo
    sta     HeroVelocityYHi

    lda     #HERO_GROUNDED
    sta     HeroGrounded
    rts

  landingNext:
    inx
    cpx     #PLATFORM_COUNT
    bne     landingLoop

  resolveHeroLandingDone:
    rts

.ENDPROC


; -------------------------------------------------------------------------------------------------
; Collision surfaces. XMax is exclusive.
;
;   floor:   X 0..247,   Y 192
;   left:    X 24..87,   Y 160
;   center:  X 96..159,  Y 128
;   right:   X 168..231, Y 160
; -------------------------------------------------------------------------------------------------

PlatformXMin:
.BYTE $00, $18, $60, $A8

PlatformXMax:
.BYTE $F8, $58, $A0, $E8

PlatformY:
.BYTE $C0, $A0, $80, $A0

; End of lib/game/platform_collision.s
