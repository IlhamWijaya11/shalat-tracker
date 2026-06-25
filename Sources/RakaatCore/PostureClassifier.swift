import Foundation

/// Rule-based posture classifier (v1). Transparent, fast, no training data.
/// Swap for a CoreML action classifier later (see plan, roadmap step 7) if the
/// rules prove too brittle.
public struct PostureClassifier {
    public struct Thresholds: Sendable {
        /// Above this torso angle the spine counts as "tilted" (ruku/sujud).
        public var tiltedAngle: Double = 45
        /// In a tilted pose, head this low (×torsoLength above ankle) ⇒ sujud.
        public var sujudHeadAboveAnkle: Double = 0.6
        /// Upright pose with hips this high above ankles ⇒ standing, else sitting.
        public var standingHipAboveAnkle: Double = 0.8

        public init() {}
    }

    public var thresholds: Thresholds

    public init(thresholds: Thresholds = Thresholds()) {
        self.thresholds = thresholds
    }

    public func classify(_ joints: BodyJoints) -> Posture {
        guard let f = PoseFeatures.from(joints) else { return .unknown }
        return classify(f)
    }

    public func classify(_ f: PoseFeatures) -> Posture {
        let t = thresholds
        if f.torsoAngle > t.tiltedAngle {
            // Spine horizontal: ruku vs sujud decided by head height off the floor.
            return f.headAboveAnkle < t.sujudHeadAboveAnkle ? .sujud : .ruku
        } else {
            // Spine upright: standing vs sitting decided by hip height off the floor.
            return f.hipAboveAnkle > t.standingHipAboveAnkle ? .standing : .jalsa
        }
    }
}
