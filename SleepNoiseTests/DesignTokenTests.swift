import SwiftUI
import UIKit
import XCTest
@testable import SleepNoise

/// The Grafito tokens: colours with their "Increase Contrast" variants, the
/// nine-step type scale, the 4 pt grid and the motion durations.
final class DesignTokenTests: XCTestCase {
    // MARK: Tokens

    private func hex(_ color: UIColor, contrast: UIAccessibilityContrast) -> UInt32 {
        let traits = UITraitCollection { mutable in
            mutable.userInterfaceStyle = .dark
            mutable.accessibilityContrast = contrast
        }
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.resolvedColor(with: traits).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        XCTAssertEqual(alpha, 1)
        return UInt32((red * 255).rounded()) << 16 | UInt32((green * 255).rounded()) << 8 | UInt32((blue * 255).rounded())
    }

    func testTokensCarryTheGrafitoValues() {
        let expected: [(InkToken, UInt32, UInt32)] = [
            (InkTokens.background, 0x000000, 0x000000),
            (InkTokens.sheet, 0x1C1C1E, 0x1C1C1E),
            (InkTokens.relief, 0x1E1D1B, 0x1E1D1B),
            (InkTokens.rule, 0x2A2A2E, 0x3A3836),
            (InkTokens.ruleSheet, 0x38383B, 0x3A3836),
            (InkTokens.text, 0xE8E4DC, 0xE8E4DC),
            (InkTokens.text2, 0x9C9A96, 0xB4B2AE),
            (InkTokens.text3, 0x6E6C68, 0x7A7672),
            (InkTokens.textNight, 0xA2A09A, 0xB4B2AE),
            (InkTokens.index, 0xF0C020, 0xFFD23C),
            (InkTokens.indexNight, 0xBA941C, 0xFFD23C),
        ]
        XCTAssertEqual(InkTokens.all.count, expected.count)
        for (token, regular, contrast) in expected {
            XCTAssertEqual(token.hex, regular)
            XCTAssertEqual(token.highContrastHex, contrast)
            // The colour views get resolves by the system contrast setting.
            XCTAssertEqual(hex(token.uiColor, contrast: .normal), regular)
            XCTAssertEqual(hex(token.uiColor, contrast: .high), contrast)
        }
    }

    func testTheAccentIsOneToken() {
        // Changing the accent means changing AccentToken and nothing else.
        XCTAssertEqual(InkTokens.index.hex, AccentToken.hex)
        XCTAssertEqual(InkTokens.indexNight.hex, AccentToken.nightHex)
        XCTAssertEqual(InkTokens.index.highContrastHex, AccentToken.highContrastHex)
        XCTAssertEqual(InkTokens.indexNight.highContrastHex, AccentToken.highContrastHex)
        let accents = InkTokens.all.filter { $0.name.hasPrefix("índice") }
        XCTAssertEqual(accents.count, 2)
    }

    func testAtNightThereIsOneInk() {
        for phase in [NightPhase.nightPage, .night, .smallHours] {
            XCTAssertTrue(phase.isNight)
            XCTAssertEqual(Ink.primary(phase), Ink.textNight)
            XCTAssertEqual(Ink.secondary(phase), Ink.textNight)
            XCTAssertEqual(Ink.accent(phase), Ink.indexNight)
            XCTAssertFalse(MotionGate.allows(phase))
        }
        XCTAssertFalse(NightPhase.day.isNight)
        XCTAssertEqual(Ink.primary(.day), Ink.text)
        XCTAssertEqual(Ink.secondary(.day), Ink.text2)
        XCTAssertEqual(Ink.accent(.day), Ink.index)
        XCTAssertTrue(MotionGate.allows(.day))
        XCTAssertTrue(NightPhase.night.isNightScreen)
        XCTAssertFalse(NightPhase.nightPage.isNightScreen)
        XCTAssertEqual(Ink.rule(on: .sheet), Ink.ruleSheet)
        XCTAssertEqual(Ink.rule(on: .black), Ink.rule)
    }

    // MARK: Type

    func testTypeScaleHasNineStepsWithTheirSizes() {
        XCTAssertEqual(Set(TypeStep.allCases.map(\.scaleStep)), Set(1...9))
        let large: [TypeStep: (CGFloat, CGFloat)] = [
            .figure: (72, 80), .figureSmall: (56, 64), .name: (28, 34), .header: (22, 28),
            .nightState: (22, 28), .nightAction: (20, 25), .row: (17, 22), .value: (17, 22),
            .body: (17, 22), .reading: (17, 26), .bar: (17, 22), .secondary: (15, 20),
            .note: (13, 18), .data: (13, 18), .stateWord: (13, 18),
        ]
        XCTAssertEqual(large.count, TypeStep.allCases.count)
        for step in TypeStep.allCases {
            let (size, line) = large[step] ?? (0, 0)
            XCTAssertEqual(step.size, size, "\(step)")
            XCTAssertEqual(step.lineHeight, line, "\(step)")
            // At Large a step is exactly its nominal size; nothing is under 13.
            XCTAssertEqual(step.scaledSize(for: .large), size, accuracy: 0.01, "\(step)")
            XCTAssertGreaterThanOrEqual(step.size, 13, "\(step)")
        }
    }

    func testTypeFollowsDynamicTypeAndTheFigureStopsEarly() {
        for step in TypeStep.allCases {
            XCTAssertLessThan(step.scaledSize(for: .xSmall), step.scaledSize(for: .xxxLarge), "\(step)")
            XCTAssertLessThanOrEqual(step.scaledSize(for: .xxxLarge), step.scaledSize(for: .accessibility3), "\(step)")
        }
        XCTAssertGreaterThan(TypeStep.row.scaledSize(for: .accessibility5), TypeStep.row.scaledSize(for: .accessibility2))
        // The figure stops growing at Accessibility 2.
        XCTAssertEqual(
            TypeStep.figure.scaledSize(for: .accessibility5),
            TypeStep.figure.scaledSize(for: .accessibility2),
            accuracy: 0.01
        )
        // The line height keeps its proportion.
        let size = TypeStep.body.scaledSize(for: .accessibility1)
        XCTAssertEqual(TypeStep.body.scaledLineHeight(for: .accessibility1), size * 22 / 17, accuracy: 0.01)
    }

    func testWeightsNeverGoUnderMediumAtNight() {
        let allowed: Set<Font.Weight> = [.regular, .medium, .semibold]
        for step in TypeStep.allCases {
            XCTAssertTrue(allowed.contains(step.weight(.day)), "\(step)")
            let night = step.weight(.nightPage)
            // Only the figure, 20 pt and more, stays Regular at night.
            if step.scaleStep == 1 {
                XCTAssertEqual(night, .regular)
            } else {
                XCTAssertTrue(night == .medium || night == .semibold, "\(step)")
            }
        }
        XCTAssertEqual(TypeStep.row.weight(.day), .semibold)
        XCTAssertEqual(TypeStep.body.weight(.day), .regular)
        XCTAssertTrue(TypeStep.data.isTabular)
        XCTAssertTrue(TypeStep.value.isTabular)
        XCTAssertTrue(TypeStep.stateWord.isSmallCaps)
        XCTAssertEqual(TypeStep.stateWord.trackingFraction, 0.02)
        XCTAssertEqual(TypeStep.figure.trackingFraction, -0.01)
    }

    // MARK: Grid and motion

    func testGridIsBuiltOnFourPoints() {
        let values = [
            Grid.margin, Grid.inner, Grid.group, Grid.row, Grid.rowSubtitle, Grid.layerTouch,
            Grid.layerChannel, Grid.layerRow, Grid.horizonBand, Grid.target, Grid.largeTarget, Grid.disc,
        ]
        for value in values + Grid.steps {
            XCTAssertEqual(value.truncatingRemainder(dividingBy: Grid.unit), 0, "\(value)")
        }
        XCTAssertEqual(Grid.margin, 20)
        XCTAssertEqual(Grid.radius, 0)
        XCTAssertEqual(Grid.layerRow, Grid.layerTouch + Grid.layerChannel)
        XCTAssertEqual(Grid.largeTarget, 64)
        XCTAssertEqual(Grid.hairline(displayScale: 2), 0.5)
        XCTAssertEqual(Grid.hairline(displayScale: 3), 1.0 / 3, accuracy: 0.0001)
        XCTAssertEqual(Grid.hairline(displayScale: 0), 1)
    }

    func testAccentLinesAreNeverThinnerThanAPointAndAHalf() {
        // 1.5 pt is four and a half pixels at 3x: rounded up, never down.
        XCTAssertEqual(Grid.pixelCeil(Grid.accentLine, displayScale: 3), 5.0 / 3, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelCeil(Grid.accentLine, displayScale: 2), 1.5, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelCeil(Grid.accentLine, displayScale: 1), 2, accuracy: 0.0001)
        // Whole pixels stay as they are.
        XCTAssertEqual(Grid.pixelCeil(3, displayScale: 3), 3, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelCeil(2, displayScale: 2), 2, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelCeil(1.0 / 3, displayScale: 3), 1.0 / 3, accuracy: 0.0001)
        for scale in [CGFloat(1), 2, 3] {
            for step in 0...20 {
                let thickness = SoundLevelScale.thickness(level: Float(step) / 20)
                let snapped = Grid.pixelCeil(thickness, displayScale: scale)
                XCTAssertGreaterThanOrEqual(snapped, Grid.accentLine)
                XCTAssertGreaterThanOrEqual(snapped, thickness - 0.001)
                XCTAssertLessThan(snapped, thickness + 1 / scale)
                XCTAssertEqual((snapped * scale).rounded(), snapped * scale, accuracy: 0.0001)
            }
        }
    }

    func testRowsGrowWithTheTextSize() {
        // 04 §5d, band by band.
        let regular: [DynamicTypeSize] = [.xSmall, .medium, .large]
        let larger: [DynamicTypeSize] = [.xLarge, .xxLarge, .xxxLarge]
        let accessible: [DynamicTypeSize] = [.accessibility1, .accessibility2]
        let largest: [DynamicTypeSize] = [.accessibility3, .accessibility4, .accessibility5]
        for size in regular {
            XCTAssertEqual(Grid.row(subtitle: false, dynamicType: size), 56)
            XCTAssertEqual(Grid.row(subtitle: true, dynamicType: size), 72)
            XCTAssertEqual(Grid.primaryAction(dynamicType: size), 64)
            XCTAssertEqual(Grid.textAction(dynamicType: size, night: false), 44)
        }
        for size in larger {
            XCTAssertEqual(Grid.row(subtitle: false, dynamicType: size), 64)
            XCTAssertEqual(Grid.row(subtitle: true, dynamicType: size), 80)
            XCTAssertEqual(Grid.primaryAction(dynamicType: size), 64)
            XCTAssertEqual(Grid.textAction(dynamicType: size, night: false), 56)
        }
        for size in accessible + largest {
            XCTAssertEqual(Grid.row(subtitle: false, dynamicType: size), 88)
            XCTAssertEqual(Grid.row(subtitle: true, dynamicType: size), 104)
            XCTAssertEqual(Grid.primaryAction(dynamicType: size), 80)
        }
        for size in accessible {
            XCTAssertEqual(Grid.textAction(dynamicType: size, night: false), 56)
        }
        for size in largest {
            XCTAssertEqual(Grid.textAction(dynamicType: size, night: false), 64)
        }
        // The night page never goes under 64.
        for size in regular + larger + accessible + largest {
            XCTAssertEqual(Grid.textAction(dynamicType: size, night: true), 64)
        }
    }

    func testHorizonSitsAtAThirdOfTheScreen() {
        XCTAssertEqual(Grid.horizonY(fullHeight: 852), 284)
        XCTAssertEqual(Grid.horizonY(fullHeight: 844), 280)
        XCTAssertEqual(Grid.horizonY(fullHeight: 667), 224)
    }

    func testNoFiniteMotionIsLongerThanTwoSeconds() {
        let durations = [
            Motion.control, Motion.content, Motion.fingerIn, Motion.fingerOut,
            Motion.start, Motion.stop, Motion.phase, Motion.phaseReduced,
        ]
        for duration in durations {
            XCTAssertGreaterThan(duration, 0)
            XCTAssertLessThanOrEqual(duration, Motion.longest)
        }
        XCTAssertEqual(Motion.stop, 1.5)
        XCTAssertEqual(Motion.horizonInterval(reduceMotion: false), 0.05)
        XCTAssertEqual(Motion.horizonTau(reduceMotion: false), 0.5)
        XCTAssertEqual(Motion.horizonInterval(reduceMotion: true), 0.25)
        XCTAssertEqual(Motion.horizonTau(reduceMotion: true), 1.5)
        XCTAssertEqual(Motion.phase(reduceMotion: true), 0.25)
    }
}
