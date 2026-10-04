;
; first_nes
; lib/isr/poweron_reset.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Initialize CPU, APU, PPU, RAM, background, player state, and rendering after power-on or
;          reset, then transfer permanent foreground control to MainLoop.
;


; =================================================================================================
; ISR_PowerOn_Reset
;
; Purpose:
;   This is the NES RESET interrupt handler. The CPU begins executing here after power-on and after a
;   reset. It establishes a safe machine state before any normal game logic or rendering begins.
;
; Beginner notes:
;   RESET is not called with JSR, so this routine does not finish with RTS. After initialization it
;   jumps directly to MainLoop, which becomes the foreground program for the rest of the session.
;
;   The PPU needs startup time after reset. first_nes waits for two vertical blanks, with CPU RAM
;   initialization between them, before loading VRAM and enabling rendering.
;
; Inputs:
;   None. Hardware state immediately after reset should be treated as only partially initialized.
;
; Outputs / side effects:
;   Initializes the stack, disables audio/video IRQ sources, clears CPU RAM and OAM shadow RAM,
;   loads palette/background/sprite data, initializes player physics, enables rendering/NMI, and
;   jumps to MainLoop.
;
; Registers:
;   A, X, and Y may all be modified during initialization.
;
; Returns:
;   Does not return. Control leaves this routine with JMP MainLoop.
; =================================================================================================

.PROC ISR_PowerOn_Reset

    ; ---------------------------------------------------------------------------------------------
    ; Establish a predictable CPU/APU/PPU starting state.
    ; ---------------------------------------------------------------------------------------------

    cld                             ; NES ADC/SBC ignore decimal mode, but clear D for debugger safety.

    ldx     #255                    ; $FF is the conventional reset value for the 6502 stack pointer.
    txs                             ; Stack now begins at CPU address $01FF and grows downward.

    jsr     DisableVideoOutput      ; Keep the PPU from rendering while VRAM/OAM are being prepared.
    jsr     DisableAudioOutput      ; Disable APU/DMC interrupt sources before normal game execution.

    jsr     ClearVBlankFlag         ; Acknowledge a possible vblank that was already in progress.

    ; ---------------------------------------------------------------------------------------------
    ; Wait for the first post-reset vertical blank, then initialize CPU RAM.
    ;
    ; __ClearCPUMemory intentionally jumps back to the local __CPUMemoryCleared label when finished.
    ; That older control-flow shape is preserved here because it is part of the original project.
    ; ---------------------------------------------------------------------------------------------

    jsr     WaitForVBlank

    jmp     __ClearCPUMemory        ; Clear internal RAM and initialize unused OAM sprites off-screen.
   __CPUMemoryCleared:

    ; The second wait completes the conservative two-vblank PPU startup delay.
    jsr     WaitForVBlank

    ; ---------------------------------------------------------------------------------------------
    ; The PPU is now ready for normal setup while rendering is still disabled.
    ; Order matters: load static graphics/state first, render the initial hero into OAM, then enable
    ; video output and NMI only after the frame is ready to be shown.
    ; ---------------------------------------------------------------------------------------------

    jsr     LoadPaletteData         ; Copy all 32 palette bytes to PPU palette RAM at $3F00.
    jsr     LoadDemoBackground      ; Copy the 32x30 room plus attribute table to nametable 0.
    jsr     LoadSpriteData          ; Seed the first four OAM shadow entries with Neon Ranger data.

    jsr     InitializeHeroState     ; Initialize logical X/Y position and facing direction.
    jsr     InitializeHeroPhysics   ; Initialize subpixel Y, vertical velocity, and grounded state.
    jsr     InitializeHeroJumpAssist; Initialize coyote-time and jump-buffer counters.

    jsr     RenderHeroToOAM         ; Make OAM coordinates agree with the logical spawn position.
    jsr     EnableVideoOutput       ; Turn on background/sprites and enable NMI at vblank.

    ; ---------------------------------------------------------------------------------------------
    ; Initialization is complete. MainLoop owns foreground execution from this point forward. NMI
    ; will interrupt it once per frame to DMA OAM and increment FrameCounter.
    ; ---------------------------------------------------------------------------------------------

    jmp     MainLoop                ; RESET never returns; enter the permanent game loop.

.ENDPROC

; End of lib/isr/poweron_reset.s
