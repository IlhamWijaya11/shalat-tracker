import Foundation

/// Counts rakaat from a stream of **proximity** events instead of camera poses.
///
/// Technique (see plan): the phone lies face-up on the prayer mat at the spot the
/// **forehead** lands during sujud. Each prostration covers the front proximity
/// sensor; lifting the head uncovers it. Since **each rakaat contains exactly two
/// sujud**, the rakaat count = number of completed sujud ÷ 2.
///
/// This is intentionally a separate, self-contained counter (not the pose
/// `RakaatStateMachine`): proximity sees *sujud*, not *ruku*, and carries no
/// posture/timing detail to validate tuma'ninah. Pure logic, no UIKit — feed it
/// `(covered, t)` edges from `ProximityManager` and read the derived state.
public final class ProximityRakaatCounter {

    /// Number of confirmed sujud (prostrations) seen so far.
    public private(set) var sujudCount = 0

    /// Rakaat to display / persist. `ceil(sujudCount / 2)`: shows the rakaat
    /// currently being performed, and equals the true count when a (even-sujud)
    /// prayer ends. e.g. 0→0, 1→1, 2→1, 3→2, 4→2.
    public var rakaatCount: Int { (sujudCount + 1) / 2 }

    /// A sujud is confirmed only after the sensor stays covered at least this long,
    /// rejecting brief accidental covers (hand wave, adjusting the phone).
    private let minSujudSeconds: Double

    private var coverStart: Double?

    public init(minSujudSeconds: Double = 0.8) {
        self.minSujudSeconds = max(0, minSujudSeconds)
    }

    /// Feed one proximity edge. `covered` = sensor blocked (head down); `t` is a
    /// monotonic timestamp in seconds. Call on every state change.
    public func feed(covered: Bool, t: Double) {
        if covered {
            // Rising edge: head went down. Remember when (ignore repeats).
            if coverStart == nil { coverStart = t }
        } else if let start = coverStart {
            // Falling edge: head came up. Count it if it was held long enough.
            if t - start >= minSujudSeconds { sujudCount += 1 }
            coverStart = nil
        }
    }

    public func reset() {
        sujudCount = 0
        coverStart = nil
    }
}
