import Foundation

/// Scale-invariant features derived from one frame's joints. All vertical
/// distances are normalized by torso length (shoulder→hip), which stays roughly
/// constant across postures, so thresholds don't depend on the person's distance
/// from the camera.
public struct PoseFeatures: Equatable, Sendable {
    /// Angle of the spine (hip→shoulder vector) from vertical, in degrees 0...180.
    /// ~0 = upright (standing/sitting), ~90 = horizontal (ruku/sujud).
    public let torsoAngle: Double
    /// (head.y − ankle.y) / torsoLength. How high the head sits above the floor.
    /// High when standing/ruku, low in sujud.
    public let headAboveAnkle: Double
    /// (hip.y − ankle.y) / torsoLength. High when standing, low when sitting.
    public let hipAboveAnkle: Double
    /// (head.y − hip.y) / torsoLength. Positive standing, ~0 ruku, negative sujud.
    public let headAboveHip: Double

    public init(torsoAngle: Double, headAboveAnkle: Double, hipAboveAnkle: Double, headAboveHip: Double) {
        self.torsoAngle = torsoAngle
        self.headAboveAnkle = headAboveAnkle
        self.hipAboveAnkle = hipAboveAnkle
        self.headAboveHip = headAboveHip
    }

    /// Compute features from joints. Returns nil if required joints are missing
    /// or the body has no measurable scale.
    public static func from(_ j: BodyJoints) -> PoseFeatures? {
        guard let shoulder = j.shoulderMid,
              let hip = j.hipMid,
              let ankle = j.ankleMid,
              let head = j.head else { return nil }

        let torso = shoulder - hip
        let torsoLength = torso.length
        guard torsoLength > 1e-6 else { return nil }

        // Angle from vertical (0,1): cos = torso.y / |torso|.
        let cosA = max(-1.0, min(1.0, torso.y / torsoLength))
        let angle = acos(cosA) * 180.0 / Double.pi

        return PoseFeatures(
            torsoAngle: angle,
            headAboveAnkle: (head.y - ankle.y) / torsoLength,
            hipAboveAnkle: (hip.y - ankle.y) / torsoLength,
            headAboveHip: (head.y - hip.y) / torsoLength
        )
    }
}
