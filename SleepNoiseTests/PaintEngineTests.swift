import UIKit
import XCTest
@testable import SleepNoise

/// The paint engine of the app (exploration 12 §7 fase 2, task 1): the
/// brush shared with the build-time generator, the scene of a mix, the
/// rasterizer off the main thread and its cancellation, the store, the
/// breath of the live layer, the phase rule and the setting.
final class PaintEngineTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Madrid")!
        return calendar
    }()

    private func day(_ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }

    private let geometry = PaintWindowGeometry(width: 402)

    private func scene(_ mix: HouseMix, hasFullAccess: Bool = true) -> PaintScene {
        PaintScene(mix: mix, hasFullAccess: hasFullAccess, on: day(11, 19), calendar: calendar, geometry: geometry)!
    }

    // MARK: The shared brush

    /// The generator of the mock-ups, draw for draw: a seed gives the same
    /// numbers in JavaScript, in the script and in the app.
    func testTheGeneratorIsTheOneOfTheMockUps() {
        var R = Pigment.LCG(seed: 2101)
        XCTAssertEqual(R.next(), 0.0503156222, accuracy: 1e-9)
        XCTAssertEqual(R.next(), 0.8471775164, accuracy: 1e-9)
        XCTAssertEqual(R.next(), 0.3916139458, accuracy: 1e-9)
        XCTAssertEqual(Pigment.fnv1a("Rosa y lluvia"), 983_396_062)
        XCTAssertEqual(Pigment.fnv1a("pinkAndRain"), 517_360_532)
        XCTAssertEqual(Pigment.fnv1a(""), 2_166_136_261)
    }

    /// The script compiles the app's own brush: there is one generator, one
    /// palette and one ribbon, so the catalog and the page cannot drift
    /// apart.
    func testTheBuildTimeGeneratorCompilesTheSameBrush() throws {
        let root = CatalogSource.root
        let script = try String(contentsOf: root.appendingPathComponent("scripts/paint/generate.sh"), encoding: .utf8)
        XCTAssertTrue(script.contains("SleepNoise/Design/Paint/Pigment.swift"))
        let generator = try String(
            contentsOf: root.appendingPathComponent("scripts/paint/PaintGenerator.swift"), encoding: .utf8
        )
        for own in ["struct LCG", "struct Tint", "enum Palette", "func ribbon(_ ctx", "struct ValueNoise"] {
            XCTAssertFalse(generator.contains(own), "the script defines its own \(own)")
        }
        XCTAssertTrue(generator.contains("typealias LCG = Pigment.LCG"))
    }

    /// The same seed paints the same bytes twice; another seed paints
    /// something else.
    func testASeedPaintsTheSameBytesTwice() throws {
        let first = try offMain { try PaintRasterizer.draw(self.scene(.pinkAndRain), scale: 1) }
        let second = try offMain { try PaintRasterizer.draw(self.scene(.pinkAndRain), scale: 1) }
        XCTAssertEqual(bytes(first.dry), bytes(second.dry))
        XCTAssertEqual(bytes(first.live), bytes(second.live))
        var other = scene(.pinkAndRain)
        other.seed ^= 1
        let third = try offMain { try PaintRasterizer.draw(other, scale: 1) }
        XCTAssertNotEqual(bytes(first.dry), bytes(third.dry))
    }

    /// The band of "Pared" in the catalog, painted by the script on macOS,
    /// against the same strokes painted here with the shared brush: the
    /// same composition, pixel for pixel but for the rounding of two
    /// CoreGraphics builds.
    func testTheBandInTheCatalogIsWhatTheSharedBrushPaints() throws {
        let bundle = Bundle(for: MixStore.self)
        let asset = try XCTUnwrap(UIImage(named: HousePaint.bandName(.wall), in: bundle, compatibleWith: nil))
        let shipped = try XCTUnwrap(asset.cgImage)
        let scale = Double(asset.scale)
        let width = Double(HousePaint.bandSize.width), height = Double(HousePaint.bandSize.height)
        let cv = try XCTUnwrap(Pigment.Canvas(width: width, height: height, scale: scale, focus: 92))
        // `HousePiece` "wall" of the script: the brown field alone, seed 2104.
        var R = Pigment.LCG(seed: 2104)
        let c = Pigment.Palette.brown
        cv.fill(c[c.count - 1].towardsBlack(0.45))
        Pigment.grain(cv.context, width: width, height: height, &R, 0.06)
        Pigment.times(width * height / 160) {
            let x = R.next() * width - 10, y = R.next() * height, ang = (R.next() - 0.5) * 0.5, len = 22 + R.next() * 18
            let p = Pigment.strokeNoise(x, y, ang, len, 6, &R, 0.3)
            let k = Pigment.pick(&R, [1, 3, 5, 4])
            Pigment.ribbon(cv.context, p, 7 + R.next() * 3, c[max(0, k - 1)], c[k], 0.9)
        }
        let painted = try XCTUnwrap(cv.image())
        XCTAssertEqual(painted.width, shipped.width)
        XCTAssertEqual(painted.height, shipped.height)
        let a = rgb(painted), b = rgb(shipped)
        XCTAssertEqual(a.count, b.count)
        var total = 0, exact = 0
        for i in 0..<a.count {
            let d = abs(Int(a[i]) - Int(b[i]))
            total += d
            if d == 0 { exact += 1 }
        }
        let mean = Double(total) / Double(a.count)
        let same = Double(exact) / Double(a.count)
        print("paint: catalog band vs shared brush · mean channel difference \(mean) · \(same * 100) % equal")
        // Two CoreGraphics builds (macOS for the script, iOS for the app)
        // round the edges of the ribbons apart by a unit here and there; a
        // different composition would differ by tens per channel.
        XCTAssertLessThan(mean, 1, "the shipped band is not the painting of the shared brush")
        XCTAssertGreaterThan(same, 0.6)
    }

    // MARK: The scene of a mix

    func testEveryHouseMixHasAScene() {
        for mix in HouseMix.allCases {
            let scene = scene(mix)
            XCTAssertEqual(scene.layers.count, mix.recipe.count, mix.rawValue)
            XCTAssertEqual(scene.dominant.sound, mix.recipe[0].sound, mix.rawValue)
            XCTAssertEqual(scene.layers.map(\.sound), mix.recipe.map(\.sound), "loudest first: \(mix.rawValue)")
            XCTAssertEqual(scene.geometry, geometry)
            XCTAssertEqual(scene.seed, PaintScene.seed(identity: mix.rawValue, day: day(11, 19), calendar: calendar))
        }
        XCTAssertEqual(scene(.pinkAndRain).direction, 72 * Double.pi / 180, accuracy: 1e-9, "rain falls to the right")
        XCTAssertEqual(scene(.wall).direction, 0, "the brown field runs horizontal")
    }

    /// Without full access the house mix loads trimmed, and so does its
    /// paint: the ocean is not there, the wind grounds the band.
    func testATrimmedHouseMixPaintsWhatSounds() {
        let trimmed = scene(.seaAndWind, hasFullAccess: false)
        XCTAssertEqual(trimmed.layers.map(\.sound), [.wind])
        XCTAssertEqual(trimmed.dominant.motif, .wind)
        XCTAssertEqual(scene(.seaAndWind).dominant.motif, .ocean)
    }

    func testASavedMixHasASceneSeededByItsId() {
        let id = UUID()
        let saved = SavedMix(
            id: id, name: "x",
            levels: [MixLevel(sound: .thunder, value: 0.3), MixLevel(sound: .cabin, value: 0.6), MixLevel(sound: .white, value: 0)],
            createdAt: day(11, 1)
        )
        let scene = PaintScene(mix: saved, on: day(11, 19), calendar: calendar, geometry: geometry)
        XCTAssertEqual(scene?.layers.map(\.sound), [.cabin, .thunder], "zero levels are not layers")
        XCTAssertEqual(scene?.seed, PaintScene.seed(identity: id.uuidString, day: day(11, 19), calendar: calendar))
        let composition = PaintComposition(scene!)
        XCTAssertEqual(composition.strokes.filter(\.isCrack).count, 1, "the thunder puts one crack in the band")
        XCTAssertFalse(composition.strokes.first(where: \.isCrack)!.isLive, "the crack never flashes")
    }

    func testNothingSoundingIsNoScene() {
        XCTAssertNil(PaintScene(levels: [:], seed: 1, geometry: geometry))
        XCTAssertNil(PaintScene(levels: [.rain: 0], seed: 1, geometry: geometry))
    }

    /// Today's paint is not yesterday's, and the same mix on the same day
    /// is the same; the house mixes do not share a seed.
    func testTheSeedIsPerMixAndDay() {
        let today = PaintScene.seed(identity: "pinkAndRain", day: day(11, 19), calendar: calendar)
        XCTAssertEqual(today, PaintScene.seed(identity: "pinkAndRain", day: day(11, 19, hour: 23), calendar: calendar))
        XCTAssertNotEqual(today, PaintScene.seed(identity: "pinkAndRain", day: day(11, 20), calendar: calendar))
        XCTAssertEqual(today, Pigment.fnv1a("pinkAndRain") ^ UInt32(2026 * 1000 + 323))
        let seeds = Set(HouseMix.allCases.map { PaintScene.seed(identity: $0.rawValue, day: day(11, 19), calendar: calendar) })
        XCTAssertEqual(seeds.count, HouseMix.allCases.count)
        XCTAssertEqual(PaintScene.identity(ofSounds: [.rain: 0.5, .pink: 0.2, .wind: 0]), "pink+rain")
    }

    /// The composition keeps the language: fields before beds, about a
    /// fifth of the ribbons live, black tongues never live, every stroke
    /// born inside the window and its margin.
    func testTheCompositionKeepsTheLanguage() {
        for mix in HouseMix.allCases {
            let composition = PaintComposition(scene(mix))
            let strokes = composition.strokes
            XCTAssertGreaterThan(strokes.count, 200, mix.rawValue)
            let live = Double(composition.liveStrokes.count) / Double(strokes.count)
            XCTAssertEqual(live, PaintComposition.liveShare, accuracy: 0.06, mix.rawValue)
            XCTAssertEqual(composition.dryStrokes.count + composition.liveStrokes.count, strokes.count)
            for stroke in strokes where stroke.ribbon.isBlack {
                XCTAssertFalse(stroke.isLive, "a burnt tongue does not breathe")
                XCTAssertEqual(stroke.motif, .campfire)
            }
            for stroke in strokes where !stroke.isCrack {
                let y = stroke.ribbon.points[0].y
                XCTAssertGreaterThanOrEqual(y, -PaintComposition.margin, mix.rawValue)
                XCTAssertLessThanOrEqual(y, Double(geometry.height) + PaintComposition.margin, mix.rawValue)
            }
            if let firstBed = strokes.firstIndex(where: { !$0.motif.isField }),
               let lastField = strokes.lastIndex(where: { $0.motif.isField }) {
                XCTAssertLessThan(lastField, firstBed, "fields are the ground: \(mix.rawValue)")
            }
        }
    }

    func testTheWindowGeometryIsTheOneOfTheDesign() {
        XCTAssertEqual(geometry.height, 240)
        XCTAssertEqual(geometry.horizonY, 120)
        XCTAssertEqual(geometry.bandBottom - geometry.bandTop, TideLine.band)
        // The band ends 20 pt under the Horizon (the mock-up's 292 to
        // 312): 8 pt of full tints under the reserve strip.
        XCTAssertEqual(geometry.bandBottom, geometry.horizonY + 20)
        XCTAssertGreaterThan(geometry.bandBottom, geometry.horizonY + PaintWindowGeometry.reserve / 2)
        XCTAssertEqual(geometry.density(atY: geometry.bandTop + 10), 1)
        XCTAssertEqual(geometry.density(atY: geometry.bandBottom + 60), 0.625, accuracy: 1e-9)
        // 20 pt over the window: 40 from the band, a tenth of the way to a quarter.
        XCTAssertEqual(geometry.density(atY: -20), 0.75, accuracy: 1e-9)
        XCTAssertEqual(geometry.density(atY: geometry.bandBottom + 200), 0.25, "never under a quarter")
        XCTAssertTrue(geometry.touchesBand([Pigment.P(x: 0, y: Double(geometry.bandTop) - 4)]))
        XCTAssertFalse(geometry.touchesBand([Pigment.P(x: 0, y: Double(geometry.bandBottom) + 20)]))
    }

    /// Over the blue of the sea no warm pigment carries light (lenguaje
    /// §7): in "Sea and wind" every stroke of the wind keeps to its two
    /// olive tints at 70 %, in the band as well, and the raster holds no
    /// warm pixel above the dark; the sea itself is untouched. In "Pink and
    /// rain" the pink field is painted whole, and in "Brown and fire"
    /// nothing is muted.
    func testAWarmMotifOverTheSeaKeepsToItsDarkTints() async throws {
        let seaAndWind = PaintComposition(scene(.seaAndWind))
        let wind = seaAndWind.strokes.filter { $0.motif == .wind }
        XCTAssertFalse(wind.isEmpty)
        XCTAssertTrue(wind.allSatisfy { $0.minimumTint == 2 && $0.ribbon.alpha == PaintComposition.mutedAlpha })
        XCTAssertTrue(seaAndWind.strokes.filter { $0.motif == .ocean }.allSatisfy { $0.minimumTint == 0 })
        XCTAssertTrue(PaintComposition(scene(.pinkAndRain)).strokes.allSatisfy { $0.minimumTint == 0 })
        XCTAssertTrue(PaintComposition(scene(.brownAndFire)).strokes.allSatisfy { $0.minimumTint == 0 })
        XCTAssertTrue(PaintComposition.isMuted(.brown, among: [.brown, .rain]))
        XCTAssertTrue(PaintComposition.isMuted(.rain, among: [.rain, .campfire]), "no blue in the campfire")
        XCTAssertFalse(PaintComposition.isMuted(.pink, among: [.pink, .rain]))
        XCTAssertFalse(PaintComposition.isMuted(.wind, among: [.wind, .brown]))

        // The raster: the two layers over black, without the veil. A warm
        // pixel is one with red over blue; none passes Y 0.05.
        let raster = try await PaintRasterizer().request(scene(.seaAndWind), scale: 1).value
        let width = raster.dry.width, height = raster.dry.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let context = try XCTUnwrap(CGContext(
            data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: Pigment.sRGB, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
        context.fill(rect)
        context.draw(raster.dry, in: rect)
        context.draw(raster.live, in: rect)
        var warm = 0
        for i in stride(from: 0, to: pixels.count, by: 4) {
            let r = Int(pixels[i]), g = Int(pixels[i + 1]), b = Int(pixels[i + 2])
            guard r >= g, g >= b, r > b + 8 else { continue }
            func linear(_ v: Int) -> Double {
                let c = Double(v) / 255
                return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
            }
            if 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b) > 0.05 { warm += 1 }
        }
        XCTAssertEqual(warm, 0, "wheat over the sea: the pair the jury forbade")
    }

    // MARK: The rasterizer

    /// Two layers of the window at the scale asked, alpha in both, drawn
    /// off the main thread; the measure of the raster for the report.
    func testTheRasterIsTwoLayersOfTheWindowOffTheMainThread() async throws {
        let rasterizer = PaintRasterizer()
        for mix in HouseMix.allCases {
            let raster = try await rasterizer.request(scene(mix), scale: 3).value
            XCTAssertFalse(raster.renderedOnMainThread, mix.rawValue)
            XCTAssertEqual(raster.dry.width, Int(geometry.width * 3))
            XCTAssertEqual(raster.dry.height, Int(geometry.height * 3))
            XCTAssertEqual(raster.live.width, raster.dry.width)
            XCTAssertEqual(raster.live.height, raster.dry.height)
            XCTAssertEqual(raster.dry.alphaInfo, .premultipliedLast)
            XCTAssertEqual(raster.live.alphaInfo, .premultipliedLast)
            XCTAssertEqual(raster.bytes, 2 * Int(geometry.width * 3) * 4 * Int(geometry.height * 3))
            XCTAssertGreaterThan(raster.renderTime, 0)
            let ms = Int((raster.renderTime * 1000).rounded())
            print("paint: window \(mix.rawValue) at 3x · \(raster.strokeCount) strokes · \(ms) ms · \(raster.bytes) bytes")
            // The live layer is mostly empty: it holds a fifth of the ribbons.
            XCTAssertLessThan(coverage(raster.live), coverage(raster.dry), mix.rawValue)
            XCTAssertGreaterThan(coverage(raster.live), 0, mix.rawValue)
        }
    }

    /// A request cancelled before the queue reaches it draws nothing and
    /// throws; a newer request cancels the one before it.
    func testANewerSceneCancelsTheRasterInFlight() async throws {
        let queue = DispatchQueue(label: "paint.test", qos: .utility)
        queue.suspend()
        let rasterizer = PaintRasterizer(queue: queue)
        let first = rasterizer.request(scene(.wall), scale: 1)
        let second = rasterizer.request(scene(.pinkAndRain), scale: 1)
        XCTAssertTrue(first.isCancelled)
        XCTAssertFalse(second.isCancelled)
        queue.resume()
        do {
            _ = try await first.value
            XCTFail("a cancelled request must not deliver a raster")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
        let raster = try await second.value
        XCTAssertEqual(raster.scene, scene(.pinkAndRain))
    }

    /// The drawing itself stops at the next stroke once cancelled. (It is
    /// called off the main thread here as everywhere: on the main thread
    /// `draw` refuses to run, by precondition.)
    func testTheDrawingStopsWhenCancelled() {
        let counter = Counter()
        XCTAssertThrowsError(try offMain {
            try PaintRasterizer.draw(self.scene(.wall), scale: 1) { counter.bump() < 3 }
        }) { error in
            XCTAssertTrue(error is CancellationError)
        }
        XCTAssertEqual(counter.count, 3, "asked at the start and every \(PaintRasterizer.checkEvery) strokes")
    }

    func testCancelAllLeavesNothingInFlight() async {
        let queue = DispatchQueue(label: "paint.test.cancelAll", qos: .utility)
        queue.suspend()
        let rasterizer = PaintRasterizer(queue: queue)
        let request = rasterizer.request(scene(.wall), scale: 1)
        rasterizer.cancelAll()
        queue.resume()
        do {
            _ = try await request.value
            XCTFail("cancelled")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }

    // MARK: The store

    @MainActor
    func testTheStorePublishesTheLayersAndDropsThemWhenAbsent() async {
        let store = PaintStore()
        XCTAssertNil(store.dry)
        XCTAssertNil(store.live)
        store.apply(scene: scene(.brownAndFire), phase: .visible, scale: 2)
        XCTAssertTrue(store.isRendering)
        await store.settle()
        XCTAssertFalse(store.isRendering)
        XCTAssertNotNil(store.dry)
        XCTAssertNotNil(store.live)
        XCTAssertEqual(store.raster?.scene, scene(.brownAndFire))
        XCTAssertNotNil(store.lastRenderTime)

        // The same scene again: nothing is drawn again.
        var before = store.raster
        store.apply(scene: scene(.brownAndFire), phase: .frozen, scale: 2)
        XCTAssertFalse(store.isRendering)
        XCTAssertEqual(store.phase, .frozen)
        XCTAssertTrue(store.raster?.dry === before?.dry)

        // Absent: nil, not opacity 0, and nothing else holds the bitmaps:
        // not the rasterizer, not a request (the test lets go of its own
        // copy first). The memory goes with them.
        weak let dry = store.dry
        weak let live = store.live
        XCTAssertNotNil(dry)
        before = nil
        store.apply(scene: scene(.brownAndFire), phase: .absent, scale: 2)
        XCTAssertNil(store.raster)
        XCTAssertNil(store.dry)
        XCTAssertNil(store.live)
        XCTAssertFalse(store.isRendering)
        XCTAssertNil(dry, "the dry layer is still in memory behind the dark screen")
        XCTAssertNil(live, "the live layer is still in memory behind the dark screen")

        // No scene: nothing to paint.
        store.apply(scene: nil, phase: .visible, scale: 2)
        XCTAssertNil(store.raster)
        XCTAssertFalse(store.isRendering)
    }

    /// A scene that changes while its raster is in flight: the first raster
    /// never shows, the second does. Going absent while in flight: nothing
    /// shows.
    @MainActor
    func testTheStoreKeepsOnlyTheSceneStillWanted() async {
        let store = PaintStore()
        store.apply(scene: scene(.wall), phase: .visible, scale: 1)
        store.apply(scene: scene(.seaAndWind), phase: .visible, scale: 1)
        await store.settle()
        XCTAssertEqual(store.raster?.scene, scene(.seaAndWind))

        store.apply(scene: scene(.pinkAndRain), phase: .visible, scale: 1)
        store.apply(scene: scene(.pinkAndRain), phase: .absent, scale: 1)
        await store.settle()
        XCTAssertNil(store.raster)
        XCTAssertFalse(store.isRendering)
    }

    // MARK: The breath of the live layer

    func testTheLiveOpacityStaysInsideTheLanguage() {
        XCTAssertEqual(PaintBreath.liveTarget(rms: 0), 0, "silence: nothing is drawn")
        XCTAssertEqual(PaintBreath.liveTarget(rms: 1), PaintBreath.liveMax)
        XCTAssertEqual(PaintBreath.liveTarget(rms: 0.003), PaintBreath.liveMin, accuracy: 1e-6, "under the floor, at the floor")
        var rms: Float = 0
        while rms <= 1 {
            let value = PaintBreath.liveTarget(rms: rms)
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, PaintBreath.liveMax)
            rms += 0.01
        }
        XCTAssertEqual(PaintBreath.maxChangePerSecond, 0.2, accuracy: 1e-9, "half the range per second")
    }

    /// From silence to a loud mix the follower is born in two seconds and
    /// never jumps; back to silence it dies in three.
    func testTheFollowerNeverJumps() {
        var follower = PaintBreathFollower()
        XCTAssertEqual(follower.liveOpacity, 0)
        let dt = Motion.horizonInterval
        var previous = follower
        var ticks = 0
        while follower.presence < 1 {
            follower.advance(rms: 0.5, dt: dt)
            XCTAssertLessThanOrEqual(abs(follower.level - previous.level), PaintBreath.maxChangePerSecond * dt + 1e-9)
            XCTAssertLessThanOrEqual(abs(follower.presence - previous.presence), dt / PaintBreath.birth + 1e-9)
            XCTAssertLessThanOrEqual(follower.liveOpacity, PaintBreath.liveMax)
            previous = follower
            ticks += 1
            XCTAssertLessThan(ticks, 1000)
        }
        XCTAssertEqual(Double(ticks) * dt, PaintBreath.birth, accuracy: dt * 2)
        // Loud now: the level climbs at most 0.2 a second.
        for _ in 0..<40 { follower.advance(rms: 1, dt: dt) }
        XCTAssertEqual(follower.level, PaintBreath.liveMax, accuracy: 1e-6)
        XCTAssertEqual(follower.liveOpacity, PaintBreath.liveMax, accuracy: 1e-6)
        // A sudden drop in level moves the layer slowly too.
        follower.advance(rms: 0.003, dt: dt)
        XCTAssertGreaterThan(follower.level, PaintBreath.liveMax - 0.011)
        // Silence: dead in three seconds, never below zero.
        ticks = 0
        while follower.presence > 0 {
            follower.advance(rms: 0, dt: dt)
            XCTAssertGreaterThanOrEqual(follower.liveOpacity, 0)
            ticks += 1
            XCTAssertLessThan(ticks, 1000)
        }
        XCTAssertEqual(Double(ticks) * dt, PaintBreath.death, accuracy: dt * 2)
        follower.reset()
        XCTAssertEqual(follower, PaintBreathFollower())
    }

    func testTheTideSlidesTheWindowSixPointsAlongTheMotif() {
        XCTAssertEqual(PaintBreath.offset(tide: nil, direction: 0), .zero)
        XCTAssertEqual(PaintBreath.offset(tide: 0.5, direction: 0), .zero)
        XCTAssertEqual(PaintBreath.offset(tide: 1, direction: 0).width, 6, accuracy: 1e-9)
        XCTAssertEqual(PaintBreath.offset(tide: 0, direction: 0).width, -6, accuracy: 1e-9)
        let rain = PaintBreath.offset(tide: 1, direction: 72 * Double.pi / 180)
        XCTAssertEqual((rain.width * rain.width + rain.height * rain.height).squareRoot(), 6, accuracy: 1e-9)
        XCTAssertEqual(PaintBreath.offset(tide: 7, direction: 0).width, 6, "clamped")
    }

    // MARK: The phase

    func testThePhaseRuleOnATable() {
        let noon = day(11, 19), evening = day(11, 19, hour: 21), dawn = day(11, 20, hour: 6)
        var base = PaintConditions(now: noon)
        base.calendar = calendar
        func phase(_ change: (inout PaintConditions) -> Void) -> PaintPhase {
            var conditions = base
            change(&conditions)
            return PaintPolicy.phase(conditions)
        }
        XCTAssertEqual(phase { _ in }, .visible)
        // Absent, whatever else is on.
        XCTAssertEqual(phase { $0.now = evening }, .absent)
        XCTAssertEqual(phase { $0.now = dawn }, .absent)
        XCTAssertEqual(phase { $0.nightPhase = .nightPage }, .absent)
        XCTAssertEqual(phase { $0.nightPhase = .night }, .absent)
        XCTAssertEqual(phase { $0.nightPhase = .smallHours }, .absent)
        XCTAssertEqual(phase { $0.isLuminanceReduced = true }, .absent)
        XCTAssertEqual(phase { $0.increaseContrast = true }, .absent)
        XCTAssertEqual(phase { $0.reduceTransparency = true }, .absent)
        XCTAssertEqual(phase { $0.setting = .never }, .absent)
        XCTAssertEqual(phase { $0.setting = .never; $0.sheetPresented = true; $0.reduceMotion = true }, .absent)
        XCTAssertEqual(phase { $0.nightPhase = .night; $0.sheetPresented = true }, .absent)
        // Dimmed: nobody looks.
        XCTAssertEqual(phase { $0.sheetPresented = true }, .dimmed)
        XCTAssertEqual(phase { $0.sceneActive = false }, .dimmed)
        XCTAssertEqual(phase { $0.sheetPresented = true; $0.reduceMotion = true }, .dimmed)
        // Frozen: on show, still.
        XCTAssertEqual(phase { $0.reduceMotion = true }, .frozen)
        // The border is the one of the night window.
        XCTAssertEqual(phase { $0.now = self.day(11, 19, hour: 20) }, .visible)
        XCTAssertEqual(phase { $0.now = self.day(11, 20, hour: 7) }, .visible)
    }

    func testThePhasesSayWhatTheyDraw() {
        XCTAssertEqual(PaintPhase.allCases.filter(\.exists), [.visible, .dimmed, .frozen])
        XCTAssertEqual(PaintPhase.allCases.filter(\.isLive), [.visible])
        XCTAssertEqual(PaintPhase.visible.opacity, 1)
        XCTAssertEqual(PaintPhase.frozen.opacity, 1)
        XCTAssertEqual(PaintPhase.dimmed.opacity, PaintBreath.dimmedOpacity)
        XCTAssertEqual(PaintPhase.absent.opacity, 0)
    }

    // MARK: The setting

    func testTheSettingHasAStableKeyAndADefault() {
        XCTAssertEqual(PaintSetting.key, "sleepnoise.paint.v1")
        XCTAssertEqual(PaintSetting.default, .byDay)
        let defaults = UserDefaults(suiteName: "PaintEngineTests.setting")!
        defaults.removePersistentDomain(forName: "PaintEngineTests.setting")
        XCTAssertEqual(PaintSetting.stored(in: defaults), .byDay)
        defaults.set("never", forKey: PaintSetting.key)
        XCTAssertEqual(PaintSetting.stored(in: defaults), .never)
        defaults.set("something", forKey: PaintSetting.key)
        XCTAssertEqual(PaintSetting.stored(in: defaults), .byDay, "an unknown value is the default")
        defaults.removePersistentDomain(forName: "PaintEngineTests.setting")
    }

    /// Reduce Motion and Increase Contrast together turn the paint off on
    /// their own; either alone leaves the choice as it is.
    func testBothAccessibilitySwitchesTurnThePaintOff() {
        XCTAssertEqual(PaintSetting.effective(.byDay, reduceMotion: false, increaseContrast: false), .byDay)
        XCTAssertEqual(PaintSetting.effective(.byDay, reduceMotion: true, increaseContrast: false), .byDay)
        XCTAssertEqual(PaintSetting.effective(.byDay, reduceMotion: false, increaseContrast: true), .byDay)
        XCTAssertEqual(PaintSetting.effective(.byDay, reduceMotion: true, increaseContrast: true), .never)
        XCTAssertEqual(PaintSetting.effective(.never, reduceMotion: false, increaseContrast: false), .never)
    }

    @MainActor
    func testChoosingThePaintSettingIsKept() throws {
        let night = try NightHarness(at: NightHarness.time(12))
        XCTAssertEqual(night.model.paintSetting, .byDay, "the default")
        night.model.setPaintSetting(.never)
        XCTAssertEqual(night.model.paintSetting, .never)
        XCTAssertEqual(night.defaults.string(forKey: PaintSetting.key), PaintSetting.never.rawValue)
        night.model.setPaintSetting(.byDay)
        XCTAssertEqual(night.defaults.string(forKey: PaintSetting.key), PaintSetting.byDay.rawValue)
    }

    func testThePaintSettingHasItsWordsInBothLanguages() {
        let expected: [(PaintSetting, String, String)] = [
            (.byDay, "By day", "De día"),
            (.never, "Never", "Nunca"),
        ]
        XCTAssertEqual(PaintSetting.allCases.count, expected.count)
        XCTAssertEqual(ProCatalog.lookup("en")(SettingsText.paintTitleKey), "Paint")
        XCTAssertEqual(ProCatalog.lookup("es")(SettingsText.paintTitleKey), "Pintura")
        for (option, english, spanish) in expected {
            let key = SettingsText.paintKey(option)
            XCTAssertEqual(ProCatalog.lookup("en")(key), english)
            XCTAssertEqual(ProCatalog.lookup("es")(key), spanish)
        }
    }

    // MARK: MetricKit

    func testTheMetricsLogKeepsTheLastThirtyDaysAndWritesItsFile() throws {
        let suite = "PaintEngineTests.metrics"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("paint-metrics-test.json")
        let log = PaintMetricsLog(defaults: defaults, fileURL: file)
        log.clear()
        XCTAssertEqual(log.samples, [])
        XCTAssertEqual(log.dump(), "[]")
        let day0 = Date(timeIntervalSinceReferenceDate: 800_000_000)
        for i in 0..<(PaintMetricsLog.keep + 3) {
            log.record(PaintMetricsSample(
                receivedAt: day0.addingTimeInterval(Double(i) * 86_400),
                begin: day0.addingTimeInterval(Double(i - 1) * 86_400),
                end: day0.addingTimeInterval(Double(i) * 86_400),
                averagePixelLuminance: Double(i),
                cpuSeconds: 12.5,
                cpuInstructions: 1e9,
                appVersion: "1.0.0"
            ))
        }
        XCTAssertEqual(log.samples.count, PaintMetricsLog.keep)
        XCTAssertEqual(log.samples.first?.averagePixelLuminance, 3, "the oldest went")
        XCTAssertEqual(log.samples.last?.averagePixelLuminance, Double(PaintMetricsLog.keep + 2))
        let dump = log.dump()
        XCTAssertTrue(dump.contains("\"averagePixelLuminance\""))
        XCTAssertTrue(dump.contains("\"cpuSeconds\" : 12.5"))
        XCTAssertEqual(try String(contentsOf: file, encoding: .utf8), dump, "the file is the dump")
        // A second log on the same defaults reads the same samples.
        XCTAssertEqual(PaintMetricsLog(defaults: defaults, fileURL: nil).samples, log.samples)
        log.clear()
        XCTAssertEqual(log.samples, [])
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        defaults.removePersistentDomain(forName: suite)
    }

    func testTheSubscriberIsOneAndWritesToTheStandardLog() {
        XCTAssertTrue(PaintMetricsSubscriber.shared === PaintMetricsSubscriber.shared)
        XCTAssertTrue(PaintMetricsSubscriber.shared.log === PaintMetricsLog.standard)
        XCTAssertEqual(PaintMetricsLog.key, "sleepnoise.paint.metrics.v1")
    }

    // MARK: Proofs

    /// Writes the four windows of the house, veiled as the page will veil
    /// them (35 % at the Horizon, 75 % at the edges, 80 % on the reserve
    /// strip), to .build/shots/window-<mix>.png at 3x, and measures the
    /// luminance the design caps: mean Y of the veiled paint outside the
    /// band at most 0.08, peak Y at most 0.28 (exploration 12 §7 fase 2).
    /// Then the same window paused: the paint dried to 0.6 under the whole
    /// veil, which never thins with the phase, so every zone is darker
    /// than it is while sounding, under the rows included.
    func testTheVeiledWindowStaysUnderTheLuminanceTheDesignCaps() async throws {
        let rasterizer = PaintRasterizer()
        let shots = CatalogSource.root.appendingPathComponent(".build/shots")
        try FileManager.default.createDirectory(at: shots, withIntermediateDirectories: true)
        struct Measure { var outside: Double; var band: Double; var below: Double; var peak: Double }
        for mix in HouseMix.allCases {
            let raster = try await rasterizer.request(scene(mix), scale: 3).value
            let g = raster.scene.geometry
            let width = raster.dry.width, height = raster.dry.height

            /// The two layers at their alpha, over black, under the veil
            /// the page draws (`PaintVeil`), row by row, in the flipped
            /// device space of the bitmap (row 0 at the top of the image),
            /// without the text reserves: the bare window.
            func compose(dry dryAlpha: Double, live liveAlpha: Double) throws -> (pixels: [UInt8], image: CGImage) {
                var pixels = [UInt8](repeating: 0, count: width * height * 4)
                let context = try XCTUnwrap(CGContext(
                    data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                    space: Pigment.sRGB, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
                ))
                context.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
                context.fill(CGRect(x: 0, y: 0, width: width, height: height))
                let rect = CGRect(x: 0, y: 0, width: width, height: height)
                context.saveGState()
                context.setAlpha(CGFloat(dryAlpha))
                context.draw(raster.dry, in: rect)
                context.restoreGState()
                context.saveGState()
                context.setAlpha(CGFloat(liveAlpha))
                context.draw(raster.live, in: rect)
                context.restoreGState()
                context.scaleBy(x: 3, y: 3)
                for row in 0..<Int(g.height) {
                    let y = CGFloat(row) + 0.5
                    let veil = PaintVeil.opacity(atY: y, geometry: g)
                    context.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: CGFloat(veil)))
                    context.fill(CGRect(x: 0, y: g.height - CGFloat(row) - 1, width: g.width, height: 1))
                }
                let image = try XCTUnwrap(context.makeImage())
                return (pixels, image)
            }

            func measure(_ pixels: [UInt8]) -> Measure {
                func luminance(_ i: Int) -> Double {
                    func linear(_ v: UInt8) -> Double {
                        let c = Double(v) / 255
                        return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
                    }
                    return 0.2126 * linear(pixels[i]) + 0.7152 * linear(pixels[i + 1]) + 0.0722 * linear(pixels[i + 2])
                }
                var outsideSum = 0.0, outsideCount = 0, peak = 0.0, bandSum = 0.0, bandCount = 0
                var belowSum = 0.0, belowCount = 0
                for row in 0..<height {
                    let y = CGFloat(row) / 3
                    let inBand = y >= g.bandTop && y <= g.bandBottom
                    for column in 0..<width {
                        let value = luminance((row * width + column) * 4)
                        peak = max(peak, value)
                        if inBand { bandSum += value; bandCount += 1 } else { outsideSum += value; outsideCount += 1 }
                        if y > g.bandBottom + PaintWindowGeometry.feather { belowSum += value; belowCount += 1 }
                    }
                }
                return Measure(
                    outside: outsideSum / Double(outsideCount), band: bandSum / Double(bandCount),
                    below: belowSum / Double(max(1, belowCount)), peak: peak
                )
            }

            // Sounding: the live layer at its brightest.
            let sounding = try compose(dry: 1, live: PaintBreath.liveMax)
            let url = shots.appendingPathComponent("window-\(mix.rawValue).png")
            let png = try XCTUnwrap(UIImage(cgImage: sounding.image).pngData())
            try png.write(to: url)
            let lit = measure(sounding.pixels)
            print("paint: veiled window \(mix.rawValue) · mean Y outside band \(lit.outside) · in band \(lit.band) · peak Y \(lit.peak) · \(url.lastPathComponent)")
            XCTAssertLessThanOrEqual(lit.outside, 0.08, "\(mix.rawValue): the veiled paint outside the band lights the room")
            XCTAssertLessThanOrEqual(lit.peak, 0.28, "\(mix.rawValue): a pixel of the veiled paint outshines the design")

            // Paused: the same picture dried to 0.6 (`PaintMotion.opacity`),
            // the live strokes at their lowest, the veil whole. Darker in
            // every zone, the rows' included: pausing never lights the page.
            let dried = PaintMotion.opacity(phase: .visible, isPlaying: false)
            XCTAssertEqual(dried, PaintBreath.driedOpacity)
            let paused = try compose(dry: dried, live: dried * PaintBreath.liveMin)
            let dry = measure(paused.pixels)
            print("paint: veiled window \(mix.rawValue) paused · mean Y outside band \(dry.outside) · in band \(dry.band) · under the rows \(dry.below) · peak Y \(dry.peak)")
            XCTAssertLessThanOrEqual(dry.outside, lit.outside * dried + 1e-6, "\(mix.rawValue): paused, the paint outside the band got lighter")
            XCTAssertLessThanOrEqual(dry.band, lit.band * dried + 1e-6, "\(mix.rawValue): paused, the band got lighter")
            XCTAssertLessThanOrEqual(dry.below, lit.below * dried + 1e-6, "\(mix.rawValue): paused, the paint under the rows got lighter")
            XCTAssertLessThanOrEqual(dry.peak, lit.peak, "\(mix.rawValue): paused, a pixel outshines the sounding window")
            XCTAssertGreaterThan(dry.band, 0, "\(mix.rawValue): paused is not absent")
        }
    }

    // MARK: Helpers

    private final class Counter: @unchecked Sendable {
        private(set) var count = 0
        func bump() -> Int { count += 1; return count }
    }

    /// Runs `work` on a utility queue and waits: the drawing never runs on
    /// the main thread, and the tests respect that.
    private func offMain<T>(_ work: @escaping () throws -> T) throws -> T {
        // `sync` would run the block on the main thread itself; `async` and
        // a wait puts it on another thread, as the rasterizer's queue does.
        let queue = DispatchQueue(label: "paint.test.offMain", qos: .utility)
        let done = DispatchSemaphore(value: 0)
        var outcome: Result<T, Error>!
        queue.async {
            outcome = Result { try work() }
            done.signal()
        }
        done.wait()
        return try outcome.get()
    }

    private func bytes(_ image: CGImage) -> Data {
        guard let provider = image.dataProvider, let data = provider.data else { return Data() }
        return data as Data
    }

    /// The RGB channels of an image, one byte each, alpha dropped.
    private func rgb(_ image: CGImage) -> [UInt8] {
        let width = image.width, height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let context = CGContext(
            data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: Pigment.sRGB, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )!
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        var out: [UInt8] = []
        out.reserveCapacity(width * height * 3)
        for i in stride(from: 0, to: pixels.count, by: 4) {
            out.append(pixels[i]); out.append(pixels[i + 1]); out.append(pixels[i + 2])
        }
        return out
    }

    /// The share of pixels with any alpha.
    private func coverage(_ image: CGImage) -> Double {
        let data = bytes(image)
        guard !data.isEmpty else { return 0 }
        var covered = 0
        var i = 3
        while i < data.count {
            if data[i] > 0 { covered += 1 }
            i += 4
        }
        return Double(covered) / Double(data.count / 4)
    }
}
