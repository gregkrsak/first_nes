;
; first_nes
; lib/game/player.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Store Neon Ranger's logical player position/facing, then copy that logical state into the
;          CPU-side OAM shadow page used to draw the 16x16 character.
;
; The important beginner concept in this file is that HeroX/HeroY are the game's authoritative
; position. OAM is only a picture of that state. Physics and collision update HeroX/HeroY first;
; RenderHeroToOAM later copies the finished position into the four hardware-sprite entries.
;


HERO_START_X      = $78             ; 120: centers a 16px hero on the 256px-wide screen
HERO_START_Y      = $B0             ; 176: 16px hero stands on the floor beginning at Y=192
HERO_FACING_RIGHT = $00             ; Logical facing value used by the animation renderer
HERO_FACING_LEFT  = $01             ; Logical facing value used by the animation renderer


.SEGMENT "ZEROPAGE"

HeroX:       .res 1                 ; Top-left X coordinate of the complete 16x16 hero
HeroY:       .res 1                 ; Top-left Y coordinate of the complete 16x16 hero
HeroFacing:  .res 1                 ; HERO_FACING_RIGHT or HERO_FACING_LEFT


.SEGMENT "CODE"


; =================================================================================================
; InitializeHeroState
;
; Purpose:
;   Give Neon Ranger a known starting position and facing direction after reset.
;
; Inputs:
;   None.
;
; Outputs / side effects:
;   HeroX      = HERO_START_X
;   HeroY      = HERO_START_Y
;   HeroFacing = HERO_FACING_RIGHT
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC InitializeHeroState

    lda     #HERO_START_X           ; Load the horizontal spawn coordinate.
    sta     HeroX                   ; Save it as the logical player X position.

    lda     #HERO_START_Y           ; Load the vertical spawn coordinate.
    sta     HeroY                   ; Save it as the logical player Y position.

    lda     #HERO_FACING_RIGHT      ; Begin the demo facing toward the right side of the screen.
    sta     HeroFacing

    rts                             ; Return to the caller.

.ENDPROC


; =================================================================================================
; RenderHeroToOAM
;
; Purpose:
;   Convert the logical 16x16 player position into the four 8x8 hardware-sprite positions stored in
;   the CPU-side OAM shadow page at $0200-$02FF.
;
; Beginner notes:
;   Each NES hardware sprite uses four bytes in OAM: Y, tile number, attributes, X. This routine only
;   changes the Y and X bytes. Tile numbers and attributes are selected by UpdateHeroAnimation.
;
;   Neon Ranger is built from four sprites arranged like this:
;
;       upper-left   upper-right
;       lower-left   lower-right
;
;   The right column is HeroX + 8. The lower row is HeroY + 8.
;
; Inputs:
;   HeroX and HeroY contain the current logical top-left player position.
;
; Outputs / side effects:
;   Writes Y coordinates to $0200, $0204, $0208, $020C.
;   Writes X coordinates to $0203, $0207, $020B, $020F.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the main game loop.
; =================================================================================================

.PROC RenderHeroToOAM

    ; ---------------------------------
    ; Write the two upper Y coordinates.
    ; ---------------------------------

    lda     HeroY                   ; A = logical top edge of the 16x16 character.
    sta     $0200                   ; Sprite 0 Y: upper-left.
    sta     $0204                   ; Sprite 1 Y: upper-right.

    ; ---------------------------------
    ; Write the two lower Y coordinates.
    ; ---------------------------------

    clc                             ; Clear carry before adding the eight-pixel sprite height.
    adc     #$08                    ; A = HeroY + 8, the second row of the 16x16 character.
    sta     $0208                   ; Sprite 2 Y: lower-left.
    sta     $020C                   ; Sprite 3 Y: lower-right.

    ; ---------------------------------
    ; Write the two left X coordinates.
    ; ---------------------------------

    lda     HeroX                   ; A = logical left edge of the 16x16 character.
    sta     $0203                   ; Sprite 0 X: upper-left.
    sta     $020B                   ; Sprite 2 X: lower-left.

    ; ----------------------------------
    ; Write the two right X coordinates.
    ; ----------------------------------

    clc                             ; Clear carry before adding the eight-pixel sprite width.
    adc     #$08                    ; A = HeroX + 8, the second column of the 16x16 character.
    sta     $0207                   ; Sprite 1 X: upper-right.
    sta     $020F                   ; Sprite 3 X: lower-right.

    rts                             ; Return after the complete composite position is written.

.ENDPROC

; End of lib/game/player.s
