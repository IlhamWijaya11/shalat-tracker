#if os(iOS)
import Foundation
import CoreLocation
import RakaatCore

/// Supplies `PrayerWindows` for inference. The default implementation returns the
/// fixed fallback; the Adhan-backed one computes real times from location.
public protocol PrayerTimeProviding {
    func windows(for date: Date) -> PrayerWindows
}

/// No-location fallback (rough fixed windows). Always available, fully offline.
public struct FallbackPrayerTimeProvider: PrayerTimeProviding {
    public init() {}
    public func windows(for date: Date) -> PrayerWindows { .fallback }
}

// MARK: - Adhan integration (add the `Adhan` Swift Package on the Mac)
//
// Add https://github.com/batoulapps/adhan-swift via SwiftPM, then build windows
// from each prayer's start time to the next prayer's start:
//
//   import Adhan
//   let coords = Coordinates(latitude: lat, longitude: lon)
//   let params = CalculationMethod.muslimWorldLeague.params  // pick per region
//   let times  = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)
//   // map times.fajr/dhuhr/asr/maghrib/isha → PrayerWindows minute ranges
//
// Keep it offline: Adhan computes locally from lat/long + date, no network.
#endif
