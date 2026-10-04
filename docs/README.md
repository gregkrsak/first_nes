<div align="center">

# 🎮 first_nes

### A tiny NES platformer you can understand all the way down to the bytes

[![Assembly](https://img.shields.io/badge/language-6502%20assembly-5b5bd6)](../first_nes.s)
[![Toolchain](https://img.shields.io/badge/CI%20toolchain-cc65%20V2.19-22c7c7)](https://github.com/cc65/cc65/releases/tag/V2.19)
[![Build & Validate ROM](https://github.com/gregkrsak/first_nes/actions/workflows/makefile.yml/badge.svg)](https://github.com/gregkrsak/first_nes/actions/workflows/makefile.yml)

<img src="neon_ranger.svg" alt="Pixel-art frames of the original Neon Ranger character" width="620">

**Run. Jump. Land. Read the 6502 code that made every pixel move.** ⚡

</div>

---

## ✨ What is this?

`first_nes` is a deliberately small Nintendo Entertainment System project for learning how a real NES ROM fits together. It uses the **ca65/ld65** toolchain and targets a simple mapper-0 / NROM cartridge layout.

The project does not hide the machine behind a game engine. Reset, PPU startup, palettes, CHR tiles, nametables, OAM DMA, controller polling, interrupts, fixed-point physics, platform collision, animation, linker layout, and the frame-synchronized foreground loop are all visible in the source.

The playable character is **Neon Ranger**, an original 16×16 sprite built from four NES hardware sprites. The current demo is a compact single-screen platformer chamber with a floor, elevated ledges, gravity, jumping, landing, walking animation, dedicated rising/falling poses, and hardware-assisted left/right sprite flipping.

## 🕹️ Controls

| Control | Action |
| --- | --- |
| D-pad ← / → | Move Neon Ranger |
| A | Jump |
| Tap A | Short hop |
| Hold A | Full jump |
| Walk off a ledge | Gravity takes over |

Up, Down, B, Select, and Start are intentionally available for future gameplay rather than being spent on free-flight movement.

## ⚡ Why the jump feels nicer than a literal first implementation

The physics remain small enough to study, but the controls include three tiny quality-of-life techniques used by modern platformers:

- **8.8 fixed-point motion** — whole pixels plus a fractional byte produce a smooth accelerating arc;
- **4-frame coyote time** — A can still jump for a moment after stepping off a ledge;
- **4-frame jump buffer** — an A press just before landing is remembered briefly;
- **variable jump height** — releasing A while rising cuts upward speed, turning a full leap into a short hop.

Core tuning starts at **−4.5 px/frame jump velocity**, **+0.25 px/frame² gravity**, and a **+4.0 px/frame terminal fall speed**. The values are deliberately named and grouped in `lib/game/physics.s` and `lib/game/jump_assist.s` so experimentation does not require hunting through the program.

```text
Controller
    │
    ▼
Horizontal movement ──► support check
                            │
                            ▼
                    jump buffer / coyote
                            │
                            ▼
                     fixed-point gravity
                            │
                            ▼
                      platform landing
                            │
                            ▼
                 idle / run / jump / fall
                            │
                            ▼
                    RenderHeroToOAM
                            │
                            ▼
                         NMI DMA
```

That boundary is intentional: **game state owns the player position; OAM only renders it.**

## 🧠 What you can learn here

- how a 16-byte iNES header, PRG ROM, and CHR ROM become one `.nes` file;
- how the 6502 reset, NMI, and IRQ/BRK vectors are wired;
- why the PPU needs startup time before normal access;
- how palette data and 2-bit CHR tiles reach the screen;
- how a 32×30 nametable plus attribute data becomes a full background scene;
- how a 256-byte CPU OAM shadow page becomes 64 hardware sprites through DMA;
- how the NES controller's serial A/B/Select/Start/D-pad report becomes reusable current/previous/pressed state;
- how foreground game logic can synchronize safely to NMI without living inside the interrupt handler;
- how signed 8.8 fixed-point velocity implements gravity without floating-point hardware;
- how downward-crossing tests and horizontal overlap produce simple one-way platform surfaces;
- how coyote time, input buffering, and jump cutting improve responsiveness with only a few bytes of state;
- how one 16×16 character can face both directions by swapping tiles and using the OAM horizontal-flip bit;
- how ca65 source and an ld65 linker configuration cooperate to place bytes exactly where the NES expects them.

## 🚀 Quick start

You need **Git**, **GNU Make**, the **cc65** toolchain, and an NES emulator such as Nestopia UE, Mesen, or another mapper-0-compatible emulator. Python 3 is optional for building, but is used by the ROM validator.

### Linux / BSD

Install or build cc65 so `ca65` and `ld65` are on your `PATH`, then:

```bash
git clone https://github.com/gregkrsak/first_nes.git
cd first_nes
make
make validate
```

### macOS

With Homebrew:

```bash
brew install cc65
git clone https://github.com/gregkrsak/first_nes.git
cd first_nes
make
make validate
```

### Windows

Install a cc65 distribution plus a `make` implementation, or use a Unix-like development shell such as MSYS2. Once `ca65`, `ld65`, and `make` are on your `PATH`:

```bash
git clone https://github.com/gregkrsak/first_nes.git
cd first_nes
make
make validate
```

The build creates:

```text
first_nes.nes
```

Load it in your emulator, use **← / →**, and press **A** to jump.

## 🗺️ Project map

```text
first_nes.s                    composition root: assets, libraries, vectors
config/ines.cfg                ld65 memory map and ROM layout
data/background/               32x30 Neon industrial chamber + attributes
data/header/                   iNES metadata
data/palette/                  NES palette bytes
data/sprites/                  initial OAM shadow data
data/tiles/                    original character + environment CHR source
lib/isr/                       reset, NMI, IRQ/BRK handlers
lib/shared_code/               CPU/APU/PPU/controller primitives
lib/game/player.s              authoritative player position/facing
lib/game/physics.s             signed 8.8 jump + gravity integration
lib/game/jump_assist.s         coyote time, input buffer, variable jump height
lib/game/platform_collision.s  visible platform/support/landing geometry
lib/game/main_loop.s           frame-synchronized gameplay pipeline
lib/sprite/                    horizontal movement + animation/OAM facing
scripts/validate_rom.py        structural iNES sanity checker
```

## 🎨 Original art, readable as source

The **Neon Ranger**, standing/running/jump/fall poses, and the neon industrial chamber were created specifically for `first_nes` in 2026 and are distributed under the same project license.

The room is built from original glowing platform surfaces, structural supports, wall panels, conduits, lamps, vents, hazard chevrons, and reinforced beams. The visible ledges intentionally match the collision table, so a learner can compare what the nametable draws with what the physics code considers solid.

CHR graphics and nametable data remain assembly source on purpose. Open the files, inspect the bit planes, change a byte, rebuild, and see exactly what the NES does with it.

## 🧩 Build pipeline

The ROM build stays transparent:

```text
first_nes.s
    │
    ▼
   ca65
    │
    ▼
first_nes.o
    │
    ▼
   ld65 + config/ines.cfg
    │
    ├── iNES header
    ├── 16 KiB PRG ROM
    └── 8 KiB CHR ROM
            │
            ▼
       first_nes.nes
            │
            ▼
   scripts/validate_rom.py
```

No game engine. No mystery ROM packer. **Just 6502 code, NES hardware, and enough structure to make both fun to learn.**

## ✅ Reproducible CI

GitHub Actions builds every pushed branch and every pull request targeting `staging` or `master`. CI deliberately pins **cc65 V2.19** rather than cloning an arbitrary future `master` revision.

After building, `make validate` checks the generated ROM for the invariants this starter promises:

- `NES` + `$1A` iNES magic;
- exactly one 16 KiB PRG bank and one 8 KiB CHR bank;
- mapper 0 / NROM;
- vertical mirroring;
- no trainer and no accidental NES 2.0 marker;
- a file length matching the header-described ROM layout.

A successful run uploads `first_nes.nes` as a workflow artifact, so a PR can be inspected without rebuilding it locally.

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request so expectations stay synchronized.

## 🕹️ History & acknowledgements

`first_nes` was written by **Greg M. Krsak** in 2018 and grew out of hands-on study of classic NES development material, including:

- the NintendoAge **Nerdy Nights** tutorials by bunnyboy;
- Marat Fayzullin's *Nintendo Entertainment System Architecture*;
- Jeremy Chadwick's *Nintendo Entertainment System Documentation*;
- the NESdev community and its evolving hardware documentation.

Additional thanks to earlier contributors and testers, including **@elennick**, **@hxlnt**, **@ericandrewlewis**, **@nortti**, and community members who reported setup/documentation issues over the project's history.

For current low-level NES reference material, start with [NESdev](https://www.nesdev.org/).

---

<div align="center">

**Small ROM. Real physics. Neon pixels. No mystery.** 👾⚡

</div>
