import Foundation

/// Where a line of words may break: the middle dot travels with what
/// follows it, and a figure never leaves its unit.
///
/// The catalog keeps plain spaces, as the copy guide writes them. What is
/// set on screen ties the words that belong together with no-break spaces,
/// so a wrapped line reads "Paused" / "· earbuds" and never "Paused ·" /
/// "earbuds", and "20 min" is never cut in two.
enum LineTies {
    static let tie = "\u{00A0}"
    static let dot = "·"

    /// Every space of a short phrase becomes a no-break space: "rain 50",
    /// "fan is Pro".
    static func whole(_ phrase: String) -> String {
        phrase.replacingOccurrences(of: " ", with: tie)
    }

    /// Only the last two words stay together: for a phrase that may be
    /// wider than its column, so the last line is never one word.
    static func tail(_ phrase: String) -> String {
        guard let last = phrase.range(of: " ", options: .backwards) else { return phrase }
        return phrase.replacingCharacters(in: last, with: tie)
    }

    /// Joins segments so that each separator opens the segment after it:
    /// a line may begin with the dot and never ends with it.
    static func joined(_ segments: [String], separator: String = dot) -> String {
        segments.joined(separator: " " + separator + tie)
    }

    /// A phrase of the catalog with dots in it, as it is set: "Small hours
    /// · 20 min" keeps its first words free and ties each later part to
    /// its dot.
    static func dotLeads(_ text: String, separator: String = dot) -> String {
        let parts = text.components(separatedBy: separator)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count > 1, let first = parts.first else { return text }
        return joined([first] + parts.dropFirst().map(whole), separator: separator)
    }

    /// A paragraph of the catalog, one sentence per line: the stop keeps
    /// its sentence and the space after it is the break.
    static func sentences(_ text: String) -> [String] {
        var lines: [String] = []
        var rest = Substring(text)
        while let stop = rest.range(of: ". ") {
            lines.append(String(rest[..<stop.lowerBound]) + ".")
            rest = rest[stop.upperBound...]
        }
        if !rest.isEmpty { lines.append(String(rest)) }
        return lines
    }
}
