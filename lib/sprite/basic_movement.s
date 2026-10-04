;
; first_nes
; lib/sprite/basic_movement.s
;
; Bounded movement routines for the four-sprite 16x16 Neon Ranger demo character.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
; Expanded with four-direction bounds for the Neon Ranger demo, 2026.
;
; The character stays inside an 8-pixel horizontal margin and above the lowest neon-floor rows.
;


HERO_X_MIN = $08
HERO_X_MAX = $E8                    ; 232 + 16px character width = 248
HERO_Y_MIN = $10
HERO_Y_MAX = $C8                    ; keep the character above the lowest floor band


.PROC MoveHeroRight

    lda     $0203                   ; upper-left X is our canonical horizontal position
    cmp     #HERO_X_MAX
    bcs     moveHeroRightDone

    inc     $0203
    inc     $0207
    inc     $020B
    inc     $020F

  moveHeroRightDone:
    rts

.ENDPROC


.PROC MoveHeroLeft

    lda     $0203
    cmp     #HERO_X_MIN
    bcc     moveHeroLeftDone
    beq     moveHeroLeftDone

    dec     $0203
    dec     $0207
    dec     $020B
    dec     $020F

  moveHeroLeftDone:
    rts

.ENDPROC


.PROC MoveHeroUp

    lda     $0200                   ; upper-left Y is our canonical vertical position
    cmp     #HERO_Y_MIN
    bcc     moveHeroUpDone
    beq     moveHeroUpDone

    dec     $0200
    dec     $0204
    dec     $0208
    dec     $020C

  moveHeroUpDone:
    rts

.ENDPROC


.PROC MoveHeroDown

    lda     $0200
    cmp     #HERO_Y_MAX
    bcs     moveHeroDownDone

    inc     $0200
    inc     $0204
    inc     $0208
    inc     $020C

  moveHeroDownDone:
    rts

.ENDPROC

; End of lib/sprite/basic_movement.s
