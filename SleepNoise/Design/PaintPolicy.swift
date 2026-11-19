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
}
