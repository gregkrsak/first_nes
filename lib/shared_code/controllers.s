;
; first_nes
; lib/shared_code/controllers.s
;
; Complete controller polling for controller 1.
;
; The NES returns controller buttons serially in this order:
;   A, B, Select, Start, Up, Down, Left, Right
;
; This routine packs those eight reads into one byte where A is bit 0 and Right is bit 7. It also
; keeps the previous frame and a "newly pressed" mask so callers do not need to reread $4016.
;


.SEGMENT "ZEROPAGE"

Controller1Current:   .res 1
Controller1Previous:  .res 1
Controller1Pressed:   .res 1


.SEGMENT "CODE"


.PROC ReadController1

    ; Preserve last frame before collecting the new serial report.
    lda     Controller1Current
    sta     Controller1Previous

    ; Strobe controller 1: writing 1 then 0 freezes the current button state.
    lda     #$01
    sta     _JOY1
    lda     #$00
    sta     _JOY1

    ; Eight serial reads are rotated into the state byte. Because A arrives first, repeated RORs
    ; naturally leave A in bit 0 and Right in bit 7 after the eighth read.
    lda     #$00
    sta     Controller1Current

    ldx     #$08
   readController1Loop:
    lda     _JOY1
    lsr     a                       ; controller bit 0 -> carry
    ror     Controller1Current
    dex
    bne     readController1Loop

    ; Newly pressed = current AND NOT previous.
    lda     Controller1Previous
    eor     #$FF
    and     Controller1Current
    sta     Controller1Pressed

    rts

.ENDPROC

; End of lib/shared_code/controllers.s
