#if os(iOS)
import SwiftUI
import AVFoundation

/// SwiftUI wrapper around an AVCaptureVideoPreviewLayer. Display only — the
/// preview never records; frames are handled separately by CameraManager.
public struct CameraPreview: UIViewRepresentable {
    public let session: AVCaptureSession

    public init(session: AVCaptureSession) { self.session = session }

    public func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    public func updateUIView(_ uiView: PreviewView, context: Context) {}

    public final class PreviewView: UIView {
        public override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
#endif
