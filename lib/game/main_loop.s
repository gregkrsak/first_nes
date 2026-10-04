;
; first_nes
; lib/game/main_loop.s
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Run one complete frame of foreground game logic each time the NMI handler publishes a new
;          frame number.
;
; The important beginner concept here is separation of responsibilities: the NMI handler performs
; short, time-critical video work; MainLoop performs controller reading, movement, physics,
; collision, animation, and OAM preparation in normal foreground time.
;


.SEGMENT "ZEROPAGE"

FrameCounter:      .res 1            ; NMI increments this once per displayed frame.
LastFrameCounter:  .res 1            ; MainLoop remembers the most recent frame it consumed.


.SEGMENT "CODE"


; =================================================================================================
; MainLoop
;
; Purpose:
;   Wait for a new video frame, then run exactly one pass of the platformer's foreground game logic.
;   This procedure never returns during normal gameplay; after finishing one frame it jumps back to
;   wait for the next NMI-produced frame number.
;
; Why a counter instead of a simple "ready" flag?
;   NMI can occur between almost any two foreground instructions. A single flag can be cleared at an
;   unlucky moment and lose a notification. Comparing an NMI-owned counter with the last counter
;   consumed by MainLoop avoids that race while staying easy to inspect in a debugger.
;
; Inputs:
;   FrameCounter is incremented by ISR_Vertical_Blank.
;   Controller and player state variables contain the previous frame's state.
;
; Outputs / side effects:
;   Updates controller state, HeroX/HeroY, jump/physics state, collision state, animation state,
;   and the CPU-side OAM shadow used by the next NMI.
;
; Registers:
;   A is modified repeatedly. Called routines may also modify X and Y. No register preservation is
;   required because this is the top-level foreground loop rather than a conventional subroutine.
;
; Returns:
;   It does not normally RTS. The procedure loops forever by jumping back to waitForNextFrame.
; =================================================================================================

.PROC MainLoop

  waitForNextFrame:
    lda     FrameCounter            ; Read the frame number most recently published by NMI.
    cmp     LastFrameCounter        ; Is it different from the frame we already processed?
    beq     waitForNextFrame        ; No: wait here until the next vertical blank occurs.
    sta     LastFrameCounter        ; Yes: claim this frame before doing any game work.

    ; ---------------------
    ; Read player controls.
    ; ---------------------

    jsr     ReadController1         ; Build current, previous, and newly-pressed button masks.

    ; --------------------------------
    ; Apply held horizontal movement.
    ; --------------------------------

    lda     Controller1Current      ; Test the current frame's held-button byte.
    and     #BUTTON_RIGHT           ; Keep only the Right button bit.
    beq     mainRightDone           ; Skip movement when Right is not held.
    jsr     MoveHeroRight           ; Move one pixel and face right.
  mainRightDone:

    lda     Controller1Current      ; Re-read the held-button byte for the independent Left test.
    and     #BUTTON_LEFT            ; Keep only the Left button bit.
    beq     mainLeftDone            ; Skip movement when Left is not held.
    jsr     MoveHeroLeft            ; Move one pixel and face left.
  mainLeftDone:

    ; ---------------------------------------------------------------------------------------------
    ; Run the vertical platformer pipeline in a deliberate order.
    ;
    ; 1. Check whether horizontal movement walked a grounded hero beyond a platform edge.
    ; 2. Remember a new A-button press for jump buffering.
    ; 3. Start a jump if grounded or still inside the coyote-time window.
    ; 4. Shorten an upward jump when A has been released.
    ; 5. Integrate vertical position and gravity.
    ; 6. Resolve any platform surface crossed while falling.
    ; 7. Age the coyote-time and jump-buffer counters.
    ; ---------------------------------------------------------------------------------------------

    jsr     CheckHeroGroundSupport
    jsr     CaptureHeroJumpInput
    jsr     TryStartHeroJump
    jsr     ApplyHeroJumpCut
    jsr     UpdateHeroVerticalPhysics
    jsr     ResolveHeroPlatformLanding
    jsr     TickHeroJumpAssist

    ; -------------------------------------------------------------
    ; Choose graphics, then project logical position into OAM RAM.
    ; -------------------------------------------------------------

    jsr     UpdateHeroAnimation     ; Select idle/run/jump/fall tiles and facing attributes.
    jsr     RenderHeroToOAM         ; Write the final X/Y coordinates for all four sprites.

    jmp     waitForNextFrame        ; Begin waiting for the next NMI-published frame.

.ENDPROC

; End of lib/game/main_loop.s
