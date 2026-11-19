// SleepNoise store captures: lays one screen of the app on the canvas of the
// App Store with its headline.
//
// Source of truth for the canvas: docs/design/11-ICONO-Y-APP-STORE.md §2.2.
// Colour tokens and type steps: docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md.
// The headlines are read from docs/store/ficha-<language>.md, where the owner
// edits them: under "### Captura N" the first block of text is the headline
// and the block after "Subtítulo de la captura:" is the second line.
//
// Run through scripts/screenshots.sh. By hand:
//
//   shot-composer --ficha docs/store/ficha-es.md --index 1 \
//                 --screen raw.png --out 01-page-playing.png
//   shot-composer --ficha docs/store/ficha-es.md --list
//   shot-composer --same-top first.png second.png
//
// --same-top compares the top of two takes of the same screen and exits 0
// when they match: a banner of the system passing through (a simulator that
// has just been created has things to say) makes them differ.
//
// --keep-home-indicator leaves the bottom strip of the screen as captured.
//
// No dependencies beyond the macOS SDK that ships with Xcode.

import AppKit
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

// MARK: - Canvas (pt on a 440 × 956 canvas, exported at 3×: the 6.9" class)
//
// The screen may come from any iPhone: it is laid 336 pt wide, whatever its
// own width (402 pt on the default simulator of the script: 0.836).

let scale: CGFloat = 3
let canvasSize = CGSize(width: 440, height: 956)

/// Headline and second line start here; the same margin closes the canvas.
let textX: CGFloat = 32
let textWidth: CGFloat = 376

/// Step 2: SF Pro Display Medium 28/34, first baseline at y 100.
let headlineSize: CGFloat = 28
let headlineLine: CGFloat = 34
let headlineBaseline: CGFloat = 100
let headlineMaxLines = 2

/// Step 6: SF Pro Regular 17/22, always in the box y 152-174, one line
/// (captures 1 and 3).
let secondSize: CGFloat = 17
let secondBox: ClosedRange<CGFloat> = 152...174

/// The screen: 336 pt wide on the 4 pt grid, centred (x 52), from y 196. Its
/// height is its own proportion, rounded to the point. No radius, no outline.
let screenX: CGFloat = 52
let screenY: CGFloat = 196
let screenWidth: CGFloat = 336

// MARK: - Colour tokens (03 §3.1)

func color(_ hex: UInt32) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1
    )
}

enum Token {
    static let negro = color(0x000000)
    static let texto = color(0xE8E4DC)
    static let texto2 = color(0x9C9A96)
}

// MARK: - Headlines

struct Headline {
    var title: String
    var subtitle: String?
}

/// The same reading as `StoreHeadlines` in SleepNoiseTests/CopyLintTests.swift,
/// which lints what this finds.
func readHeadlines(_ markdown: String) -> [Headline] {
    var headlines: [Headline] = []
    var inCapture = false
    var inBlock = false
    var awaitsSubtitle = false
    var block: [String] = []
    var blocksInCapture = 0
    for line in markdown.components(separatedBy: "\n") {
        if line.hasPrefix("### Captura ") {
            inCapture = true
            blocksInCapture = 0
            awaitsSubtitle = false
            continue
        }
        if line.hasPrefix("## ") { inCapture = false }
        guard inCapture else { continue }
        if line.hasPrefix("```") {
            if inBlock {
                let text = block.joined(separator: " ")
                if blocksInCapture == 0 {
                    headlines.append(Headline(title: text, subtitle: nil))
                } else if awaitsSubtitle, !headlines.isEmpty {
                    headlines[headlines.count - 1].subtitle = text
                    awaitsSubtitle = false
                }
                blocksInCapture += 1
                block = []
            }
            inBlock.toggle()
            continue
        }
        if inBlock {
            block.append(line)
        } else if line.hasPrefix("Subtítulo de la captura:") {
            awaitsSubtitle = true
        }
    }
    return headlines
}

// MARK: - Text

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data(("shot-composer: " + message + "\n").utf8))
    exit(1)
}

/// The system face at its size in pt, as the app draws it: SF Pro, Display
/// from 20 pt up, with the optical size and the tracking the system gives
/// that size (tracking 0 in the spec). The canvas is scaled, not the font: a
/// font made at three times the size would be the cut and the tracking of
/// 84 pt and 51 pt, narrower than the 28 and the 17 of the app.
func line(_ text: String, size: CGFloat, weight: NSFont.Weight, ink: CGColor) -> CTLine {
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): ink,
    ]
    return CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
}

func width(_ line: CTLine) -> CGFloat {
    CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
}

/// Breaks a headline into at most two lines no wider than the column. One
/// line when it fits. Otherwise the break goes after a full stop, or after a
/// comma, or where the two lines come out most alike, and never leaves a
/// short word (an article, a preposition) hanging at the end of the first.
func wrap(_ text: String, size: CGFloat, weight: NSFont.Weight) -> [String] {
    func measure(_ candidate: String) -> CGFloat {
        width(line(candidate, size: size, weight: weight, ink: Token.texto))
    }
    if measure(text) <= textWidth { return [text] }
    let words = text.split(separator: " ").map(String.init)
    var best: (lines: [String], cost: CGFloat)?
    for index in words.indices.dropLast() {
        let first = words[...index].joined(separator: " ")
        let rest = words[(index + 1)...].joined(separator: " ")
        let (firstWidth, restWidth) = (measure(first), measure(rest))
        guard firstWidth <= textWidth, restWidth <= textWidth else { continue }
        var cost = abs(firstWidth - restWidth)
        let last = words[index]
        if last.hasSuffix(".") {
            cost -= 2 * textWidth
        } else if last.hasSuffix(",") {
            cost -= textWidth
        } else if last.count <= 3 {
            cost += textWidth
        }
        if best == nil || cost < best!.cost { best = ([first, rest], cost) }
    }
    // Three lines or more: reported by the caller.
    return best?.lines ?? words
}

// MARK: - Arguments

var ficha: String?
var index: Int?
var screenPath: String?
var outPath: String?
var lists = false
var keepsHomeIndicator = false
var takes: [String] = []

var arguments = Array(CommandLine.arguments.dropFirst())
while !arguments.isEmpty {
    let flag = arguments.removeFirst()
    func value() -> String {
        guard !arguments.isEmpty else { fail("\(flag) needs a value") }
        return arguments.removeFirst()
    }
    switch flag {
    case "--ficha": ficha = value()
    case "--index": index = Int(value())
    case "--screen": screenPath = value()
    case "--out": outPath = value()
    case "--list": lists = true
    case "--same-top": takes = [value(), value()]
    case "--keep-home-indicator": keepsHomeIndicator = true
    default: fail("unknown argument \(flag)")
    }
}

// MARK: - Two takes of one screen

/// The top of a take as bytes: where the system lays a banner, from the
/// edge down to a sixth of the height. Nothing of the app moves there in
/// the staged states of the store.
func top(of path: String) -> (bytes: [UInt8], width: Int, height: Int) {
    guard
        let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
        let band = image.cropping(to: CGRect(x: 0, y: 0, width: image.width, height: image.height / 6)),
        let space = CGColorSpace(name: CGColorSpace.sRGB)
    else { fail("cannot read \(path)") }
    var bytes = [UInt8](repeating: 0, count: band.width * band.height * 4)
    let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
        guard let context = CGContext(
            data: buffer.baseAddress, width: band.width, height: band.height, bitsPerComponent: 8,
            bytesPerRow: band.width * 4, space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else { return false }
        context.draw(band, in: CGRect(x: 0, y: 0, width: band.width, height: band.height))
        return true
    }
    guard drawn else { fail("cannot draw \(path)") }
    return (bytes, band.width, band.height)
}

if takes.count == 2 {
    let (first, second) = (top(of: takes[0]), top(of: takes[1]))
    guard first.width == second.width, first.height == second.height else { exit(3) }
    var different = 0
    var index = 0
    while index < first.bytes.count {
        // A pixel counts when a channel moves by more than a tenth.
        if abs(Int(first.bytes[index]) - Int(second.bytes[index])) > 24
            || abs(Int(first.bytes[index + 1]) - Int(second.bytes[index + 1])) > 24
            || abs(Int(first.bytes[index + 2]) - Int(second.bytes[index + 2])) > 24 {
            different += 1
        }
        index += 4
    }
    // A banner covers a third of the band; antialiasing, a handful of pixels.
    let share = Double(different) / Double(first.width * first.height)
    print(String(format: "%.4f", share))
    exit(share < 0.002 ? 0 : 3)
}

guard let ficha else { fail("--ficha is required") }
guard let markdown = try? String(contentsOfFile: ficha, encoding: .utf8) else { fail("cannot read \(ficha)") }
let headlines = readHeadlines(markdown)
guard headlines.count == 7 else { fail("\(ficha): expected seven captures, found \(headlines.count)") }

if lists {
    for (number, headline) in headlines.enumerated() {
        let lines = wrap(headline.title, size: headlineSize, weight: .medium)
        let second = headline.subtitle.map {
            "\($0) (\(Int(width(line($0, size: secondSize, weight: .regular, ink: Token.texto2)).rounded(.up))) pt of \(Int(textWidth)))"
        }
        print("\(number + 1)\t\(lines.joined(separator: " / "))\t\(second ?? "")")
    }
    exit(0)
}

guard let index, headlines.indices.contains(index - 1) else { fail("--index must be 1 to 7") }
guard let screenPath, let outPath else { fail("--screen and --out are required") }
let headline = headlines[index - 1]

guard
    let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: screenPath) as CFURL, nil),
    let screen = CGImageSourceCreateImageAtIndex(source, 0, nil)
else { fail("cannot read \(screenPath)") }

// MARK: - Drawing (y grows downwards, as in the spec)

let pixelWidth = Int(canvasSize.width * scale)
let pixelHeight = Int(canvasSize.height * scale)
guard
    let space = CGColorSpace(name: CGColorSpace.sRGB),
    let context = CGContext(
        data: nil, width: pixelWidth, height: pixelHeight, bitsPerComponent: 8, bytesPerRow: 0,
        space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )
else { fail("cannot create the canvas") }

// Everything below is drawn in pt: the context carries the 3×.
context.scaleBy(x: scale, y: scale)
context.setAllowsFontSubpixelPositioning(true)
context.setShouldSubpixelPositionFonts(true)
context.setAllowsFontSubpixelQuantization(false)
context.setShouldSubpixelQuantizeFonts(false)

context.setFillColor(Token.negro)
context.fill(CGRect(origin: .zero, size: canvasSize))

/// Draws a line of text with its baseline at `baseline` pt from the top.
func draw(_ text: CTLine, x: CGFloat, baseline: CGFloat) {
    context.textPosition = CGPoint(x: x, y: canvasSize.height - baseline)
    CTLineDraw(text, context)
}

let titleLines = wrap(headline.title, size: headlineSize, weight: .medium)
guard titleLines.count <= headlineMaxLines else {
    fail("the headline of capture \(index) needs \(titleLines.count) lines: \(headline.title)")
}
for (row, text) in titleLines.enumerated() {
    draw(
        line(text, size: headlineSize, weight: .medium, ink: Token.texto),
        x: textX, baseline: headlineBaseline + CGFloat(row) * headlineLine
    )
}

if let subtitle = headline.subtitle {
    let text = line(subtitle, size: secondSize, weight: .regular, ink: Token.texto2)
    guard width(text) <= textWidth else {
        fail("the second line of capture \(index) is \(Int(width(text).rounded(.up))) pt wide, over \(Int(textWidth)): \(subtitle)")
    }
    // Centred in its box by the metrics of the face, as a line of 17/22.
    let font = NSFont.systemFont(ofSize: secondSize, weight: .regular)
    let ascent = CTFontGetAscent(font)
    let descent = CTFontGetDescent(font)
    let box = secondBox.upperBound - secondBox.lowerBound
    let baseline = secondBox.lowerBound + (box - (ascent + descent)) / 2 + ascent
    draw(text, x: textX, baseline: baseline.rounded())
}

let screenHeight = (screenWidth * CGFloat(screen.height) / CGFloat(screen.width)).rounded()
guard screenY + screenHeight <= canvasSize.height else { fail("the screen does not fit the canvas") }
context.interpolationQuality = .high
context.draw(screen, in: CGRect(
    x: screenX,
    y: canvasSize.height - (screenY + screenHeight),
    width: screenWidth,
    height: screenHeight
))

// The home indicator. The capture asks the system to hide it (11 §2.2) and
// the simulator leaves it there, dimmed. It is the system's, not the app's,
// and it sits in the strip of the bottom safe area where the app draws only
// its background: the strip is repainted with the column of pixels just to
// the left of the indicator, row by row. The screen alone (raw/) is untouched.
if keepsHomeIndicator == false {
    let sourceWidth = CGFloat(screen.width)
    let sourceHeight = CGFloat(screen.height)
    // Every iPhone this is run on draws at 3×.
    let pixelsPerPoint: CGFloat = 3
    // From 3 pt to 15 pt above the bottom edge, the middle 40 % of the width.
    let band = CGRect(
        x: (sourceWidth * 0.3).rounded(),
        y: sourceHeight - 15 * pixelsPerPoint,
        width: (sourceWidth * 0.4).rounded(),
        height: 12 * pixelsPerPoint
    )
    let sample = CGRect(x: band.minX - 8, y: band.minY, width: 1, height: band.height)
    if let column = screen.cropping(to: sample) {
        // Source pixels to canvas pt.
        let factor = screenWidth / sourceWidth
        let top = screenY + band.minY * factor
        context.interpolationQuality = .none
        context.draw(column, in: CGRect(
            x: screenX + band.minX * factor,
            y: canvasSize.height - top - band.height * factor,
            width: band.width * factor,
            height: band.height * factor
        ))
    }
}

guard
    let image = context.makeImage(),
    let destination = CGImageDestinationCreateWithURL(
        URL(fileURLWithPath: outPath) as CFURL, UTType.png.identifier as CFString, 1, nil
    )
else { fail("cannot write \(outPath)") }
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { fail("cannot write \(outPath)") }
