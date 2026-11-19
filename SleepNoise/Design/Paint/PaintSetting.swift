import Foundation

/// The one setting of the paint (exploration 12 §7 fase 2): "Paint: by day"
/// or "never". Stored under a stable key. "By day" is the default and never
/// means more than the rule in `PaintPolicy` allows.
///
/// With Reduce Motion and Increase Contrast both on, the effective setting
/// is "never" whatever is stored: the paint turns itself off, and comes
/// back when either switch is turned off again. The stored choice is not
/// touched, so nothing is lost behind the person's back.
enum PaintSetting: String, CaseIterable {
    case byDay
    case never

    /// The key in the defaults. Stable: a rename of the key loses the choice.
    static let key = "sleepnoise.paint.v1"

    static let `default` = PaintSetting.byDay

    /// The stored setting, or the default.
    static func stored(in defaults: UserDefaults) -> PaintSetting {
        defaults.string(forKey: key).flatMap(PaintSetting.init) ?? .default
    }

    /// What the paint goes by: the stored choice, or "never" when both
    /// accessibility switches are on at once.
    static func effective(_ stored: PaintSetting, reduceMotion: Bool, increaseContrast: Bool) -> PaintSetting {
        if reduceMotion && increaseContrast { return .never }
        return stored
    }
}
