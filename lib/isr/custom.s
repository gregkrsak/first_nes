;
; first_nes
; lib/isr/custom.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Provide a safe placeholder handler for the 6502's shared IRQ/BRK vector at $FFFE-$FFFF.
;
; The current NROM demo disables the APU interrupt sources it knows about and has no mapper IRQ, so
; this routine normally has no interrupt-specific work to perform. It still preserves A/X/Y correctly
; so future beginners can add IRQ logic without first having to repair the handler framework.
;


; =================================================================================================
; ISR_IRQ_BRK
;
; Purpose:
;   Handle a maskable hardware IRQ or a BRK instruction. On the 6502, both sources enter through the
;   same vector, so a more advanced program would inspect the saved processor state or device status
;   to determine which source needs service.
;
; Inputs:
;   None are currently required by first_nes.
;
; Outputs / side effects:
;   No game or hardware state is intentionally changed yet. A placeholder NOP marks the future work
;   area while the interrupted A/X/Y values are preserved and restored.
;
; Registers:
;   A, X, and Y are temporarily modified but restored before RTI.
;
; Returns:
;   RTI restores the processor status and interrupted program counter.
; =================================================================================================

.PROC ISR_IRQ_BRK

    ; Save the interrupted foreground accumulator first.
    pha

    ; PHA cannot push X directly, so transfer X through A and push the result.
    txa
    pha

    ; Do the same for Y. This is the last register pushed, so it will be the first restored.
    tya
    pha

    ; ---------------------------------------------------------------------------------------------
    ; No IRQ/BRK-specific work is required by the current demo. Future code would acknowledge the
    ; appropriate interrupt source here before returning.
    ; ---------------------------------------------------------------------------------------------

    nop                             ; Intentional placeholder; has no program-visible effect.

    ; Restore registers in exact reverse order because the 6502 stack is last-in, first-out.
    pla
    tay                             ; Restore Y.

    pla
    tax                             ; Restore X.

    pla                             ; Restore A.

    rti                             ; Resume the interrupted code path.

.ENDPROC

; End of lib/isr/custom.s
