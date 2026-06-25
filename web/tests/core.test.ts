import { describe, expect, it } from "vitest";
import { poseFeaturesFrom } from "../src/core/poseFeatures.js";
import { Posture } from "../src/core/posture.js";
import { PostureClassifier } from "../src/core/postureClassifier.js";
import { PostureSmoother } from "../src/core/postureSmoother.js";
import { MovementValidator } from "../src/core/movementValidator.js";
import { RakaatStateMachine } from "../src/core/rakaatStateMachine.js";
import { PrayerTypeInference } from "../src/core/prayerTypeInference.js";
import { PrayerType } from "../src/core/prayerType.js";
import { RakaatTracker } from "../src/core/rakaatTracker.js";
import { BodyJoints } from "../src/core/geometry.js";
import { Fixtures } from "./fixtures.js";

describe("PostureClassifier", () => {
  const c = new PostureClassifier();
  it("classifies each posture", () => {
    expect(c.classify(Fixtures.standing)).toBe(Posture.Standing);
    expect(c.classify(Fixtures.ruku)).toBe(Posture.Ruku);
    expect(c.classify(Fixtures.sujud)).toBe(Posture.Sujud);
    expect(c.classify(Fixtures.jalsa)).toBe(Posture.Jalsa);
  });
  it("returns unknown without enough joints", () => {
    expect(c.classify({} as BodyJoints)).toBe(Posture.Unknown);
    expect(c.classify({ nose: { x: 0.5, y: 0.9 } })).toBe(Posture.Unknown);
  });
  it("standing is upright, ruku is tilted", () => {
    const s = poseFeaturesFrom(Fixtures.standing)!;
    expect(s.torsoAngle).toBeLessThan(20);
    expect(s.hipAboveAnkle).toBeGreaterThan(0.8);
    const r = poseFeaturesFrom(Fixtures.ruku)!;
    expect(r.torsoAngle).toBeGreaterThan(45);
    expect(r.headAboveAnkle).toBeGreaterThan(0.6);
  });
});

describe("PostureSmoother", () => {
  it("holds until stable then commits", () => {
    const s = new PostureSmoother(3);
    expect(s.feed(Posture.Standing)).toBe(Posture.Unknown);
    expect(s.feed(Posture.Standing)).toBe(Posture.Unknown);
    expect(s.feed(Posture.Standing)).toBe(Posture.Standing);
  });
  it("ignores single-frame jitter", () => {
    const s = new PostureSmoother(3);
    s.feed(Posture.Standing); s.feed(Posture.Standing); s.feed(Posture.Standing);
    expect(s.feed(Posture.Ruku)).toBe(Posture.Standing);
    expect(s.feed(Posture.Standing)).toBe(Posture.Standing);
  });
});

describe("RakaatStateMachine", () => {
  function sequence(n: number): Array<[Posture, number]> {
    const out: Array<[Posture, number]> = [];
    let t = 0;
    const add = (p: Posture, hold = 2) => { out.push([p, t]); t += hold; };
    for (let i = 0; i < n; i++) {
      add(Posture.Standing); add(Posture.Ruku); add(Posture.Standing);
      add(Posture.Sujud); add(Posture.Jalsa); add(Posture.Sujud);
    }
    out.push([Posture.Jalsa, t]); t += 8;
    out.push([Posture.Jalsa, t]);
    return out;
  }
  function run(seq: Array<[Posture, number]>): RakaatStateMachine {
    const sm = new RakaatStateMachine();
    for (const [p, t] of seq) sm.update(p, t);
    return sm;
  }
  it("counts 2 rakaat and completes", () => {
    const sm = run(sequence(2));
    expect(sm.rakaatCount).toBe(2);
    expect(sm.isComplete).toBe(true);
  });
  it("counts 4 rakaat", () => {
    expect(run(sequence(4)).rakaatCount).toBe(4);
  });
  it("counts 3 rakaat", () => {
    expect(run(sequence(3)).rakaatCount).toBe(3);
  });
  it("does not double-count repeated ruku frames", () => {
    const sm = new RakaatStateMachine();
    sm.update(Posture.Standing, 0);
    sm.update(Posture.Ruku, 2);
    sm.update(Posture.Ruku, 2.1);
    sm.update(Posture.Ruku, 2.2);
    expect(sm.rakaatCount).toBe(1);
  });
});

describe("MovementValidator", () => {
  const v = new MovementValidator();
  it("flags short ruku", () => {
    expect(v.check(Posture.Ruku, 0.4, 1)).toEqual({ rakaat: 1, posture: Posture.Ruku, duration: 0.4 });
  });
  it("accepts held ruku and ignores unvalidated postures", () => {
    expect(v.check(Posture.Ruku, 1.5, 1)).toBeNull();
    expect(v.check(Posture.Standing, 0.1, 1)).toBeNull();
  });
  it("state machine records a rush violation", () => {
    const sm = new RakaatStateMachine();
    sm.update(Posture.Standing, 0);
    sm.update(Posture.Ruku, 2.0);
    sm.update(Posture.Standing, 2.4);
    expect(sm.violations.length).toBe(1);
    expect(sm.violations[0].posture).toBe(Posture.Ruku);
  });
});

describe("PrayerTypeInference", () => {
  const infer = new PrayerTypeInference();
  it("maps rakaat + time to prayer", () => {
    expect(infer.infer(2, 5 * 60)).toBe(PrayerType.Subuh);
    expect(infer.infer(3, 18 * 60 + 30)).toBe(PrayerType.Maghrib);
    expect(infer.infer(4, 13 * 60)).toBe(PrayerType.Dzuhur);
    expect(infer.infer(4, 16 * 60)).toBe(PrayerType.Ashar);
    expect(infer.infer(4, 20 * 60)).toBe(PrayerType.Isya);
    expect(infer.infer(4, 3 * 60)).toBe(PrayerType.Unknown);
  });
});

describe("RakaatTracker end-to-end", () => {
  it("2-rakaat Subuh from synthetic frames", () => {
    const tracker = new RakaatTracker();
    let t = 0;
    const dt = 0.2;
    const feed = (j: BodyJoints, seconds: number) => {
      const frames = Math.floor(seconds / dt);
      for (let i = 0; i < frames; i++) { tracker.process(j, t); t += dt; }
    };
    const rakaat = () => {
      feed(Fixtures.standing, 2); feed(Fixtures.ruku, 2); feed(Fixtures.standing, 2);
      feed(Fixtures.sujud, 2); feed(Fixtures.jalsa, 1.5); feed(Fixtures.sujud, 2);
    };
    rakaat(); rakaat();
    feed(Fixtures.jalsa, 8);
    expect(tracker.rakaatCount).toBe(2);
    expect(tracker.isComplete).toBe(true);
    const session = tracker.makeSession(new Date(2026, 5, 24, 5, 0));
    expect(session.prayer).toBe(PrayerType.Subuh);
    expect(session.rakaat).toBe(2);
  });
});
