import Foundation

/// The small, persisted result of one prayer session. This — and only this — is
/// what touches disk. **No video, no frames, no joint data is stored** (see plan,
/// "Privacy: No-Video, On-Device Only").
public struct RakaatSession: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let prayer: PrayerType
    public let rakaat: Int
    public let violations: [String]   // human-readable tuma'ninah notes

    public var isValid: Bool { violations.isEmpty }

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        prayer: PrayerType,
        rakaat: Int,
        violations: [String]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.prayer = prayer
        self.rakaat = rakaat
        self.violations = violations
    }
}
