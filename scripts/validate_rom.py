#!/usr/bin/env python3
"""Validate the structural invariants of the first_nes iNES ROM."""

from __future__ import annotations

import sys
from pathlib import Path

HEADER_SIZE = 16
TRAINER_SIZE = 512
PRG_BANK_SIZE = 16 * 1024
CHR_BANK_SIZE = 8 * 1024

EXPECTED_PRG_BANKS = 1
EXPECTED_CHR_BANKS = 1
EXPECTED_MAPPER = 0


def validate_rom(path: Path) -> list[str]:
    """Return a list of validation errors; an empty list means success."""
    data = path.read_bytes()
    errors: list[str] = []

    if len(data) < HEADER_SIZE:
        return [f"ROM is only {len(data)} bytes; an iNES header requires 16 bytes"]

    if data[:4] != b"NES\x1a":
        errors.append("missing iNES magic bytes: expected 4e 45 53 1a")

    prg_banks = data[4]
    chr_banks = data[5]
    flags6 = data[6]
    flags7 = data[7]

    mapper = (flags6 >> 4) | (flags7 & 0xF0)
    has_trainer = bool(flags6 & 0x04)
    vertical_mirroring = bool(flags6 & 0x01)
    is_nes2 = (flags7 & 0x0C) == 0x08

    if prg_banks != EXPECTED_PRG_BANKS:
        errors.append(
            f"expected {EXPECTED_PRG_BANKS} x 16 KiB PRG bank, found {prg_banks}"
        )

    if chr_banks != EXPECTED_CHR_BANKS:
        errors.append(
            f"expected {EXPECTED_CHR_BANKS} x 8 KiB CHR bank, found {chr_banks}"
        )

    if mapper != EXPECTED_MAPPER:
        errors.append(f"expected mapper 0 (NROM), found mapper {mapper}")

    if has_trainer:
        errors.append("unexpected 512-byte trainer flag in iNES header")

    if not vertical_mirroring:
        errors.append("expected vertical nametable mirroring flag")

    if is_nes2:
        errors.append("expected classic iNES header, found NES 2.0 marker")

    expected_size = (
        HEADER_SIZE
        + (TRAINER_SIZE if has_trainer else 0)
        + prg_banks * PRG_BANK_SIZE
        + chr_banks * CHR_BANK_SIZE
    )
    if len(data) != expected_size:
        errors.append(
            f"file size mismatch: header describes {expected_size} bytes, "
            f"but file contains {len(data)} bytes"
        )

    if not errors:
        print("ROM validation passed")
        print(f"  file:      {path}")
        print(f"  size:      {len(data)} bytes")
        print(f"  PRG:       {prg_banks} x 16 KiB")
        print(f"  CHR:       {chr_banks} x 8 KiB")
        print(f"  mapper:    {mapper} (NROM)")
        print("  mirroring: vertical")

    return errors


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "first_nes.nes")

    if not path.is_file():
        print(f"ROM validation failed: file not found: {path}", file=sys.stderr)
        return 1

    errors = validate_rom(path)
    if errors:
        print("ROM validation failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
