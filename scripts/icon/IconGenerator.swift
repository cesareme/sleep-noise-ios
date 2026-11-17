// SleepNoise app icon generator: "La regla y la marea" (the rule and the tide).
//
// Source of truth for the drawing: docs/design/11-ICONO-Y-APP-STORE.md §2.1.
// Colour tokens: docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md §3.1.
//
// Run through scripts/icon/generate.sh from anywhere inside the checkout:
//
//   scripts/icon/generate.sh            writes the three 1024 px PNGs and Contents.json
//   scripts/icon/generate.sh --proof    also writes small-size proofs to .build/icon-proof/
//   scripts/icon/generate.sh --layers   also writes transparent layers to .build/icon-layers/
//
// No dependencies beyond the macOS SDK that ships with Xcode.

import CoreGraphics
import Foundation
import ImageIO

// MARK: - Geometry (px on a 1024 canvas, y grows downwards as in the SVG of the spec)

let canvas: CGFloat = 1024
let strokeWidth: CGFloat = 112

/// The rule: the still horizon. Butt caps, so it covers y 552-664.
let ruleStart = CGPoint(x: 192, y: 608)
let ruleEnd = CGPoint(x: 832, y: 608)

/// The tide: rises 192 px, falls 256 px, horizontal tangent at every joint.
/// The crest sits on the 64 px grid (576), the recommendation written in spec §9.1.
/// For the literal 4:6 split use crest x 563 and fall control x 723.
let tideStart = CGPoint(x: 384, y: 608)
let tideCrest = CGPoint(x: 576, y: 352)
let tideEnd = CGPoint(x: 832, y: 608)
let riseControl1 = CGPoint(x: 499, y: 608)
let riseControl2 = CGPoint(x: 461, y: 352)
let fallControl1 = CGPoint(x: 691, y: 352)
let fallControl2 = CGPoint(x: 717, y: 608)

// MARK: - Colour tokens

struct RGB {
    let r: CGFloat, g: CGFloat, b: CGFloat

    init(_ hex: UInt32) {
        r = CGFloat((hex >> 16) & 0xFF) / 255
        g = CGFloat((hex >> 8) & 0xFF) / 255
        b = CGFloat(hex & 0xFF) / 255
    }

    init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.r = r
        self.g = g
        self.b = b
    }

    /// Neutral grey with the same Rec. 709 luma, rounded to 8 bits.
    var grey: RGB {
        let luma = (0.2126 * r + 0.7152 * g + 0.0722 * b) * 255
        let level = luma.rounded() / 255
        return RGB(r: level, g: level, b: level)
    }

    var cgColor: CGColor { CGColor(srgbRed: r, green: g, blue: b, alpha: 1) }
}

enum Token {
    static let negro = RGB(0x000000)
    static let texto = RGB(0xE8E4DC)
    /// The accent. Still an open owner decision: change this hex and nothing else.
    static let indice = RGB(0xF0C020)
    /// Paper tokens, only for the Clear light layers of a future Icon Composer file.
    static let tinta = RGB(0x1E1C19)
    static let ocre = RGB(0x8A6508)
}

struct Palette {
    let background: RGB?
    let tide: RGB?
    let rule: RGB?
}

struct Appearance {
    let name: String
    let filename: String
    /// Value of the "luminosity" appearance in Contents.json; nil is the default image.
    let luminosity: String?
    let palette: Palette
}

// Default equals Dark: the app is dark only in 1.0, the object is black on a light
// home screen too. Tinted is one monochrome shape; the system supplies the hue.
let appearances = [
    Appearance(name: "default", filename: "AppIcon.png", luminosity: nil,
               palette: Palette(background: Token.negro, tide: Token.indice, rule: Token.texto)),
    Appearance(name: "dark", filename: "AppIcon-Dark.png", luminosity: "dark",
               palette: Palette(background: Token.negro, tide: Token.indice, rule: Token.texto)),
    Appearance(name: "tinted", filename: "AppIcon-Tinted.png", luminosity: "tinted",
               palette: Palette(background: Token.negro, tide: Token.texto.grey, rule: Token.texto.grey)),
]

// MARK: - Drawing

let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("icon: \(message)\n".utf8))
    exit(1)
}

/// Bitmap context in sRGB. Opaque contexts carry no alpha channel, so the PNG has none.
func makeContext(width: Int, height: Int, opaque: Bool) -> CGContext {
    let alpha: CGImageAlphaInfo = opaque ? .noneSkipLast : .premultipliedLast
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                  bytesPerRow: width * 4, space: sRGB, bitmapInfo: alpha.rawValue)
    else { fail("could not create a \(width)x\(height) bitmap") }
    return context
}

/// Draws the icon on a square of `side` pixels. Layer order, bottom to top:
/// background, tide, rule. The rule goes on top so the white line stays continuous
/// and the tide only shows above it.
func drawIcon(in context: CGContext, side: CGFloat, palette: Palette) {
    context.saveGState()
    // Flip to the SVG coordinate system (origin top left).
    context.translateBy(x: 0, y: side)
    context.scaleBy(x: side / canvas, y: -side / canvas)
    context.setShouldAntialias(true)

    if let background = palette.background {
        context.setFillColor(background.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: canvas, height: canvas))
    }

    context.setLineWidth(strokeWidth)
    context.setLineCap(.butt)
    context.setLineJoin(.round)

    if let tide = palette.tide {
        context.beginPath()
        context.move(to: tideStart)
        context.addCurve(to: tideCrest, control1: riseControl1, control2: riseControl2)
        context.addCurve(to: tideEnd, control1: fallControl1, control2: fallControl2)
        context.setStrokeColor(tide.cgColor)
        context.strokePath()
    }

    if let rule = palette.rule {
        context.beginPath()
        context.move(to: ruleStart)
        context.addLine(to: ruleEnd)
        context.setStrokeColor(rule.cgColor)
        context.strokePath()
    }
    context.restoreGState()
}

func renderMaster(_ palette: Palette, opaque: Bool = true) -> CGImage {
    let context = makeContext(width: Int(canvas), height: Int(canvas), opaque: opaque)
    drawIcon(in: context, side: canvas, palette: palette)
    return context.makeImage()!
}

func writePNG(_ image: CGImage, to url: URL) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                             withIntermediateDirectories: true)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)
    else { fail("could not open \(url.path) for writing") }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fail("could not write \(url.path)") }
}

// MARK: - Asset catalog

/// Single-size iOS icon. iOS 17 reads the image without appearances; iOS 18 and
/// later also read the dark and tinted ones.
func contentsJSON() -> String {
    var entries: [String] = []
    for appearance in appearances {
        var lines: [String] = []
        if let luminosity = appearance.luminosity {
            lines.append("""
                  "appearances" : [
                    {
                      "appearance" : "luminosity",
                      "value" : "\(luminosity)"
                    }
                  ],
            """)
        }
        lines.append("""
              "filename" : "\(appearance.filename)",
              "idiom" : "universal",
              "platform" : "ios",
              "size" : "1024x1024"
        """)
        entries.append("    {\n" + lines.joined(separator: "\n") + "\n    }")
    }
    return """
    {
      "images" : [
    \(entries.joined(separator: ",\n"))
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }

    """
}

// MARK: - Measurements

/// Share of the canvas that each ink covers in the exported default image.
func reportCoverage(of image: CGImage) {
    let side = Int(canvas)
    let context = makeContext(width: side, height: side, opaque: true)
    context.draw(image, in: CGRect(x: 0, y: 0, width: side, height: side))
    guard let data = context.data else { return }
    let pixels = data.bindMemory(to: UInt8.self, capacity: side * side * 4)
    var tide = 0.0
    var rule = 0.0
    for index in 0..<(side * side) {
        let r = Double(pixels[index * 4]), b = Double(pixels[index * 4 + 2])
        // Background is black, so the red channel is the coverage of either ink and
        // the blue channel tells the warm grey rule from the yellow tide.
        let ink = r / 232
        if ink <= 0 { continue }
        let ruleShare = min(1, max(0, (b / max(r, 1) - 32.0 / 240.0) / (220.0 / 232.0 - 32.0 / 240.0)))
        rule += min(1, ink) * ruleShare
        tide += min(1, ink) * (1 - ruleShare)
    }
    let total = Double(side * side)
    print(String(format: "coverage · tide %.2f %% · rule %.2f %% of the canvas", tide / total * 100, rule / total * 100))
}

// MARK: - Proofs

/// Home screen stand-ins: the light system background and black.
let proofBackgrounds: [(name: String, colour: RGB)] = [("light", RGB(0xF2F2F7)), ("dark", Token.negro)]
let proofPoints = [29, 40, 60, 120]
let proofScale = 3

/// Scales the master down the way the system does and applies an icon mask.
/// The mask is a plain rounded rectangle, close enough to judge legibility.
func drawMasked(_ image: CGImage, in context: CGContext, rect: CGRect) {
    context.saveGState()
    let radius = rect.width * 0.2237
    context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    context.clip()
    context.interpolationQuality = .high
    context.draw(image, in: rect)
    context.restoreGState()
}

/// What a tinted home screen roughly does: the grey level scales a tint colour.
func tintedPreview(_ grey: CGImage, tint: RGB) -> CGImage {
    let side = Int(canvas)
    let rect = CGRect(x: 0, y: 0, width: side, height: side)
    let context = makeContext(width: side, height: side, opaque: true)
    context.draw(grey, in: rect)
    context.setBlendMode(.multiply)
    context.setFillColor(tint.cgColor)
    context.fill(rect)
    return context.makeImage()!
}

/// The default icon under the accessibility greyscale colour filter.
func greyscalePreview(_ image: CGImage) -> CGImage {
    let side = Int(canvas)
    let grey = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)!
    guard let context = CGContext(data: nil, width: side, height: side, bitsPerComponent: 8,
                                  bytesPerRow: side, space: grey, bitmapInfo: CGImageAlphaInfo.none.rawValue)
    else { fail("could not create the greyscale bitmap") }
    context.draw(image, in: CGRect(x: 0, y: 0, width: side, height: side))
    return context.makeImage()!
}

func writeProofs(masters: [(name: String, image: CGImage)], to directory: URL) {
    let margin = 24 * proofScale
    for background in proofBackgrounds {
        // One file per icon and size.
        for master in masters {
            for points in proofPoints {
                let side = points * proofScale
                let context = makeContext(width: side + margin * 2, height: side + margin * 2, opaque: true)
                context.setFillColor(background.colour.cgColor)
                context.fill(CGRect(x: 0, y: 0, width: context.width, height: context.height))
                drawMasked(master.image, in: context, rect: CGRect(x: margin, y: margin, width: side, height: side))
                writePNG(context.makeImage()!,
                         to: directory.appendingPathComponent("icon-\(master.name)-\(points)pt-\(background.name).png"))
            }
        }

        // One sheet per background: a row per icon, a column per size.
        let cell = proofPoints.max()! * proofScale + margin
        let width = proofPoints.reduce(margin) { $0 + $1 * proofScale + margin }
        let height = masters.count * cell + margin
        let sheet = makeContext(width: width, height: height, opaque: true)
        sheet.setFillColor(background.colour.cgColor)
        sheet.fill(CGRect(x: 0, y: 0, width: width, height: height))
        for (row, master) in masters.enumerated() {
            var x = margin
            for points in proofPoints {
                let side = points * proofScale
                // Rows run top to bottom; icons sit on the bottom edge of their row.
                let y = height - (row + 1) * cell
                drawMasked(master.image, in: sheet, rect: CGRect(x: x, y: y, width: side, height: side))
                x += side + margin
            }
        }
        writePNG(sheet.makeImage()!, to: directory.appendingPathComponent("sheet-\(background.name).png"))
    }

    // The smallest size at 2x and 3x, magnified without smoothing to inspect pixels.
    let magnification = 8
    for master in masters {
        let sides = [29 * 2, 29 * 3]
        let gap = 16
        let width = sides.reduce(gap) { $0 + $1 * magnification + gap }
        let height = sides.max()! * magnification + gap * 2
        let zoom = makeContext(width: width, height: height, opaque: true)
        zoom.setFillColor(RGB(0x808080).cgColor)
        zoom.fill(CGRect(x: 0, y: 0, width: width, height: height))
        var x = gap
        for side in sides {
            let small = makeContext(width: side, height: side, opaque: true)
            small.interpolationQuality = .high
            small.draw(master.image, in: CGRect(x: 0, y: 0, width: side, height: side))
            zoom.interpolationQuality = .none
            zoom.draw(small.makeImage()!, in: CGRect(x: x, y: gap, width: side * magnification, height: side * magnification))
            x += side * magnification + gap
        }
        writePNG(zoom.makeImage()!, to: directory.appendingPathComponent("zoom-29pt-\(master.name).png"))
    }
}

// MARK: - Main

let arguments = Set(CommandLine.arguments.dropFirst())
let known: Set<String> = ["--proof", "--layers"]
if let unknown = arguments.subtracting(known).first {
    fail("unknown argument \(unknown). Usage: generate.sh [--proof] [--layers]")
}

// generate.sh changes to the checkout root before running this.
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconSet = root.appendingPathComponent("SleepNoise/Resources/Assets.xcassets/AppIcon.appiconset")
guard FileManager.default.fileExists(atPath: iconSet.path) else {
    fail("AppIcon.appiconset not found; run scripts/icon/generate.sh")
}

var rendered: [String: CGImage] = [:]
for appearance in appearances {
    let image = renderMaster(appearance.palette)
    rendered[appearance.name] = image
    writePNG(image, to: iconSet.appendingPathComponent(appearance.filename))
    print("wrote \(appearance.filename)")
}
do {
    try contentsJSON().write(to: iconSet.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    print("wrote Contents.json")
} catch {
    fail("could not write Contents.json")
}
reportCoverage(of: rendered["default"]!)

if arguments.contains("--proof") {
    let directory = root.appendingPathComponent(".build/icon-proof")
    let masters: [(name: String, image: CGImage)] = [
        ("default", rendered["default"]!),
        ("tinted", rendered["tinted"]!),
        ("tinted-preview", tintedPreview(rendered["tinted"]!, tint: RGB(0x4DA3FF))),
        ("greyscale", greyscalePreview(rendered["default"]!)),
    ]
    writeProofs(masters: masters, to: directory)
    print("wrote proofs to .build/icon-proof/")
}

if arguments.contains("--layers") {
    // Transparent layers for a future Icon Composer file (Clear and layered Tinted).
    let directory = root.appendingPathComponent(".build/icon-layers")
    let layers: [(name: String, palette: Palette)] = [
        ("marea", Palette(background: nil, tide: Token.indice, rule: nil)),
        ("regla", Palette(background: nil, tide: nil, rule: Token.texto)),
        ("marea-clear-light", Palette(background: nil, tide: Token.ocre, rule: nil)),
        ("regla-clear-light", Palette(background: nil, tide: nil, rule: Token.tinta)),
    ]
    for layer in layers {
        writePNG(renderMaster(layer.palette, opaque: false), to: directory.appendingPathComponent("\(layer.name).png"))
    }
    print("wrote layers to .build/icon-layers/")
}
