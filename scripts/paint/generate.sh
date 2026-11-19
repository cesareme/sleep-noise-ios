#!/usr/bin/env bash
#
# Regenerates the painted pieces of the house mixes from scripts/paint/PaintGenerator.swift.
#
#   scripts/paint/generate.sh            the four bands (2x and 3x) into Assets.xcassets/Paint
#   scripts/paint/generate.sh --proof    plus real-size proofs in .build/shots/paint-*.png
#   scripts/paint/generate.sh --store    plus one 1320 x 2868 piece per mix in .build/paint-store/
#
# Needs Xcode (swiftc and the macOS SDK). Nothing else.
# Compiles SleepNoise/Design/Paint/Pigment.swift next to the generator.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

# The brush (generator, palette, ribbon, canvas) is the app's own file, so
# the catalog and the page paint with one code. Top-level code must live in a
# file called main.swift when swiftc gets more than one, hence the copy.
mkdir -p .build/paint
cp scripts/paint/PaintGenerator.swift .build/paint/main.swift
xcrun --sdk macosx swiftc -O -o .build/paint/paint-generator \
    .build/paint/main.swift SleepNoise/Design/Paint/Pigment.swift
exec .build/paint/paint-generator "$@"
