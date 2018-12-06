#
# first_nes
# Makefile
#
# Makefile ("make") configuration for iNES ROM files.
#
# Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
#
# Based on the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
#   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
# Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
#   http://fms.komkon.org/EMUL8/NES.html
# Based on "Nintendo Entertainment System Documentation", by Jeremy Chadwick:
#   https://emu-docs.org/NES/nestech.txt
#
# Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
# Assembler: ca65 (cc65 binutils)
#
# Tested with:
#  make
#  nestopia first_nes.nes
#
# Tested on:
#  - Linux with Nestopia UE 1.47
#  - Windows with Nestopia UE 1.48
#
# For more information about NES programming in general, try these references:
# https://en.wikibooks.org/wiki/NES_Programming
#
# For more information on the ca65 assembler, try these references:
# https://github.com/cc65/cc65
# http://cc65.github.io/doc/ca65.html
#


# Reference: https://www.cs.swarthmore.edu/~newhall/unixhelp/howto_makefiles.html


# Makefile variable for the assembler 
ASSEMBLER = ca65

# Makefile variable for the linker 
LINKER = ld65

# Makefile variable for assembly flags
ASMFLAGS = --cpu 6502

# Makefile variable for linker flags
LINKFLAGS = --config config/ines.cfg

# Simply typing "make" will invoke all suggested targets to build an emulator-ready ROM
default: universal-pre-clean assemble link emulator emulator-post-clean

# To start over from scratch, type "make clean"
clean: universal-pre-clean emulator-post-clean
	
# This target entry assembles the .s assembly language files into .o object files
assemble: first_nes.s
	$(ASSEMBLER) $(ASMFLAGS) first_nes.s

# This target entry links the .o object files into .bin ROM files
link: first_nes.o
	$(LINKER) first_nes.o $(LINKFLAGS)

# This target entry concatenates the .bin ROM files into a .nes iNES emulator-compatible ROM file
emulator: bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin
	cat bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin > first_nes.nes

# TODO: Implement this target for making physical NES cartridges
cart:
	echo "'cart' target is not currently implemented"

# This target entry removes any build files (.bin, .nes) associated with an NES ROM 
universal-pre-clean:
	$(RM) bin/*.bin && $(RM) first_nes.nes && $(RM) first_nes.o

# This target entry removes the files (.o, .out) not required by emulators
emulator-post-clean:
	$(RM) first_nes.o && $(RM) a.out

# End of Makefile
