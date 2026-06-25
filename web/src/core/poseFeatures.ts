import {
  BodyJoints,
  Point2D,
  ankleMid,
  head,
  hipMid,
  length,
  shoulderMid,
  sub,
} from "./geometry.js";

/** Scale-invariant features derived from one frame's joints. Vertical distances
 *  are normalized by torso length (shoulder→hip), which stays roughly constant
 *  across postures, so thresholds don't depend on camera distance. */
export interface PoseFeatures {
  /** Spine angle from vertical, degrees 0..180. ~0 upright, ~90 horizontal. */
  torsoAngle: number;
  /** (head.y − ankle.y)/torsoLength. High standing/ruku, low in sujud. */
  headAboveAnkle: number;
  /** (hip.y − ankle.y)/torsoLength. High standing, low sitting. */
  hipAboveAnkle: number;
  /** (head.y − hip.y)/torsoLength. Positive standing, ~0 ruku, negative sujud. */
  headAboveHip: number;
}

/** Returns null if required joints are missing or the body has no scale. */
export function poseFeaturesFrom(j: BodyJoints): PoseFeatures | null {
  const shoulder = shoulderMid(j);
  const hip = hipMid(j);
  const ankle = ankleMid(j);
  const h = head(j);
  if (!shoulder || !hip || !ankle || !h) return null;

  const torso: Point2D = sub(shoulder, hip);
  const torsoLength = length(torso);
  if (torsoLength <= 1e-6) return null;

  // Angle from vertical (0,1): cos = torso.y / |torso|.
  const cosA = Math.max(-1, Math.min(1, torso.y / torsoLength));
  const torsoAngle = (Math.acos(cosA) * 180) / Math.PI;

  return {
    torsoAngle,
    headAboveAnkle: (h.y - ankle.y) / torsoLength,
    hipAboveAnkle: (hip.y - ankle.y) / torsoLength,
    headAboveHip: (h.y - hip.y) / torsoLength,
  };
}
