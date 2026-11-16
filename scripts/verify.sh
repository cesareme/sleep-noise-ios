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
#   - an entry of that list is not a valid expression, or is broad enough to
#     hide an unrelated warning
#   - a test was skipped (XCTSkip is not allowed)
#   - fewer tests ran than the floor in scripts/verify-min-tests.txt
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
MIN_TESTS_FILE="scripts/verify-min-tests.txt"
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
            sed -n '3,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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
    grep -a -E "$pattern" "$LOG" | sed "s|$ROOT/||g" | awk '!seen[$0]++' | head -n "$limit" || true
}

# Picks the newest available iPhone simulator whose runtime is not newer than
# the simulator SDK of the selected Xcode: an image can carry a later Xcode with
# its own runtime, and xcodebuild may refuse a runtime ahead of its SDK.
# Prints "UDID<TAB>name<TAB>iOS x.y".
pick_ci_simulator() {
    local sdk_version
    sdk_version="$(xcrun --sdk iphonesimulator --show-sdk-version 2> /dev/null || true)"
    xcrun simctl list devices available -j | /usr/bin/python3 -c '
import json, re, sys

minimum = int(sys.argv[1])
cap = None
cap_match = re.match(r"(\d+)\.(\d+)", sys.argv[2] if len(sys.argv) > 2 else "")
if cap_match:
    cap = (int(cap_match.group(1)), int(cap_match.group(2)))
found = []
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
        found.append(((version, plain, name), device["udid"], name))
# If the cap leaves nothing (or the SDK version is unknown), any runtime will do.
within = [item for item in found if cap is None or item[0][0][:2] <= cap]
pool = within or found
if not pool:
    sys.exit(1)
best = max(pool, key=lambda item: item[0])
print("%s\t%s\tiOS %d.%d" % (best[1], best[2], best[0][0][0], best[0][0][1]))
' "$MIN_IOS_MAJOR" "$sdk_version"
}

mkdir -p .build
: > "$LOG"

# --------------------------------------------------------- gate configuration
# Both files are checked before the build so a broken gate fails in seconds.
allow=".build/verify-known-warnings.regex"
if [[ -f "$KNOWN_WARNINGS" ]]; then
    grep -v -E '^[[:space:]]*(#|$)' "$KNOWN_WARNINGS" > "$allow" || true
else
    : > "$allow"
fi
if [[ -s "$allow" ]]; then
    # grep exits 0 or 1 for a valid list and 2 for a broken expression. A broken
    # or greedy entry would otherwise drop every warning and read as "no warnings".
    allow_status=0
    grep -E -f "$allow" /dev/null > /dev/null 2>&1 || allow_status=$?
    if [[ "$allow_status" -gt 1 ]]; then
        fail "expresión no válida en $KNOWN_WARNINGS"
    fi
    canaries='Canary.swift:1:1: warning: verify canary
ld: warning: verify canary
appintentsmetadataprocessor[1:1] warning: verify canary
appintentsmetadataprocessor[1:1] error: verify canary'
    canary_hits="$(grep -c -E -f "$allow" <<< "$canaries" || true)"
    if [[ "$canary_hits" != "0" ]]; then
        fail "una entrada de $KNOWN_WARNINGS es demasiado amplia: tapa avisos ajenos"
    fi
fi

if [[ ! -f "$MIN_TESTS_FILE" ]]; then
    fail "falta $MIN_TESTS_FILE"
fi
min_tests="$(grep -v -E '^[[:space:]]*(#|$)' "$MIN_TESTS_FILE" | head -n 1 | tr -d '[:space:]' || true)"
if [[ ! "$min_tests" =~ ^[0-9]+$ ]] || [[ "$min_tests" -le 0 ]]; then
    fail "$MIN_TESTS_FILE no contiene un número de tests válido"
fi

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
{
    echo "verify: $(xcodebuild -version 2>&1 | tr '\n' ' ' || true)"
    echo "verify: xcodegen $(xcodegen --version 2>&1 | tr '\n' ' ' || true)"
} >> "$LOG"
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
# With a skipped test the line reads "with K tests skipped and F failures".
# grep -a everywhere on the log: a stray NUL byte in test output would make BSD
# grep answer "Binary file matches" instead of the lines.
executed_line="$(grep -a -E 'Executed [0-9]+ tests?, with ([0-9]+ tests? skipped and )?[0-9]+ failures?' "$LOG" | tail -n 1 || true)"
tests_run=0
tests_failed=0
tests_skipped=0
if [[ -n "$executed_line" ]]; then
    tests_run="$(sed -E 's/.*Executed ([0-9]+) tests?.*/\1/' <<< "$executed_line")"
    tests_failed="$(sed -E 's/.*[^0-9]([0-9]+) failures?.*/\1/' <<< "$executed_line")"
    tests_skipped="$(sed -n -E 's/.*with ([0-9]+) tests? skipped.*/\1/p' <<< "$executed_line")"
    tests_skipped="${tests_skipped:-0}"
fi

if [[ "$build_status" -ne 0 ]]; then
    if [[ "$tests_failed" -gt 0 ]]; then
        show ': error: -\[|^Test Case .* failed ' 30
        fail "$tests_failed de $tests_run tests fallan"
    fi
    if grep -a -q -E '(error|fatal error): ' "$LOG"; then
        show '(error|fatal error): ' 30
        if grep -a -q -E 'Testing cancelled because the build failed|BUILD FAILED' "$LOG"; then
            fail "error de compilación"
        fi
        fail "xcodebuild ha fallado con código $build_status"
    fi
    tail -n 25 "$LOG" | sed "s|$ROOT/||g"
    fail "xcodebuild ha fallado con código $build_status"
fi

# ------------------------------------------------------------------- warnings
# Writes to $2 the log lines that match $1 and are not known warnings, without
# the checkout path and without repeats. Only "no lines" (grep exit 1) is
# tolerated: any other grep failure must not read as "no warnings".
scan_log() {
    local pattern="$1" out="$2" status=0
    grep -a -E "$pattern" "$LOG" > "$out.raw" || status=$?
    if [[ "$status" -gt 1 ]]; then
        fail "grep ha fallado ($status) al leer $LOG"
    fi
    if [[ -s "$allow" ]]; then
        status=0
        grep -a -v -E -f "$allow" "$out.raw" > "$out.kept" || status=$?
        if [[ "$status" -gt 1 ]]; then
            fail "expresión no válida en $KNOWN_WARNINGS"
        fi
    else
        cp "$out.raw" "$out.kept"
    fi
    sed "s|$ROOT/||g" "$out.kept" | awk '!seen[$0]++' > "$out" \
        || fail "no se han podido filtrar los avisos de $LOG"
    rm -f "$out.raw" "$out.kept"
}

intents_pattern='appintentsmetadataprocessor.*(warning|error): |(warning|error): .*(AppIntents|App Intents)'
scan_log '(^|[^[:alnum:]_])warning: ' .build/verify-warnings.txt
scan_log "$intents_pattern" .build/verify-intents.txt
all_warnings="$(cat .build/verify-warnings.txt)"
intents_issues="$(cat .build/verify-intents.txt)"
build_warnings="$(grep -a -v -E "$intents_pattern" <<< "$all_warnings" || true)"

if [[ -n "$intents_issues" ]]; then
    head -n 30 <<< "$intents_issues"
    fail "avisos o errores de metadatos de App Intents: $(grep -c '' <<< "$intents_issues")"
fi
if [[ -n "$build_warnings" ]]; then
    head -n 30 <<< "$build_warnings"
    fail "avisos de compilación: $(grep -c '' <<< "$build_warnings")"
fi

# ---------------------------------------------------------------------- tests
if ! grep -a -q -F '** TEST SUCCEEDED **' "$LOG"; then
    fail "xcodebuild no ha confirmado los tests (falta TEST SUCCEEDED)"
fi
if [[ "$tests_run" -le 0 ]]; then
    fail "no se ha ejecutado ningún test"
fi
if [[ "$tests_skipped" -gt 0 ]]; then
    show ' skipped ' 20
    fail "$tests_skipped de $tests_run tests saltados (XCTSkip no está permitido)"
fi
if [[ "$tests_run" -lt "$min_tests" ]]; then
    fail "$tests_run tests, el mínimo es $min_tests ($MIN_TESTS_FILE)"
fi

trap - ERR
suffix=""
if [[ "$CLEAN" -eq 0 ]]; then
    suffix=" (--fast: sin clean, no vale como puerta)"
fi
finish "VERIFY OK · $tests_run tests$suffix"
