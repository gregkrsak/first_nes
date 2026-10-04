;
; first_nes
; lib/shared_code/controllers.inc
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Define the NES controller I/O register addresses and beginner-friendly button bit masks
;          used by controllers.s and foreground game logic.
;


; Two standard NES controller ports are exposed through CPU I/O addresses $4016 and $4017.
_JOY1       = $4016                  ; Controller 1 serial data + strobe register
_JOY2       = $4017                  ; Controller 2 serial data register


; Controller state is packed into one byte in the same order produced by ReadController1.
; A is bit 0 and Right is bit 7, so game code can test a button with AND #BUTTON_NAME.
BUTTON_A       = %00000001           ; Bit 0: A
BUTTON_B       = %00000010           ; Bit 1: B
BUTTON_SELECT  = %00000100           ; Bit 2: Select
BUTTON_START   = %00001000           ; Bit 3: Start
BUTTON_UP      = %00010000           ; Bit 4: D-pad Up
BUTTON_DOWN    = %00100000           ; Bit 5: D-pad Down
BUTTON_LEFT    = %01000000           ; Bit 6: D-pad Left
BUTTON_RIGHT   = %10000000           ; Bit 7: D-pad Right

; End of lib/shared_code/controllers.inc
