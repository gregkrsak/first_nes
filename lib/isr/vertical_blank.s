;
; first_nes
; lib/isr/vertical_blank.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Handle the once-per-frame PPU vertical-blank NMI by copying the prepared OAM shadow page
;          into PPU OAM and publishing a new frame number to foreground game logic.
;


; =================================================================================================
; ISR_Vertical_Blank
;
; Purpose:
;   Service the PPU's non-maskable interrupt (NMI) at the beginning of vertical blank. The handler is
;   intentionally short: preserve interrupted CPU registers, perform OAM DMA, increment FrameCounter,
;   restore the registers, and return to whatever foreground instruction was interrupted.
;
; Beginner notes:
;   NMI can arrive between almost any two foreground instructions. The 6502 automatically pushes the
;   return address and processor status, but it does NOT automatically save A, X, or Y. This handler
;   therefore saves those registers manually and restores them in reverse order before RTI.
;
; Inputs:
;   $0200-$02FF contains the CPU-side OAM shadow prepared by foreground code.
;   FrameCounter contains the frame number most recently published to MainLoop.
;
; Outputs / side effects:
;   Copies all 256 OAM-shadow bytes into PPU OAM through $4014 DMA.
;   Increments FrameCounter once.
;
; Registers:
;   A, X, and Y are temporarily modified but restored to their interrupted values before RTI.
;
; Returns:
;   RTI restores processor status and the interrupted program counter.
; =================================================================================================

.PROC ISR_Vertical_Blank

    ; ---------------------------------------------------------------------------------------------
    ; Save foreground register state.
    ;
    ; PHA can push only A, so X and Y are first transferred through A. The stack is LIFO (last in,
    ; first out), which is why restoration later happens in the opposite order.
    ; ---------------------------------------------------------------------------------------------

    pha                             ; Save the foreground accumulator.

    txa                             ; Move foreground X into A so it can be pushed.
    pha                             ; Save foreground X.

    tya                             ; Move foreground Y into A so it can be pushed.
    pha                             ; Save foreground Y.

    ; ---------------------------------------------------------------------------------------------
    ; Copy CPU OAM shadow RAM into the PPU's Object Attribute Memory.
    ; ---------------------------------------------------------------------------------------------

    lda     #$00                    ; Begin writing hardware OAM at entry/address zero.
    sta     _OAMADDR

    lda     #$02                    ; DMA source page $02 means CPU addresses $0200-$02FF.
    sta     _OAMDMA                 ; Writing $02 to $4014 performs the complete 256-byte transfer.

    ; ---------------------------------------------------------------------------------------------
    ; Publish a new frame to MainLoop.
    ; MainLoop waits for this byte to differ from LastFrameCounter before running another update.
    ; ---------------------------------------------------------------------------------------------

    inc     FrameCounter            ; One more display frame has reached vblank.

    ; ---------------------------------------------------------------------------------------------
    ; Restore foreground register state in reverse order: Y, then X, then A.
    ; ---------------------------------------------------------------------------------------------

    pla                             ; Recover the saved Y value into A.
    tay                             ; Restore Y.

    pla                             ; Recover the saved X value into A.
    tax                             ; Restore X.

    pla                             ; Restore the original accumulator last.

    rti                             ; Resume the interrupted foreground instruction stream.

.ENDPROC

; End of lib/isr/vertical_blank.s
