#if os(iOS)
import UIKit
import QuartzCore

/// Live proximity capture (analog to `CameraManager`, but for the "sajadah" mode).
/// Wraps `UIDevice` proximity monitoring: the front sensor reports *covered* when
/// the user's forehead is down in sujud. Emits one event per state change — no
/// camera, no frames, nothing persisted.
///
/// Note: while monitoring is on, iOS blanks the screen whenever the sensor is
/// covered (same as during a call). That's fine — the phone is face-down-covered
/// on the mat — and the app keeps receiving events.
public final class ProximityManager {

    /// Called on every proximity change: `covered` = sensor blocked (head down),
    /// with a monotonic timestamp in seconds.
    public var onProximityChange: ((Bool, Double) -> Void)?

    private let device = UIDevice.current
    private var observing = false

    public init() {}

    /// Whether the running device actually has a usable proximity sensor.
    public var isAvailable: Bool {
        device.isProximityMonitoringEnabled = true
        let ok = device.isProximityMonitoringEnabled
        device.isProximityMonitoringEnabled = false
        return ok
    }

    public func start() {
        guard !observing else { return }
        device.isProximityMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self, selector: #selector(proximityChanged),
            name: UIDevice.proximityStateDidChangeNotification, object: device)
        observing = true
    }

    public func stop() {
        guard observing else { return }
        NotificationCenter.default.removeObserver(
            self, name: UIDevice.proximityStateDidChangeNotification, object: device)
        device.isProximityMonitoringEnabled = false   // restore normal screen behaviour
        observing = false
    }

    @objc private func proximityChanged() {
        onProximityChange?(device.proximityState, CACurrentMediaTime())
    }

    deinit { stop() }
}
#endif
