;
; first_nes
; lib/sprite/basic_movement.s
;
; Bounded horizontal movement for the 16x16 Neon Ranger platformer character.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
; Modernized to update logical player state instead of OAM directly, 2026.
;


HERO_X_MIN = $08
HERO_X_MAX = $E8                    ; 232 + 16px character width = 248


.PROC MoveHeroRight

    lda     HeroX
    cmp     #HERO_X_MAX
    bcs     moveHeroRightDone

    inc     HeroX
    lda     #HERO_FACING_RIGHT
    sta     HeroFacing

  moveHeroRightDone:
    rts

.ENDPROC


.PROC MoveHeroLeft

    lda     HeroX
    cmp     #HERO_X_MIN
    bcc     moveHeroLeftDone
    beq     moveHeroLeftDone

    dec     HeroX
    lda     #HERO_FACING_LEFT
    sta     HeroFacing

  moveHeroLeftDone:
    rts

.ENDPROC

; End of lib/sprite/basic_movement.s
