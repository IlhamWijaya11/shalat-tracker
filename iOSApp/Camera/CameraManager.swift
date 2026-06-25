#if canImport(AVFoundation) && os(iOS)
import AVFoundation
import CoreVideo

/// Live camera capture. Streams frames to a delegate for on-device pose
/// processing. **Never** attaches an `AVAssetWriter` or writes frames to disk —
/// the only sink is the per-frame callback (see plan, privacy section).
public final class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "rakaat.camera.frames")

    /// Called for every frame with the raw pixel buffer + a monotonic timestamp (s).
    public var onFrame: ((CVPixelBuffer, Double) -> Void)?

    public override init() {
        super.init()
        configure()
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .high
        // Front or back camera; side-profile framing recommended (see plan).
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
    }

    public func start() {
        queue.async { [weak self] in self?.session.startRunning() }
    }

    public func stop() {
        queue.async { [weak self] in self?.session.stopRunning() }
    }

    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let t = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        onFrame?(buffer, t)
        // sampleBuffer goes out of scope here — nothing is retained or persisted.
    }
}
#endif
