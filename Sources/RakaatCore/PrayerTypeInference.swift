import Foundation

/// Infers which prayer this was from the rakaat count plus the time of day.
///
/// Logic:
/// - 2 rakaat ⇒ Subuh
/// - 3 rakaat ⇒ Maghrib
/// - 4 rakaat ⇒ Dzuhur / Ashar / Isya, disambiguated by the time window
/// The time window is the tie-breaker (and a sanity check) for every count.
public struct PrayerTypeInference: Sendable {
    public var windows: PrayerWindows

    public init(windows: PrayerWindows = .fallback) {
        self.windows = windows
    }

    /// `minutesOfDay` = hour*60 + minute (0...1439).
    public func infer(rakaat: Int, minutesOfDay: Int) -> PrayerType {
        let byTime = windows.prayer(atMinutes: minutesOfDay)
        switch rakaat {
        case 2: return .subuh
        case 3: return .maghrib
        case 4:
            // Prefer the active time window when it's a 4-rakaat prayer.
            if byTime == .dzuhur || byTime == .ashar || byTime == .isya { return byTime }
            return .unknown
        default:
            return .unknown
        }
    }

    /// Convenience overload taking a `Date` in the current calendar.
    public func infer(rakaat: Int, at date: Date, calendar: Calendar = .current) -> PrayerType {
        let c = calendar.dateComponents([.hour, .minute], from: date)
        let minutes = (c.hour ?? 0) * 60 + (c.minute ?? 0)
        return infer(rakaat: rakaat, minutesOfDay: minutes)
    }
}
