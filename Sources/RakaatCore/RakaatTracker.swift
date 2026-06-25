import Foundation

/// Top-level pipeline the iOS app drives. Feed it joints + timestamp per frame;
/// read `livePosture` / `rakaatCount` for the overlay, and `makeSession(...)`
/// once `isComplete` to get the persisted result.
///
///     classify → smooth → state machine (+ validator)
public final class RakaatTracker {
    private let classifier: PostureClassifier
    private let smoother: PostureSmoother
    private let stateMachine: RakaatStateMachine
    private let inference: PrayerTypeInference

    public init(
        classifier: PostureClassifier = PostureClassifier(),
        smoother: PostureSmoother = PostureSmoother(),
        stateMachine: RakaatStateMachine = RakaatStateMachine(),
        inference: PrayerTypeInference = PrayerTypeInference()
    ) {
        self.classifier = classifier
        self.smoother = smoother
        self.stateMachine = stateMachine
        self.inference = inference
    }

    public var livePosture: Posture { smoother.current }
    public var rakaatCount: Int { stateMachine.rakaatCount }
    public var isComplete: Bool { stateMachine.isComplete }

    /// Process one frame. `t` is a monotonic timestamp in seconds.
    @discardableResult
    public func process(joints: BodyJoints, t: Double) -> Posture {
        let raw = classifier.classify(joints)
        let committed = smoother.feed(raw)
        stateMachine.update(posture: committed, t: t)
        return committed
    }

    /// End the session early (user taps stop).
    public func stop(at t: Double) {
        stateMachine.finish(at: t)
    }

    /// Build the persisted session result. Call after `isComplete` (or stop).
    public func makeSession(at date: Date = Date(), calendar: Calendar = .current) -> RakaatSession {
        let prayer = inference.infer(rakaat: stateMachine.rakaatCount, at: date, calendar: calendar)
        return RakaatSession(
            timestamp: date,
            prayer: prayer,
            rakaat: stateMachine.rakaatCount,
            violations: stateMachine.violations.map(\.message)
        )
    }

    public func reset() {
        smoother.reset()
        stateMachine.reset()
    }
}
