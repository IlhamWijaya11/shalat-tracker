import Foundation

/// The salah postures we classify each frame into.
public enum Posture: String, Equatable, Sendable, CaseIterable {
    case standing   // qiyam / i'tidal — torso upright, hips high above ankles
    case ruku       // bowing — torso ~horizontal, head still well above floor
    case sujud      // prostration — torso low, head near the floor
    case jalsa      // sitting — torso upright, hips low near ankles
    case unknown    // not enough joints to decide

    /// Human-readable Indonesian label for the live overlay.
    public var labelID: String {
        switch self {
        case .standing: return "BERDIRI"
        case .ruku: return "RUKU"
        case .sujud: return "SUJUD"
        case .jalsa: return "DUDUK"
        case .unknown: return "—"
        }
    }
}
