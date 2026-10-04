;
; first_nes
; lib/game/platform_collision.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Provide a small, explicit platform-surface collision system for the single-screen Neon
;          Ranger demo room.
;
; Each platform is described by an inclusive left edge (XMin), an exclusive right edge (XMax), and a
; top-surface Y coordinate. The visible background platforms intentionally use the same coordinates
; so the collision system matches what the player sees.
;


PLATFORM_COUNT = 4                  ; Floor + left ledge + center ledge + right ledge


.SEGMENT "ZEROPAGE"

CollisionOldFeetY:  .res 1          ; Hero's bottom edge before this frame's vertical movement
CollisionNewFeetY:  .res 1          ; Hero's bottom edge after this frame's vertical movement


.SEGMENT "CODE"


; =================================================================================================
; CheckHeroGroundSupport
;
; Purpose:
;   Verify that a hero marked as grounded still overlaps a platform directly beneath their feet.
;   Horizontal movement can carry the hero beyond a ledge, so grounded state must be rechecked before
;   jump/gravity logic runs.
;
; Inputs:
;   HeroGrounded tells whether this check is necessary.
;   HeroX/HeroY contain the current logical top-left position.
;   PlatformXMin/PlatformXMax/PlatformY describe all collision surfaces.
;
; Outputs / side effects:
;   Leaves HeroGrounded unchanged when support is found.
;   Changes HeroGrounded to HERO_AIRBORNE when no platform supports the current position.
;   CollisionNewFeetY is used as temporary scratch storage.
;
; Registers:
;   A and X are modified. Y is preserved.
;
; Returns:
;   RTS as soon as support is found, or after all platform entries have been tested.
; =================================================================================================

.PROC CheckHeroGroundSupport

    lda     HeroGrounded            ; Airborne characters already know they are unsupported.
    beq     checkHeroGroundSupportDone

    clc                             ; Compute the Y coordinate of the hero's feet.
    lda     HeroY
    adc     #HERO_HEIGHT            ; Feet are one full 16-pixel character height below HeroY.
    sta     CollisionNewFeetY

    ldx     #$00                    ; X is the index into all three parallel platform tables.
  supportLoop:

    ; The hero's feet must sit exactly on the platform's top surface while grounded.
    lda     CollisionNewFeetY
    cmp     PlatformY,x
    bne     supportNext             ; Different Y means this platform cannot be the support surface.

    ; Horizontal overlap test, part 1: hero left edge must be left of the platform's exclusive XMax.
    lda     HeroX
    cmp     PlatformXMax,x
    bcs     supportNext             ; Hero begins at/after XMax, so there is no overlap.

    ; Horizontal overlap test, part 2: hero right-most pixel must reach PlatformXMin.
    ; HeroX never exceeds 232, so adding HERO_WIDTH-1 (15) cannot wrap the 8-bit coordinate.
    clc
    adc     #(HERO_WIDTH-1)
    cmp     PlatformXMin,x
    bcc     supportNext             ; Hero ends before the platform begins.

    rts                             ; Y matches and X ranges overlap: the hero is still supported.

  supportNext:
    inx                             ; Try the next collision surface.
    cpx     #PLATFORM_COUNT
    bne     supportLoop

    lda     #HERO_AIRBORNE          ; No table entry supported the feet, so gravity must take over.
    sta     HeroGrounded

  checkHeroGroundSupportDone:
    rts                             ; Return after preserving or clearing grounded state.

.ENDPROC


; =================================================================================================
; ResolveHeroPlatformLanding
;
; Purpose:
;   Detect a downward crossing of a platform's top surface and snap Neon Ranger cleanly onto it.
;   Comparing the old and new foot positions prevents a fast fall from stepping completely through
;   a thin one-way platform between frames.
;
; Inputs:
;   HeroGrounded indicates whether landing work is needed.
;   HeroPreviousY is the whole-pixel top edge before vertical movement.
;   HeroY is the whole-pixel top edge after vertical movement.
;   HeroVelocityYHi identifies rising (negative) versus falling (zero/positive) motion.
;   HeroX and the platform tables provide horizontal overlap information.
;
; Outputs / side effects:
;   On landing, HeroY is snapped to platformY - HERO_HEIGHT, subpixel position and vertical velocity
;   are cleared, and HeroGrounded becomes HERO_GROUNDED.
;
; Registers:
;   A and X are modified. Y is preserved.
;
; Returns:
;   RTS immediately after the first valid landing, or after every platform has been tested.
; =================================================================================================

.PROC ResolveHeroPlatformLanding

    lda     HeroGrounded            ; A hero already standing somewhere cannot land again this frame.
    bne     resolveHeroLandingDone

    lda     HeroVelocityYHi         ; Signed high byte tells us which vertical direction we are moving.
    bmi     resolveHeroLandingDone  ; Negative means rising; these platforms collide only from above.

    clc                             ; Compute feet position before this frame's vertical movement.
    lda     HeroPreviousY
    adc     #HERO_HEIGHT
    sta     CollisionOldFeetY

    clc                             ; Compute feet position after this frame's vertical movement.
    lda     HeroY
    adc     #HERO_HEIGHT
    sta     CollisionNewFeetY

    ldx     #$00                    ; Start with platform table entry zero.
  landingLoop:

    ; Horizontal overlap, part 1: hero left must be before the platform's exclusive right edge.
    lda     HeroX
    cmp     PlatformXMax,x
    bcs     landingNext

    ; Horizontal overlap, part 2: hero right-most pixel must reach the platform's left edge.
    clc
    adc     #(HERO_WIDTH-1)
    cmp     PlatformXMin,x
    bcc     landingNext

    ; Before movement, the feet must have been at or above the top surface.
    lda     CollisionOldFeetY
    cmp     PlatformY,x
    bcc     landingOldOkay          ; Strictly above is valid.
    beq     landingOldOkay          ; Exactly on the surface is also valid.
    bne     landingNext             ; Already below means we did not cross this surface from above.

  landingOldOkay:
    ; After movement, the feet must have reached or crossed that same surface.
    lda     CollisionNewFeetY
    cmp     PlatformY,x
    bcc     landingNext             ; Still above it: no landing yet.

    ; Snap the logical top-left Y so the 16-pixel-tall hero's feet sit exactly on PlatformY.
    lda     PlatformY,x
    sec
    sbc     #HERO_HEIGHT
    sta     HeroY

    ; Remove every trace of downward motion so the next frame begins from an exact resting state.
    lda     #$00
    sta     HeroYSubpixel
    sta     HeroVelocityYLo
    sta     HeroVelocityYHi

    lda     #HERO_GROUNDED          ; Record that a support surface now owns the vertical position.
    sta     HeroGrounded

    rts                             ; One hero can land on only one surface in this frame.

  landingNext:
    inx                             ; Advance to the next platform entry.
    cpx     #PLATFORM_COUNT
    bne     landingLoop

  resolveHeroLandingDone:
    rts                             ; No landing occurred, or the hero was not eligible to land.

.ENDPROC


; -------------------------------------------------------------------------------------------------
; Collision surfaces. The three tables are parallel: entry N in each table describes one platform.
; XMin is inclusive, XMax is exclusive, and Y is the top surface measured in screen pixels.
;
;   entry 0 - floor:   X 0..247,   Y 192
;   entry 1 - left:    X 24..87,   Y 160
;   entry 2 - center:  X 96..159,  Y 128
;   entry 3 - right:   X 168..231, Y 160
; -------------------------------------------------------------------------------------------------

PlatformXMin:
.BYTE $00, $18, $60, $A8            ; Inclusive left edges

PlatformXMax:
.BYTE $F8, $58, $A0, $E8            ; Exclusive right edges

PlatformY:
.BYTE $C0, $A0, $80, $A0            ; Top-surface Y coordinates

; End of lib/game/platform_collision.s
