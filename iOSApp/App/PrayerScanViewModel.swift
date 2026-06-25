#if os(iOS)
import SwiftUI
import Combine
import QuartzCore
import RakaatCore

/// Detection input source for a session.
public enum DetectionMode {
    case camera     // kamera + pose detection (butuh jarak, badan full-frame)
    case proximity  // sensor jarak: HP di sajadah, hitung sujud (tempat sempit)
}

/// Wires the chosen input source → RakaatCore, publishing live state to the
/// SwiftUI views. Holds no frames; only the small derived state.
///
/// - `.camera`: camera → pose estimator → `RakaatTracker`.
/// - `.proximity`: `ProximityManager` → `ProximityRakaatCounter` (sujud ÷ 2).
@MainActor
public final class PrayerScanViewModel: ObservableObject {
    @Published public var posture: Posture = .unknown
    @Published public var rakaatCount: Int = 0
    @Published public var isComplete: Bool = false
    @Published public var finishedSession: RakaatSession?
    /// Live sensor state for proximity mode (true = head down / sujud now).
    @Published public var sujudActive: Bool = false

    public private(set) var mode: DetectionMode = .camera

    // Camera path.
    private let camera = CameraManager()
    private let estimator = PoseEstimator()
    private var tracker = RakaatTracker()

    // Proximity path.
    private let proximity = ProximityManager()
    private var counter = ProximityRakaatCounter()
    private let inference = PrayerTypeInference()

    public var captureSession: AVCaptureSession { camera.session }
    public var proximityAvailable: Bool { proximity.isAvailable }

    public init() {
        camera.onFrame = { [weak self] buffer, t in
            guard let self else { return }
            let joints = self.estimator.joints(in: buffer) ?? BodyJoints()
            self.tracker.process(joints: joints, t: t)
            Task { @MainActor in self.publishCamera() }
        }
        proximity.onProximityChange = { [weak self] covered, t in
            guard let self else { return }
            self.counter.feed(covered: covered, t: t)
            Task { @MainActor in self.publishProximity(covered: covered) }
        }
    }

    public func start(mode: DetectionMode = .camera) {
        self.mode = mode
        finishedSession = nil
        isComplete = false
        posture = .unknown
        rakaatCount = 0
        sujudActive = false
        switch mode {
        case .camera:
            tracker.reset()
            camera.start()
        case .proximity:
            counter.reset()
            proximity.start()
        }
    }

    /// User taps stop, or auto-complete fires.
    public func stop(at t: Double = CACurrentMediaTime()) {
        switch mode {
        case .camera:
            tracker.stop(at: t)
            camera.stop()
            finalize(session: tracker.makeSession())
        case .proximity:
            proximity.stop()
            finalize(session: makeProximitySession())
        }
    }

    private func publishCamera() {
        posture = tracker.livePosture
        rakaatCount = tracker.rakaatCount
        if tracker.isComplete && !isComplete {
            isComplete = true
            camera.stop()
            finalize(session: tracker.makeSession())
        }
    }

    private func publishProximity(covered: Bool) {
        sujudActive = covered
        posture = covered ? .sujud : .unknown
        rakaatCount = counter.rakaatCount
    }

    /// Proximity has no posture/timing detail, so no tuma'ninah violations.
    private func makeProximitySession(at date: Date = Date()) -> RakaatSession {
        let rakaat = counter.rakaatCount
        return RakaatSession(
            timestamp: date,
            prayer: inference.infer(rakaat: rakaat, at: date),
            rakaat: rakaat,
            violations: []
        )
    }

    private func finalize(session: RakaatSession) {
        finishedSession = session
        SessionStore.shared.add(session)  // persists summary only — no video
    }
}
#endif
