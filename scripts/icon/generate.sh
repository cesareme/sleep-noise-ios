#!/usr/bin/env bash
#
# Regenerates the app icon "La regla y la marea" from scripts/icon/IconGenerator.swift.
#
#   scripts/icon/generate.sh            PNGs and Contents.json of AppIcon.appiconset
#   scripts/icon/generate.sh --proof    plus small-size proofs in .build/icon-proof/
#   scripts/icon/generate.sh --layers   plus transparent layers in .build/icon-layers/
#
# Needs Xcode (swiftc and the macOS SDK). Nothing else.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

mkdir -p .build/icon
xcrun --sdk macosx swiftc -O -o .build/icon/icon-generator scripts/icon/IconGenerator.swift
exec .build/icon/icon-generator "$@"
