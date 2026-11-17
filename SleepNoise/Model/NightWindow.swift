import Foundation

/// The one night window of the app (C40): 21:00 to 07:00, local time.
///
/// Inside it nothing is sold (C08) and no tip or review prompt is shown.
/// Every rule that says "at night" reads these two constants, so the window
/// cannot drift between features.
enum NightWindow {
    /// 21:00:00 is inside.
    static let startHour = 21
    /// 07:00:00 is outside.
    static let endHour = 7

    /// True when the local hour of `date` in `calendar` is 21 or later, or
    /// earlier than 7.
    static func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: date)
        return hour >= startHour || hour < endHour
    }

    /// The next moment the window begins or ends: the first 21:00 or 07:00
    /// after `date`, local time.
    static func nextBorder(after date: Date, calendar: Calendar = .current) -> Date {
        let borders = [startHour, endHour].compactMap { hour in
            calendar.nextDate(
                after: date,
                matching: DateComponents(hour: hour, minute: 0, second: 0),
                matchingPolicy: .nextTime
            )
        }
        return borders.min() ?? date.addingTimeInterval(3_600)
    }

    /// `contains` for the present moment. The clock comes in as a closure so
    /// that callers never read `Date()` on their own and tests can pin it.
    static func isNight(calendar: Calendar = .current, now: () -> Date = { Date() }) -> Bool {
        contains(now(), calendar: calendar)
    }
}
