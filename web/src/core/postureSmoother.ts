import { Posture } from "./posture.js";

/** Debounces a noisy per-frame posture stream into a stable "committed" posture.
 *  A new posture must persist for `holdFrames` consecutive frames before it
 *  replaces the committed one — kills single-frame jitter without much lag. */
export class PostureSmoother {
  private committed = Posture.Unknown;
  private candidate = Posture.Unknown;
  private candidateRun = 0;
  private readonly holdFrames: number;

  constructor(holdFrames = 4) {
    this.holdFrames = Math.max(1, holdFrames);
  }

  get current(): Posture {
    return this.committed;
  }

  /** Feed one raw classification; returns the (possibly unchanged) committed posture. */
  feed(raw: Posture): Posture {
    if (raw === this.candidate) {
      this.candidateRun += 1;
    } else {
      this.candidate = raw;
      this.candidateRun = 1;
    }
    if (this.candidate !== this.committed && this.candidateRun >= this.holdFrames) {
      this.committed = this.candidate;
    }
    return this.committed;
  }

  reset(): void {
    this.committed = Posture.Unknown;
    this.candidate = Posture.Unknown;
    this.candidateRun = 0;
  }
}
