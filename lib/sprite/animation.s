;
; first_nes
; lib/sprite/animation.s
;
; Tiny two-frame walking animation for Neon Ranger.
;
; Standing uses tiles $36-$39. The step pose uses $3A-$3D. While any D-pad direction is held, bit 3
; of FrameCounter selects the pose, producing a relaxed ~7.5 Hz animation at NTSC frame rate.
;


.PROC UpdateHeroAnimation

    lda     Controller1Current
    and     #%11110000              ; any D-pad direction held?
    beq     heroStandingFrame

    lda     FrameCounter
    and     #%00001000
    beq     heroStandingFrame

  heroStepFrame:
    lda     #$3A
    sta     $0201
    lda     #$3B
    sta     $0205
    lda     #$3C
    sta     $0209
    lda     #$3D
    sta     $020D
    rts

  heroStandingFrame:
    lda     #$36
    sta     $0201
    lda     #$37
    sta     $0205
    lda     #$38
    sta     $0209
    lda     #$39
    sta     $020D
    rts

.ENDPROC

; End of lib/sprite/animation.s
