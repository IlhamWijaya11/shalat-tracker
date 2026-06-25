import { describe, expect, it } from "vitest";
import { SujudRakaatCounter } from "../src/core/sujudRakaatCounter.js";

/** One sujud = down at `start`, up after `held` seconds. */
function sujud(c: SujudRakaatCounter, start: number, held: number): void {
  c.feed(true, start);
  c.feed(false, start + held);
}

describe("SujudRakaatCounter", () => {
  it("two sujud = one rakaat", () => {
    const c = new SujudRakaatCounter(0.8);
    sujud(c, 0, 2);
    expect(c.sujudCount).toBe(1);
    expect(c.rakaatCount).toBe(1); // mid-rakaat after first sujud
    sujud(c, 5, 2);
    expect(c.sujudCount).toBe(2);
    expect(c.rakaatCount).toBe(1); // rakaat 1 complete
  });

  it("four sujud = two rakaat", () => {
    const c = new SujudRakaatCounter(0.8);
    for (let i = 0; i < 4; i++) sujud(c, i * 5, 2);
    expect(c.rakaatCount).toBe(2);
  });

  it("ignores a brief dip below the threshold", () => {
    const c = new SujudRakaatCounter(0.8);
    sujud(c, 0, 0.3);
    expect(c.sujudCount).toBe(0);
  });

  it("does not double-count repeated down edges", () => {
    const c = new SujudRakaatCounter(0.8);
    c.feed(true, 0);
    c.feed(true, 1); // duplicate rising edge — keep earliest start
    c.feed(false, 2);
    expect(c.sujudCount).toBe(1);
  });

  it("reset clears state", () => {
    const c = new SujudRakaatCounter();
    sujud(c, 0, 2);
    c.reset();
    expect(c.sujudCount).toBe(0);
    expect(c.rakaatCount).toBe(0);
  });
});
