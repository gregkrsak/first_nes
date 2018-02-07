first_nes project (WIP)
=================


A "starter" assembly language game for the Nintendo Entertainment System.
Please leave issues or submit pull requests!
-------------------------------------------------------------------------


Written by Greg M. Krsak ([email](mailto:greg.krsak@gmail.com)), 2018

Based on the [NintendoAge "Nerdy Nights" tutorials](http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155), by bunnyboy

Based on ["Nintendo Entertainment System Architecture"](http://fms.komkon.org/EMUL8/NES.html), by Marat Fayzullin
 
Based on ["Nintendo Entertainment System Documentation"](https://emu-docs.org/NES/nestech.txt), by an unknown author

**Processor:** 8-bit, [Ricoh RP2A03](https://en.wikipedia.org/wiki/Ricoh_2A03) (6502), 1.789773 MHz (NTSC)

**Assembler:** ca65 ([cc65 binutils](https://github.com/cc65/cc65))

**Tested with:**

```bash
rm bin/*.bin
rm first_nes.nes
ca65 first_nes.s
ld65 first_nes.o -C config/ines.cfg
cat bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin > first_nes.nes
rm a.out && rm first_nes.o
nestopia first_nes.nes
```

**Tested on:**

[Nestopia UE](http://0ldsk00l.ca/nestopia/) 1.47


For more information about NES programming in general, try these references:
-----------------------------------------------------------------------------------------------------------------

https://en.wikibooks.org/wiki/NES_Programming

For more information on the ca65 assembler, try these references:
------------------------------------------------------------------------------------------------------

https://github.com/cc65/cc65

http://cc65.github.io/doc/ca65.html
