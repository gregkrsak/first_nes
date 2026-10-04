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


ASSEMBLER = ca65
LINKER = ld65
PYTHON ?= python3

ASMFLAGS = --cpu 6502
LINKFLAGS = --config config/ines.cfg

.PHONY: default clean assemble link emulator validate cart universal-pre-clean emulator-post-clean

# Simply typing "make" builds an emulator-ready ROM.
default: universal-pre-clean assemble link emulator emulator-post-clean

# To start over from scratch, type "make clean".
clean: universal-pre-clean emulator-post-clean
	
# Assemble the top-level translation unit into a 6502 object file.
assemble: first_nes.s
	$(ASSEMBLER) $(ASMFLAGS) first_nes.s

# Link the object file into the header/PRG/CHR binary components described by config/ines.cfg.
link: first_nes.o
	$(LINKER) first_nes.o $(LINKFLAGS)

# Concatenate the binary components into an emulator-compatible iNES ROM.
emulator: bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin
	cat bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin > first_nes.nes

# Validate an already-built ROM. Typical local usage: `make && make validate`.
validate:
	$(PYTHON) scripts/validate_rom.py first_nes.nes

# TODO: Implement this target for making physical NES cartridges.
cart:
	echo "'cart' target is not currently implemented"

# Remove build files associated with an NES ROM.
universal-pre-clean:
	$(RM) bin/*.bin && $(RM) first_nes.nes && $(RM) first_nes.o

# Remove intermediate files not required by emulators.
emulator-post-clean:
	$(RM) first_nes.o && $(RM) a.out

# End of Makefile
