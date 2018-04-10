first_nes project (WIP)
=================


[![GitHub issues](https://img.shields.io/github/issues/gregkrsak/first_nes.svg)](https://github.com/gregkrsak/first_nes/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/gregkrsak/first_nes.svg)](https://github.com/gregkrsak/first_nes/commits/)
[![Custom language](https://img.shields.io/badge/language-assembly%20language-blue.svg)](https://github.com/gregkrsak/first_nes/blob/master/first_nes.s)


Create your own games for the Nintendo Entertainment System with this "starter" project!

If you'd like to contribute, [click here](https://github.com/gregkrsak/first_nes/blob/master/docs/CONTRIBUTING.md) so we can synchronize our expectations!


Boilerplate code is provided!       |  Instantly get up and playing!
------------------------------------|-----------------------------------
![Image: Editing](https://i.imgur.com/EabWh01.png "Boilerplate code is provided! Just add custom libraries, and graphics if you'd like.")  |  ![Image: Running](https://i.imgur.com/GcwC0tR.png "Instantly get up and playing!")


Quick Start
-----------

**Linux:**

First, assuming you have Git installed, get the cc65 binutils:

```
git clone https://github.com/cc65/cc65.git
cd cc65
make
make avail
```


Next, if you don't already have an NES emulator, install Nestopia using your package manager. Instructions
on how to do that aren't covered here, but the following distros *should* be supported:

- Arch Linux
- Debian
- OpenBSD
- Rosa Desktop Fresh
- Slackware (Slackbuilds)
- Ubuntu
- Void Linux


Now grab the first_nes project:

```
git clone https://github.com/gregkrsak/first_nes
cd first_nes
make
```


Finally, run the game. You can move the Luigi-like character back and forth with the A and B buttons:

```
nestopia first_nes.nes
```


**Mac OS:**

First, get the cc65 binutils by following [these instructions](http://macappstore.org/cc65/).


Next, if you don't already have an NES emulator, install the [Nestopia .dmg](http://www.bannister.org/cgi-bin/download.cgi?nestopia) file.


If you need help installing the .dmg file, try [this guide](http://techapple.net/2015/12/how-to-install-apps-from-dmg-files-in-mac-os-x-imac-macbook/).


Now, assuming you have Git installed, and the ability to ```make```, grab the first_nes project using the Terminal:

```
git clone https://github.com/gregkrsak/first_nes
cd first_nes
make
```


Finally, start Nestopia and load the ```first_nes.nes``` file. You can move the Luigi-like character back and forth with the A and B buttons:


**Windows (untested):**

First, get the cc65 binutils. Follow the Windows guide at [this link](http://cc65.github.io/cc65/getting-started.html#Windows).


Next, if you don't already have an NES emulator, click [this link](http://sourceforge.net/projects/nestopiaue/files/1.48/nestopia_1.48-win32.zip/download) to download the .ZIP archive of Nestopia.


Now, assuming you have Git installed, grab the first_nes project:

```
git clone https://github.com/gregkrsak/first_nes
cd first_nes
```

Then, browse [this Q&A](https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows) for information on how to run a Makefile in Windows.

Finally, start Nestopia and load the ```first_nes.nes``` file. You can move the Luigi-like character back and forth with the A and B buttons.


Credits
-------

**Authors:**

- Written by Greg M. Krsak ([email](mailto:greg.krsak@gmail.com)), 2018

**Standing on the shoulders of giants:**

- Based on the [NintendoAge "Nerdy Nights" tutorials](http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155), by bunnyboy

- Based on ["Nintendo Entertainment System Architecture"](http://fms.komkon.org/EMUL8/NES.html), by Marat Fayzullin
 
- Based on ["Nintendo Entertainment System Documentation"](https://emu-docs.org/NES/nestech.txt), by Jeremy Chadwick

**Additional thanks to:**

- [@elennick](https://github.com/elennick) for testing the Mac OS quick start instructions (Issue [#22](https://github.com/gregkrsak/first_nes/issues/22)).

- [@hxlnt](https://github.com/hxlnt) for expanding the credits (PR [#33](https://github.com/gregkrsak/first_nes/pull/33)).


About my Development Environment
--------------------------------

**Editor:** [Sublime Text 3](https://www.sublimetext.com/3), 2-space tabs, tabs-to-spaces, 100-column ruler

**Target CPU:** 8-bit, [Ricoh RP2A03](https://en.wikipedia.org/wiki/Ricoh_2A03) (6502), 1.789773 MHz (NTSC)

**Assembler:** ca65 (cc65 binutils)

**Tested with:**

```
make
nestopia first_nes.nes
```

**Tested on:**

- Linux (Ubuntu Desktop 16.04 LTS)

- Nestopia UE 1.47


Additional Resources
--------------------

**Git and GitHub:**

- [What is Git](https://en.wikipedia.org/wiki/Git) and [how do I use it?](https://git-scm.com/doc)

- Download [GitHub Desktop for Windows and Mac OS](https://desktop.github.com/) or [Git for Linux](https://git-scm.com/download/linux)

**NES programming in general:**

- [Wikibooks: NES Programming](https://en.wikibooks.org/wiki/NES_Programming)

- [NesDev](http://nesdev.com/)

**The ca65 assembler:**

- [ca65 Documentation](http://cc65.github.io/doc/ca65.html)

- [cc65 GitHub repository](https://github.com/cc65/cc65)

**Building this project:**

- This project's [Makefile](https://github.com/gregkrsak/first_nes/blob/master/Makefile)

- [Makefiles: A Tutorial by Example](http://mrbook.org/blog/tutorials/make/)


first_nes was written by [Greg M. Krsak](https://github.com/gregkrsak/), 2018. You may send me email using [this address](mailto:greg.krsak@gmail.com). If you'd like to contribute, [click here](https://github.com/gregkrsak/first_nes/blob/master/docs/CONTRIBUTING.md) so we can synchronize our expectations!
