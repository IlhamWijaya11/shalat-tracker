import Foundation

/// One flagged tuma'ninah problem: a key posture held too briefly.
public struct TumaninahViolation: Equatable, Sendable {
    public let rakaat: Int
    public let posture: Posture
    public let duration: Double

    public init(rakaat: Int, posture: Posture, duration: Double) {
        self.rakaat = rakaat
        self.posture = posture
        self.duration = duration
    }

    /// Indonesian message for the result screen.
    public var message: String {
        "\(posture.labelID.capitalized) rakaat \(rakaat) terlalu cepat (\(String(format: "%.1f", duration))s)"
    }
}

/// Checks tuma'ninah: key postures must be held at least a minimum time.
/// v1 validates ruku and sujud (the unambiguous cases). i'tidal/duduk are harder
/// to separate from qiyam reliably, so they're off by default.
public struct MovementValidator: Sendable {
    /// Minimum hold time (seconds) per posture. Postures absent from the map are
    /// not validated.
    public var minDwell: [Posture: Double]

    public init(minDwell: [Posture: Double] = [.ruku: 1.0, .sujud: 1.0]) {
        self.minDwell = minDwell
    }

    /// Returns a violation if this segment is a validated posture held too briefly.
    public func check(posture: Posture, duration: Double, rakaat: Int) -> TumaninahViolation? {
        guard let minimum = minDwell[posture], duration < minimum else { return nil }
        return TumaninahViolation(rakaat: rakaat, posture: posture, duration: duration)
    }
}
