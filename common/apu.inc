;
; apu.inc
;
; APU-Related assembler directives for Nintendo Entertainment System assembly language.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, Feb. 2017
;
; Based on the the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
;   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
; Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
;   http://fms.komkon.org/EMUL8/NES.html
; Based on "Nintendo Entertainment System Documentation", by an unknown author:
;   https://emu-docs.org/NES/nestech.txt
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: NESASM 3.1
;
; Tested with:
; nesasm3 "first_nes.asm"
;
; Tested on:
; Nestopia 1.40
;
; For more information about NES programming in general, try these references:
; https://patater.com/nes-asm-tutorials/
; https://en.wikibooks.org/wiki/NES_Programming/Memory_Map
;
; For more information on the NESASM assembler, try these references:
; http://www.nespowerpak.com/nesasm/usage.txt
;


; The APU (Audio Processing Unit) is the sound hardware the NES console which generates sound for games.
; It is implemented in the RP2A03 (NTSC) and RP2A07 (PAL) chips.
; Its registers are mapped in the range $4000-$4013, $4015 and $4017.


; ------+-----+---------------------------------------------------------------
; $4015 | W   | Sound Channel Switch
;       |   0 | Channel 1, 1 = enable sound.
;       |   1 | Channel 2, 1 = enable sound.
;       |   2 | Channel 3, 1 = enable sound.
;       |   3 | Channel 4, 1 = enable sound.
;       |   4 | Channel 5, 1 = enable sound.
;       | 5-7 | Unused (???)
; ------+-----+---------------------------------------------------------------
SND_CHN     = $4015                 ; Reference: https://wiki.nesdev.com/w/index.php/APU#Status_.28.244015.29

; APU Square wave channels 1 and 2
; Reference: https://wiki.nesdev.com/w/index.php/APU_Pulse
SQ1_VOL     = $4000
SQ1_SWEEP   = $4001
SQ1_LO      = $4002
SQ1_HI      = $4003
SQ2_VOL     = $4004
SQ2_SWEEP   = $4005
SQ2_LO      = $4006
SQ2_HI      = $4007

; APU Triangle wave channel
; Reference: https://wiki.nesdev.com/w/index.php/APU_Triangle
TRI_LINEAR  = $4008
TRI_LO      = $400a
TRI_HI      = $400b

; APU Noise generator
; Reference: https://wiki.nesdev.com/w/index.php/APU_Noise
NOISE_VOL   = $400c
NOISE_LO    = $400e
NOISE_HI    = $400f

; APU Delta Modulation Channel
; Reference: https://wiki.nesdev.com/w/index.php/APU_DMC
DMC_FREQ    = $4010
DMC_RAW     = $4011
DMC_START   = $4012
DMC_LEN     = $4013

; APU Frame counter
FR_COUNTER 	= $4017                 ; Reference: https://wiki.nesdev.com/w/index.php/APU_Frame_Counter


; End of apu.inc
