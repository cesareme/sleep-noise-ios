import Observation
import SwiftUI

/// One accent per screen (03 §3.1 rule 2).
///
/// Every component that may carry the accent asks here first. The finger on a
/// level row outranks the tide line, which outranks the Horizon; whoever is
/// not the owner draws in plain ink. With nobody claiming, the screen has no
/// colour at all, which is what silence looks like.
///
/// A screen installs its own arbiter with `.indexArbiter(_:)`. The purchase
/// hairlines are outside it by rule (they exist only on the Pro sheet, where
/// nothing else claims).
@Observable
final class IndexArbiter {
    enum Owner: Equatable {
        /// A finger dragging the level row with this identifier.
        case finger(String)
        /// The tide line while it guides.
        case tide
        /// The Horizon while the engine produces audio.
        case horizon

        fileprivate var rank: Int {
            switch self {
            case .finger: return 0
            case .tide: return 1
            case .horizon: return 2
            }
        }
    }

    private(set) var owner: Owner?
    @ObservationIgnored private var claims: [Owner] = []

    init() {}

    func claim(_ candidate: Owner) {
        claims.removeAll { $0 == candidate }
        claims.append(candidate)
        resolve()
    }

    func release(_ candidate: Owner) {
        claims.removeAll { $0 == candidate }
        resolve()
    }

    func owns(_ candidate: Owner) -> Bool {
        owner == candidate
    }

    /// True while a finger holds a level row.
    var fingerIsDown: Bool {
        if case .finger = owner { return true }
        return false
    }

    private func resolve() {
        // Among equals the oldest claim wins: a second finger takes nothing.
        let next = claims.enumerated().min { lhs, rhs in
            (lhs.element.rank, lhs.offset) < (rhs.element.rank, rhs.offset)
        }?.element
        if next != owner {
            owner = next
        }
    }
}

private struct IndexArbiterKey: EnvironmentKey {
    static let defaultValue = IndexArbiter()
}

extension EnvironmentValues {
    var indexArbiter: IndexArbiter {
        get { self[IndexArbiterKey.self] }
        set { self[IndexArbiterKey.self] = newValue }
    }
}

extension View {
    /// Gives this screen its own arbiter. Without it, components fall back to
    /// one shared arbiter, which is only right for a single screen.
    func indexArbiter(_ arbiter: IndexArbiter) -> some View {
        environment(\.indexArbiter, arbiter)
    }
}
