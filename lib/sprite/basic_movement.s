;
; first_nes
; lib/sprite/basic_movement.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Move Neon Ranger left or right by one pixel while keeping the complete 16x16 character
;          inside the intended horizontal play area.
;
; This file intentionally changes logical game state only. RenderHeroToOAM later copies HeroX into
; the four hardware-sprite X coordinates.
;


HERO_X_MIN = $08                    ; Left-most allowed logical X coordinate
HERO_X_MAX = $E8                    ; 232 + 16px character width = 248 at the right edge


; =================================================================================================
; MoveHeroRight
;
; Purpose:
;   Move the logical player position one pixel to the right, unless the player has already reached
;   HERO_X_MAX. Successful rightward movement also records that the hero is facing right.
;
; Inputs:
;   HeroX contains the current logical horizontal position.
;
; Outputs / side effects:
;   HeroX may increase by one.
;   HeroFacing becomes HERO_FACING_RIGHT when movement actually occurs.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the caller.
; =================================================================================================

.PROC MoveHeroRight

    lda     HeroX                   ; Read the current left edge of the 16x16 hero.
    cmp     #HERO_X_MAX            ; Has the hero already reached the right-most allowed position?
    bcs     moveHeroRightDone       ; Yes: do not move farther right.

    inc     HeroX                   ; No: advance exactly one pixel to the right.

    lda     #HERO_FACING_RIGHT      ; A successful rightward step also changes facing direction.
    sta     HeroFacing

  moveHeroRightDone:
    rts                             ; Return whether or not movement occurred.

.ENDPROC


; =================================================================================================
; MoveHeroLeft
;
; Purpose:
;   Move the logical player position one pixel to the left, unless the player has already reached
;   HERO_X_MIN. Successful leftward movement also records that the hero is facing left.
;
; Inputs:
;   HeroX contains the current logical horizontal position.
;
; Outputs / side effects:
;   HeroX may decrease by one.
;   HeroFacing becomes HERO_FACING_LEFT when movement actually occurs.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the caller.
; =================================================================================================

.PROC MoveHeroLeft

    lda     HeroX                   ; Read the current left edge of the 16x16 hero.
    cmp     #HERO_X_MIN            ; Compare it with the left-most allowed position.
    bcc     moveHeroLeftDone        ; Below the limit should never happen, but treat it as blocked.
    beq     moveHeroLeftDone        ; Exactly at the limit: do not move farther left.

    dec     HeroX                   ; Move exactly one pixel to the left.

    lda     #HERO_FACING_LEFT       ; A successful leftward step also changes facing direction.
    sta     HeroFacing

  moveHeroLeftDone:
    rts                             ; Return whether or not movement occurred.

.ENDPROC

; End of lib/sprite/basic_movement.s
