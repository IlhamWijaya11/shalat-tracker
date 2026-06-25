import { PrayerType } from "./prayerType.js";

/** The small, persisted result of one prayer session. This — and only this — is
 *  stored (in IndexedDB/localStorage). **No video, no frames, no joint data.** */
export interface RakaatSession {
  id: string;
  timestamp: number; // epoch ms
  prayer: PrayerType;
  rakaat: number;
  violations: string[]; // human-readable tuma'ninah notes
}

export function sessionIsValid(s: RakaatSession): boolean {
  return s.violations.length === 0;
}

export function makeSessionId(): string {
  return (crypto as Crypto | undefined)?.randomUUID?.() ?? `s_${Date.now()}_${Math.random().toString(36).slice(2)}`;
}
