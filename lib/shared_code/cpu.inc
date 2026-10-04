;
; first_nes
; lib/shared_code/cpu.inc
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Document the NES CPU memory model and define reset-time RAM constants shared by CPU
;          initialization code.
;


; -------------------------------------------------------------------------------------------------
; NES CPU notes
; -------------------------------------------------------------------------------------------------
;
; The Ricoh RP2A03 CPU is based on the 6502, but its ADC/SBC instructions do not implement decimal
; arithmetic. CLD and SED still exist as opcodes, so first_nes explicitly executes CLD at reset to
; keep debugger/emulator state predictable even though decimal mode has no arithmetic effect here.
;
; Audio registers are memory-mapped inside the CPU/APU chip and occupy part of the I/O range.
;


; -------------------------------------------------------------------------------------------------
; Simplified CPU memory map
; -------------------------------------------------------------------------------------------------
;
; --------------------------------------- $10000
; Upper Bank of Cartridge ROM
; --------------------------------------- $C000
; Lower Bank of Cartridge ROM
; --------------------------------------- $8000
; Cartridge RAM (may be battery-backed)
; --------------------------------------- $6000
; Expansion Modules
; --------------------------------------- $5000
; Input/Output
; --------------------------------------- $2000
; 2kB Internal RAM, mirrored 4 times
; --------------------------------------- $0000
;


; Reset-time RAM fill values.
_RAM_CLEAR_VALUE = $00               ; Normal internal RAM begins cleared to zero.
_OAM_HIDDEN_Y     = $FE               ; Unused OAM-shadow entries begin below the visible screen.

; End of lib/shared_code/cpu.inc
