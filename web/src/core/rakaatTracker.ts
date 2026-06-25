import { BodyJoints } from "./geometry.js";
import { violationMessage } from "./movementValidator.js";
import { Posture } from "./posture.js";
import { PostureClassifier } from "./postureClassifier.js";
import { PostureSmoother } from "./postureSmoother.js";
import { PrayerTypeInference } from "./prayerTypeInference.js";
import { RakaatSession, makeSessionId } from "./rakaatSession.js";
import { RakaatStateMachine } from "./rakaatStateMachine.js";

export interface TrackerDeps {
  classifier?: PostureClassifier;
  smoother?: PostureSmoother;
  stateMachine?: RakaatStateMachine;
  inference?: PrayerTypeInference;
}

/** Top-level pipeline the UI drives: classify → smooth → state machine. Feed it
 *  joints + timestamp per frame; read live state for the overlay and
 *  makeSession() once complete. Holds no frames. */
export class RakaatTracker {
  private classifier: PostureClassifier;
  private smoother: PostureSmoother;
  private stateMachine: RakaatStateMachine;
  private inference: PrayerTypeInference;

  constructor(deps: TrackerDeps = {}) {
    this.classifier = deps.classifier ?? new PostureClassifier();
    this.smoother = deps.smoother ?? new PostureSmoother();
    this.stateMachine = deps.stateMachine ?? new RakaatStateMachine();
    this.inference = deps.inference ?? new PrayerTypeInference();
  }

  get livePosture(): Posture {
    return this.smoother.current;
  }
  get rakaatCount(): number {
    return this.stateMachine.rakaatCount;
  }
  get isComplete(): boolean {
    return this.stateMachine.isComplete;
  }

  /** Process one frame. `t` is a monotonic timestamp in seconds. */
  process(joints: BodyJoints, t: number): Posture {
    const raw = this.classifier.classify(joints);
    const committed = this.smoother.feed(raw);
    this.stateMachine.update(committed, t);
    return committed;
  }

  /** End the session early (user taps stop). */
  stop(t: number): void {
    this.stateMachine.finish(t);
  }

  /** Build the persisted session result. Call after isComplete (or stop). */
  makeSession(date: Date = new Date()): RakaatSession {
    return {
      id: makeSessionId(),
      timestamp: date.getTime(),
      prayer: this.inference.inferAt(this.stateMachine.rakaatCount, date),
      rakaat: this.stateMachine.rakaatCount,
      violations: this.stateMachine.violations.map(violationMessage),
    };
  }

  reset(): void {
    this.smoother.reset();
    this.stateMachine.reset();
  }
}
