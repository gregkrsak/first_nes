;
; first_nes
; lib/shared_code/apu.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Provide small reusable Audio Processing Unit (APU) helper routines for NES startup and
;          future sound work.
;


; =================================================================================================
; DisableAudioOutput
;
; Purpose:
;   Disable the APU frame IRQ and DMC IRQ sources during reset so the starter program cannot receive
;   unexpected maskable audio interrupts before it has installed real audio logic.
;
; Inputs:
;   None.
;
; Outputs / side effects:
;   Writes %01000000 to the APU frame-counter register at $4017.
;   Writes the same value to the DMC control/frequency register at $4010.
;
; Beginner note:
;   This routine's name is historical: the important job performed here is disabling interrupt
;   sources. first_nes does not yet implement music or sound-effect channel setup.
;
; Registers:
;   A is modified. X and Y are preserved.
;
; Returns:
;   RTS to the reset routine.
; =================================================================================================

.PROC DisableAudioOutput

    lda     #%01000000              ; Bit 6 disables the APU frame interrupt in the frame counter.
    sta     _FR_COUNTER             ; $4017: disable APU frame IRQ generation.
    sta     _DMC_FREQ               ; $4010: bit 7 remains clear, disabling DMC IRQ generation.

    rts                             ; Return with audio interrupt sources safely disabled.

.ENDPROC

; End of lib/shared_code/apu.s
