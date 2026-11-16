import Foundation

/// Tiny xorshift32. State lives in a register-sized word; `next` does not allocate.
struct XorShift32 {
    var state: UInt32

    init(seed: UInt32) {
        state = seed == 0 ? 0x6D2B79F5 : seed
    }

    mutating func nextUInt() -> UInt32 {
        var x = state
        if x == 0 { x = 0x6D2B79F5 }
        x ^= x << 13
        x ^= x >> 17
        x ^= x << 5
        state = x
        return x
    }

    /// Uniform value in [-1, 1).
    mutating func nextBipolar() -> Float {
        let unit = Float(nextUInt() >> 8) / Float(16_777_216)
        return unit * 2 - 1
    }

    /// Uniform value in [0, 1).
    mutating func nextUnit() -> Float {
        Float(nextUInt() >> 8) / Float(16_777_216)
    }
}
