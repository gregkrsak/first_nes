;
; first_nes
; lib/game/player.s
;
; Authoritative player state and projection into the OAM shadow page.
;
; The platformer code treats HeroX/HeroY as game state. OAM is only a render target. Keeping those
; concerns separate makes gravity, collision, scrolling, and animation much easier to reason about.
;


HERO_START_X      = $78             ; 120: centers a 16px hero on the 256px-wide screen
HERO_START_Y      = $B0             ; 176: 16px hero stands on the floor beginning at Y=192
HERO_FACING_RIGHT = $00
HERO_FACING_LEFT  = $01


.SEGMENT "ZEROPAGE"

HeroX:       .res 1
HeroY:       .res 1
HeroFacing:  .res 1


.SEGMENT "CODE"


.PROC InitializeHeroState

    lda     #HERO_START_X
    sta     HeroX
    lda     #HERO_START_Y
    sta     HeroY
    lda     #HERO_FACING_RIGHT
    sta     HeroFacing

    rts

.ENDPROC


.PROC RenderHeroToOAM

    ; Upper row Y coordinates.
    lda     HeroY
    sta     $0200
    sta     $0204

    ; Lower row is eight pixels below the logical top-left position.
    clc
    adc     #$08
    sta     $0208
    sta     $020C

    ; Left column X coordinates.
    lda     HeroX
    sta     $0203
    sta     $020B

    ; Right column is eight pixels to the right.
    clc
    adc     #$08
    sta     $0207
    sta     $020F

    rts

.ENDPROC

; End of lib/game/player.s
