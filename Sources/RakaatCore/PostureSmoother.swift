import Foundation

/// Debounces a noisy per-frame posture stream into a stable "committed" posture.
/// A new posture must persist for `holdFrames` consecutive frames before it
/// replaces the committed one — kills single-frame jitter without much lag.
public final class PostureSmoother {
    private let holdFrames: Int
    private var committed: Posture = .unknown
    private var candidate: Posture = .unknown
    private var candidateRun = 0

    public init(holdFrames: Int = 4) {
        self.holdFrames = max(1, holdFrames)
    }

    public var current: Posture { committed }

    /// Feed one raw classification; returns the (possibly unchanged) committed posture.
    @discardableResult
    public func feed(_ raw: Posture) -> Posture {
        if raw == candidate {
            candidateRun += 1
        } else {
            candidate = raw
            candidateRun = 1
        }
        if candidate != committed && candidateRun >= holdFrames {
            committed = candidate
        }
        return committed
    }

    public func reset() {
        committed = .unknown
        candidate = .unknown
        candidateRun = 0
    }
}
