import SwiftUI

/// What the page wants of its paint right now, in one value the page
/// compares between draws: the scene of the mix that sounds, the phase
/// the rule gives and the scale of the screen. Pure, built from the model
/// and the environment; the page acts on a change of it, never in a draw.
struct PagePaint: Equatable {
    var scene: PaintScene?
    var phase: PaintPhase
    var scale: CGFloat
    /// The sound is paused: the paint dries to 0.6 and does not fade.
    var isPlaying: Bool
    /// The absence is the night's: the paint fades and does not come back
    /// on its own (`PaintPolicy.fadeIsFinal`).
    var fadeIsFinal: Bool
    /// The app is in the background: the raster goes at once, unseen.
    var inBackground: Bool

    /// The scene of what sounds: the layers above zero that may play, the
    /// six highest, seeded by the mix and the day. Nil when nothing sounds.
    @MainActor
    static func scene(
        model: MixerModel, hasFullAccess: Bool, width: CGFloat, isAccessibilitySize: Bool
    ) -> PaintScene? {
        var levels = MixLoad(levels: model.levels, hasFullAccess: hasFullAccess).audibleLevels
        for sound in model.waitingLayers { levels[sound] = 0 }
        let identity = model.activeHouseMix?.rawValue
            ?? model.loadedSavedMixID?.uuidString
            ?? PaintScene.identity(ofSounds: levels)
        let geometry = PaintWindowGeometry(
            width: width,
            height: isAccessibilitySize ? PaintWindowGeometry.accessibilityHeight : PaintWindowGeometry.height
        )
        return PaintScene(
            levels: levels,
            seed: PaintScene.seed(identity: identity, day: model.currentDate, calendar: model.currentCalendar),
            geometry: geometry
        )
    }
}

extension PaintConditions {
    /// The conditions of the paint as a view reads them: the model's clock
    /// and phases, the switches of the system and what is in front.
    @MainActor
    init(
        model: MixerModel,
        isLuminanceReduced: Bool,
        contrast: ColorSchemeContrast,
        reduceTransparency: Bool,
        reduceMotion: Bool,
        sheetPresented: Bool,
        scenePhase: ScenePhase
    ) {
        var increaseContrast = contrast == .increased
        var reduceMotion = reduceMotion
        #if DEBUG
        increaseContrast = increaseContrast || PaintArguments.forcesIncreasedContrast
        reduceMotion = reduceMotion || PaintArguments.forcesReduceMotion
        #endif
        self.init(now: model.currentDate)
        if model.isSmallHours {
            nightPhase = .smallHours
        } else if model.isBedtime {
            nightPhase = .night
        } else if model.isNightSession {
            nightPhase = .nightPage
        }
        self.isLuminanceReduced = isLuminanceReduced
        self.increaseContrast = increaseContrast
        self.reduceTransparency = reduceTransparency
        self.reduceMotion = reduceMotion
        setting = PaintSetting.effective(model.paintSetting, reduceMotion: reduceMotion, increaseContrast: increaseContrast)
        self.sheetPresented = sheetPresented
        sceneActive = scenePhase == .active
        inBackground = scenePhase == .background
        calendar = model.currentCalendar
    }
}

/// The latch of the night fade (lenguaje §4, "after the fade it does not
/// come back on its own"): what arms it and what opens it, apart from the
/// deliberate ways out the page handles (leaving the night page, Night
/// giving the page back by day).
enum PaintLatch {
    /// A final absence (`PaintPolicy.fadeIsFinal`) latches only when there
    /// was paint to fade: the app opened at 22:00 without a Play, or back
    /// in front at 21:05 after dropping its raster in the background, has
    /// seen no fade, and the next day paints as any day.
    static func arms(fadeIsFinal: Bool, paintExists: Bool) -> Bool {
        fadeIsFinal && paintExists
    }

    /// Coming back to the front from the background by day is a new
    /// visit: the latch opens. Not at night, and never while the app stays
    /// in front (07:00 does not undo the fade).
    static func opensOnForeground(now: Date, calendar: Calendar) -> Bool {
        !NightWindow.contains(now, calendar: calendar)
    }
}

/// The durations of the paint's transitions (lenguaje §3 and §4,
/// camino-contenido.md): born in 2 s, dimmed in 1.5 s and back in 0.8 s,
/// dried in 1.5 s and back in 0.8 s, faded in 2 s. With Reduce Motion
/// every one is 0.25 s.
enum PaintMotion {
    static func birth(reduceMotion: Bool) -> TimeInterval { Motion.phase(reduceMotion: reduceMotion) }
    static func fade(reduceMotion: Bool) -> TimeInterval { Motion.phase(reduceMotion: reduceMotion) }
    static func dim(reduceMotion: Bool) -> TimeInterval { reduceMotion ? Motion.phaseReduced : Motion.stop }
    static func lift(reduceMotion: Bool) -> TimeInterval { reduceMotion ? Motion.phaseReduced : Motion.start }

    /// The opacity of a window that exists: the phase's, dried while the
    /// sound is paused (pause is not night).
    static func opacity(phase: PaintPhase, isPlaying: Bool) -> Double {
        phase.opacity * (isPlaying ? 1 : PaintBreath.driedOpacity)
    }

    /// How long a change of opacity takes: down slowly, up quickly.
    static func duration(from: Double, to: Double, born: Bool, reduceMotion: Bool) -> TimeInterval {
        if born { return birth(reduceMotion: reduceMotion) }
        return to < from ? dim(reduceMotion: reduceMotion) : lift(reduceMotion: reduceMotion)
    }
}
