import { RakaatSession } from "./core/rakaatSession.js";

const KEY = "shalat.sessions.v1";

/** Persists session summaries in localStorage. Only small structured data —
 *  never video or frames. */
export const SessionStore = {
  all(): RakaatSession[] {
    try {
      return JSON.parse(localStorage.getItem(KEY) ?? "[]") as RakaatSession[];
    } catch {
      return [];
    }
  },

  add(session: RakaatSession): void {
    const list = SessionStore.all();
    list.unshift(session);
    localStorage.setItem(KEY, JSON.stringify(list));
  },

  clear(): void {
    localStorage.removeItem(KEY);
  },
};
