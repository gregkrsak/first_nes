;
; first_nes
; lib/sprite/animation.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Choose Neon Ranger's idle/run/jump/fall frame and write the matching tile numbers and
;          sprite attributes into the CPU-side OAM shadow page.
;
; Neon Ranger is a 16x16 composite character built from four 8x8 NES hardware sprites. Facing left
; does not require duplicate mirrored CHR artwork: the renderer swaps the left/right tile columns and
; sets OAM's horizontal-flip bit for each 8x8 sprite.
;


HERO_ANIM_IDLE = $00                ; Standing still on a surface
HERO_ANIM_RUN  = $01                ; Moving horizontally on a surface
HERO_ANIM_JUMP = $02                ; Airborne with negative/upward vertical velocity
HERO_ANIM_FALL = $03                ; Airborne with zero/positive/downward vertical velocity

SPRITE_ATTR_RIGHT = %00000010       ; Sprite palette 2, no horizontal flip
SPRITE_ATTR_LEFT  = %01000010       ; Sprite palette 2 + OAM horizontal-flip bit 6


.SEGMENT "ZEROPAGE"

HeroAnimationState: .res 1          ; One of HERO_ANIM_IDLE/RUN/JUMP/FALL


.SEGMENT "CODE"


; =================================================================================================
; UpdateHeroAnimation
;
; Purpose:
;   Decide which animation state Neon Ranger should display, choose one row from the four frame
;   tables, then write tile numbers and sprite attributes to the OAM shadow entries at $0200-$020F.
;
; Decision order:
;   1. Airborne state wins over controller input.
;   2. Negative vertical velocity selects JUMP; zero/positive selects FALL.
;   3. A grounded hero holding Left or Right selects RUN.
;   4. Otherwise the grounded hero selects IDLE.
;
; Inputs:
;   HeroGrounded, HeroVelocityYHi, Controller1Current, FrameCounter, and HeroFacing.
;
; Outputs / side effects:
;   HeroAnimationState is updated.
;   OAM tile bytes $0201/$0205/$0209/$020D are updated.
;   OAM attribute bytes $0202/$0206/$020A/$020E are updated.
;
; Registers:
;   A and X are modified. Y is preserved.
;
; Returns:
;   RTS after rendering either the right-facing or left-facing composite frame.
; =================================================================================================

.PROC UpdateHeroAnimation

    ; ---------------------------------------
    ; First decide airborne versus grounded.
    ; ---------------------------------------

    lda     HeroGrounded            ; Ground state takes priority over horizontal button state.
    bne     chooseGroundedHeroFrame ; Nonzero means the hero is standing on a surface.

    lda     HeroVelocityYHi         ; Signed high byte tells us whether airborne motion is up or down.
    bmi     chooseJumpHeroFrame     ; Bit 7 set = negative velocity = rising.

  chooseFallHeroFrame:
    lda     #HERO_ANIM_FALL         ; Zero/positive velocity means the hero is at/after the apex.
    sta     HeroAnimationState
    ldx     #$03                    ; Frame-table index 3 is the falling pose.
    jmp     renderHeroAnimationFrame

  chooseJumpHeroFrame:
    lda     #HERO_ANIM_JUMP
    sta     HeroAnimationState
    ldx     #$02                    ; Frame-table index 2 is the rising/jump pose.
    jmp     renderHeroAnimationFrame

    ; -----------------------------------------
    ; Grounded: choose run versus idle graphics.
    ; -----------------------------------------

  chooseGroundedHeroFrame:
    lda     Controller1Current      ; Read the held-button mask for this frame.
    and     #%11000000              ; Keep only Left (bit 6) and Right (bit 7).
    beq     chooseIdleHeroFrame     ; Neither horizontal direction is held.

    lda     #HERO_ANIM_RUN
    sta     HeroAnimationState

    ; Toggle the run pose every eight frames. FrameCounter bit 3 changes state every 8 increments.
    lda     FrameCounter
    and     #%00001000              ; Isolate frame-counter bit 3.
    beq     chooseRunStandingFrame  ; Zero half of the cycle reuses the standing frame.

    ldx     #$01                    ; Table index 1 is the stepping frame.
    jmp     renderHeroAnimationFrame

  chooseRunStandingFrame:
    ldx     #$00                    ; Table index 0 is the normal standing frame.
    jmp     renderHeroAnimationFrame

  chooseIdleHeroFrame:
    lda     #HERO_ANIM_IDLE
    sta     HeroAnimationState
    ldx     #$00                    ; Idle also uses frame-table index 0.

    ; ----------------------------------------------------------
    ; X now selects one entry from each of the four frame tables.
    ; ----------------------------------------------------------

  renderHeroAnimationFrame:
    lda     HeroFacing
    cmp     #HERO_FACING_LEFT
    beq     renderHeroFacingLeft

    ; ---------------------------------------------------------------------------------------------
    ; Right-facing composite.
    ; Tile bytes stay in natural left/right order and no hardware horizontal flip is requested.
    ; ---------------------------------------------------------------------------------------------

  renderHeroFacingRight:
    lda     HeroFrameTopLeft,x      ; Upper-left tile number for the selected animation frame.
    sta     $0201                   ; Sprite 0 tile byte.

    lda     HeroFrameTopRight,x     ; Upper-right tile number.
    sta     $0205                   ; Sprite 1 tile byte.

    lda     HeroFrameBottomLeft,x   ; Lower-left tile number.
    sta     $0209                   ; Sprite 2 tile byte.

    lda     HeroFrameBottomRight,x  ; Lower-right tile number.
    sta     $020D                   ; Sprite 3 tile byte.

    lda     #SPRITE_ATTR_RIGHT      ; Palette 2, no horizontal flip.
    sta     $0202                   ; Sprite 0 attributes.
    sta     $0206                   ; Sprite 1 attributes.
    sta     $020A                   ; Sprite 2 attributes.
    sta     $020E                   ; Sprite 3 attributes.

    rts                             ; Right-facing frame is complete.

    ; ---------------------------------------------------------------------------------------------
    ; Left-facing composite.
    ;
    ; Flipping each 8x8 sprite in place is not enough for a 16x16 character: the left and right
    ; halves must also trade places. We therefore swap tile columns AND set OAM's horizontal-flip bit.
    ; ---------------------------------------------------------------------------------------------

  renderHeroFacingLeft:
    lda     HeroFrameTopRight,x     ; Former right tile becomes the displayed left tile.
    sta     $0201

    lda     HeroFrameTopLeft,x      ; Former left tile becomes the displayed right tile.
    sta     $0205

    lda     HeroFrameBottomRight,x  ; Same column swap for the lower row.
    sta     $0209

    lda     HeroFrameBottomLeft,x
    sta     $020D

    lda     #SPRITE_ATTR_LEFT       ; Palette 2 plus horizontal flip on every 8x8 component.
    sta     $0202
    sta     $0206
    sta     $020A
    sta     $020E

    rts                             ; Left-facing frame is complete.

.ENDPROC


; -------------------------------------------------------------------------------------------------
; Animation frame tables.
;
; X index: 0 = standing/idle, 1 = run step, 2 = jump, 3 = fall.
; Each table supplies one quadrant of the composite 16x16 character.
; -------------------------------------------------------------------------------------------------

HeroFrameTopLeft:
.BYTE $36, $3A, $36, $36            ; Upper-left CHR tile for each animation state

HeroFrameTopRight:
.BYTE $37, $3B, $37, $37            ; Upper-right CHR tile for each animation state

HeroFrameBottomLeft:
.BYTE $38, $3C, $4A, $4C            ; Lower-left CHR tile for each animation state

HeroFrameBottomRight:
.BYTE $39, $3D, $4B, $4D            ; Lower-right CHR tile for each animation state

; End of lib/sprite/animation.s
