;
; first_nes
; lib/shared_code/cpu.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Provide reusable CPU-side helper routines, including an intentional endless loop and the
;          reset-time RAM initialization used by ISR_PowerOn_Reset.
;


; =================================================================================================
; EndlessLoop
;
; Purpose:
;   Stop normal forward program progress by jumping to the same label forever. This is useful while
;   learning/debugging when you deliberately want the CPU to remain in one safe location.
;
; Inputs:
;   None.
;
; Outputs / side effects:
;   None, other than consuming CPU time forever.
;
; Registers:
;   A, X, and Y are preserved.
;
; Returns:
;   It does not normally return. The RTS remains unreachable documentation of the procedure shape.
; =================================================================================================

.PROC EndlessLoop

   endlessLoop:
    jmp     endlessLoop             ; Jump back to the same address forever.

    rts                             ; Unreachable during normal execution.

.ENDPROC


; =================================================================================================
; __ClearCPUMemory
;
; Purpose:
;   Initialize the NES's internal CPU RAM to predictable values during reset.
;
; Why this routine is unusual:
;   It is intentionally NOT a .PROC and is entered with JMP rather than JSR. After clearing memory it
;   jumps directly back into ISR_PowerOn_Reset at __CPUMemoryCleared. This preserves the control-flow
;   style of the original first_nes project.
;
;   Most RAM is filled with $00. The OAM shadow page at $0200-$02FF is different: all 256 bytes are
;   filled with _OAM_HIDDEN_Y ($FE) first. Later, LoadSpriteData overwrites the active sprite entries.
;   Because OAM DMA copies the entire page every frame, this keeps every unused sprite safely off-screen.
;
; Inputs:
;   _RAM_CLEAR_VALUE and _OAM_HIDDEN_Y are constants defined in cpu.inc.
;
; Outputs / side effects:
;   Initializes CPU RAM pages $0000-$07FF as described above.
;
; Registers:
;   A and X are modified. Y is preserved.
;
; Returns:
;   Does not RTS. Jumps to ISR_PowerOn_Reset::__CPUMemoryCleared.
; =================================================================================================

__ClearCPUMemory:
    ldx     #$00                    ; X will visit every byte offset $00-$FF exactly once.

   __clearMemoryLoop:
    lda     #_RAM_CLEAR_VALUE       ; Most internal RAM should begin at the known value $00.

    sta     $0000, x                ; Zero page / general RAM.
    sta     $0100, x                ; Hardware stack page. The active stack starts near $01FF.
    sta     $0300, x                ; General RAM.
    sta     $0400, x                ; General RAM.
    sta     $0500, x                ; General RAM.
    sta     $0600, x                ; General RAM.
    sta     $0700, x                ; General RAM.

    ; $0200-$02FF is reserved as the CPU-side OAM shadow page in this project.
    lda     #_OAM_HIDDEN_Y          ; $FE is below the visible sprite area when used as a sprite Y.
    sta     $0200, x                ; Hide every possible OAM entry before active sprites are loaded.

    inx                             ; Advance the byte offset. $FF + 1 wraps X back to $00.
    bne     __clearMemoryLoop       ; Continue until that wrap proves all 256 offsets were visited.

    jmp     ISR_PowerOn_Reset::__CPUMemoryCleared
                                    ; Resume the reset sequence without creating another stack frame.

; End of lib/shared_code/cpu.s
