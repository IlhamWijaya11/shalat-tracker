import Foundation

/// The five daily fardh prayers (plus unknown for ambiguous cases).
public enum PrayerType: String, Equatable, Sendable, CaseIterable {
    case subuh
    case dzuhur
    case ashar
    case maghrib
    case isya
    case unknown

    public var displayName: String {
        switch self {
        case .subuh: return "Subuh"
        case .dzuhur: return "Dzuhur"
        case .ashar: return "Ashar"
        case .maghrib: return "Maghrib"
        case .isya: return "Isya"
        case .unknown: return "Tidak diketahui"
        }
    }

    /// Canonical fardh rakaat count.
    public var rakaat: Int {
        switch self {
        case .subuh: return 2
        case .maghrib: return 3
        case .dzuhur, .ashar, .isya: return 4
        case .unknown: return 0
        }
    }
}

/// Half-open time windows [start, end) in minutes-from-midnight that map a
/// wall-clock time to the currently-active prayer. The iOS app fills these from
/// the Adhan library (location-based); this struct keeps inference testable and
/// provides a rough fallback.
public struct PrayerWindows: Sendable {
    /// (prayer, startMinute, endMinute). Order does not matter.
    public var windows: [(PrayerType, Int, Int)]

    public init(windows: [(PrayerType, Int, Int)]) {
        self.windows = windows
    }

    /// Rough fixed fallback when no location is available.
    public static let fallback = PrayerWindows(windows: [
        (.subuh,   4 * 60,  6 * 60),       // 04:00–06:00
        (.dzuhur, 11 * 60 + 30, 15 * 60),  // 11:30–15:00
        (.ashar,  15 * 60, 18 * 60),       // 15:00–18:00
        (.maghrib,18 * 60, 19 * 60),       // 18:00–19:00
        (.isya,   19 * 60, 24 * 60),       // 19:00–24:00
    ])

    public func prayer(atMinutes m: Int) -> PrayerType {
        for (p, s, e) in windows where m >= s && m < e { return p }
        return .unknown
    }
}
