import { PrayerType, PrayerWindows } from "./prayerType.js";

/** Infers which prayer this was from rakaat count + time of day.
 *  - 2 rakaat ⇒ Subuh
 *  - 3 rakaat ⇒ Maghrib
 *  - 4 rakaat ⇒ Dzuhur / Ashar / Isya, disambiguated by the time window */
export class PrayerTypeInference {
  constructor(public windows: PrayerWindows = PrayerWindows.fallback()) {}

  /** `minutesOfDay` = hour*60 + minute (0..1439). */
  infer(rakaat: number, minutesOfDay: number): PrayerType {
    const byTime = this.windows.prayerAtMinutes(minutesOfDay);
    switch (rakaat) {
      case 2:
        return PrayerType.Subuh;
      case 3:
        return PrayerType.Maghrib;
      case 4:
        if (byTime === PrayerType.Dzuhur || byTime === PrayerType.Ashar || byTime === PrayerType.Isya) {
          return byTime;
        }
        return PrayerType.Unknown;
      default:
        return PrayerType.Unknown;
    }
  }

  inferAt(rakaat: number, date: Date): PrayerType {
    return this.infer(rakaat, date.getHours() * 60 + date.getMinutes());
  }
}
