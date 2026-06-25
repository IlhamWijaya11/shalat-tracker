import Foundation

/// Counts rakaat from a stream of committed postures + timestamps.
///
/// Core insight (see plan): **each rakaat contains exactly one ruku**, so the
/// rakaat count = the number of times the body enters the ruku posture. Sujud
/// presence and long final sitting (tashahhud) confirm structure and detect the
/// end of the session.
///
/// Feed it the *smoothed* posture (from `PostureSmoother`) once per frame.
public final class RakaatStateMachine {

    /// A contiguous run of one posture.
    public struct Segment: Equatable, Sendable {
        public let posture: Posture
        public let start: Double
        public let end: Double
        public var duration: Double { end - start }
    }

    public private(set) var rakaatCount = 0
    public private(set) var isComplete = false
    public private(set) var segments: [Segment] = []
    public private(set) var violations: [TumaninahViolation] = []

    private let validator: MovementValidator
    /// A jalsa held at least this long (after the min rakaat) marks the end.
    private let finalSitSeconds: Double
    private let minRakaatForComplete: Int

    private var currentPosture: Posture = .unknown
    private var segmentStart: Double = 0
    private var started = false

    public init(
        validator: MovementValidator = MovementValidator(),
        finalSitSeconds: Double = 6.0,
        minRakaatForComplete: Int = 2
    ) {
        self.validator = validator
        self.finalSitSeconds = finalSitSeconds
        self.minRakaatForComplete = minRakaatForComplete
    }

    /// Feed one frame. `posture` should already be smoothed; `t` is seconds.
    public func update(posture: Posture, t: Double) {
        guard !isComplete else { return }

        if !started {
            started = true
            currentPosture = posture
            segmentStart = t
            if posture == .ruku { rakaatCount += 1 }
            return
        }

        if posture != currentPosture {
            closeSegment(end: t)
            // Entering ruku from any other posture = one more rakaat.
            if posture == .ruku { rakaatCount += 1 }
            currentPosture = posture
            segmentStart = t
        }

        // Long sustained sitting after enough rakaat ⇒ tashahhud / session end.
        if currentPosture == .jalsa,
           rakaatCount >= minRakaatForComplete,
           (t - segmentStart) >= finalSitSeconds {
            closeSegment(end: t)
            isComplete = true
        }
    }

    /// Force-close the session (e.g. user taps stop), flushing the open segment.
    public func finish(at t: Double) {
        guard started, !isComplete else { return }
        closeSegment(end: t)
        isComplete = true
    }

    private func closeSegment(end: Double) {
        let seg = Segment(posture: currentPosture, start: segmentStart, end: end)
        segments.append(seg)
        // Pre-first-ruku postures belong to rakaat 1.
        let rakaat = max(1, rakaatCount)
        if let v = validator.check(posture: seg.posture, duration: seg.duration, rakaat: rakaat) {
            violations.append(v)
        }
    }

    public func reset() {
        rakaatCount = 0
        isComplete = false
        segments = []
        violations = []
        currentPosture = .unknown
        segmentStart = 0
        started = false
    }
}
