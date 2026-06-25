export enum Posture {
  Standing = "standing", // qiyam / i'tidal — torso upright, hips high
  Ruku = "ruku", // bowing — torso ~horizontal, head still high
  Sujud = "sujud", // prostration — torso low, head near floor
  Jalsa = "jalsa", // sitting — torso upright, hips low
  Unknown = "unknown", // not enough joints
}

/** Indonesian label for the live overlay. */
export function postureLabel(p: Posture): string {
  switch (p) {
    case Posture.Standing:
      return "BERDIRI";
    case Posture.Ruku:
      return "RUKU";
    case Posture.Sujud:
      return "SUJUD";
    case Posture.Jalsa:
      return "DUDUK";
    default:
      return "—";
  }
}
