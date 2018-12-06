;
; first_nes
; lib/shared_code/ppu.inc
;
; PPU-Related assembler directives for Nintendo Entertainment System assembly language.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
;
; Based on the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
;   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
; Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
;   http://fms.komkon.org/EMUL8/NES.html
; Based on "Nintendo Entertainment System Documentation", by Jeremy Chadwick:
;   https://emu-docs.org/NES/nestech.txt
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: ca65 (cc65 binutils)
;
; Tested with:
;  make
;  nestopia first_nes.nes
;
; Tested on:
;  - Linux with Nestopia UE 1.47
;  - Windows with Nestopia UE 1.48
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the ca65 assembler, try these references:
; https://github.com/cc65/cc65
; http://cc65.github.io/doc/ca65.html
;


; The PPU (Picture Processing Unit) generates a composite video signal with 240 lines of pixels.
; Reference: https://wiki.nesdev.com/w/index.php/PPU


;
; PPU MEMORY MAP
;
; --------------------------------------- $4000
; Empty
; --------------------------------------- $3F20
; Sprite Palette
; --------------------------------------- $3F10
; Image Palette
; --------------------------------------- $3F00
; Empty
; --------------------------------------- $3000
; Attribute Table 3
; --------------------------------------- $2FC0
; Name Table 3 (32x30 tiles)
; --------------------------------------- $2C00
; Attribute Table 2
; --------------------------------------- $2BC0
; Name Table 2 (32x30 tiles)
; --------------------------------------- $2800
; Attribute Table 1
; --------------------------------------- $27C0
; Name Table 1 (32x30 tiles)
; --------------------------------------- $2400
; Attribute Table 0
; --------------------------------------- $23C0
; Name Table 0 (32x30 tiles)
; --------------------------------------- $2000
; Pattern Table 1 (256x2x8, may be VROM)
; --------------------------------------- $1000
; Pattern Table 0 (256x2x8, may be VROM)
; --------------------------------------- $0000
;


; ------+-----+---------------------------------------------------------------
; $2000 | RW  | PPU Control Register 1
;       | 0-1 | Name Table Address:
;       |     |
;       |     |           +-----------+-----------+
;       |     |           | 2 ($2800) | 3 ($2C00) |
;       |     |           +-----------+-----------+
;       |     |           | 0 ($2000) | 1 ($2400) |
;       |     |           +-----------+-----------+
;       |     |
;       |     | Remember that because of the mirroring there are only 2  
;       |     | real Name Tables, not 4. Also, PPU will automatically
;       |     | switch to another Name Table when running off the current
;       |     | Name Table during scroll (see picture above).
;       |   2 | Vertical Write, 1 = PPU memory address increments by 32:
;       |     |
;       |     |    Name Table, VW=0          Name Table, VW=1
;       |     |   +----------------+        +----------------+
;       |     |   |----> write     |        | | write        |
;       |     |   |                |        | V              |
;       |     |
;       |   3 | Sprite Pattern Table Address, 1 = $1000, 0 = $0000.
;       |   4 | Screen Pattern Table Address, 1 = $1000, 0 = $0000.
;       |   5 | Sprite Size, 1 = 8x16, 0 = 8x8.
;       |   6 | PPU Master/Slave Mode, not used in NES.
;       |   7 | VBlank Enable, 1 = generate interrupts on VBlank.
; ------+-----+---------------------------------------------------------------
_PPUCTRL    = $2000           ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#PPUCTRL

; ------+-----+---------------------------------------------------------------
; $2001 | RW  | PPU Control Register 2
;       |   0 | Unknown (???)
;       |   1 | Image Mask, 0 = don't show left 8 columns of the screen.
;       |   2 | Sprite Mask, 0 = don't show sprites in left 8 columns. 
;       |   3 | Screen Enable, 1 = show picture, 0 = blank screen.
;       |   4 | Sprites Enable, 1 = show sprites, 0 = hide sprites.
;       | 5-7 | Background Color, 0 = black, 1 = blue, 2 = green, 4 = red.
;       |     | Do not use any other numbers as you may damage PPU hardware.
; ------+-----+---------------------------------------------------------------
_PPUMASK    = $2001           ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#PPUMASK

; ------+-----+---------------------------------------------------------------
; $2002 | R   | PPU Status Register
;       | 0-5 | Unknown (???)
;       |   6 | Hit Flag, 1 = Sprite refresh has hit sprite #0.
;       |     | This flag resets to 0 when screen refresh starts.
;       |   7 | VBlank Flag, 1 = PPU is in VBlank state.
;       |     | This flag resets to 0 when VBlank ends or CPU reads $2002.
; ------+-----+---------------------------------------------------------------
_PPUSTATUS  = $2002         ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#PPUSTATUS

; ------+-----+---------------------------------------------------------------
; $2005 | W   | Screen Scroll Offsets
;       |     | There are two scroll registers, vertical and horizontal, 
;       |     | which are both written via this port. The first value written
;       |     | will go into the Vertical Scroll Register (unless it is >239,
;       |     | then it will be ignored). The second value will appear in the
;       |     | Horizontal Scroll Register. Name Tables are assumed to be
;       |     | arranged in the following way:
;       |     |
;       |     |           +-----------+-----------+
;       |     |           | 2 ($2800) | 3 ($2C00) |
;       |     |           +-----------+-----------+
;       |     |           | 0 ($2000) | 1 ($2400) |
;       |     |           +-----------+-----------+
;       |     |
;       |     | When scrolled, the picture may span over several Name Tables.
;       |     | Remember that because of the mirroring there are only 2 real
;       |     | Name Tables, not 4.
; ------+-----+---------------------------------------------------------------
_PPUSCROLL  = $2005         ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#PPUSCROLL

; ------+-----+---------------------------------------------------------------
; $2006 | W   | PPU Memory Address
;       |     | Used to set the address of PPU Memory to be accessed via
;       |     | $2007. The first write to this register will set 8 lower
;       |     | address bits. The second write will set 6 upper bits. The
;       |     | address will increment either by 1 or by 32 after each
;       |     | access to $2007.
; ------+-----+---------------------------------------------------------------
_PPUADDR    = $2006           ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#PPUADDR

; ------+-----+---------------------------------------------------------------
; $2007 | RW  | PPU Memory Data
;       |     | Used to read/write the PPU Memory. The address is set via
;       |     | $2006 and increments after each access, either by 1 or by 32.
; ------+-----+---------------------------------------------------------------
_PPUDATA    = $2007           ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#PPUDATA


; The OAM (Object Attribute Memory) is internal memory inside the PPU that contains a lookup table 
; of up to 64 sprites, where each table entry consists of 4 bytes.


; ------+-----+---------------------------------------------------------------
; $2003 | W   | Sprite Memory Address
;       |     | Used to set the address of the 256-byte Sprite Memory to be 
;       |     | accessed via $2004. This address will increment by 1 after
;       |     | each access to $2004. Sprite Memory contains coordinates,
;       |     | colors, and other sprite attributes.
; ------+-----+---------------------------------------------------------------
_OAMADDR    = $2003           ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#OAMADDR

; ------+-----+---------------------------------------------------------------
; $2004 | RW  | Sprite Memory Data
;       |     | Used to read/write the Sprite Memory. The address is set via
;       |     | $2003 and increments by 1 after each access. Sprite Memory 
;       |     | contains coordinates, colors, and other sprite attributes
;       |     | sprites.
; ------+-----+---------------------------------------------------------------
_OAMDATA    = $2004           ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#OAMDATA

; ------+-----+---------------------------------------------------------------
; $4014 | W   | DMA Access to the Sprite Memory
;       |     | Writing a value N into this port causes an area of CPU memory
;       |     | at address $100*N to be transferred into the Sprite Memory.
;       |     | The CPU is suspended while the transfer is taking place.
; ------+-----+---------------------------------------------------------------
_OAMDMA     = $4014            ; Reference: https://wiki.nesdev.com/w/index.php/PPU_registers#OAMDMA

; End of lib/shared_code/ppu.inc
