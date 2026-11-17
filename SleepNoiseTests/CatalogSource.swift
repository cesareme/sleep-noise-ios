import Foundation
import XCTest

/// The two string catalogs and the Swift sources of the app, read from the
/// checkout: the catalogs are compiled away at build time, and what the
/// audits look at is what people wrote.
enum CatalogSource {
    static let interface = "Localizable.xcstrings"
    static let shortcuts = "AppShortcuts.xcstrings"
    static let catalogs = [interface, shortcuts]
    static let languages = ["en", "es"]

    static var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    /// One value a person may read or hear: a string of one key in one
    /// language. A plural has one per form and a set of phrases one per
    /// phrase.
    struct Value {
        let catalog: String
        let key: String
        let language: String
        /// "other", "one"… for a plural form; nil otherwise.
        let form: String?
        let state: String
        let text: String

        var place: String { "\(catalog) \(key) [\(language)\(form.map { " " + $0 } ?? "")]" }

        /// The text without what the code fills in: format specifiers and
        /// the parameters of a Siri phrase are not copy.
        var copy: String { CatalogSource.withoutPlaceholders(text) }
    }

    static func strings(_ catalog: String) throws -> [String: [String: Any]] {
        let url = root.appendingPathComponent("SleepNoise/Resources/\(catalog)")
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        let strings = try XCTUnwrap(json?["strings"] as? [String: [String: Any]], catalog)
        return strings
    }

    static func localizations(_ entry: [String: Any]) -> [String: [String: Any]] {
        entry["localizations"] as? [String: [String: Any]] ?? [:]
    }

    /// Every value of a catalog, in every language it carries.
    static func values(_ catalog: String) throws -> [Value] {
        var found: [Value] = []
        for (key, entry) in try strings(catalog) {
            for (language, node) in localizations(entry) {
                found.append(contentsOf: values(in: node, catalog: catalog, key: key, language: language))
            }
        }
        return found.sorted { ($0.key, $0.language, $0.form ?? "") < ($1.key, $1.language, $1.form ?? "") }
    }

    static func allValues() throws -> [Value] {
        try catalogs.flatMap { try values($0) }
    }

    private static func values(
        in node: [String: Any], catalog: String, key: String, language: String
    ) -> [Value] {
        if let unit = node["stringUnit"] as? [String: Any] {
            return [Value(
                catalog: catalog, key: key, language: language, form: nil,
                state: unit["state"] as? String ?? "", text: unit["value"] as? String ?? ""
            )]
        }
        if let set = node["stringSet"] as? [String: Any] {
            let state = set["state"] as? String ?? ""
            return (set["values"] as? [String] ?? []).map {
                Value(catalog: catalog, key: key, language: language, form: nil, state: state, text: $0)
            }
        }
        if let plural = (node["variations"] as? [String: Any])?["plural"] as? [String: [String: Any]] {
            return plural.flatMap { form, child in
                values(in: child, catalog: catalog, key: key, language: language).map {
                    Value(
                        catalog: catalog, key: key, language: language, form: form,
                        state: $0.state, text: $0.text
                    )
                }
            }
        }
        return []
    }

    /// True when the key varies by plural in that language.
    static func isPlural(_ entry: [String: Any], language: String) -> Bool {
        let node = localizations(entry)[language]
        return (node?["variations"] as? [String: Any])?["plural"] != nil
    }

    // MARK: Placeholders

    /// `%lld`, `%2$@`… as written.
    static func specifiers(in text: String) -> [String] {
        matches(of: #"%(?:\d+\$)?(?:lld|ld|d|@|(?:\.\d+)?f)"#, in: text)
    }

    /// `${mix}`, `${applicationName}`: the parameters of a Siri phrase.
    static func parameters(in text: String) -> [String] {
        matches(of: #"\$\{[A-Za-z]+\}"#, in: text)
    }

    static func withoutPlaceholders(_ text: String) -> String {
        var copy = text
        for pattern in [#"\$\{[A-Za-z]+\}"#, #"%(?:\d+\$)?(?:lld|ld|d|@|(?:\.\d+)?f)"#] {
            copy = copy.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)
        }
        return copy
    }

    static func matches(of pattern: String, in text: String, options: NSRegularExpression.Options = []) -> [String] {
        guard let expression = try? NSRegularExpression(pattern: pattern, options: options) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return expression.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }
}

/// A string literal of a Swift source file of the app, with the code that
/// leads to it.
struct SourceLiteral {
    /// Path under `SleepNoise/`.
    let file: String
    let line: Int
    /// What is between the quotes, as written (escapes included).
    let text: String
    /// The code before the opening quote, on one line and without the
    /// literals before it (each one reads `"S"`).
    let before: String
    /// Inside `#if DEBUG`, or after a `#Preview`: not in a release build.
    let isDebugOnly: Bool

    var place: String { "\(file):\(line)" }

    /// The text without its interpolations.
    var plain: String {
        var result = ""
        var depth = 0
        var index = text.startIndex
        while index < text.endIndex {
            let character = text[index]
            let next = text.index(after: index)
            if depth == 0, character == "\\", next < text.endIndex, text[next] == "(" {
                depth = 1
                index = text.index(after: next)
                continue
            }
            if depth > 0 {
                if character == "(" { depth += 1 }
                if character == ")" { depth -= 1 }
            } else {
                result.append(character)
            }
            index = next
        }
        return result
    }

    /// The literal as App Intents names it in a catalog: `\(.applicationName)`
    /// is `${applicationName}` and `\(\.$mix)` is `${mix}`.
    var asIntentKey: String {
        text.replacingOccurrences(
            of: #"\\\(\\?\.\$?([A-Za-z]+)\)"#, with: "\\${$1}", options: .regularExpression
        )
    }
}

enum SwiftSources {
    /// Every string literal of the app's sources.
    static func literals() throws -> [SourceLiteral] {
        let base = CatalogSource.root.appendingPathComponent("SleepNoise")
        let files = FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil)
        var found: [SourceLiteral] = []
        while let url = files?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            let name = String(url.path.dropFirst(base.path.count + 1))
            found.append(contentsOf: literals(in: text, file: name))
        }
        return found.sorted { ($0.file, $0.line) < ($1.file, $1.line) }
    }

    private enum Branch { case debug, release, other }

    /// A small reader of Swift: enough to tell code from comments and
    /// strings, and to know which lines only a debug build compiles.
    static func literals(in source: String, file: String) -> [SourceLiteral] {
        let text = Array(source)
        var found: [SourceLiteral] = []
        var index = 0
        var line = 1
        var code = ""
        var branches: [Branch] = []
        var isPreview = false

        func starts(_ word: String, at position: Int) -> Bool {
            let characters = Array(word)
            guard position + characters.count <= text.count else { return false }
            return Array(text[position..<position + characters.count]) == characters
        }

        while index < text.count {
            let character = text[index]
            if character == "\n" {
                line += 1
                code.append(" ")
                index += 1
                continue
            }
            if starts("//", at: index) {
                while index < text.count, text[index] != "\n" { index += 1 }
                continue
            }
            if starts("/*", at: index) {
                while index < text.count, !starts("*/", at: index) {
                    if text[index] == "\n" { line += 1 }
                    index += 1
                }
                index += 2
                continue
            }
            if character == "#" {
                var end = index
                while end < text.count, text[end] != "\n" { end += 1 }
                let directive = String(text[index..<end])
                if directive.hasPrefix("#if ") {
                    let isDebug = directive.contains("DEBUG") && !directive.contains("!DEBUG")
                    branches.append(isDebug ? .debug : .other)
                    index = end
                    continue
                }
                if directive.hasPrefix("#elseif") {
                    if !branches.isEmpty { branches[branches.count - 1] = .other }
                    index = end
                    continue
                }
                if directive.hasPrefix("#else") {
                    if let last = branches.last {
                        branches[branches.count - 1] = last == .debug ? .release : (last == .release ? .debug : .other)
                    }
                    index = end
                    continue
                }
                if directive.hasPrefix("#endif") {
                    if !branches.isEmpty { branches.removeLast() }
                    index = end
                    continue
                }
                if directive.hasPrefix("#Preview") { isPreview = true }
            }
            if character == "\"" {
                let startLine = line
                var end = index + 1
                while end < text.count, text[end] != "\"" {
                    if text[end] == "\\", end + 1 < text.count, text[end + 1] == "(" {
                        var depth = 1
                        end += 2
                        while end < text.count, depth > 0 {
                            if text[end] == "(" { depth += 1 }
                            if text[end] == ")" { depth -= 1 }
                            end += 1
                        }
                        continue
                    }
                    if text[end] == "\\" {
                        end += 2
                        continue
                    }
                    if text[end] == "\n" { line += 1 }
                    end += 1
                }
                let before = String(code.suffix(240))
                    .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
                found.append(SourceLiteral(
                    file: file,
                    line: startLine,
                    text: String(text[min(index + 1, text.count)..<min(end, text.count)]),
                    before: String(before.suffix(80)),
                    isDebugOnly: isPreview || branches.contains(.debug)
                ))
                code.append("\"S\"")
                index = end + 1
                continue
            }
            code.append(character)
            index += 1
        }
        return found
    }
}
