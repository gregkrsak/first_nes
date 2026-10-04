;
; first_nes
; lib/shared_code/controllers.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Read controller 1 once per frame and expose current, previous, and newly-pressed button
;          masks to the rest of the game.
;
; The NES reports controller buttons serially in this order:
;   A, B, Select, Start, Up, Down, Left, Right
;
; first_nes packs those eight reads into one byte where A is bit 0 and Right is bit 7.
;


.SEGMENT "ZEROPAGE"

Controller1Current:   .res 1        ; Buttons held during the current frame
Controller1Previous:  .res 1        ; Buttons that were held during the previous frame
Controller1Pressed:   .res 1        ; Buttons that changed from released to pressed this frame


.SEGMENT "CODE"


; =================================================================================================
; ReadController1
;
; Purpose:
;   Latch controller 1's current physical button state, read all eight serial bits from $4016, pack
;   them into Controller1Current, and derive a separate newly-pressed mask.
;
; Inputs:
;   Controller1Current contains the previous frame's held-button state before this routine begins.
;
; Outputs / side effects:
;   Controller1Previous receives the old Controller1Current value.
;   Controller1Current receives the freshly-read eight-button state.
;   Controller1Pressed = Controller1Current AND (NOT Controller1Previous).
;   Writes the standard 1-then-0 controller strobe sequence to $4016.
;
; Registers:
;   A and X are modified. Y is preserved.
;
; Returns:
;   RTS to the main game loop.
; =================================================================================================

.PROC ReadController1

    ; Preserve the old held-button byte before replacing it with the new serial report.
    lda     Controller1Current
    sta     Controller1Previous

    ; ---------------------------------------------------------------------------------------------
    ; Strobe the controller.
    ; Writing 1 and then 0 to $4016 asks the NES controller hardware to latch the current buttons so
    ; the program can shift them out one at a time without the report changing halfway through.
    ; ---------------------------------------------------------------------------------------------

    lda     #$01                    ; Strobe high: ask the controller to capture its button state.
    sta     _JOY1

    lda     #$00                    ; Strobe low: begin serial shifting on subsequent reads.
    sta     _JOY1

    ; Clear the destination byte before rotating eight new serial bits into it.
    lda     #$00
    sta     Controller1Current

    ldx     #$08                    ; Exactly eight standard NES buttons must be read.
   readController1Loop:
    lda     _JOY1                   ; Read the next serial controller report from $4016.
    lsr     a                       ; Move report bit 0 into the 6502 carry flag.
    ror     Controller1Current      ; Rotate carry into the state byte while older bits move right.

    dex                             ; One fewer controller bit remains.
    bne     readController1Loop

    ; ---------------------------------------------------------------------------------------------
    ; Calculate edge-triggered presses.
    ;
    ; previous XOR $FF produces NOT(previous). ANDing that with current leaves only buttons that are
    ; down now but were not down last frame.
    ; ---------------------------------------------------------------------------------------------

    lda     Controller1Previous
    eor     #$FF                    ; A = NOT previous.
    and     Controller1Current      ; A = current AND NOT previous.
    sta     Controller1Pressed

    rts                             ; Controller state for this frame is ready for game logic.

.ENDPROC

; End of lib/shared_code/controllers.s
