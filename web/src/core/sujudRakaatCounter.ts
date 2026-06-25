/** Counts rakaat from a stream of **sujud (down-posture) edges** instead of camera
 *  poses — used by the motion (IMU) mode, where the phone sits in a pocket and the
 *  body tilt tells us when the user is prostrating.
 *
 *  Each rakaat contains exactly two sujud, so `rakaatCount = ceil(sujudCount / 2)`.
 *  Pure logic, no DOM — feed it `(down, t)` edges from `MotionSensor`.
 *
 *  Mirrors the iOS `ProximityRakaatCounter`: a sujud is confirmed only after the
 *  body stays "down" at least `minSujudSeconds`, rejecting brief accidental dips. */
export class SujudRakaatCounter {
  /** Number of confirmed sujud (prostrations) seen so far. */
  sujudCount = 0;

  private coverStart: number | null = null;

  constructor(private readonly minSujudSeconds = 0.8) {}

  /** Rakaat to display / persist. `ceil(sujudCount / 2)`: shows the rakaat being
   *  performed, and equals the true count when a (even-sujud) prayer ends. */
  get rakaatCount(): number {
    return Math.floor((this.sujudCount + 1) / 2);
  }

  /** Feed one down-state edge. `down` = body in sujud/low posture; `t` is seconds. */
  feed(down: boolean, t: number): void {
    if (down) {
      if (this.coverStart === null) this.coverStart = t; // ignore repeat rising edges
    } else if (this.coverStart !== null) {
      if (t - this.coverStart >= this.minSujudSeconds) this.sujudCount += 1;
      this.coverStart = null;
    }
  }

  reset(): void {
    this.sujudCount = 0;
    this.coverStart = null;
  }
}
