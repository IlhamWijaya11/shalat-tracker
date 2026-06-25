export enum PrayerType {
  Subuh = "subuh",
  Dzuhur = "dzuhur",
  Ashar = "ashar",
  Maghrib = "maghrib",
  Isya = "isya",
  Unknown = "unknown",
}

export function prayerDisplayName(p: PrayerType): string {
  switch (p) {
    case PrayerType.Subuh:
      return "Subuh";
    case PrayerType.Dzuhur:
      return "Dzuhur";
    case PrayerType.Ashar:
      return "Ashar";
    case PrayerType.Maghrib:
      return "Maghrib";
    case PrayerType.Isya:
      return "Isya";
    default:
      return "Tidak diketahui";
  }
}

export interface PrayerWindow {
  prayer: PrayerType;
  startMinute: number;
  endMinute: number;
}

/** Half-open windows [start, end) in minutes-from-midnight mapping wall-clock
 *  time to the active prayer. The app can replace this with real times from a
 *  prayer-time library; this fixed set is the offline fallback. */
export class PrayerWindows {
  constructor(public windows: PrayerWindow[]) {}

  static fallback(): PrayerWindows {
    return new PrayerWindows([
      { prayer: PrayerType.Subuh, startMinute: 4 * 60, endMinute: 6 * 60 },
      { prayer: PrayerType.Dzuhur, startMinute: 11 * 60 + 30, endMinute: 15 * 60 },
      { prayer: PrayerType.Ashar, startMinute: 15 * 60, endMinute: 18 * 60 },
      { prayer: PrayerType.Maghrib, startMinute: 18 * 60, endMinute: 19 * 60 },
      { prayer: PrayerType.Isya, startMinute: 19 * 60, endMinute: 24 * 60 },
    ]);
  }

  prayerAtMinutes(m: number): PrayerType {
    for (const w of this.windows) {
      if (m >= w.startMinute && m < w.endMinute) return w.prayer;
    }
    return PrayerType.Unknown;
  }
}
