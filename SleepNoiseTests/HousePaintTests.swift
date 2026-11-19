import UIKit
import XCTest
@testable import SleepNoise

/// The painted bands of the four house mixes: in the bundle, at the size the
/// Mixes row shows, at 2x and 3x, and light enough to ship.
final class HousePaintTests: XCTestCase {
    private static let catalog = "SleepNoise/Resources/Assets.xcassets/Paint"

    func testEveryHouseMixHasItsBandInTheBundle() {
        let bundle = Bundle(for: MixStore.self)
        for mix in HouseMix.allCases {
            let image = UIImage(named: HousePaint.bandName(mix), in: bundle, compatibleWith: nil)
            XCTAssertNotNil(image, mix.rawValue)
            XCTAssertEqual(image?.size, HousePaint.bandSize, mix.rawValue)
            XCTAssertTrue([2, 3].contains(image?.scale ?? 0), "\(mix.rawValue): scale \(image?.scale ?? 0)")
        }
    }

    /// The catalog on disk: one imageset per mix with a 2x and a 3x PNG of
    /// the expected pixel size, no 1x (the app is iPhone only), under 2 MB
    /// in all.
    func testTheCatalogCarriesBothScalesUnderTwoMegabytes() throws {
        let folder = CatalogSource.root.appendingPathComponent(Self.catalog)
        let namespace = try JSONSerialization.jsonObject(
            with: Data(contentsOf: folder.appendingPathComponent("Contents.json"))
        ) as? [String: Any]
        let properties = namespace?["properties"] as? [String: Any]
        XCTAssertEqual(properties?["provides-namespace"] as? Bool, true)

        var total = 0
        for mix in HouseMix.allCases {
            let set = folder.appendingPathComponent("HouseMix-\(mix.rawValue).imageset")
            let contents = try JSONSerialization.jsonObject(
                with: Data(contentsOf: set.appendingPathComponent("Contents.json"))
            ) as? [String: Any]
            let images = try XCTUnwrap(contents?["images"] as? [[String: Any]], mix.rawValue)
            XCTAssertEqual(images.compactMap { $0["scale"] as? String }.sorted(), ["2x", "3x"], mix.rawValue)
            for entry in images {
                let scale = try XCTUnwrap((entry["scale"] as? String)?.first?.wholeNumberValue, mix.rawValue)
                let filename = try XCTUnwrap(entry["filename"] as? String, mix.rawValue)
                XCTAssertEqual(filename, "HouseMix-\(mix.rawValue)@\(scale)x.png")
                let data = try Data(contentsOf: set.appendingPathComponent(filename))
                total += data.count
                let image = try XCTUnwrap(UIImage(data: data, scale: CGFloat(scale)), filename)
                XCTAssertEqual(image.size, HousePaint.bandSize, filename)
            }
        }
        XCTAssertGreaterThan(total, 0)
        XCTAssertLessThan(total, 2_000_000, "the paint adds \(total) bytes to the bundle")
    }

    /// The generator and the app agree on the size of the band.
    func testTheGeneratorPaintsTheSizeTheSheetShows() throws {
        let url = CatalogSource.root.appendingPathComponent("scripts/paint/PaintGenerator.swift")
        let source = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(source.contains("let bandWidth = \(Int(HousePaint.bandSize.width)).0"))
        XCTAssertTrue(source.contains("let bandHeight = \(Int(HousePaint.bandSize.height)).0"))
        XCTAssertTrue(source.contains("let assetFolder = \"\(Self.catalog)\""))
    }
}
