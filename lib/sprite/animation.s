;
; first_nes
; lib/sprite/animation.s
;
; Explicit Neon Ranger animation states plus left/right facing.
;
; A 16x16 character is composed from four 8x8 sprites. Facing left does not consume mirrored CHR
; artwork: the renderer swaps the left/right tile assignments and sets OAM's horizontal-flip bit.
;


HERO_ANIM_IDLE = $00
HERO_ANIM_RUN  = $01
HERO_ANIM_JUMP = $02
HERO_ANIM_FALL = $03

SPRITE_ATTR_RIGHT = %00000010       ; sprite palette 2
SPRITE_ATTR_LEFT  = %01000010       ; palette 2 + horizontal flip


.SEGMENT "ZEROPAGE"

HeroAnimationState: .res 1


.SEGMENT "CODE"


.PROC UpdateHeroAnimation

    ; Airborne state takes priority over controller input.
    lda     HeroGrounded
    bne     chooseGroundedHeroFrame

    lda     HeroVelocityYHi
    bmi     chooseJumpHeroFrame

  chooseFallHeroFrame:
    lda     #HERO_ANIM_FALL
    sta     HeroAnimationState
    ldx     #$03
    jmp     renderHeroAnimationFrame

  chooseJumpHeroFrame:
    lda     #HERO_ANIM_JUMP
    sta     HeroAnimationState
    ldx     #$02
    jmp     renderHeroAnimationFrame

  chooseGroundedHeroFrame:
    lda     Controller1Current
    and     #%11000000              ; Left or Right held?
    beq     chooseIdleHeroFrame

    lda     #HERO_ANIM_RUN
    sta     HeroAnimationState

    ; Running alternates the standing and stepping poses every eight frames.
    lda     FrameCounter
    and     #%00001000
    beq     chooseRunStandingFrame

    ldx     #$01
    jmp     renderHeroAnimationFrame

  chooseRunStandingFrame:
    ldx     #$00
    jmp     renderHeroAnimationFrame

  chooseIdleHeroFrame:
    lda     #HERO_ANIM_IDLE
    sta     HeroAnimationState
    ldx     #$00

  renderHeroAnimationFrame:
    lda     HeroFacing
    cmp     #HERO_FACING_LEFT
    beq     renderHeroFacingLeft

  renderHeroFacingRight:
    lda     HeroFrameTopLeft,x
    sta     $0201
    lda     HeroFrameTopRight,x
    sta     $0205
    lda     HeroFrameBottomLeft,x
    sta     $0209
    lda     HeroFrameBottomRight,x
    sta     $020D

    lda     #SPRITE_ATTR_RIGHT
    sta     $0202
    sta     $0206
    sta     $020A
    sta     $020E
    rts

  renderHeroFacingLeft:
    ; Swap tile columns, then horizontally flip each 8x8 hardware sprite. Together those operations
    ; mirror the complete 16x16 character rather than mirroring four sprites in place.
    lda     HeroFrameTopRight,x
    sta     $0201
    lda     HeroFrameTopLeft,x
    sta     $0205
    lda     HeroFrameBottomRight,x
    sta     $0209
    lda     HeroFrameBottomLeft,x
    sta     $020D

    lda     #SPRITE_ATTR_LEFT
    sta     $0202
    sta     $0206
    sta     $020A
    sta     $020E
    rts

.ENDPROC


; Frame tables: idle/standing, run step, jump, fall.
HeroFrameTopLeft:
.BYTE $36, $3A, $36, $36

HeroFrameTopRight:
.BYTE $37, $3B, $37, $37

HeroFrameBottomLeft:
.BYTE $38, $3C, $4A, $4C

HeroFrameBottomRight:
.BYTE $39, $3D, $4B, $4D

; End of lib/sprite/animation.s
