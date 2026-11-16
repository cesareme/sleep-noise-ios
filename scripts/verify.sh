#!/usr/bin/env bash
#
# Local and CI gate. Nothing reaches main unless this prints "VERIFY OK".
#
#   scripts/verify.sh                 clean build + tests on the simulator named by SN_SIM
#   scripts/verify.sh --fast          same without the clean step (quick loop, NOT the gate)
#   scripts/verify.sh --ci            picks an available iPhone simulator by itself
#
# Environment:
#   SN_SIM      simulator name, default "iPhone 17" (ignored with --ci)
#   SN_DERIVED  DerivedData path, default .build/DerivedData
#
# It fails when:
#   - xcodegen or xcodebuild fail (build error, failing test, missing simulator)
#   - the log has a compiler or linker warning that is not listed in
#     scripts/verify-known-warnings.txt
#   - the App Intents metadata processor prints a warning or an error that is
#     not listed there either
#   - no test ran
#
# The full log is always written to .build/verify.log. The last line printed is
# "VERIFY OK · N tests" or "VERIFY FAIL · <reason>". Exit code 0, 1, or 2 (usage).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SN_SIM="${SN_SIM:-iPhone 17}"
SN_DERIVED="${SN_DERIVED:-.build/DerivedData}"
LOG=".build/verify.log"
KNOWN_WARNINGS="scripts/verify-known-warnings.txt"
PROJECT="SleepNoise.xcodeproj"
SCHEME="SleepNoise"
MIN_IOS_MAJOR=17

MODE="local"
CLEAN=1
for arg in "$@"; do
    case "$arg" in
        --ci) MODE="ci" ;;
        --fast) CLEAN=0 ;;
        -h|--help)
            sed -n '3,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "verify.sh: unknown argument: $arg" >&2
            echo "VERIFY FAIL · argumento desconocido: $arg"
            exit 2
            ;;
    esac
done

say() { printf '%s\n' "$*"; }

finish() {
    # $1 = final line. Also lands in the GitHub job summary when there is one.
    say "$1"
    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
        printf '%s\n' "$1" >> "$GITHUB_STEP_SUMMARY" || true
    fi
}

fail() {
    trap - ERR
    finish "VERIFY FAIL · $1"
    exit 1
}

trap 'fail "error inesperado del script en la línea $LINENO (log: $LOG)"' ERR

# Prints matching lines with the checkout path removed, at most $2 lines.
show() {
    local pattern="$1" limit="${2:-20}"
    grep -E "$pattern" "$LOG" | sed "s|$ROOT/||g" | awk '!seen[$0]++' | head -n "$limit" || true
}

# Picks the newest available iPhone simulator. Prints "UDID<TAB>name<TAB>iOS x.y".
pick_ci_simulator() {
    xcrun simctl list devices available -j | /usr/bin/python3 -c '
import json, re, sys

minimum = int(sys.argv[1])
best = None
for runtime, devices in json.load(sys.stdin).get("devices", {}).items():
    match = re.search(r"SimRuntime\.iOS-(\d+)(?:-(\d+))?(?:-(\d+))?$", runtime)
    if not match:
        continue
    version = tuple(int(part or 0) for part in match.groups())
    if version[0] < minimum:
        continue
    for device in devices:
        name = device.get("name", "")
        if not device.get("isAvailable", True) or not name.startswith("iPhone"):
            continue
        # Newest runtime first; then the plain model ("iPhone 17") over variants.
        plain = 1 if re.fullmatch(r"iPhone \d+", name) else 0
        key = (version, plain, name)
        if best is None or key > best[0]:
            best = (key, device["udid"], name)
if best is None:
    sys.exit(1)
print("%s\t%s\tiOS %d.%d" % (best[1], best[2], best[0][0][0], best[0][0][1]))
' "$MIN_IOS_MAJOR"
}

mkdir -p .build
: > "$LOG"

# ---------------------------------------------------------------- destination
if [[ "$MODE" == "ci" ]]; then
    if ! picked="$(pick_ci_simulator)"; then
        fail "no hay ningún simulador de iPhone con iOS $MIN_IOS_MAJOR o posterior"
    fi
    IFS=$'\t' read -r sim_id sim_name sim_os <<< "$picked"
    DESTINATION="platform=iOS Simulator,id=$sim_id"
    say "verify: simulador elegido: $sim_name ($sim_os)"
else
    DESTINATION="platform=iOS Simulator,name=$SN_SIM"
    say "verify: simulador: $SN_SIM"
fi

# ------------------------------------------------------------------- generate
if ! command -v xcodegen > /dev/null 2>&1; then
    fail "xcodegen no está instalado (brew install xcodegen)"
fi
say "verify: xcodegen generate"
if ! xcodegen generate >> "$LOG" 2>&1; then
    tail -n 20 "$LOG"
    fail "xcodegen generate ha fallado"
fi

# ----------------------------------------------------------------------- test
actions=(test)
if [[ "$CLEAN" -eq 1 ]]; then
    # A clean build makes every file report its warnings again. An incremental
    # build only recompiles what changed, so an old warning would go unseen.
    actions=(clean test)
fi
say "verify: xcodebuild ${actions[*]} (log en $LOG)"
{
    echo "verify: destination: $DESTINATION"
    echo "verify: derived data: $SN_DERIVED"
} >> "$LOG"

# No pipe here on purpose: the exit code is xcodebuild's own. The if/else form
# keeps both errexit and the ERR trap out of the way of a failing build.
if xcodebuild "${actions[@]}" \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$SN_DERIVED" \
    >> "$LOG" 2>&1; then
    build_status=0
else
    build_status=$?
fi

# XCTest prints one "Executed N tests" line per suite; the last one is the total.
executed_line="$(grep -E 'Executed [0-9]+ tests?, with [0-9]+ failures?' "$LOG" | tail -n 1 || true)"
tests_run=0
tests_failed=0
if [[ -n "$executed_line" ]]; then
    tests_run="$(sed -E 's/.*Executed ([0-9]+) tests?.*/\1/' <<< "$executed_line")"
    tests_failed="$(sed -E 's/.*with ([0-9]+) failures?.*/\1/' <<< "$executed_line")"
fi

if [[ "$build_status" -ne 0 ]]; then
    if [[ "$tests_failed" -gt 0 ]]; then
        show ': error: -\[|^Test Case .* failed ' 30
        fail "$tests_failed de $tests_run tests fallan"
    fi
    if grep -q -E '(error|fatal error): ' "$LOG"; then
        show '(error|fatal error): ' 30
        if grep -q -E 'Testing cancelled because the build failed|BUILD FAILED' "$LOG"; then
            fail "error de compilación"
        fi
        fail "xcodebuild ha fallado con código $build_status"
    fi
    tail -n 25 "$LOG" | sed "s|$ROOT/||g"
    fail "xcodebuild ha fallado con código $build_status"
fi

# ------------------------------------------------------------------- warnings
allow=".build/verify-known-warnings.regex"
if [[ -f "$KNOWN_WARNINGS" ]]; then
    grep -v -E '^[[:space:]]*(#|$)' "$KNOWN_WARNINGS" > "$allow" || true
else
    : > "$allow"
fi

drop_known() {
    if [[ -s "$allow" ]]; then
        grep -v -E -f "$allow" || true
    else
        cat
    fi
}

intents_pattern='appintentsmetadataprocessor.*(warning|error): |(warning|error): .*(AppIntents|App Intents)'
all_warnings="$(grep -E '(^|[^[:alnum:]_])warning: ' "$LOG" | drop_known | sed "s|$ROOT/||g" | awk '!seen[$0]++' || true)"
intents_issues="$(grep -E "$intents_pattern" "$LOG" | drop_known | sed "s|$ROOT/||g" | awk '!seen[$0]++' || true)"
build_warnings="$(grep -v -E "$intents_pattern" <<< "$all_warnings" || true)"

if [[ -n "$intents_issues" ]]; then
    head -n 30 <<< "$intents_issues"
    fail "avisos o errores de metadatos de App Intents: $(grep -c '' <<< "$intents_issues")"
fi
if [[ -n "$build_warnings" ]]; then
    head -n 30 <<< "$build_warnings"
    fail "avisos de compilación: $(grep -c '' <<< "$build_warnings")"
fi

# ---------------------------------------------------------------------- tests
if ! grep -q -F '** TEST SUCCEEDED **' "$LOG"; then
    fail "xcodebuild no ha confirmado los tests (falta TEST SUCCEEDED)"
fi
if [[ "$tests_run" -le 0 ]]; then
    fail "no se ha ejecutado ningún test"
fi

trap - ERR
suffix=""
if [[ "$CLEAN" -eq 0 ]]; then
    suffix=" (--fast: sin clean, no vale como puerta)"
fi
finish "VERIFY OK · $tests_run tests$suffix"
