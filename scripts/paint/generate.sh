#!/usr/bin/env bash
#
# Regenerates the painted pieces of the house mixes from scripts/paint/PaintGenerator.swift.
#
#   scripts/paint/generate.sh            the four bands (2x and 3x) into Assets.xcassets/Paint
#   scripts/paint/generate.sh --proof    plus real-size proofs in .build/shots/paint-*.png
#   scripts/paint/generate.sh --store    plus one 1320 x 2868 piece per mix in .build/paint-store/
#
# Needs Xcode (swiftc and the macOS SDK). Nothing else.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

mkdir -p .build/paint
xcrun --sdk macosx swiftc -O -o .build/paint/paint-generator scripts/paint/PaintGenerator.swift
exec .build/paint/paint-generator "$@"
