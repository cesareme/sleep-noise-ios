import SwiftUI

/// The Horizon (03 §4.1): the picture of the sound.
///
/// One still line from margin to margin, in a 24 pt band that never moves.
/// In silence it is a hairline. While the engine produces audio its thickness
/// (1.5 to 3 pt) and its light (opacity 0.6 to 1) are the real RMS of the
/// output; there is no history and nothing scrolls. It carries the accent
/// because colour means sound, unless a finger is holding a level, and then
/// it steps back to plain ink.
///
/// It reads the engine, not a clock: if the engine goes quiet the line is a
/// hairline again as soon as the smoothed level gets there, and then the
/// timeline stops, so nothing ticks while nothing sounds.
struct SoundLine: View {
    /// Smoothed RMS of the output for a time constant in seconds: the
    /// engine's `smoothedOutputRMS(tau:)`.
    typealias Reading = (_ tau: TimeInterval) -> Float

    /// The engine has been asked to play. The line itself follows `reading`.
    var isSounding: Bool
    var reading: Reading

    @Environment(\.indexArbiter) private var arbiter
    @Environment(\.nightPhase) private var phase
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.sheetPresented) private var sheetPresented
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Something may still be on show: the timeline runs.
    @State private var awake = false
    @State private var rms: Float = 0
    @State private var spokenGate = SpokenLevelGate()
    @State private var holdsClaim = false

    private var interval: TimeInterval { Motion.horizonInterval(reduceMotion: reduceMotion) }
    private var tau: TimeInterval { Motion.horizonTau(reduceMotion: reduceMotion) }

    /// A sheet in front, the Night screens and a scene that is not active
    /// freeze the line: nobody is looking at it.
    private var isFrozen: Bool {
        sheetPresented || phase.isNightScreen || scenePhase != .active
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: interval, paused: !awake || isFrozen)) { context in
            SoundLineMark(
                rms: isFrozen ? 0 : rms,
                isSounding: isSounding,
                ownsAccent: arbiter.owns(.horizon),
                tick: interval
            )
            .onChange(of: context.date) { _, date in
                tick(at: date.timeIntervalSinceReferenceDate)
            }
        }
        .frame(height: Grid.horizonBand)
        .padding(.horizontal, Grid.margin)
        .onAppear {
            awake = isSounding
        }
        .onChange(of: isSounding) { _, sounding in
            if sounding { awake = true }
        }
        .onChange(of: isFrozen) { _, frozen in
            // A frozen line shows no colour, so it must not hold the accent.
            if frozen { releaseAccent() }
        }
        .onDisappear {
            releaseAccent()
        }
        .accessibilityElement()
        .accessibilityLabel(Text("ax.horizonte"))
        .accessibilityValue(Text(LocalizedStringKey(spokenGate.spoken.key)))
        .accessibilityAddTraits([.isImage, .updatesFrequently])
    }

    private func tick(at time: TimeInterval) {
        let next = reading(tau)
        let present = SoundLevelScale.presence(rms: next) > 0
        rms = next
        _ = spokenGate.update(SoundLevelScale.spoken(rms: next), at: time)
        if present {
            if !holdsClaim {
                holdsClaim = true
                arbiter.claim(.horizon)
            }
        } else {
            releaseAccent()
            // Quiet and not asked to play: nothing left to draw.
            if !isSounding {
                rms = 0
                awake = false
            }
        }
    }

    private func releaseAccent() {
        guard holdsClaim else { return }
        holdsClaim = false
        arbiter.release(.horizon)
    }
}

/// The drawing of the Horizon for one reading. No state: the same reading
/// always gives the same line.
struct SoundLineMark: View {
    var rms: Float
    var isSounding: Bool
    var ownsAccent: Bool
    /// Seconds between two readings, to glide from one to the next.
    var tick: TimeInterval = Motion.horizonInterval

    @Environment(\.nightPhase) private var phase

    private var level: Float { SoundLevelScale.level(rms: rms) }
    private var presence: Float { SoundLevelScale.presence(rms: rms) }

    private var color: Color {
        // The night page never shows the accent on the Horizon.
        if phase.isNight { return Ink.textNight }
        return ownsAccent ? Ink.index : Ink.text
    }

    var body: some View {
        ZStack {
            if phase.isNightScreen {
                // Night and small hours: a still 2 pt line. Continuous means
                // it sounds; absent means it is paused. It never writes.
                Rectangle()
                    .fill(Ink.textNight)
                    .frame(height: 2)
                    .opacity(isSounding ? 1 : 0)
                    .animation(Motion.stopCurve, value: isSounding)
            } else {
                // Silence drawn: the hairline is always there, underneath.
                Hairline()
                Rectangle()
                    .fill(color)
                    .frame(height: SoundLevelScale.thickness(level: level))
                    .opacity(SoundLevelScale.opacity(level: level) * Double(presence))
                    .animation(.linear(duration: tick), value: rms)
                    .animation(Motion.controlCurve, value: ownsAccent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityHidden(true)
    }
}

private struct SheetPresentedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Set by the page that presents a sheet, on itself, so the Horizon
    /// underneath can freeze. A sheet does not detect itself.
    var sheetPresented: Bool {
        get { self[SheetPresentedKey.self] }
        set { self[SheetPresentedKey.self] = newValue }
    }
}

#Preview("Horizon") {
    VStack(spacing: Grid.group) {
        SoundLineMark(rms: 0, isSounding: false, ownsAccent: false)
        SoundLineMark(rms: 0.02, isSounding: true, ownsAccent: true)
        SoundLineMark(rms: 0.12, isSounding: true, ownsAccent: true)
        SoundLineMark(rms: 0.4, isSounding: true, ownsAccent: true)
        SoundLineMark(rms: 0.12, isSounding: true, ownsAccent: false)
        SoundLineMark(rms: 0.12, isSounding: true, ownsAccent: false)
            .environment(\.nightPhase, .nightPage)
    }
    .frame(height: 320)
    .padding(.horizontal, Grid.margin)
    .frame(maxHeight: .infinity)
    .grafitoRoot()
}
