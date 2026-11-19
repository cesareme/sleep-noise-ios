import Foundation

/// The one rule of day and night for the house paint (exploration 12 §3,
/// decided 19-11-2026): the paint exists by day and nowhere else. Nothing
/// lights the room.
///
/// It is false inside `NightWindow` (21:00 to 07:00), on the night page
/// (C40, one ink), and with Reduce Transparency or Increase Contrast on:
/// then the row is exactly the row without paint. Every view that paints
/// asks here and nowhere else, so the rule cannot drift.
enum PaintPolicy {
    static func showsHousePaint(
        now: Date,
        nightSession: Bool,
        reduceTransparency: Bool,
        increaseContrast: Bool,
        calendar: Calendar = .current
    ) -> Bool {
        !nightSession
            && !reduceTransparency
            && !increaseContrast
            && !NightWindow.contains(now, calendar: calendar)
    }

    /// The phase of the painted window of the page for one set of
    /// conditions (exploration 12 §3 and §7 fase 2). One function, so the
    /// view never works the rule out on its own.
    ///
    /// Absent wins over everything: inside the night window, on the night
    /// page, in Night and Small Hours, with the screen's luminance reduced,
    /// with Increase Contrast or Reduce Transparency, or with the setting
    /// "never". Then dimmed: a sheet in front or the scene not active,
    /// where nobody looks and the live layer does not move either. Then
    /// frozen: Reduce Motion keeps the paint and stills the live layer.
    /// Else visible.
    static func phase(_ conditions: PaintConditions) -> PaintPhase {
        let hidden = !showsHousePaint(
            now: conditions.now,
            nightSession: conditions.nightPhase.isNight,
            reduceTransparency: conditions.reduceTransparency,
            increaseContrast: conditions.increaseContrast,
            calendar: conditions.calendar
        )
        if hidden || conditions.isLuminanceReduced || conditions.setting == .never {
            return .absent
        }
        if conditions.sheetPresented || !conditions.sceneActive {
            return .dimmed
        }
        if conditions.reduceMotion {
            return .frozen
        }
        return .visible
    }
}

/// What the page does with the paint right now.
enum PaintPhase: Equatable, CaseIterable {
    /// Full, breathing with the sound and sliding with the tide.
    case visible
    /// A sheet in front or the app at the back: 0.3 of its opacity, still.
    case dimmed
    /// Reduce Motion: on show, the live layer still.
    case frozen
    /// No view and no raster: nil, not opacity 0.
    case absent

    /// Something is drawn.
    var exists: Bool { self != .absent }

    /// The live layer follows the sound and the tide.
    var isLive: Bool { self == .visible }

    /// The opacity of the window in this phase (the veil comes on top).
    var opacity: Double {
        switch self {
        case .visible, .frozen: return 1
        case .dimmed: return PaintBreath.dimmedOpacity
        case .absent: return 0
        }
    }
}

/// Everything the phase of the paint depends on, in one place, so a test
/// can set it on a table and a view hands it over without thinking.
struct PaintConditions: Equatable {
    var now: Date
    var nightPhase: NightPhase = .day
    var isLuminanceReduced = false
    var increaseContrast = false
    var reduceTransparency = false
    var reduceMotion = false
    var setting: PaintSetting = .byDay
    var sheetPresented = false
    var sceneActive = true
    var calendar: Calendar = .current
}
