import Foundation

/// Catalog strings with arguments. The catalog key is the bare key
/// ("ax.capa"), never the key plus its format, so nothing is interpolated
/// into a `LocalizedStringKey`.
enum Localized {
    static func string(_ key: String, bundle: Bundle = .main) -> String {
        String(localized: String.LocalizationValue(key), bundle: bundle)
    }

    static func format(_ key: String, bundle: Bundle = .main, _ arguments: CVarArg...) -> String {
        String(format: string(key, bundle: bundle), arguments: arguments)
    }
}
