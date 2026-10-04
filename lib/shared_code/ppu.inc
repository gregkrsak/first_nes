;
; first_nes
; lib/shared_code/ppu.inc
;
; PPU-related assembler directives for Nintendo Entertainment System assembly language.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
; Modernized against current NESdev documentation, 2026.
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; PPU: Ricoh RP2C02 (NTSC)
; Assembler: ca65 (cc65 binutils)
;
; Reference: https://www.nesdev.org/wiki/PPU_registers
;


; =================================================================================================
;  PPU QUICK MAP
;  Think of this as the NES video system's tiny cockpit: pattern data, nametables, palettes, and a
;  handful of memory-mapped registers that control how the PPU sees all of it.
; =================================================================================================
;
; $0000-$0FFF  Pattern table 0
; $1000-$1FFF  Pattern table 1
; $2000-$23FF  Nametable 0 + attribute table
; $2400-$27FF  Nametable 1 + attribute table
; $2800-$2BFF  Nametable 2 + attribute table
; $2C00-$2FFF  Nametable 3 + attribute table
; $3000-$3EFF  Mirrors of $2000-$2EFF
; $3F00-$3F1F  Palette RAM
; $3F20-$3FFF  Mirrors of $3F00-$3F1F
;
; Cartridge mirroring determines which logical nametables share physical VRAM.
;


; =================================================================================================
;  $2000 - PPUCTRL
;  Big switches: nametable selection, address increment, pattern tables, sprite size, and NMI.
; =================================================================================================
;
; bit 0-1  Base nametable address
;          00=$2000, 01=$2400, 10=$2800, 11=$2C00
; bit 2    VRAM increment after $2007 access: 0=+1, 1=+32
; bit 3    Sprite pattern table for 8x8 sprites: 0=$0000, 1=$1000
; bit 4    Background pattern table: 0=$0000, 1=$1000
; bit 5    Sprite size: 0=8x8, 1=8x16
; bit 6    PPU master/slave select (normally unused on retail NES software)
; bit 7    Generate NMI at the start of vertical blank
;
_PPUCTRL    = $2000


; =================================================================================================
;  $2001 - PPUMASK
;  What gets drawn, what gets clipped, and how color is emphasized.
; =================================================================================================
;
; bit 0    Grayscale mode
; bit 1    Show background in leftmost 8 pixels
; bit 2    Show sprites in leftmost 8 pixels
; bit 3    Show background
; bit 4    Show sprites
; bit 5    Emphasize red   (NTSC RP2C02)
; bit 6    Emphasize green (NTSC RP2C02)
; bit 7    Emphasize blue  (NTSC RP2C02)
;
; NOTE: The old "background color" interpretation of bits 5-7 is incorrect. They are emphasis bits.
;
_PPUMASK    = $2001


; =================================================================================================
;  $2002 - PPUSTATUS
;  Read-only status. Reading this register also clears the vblank flag and resets the $2005/$2006
;  write toggle, which is why many PPU update routines begin with a read from $2002.
; =================================================================================================
;
; bit 5    Sprite overflow flag
; bit 6    Sprite 0 hit flag
; bit 7    Vblank flag
; bits 0-4 Return PPU open-bus data rather than useful status flags
;
_PPUSTATUS  = $2002


; =================================================================================================
;  $2003 / $2004 - OAMADDR / OAMDATA
;  Direct access to the PPU's 256-byte Object Attribute Memory (64 sprites x 4 bytes).
; =================================================================================================
;
_OAMADDR    = $2003
_OAMDATA    = $2004


; =================================================================================================
;  $2005 - PPUSCROLL
;  Two-write register: FIRST write is X/horizontal scroll, SECOND write is Y/vertical scroll.
;  Reading $2002 resets the internal write toggle so the next $2005 write is X again.
; =================================================================================================
;
_PPUSCROLL  = $2005


; =================================================================================================
;  $2006 - PPUADDR
;  Two-write register used to select a 14-bit PPU address. FIRST write supplies the high byte;
;  SECOND write supplies the low byte. This is intentionally high-then-low.
; =================================================================================================
;
_PPUADDR    = $2006


; =================================================================================================
;  $2007 - PPUDATA
;  Data port for the PPU address selected through $2006. The address automatically advances by
;  either 1 or 32 according to PPUCTRL bit 2. Most reads are delayed by the PPU's internal read
;  buffer; palette reads ($3F00-$3FFF) are the important exception.
; =================================================================================================
;
_PPUDATA    = $2007


; =================================================================================================
;  $4014 - OAMDMA
;  Write a page number N here to copy CPU addresses $NN00-$NNFF into PPU OAM. During the transfer
;  the CPU pauses for 513 or 514 cycles, depending on alignment. first_nes uses page $02.
; =================================================================================================
;
_OAMDMA     = $4014


; =================================================================================================
;  PPU WRITE-LATCH CHEAT SHEET
; =================================================================================================
;
;   bit $2002          ; reset $2005/$2006 write toggle
;
;   lda #$3F
;   sta $2006          ; HIGH byte first
;   lda #$00
;   sta $2006          ; LOW byte second -> address $3F00
;
;   ; $2005 follows the same two-write rhythm: X first, then Y.
;
; End of lib/shared_code/ppu.inc
