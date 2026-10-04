;
; first_nes
; lib/shared_code/controllers.inc
;
; Controller-related assembler directives for Nintendo Entertainment System assembly language.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
; Expanded into a complete controller-state interface, 2026.
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: ca65 (cc65 binutils)
;


; Two standard NES controllers are accessed through $4016 and $4017.
_JOY1       = $4016
_JOY2       = $4017


; Controller state is stored in the same intuitive bit order in which most game code wants to test
; it. A is bit 0; Right is bit 7.
BUTTON_A       = %00000001
BUTTON_B       = %00000010
BUTTON_SELECT  = %00000100
BUTTON_START   = %00001000
BUTTON_UP      = %00010000
BUTTON_DOWN    = %00100000
BUTTON_LEFT    = %01000000
BUTTON_RIGHT   = %10000000

; End of lib/shared_code/controllers.inc
