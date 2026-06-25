import { Posture, postureLabel } from "./posture.js";

export interface TumaninahViolation {
  rakaat: number;
  posture: Posture;
  duration: number;
}

/** Indonesian message for the result screen. */
export function violationMessage(v: TumaninahViolation): string {
  const name = postureLabel(v.posture);
  const cap = name.charAt(0) + name.slice(1).toLowerCase();
  return `${cap} rakaat ${v.rakaat} terlalu cepat (${v.duration.toFixed(1)}s)`;
}

/** Checks tuma'ninah: key postures must be held at least a minimum time.
 *  v1 validates ruku & sujud (unambiguous cases). */
export class MovementValidator {
  constructor(
    public minDwell: Partial<Record<Posture, number>> = {
      [Posture.Ruku]: 1.0,
      [Posture.Sujud]: 1.0,
    }
  ) {}

  /** Returns a violation if this segment is a validated posture held too briefly. */
  check(posture: Posture, duration: number, rakaat: number): TumaninahViolation | null {
    const minimum = this.minDwell[posture];
    if (minimum === undefined || duration >= minimum) return null;
    return { rakaat, posture, duration };
  }
}
