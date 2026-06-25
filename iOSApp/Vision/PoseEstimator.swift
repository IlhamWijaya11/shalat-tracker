#if canImport(Vision)
import Vision
import CoreVideo
import RakaatCore

/// Bridges Apple's Vision body-pose detection to RakaatCore's `BodyJoints`.
/// Runs entirely on-device; the pixel buffer is processed and discarded — never
/// written to disk (see plan, "Privacy: No-Video, On-Device Only").
public final class PoseEstimator {
    private let request = VNDetectHumanBodyPoseRequest()
    /// Minimum joint confidence to trust a point.
    public var minConfidence: Float = 0.3

    public init() {}

    /// Detect joints for one frame. Returns nil if no body is found.
    public func joints(in pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .up) -> BodyJoints? {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        guard let observation = request.results?.first else { return nil }
        return Self.map(observation, minConfidence: minConfidence)
    }

    /// Map a Vision observation to BodyJoints. Vision normalized coords already
    /// match RakaatCore (origin bottom-left, y up), so no axis flip is needed.
    static func map(_ obs: VNHumanBodyPoseObservation, minConfidence: Float) -> BodyJoints {
        func pt(_ name: VNHumanBodyPoseObservation.JointName) -> Point2D? {
            guard let p = try? obs.recognizedPoint(name), p.confidence >= minConfidence else { return nil }
            return Point2D(x: Double(p.location.x), y: Double(p.location.y))
        }
        return BodyJoints(
            nose: pt(.nose),
            leftEar: pt(.leftEar), rightEar: pt(.rightEar),
            leftShoulder: pt(.leftShoulder), rightShoulder: pt(.rightShoulder),
            leftHip: pt(.leftHip), rightHip: pt(.rightHip),
            leftKnee: pt(.leftKnee), rightKnee: pt(.rightKnee),
            leftAnkle: pt(.leftAnkle), rightAnkle: pt(.rightAnkle)
        )
    }
}
#endif
