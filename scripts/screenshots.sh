#!/usr/bin/env bash
#
# The six captures of the App Store, in Spanish and in English.
#
#   scripts/screenshots.sh              builds, captures and composes both languages
#   scripts/screenshots.sh --no-build   reuses the app already built in SN_DERIVED
#   scripts/screenshots.sh es           one language only (es, en)
#
# Environment:
#   SN_SHOT_DEVICE  device type of the simulator the script creates for the
#                   run and deletes when it ends, default "iPhone 17 Pro"
#                   (document 11 §4.4)
#   SN_SHOT_UDID    an existing simulator to use instead; nothing is created
#                   or deleted, the app is installed over the one it has and
#                   its status bar override is cleared at the end
#   SN_DERIVED      DerivedData path, default .build/DerivedData
#   SN_SHOT_OUT     output folder, default .build/store-shots
#
# What it does: generates the project, creates a simulator of its own, builds
# the Debug app for it, installs it, pins the status bar (9:41, full battery,
# no carrier) and, for each language, launches each of the six screens of the
# store (C57, document 11 §2.3 to §2.8) in its staged state (`-pageState`, see
# PageDebug.swift), takes the screen and lays it on the canvas of document 11
# §2.2 with its headline, which is read from docs/store/ficha-<language>.md.
#
#   .build/store-shots/<language>/NN-name.png       the capture to upload
#   .build/store-shots/<language>/raw/NN-name.png   the screen alone
#
# The capture to upload is 1320 × 2868 px, what App Store Connect asks of the
# 6.9" display; the screen alone has the size of the simulator. Nothing here
# is versioned and nothing is uploaded. The simulator is new at every run, so
# no setting of another one (contrast, bold text, 24 hours) reaches the
# captures and no simulator that someone else is using is touched. The staged
# states run on a scripted store, a scratch defaults suite and
# `-silentOutput`: no sound and no purchase. The simulator is deleted however
# the script ends. The last line printed is "SHOTS OK · N captures" or
# "SHOTS FAIL · reason".

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DEVICE_TYPE="${SN_SHOT_DEVICE:-iPhone 17 Pro}"
SN_DERIVED="${SN_DERIVED:-.build/DerivedData}"
OUT="${SN_SHOT_OUT:-.build/store-shots}"
LOG=".build/screenshots.log"
BUNDLE_ID="com.cesareme.sleepnoise"
EXPECTED_SIZE="1320x2868"
# Seconds between the launch and the capture: sheets are up, the Pro price
# has arrived and the home indicator has gone.
SETTLE="${SN_SHOT_SETTLE:-6}"
# Every screen is taken twice and the top of the two takes must match: a
# simulator that has just been created shows banners of the system ("Ready
# for…") over whatever is on screen. The takes are further apart than a
# banner lasts, so one of them is always without it. When they differ the
# script waits and takes both again, up to RETAKES times: within the minute
# after which Night dims its screen.
RETAKE_GAP=8
RETAKE_WAIT=8
RETAKES=3

# number-name, staged state. The order is the order of the store.
SHOTS=(
    "01-page-playing:storePlaying"
    "02-first-use:storeFirstUse"
    "03-layers:storeLayers"
    "04-tide:storeTide"
    "05-night:storeNight"
    "06-not-here:settingsNotHere"
)

BUILD=1
LANGUAGES=()
for arg in "$@"; do
    case "$arg" in
        --no-build) BUILD=0 ;;
        es|en) LANGUAGES+=("$arg") ;;
        -h|--help)
            sed -n '3,37p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "screenshots.sh: unknown argument: $arg" >&2
            echo "SHOTS FAIL · argumento desconocido: $arg"
            exit 2
            ;;
    esac
done
if [[ "${#LANGUAGES[@]}" -eq 0 ]]; then
    LANGUAGES=(es en)
fi

say() { printf '%s\n' "$*"; }

UDID=""
# 1 when the simulator is the script's own: created here, deleted here.
OWNS_DEVICE=0
cleanup() {
    trap - EXIT ERR INT TERM
    [[ -n "$UDID" ]] || return 0
    if [[ "$OWNS_DEVICE" -eq 1 ]]; then
        xcrun simctl shutdown "$UDID" > /dev/null 2>&1 || true
        xcrun simctl delete "$UDID" > /dev/null 2>&1 || true
    else
        xcrun simctl terminate "$UDID" "$BUNDLE_ID" > /dev/null 2>&1 || true
        xcrun simctl status_bar "$UDID" clear > /dev/null 2>&1 || true
    fi
}

fail() {
    trap - ERR
    say "SHOTS FAIL · $1"
    exit 1
}

# However the script ends (the last line, a failure, Ctrl-C, a kill), the
# simulator it created goes with it.
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'fail "error inesperado del script en la línea $LINENO (log: $LOG)"' ERR

locale_of() {
    case "$1" in
        es) echo "es_ES" ;;
        en) echo "en_US" ;;
    esac
}

mkdir -p .build/shots
: > "$LOG"

# ------------------------------------------------------------------ simulator
if [[ -n "${SN_SHOT_UDID:-}" ]]; then
    # Someone's simulator, on their word: used as it is and left there.
    UDID="$SN_SHOT_UDID"
    if ! xcrun simctl list devices available | grep -q "($UDID)"; then
        UDID=""
        fail "no hay ningún simulador disponible con el identificador de SN_SHOT_UDID"
    fi
    say "screenshots: simulador existente (SN_SHOT_UDID)"
else
    # A simulator of the script's own, with the newest runtime installed.
    if ! UDID="$(xcrun simctl create "SleepNoise shots $$" "$DEVICE_TYPE" 2>> "$LOG")" || [[ -z "$UDID" ]]; then
        UDID=""
        fail "no se ha podido crear un simulador \"$DEVICE_TYPE\" (xcrun simctl list devicetypes)"
    fi
    OWNS_DEVICE=1
    say "screenshots: simulador propio: $DEVICE_TYPE"
fi

# ---------------------------------------------------------------------- build
if [[ "$BUILD" -eq 1 ]]; then
    if ! command -v xcodegen > /dev/null 2>&1; then
        fail "xcodegen no está instalado (brew install xcodegen)"
    fi
    say "screenshots: xcodegen generate"
    if ! xcodegen generate >> "$LOG" 2>&1; then
        tail -n 20 "$LOG"
        fail "xcodegen generate ha fallado"
    fi
    say "screenshots: xcodebuild build (log en $LOG)"
    if ! xcodebuild build \
        -project SleepNoise.xcodeproj \
        -scheme SleepNoise \
        -configuration Debug \
        -destination "platform=iOS Simulator,id=$UDID" \
        -derivedDataPath "$SN_DERIVED" \
        >> "$LOG" 2>&1; then
        grep -a -E '(error|fatal error): ' "$LOG" | sed "s|$ROOT/||g" | head -n 20 || true
        fail "error de compilación"
    fi
fi
APP="$SN_DERIVED/Build/Products/Debug-iphonesimulator/SleepNoise.app"
if [[ ! -d "$APP" ]]; then
    fail "no hay app compilada en $APP (quita --no-build)"
fi

say "screenshots: compositor"
if ! xcrun --sdk macosx swiftc -O -o .build/shots/shot-composer scripts/screenshots/ShotComposer.swift >> "$LOG" 2>&1; then
    tail -n 20 "$LOG"
    fail "el compositor no compila"
fi

# -------------------------------------------------------------------- install
xcrun simctl bootstatus "$UDID" -b >> "$LOG" 2>&1 || fail "el simulador no arranca"
if [[ "$OWNS_DEVICE" -eq 1 ]]; then
    # The app is dark whatever the system says; the system's own surfaces
    # (the home indicator) follow this.
    xcrun simctl ui "$UDID" appearance dark >> "$LOG" 2>&1 || true
fi
xcrun simctl terminate "$UDID" "$BUNDLE_ID" > /dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP" >> "$LOG" 2>&1 || fail "no se ha podido instalar la app"
# The captures hide the status bar (document 11 §2.2); it is pinned all the
# same, so that anything of the system that did show would show 9:41.
xcrun simctl status_bar "$UDID" override \
    --time "9:41" --batteryState charged --batteryLevel 100 \
    --operatorName "" --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 >> "$LOG" 2>&1 || fail "no se ha podido fijar la barra de estado"

# -------------------------------------------------------------------- capture
size_of() {
    /usr/bin/sips -g pixelWidth -g pixelHeight "$1" 2> /dev/null \
        | awk '/pixelWidth/ { w = $2 } /pixelHeight/ { h = $2 } END { print w "x" h }'
}

count=0
for language in "${LANGUAGES[@]}"; do
    locale="$(locale_of "$language")"
    ficha="docs/store/ficha-$language.md"
    [[ -f "$ficha" ]] || fail "falta $ficha"
    rm -rf "${OUT:?}/$language"
    mkdir -p "$OUT/$language/raw"
    index=0
    for shot in "${SHOTS[@]}"; do
        index=$((index + 1))
        name="${shot%%:*}"
        state="${shot##*:}"
        raw="$OUT/$language/raw/$name.png"
        final="$OUT/$language/$name.png"
        say "screenshots: $language $name ($state)"
        xcrun simctl terminate "$UDID" "$BUNDLE_ID" > /dev/null 2>&1 || true
        xcrun simctl launch "$UDID" "$BUNDLE_ID" \
            -pageState "$state" -storeShot -silentOutput -pageType large \
            -AppleLanguages "($language)" -AppleLocale "$locale" \
            >> "$LOG" 2>&1 || fail "no se ha podido lanzar $state"
        sleep "$SETTLE"
        attempt=0
        while :; do
            attempt=$((attempt + 1))
            xcrun simctl io "$UDID" screenshot --type=png "$raw.first.png" >> "$LOG" 2>&1 \
                || fail "no se ha podido capturar $state"
            sleep "$RETAKE_GAP"
            xcrun simctl io "$UDID" screenshot --type=png "$raw" >> "$LOG" 2>&1 \
                || fail "no se ha podido capturar $state"
            if .build/shots/shot-composer --same-top "$raw.first.png" "$raw" >> "$LOG" 2>&1; then
                break
            fi
            if [[ "$attempt" -ge "$RETAKES" ]]; then
                fail "algo del sistema tapa la pantalla en $language $name tras $RETAKES intentos"
            fi
            say "screenshots: $language $name: algo pasa por encima de la pantalla, se repite"
            sleep "$RETAKE_WAIT"
        done
        rm -f "$raw.first.png"
        if ! .build/shots/shot-composer --ficha "$ficha" --index "$index" --screen "$raw" --out "$final" 2>> "$LOG"; then
            tail -n 3 "$LOG"
            fail "el compositor ha fallado en $language $name"
        fi
        size="$(size_of "$final")"
        if [[ "$size" != "$EXPECTED_SIZE" ]]; then
            fail "$final mide $size, no $EXPECTED_SIZE"
        fi
        count=$((count + 1))
    done
done

trap - ERR
say "SHOTS OK · $count captures en $OUT"
