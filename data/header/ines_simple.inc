;
; first_nes
; data/header/ines_simple.inc
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Emit the meaningful bytes of the simple iNES file header used by first_nes: one 16 KiB
;          PRG bank, one 8 KiB CHR bank, mapper 0 (NROM), and vertical mirroring.
;
; Beginner note: an iNES ROM begins with a 16-byte metadata header. The linker configuration pads the
; remainder of this header segment with zero bytes, so this source file only needs to state the bytes
; that carry useful information for this simple NROM cartridge layout.
;


.BYTE   "NES", $1a                  ; Bytes 0-3: required iNES magic signature "NES" + $1A
.BYTE   $01                         ; Byte 4: one 16 KiB PRG-ROM bank
.BYTE   $01                         ; Byte 5: one 8 KiB CHR-ROM bank
.BYTE   %00000001                   ; Byte 6: mapper low nibble 0000 + vertical mirroring bit set

; Bytes 7-15 are zero-filled by the HEADER segment definition in config/ines.cfg.

; End of data/header/ines_simple.inc
