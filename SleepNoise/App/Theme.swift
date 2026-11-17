import SwiftUI

/// Colours of the sheets that are not rebuilt in Grafito yet (timer, tide,
/// mixes and Pro). The page and the Layers sheet use `Ink`.
enum Palette {
    static let background = Color(red: 0.055, green: 0.067, blue: 0.078)
    static let ink = Color(red: 0.09, green: 0.11, blue: 0.13)
    static let card = Color(red: 0.122, green: 0.137, blue: 0.153)
    static let amber = Color(red: 0.922, green: 0.722, blue: 0.451)
    static let mist = Color(red: 0.655, green: 0.745, blue: 0.753)
    static let text = Color(red: 0.933, green: 0.914, blue: 0.863)
    static let muted = Color(red: 0.58, green: 0.60, blue: 0.62)
}
