import Foundation

/// At night nothing is sold (C08): the one gate every path to the Pro sheet
/// goes through.
///
/// Closed inside `NightWindow` and for as long as the night page lasts,
/// whatever the hour: that page comes from the Night screen and inherits its
/// rule. A request that arrives while the gate is closed is dropped; there
/// is no queue and nothing is offered later.
enum SaleGate {
    static func isOpen(at date: Date, calendar: Calendar = .current, nightSession: Bool = false) -> Bool {
        !nightSession && !NightWindow.contains(date, calendar: calendar)
    }
}
