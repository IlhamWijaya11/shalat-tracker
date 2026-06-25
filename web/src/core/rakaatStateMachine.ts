import { MovementValidator, TumaninahViolation } from "./movementValidator.js";
import { Posture } from "./posture.js";

export interface Segment {
  posture: Posture;
  start: number;
  end: number;
}

export function segmentDuration(s: Segment): number {
  return s.end - s.start;
}

export interface StateMachineOptions {
  validator?: MovementValidator;
  /** A jalsa held at least this long (after min rakaat) marks the end. */
  finalSitSeconds?: number;
  minRakaatForComplete?: number;
}

/** Counts rakaat from a stream of committed postures + timestamps.
 *
 *  Core insight: **each rakaat contains exactly one ruku**, so rakaat count =
 *  the number of times the body enters the ruku posture. A long final sit
 *  (tashahhud) detects the end. Feed it the smoothed posture once per frame. */
export class RakaatStateMachine {
  rakaatCount = 0;
  isComplete = false;
  segments: Segment[] = [];
  violations: TumaninahViolation[] = [];

  private readonly validator: MovementValidator;
  private readonly finalSitSeconds: number;
  private readonly minRakaatForComplete: number;

  private currentPosture = Posture.Unknown;
  private segmentStart = 0;
  private started = false;

  constructor(opts: StateMachineOptions = {}) {
    this.validator = opts.validator ?? new MovementValidator();
    this.finalSitSeconds = opts.finalSitSeconds ?? 6.0;
    this.minRakaatForComplete = opts.minRakaatForComplete ?? 2;
  }

  /** Feed one frame. `posture` should already be smoothed; `t` is seconds. */
  update(posture: Posture, t: number): void {
    if (this.isComplete) return;

    if (!this.started) {
      this.started = true;
      this.currentPosture = posture;
      this.segmentStart = t;
      if (posture === Posture.Ruku) this.rakaatCount += 1;
      return;
    }

    if (posture !== this.currentPosture) {
      this.closeSegment(t);
      if (posture === Posture.Ruku) this.rakaatCount += 1; // one ruku = one rakaat
      this.currentPosture = posture;
      this.segmentStart = t;
    }

    // Long sustained sitting after enough rakaat ⇒ tashahhud / session end.
    if (
      this.currentPosture === Posture.Jalsa &&
      this.rakaatCount >= this.minRakaatForComplete &&
      t - this.segmentStart >= this.finalSitSeconds
    ) {
      this.closeSegment(t);
      this.isComplete = true;
    }
  }

  /** Force-close the session (user taps stop), flushing the open segment. */
  finish(t: number): void {
    if (!this.started || this.isComplete) return;
    this.closeSegment(t);
    this.isComplete = true;
  }

  private closeSegment(end: number): void {
    const seg: Segment = { posture: this.currentPosture, start: this.segmentStart, end };
    this.segments.push(seg);
    const rakaat = Math.max(1, this.rakaatCount); // pre-first-ruku belongs to rakaat 1
    const v = this.validator.check(seg.posture, segmentDuration(seg), rakaat);
    if (v) this.violations.push(v);
  }

  reset(): void {
    this.rakaatCount = 0;
    this.isComplete = false;
    this.segments = [];
    this.violations = [];
    this.currentPosture = Posture.Unknown;
    this.segmentStart = 0;
    this.started = false;
  }
}
