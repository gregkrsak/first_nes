;
; first_nes (https://github.com/gregkrsak/first_nes/)
; data/background/scene.inc
;
; Sample nametable to produce a background scene.
; Uses data/tiles/smb1_chr.bin
;
; Please see first_nes/docs/README.md for license and attribution.


_NAMETABLE:
  .BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
  .BYTE $24,$24,$24,$24,$24,$24,$24,$0f,$12,$1b,$1c,$1d,$24,$17,$0e,$1c ;first nes

_ATTRIBUTE:
  .BYTE %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
  .BYTE %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000


; End of data/background/scene.inc
