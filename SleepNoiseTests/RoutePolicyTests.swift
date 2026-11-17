import XCTest
@testable import SleepNoise

/// What a change of output does to the night.
final class RoutePolicyTests: XCTestCase {
    private let now = Date(timeIntervalSinceReferenceDate: 785_000_000)
    private let speaker = OutputRoute.builtInSpeaker
    private let airPods = OutputRoute.external(id: "airpods")
    private let kitchen = OutputRoute.external(id: "kitchen-speaker")

    private func ago(_ seconds: TimeInterval) -> Date {
        now.addingTimeInterval(-seconds)
    }

    private func state(
        playing: Bool = false,
        session: OutputRoute,
        current: OutputRoute,
        lost: TimeInterval? = nil,
        active: Bool = true,
        master: Float = 0.8
    ) -> RouteState {
        RouteState(
            isPlaying: playing,
            sessionRoute: session,
            currentRoute: current,
            lostOutputAt: lost.map(ago),
            appIsActive: active,
            master: master
        )
    }

    func testActionTable() {
        let offer = now.addingTimeInterval(60)
        let rows: [(String, RouteEvent, RouteState, RouteAction)] = [
            // The output goes away: a 40 ms fade and a pause.
            ("AirPods out", .outputLost, state(playing: true, session: airPods, current: speaker),
             .pause(fadeOut: 0.04, speakerOfferUntil: offer)),
            ("AirPods out with the app behind", .outputLost,
             state(playing: true, session: airPods, current: speaker, active: false),
             .pause(fadeOut: 0.04, speakerOfferUntil: offer)),
            ("AirPods out, another speaker takes over", .outputLost,
             state(playing: true, session: airPods, current: kitchen),
             .pause(fadeOut: 0.04, speakerOfferUntil: nil)),
            ("an output leaves a paused night", .outputLost, state(session: airPods, current: speaker), .none),

            // An output appears: it resumes unasked only on the same output,
            // with the app in front, within twenty minutes, at full level.
            ("AirPods back", .outputAvailable, state(session: airPods, current: airPods, lost: 30),
             .resume(fadeIn: 0.8, master: 0.8)),
            ("AirPods back after 19:59", .outputAvailable, state(session: airPods, current: airPods, lost: 1_199),
             .resume(fadeIn: 0.8, master: 0.8)),
            ("AirPods back after 20:00", .outputAvailable, state(session: airPods, current: airPods, lost: 1_200),
             .endSession),
            ("AirPods back with the app behind", .outputAvailable,
             state(session: airPods, current: airPods, lost: 30, active: false), .none),
            ("something appears, the speaker is still the output", .outputAvailable,
             state(session: airPods, current: speaker, lost: 30), .none),
            ("another speaker connects", .outputAvailable, state(session: airPods, current: kitchen, lost: 30), .none),
            ("an output appears, paused by the person", .outputAvailable,
             state(session: airPods, current: airPods), .none),
            ("an output appears while playing", .outputAvailable,
             state(playing: true, session: speaker, current: airPods), .none),

            // The person asks: it plays on what there is. Capped to 0.4 only
            // when the output changed to the iPhone's speaker.
            ("Keep playing on speaker", .resumeRequested, state(session: airPods, current: speaker, lost: 10),
             .resume(fadeIn: 0.8, master: 0.4)),
            ("on speaker, already quiet", .resumeRequested,
             state(session: airPods, current: speaker, lost: 10, master: 0.25), .resume(fadeIn: 0.8, master: 0.25)),
            ("on speaker, minutes later", .resumeRequested, state(session: airPods, current: speaker, lost: 300),
             .resume(fadeIn: 0.8, master: 0.4)),
            ("on speaker, with the app behind", .resumeRequested,
             state(session: airPods, current: speaker, lost: 10, active: false), .resume(fadeIn: 0.8, master: 0.4)),
            ("AirPods back in, then a touch", .resumeRequested, state(session: airPods, current: airPods, lost: 10),
             .resume(fadeIn: 0.8, master: 0.8)),
            ("paused by hand on AirPods, now the speaker", .resumeRequested, state(session: airPods, current: speaker),
             .resume(fadeIn: 0.8, master: 0.4)),
            ("paused and resumed on the speaker", .resumeRequested, state(session: speaker, current: speaker),
             .resume(fadeIn: 0.8, master: 0.8)),
            ("from the speaker to AirPods", .resumeRequested, state(session: speaker, current: airPods),
             .resume(fadeIn: 0.8, master: 0.8)),
            ("from AirPods to another speaker", .resumeRequested, state(session: airPods, current: kitchen),
             .resume(fadeIn: 0.8, master: 0.8)),
            ("a touch while playing", .resumeRequested, state(playing: true, session: airPods, current: airPods), .none),
        ]
        for (name, event, state, expected) in rows {
            XCTAssertEqual(RoutePolicy.action(for: event, state: state, now: now), expected, name)
        }
    }

    /// Over every combination: the night never comes back by itself on the
    /// iPhone's speaker, and a resume never plays louder than the master.
    func testItNeverResumesByItselfOnTheSpeaker() {
        let routes = [speaker, airPods, kitchen]
        var checked = 0
        for event in RouteEvent.allCases {
            for playing in [true, false] {
                for session in routes {
                    for current in routes {
                        for lost in [nil, 5.0, 59, 61, 1_199, 1_200, 7_200] as [TimeInterval?] {
                            for active in [true, false] {
                                for master in [0.1, 0.4, 0.41, 1] as [Float] {
                                    let state = self.state(
                                        playing: playing, session: session, current: current,
                                        lost: lost, active: active, master: master
                                    )
                                    let action = RoutePolicy.action(for: event, state: state, now: now)
                                    checked += 1
                                    guard case .resume(_, let level) = action else { continue }
                                    let label = "\(event) \(state)"
                                    XCTAssertLessThanOrEqual(level, master, label)
                                    XCTAssertFalse(playing, label)
                                    if event != .resumeRequested {
                                        XCTAssertNotEqual(current, speaker, label)
                                        XCTAssertEqual(current, session, label)
                                        XCTAssertTrue(active, label)
                                    } else if current == speaker, session != speaker {
                                        XCTAssertLessThanOrEqual(level, RoutePolicy.speakerMasterCap, label)
                                    } else {
                                        XCTAssertEqual(level, master, label)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        XCTAssertEqual(checked, 3 * 2 * 3 * 3 * 7 * 2 * 4)
    }

    func testUnaskedResumeOnlyOnTheSameOutput() {
        let cases: [(OutputRoute, OutputRoute, Bool)] = [
            (speaker, speaker, true),
            (airPods, airPods, true),
            (airPods, speaker, false),
            (airPods, kitchen, false),
            (speaker, airPods, false),
        ]
        for (pausedOn, current, expected) in cases {
            XCTAssertEqual(
                RoutePolicy.mayResumeUnasked(pausedOn: pausedOn, current: current), expected, "\(pausedOn) → \(current)"
            )
        }
    }

    func testTheSpeakerOfferLastsAMinute() {
        let cases: [(String, RouteState, Bool)] = [
            ("just lost", state(session: airPods, current: speaker, lost: 0), true),
            ("59.9 s", state(session: airPods, current: speaker, lost: 59.9), true),
            ("60 s", state(session: airPods, current: speaker, lost: 60), false),
            ("five minutes", state(session: airPods, current: speaker, lost: 300), false),
            ("clock set back", state(session: airPods, current: speaker, lost: -5), false),
            ("not lost", state(session: airPods, current: speaker), false),
            ("playing again", state(playing: true, session: speaker, current: speaker, lost: 10), false),
            ("another output took over", state(session: airPods, current: kitchen, lost: 10), false),
            ("AirPods back", state(session: airPods, current: airPods, lost: 10), false),
        ]
        for (name, state, expected) in cases {
            XCTAssertEqual(RoutePolicy.speakerOfferIsVisible(state: state, now: now), expected, name)
        }
    }

    func testNumbersAndTheWordsOfTheOffer() throws {
        XCTAssertEqual(RoutePolicy.lostOutputFadeOut, 0.04)
        XCTAssertEqual(RoutePolicy.speakerOfferDuration, 60)
        XCTAssertEqual(RoutePolicy.speakerMasterCap, 0.4)
        XCTAssertEqual(RoutePolicy.headphonesPauseFadeOut, 3)
        XCTAssertEqual(RoutePolicy.longestPause, 20 * 60)

        let expected = ["en": "Keep playing on speaker", "es": "Seguir por el altavoz"]
        for (language, words) in expected {
            let url = try XCTUnwrap(Bundle(for: MixStore.self).url(forResource: language, withExtension: "lproj"))
            let bundle = try XCTUnwrap(Bundle(url: url))
            XCTAssertEqual(bundle.localizedString(forKey: RoutePolicy.speakerOfferKey, value: nil, table: nil), words)
        }
    }
}
