;
; first_nes
; lib/sprite/basic_movement.s
;
; Very simple four-sprite movement routines for the 16x16 demo character.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
; Generalized from the original Luigi-like demo naming, 2026.
;


; =========================================
; Move the four-sprite demo character right
; =========================================

.PROC MoveHeroRight

    lda     $0203
    clc
    adc     #$01
    sta     $0203                   ; upper-left X

    lda     $0207
    clc
    adc     #$01
    sta     $0207                   ; upper-right X

    lda     $020b
    clc
    adc     #$01
    sta     $020b                   ; lower-left X
    
    lda     $020f
    clc
    adc     #$01
    sta     $020f                   ; lower-right X

    rts

.ENDPROC


; ========================================
; Move the four-sprite demo character left
; ========================================

.PROC MoveHeroLeft

    lda     $0203
    sec
    sbc     #$01
    sta     $0203                   ; upper-left X

    lda     $0207
    sec
    sbc     #$01
    sta     $0207                   ; upper-right X

    lda     $020b
    sec
    sbc     #$01
    sta     $020b                   ; lower-left X

    lda     $020f
    sec
    sbc     #$01
    sta     $020f                   ; lower-right X

    rts
    
.ENDPROC


; End of lib/sprite/basic_movement.s
